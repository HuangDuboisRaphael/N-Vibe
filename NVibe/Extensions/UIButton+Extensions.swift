//
//  UIButton+Extensions.swift
//  NVibe
//
//  Created by Raphaël Huang-Dubois on 21/04/2024.
//

import UIKit

extension UIButton {
    func setGeneralComponents(_ target: Any?, action: Selector, backgroundColor: UIColor? = nil) {
        self.backgroundColor = backgroundColor
        self.translatesAutoresizingMaskIntoConstraints = false
        self.addTarget(target, action: action, for: .touchUpInside)
    }
    
    func setSystemImage(named image: String, color: UIColor? = nil) {
        self.setImage(UIImage(systemName: image), for: .normal)
        self.tintColor = color
    }
    
    func setTitle(_ text: String, color: UIColor, font: UIFont? = nil) {
        self.setTitle(text, for: .normal)
        self.setTitleColor(color, for: .normal)
        self.titleLabel?.font = font
    }
    
    func setBorder(width: CGFloat, color: UIColor) {
        self.layer.masksToBounds = true
        self.layer.borderWidth = width
        self.layer.borderColor = color.cgColor
    }
}
