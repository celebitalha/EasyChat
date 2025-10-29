//
//  CategoryCell.swift
//  EasyChat
//
//  Created by Talha Çelebi on 29.10.2025.
//

import UIKit

class CategoryCell: UICollectionViewCell {
    
    @IBOutlet var imageView: UIImageView!
    @IBOutlet var backView: UIView!
    @IBOutlet var titleLbl: UILabel!
    
    let categories = ["Daily","Meal","Basic","Emotions","Actions"]
    let icons = ["quote.bubble.fill","fork.knife.circle.fill","bed.double.fill","heart.fill","figure.walk"]
    let imageColors: [UIColor] = [.yellow, .blue, .systemYellow, .systemRed, .systemPurple]
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setUI()
    }
    
    func setUI(){
        backView.backgroundColor = .white
        backView.layer.cornerRadius = 29
        
        titleLbl.textAlignment = .center
        titleLbl.font = .systemFont(ofSize: 12, weight: .bold)
        titleLbl.textColor = .lightGray
    }
    
    func configureCell(at index: Int) {
        titleLbl.text = categories[index]
        imageView.tintColor = imageColors[index]
        imageView.image = UIImage(systemName: icons[index])
    }
    
    
}
