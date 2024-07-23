//
//  FileModel.swift
//  FileManager
//
//  Created by Macbook on 27/06/2024.
//

import Foundation
import UIKit
import PDFKit

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
        guard let pdfDocument = PDFDocument(url: url) else {
            print("Failed to create PDFDocument from URL")
            return nil
        }
        
        guard let pdfPage = pdfDocument.page(at: 0) else {
            print("Failed to get first page of PDF")
            return nil
        }
        
        let pageRect = pdfPage.bounds(for: .mediaBox)
        let renderer = UIGraphicsImageRenderer(size: pageRect.size)
        
        let img = renderer.image { ctx in
            UIColor.white.set()
            ctx.fill(pageRect)
            
            ctx.cgContext.translateBy(x: 0.0, y: pageRect.size.height)
            ctx.cgContext.scaleBy(x: 1.0, y: -1.0)
            
            pdfPage.draw(with: .mediaBox, to: ctx.cgContext)
        }
        
        return img
    }
    
    static func debugPDFStructure(url: URL) {
        guard let pdfDocument = PDFDocument(url: url) else {
            print("Failed to create PDFDocument from URL")
            return
        }
        
        print("PDF Document Info:")
        print("Number of pages: \(pdfDocument.pageCount)")
        
        for i in 0..<pdfDocument.pageCount {
            guard let page = pdfDocument.page(at: i) else { continue }
            print("Page \(i + 1):")
            print("  Bounds: \(page.bounds(for: .mediaBox))")
            print("  Rotation: \(page.rotation)")
        }
    }
}
