    //
    //  GridCell.swift
    //  FileManager
    //
    //  Created by Macbook on 26/06/2024.
    //

    import UIKit

    class GridCell: UICollectionViewCell {
        
        @IBOutlet weak var moreBtn: UIButton!
        @IBOutlet weak var sizeLabel: UILabel!
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
                    
                case .file(let file):
                    nameLabel.text = file.name
                    if let imageData = file.data {
                        imageView.image = imageData
                        sizeLabel.text = ByteCountFormatter.string(fromByteCount: Int64(file.size!), countStyle: .file)
                    } else {
                        imageView.image = UIImage(systemName: "doc")
                        sizeLabel.text = "Unknown size"
                    }
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
