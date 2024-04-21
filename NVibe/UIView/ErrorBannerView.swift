//
//  ErrorBannerView.swift
//  NVibe
//
//  Created by Raphaël Huang-Dubois on 21/04/2024.
//

import UIKit

final class ErrorBannerView: UIView {
    private let horizontalStack: UIStackView = {
        let view = UIStackView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.axis = .horizontal
        view.alignment = .center
        view.spacing = 12
        return view
    }()
    
    private let imageView: UIImageView = {
        let view = UIImageView()
        let image = UIImage(named: "warning")!
        view.image = image
        view.contentMode = .scaleAspectFit
        return view
    }()
    
    private let errorLabel: UILabel = {
        let view = UILabel()
        view.font = UIFont(name: "Arial-BoldMT", size: 14)
        view.textColor = .white
        view.numberOfLines = 1
        view.textAlignment = .left
        return view
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        addLayout()
        makeConstraint()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setError(_ error: String) {
        errorLabel.text = error
    }
    
    private func addLayout() {
        backgroundColor = .red
        horizontalStack.addArrangedSubview(imageView)
        horizontalStack.addArrangedSubview(errorLabel)
        addSubview(horizontalStack)
    }
    
    private func makeConstraint() {
        NSLayoutConstraint.activate([
            horizontalStack.bottomAnchor.constraint(equalTo: bottomAnchor, constant: 10),
            horizontalStack.heightAnchor.constraint(equalToConstant: 60),
            horizontalStack.leadingAnchor.constraint(equalTo: leadingAnchor, constant: bounds.width * 0.06)
        ])
    }
}
