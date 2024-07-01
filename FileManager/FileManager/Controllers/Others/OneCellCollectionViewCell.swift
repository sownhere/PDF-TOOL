//
//  OneCellCollectionViewCell.swift
//  FileManager
//
//  Created by Macbook on 17/06/2024.
//

import UIKit

protocol OneCellDelegate: AnyObject {
    func didTapMoreButton(in cell: OneCellCollectionViewCell, isEditing: Bool)
   
}


class OneCellCollectionViewCell: UICollectionViewCell {
    
    var checkboxButton: UIButton!
    weak var delegate: OneCellDelegate?
    var isEditingMode: Bool = false
    var url: URL?
    
    @IBOutlet weak var moreBtn: UIButton!
    @IBOutlet weak var sizeLabel: UILabel!
    @IBOutlet weak var dateCreatedLabel: UILabel!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var imageView: UIImageView!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        moreBtn.addTarget(self, action: #selector(moreBtnTapped), for: .touchUpInside)
        
    }


    
    @objc func moreBtnTapped() {
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
            dateCreatedLabel.text = formattedDate(folder.creationDate)
            
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
            
            dateCreatedLabel.text = formattedDate(file.creationDate)
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

    
    
    private func formattedDate(_ date: Date?) -> String {
        guard let date = date else { return "Unknown date" }
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        return formatter.string(from: date)
    }
    
}

extension OneCellCollectionViewCell {
    
    static var reuseIdentifier: String {
        return "onelineCell"
    }
    
    static var nibName: String {
        return "OneCellCollectionViewCell"
    }
}
