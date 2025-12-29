//
//  SpeakerVC.swift
//  EasyChat
//
//  Created by Talha Çelebi on 24.11.2025.
//

import UIKit
import AVFoundation

class SpeakerVC: UIViewController, AVSpeechSynthesizerDelegate {

    @IBOutlet weak var speakerBackView: UIView!
    @IBOutlet weak var textView: UITextView!
    @IBOutlet weak var bottomView: UIView!
    @IBOutlet weak var speakDesc: UILabel!
    @IBOutlet weak var speakerImg: UIImageView!
    @IBOutlet weak var headerdescLbl: UILabel!
    
    private let synthesizer = AVSpeechSynthesizer()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = AppColors.background
        setupAudioSession()
        synthesizer.delegate = self
        setupTapToDismissKeyboard()
        setUI()
    }
    
    private func setupTapToDismissKeyboard() {
        // Ekranın herhangi bir yerine tıklandığında klavyeyi kapat
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        tapGesture.cancelsTouchesInView = false // Diğer gesture'ları engelleme
        view.addGestureRecognizer(tapGesture)
    }
    
    @objc private func dismissKeyboard() {
        view.endEditing(true)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // Her görünümde audio session'ı aktif et (başka view controller'dan gelindiğinde gerekli)
        setupAudioSession()
    }
    
    private func setupAudioSession() {
        // Gerçek cihazlarda AVSpeechSynthesizer için audio session yapılandırması gerekli
        do {
            let audioSession = AVAudioSession.sharedInstance()
            try audioSession.setCategory(.playback, mode: .spokenAudio, options: [.duckOthers])
            try audioSession.setActive(true)
        } catch {
            print("⚠️ Audio session yapılandırılamadı: \(error.localizedDescription)")
        }
    }
    
    // MARK: - AVSpeechSynthesizerDelegate
    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didStart utterance: AVSpeechUtterance) {
        print("✅ Konuşma başladı")
    }
    
    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didFinish utterance: AVSpeechUtterance) {
        print("✅ Konuşma tamamlandı")
    }
    
    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didCancel utterance: AVSpeechUtterance) {
        print("⚠️ Konuşma iptal edildi")
    }
    
    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didContinue utterance: AVSpeechUtterance) {
        print("▶️ Konuşma devam ediyor")
    }
    
    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didPause utterance: AVSpeechUtterance) {
        print("⏸️ Konuşma duraklatıldı")
    }
    
    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, willSpeakRangeOfSpeechString characterRange: NSRange, utterance: AVSpeechUtterance) {
        // Konuşma ilerlemesi (opsiyonel)
    }

    func setUI(){
        textView.textColor = AppColors.cardDescColor
        
        headerdescLbl.text = " Write your words below and let us be your voice ..."
        headerdescLbl.numberOfLines = 0
        headerdescLbl.lineBreakMode = .byWordWrapping
        headerdescLbl.textAlignment = .center
        headerdescLbl.textColor = AppColors.cardDescColor
        headerdescLbl.font = UIFont.systemFont(ofSize: 16, weight: .bold)
        
        speakerBackView.backgroundColor = AppColors.primary
        speakerBackView.layer.cornerRadius = speakerBackView.frame.width/2
        speakerBackView.layer.borderWidth = 1
        speakerBackView.layer.borderColor = AppColors.cardBorder.cgColor
        let speakerGest = UITapGestureRecognizer(target: self, action: #selector(speakerTapped))
        speakerBackView.addGestureRecognizer(speakerGest)
        speakerBackView.isUserInteractionEnabled = true
        
        speakerImg.image = UIImage(systemName: "waveform")
        speakerImg.tintColor = AppColors.background
        
        speakDesc.text = "Touch the speaker to convert your words to voice"
        speakDesc.textAlignment = .center
        speakDesc.textColor = AppColors.cardDescColor
        speakDesc.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        
        bottomView.layer.borderWidth = 1
        bottomView.layer.cornerRadius = 16
        bottomView.backgroundColor = AppColors.primary
        bottomView.layer.borderColor = AppColors.cardBorder.cgColor
        
        textView.textColor = AppColors.cardDescColor
        textView.font = UIFont.systemFont(ofSize: 16, weight: .regular)
        textView.tintColor = AppColors.cardDescColor
        textView.showsVerticalScrollIndicator = false
        textView.showsVerticalScrollIndicator = false
        
    }
    
    @objc func speakerTapped(){
        guard let text = textView.text, !text.isEmpty else {
            print("⚠️ Konuşulacak metin yok")
            return
        }
        
        // Önce mevcut konuşmayı durdur
        if synthesizer.isSpeaking {
            synthesizer.stopSpeaking(at: .immediate)
        }
        
        // Audio session'ı tekrar aktif et (gerçek cihazlarda gerekli olabilir)
        do {
            try AVAudioSession.sharedInstance().setActive(true)
        } catch {
            print("⚠️ Audio session aktif edilemedi: \(error.localizedDescription)")
        }
        
        let utterance = AVSpeechUtterance(string: text)
        
        // Ses ayarları
        if let voice = AVSpeechSynthesisVoice(language: "en-US") {
            utterance.voice = voice
        } else {
            // Fallback: sistem varsayılan sesi
            utterance.voice = AVSpeechSynthesisVoice(language: "en-US")
        }
        
        utterance.rate = 0.55
        utterance.pitchMultiplier = 1.0
        utterance.volume = 1.0
        
        // Konuşmayı başlat
        synthesizer.speak(utterance)
        print("🔊 Konuşma başlatıldı: \(text.prefix(50))...")
    }
}
