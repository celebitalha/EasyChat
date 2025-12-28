//
//  ListenerCell.swift
//  EasyChat
//
//  Created by Talha Çelebi on 26.12.2025.
//

import UIKit

class ListenerCell: UITableViewCell {

    @IBOutlet weak var bottomView: UIView!
    @IBOutlet weak var textView: UITextView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        selectionStyle = .none
        backgroundColor = .clear
        contentView.backgroundColor = .clear
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        setUI()
    }
    
    func setUI() {
        bottomView.layer.borderWidth = 1
        bottomView.layer.cornerRadius = 16
        bottomView.backgroundColor = AppColors.primary
        bottomView.layer.borderColor = AppColors.cardBorder.cgColor
        
        textView.textColor = AppColors.cardDescColor
        textView.font = UIFont.systemFont(ofSize: 16, weight: .regular)
        textView.tintColor = AppColors.cardDescColor
        textView.showsVerticalScrollIndicator = false
        textView.isEditable = false
        textView.isScrollEnabled = false
        textView.backgroundColor = .clear
    }
    
    func configure(with text: String, speakerID: String? = nil) {
        if let speakerID = speakerID {
            textView.text = "[\(speakerID)] \(text)"
        } else {
            textView.text = text
        }
        setNeedsLayout()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // Configure the view for the selected state
    }
    
}
