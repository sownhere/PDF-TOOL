//
//  ToolBarForPDF.swift
//  FileManager
//
//  Created by SownFrenky on 25/7/24.
//

import Foundation
import UIKit


class CustomToolbarButtonForPDF: UIView {
    private var drawButton: UIButton?
    private var signButton: UIButton?
    private var toTextButton: UIButton?
    private var rotateButton: UIButton?
    private var stackView: UIStackView?
    
    var drawButtonAction: (() -> Void)?
    var signButtonAction: (() -> Void)?
    var toTextButtonAction: (() -> Void)?
    var rotateButtonAction: (() -> Void)?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setUpViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setUpViews() {
        drawButton = UIButton()
        drawButton?.setImage(UIImage(systemName: "pencil"), for: .normal)
        drawButton?.addTarget(self, action: #selector(drawButtonPressed), for: .touchUpInside)
        
        signButton = UIButton()
        signButton?.setImage(UIImage(systemName: "signature"), for: .normal)
        signButton?.addTarget(self, action: #selector(signButtonPressed), for: .touchUpInside)
        
        toTextButton = UIButton()
        toTextButton?.setImage(UIImage(systemName: "doc.text"), for: .normal)
        toTextButton?.addTarget(self, action: #selector(toTextButtonPressed), for: .touchUpInside)
        
        rotateButton = UIButton()
        rotateButton?.setImage(UIImage(systemName: "arrow.clockwise"), for: .normal)
        rotateButton?.addTarget(self, action: #selector(rotateButtonPressed), for: .touchUpInside)
        
        stackView = UIStackView(arrangedSubviews: [drawButton!, signButton!, toTextButton!, rotateButton!])
        stackView?.axis = .horizontal
        stackView?.distribution = .fillEqually
        stackView?.spacing = 5
        stackView?.translatesAutoresizingMaskIntoConstraints = false
        addSubview(stackView!)
        
        // Constrain to fix this view like a standar toolbar

        NSLayoutConstraint.activate([
            stackView!.topAnchor.constraint(equalTo: topAnchor),
            stackView!.bottomAnchor.constraint(equalTo: bottomAnchor),
            stackView!.leadingAnchor.constraint(equalTo: leadingAnchor),
            stackView!.trailingAnchor.constraint(equalTo: trailingAnchor)
        ])
    }
    
    @objc private func drawButtonPressed() {
        drawButtonAction?()
    }
    
    @objc private func signButtonPressed() {
        signButtonAction?()
    }
    
    @objc private func toTextButtonPressed() {
        toTextButtonAction?()
    }
    
    @objc private func rotateButtonPressed() {
        rotateButtonAction?()
    }
    
}
