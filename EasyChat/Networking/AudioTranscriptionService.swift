//
//  AudioTranscriptionService.swift
//  EasyChat
//
//  Created by Talha Çelebi on 26.12.2025.
//

import Foundation
import AVFoundation

protocol AudioTranscriptionServiceDelegate: AnyObject {
    func didReceiveTranscription(speakers: [Speaker])
    func didReceiveError(message: String)
    func connectionStatusChanged(isConnected: Bool)
}

class AudioTranscriptionService: NSObject, URLSessionWebSocketDelegate {
    
    weak var delegate: AudioTranscriptionServiceDelegate?
    
    private var webSocketTask: URLSessionWebSocketTask?
    private var urlSession: URLSession?
    private var audioEngine: AVAudioEngine?
    private var isRecording = false
    private var isConnected = false
    private var shouldReceiveMessages = false
    
    // Mac'inizin IP adresini buraya yazın
    // Terminal'de: ifconfig | grep "inet " | grep -v 127.0.0.1
    // Backend'i başlatırken: uvicorn main:app --host 0.0.0.0 --port 8000 --reload
    private let backendURL = "ws://192.168.1.167:8000/ws/audio"
    
    func connect() {
        guard let url = URL(string: backendURL) else {
            print("❌ Geçersiz URL")
            DispatchQueue.main.async {
                self.delegate?.didReceiveError(message: "Geçersiz URL: \(self.backendURL)")
            }
            return
        }
        
        // Önce backend'in erişilebilir olduğunu kontrol et
        checkBackendHealth { [weak self] isHealthy in
            guard let self = self else { return }
            if !isHealthy {
                DispatchQueue.main.async {
                    self.delegate?.didReceiveError(message: "Backend'e erişilemiyor. Backend'in çalıştığından ve IP adresinin doğru olduğundan emin olun.")
                }
                return
            }
            
            // Eğer zaten bağlıysa, önce bağlantıyı kapat
            if self.isConnected {
                self.disconnect()
            }
            
            // Önceki bağlantıyı temizle
            if let existingTask = self.webSocketTask {
                existingTask.cancel(with: .goingAway, reason: nil)
                self.webSocketTask = nil
            }
            
            // URLSession'ı WebSocket için optimize edilmiş yapılandırma ile oluştur
            let config = URLSessionConfiguration.default
            config.timeoutIntervalForRequest = 30.0  // Diarization işlemi uzun sürebilir
            config.timeoutIntervalForResource = 120.0  // Toplam işlem süresi için daha uzun timeout
            config.waitsForConnectivity = true
            
            self.urlSession = URLSession(configuration: config, delegate: self, delegateQueue: OperationQueue.main)
            self.webSocketTask = self.urlSession?.webSocketTask(with: url)
            
            self.isConnected = false
            self.shouldReceiveMessages = true
            
            // WebSocket task state'ini logla
            if let task = self.webSocketTask {
                print("📡 WebSocket task oluşturuldu, state: \(task.state.rawValue)")
                print("📡 URL: \(url.absoluteString)")
            }
            
            self.webSocketTask?.resume()
            
            // Resume sonrası state'i kontrol et
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [weak self] in
                if let task = self?.webSocketTask {
                    print("📡 WebSocket task state (0.5s sonra): \(task.state.rawValue)")
                }
            }
            
            // Bağlantı timeout kontrolü
            DispatchQueue.main.asyncAfter(deadline: .now() + 30.0) { [weak self] in
                guard let self = self else { return }
                if !self.isConnected {
                    print("⏱️ Bağlantı zaman aşımı")
                    self.webSocketTask?.cancel(with: .goingAway, reason: nil)
                    DispatchQueue.main.async {
                        self.delegate?.didReceiveError(message: "Bağlantı zaman aşımı. Backend'in çalıştığından ve IP adresinin doğru olduğundan emin olun.")
                    }
                }
            }
            
            print("🔄 WebSocket bağlantısı deneniyor: \(self.backendURL)")
        }
    }
    
    // Backend'in erişilebilir olduğunu kontrol et
    private func checkBackendHealth(completion: @escaping (Bool) -> Void) {
        let baseURL = backendURL.replacingOccurrences(of: "ws://", with: "http://").replacingOccurrences(of: "/ws/audio", with: "")
        guard let healthURL = URL(string: "\(baseURL)/health") else {
            completion(false)
            return
        }
        
        var request = URLRequest(url: healthURL)
        request.timeoutInterval = 5.0
        request.httpMethod = "GET"
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("⚠️ Health check hatası: \(error.localizedDescription)")
                completion(false)
                return
            }
            
            if let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 {
                print("✅ Backend erişilebilir")
                completion(true)
            } else {
                print("⚠️ Backend health check başarısız")
                completion(false)
            }
        }
        task.resume()
    }
    
    func disconnect() {
        shouldReceiveMessages = false
        stopRecording()
        
        // Eğer bağlıysa, önce "end" mesajı gönder
        if isConnected, let task = webSocketTask {
            let message = URLSessionWebSocketTask.Message.string("end")
            task.send(message) { error in
                if let error = error {
                    print("⚠️ End mesajı gönderilemedi: \(error.localizedDescription)")
                }
            }
            
            // Mesaj gönderildikten sonra bağlantıyı kapat
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) { [weak self] in
                task.cancel(with: .goingAway, reason: nil)
                self?.webSocketTask = nil
                self?.isConnected = false
                print("🔌 WebSocket bağlantısı kapatıldı")
                self?.delegate?.connectionStatusChanged(isConnected: false)
            }
        } else {
            webSocketTask?.cancel(with: .goingAway, reason: nil)
            webSocketTask = nil
            isConnected = false
            print("🔌 WebSocket bağlantısı kapatıldı")
            delegate?.connectionStatusChanged(isConnected: false)
        }
    }
    
    // Backend'den gelen mesajları dinle
    private func receiveMessage() {
        guard shouldReceiveMessages, let task = webSocketTask else { return }
        
        task.receive { [weak self] result in
            guard let self = self, self.shouldReceiveMessages else { return }
            
            switch result {
            case .success(let message):
                switch message {
                case .string(let text):
                    self.handleResponse(text)
                case .data(let data):
                    print("Binary data alındı: \(data.count) bytes")
                @unknown default:
                    break
                }
                // Bir sonraki mesajı dinle
                self.receiveMessage()
                
            case .failure(let error):
                // Sadece gerçek hataları göster, cancelled hatası normal
                if (error as NSError).code != NSURLErrorCancelled {
                    print("❌ WebSocket hatası: \(error)")
                    DispatchQueue.main.async {
                        self.delegate?.didReceiveError(message: error.localizedDescription)
                    }
                }
            }
        }
    }
    
    // Backend'den gelen JSON'u işle
    private func handleResponse(_ jsonString: String) {
        guard let data = jsonString.data(using: .utf8) else { return }
        
        do {
            let response = try JSONDecoder().decode(TranscriptionResponse.self, from: data)
            
            if response.status == "success" {
                if let speakers = response.speakers, !speakers.isEmpty {
                    DispatchQueue.main.async {
                        self.delegate?.didReceiveTranscription(speakers: speakers)
                    }
                }
            } else if response.status == "error" {
                let errorMessage = response.message ?? "Bilinmeyen hata"
                print("❌ Backend hatası: \(errorMessage)")
                DispatchQueue.main.async {
                    self.delegate?.didReceiveError(message: errorMessage)
                }
            }
        } catch {
            print("❌ JSON parse hatası: \(error)")
            DispatchQueue.main.async {
                self.delegate?.didReceiveError(message: "JSON parse hatası: \(error.localizedDescription)")
            }
        }
    }
    
    // URLSessionWebSocketDelegate
    func urlSession(_ session: URLSession, webSocketTask: URLSessionWebSocketTask, didOpenWithProtocol `protocol`: String?) {
        print("✅ WebSocket bağlantısı açıldı")
        let protocolString = `protocol` ?? "none"
        print("📡 Protocol: \(protocolString)")
        print("📡 Task state: \(webSocketTask.state.rawValue)")
        isConnected = true
        
        // Bağlantı açıldıktan sonra mesaj dinlemeye başla
        receiveMessage()
        
        DispatchQueue.main.async {
            self.delegate?.connectionStatusChanged(isConnected: true)
        }
    }
    
    func urlSession(_ session: URLSession, webSocketTask: URLSessionWebSocketTask, didCloseWith closeCode: URLSessionWebSocketTask.CloseCode, reason: Data?) {
        let reasonString = reason.flatMap { String(data: $0, encoding: .utf8) } ?? "Bilinmeyen neden"
        print("🔌 WebSocket bağlantısı kapandı. Kod: \(closeCode.rawValue), Neden: \(reasonString)")
        
        shouldReceiveMessages = false
        isConnected = false
        
        // Eğer kayıt sırasında bağlantı kesildiyse hata göster
        if isRecording {
            DispatchQueue.main.async {
                self.delegate?.didReceiveError(message: "Bağlantı kesildi. Backend'in çalıştığından emin olun.")
            }
        }
        
        DispatchQueue.main.async {
            self.delegate?.connectionStatusChanged(isConnected: false)
        }
    }
    
    func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
        shouldReceiveMessages = false
        isConnected = false
        
        if let error = error {
            let nsError = error as NSError
            print("📡 Task completed with error:")
            print("   Code: \(nsError.code)")
            print("   Domain: \(nsError.domain)")
            print("   Description: \(error.localizedDescription)")
            if let userInfo = nsError.userInfo as? [String: Any] {
                print("   UserInfo: \(userInfo)")
            }
            
            // Cancelled hatası normal (kullanıcı bağlantıyı kapattığında)
            if nsError.code == NSURLErrorCancelled {
                print("ℹ️ WebSocket bağlantısı iptal edildi")
                return
            }
            
            print("❌ WebSocket bağlantı hatası: \(error.localizedDescription)")
            DispatchQueue.main.async {
                var errorMessage = "Bağlantı kurulamadı.\n\n"
                errorMessage += "Kontrol edin:\n"
                errorMessage += "• Backend çalışıyor mu? (Port 8000)\n"
                errorMessage += "• IP adresi doğru mu? (\(self.backendURL))\n"
                errorMessage += "• Aynı WiFi ağında mısınız?\n"
                errorMessage += "• Firewall portu engelliyor mu?\n\n"
                errorMessage += "Hata: \(error.localizedDescription)"
                self.delegate?.didReceiveError(message: errorMessage)
            }
        } else {
            print("📡 Task completed successfully")
        }
    }
}

