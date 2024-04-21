//
//  DirectionButton.swift
//  NVibe
//
//  Created by Raphaël Huang-Dubois on 19/04/2024.
//

import UIKit

final class DirectionButton: UIButton {
    enum Style {
        case itinerary
        case inProgress
        case start
    }
    
    var style: DirectionButton.Style
    
    init(style: Style) {
        self.style = style
        super.init(frame: .zero)
        configureButton(style)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func changeStyle(_ style: Style) {
        configureButton(style)
        self.style = style
    }
    
    private func configureButton(_ style: Style) {
        layer.cornerRadius = 8
        switch style {
        case .itinerary:
            backgroundColor = .white
            setBorder(width: 0.5, color: .black.withAlphaComponent(0.6))
            setSystemImage(named: "arrow.uturn.right.square", color: .black.withAlphaComponent(0.7))
            adjustsImageWhenHighlighted = false
            setTitle("Itinéraire", color: .black.withAlphaComponent(0.7))
            titleLabel?.font = UIFont.boldSystemFont(ofSize: 16.0)
            imageEdgeInsets = UIEdgeInsets(top: 0, left: 8, bottom: 0, right: 0)
            titleEdgeInsets = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 0)
            contentHorizontalAlignment = .left
        case .inProgress:
            setInProgressAndStartStyle(with: "En cours", backgroundCor: .gray)
        case .start:
            setInProgressAndStartStyle(with: "Démarrer", backgroundCor: .systemBlue)
        }
    }
    
    private func setInProgressAndStartStyle(with title: String, backgroundCor: UIColor) {
        backgroundColor = backgroundCor
        setTitle(title, for: .normal)
        setTitleColor(.white, for: .normal)
        setImage(nil, for: .normal)
        imageEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        titleEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        titleLabel?.font = UIFont.boldSystemFont(ofSize: 16.0)
        contentHorizontalAlignment = .center
    }
}
