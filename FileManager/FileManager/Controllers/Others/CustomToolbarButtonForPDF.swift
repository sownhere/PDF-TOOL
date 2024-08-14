//
//  ToolBarForPDF.swift
//  FileManager
//
//  Created by SownFrenky on 25/7/24.
//

import Foundation
import UIKit


class CustomToolbarButtonForPDF: UIView {
    private var addButton: UIButton?
    private var drawButton: UIButton?
    private var signButton: UIButton?
    private var toTextButton: UIButton?
    private var rotateButton: UIButton?
    private var deleteButton: UIButton?
    private var stackView: UIStackView?
    
    var addButtonAction: (() -> Void)?
    var drawButtonAction: (() -> Void)?
    var signButtonAction: (() -> Void)?
    var toTextButtonAction: (() -> Void)?
    var rotateButtonAction: (() -> Void)?
    var deleteButtonAction: (() -> Void)?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setUpViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setUpViews() {
        addButton = UIButton()
        addButton?.setImage(UIImage(systemName: "plus"), for: .normal)
        addButton?.addTarget(self, action: #selector(addButtonPressed), for: .touchUpInside)
        
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
        
        deleteButton = UIButton()
        deleteButton?.setImage(UIImage(systemName: "trash"), for: .normal)
        deleteButton?.addTarget(self, action: #selector(deleteButtonPressed), for: .touchUpInside)
        
        stackView = UIStackView(arrangedSubviews: [addButton!, drawButton!, signButton!, toTextButton!, rotateButton!, deleteButton!])
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
    
    @objc private func addButtonPressed() {
        addButtonAction?()
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
    
    @objc private func deleteButtonPressed() {
        deleteButtonAction?()
    }
    
}
