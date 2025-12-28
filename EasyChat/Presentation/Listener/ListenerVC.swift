//
//  ListenerVC.swift
//  EasyChat
//
//  Created by Talha Çelebi on 26.12.2025.
//

import UIKit
import AVFoundation

class ListenerVC: UIViewController {

    @IBOutlet weak var listenerBackView: UIView!
    @IBOutlet weak var listenDesc: UILabel!
    @IBOutlet weak var listenerImg: UIImageView!
    @IBOutlet weak var headerdescLbl: UILabel!
    @IBOutlet weak var tableView: UITableView!
    
    private let synthesizer = AVSpeechSynthesizer()
    private let transcriptionService = AudioTranscriptionService()
    private var speakers: [Speaker] = []
    private var isRecording = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = AppColors.background
        setupTableView()
        setupTranscriptionService()
        setUI()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        if isRecording {
            stopRecording()
        }
    }
    
    func setupTableView() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.separatorStyle = .none
        tableView.backgroundColor = .clear
        tableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        tableView.register(UINib(nibName: "ListenerCell", bundle: nil), forCellReuseIdentifier: "ListenerCell")
    }
    
    func setupTranscriptionService() {
        transcriptionService.delegate = self
    }

    func setUI(){
        
        headerdescLbl.text = " Write your words below and let us be your voice ..."
        headerdescLbl.numberOfLines = 0
        headerdescLbl.lineBreakMode = .byWordWrapping
        headerdescLbl.textAlignment = .center
        headerdescLbl.textColor = AppColors.cardDescColor
        headerdescLbl.font = UIFont.systemFont(ofSize: 16, weight: .bold)
        
        listenerBackView.backgroundColor = AppColors.primary
        listenerBackView.layer.cornerRadius = listenerBackView.frame.width/2
        listenerBackView.layer.borderWidth = 1
        listenerBackView.layer.borderColor = AppColors.cardBorder.cgColor
        listenerBackView.isUserInteractionEnabled = true
        
        // Kulaklık ikonuna tap gesture ekle
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(listenerTapped))
        listenerBackView.addGestureRecognizer(tapGesture)
        
        listenerImg.image = UIImage(systemName: "ear.badge.waveform")
        listenerImg.tintColor = AppColors.background
        
        listenDesc.text = "Touch the speaker to convert your words to voice"
        listenDesc.textAlignment = .center
        listenDesc.textColor = AppColors.cardDescColor
        listenDesc.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        
    }
    
    @objc func listenerTapped() {
        if isRecording {
            stopRecording()
        } else {
            startRecording()
        }
    }
    
    func startRecording() {
        // Önceki kayıtları temizle
        speakers.removeAll()
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
        
        // Backend'e bağlan
        transcriptionService.connect()
        
        // Bağlantı kurulduktan sonra kayıt başlat (2 saniye bekle)
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            self.transcriptionService.startRecording()
            self.isRecording = true
            self.updateUIForRecording(true)
        }
    }
    
    func stopRecording() {
        transcriptionService.stopRecording()
        transcriptionService.disconnect()
        isRecording = false
        updateUIForRecording(false)
    }
    
    func updateUIForRecording(_ recording: Bool) {
        if recording {
            listenerBackView.backgroundColor = AppColors.cardTitleColor
            listenDesc.text = "Recording... Tap to stop"
        } else {
            listenerBackView.backgroundColor = AppColors.primary
            listenDesc.text = "Touch the speaker to convert your words to voice"
        }
    }
}

// MARK: - AudioTranscriptionServiceDelegate
extension ListenerVC: AudioTranscriptionServiceDelegate {
    func didReceiveTranscription(speakers: [Speaker]) {
        print("📥 Backend'den \(speakers.count) speaker geldi")
        for speaker in speakers {
            print("   - Speaker: \(speaker.speaker), Text: \(speaker.text.prefix(50))...")
        }
        
        // Her speaker için işle
        for newSpeaker in speakers {
            // Aynı speaker ID'sine sahip mevcut speaker var mı?
            if let existingIndex = self.speakers.firstIndex(where: { $0.speaker == newSpeaker.speaker }) {
                // Aynı speaker var - text'ini biriktir (güncelle)
                let existingSpeaker = self.speakers[existingIndex]
                let combinedText = (existingSpeaker.text + " " + newSpeaker.text).trimmingCharacters(in: .whitespaces)
                
                self.speakers[existingIndex] = Speaker(
                    speaker: newSpeaker.speaker,
                    text: combinedText,
                    start: min(existingSpeaker.start, newSpeaker.start),
                    end: max(existingSpeaker.end, newSpeaker.end)
                )
                print("   ✅ Speaker \(newSpeaker.speaker) güncellendi")
            } else {
                // Yeni speaker - ekle
                self.speakers.append(newSpeaker)
                print("   ➕ Yeni speaker \(newSpeaker.speaker) eklendi")
            }
        }
        
        print("📊 Toplam \(self.speakers.count) speaker var")
        
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
    }
    
    func didReceiveError(message: String) {
        DispatchQueue.main.async {
            let alert = UIAlertController(title: "Hata", message: message, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Tamam", style: .default))
            self.present(alert, animated: true)
        }
    }
    
    func connectionStatusChanged(isConnected: Bool) {
        print("Bağlantı durumu: \(isConnected ? "Bağlı" : "Bağlantı kesildi")")
    }
}

// MARK: - UITableViewDelegate, UITableViewDataSource
extension ListenerVC: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // Eğer speaker yoksa 1 boş cell göster
        return max(1, speakers.count)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ListenerCell", for: indexPath) as! ListenerCell
        
        if indexPath.row < speakers.count {
            let speaker = speakers[indexPath.row]
            cell.configure(with: speaker.text, speakerID: speaker.speaker)
        } else {
            cell.configure(with: "")
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 160
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return 160
    }
}
