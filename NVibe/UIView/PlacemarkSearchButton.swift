//
//  LocationSearchButton.swift
//  NVibe
//
//  Created by Raphaël Huang-Dubois on 21/04/2024.
//

import UIKit

final class PlacemarkSearchButton: UIButton {
    var title: String
    var target: Any?
    var action: Selector
    
    init(title: String, target: Any?, action: Selector) {
        self.title = title
        self.target = target
        self.action = action
        super.init(frame: .zero)
        configureButton(title: title, target: target, action: action)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func configureButton(title: String, target: Any?, action: Selector) {
        self.setGeneralComponents(target, action: action, backgroundColor: .white)
        self.layer.cornerRadius = 4
        self.setBorder(width: 1, color: .black.withAlphaComponent(0.3))
        self.setTitle(title, color: .black, font: UIFont.systemFont(ofSize: 16))
        self.titleEdgeInsets = UIEdgeInsets(top: 0, left: 12, bottom: 0, right: 0)
        self.contentHorizontalAlignment = .left
    }
}
