//
//  HomeVC.swift
//  EasyChat
//
//  Created by Talha Çelebi on 29.10.2025.
//

import UIKit

class HomeVC: UIViewController {

    @IBOutlet weak var categoriesBackView: UIView!
    @IBOutlet weak var listenDesc: UITextView!
    @IBOutlet weak var listenTitle: UILabel!
    @IBOutlet weak var listenIcon: UIImageView!
    @IBOutlet weak var listenBackView: UIView!
    @IBOutlet weak var speakDesc: UITextView!
    @IBOutlet weak var speakTitle: UILabel!
    @IBOutlet weak var speakIcon: UIImageView!
    @IBOutlet weak var speakBackView: UIView!
    @IBOutlet weak var categoryCollectionView: UICollectionView!
    override func viewDidLoad() {
        super.viewDidLoad()
        configureCollectionView()
    }

    func configureCollectionView() {
        self.view.backgroundColor = AppColors.background
        
        speakBackView.backgroundColor = AppColors.primary
        speakBackView.layer.borderWidth = 1
        speakBackView.layer.borderColor = AppColors.cardBorder.cgColor
        speakBackView.layer.cornerRadius = 16
        
        speakIcon.image = UIImage(named: "talking")
        
        speakTitle.textColor = AppColors.cardTitleColor
        speakTitle.text = "Let us be your voice"
        speakTitle.textAlignment = .left
        speakTitle.numberOfLines = 0
        speakTitle.font = UIFont.systemFont(ofSize: 18, weight: .bold)
        
        speakDesc.text = "Tap this card and let your words be heard."
        speakDesc.textColor = AppColors.cardTextColor
        speakDesc.font = UIFont.systemFont(ofSize: 14, weight: .medium)
        speakDesc.isUserInteractionEnabled = false
       
        listenBackView.backgroundColor = AppColors.primary
        listenBackView.layer.borderWidth = 1
        listenBackView.layer.borderColor = AppColors.cardBorder.cgColor
        listenBackView.layer.cornerRadius = 16
        
        listenIcon.image = UIImage(named: "eavesdropping")
        
        listenTitle.numberOfLines = 0
        listenTitle.textColor = AppColors.cardTitleColor
        listenTitle.text = "Let us be your ears"
        listenTitle.textAlignment = .left
        listenTitle.font = UIFont.systemFont(ofSize: 18, weight: .bold)
        
        listenDesc.text = "Tap this card and capture sounds around you and see them in words."
        listenDesc.textColor = AppColors.cardTextColor
        listenDesc.font = UIFont.systemFont(ofSize: 14, weight: .medium)
        listenDesc.isUserInteractionEnabled = false
        
        
        categoriesBackView.layer.cornerRadius = 16
        categoriesBackView.layer.borderWidth = 1
        categoriesBackView.layer.borderColor = AppColors.cardBorder.cgColor
        categoriesBackView.backgroundColor = AppColors.primary
        categoryCollectionView.backgroundColor = .clear
        categoryCollectionView.showsHorizontalScrollIndicator = false
        categoryCollectionView.showsVerticalScrollIndicator = false
        categoryCollectionView.delegate = self
        categoryCollectionView.dataSource = self
        categoryCollectionView.register(UINib(nibName: "CategoryCell", bundle: nil), forCellWithReuseIdentifier: "CategoryCell")
        
        if let layout = categoryCollectionView.collectionViewLayout as? UICollectionViewFlowLayout {
            layout.scrollDirection = .horizontal
        }
    }
}

extension HomeVC: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 5
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = categoryCollectionView.dequeueReusableCell(withReuseIdentifier: "CategoryCell", for: indexPath) as! CategoryCell
        cell.configureCell(at: indexPath.row)
        return cell
        
    }
}

extension HomeVC: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 76, height: 76)
    }
}
