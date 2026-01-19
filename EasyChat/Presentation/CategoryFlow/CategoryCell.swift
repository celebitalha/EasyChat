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
        titleLbl.textColor = AppColors.cardDescColor
    }
    
    func configureCell(at index: Int, isSelected: Bool = false) {
        let tintColor = imageColors[index]
        titleLbl.text = categories[index]
        imageView.image = UIImage(systemName: icons[index])
        
        if isSelected {
            backView.backgroundColor = tintColor
            imageView.tintColor = .white
            titleLbl.textColor = .white
        } else {
            backView.backgroundColor = AppColors.background
            imageView.tintColor = tintColor
            titleLbl.textColor = AppColors.cardDescColor
        }
    }
    
    
}
