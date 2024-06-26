//
//  OneCellCollectionViewCell.swift
//  FileManager
//
//  Created by Macbook on 17/06/2024.
//

import UIKit

class OneCellCollectionViewCell: UICollectionViewCell {
    
    
    @IBOutlet weak var moreBtn: UIButton!
    @IBOutlet weak var sizeLable: UILabel!
    @IBOutlet weak var dateCreatedLable: UILabel!
    @IBOutlet weak var nameLable: UILabel!
    @IBOutlet weak var imageView: UIImageView!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    //    public func configure(with item: URL) {
    //        do {
    //            let resourceValues = try item.resourceValues(forKeys: [.isDirectoryKey, .fileSizeKey, .creationDateKey, .contentModificationDateKey])
    //
    //            nameLable.text = item.lastPathComponent
    //
    //            if let isDirectory = resourceValues.isDirectory {
    //                if isDirectory {
    //                    imageView.image = UIImage(named: "Folder")
    //
    //                    if let entryCount = try? item.resourceValues(forKeys: [.directoryEntryCountKey]).directoryEntryCount {
    //                        sizeLable.text = "\(entryCount) items"
    //                    } else {
    //                        sizeLable.text = "Unknown items"
    //                    }
    //                } else {
    //                    imageView.image = UIImage(systemName: "doc")
    //                    if let fileSize = resourceValues.fileSize {
    //                        sizeLable.text = ByteCountFormatter.string(fromByteCount: Int64(fileSize), countStyle: .file)
    //                    } else {
    //                        sizeLable.text = "Unknown size"
    //                    }
    //                }
    //            }
    //
    //            if let creationDate = resourceValues.creationDate {
    //                let formatter = DateFormatter()
    //                formatter.dateStyle = .medium
    //                formatter.timeStyle = .none
    //                dateCreatedLable.text = "\(formatter.string(from: creationDate))"
    //            } else {
    //                dateCreatedLable.text = "Created: Unknown"
    //            }
    //        } catch {
    //            print("Error getting resource values: \(error)")
    //            nameLable.text = item.lastPathComponent
    //            sizeLable.text = "Unknown"
    //            dateCreatedLable.text = "Unknown"
    //            imageView.image = UIImage(systemName: "questionmark")
    //        }
    //    }
    //}
    
    
    public func configure(with item: URL) {
        do {
            let resourceValues = try item.resourceValues(forKeys: [.isDirectoryKey, .fileSizeKey, .creationDateKey, .contentModificationDateKey])
            
            nameLable.text = item.lastPathComponent
            
            if let isDirectory = resourceValues.isDirectory {
                if isDirectory {
                    imageView.image = UIImage(named: "Folder")
                    if let entryCount = try? item.resourceValues(forKeys: [.directoryEntryCountKey]).directoryEntryCount {
                        sizeLable.text = "\(entryCount) items"
                    } else {
                        sizeLable.text = "Unknown items"
                    }
                } else {
                    // Check for image or PDF and load appropriately
                    if item.pathExtension.lowercased() == "pdf" {
                        configurePDFView(item: item)
                        if let fileSize = resourceValues.fileSize {
                                                sizeLable.text = ByteCountFormatter.string(fromByteCount: Int64(fileSize), countStyle: .file)
                                            } else {
                                                sizeLable.text = "Unknown size"
                                            }
                    } else {
                        if let imageData = try? Data(contentsOf: item) {
                            imageView.image = UIImage(data: imageData)
                            sizeLable.text = ByteCountFormatter.string(fromByteCount: Int64(imageData.count), countStyle: .file)
                        } else {
                            imageView.image = UIImage(systemName: "doc")
                            sizeLable.text = "Unknown size"
                        }
                    }
                }
            }
            
            if let creationDate = resourceValues.creationDate {
                let formatter = DateFormatter()
                formatter.dateStyle = .medium
                formatter.timeStyle = .none
                dateCreatedLable.text = "\(formatter.string(from: creationDate))"
            } else {
                dateCreatedLable.text = "Created: Unknown"
            }
        } catch {
            print("Error getting resource values: \(error)")
            nameLable.text = item.lastPathComponent
            sizeLable.text = "Unknown"
            dateCreatedLable.text = "Unknown"
            imageView.image = UIImage(systemName: "questionmark")
        }
    }
    
    func configurePDFView(item: URL) {
        if let document = CGPDFDocument(item as CFURL), let page = document.page(at: 1) {
            let pageRect = page.getBoxRect(.mediaBox)
            UIGraphicsBeginImageContext(pageRect.size)
            let context = UIGraphicsGetCurrentContext()!
            
            // White background
            context.setFillColor(UIColor.white.cgColor)
            context.fill(pageRect)
            
            // Render the PDF page into the context
            context.translateBy(x: 0.0, y: pageRect.size.height)
            context.scaleBy(x: 1.0, y: -1.0)
            context.drawPDFPage(page)
            
            let image = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
            
            imageView.image = image
        }
    }
}
