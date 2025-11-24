//
//  SpeakerVC.swift
//  EasyChat
//
//  Created by Talha Çelebi on 24.11.2025.
//

import UIKit
import AVFoundation

class SpeakerVC: UIViewController {

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
        setUI()
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
        if let text = textView.text, !text.isEmpty {
            let utterance = AVSpeechUtterance(string: text)
            utterance.voice = AVSpeechSynthesisVoice(language: "en-US")
            utterance.rate = 0.55
            utterance.pitchMultiplier = 1.0
            utterance.volume = 1.0
            
            synthesizer.speak(utterance)
        }
    }
}
