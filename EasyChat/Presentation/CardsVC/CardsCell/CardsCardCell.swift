//
//  CardsCardCell.swift
//  EasyChat
//
//  Created by Talha Çelebi on 2.11.2025.
//

import UIKit
import AVFoundation

class CardsCardCell: UICollectionViewCell {
    
    @IBOutlet weak var backView: UIView!
    @IBOutlet weak var audioImg: UIImageView!
    @IBOutlet weak var audioBackView: UIView!
    @IBOutlet weak var cardTitle: UILabel!
    
    private let synthesizer = AVSpeechSynthesizer()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setUI()
    }
    
    func setUI(){
        backView.layer.cornerRadius = 16
        
        cardTitle.textAlignment = .center
        cardTitle.textColor = .white
        cardTitle.font = .systemFont(ofSize: 20, weight: .bold)
        cardTitle.numberOfLines = 0
        cardTitle.lineBreakMode = .byWordWrapping
        
        audioImg.image = UIImage(systemName: "speaker.wave.1")
        audioImg.tintColor = .white
        
        let listenGesture = UITapGestureRecognizer(target: self, action: #selector(listenClicked))
        audioBackView.addGestureRecognizer(listenGesture)
        audioBackView.isUserInteractionEnabled = true
    }
    
    func configureCell(title: String, backgroundColor: UIColor) {
        cardTitle.text = title
        backView.backgroundColor = backgroundColor
    }
    
    @objc func listenClicked (){
        guard let text = cardTitle.text, !text.isEmpty else { return }
        
        let utterance = AVSpeechUtterance(string: text)
        utterance.voice = AVSpeechSynthesisVoice(language: "en-US")
        utterance.rate = 0.5
        utterance.pitchMultiplier = 1.0
        utterance.volume = 1.0
        
        synthesizer.speak(utterance)
    }
}
