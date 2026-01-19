//
//  LoginVCViewController.swift
//  EasyChat
//
//  Created by Talha Çelebi on 16.01.2026.
//

import UIKit
import FirebaseAuth

class LoginVCViewController: UIViewController {

    @IBOutlet weak var signBtn: UILabel!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var registerBtnLbl: UILabel!
    @IBOutlet weak var loginBtnLbl: UILabel!
    @IBOutlet weak var logoImg: UIImageView!
    @IBOutlet weak var loginTabView: UIView!
    @IBOutlet weak var registerTabView: UIView!
    @IBOutlet weak var tableViewHeight: NSLayoutConstraint!
    @IBOutlet weak var bottomView: UIView!
    
    private var isLoginMode = true
    
    private var nameText = ""
    private var emailText = ""
    private var passwordText = ""
    private var rePasswordText = ""
    override func viewDidLoad() {
        super.viewDidLoad()

        setupUI()
        setupTableView()
        setupGestures()
        setMode(isLogin: true)
    }

    private func setupUI() {
        view.backgroundColor = AppColors.background
        logoImg.image = UIImage(named: "Navigation-logo")
        logoImg.contentMode = .scaleAspectFit
        
        loginBtnLbl.text = "Login"
        registerBtnLbl.text = "Register"
        loginBtnLbl.textAlignment = .center
        registerBtnLbl.textAlignment = .center
        
        signBtn.textAlignment = .center
        signBtn.textColor = .white
        signBtn.layer.cornerRadius = 12
        signBtn.layer.masksToBounds = true
        
        tableView.backgroundColor = .clear
        tableView.isScrollEnabled = false
        
        bottomView.layer.cornerRadius = 34
        bottomView.backgroundColor = AppColors.loginBgColor
    }
    
    private func setupTableView() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.separatorStyle = .none
        tableView.register(UINib(nibName: "LoginCellTableViewCell", bundle: nil), forCellReuseIdentifier: "LoginCellTableViewCell")
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 200
    }
    
    private func setupGestures() {
        let loginTap = UITapGestureRecognizer(target: self, action: #selector(loginTapped))
        loginTabView.addGestureRecognizer(loginTap)
        loginTabView.isUserInteractionEnabled = true
        
        let registerTap = UITapGestureRecognizer(target: self, action: #selector(registerTapped))
        registerTabView.addGestureRecognizer(registerTap)
        registerTabView.isUserInteractionEnabled = true
        
        let signTap = UITapGestureRecognizer(target: self, action: #selector(signTapped))
        signBtn.isUserInteractionEnabled = true
        signBtn.addGestureRecognizer(signTap)
    }
    
    private func setMode(isLogin: Bool) {
        isLoginMode = isLogin
        
        loginTabView.backgroundColor = .clear
        registerTabView.backgroundColor = .clear
        
        styleTabLabel(loginBtnLbl, isSelected: isLogin)
        styleTabLabel(registerBtnLbl, isSelected: !isLogin)
        
        signBtn.text = isLogin ? "Sign In" : "Sign Up"
        signBtn.backgroundColor = AppColors.cardTitleColor
        signBtn.font = .systemFont(ofSize: 18, weight: .bold)
        
        updateTableHeight()
        tableView.reloadData()
        tableView.layoutIfNeeded()
    }
    
    private func updateTableHeight() {
        tableViewHeight.constant = isLoginMode ? 140 : 280
        view.layoutIfNeeded()
    }
    
    private func styleTabLabel(_ label: UILabel, isSelected: Bool) {
        label.backgroundColor = isSelected ? AppColors.cardTitleColor : .white
        label.textColor = isSelected ? .white : AppColors.cardTitleColor
        label.font = .systemFont(ofSize: 16, weight: .bold)
        label.layer.cornerRadius = 12
        label.layer.masksToBounds = true
        label.textAlignment = .center
        label.layer.borderWidth = 1
        label.layer.borderColor = AppColors.cardBorder.cgColor
    }
    
    @objc private func loginTapped() {
        setMode(isLogin: true)
    }
    
    @objc private func registerTapped() {
        setMode(isLogin: false)
    }
    
    @objc private func signTapped() {
        view.endEditing(true)
        if isLoginMode {
            signIn()
        } else {
            signUp()
        }
    }
    
    private func signIn() {
        guard !emailText.isEmpty, !passwordText.isEmpty else {
            showAlert(title: "Missing Info", message: "Please enter email and password.")
            return
        }
        
        Auth.auth().signIn(withEmail: emailText, password: passwordText) { [weak self] result, error in
            if let error = error {
                self?.showAlert(title: "Login Failed", message: error.localizedDescription)
                return
            }
            print("✅ Logged in:", result?.user.email ?? "")
            DispatchQueue.main.async {
                self?.goToTabbar()
            }
        }
    }
    
    private func signUp() {
        guard !nameText.isEmpty, !emailText.isEmpty, !passwordText.isEmpty, !rePasswordText.isEmpty else {
            showAlert(title: "Missing Info", message: "Please fill all fields.")
            return
        }
        guard passwordText == rePasswordText else {
            showAlert(title: "Password Mismatch", message: "Passwords do not match.")
            return
        }
        
        Auth.auth().createUser(withEmail: emailText, password: passwordText) { [weak self] result, error in
            if let error = error {
                self?.showAlert(title: "Sign Up Failed", message: error.localizedDescription)
                return
            }
            print("✅ User created:", result?.user.email ?? "")
            DispatchQueue.main.async {
                self?.goToTabbar()
            }
        }
    }
    
    private func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
    
    private func goToTabbar() {
        let tabbarVC = TabbarVCViewController(nibName: "TabbarVCViewController", bundle: nil)
        tabbarVC.modalPresentationStyle = .fullScreen
        present(tabbarVC, animated: true)
    }
}

extension LoginVCViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return isLoginMode ? 140 : 280
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "LoginCellTableViewCell", for: indexPath) as! LoginCellTableViewCell
        cell.selectionStyle = .none
        cell.configure(isLoginMode: isLoginMode)
        
        cell.nameChanged = { [weak self] text in
            self?.nameText = text
        }
        cell.emailChanged = { [weak self] text in
            self?.emailText = text
        }
        cell.passwordChanged = { [weak self] text in
            self?.passwordText = text
        }
        cell.rePasswordChanged = { [weak self] text in
            self?.rePasswordText = text
        }
        return cell
    }
}
