//
//  CardsVC.swift
//  EasyChat
//
//  Created by Talha Çelebi on 1.11.2025.
//

import UIKit

class CardsVC: UIViewController {

    
    @IBOutlet weak var cardsCollectionView: UICollectionView!
    
    let cardTitles = ["Daily", "Meal", "Basic", "Emotions", "Actions", "Greetings", "Questions", "Expressions", "Numbers", "Colors"]
    let cardBackgroundColors: [UIColor] = [
        AppColors.dailyIcon,
        AppColors.mealIcon,
        AppColors.basicIcon,
        .systemPink,
        .systemPurple,
        .systemOrange,
        .systemBlue,
        .systemGreen,
        .systemIndigo,
        .systemTeal
    ]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureCollectionView()
    }
    
    func configureCollectionView() {
        cardsCollectionView.showsVerticalScrollIndicator = false
        cardsCollectionView.delegate = self
        cardsCollectionView.dataSource = self
        cardsCollectionView.showsHorizontalScrollIndicator = false
        cardsCollectionView.register(UINib(nibName: "CardsCardCell", bundle: nil), forCellWithReuseIdentifier: "CardsCardCell")
        
        if let layout = cardsCollectionView.collectionViewLayout as? UICollectionViewFlowLayout {
            layout.minimumLineSpacing = 12
            layout.minimumInteritemSpacing = 12
            layout.sectionInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        }
    }
}

extension CardsVC: UICollectionViewDataSource , UICollectionViewDelegate{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return cardTitles.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CardsCardCell", for: indexPath) as! CardsCardCell
        
        cell.configureCell(title: cardTitles[indexPath.row], backgroundColor: cardBackgroundColors[indexPath.row])
        
        return cell
    }
}

extension CardsVC: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let spacing: CGFloat = 12
        let totalSpacing = spacing * 1
        let width = (collectionView.frame.width - totalSpacing) / 2
        let height: CGFloat = 250
        return CGSize(width: width, height: height)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 12
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 12
    }
}
