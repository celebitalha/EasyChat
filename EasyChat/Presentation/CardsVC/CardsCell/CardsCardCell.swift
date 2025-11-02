//
//  CardsCardCell.swift
//  EasyChat
//
//  Created by Talha Çelebi on 2.11.2025.
//

import UIKit

class CardsCardCell: UICollectionViewCell {
    
    @IBOutlet weak var backView: UIView!
    @IBOutlet weak var audioImg: UIImageView!
    @IBOutlet weak var audioBackView: UIView!
    @IBOutlet weak var cardTitle: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        setUI()
    }
    
    func setUI(){
        backView.layer.cornerRadius = 16
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
        
    }
}
