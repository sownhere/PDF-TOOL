//
//  CollectionReusableView.swift
//  FileManager
//
//  Created by Macbook on 17/06/2024.
//

import UIKit

protocol HeaderCollectionViewDelegate: AnyObject {
    func didTapViewToggleButton()
    func didTapFolderButton()
    func didTapSortLabel()
}

class HeaderCollectionView: UICollectionReusableView {
        
    @IBOutlet weak var viewToggleBtn: UIButton!
    @IBOutlet weak var sortLabel: UILabel!
    @IBOutlet weak var folderBtn: UIButton!
    @IBOutlet weak var typeLabel: UILabel!
    
    // Delegate reference
    weak var delegate: HeaderCollectionViewDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setupInteractions()
    }
    
    private func setupInteractions() {
        // Button actions
        viewToggleBtn.addTarget(self, action: #selector(viewToggleButtonTapped), for: .touchUpInside)
        folderBtn.addTarget(self, action: #selector(folderButtonTapped), for: .touchUpInside)

        // Label tap gesture
        let sortLabelTapGesture = UITapGestureRecognizer(target: self, action: #selector(sortLabelTapped))
        sortLabel.isUserInteractionEnabled = true
        sortLabel.addGestureRecognizer(sortLabelTapGesture)
    }
    
    @objc private func viewToggleButtonTapped() {
        delegate?.didTapViewToggleButton()
    }

    @objc private func folderButtonTapped() {
        delegate?.didTapFolderButton()
    }

    @objc private func sortLabelTapped() {
        delegate?.didTapSortLabel()
    }
}