// MARK: - Audio Recording
extension AudioTranscriptionService {
    
    func startRecording() {
        // Mikrofon izni iste
        AVAudioSession.sharedInstance().requestRecordPermission { [weak self] granted in
            guard granted else {
                print("❌ Mikrofon izni reddedildi")
                DispatchQueue.main.async {
                    self?.delegate?.didReceiveError(message: "Mikrofon izni reddedildi")
                }
                return
            }
            
            DispatchQueue.main.async {
                self?.setupAudioEngine()
            }
        }
    }
    
    private func setupAudioEngine() {
        // Önce mevcut engine'i temizle
        stopRecording()
        
        // Audio session'ı yapılandır
        do {
            let audioSession = AVAudioSession.sharedInstance()
            try audioSession.setCategory(.record, mode: .measurement, options: [])
            try audioSession.setActive(true)
        } catch {
            print("❌ Audio session yapılandırılamadı: \(error)")
            delegate?.didReceiveError(message: "Audio session yapılandırılamadı: \(error.localizedDescription)")
            return
        }
        
        audioEngine = AVAudioEngine()
        guard let audioEngine = audioEngine else { return }
        
        let inputNode = audioEngine.inputNode
        let recordingFormat = inputNode.outputFormat(forBus: 0)
        
        // Format validation
        guard recordingFormat.sampleRate > 0 && recordingFormat.channelCount > 0 else {
            print("❌ Geçersiz recording format")
            return
        }
        
        // 16kHz, mono format (backend için ideal)
        guard let desiredFormat = AVAudioFormat(
            commonFormat: .pcmFormatInt16,
            sampleRate: 16000,
            channels: 1,
            interleaved: false
        ) else {
            print("❌ Format oluşturulamadı")
            return
        }
        
        // Format dönüşümü
        guard let converter = AVAudioConverter(from: recordingFormat, to: desiredFormat) else {
            print("❌ Format dönüşümü başarısız")
            return
        }
        
        inputNode.installTap(onBus: 0, bufferSize: 1024, format: recordingFormat) { [weak self] buffer, time in
            // Ses buffer'ını backend formatına çevir
            guard let self = self, self.isRecording else { return }
            
            let frameCapacity = AVAudioFrameCount(Double(buffer.frameLength) * desiredFormat.sampleRate / recordingFormat.sampleRate)
            guard frameCapacity > 0,
                  let convertedBuffer = AVAudioPCMBuffer(
                      pcmFormat: desiredFormat,
                      frameCapacity: frameCapacity
                  ) else { return }
            
            var error: NSError?
            let inputBlock: AVAudioConverterInputBlock = { _, outStatus in
                outStatus.pointee = .haveData
                return buffer
            }
            
            converter.convert(to: convertedBuffer, error: &error, withInputFrom: inputBlock)
            
            if let error = error {
                print("❌ Dönüşüm hatası: \(error)")
                return
            }
            
            // Ses verisini backend'e gönder
            if let channelData = convertedBuffer.int16ChannelData {
                let data = Data(bytes: channelData[0], count: Int(convertedBuffer.frameLength) * 2)
                self.sendAudioData(data)
            }
        }
        
        do {
            try audioEngine.start()
            isRecording = true
            print("🎤 Kayıt başladı")
        } catch {
            print("❌ Ses motoru başlatılamadı: \(error)")
            delegate?.didReceiveError(message: "Ses motoru başlatılamadı: \(error.localizedDescription)")
        }
    }
    
    func stopRecording() {
        guard isRecording || audioEngine != nil else { return }
        
        isRecording = false
        
        // Önce tap'i kaldır (engine durmadan önce)
        if let audioEngine = audioEngine, audioEngine.isRunning {
            audioEngine.inputNode.removeTap(onBus: 0)
        }
        
        // Sonra engine'i durdur
        if let audioEngine = audioEngine {
            audioEngine.stop()
        }
        
        // Audio session'ı deaktif et
        do {
            try AVAudioSession.sharedInstance().setActive(false, options: .notifyOthersOnDeactivation)
        } catch {
            print("⚠️ Audio session deaktif edilemedi: \(error)")
        }
        
        audioEngine = nil
        print("🛑 Kayıt durduruldu")
    }
    
    // Ses verisini backend'e gönder
    private func sendAudioData(_ data: Data) {
        guard isConnected, let task = webSocketTask else { return }
        
        let message = URLSessionWebSocketTask.Message.data(data)
        task.send(message) { error in
            if let error = error {
                let nsError = error as NSError
                // Cancelled hatası normal
                if nsError.code != NSURLErrorCancelled {
                    print("❌ Ses gönderme hatası: \(error)")
                }
            }
        }
    }
}

