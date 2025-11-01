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
    let imageColors: [UIColor] = [AppColors.dailyIcon, AppColors.mealIcon, AppColors.basicIcon, .systemRed, .systemPurple]
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setUI()
    }
    
    func setUI(){
        backView.backgroundColor = AppColors.background
        backView.layer.cornerRadius = frame.height / 2
        
        titleLbl.textAlignment = .center
        titleLbl.font = .systemFont(ofSize: 12, weight: .bold)
        titleLbl.textColor = AppColors.cardTextColor
    }
    
    func configureCell(at index: Int) {
        titleLbl.text = categories[index]
        imageView.tintColor = imageColors[index]
        imageView.image = UIImage(systemName: icons[index])
    }
    
    
}
