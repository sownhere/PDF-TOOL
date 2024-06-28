//
//  OneCellCollectionViewCell.swift
//  FileManager
//
//  Created by Macbook on 17/06/2024.
//

import UIKit

class OneCellCollectionViewCell: UICollectionViewCell {
    
    
    @IBOutlet weak var moreBtn: UIButton!
    @IBOutlet weak var sizeLabel: UILabel!
    @IBOutlet weak var dateCreatedLabel: UILabel!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var imageView: UIImageView!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    
    
    public func configure(with item: HomeViewModel.FolderOrFile) {
            switch item {
            case .folder(let folder):
                nameLabel.text = folder.name
                imageView.image = UIImage(named: "Folder")
                sizeLabel.text = "\(folder.subFolders.count + folder.files.count) items"
                dateCreatedLabel.text = formattedDate(folder.creationDate)
                
            case .file(let file):
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
