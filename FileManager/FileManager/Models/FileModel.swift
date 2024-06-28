//
//  FileModel.swift
//  FileManager
//
//  Created by Macbook on 27/06/2024.
//

import Foundation
import UIKit

struct FileModel {
    var url: URL?
    var name: String?
    var creationDate: Date?
    var modificationDate: Date?
    var size: Int64?
    var data: UIImage?
    
    init(url: URL) {
        self.url = url
        
        do {
            let resourceValues = try url.resourceValues(forKeys: [.fileSizeKey, .creationDateKey, .contentModificationDateKey, .nameKey])
            
            self.name = resourceValues.name
            self.creationDate = resourceValues.creationDate
            self.modificationDate = resourceValues.contentModificationDate
            
            if let fileSize = resourceValues.fileSize {
                self.size = Int64(fileSize)
            }
            
            if url.pathExtension.lowercased() == "pdf" {
                self.data = FileModel.configurePDFView(url: url)
            }
        } catch {
            print("Error initializing FileModel: \(error)")
            self.data = nil
        }
    }
    
    
    static func configurePDFView(url: URL) -> UIImage? {
        guard let document = CGPDFDocument(url as CFURL), let page = document.page(at: 1) else {
            return nil
        }
        
        let pageRect = page.getBoxRect(.mediaBox)
        UIGraphicsBeginImageContext(pageRect.size)
        guard let context = UIGraphicsGetCurrentContext() else { return nil }
        
        // White background
        context.setFillColor(UIColor.white.cgColor)
        context.fill(pageRect)
        
        // Render the PDF page into the context
        context.translateBy(x: 0.0, y: pageRect.size.height)
        context.scaleBy(x: 1.0, y: -1.0)
        context.drawPDFPage(page)
        
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return image
    }
    
    
}
