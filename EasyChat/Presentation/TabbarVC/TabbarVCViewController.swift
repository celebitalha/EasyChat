//
//  TabbarVCViewController.swift
//  EasyChat
//
//  Created by Talha Çelebi on 29.10.2025.
//

import UIKit

class TabbarVCViewController: UIViewController {
    @IBOutlet weak var backView: UIView!
    @IBOutlet weak var homeIcon: UIImageView!
    @IBOutlet weak var homeTabBackView: UIView!
    @IBOutlet weak var firstLineView: UIView!
    @IBOutlet weak var cardsTabBackView: UIView!
    @IBOutlet weak var secondLineView: UIView!
    @IBOutlet weak var speakIcon: UIImageView!
    @IBOutlet weak var thirdLineView: UIView!
    @IBOutlet weak var speakTabBackView: UIView!
    @IBOutlet weak var cardsIcon: UIImageView!
    @IBOutlet weak var listenIcon: UIImageView!
    @IBOutlet weak var listenTabBackView: UIView!
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var logoBackView: UIView!
    @IBOutlet weak var AppLogoImg: UIImageView!
    
    private var homeVC: HomeVC!
    private var cardsVC: CardsVC!
    private var currentViewController: UIViewController?
    
    private var selectedTabIndex = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViewControllers()
        setUI()
        setupGestures()
        showHomeVC()
    }

    func setUI () {
        self.view.backgroundColor = AppColors.background
        backView.backgroundColor = AppColors.primary
        backView.layer.cornerRadius = 24
        backView.layer.borderWidth = 1
        backView.layer.borderColor = AppColors.cardBorder.cgColor
        
        AppLogoImg.image = UIImage(named: "Navigation-logo")
        AppLogoImg.contentMode = .scaleAspectFill
        AppLogoImg.backgroundColor = .clear
        logoBackView.backgroundColor = AppColors.background
        
        firstLineView.backgroundColor =  AppColors.cardBorder
        secondLineView.backgroundColor = AppColors.cardBorder
        thirdLineView.backgroundColor = AppColors.cardBorder
        
        homeIcon.image = UIImage(systemName: "house")
        homeIcon.tintColor = AppColors.cardTitleColor.withAlphaComponent(0.5)
        
        cardsIcon.image = UIImage(systemName: "rectangle.stack")
        cardsIcon.tintColor = AppColors.cardTitleColor.withAlphaComponent(0.5)
        
        speakIcon.image = UIImage(systemName: "waveform")
        speakIcon.tintColor = AppColors.cardTitleColor.withAlphaComponent(0.5)
        
        listenIcon.image = UIImage(systemName: "ear.badge.waveform")
        listenIcon.tintColor = AppColors.cardTitleColor.withAlphaComponent(0.5)
    }
    
    // MARK: - Setup Methods
    private func setupViewControllers() {
        homeVC = HomeVC(nibName: "HomeVC", bundle: nil)
        cardsVC = CardsVC(nibName: "CardsVC", bundle: nil)
    }
    
    private func setupGestures() {
        let homeTap = UITapGestureRecognizer(target: self, action: #selector(homeTabTapped))
        homeTabBackView.addGestureRecognizer(homeTap)
        homeTabBackView.isUserInteractionEnabled = true
        
        let cardsTap = UITapGestureRecognizer(target: self, action: #selector(cardsTabTapped))
        cardsTabBackView.addGestureRecognizer(cardsTap)
        cardsTabBackView.isUserInteractionEnabled = true
        
        let speakTap = UITapGestureRecognizer(target: self, action: #selector(speakTabTapped))
        speakTabBackView.addGestureRecognizer(speakTap)
        speakTabBackView.isUserInteractionEnabled = true
        
        let listenTap = UITapGestureRecognizer(target: self, action: #selector(listenTabTapped))
        listenTabBackView.addGestureRecognizer(listenTap)
        listenTabBackView.isUserInteractionEnabled = true
    }
    
    private func showHomeVC() {
        switchToViewController(homeVC, tabIndex: 0)
    }
    
    // MARK: - Tab Actions
    @objc private func homeTabTapped() {
        switchToViewController(homeVC, tabIndex: 0)
    }
    
    @objc private func cardsTabTapped() {
        switchToViewController(cardsVC, tabIndex: 1)
    }
    
    @objc private func speakTabTapped() {
        // TODO: Create SpeakVC and implementt
        print("Speak tab tapped - Not implemented yet")
    }
    
    @objc private func listenTabTapped() {
        // TODO: Create ListenVC and implement
        print("Listen tab tapped - Not implemented yet")
    }
    
    // MARK: - View Controller Management
    private func switchToViewController(_ viewController: UIViewController, tabIndex: Int) {

        if let currentVC = currentViewController {
            currentVC.willMove(toParent: nil)
            currentVC.view.removeFromSuperview()
            currentVC.removeFromParent()
        }
        
        addChild(viewController)
        containerView.addSubview(viewController.view)
        viewController.view.frame = containerView.bounds
        viewController.view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        viewController.didMove(toParent: self)
        
        currentViewController = viewController
        selectedTabIndex = tabIndex
        updateTabSelection()
    }
    
    private func updateTabSelection() {
        resetTabAppearances()
        
        switch selectedTabIndex {
        case 0:
            homeIcon.tintColor = AppColors.cardTitleColor
        case 1:
            cardsIcon.tintColor = AppColors.cardTitleColor
        case 2:
            speakIcon.tintColor = AppColors.cardTitleColor
        case 3:
            listenIcon.tintColor = AppColors.cardTitleColor
        default:
            break
        }
    }
    
    private func resetTabAppearances() {
        homeIcon.tintColor = AppColors.cardTitleColor.withAlphaComponent(0.5)
        cardsIcon.tintColor = AppColors.cardTitleColor.withAlphaComponent(0.5)
        speakIcon.tintColor = AppColors.cardTitleColor.withAlphaComponent(0.5)
        listenIcon.tintColor = AppColors.cardTitleColor.withAlphaComponent(0.5)
    }
}
