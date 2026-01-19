//
//  LoginCellTableViewCell.swift
//  EasyChat
//
//  Created by Talha Çelebi on 16.01.2026.
//

import UIKit

class LoginCellTableViewCell: UITableViewCell {
    @IBOutlet weak var emailTf: UITextField!
    @IBOutlet weak var passwordTf: UITextField!
    @IBOutlet weak var nameSurnameTf: UITextField!
    @IBOutlet weak var rePasswordTf: UITextField!
    @IBOutlet weak var nameContainerView: UIView!
    @IBOutlet weak var emailContainerView: UIView!
    @IBOutlet weak var passwordContainerView: UIView!
    @IBOutlet weak var rePasswordContainerView: UIView!
    
    var nameChanged: ((String) -> Void)?
    var emailChanged: ((String) -> Void)?
    var passwordChanged: ((String) -> Void)?
    var rePasswordChanged: ((String) -> Void)?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setUI()
        setupEditingTargets()
    }
    
    func setUI(){
        contentView.backgroundColor = .clear
        
        configureContainer(emailContainerView)
        configureContainer(passwordContainerView)
        configureContainer(nameContainerView)
        configureContainer(rePasswordContainerView)
        
        configureTextField(emailTf, placeholder: "E-mail")
        emailTf.keyboardType = .emailAddress
        emailTf.autocapitalizationType = .none
        emailTf.autocorrectionType = .no
        
        configureTextField(passwordTf, placeholder: "Password")
        passwordTf.isSecureTextEntry = true
        
        configureTextField(nameSurnameTf, placeholder: "Name Surname")
        
        configureTextField(rePasswordTf, placeholder: "Re-Password")
        rePasswordTf.isSecureTextEntry = true
    }
    
    private func configureContainer(_ view: UIView) {
        view.backgroundColor = .clear
        view.clipsToBounds = false
    }
    
    private func configureTextField(_ textField: UITextField, placeholder: String) {
        textField.borderStyle = .none
        textField.layer.cornerRadius = 12
        textField.layer.borderWidth = 1
        textField.layer.borderColor = AppColors.cardBorder.cgColor
        textField.clipsToBounds = true
        textField.placeholder = placeholder
        textField.textColor = AppColors.cardDescColor
        textField.backgroundColor = .white
    }
    
    private func setupEditingTargets() {
        emailTf.addTarget(self, action: #selector(emailEditingChanged(_:)), for: .editingChanged)
        passwordTf.addTarget(self, action: #selector(passwordEditingChanged(_:)), for: .editingChanged)
        nameSurnameTf.addTarget(self, action: #selector(nameEditingChanged(_:)), for: .editingChanged)
        rePasswordTf.addTarget(self, action: #selector(rePasswordEditingChanged(_:)), for: .editingChanged)
    }
    
    @objc private func emailEditingChanged(_ sender: UITextField) {
        emailChanged?(sender.text ?? "")
    }
    
    @objc private func passwordEditingChanged(_ sender: UITextField) {
        passwordChanged?(sender.text ?? "")
    }
    
    @objc private func nameEditingChanged(_ sender: UITextField) {
        nameChanged?(sender.text ?? "")
    }
    
    @objc private func rePasswordEditingChanged(_ sender: UITextField) {
        rePasswordChanged?(sender.text ?? "")
    }
    
    func configure(isLoginMode: Bool) {
        nameContainerView.isHidden = isLoginMode
        rePasswordContainerView.isHidden = isLoginMode
        emailContainerView.isHidden = false
        passwordContainerView.isHidden = false
        
        contentView.layoutIfNeeded()
    }
    
    @IBAction func emailTextChanged(_ sender:UITextField) {
        emailChanged?(sender.text ?? "")
    }
    @IBAction func passwordTextChanged(_ sender:UITextField) {
        passwordChanged?(sender.text ?? "")
    }
    @IBAction func nameTextChanged(_ sender:UITextField) {
        nameChanged?(sender.text ?? "")
    }
    
    @IBAction func rePasswordTextChanged(_ sender:UITextField) {
        rePasswordChanged?(sender.text ?? "")
    }
    
}
