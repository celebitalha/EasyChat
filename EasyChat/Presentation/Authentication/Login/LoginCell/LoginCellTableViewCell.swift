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
    
    var emailChanged: ((String) -> Void)?
    var passwordChanged: ((String) -> Void)?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setUI()
    }
    
    func setUI(){
        emailTf.layer.cornerRadius = 8
        emailTf.layer.borderWidth = 1
        emailTf.layer.borderColor = AppColors.cardBorder.cgColor
        emailTf.placeholder = "E-mail"
        emailTf.textColor = AppColors.cardDescColor
        
        passwordTf.isSecureTextEntry = true
        passwordTf.layer.cornerRadius = 8
        passwordTf.layer.borderWidth = 1
        passwordTf.layer.borderColor = AppColors.cardBorder.cgColor
        passwordTf.placeholder = "Password"
        passwordTf.textColor = AppColors.cardDescColor
    }
    
    @IBAction func emailTextChanged(_ sender:UITextField) {
        emailChanged?(sender.text ?? "")
    }
    @IBAction func passwordTextChanged(_ sender:UITextField) {
        passwordChanged?(sender.text ?? "")
    }
    
}
