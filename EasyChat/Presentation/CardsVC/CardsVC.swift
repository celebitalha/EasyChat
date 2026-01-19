//
//  CardsVC.swift
//  EasyChat
//
//  Created by Talha Çelebi on 1.11.2025.
//

import UIKit

class CardsVC: UIViewController {

    @IBOutlet weak var categoryCollectionView: UICollectionView!
    @IBOutlet weak var cardsCollectionView: UICollectionView!
    
    private let categories = ["Daily", "Meal", "Basic", "Emotions", "Actions"]
    private let categoryColors: [UIColor] = [
        AppColors.dailyIcon,
        AppColors.mealIcon,
        AppColors.basicIcon,
        .systemPink,
        .systemPurple
    ]
    
    private let cardsByCategory: [String: [String]] = [
        "Daily": ["Hello", "Good morning", "Good night", "Thank you", "Please", "Sorry", "How are you?", "I am fine"],
        "Meal": ["I am hungry", "I am thirsty", "Breakfast", "Lunch", "Dinner", "Water", "Tea", "Coffee"],
        "Basic": ["Yes", "No", "I need help", "I don’t understand", "Please repeat", "Stop", "Wait", "I am okay"],
        "Emotions": ["Happy", "Sad", "Angry", "Excited", "Scared", "Tired", "Calm", "Nervous"],
        "Actions": ["Go", "Come", "Sit", "Stand", "Walk", "Open", "Close", "Follow me"]
    ]
    
    private var selectedCategoryIndex = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = AppColors.background
        configureCategoryCollectionView()
        configureCardsCollectionView()
    }
    
    private func configureCategoryCollectionView() {
        categoryCollectionView.backgroundColor = AppColors.primary
        categoryCollectionView.showsHorizontalScrollIndicator = false
        categoryCollectionView.delegate = self
        categoryCollectionView.dataSource = self
        categoryCollectionView.register(UINib(nibName: "CategoryCell", bundle: nil), forCellWithReuseIdentifier: "CategoryCell")
        categoryCollectionView.layer.cornerRadius = 16
        categoryCollectionView.layer.borderWidth = 1
        categoryCollectionView.layer.borderColor = AppColors.cardBorder.cgColor
        categoryCollectionView.clipsToBounds = true
        categoryCollectionView.contentInset = UIEdgeInsets(top: 6, left: 6, bottom: 6, right: 6)
        
        if let layout = categoryCollectionView.collectionViewLayout as? UICollectionViewFlowLayout {
            layout.scrollDirection = .horizontal
            layout.minimumLineSpacing = 12
            layout.minimumInteritemSpacing = 12
        }
    }
    
    private func configureCardsCollectionView() {
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
    
    private func currentCards() -> [String] {
        let category = categories[selectedCategoryIndex]
        return cardsByCategory[category] ?? []
    }
    
    private func currentCategoryColor() -> UIColor {
        return categoryColors[selectedCategoryIndex]
    }

    func selectCategory(index: Int) {
        guard index >= 0, index < categories.count else { return }
        // Ensure outlets are loaded before accessing collection views
        loadViewIfNeeded()
        selectedCategoryIndex = index
        categoryCollectionView.reloadData()
        cardsCollectionView.reloadData()
    }
}

extension CardsVC: UICollectionViewDataSource , UICollectionViewDelegate{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView == categoryCollectionView {
            return categories.count
        }
        return currentCards().count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if collectionView == categoryCollectionView {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CategoryCell", for: indexPath) as! CategoryCell
            cell.configureCell(at: indexPath.row, isSelected: indexPath.row == selectedCategoryIndex)
            return cell
        } else {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CardsCardCell", for: indexPath) as! CardsCardCell
            let title = currentCards()[indexPath.row]
            cell.configureCell(title: title, backgroundColor: currentCategoryColor())
            return cell
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if collectionView == categoryCollectionView {
            selectedCategoryIndex = indexPath.row
            categoryCollectionView.reloadData()
            cardsCollectionView.reloadData()
        }
    }
}

extension CardsVC: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if collectionView == categoryCollectionView {
            return CGSize(width: 76, height: 76)
        }
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
