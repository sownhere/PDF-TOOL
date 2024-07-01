//
//  GridCell.swift
//  FileManager
//
//  Created by Macbook on 26/06/2024.
//

import UIKit

protocol GridCellDelegate: AnyObject {
    func didTapMoreButton(in cell: GridCell, isEditing: Bool)
}

class GridCell: UICollectionViewCell {
    
    var checkboxButton: UIButton!
    var isEditingMode: Bool = false
    var url: URL?
    weak var delegate: GridCellDelegate?
    
    @IBOutlet weak var moreBtn: UIButton!
    @IBOutlet weak var sizeLabel: UILabel!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var imageView: UIImageView!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        moreBtn.addTarget(self, action: #selector(moreButtonTapped), for: .touchUpInside)
    }
    
    @objc func moreButtonTapped() {
        if isEditingMode {
            moreBtn.isSelected = !moreBtn.isSelected  // Toggle selected state
            if moreBtn.isSelected {
                ToolbarStateManager.shared.selectedItems.append(url!)
            } else {
                ToolbarStateManager.shared.selectedItems.removeAll { URL in
                    URL == url
                }
            }
            
            
        }
        delegate?.didTapMoreButton(in: self, isEditing: isEditingMode)
    }
    
    public func configure(with item: HomeViewModel.FolderOrFile, isEditingMode: Bool) {
        switch item {
        case .folder(let folder):
            url = folder.url
            nameLabel.text = folder.name
            imageView.image = UIImage(named: "Folder")
            sizeLabel.text = "\(folder.subFolders.count + folder.files.count) items"
            
        case .file(let file):
            url = file.url
            nameLabel.text = file.name
            if let imageData = file.data {
                imageView.image = imageData
                sizeLabel.text = ByteCountFormatter.string(fromByteCount: Int64(file.size!), countStyle: .file)
            } else {
                imageView.image = UIImage(systemName: "doc")
                sizeLabel.text = "Unknown size"
            }
        }
        self.isEditingMode = isEditingMode
        updateButtonAppearance(isEditingMode: isEditingMode)
    }
    
    private func updateButtonAppearance(isEditingMode: Bool) {
        if isEditingMode {
            moreBtn.setBackgroundImage(UIImage(systemName: "button.programmable.square"), for: .normal)
            moreBtn.setBackgroundImage(UIImage(systemName: "button.programmable.square.fill"), for: .selected)
        } else {
            moreBtn.setBackgroundImage(UIImage(systemName: "ellipsis.circle"), for: .normal)
            moreBtn.isSelected = false  // Đặt lại trạng thái không chọn
        }
    }
    
}

extension GridCell {
    
    static var reuseIdentifier: String {
        return "GridCell"
    }
    
    static var nibName: String {
        return "GridCell"
    }
}
