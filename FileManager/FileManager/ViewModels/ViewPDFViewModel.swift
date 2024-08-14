//
//  ViewPDFViewModel.swift
//  FileManager
//
//  Created by Macbook on 17/07/2024.
//

import Foundation
import UIKit
import PDFKit

class ViewPDFViewModel {
    
    var fileUrl: URL?
    var document: PDFDocument?
    var uiDocument: Document?
    var overlayCoordinator: MyOverlayCoordinator = MyOverlayCoordinator()
    var page: PDFPage?
    var image: UIImage?
    
    var onDocumentOpenSuccess: (() -> Void)?
    
    init(fileUrl: URL) {
        
        self.fileUrl = fileUrl
        
        if let document = PDFDocument(url: fileUrl as URL) {
            self.document = document
            self.uiDocument = Document(fileURL: fileUrl)
            
            uiDocument?.open(completionHandler: { (success) in
                if success {
                    self.onDocumentOpenSuccess?()
                } else {
                    print("Error loading PDF document")
                }
            })
        } else {
            // Handle document loading error
            print("Error loading PDF document")
            return
        }
    }
    
    //    private func loadPDF() {
    //
    //
    //
    //        if let document = self.document {
    //            pdfView.document = document
    ////            self.uiDocument?.open(completionHandler: { (succes) in
    ////                if succes {
    ////                    self.uiDocument?.pdfDocument?.delegate = self// PDFDocumentDelegate
    ////                    self.pdfView.document = self.viewPDFViewModel?.uiDocument?.pdfDocument
    ////                    self.displaysDocument()
    ////
    ////                } else {
    ////                    print("Fail to load pdf")
    ////                }
    ////            })
    //            uiDocument?.open(completionHandler: { (succes) in
    //                if succes {
    //                    self.uiDocument?.pdfDocument?.delegate = self
    //                    self.displaysDocument()
    //                }
    //            })
    //
    //        } else {
    //            print("Failed to load the PDF document.")
    //        }
    //    }
    
    private func displaysDocument() {
        guard let document = self.document,
              let page: MyPDFPage = document.page(at: 0) as? MyPDFPage else {
            return
        }
        // Setup canvas for MyPDFPage
        self.setupCanvasView(at: page)
        
        guard let pageCanvasView = page.canvasView else {
            return
        }
        MyPDFKitToolPickerModel.shared.toolPicker.setVisible(true, forFirstResponder: pageCanvasView)
        pageCanvasView.becomeFirstResponder()
    }
    
    private func setupCanvasView(at page: MyPDFPage) {
        if page.canvasView == nil,
           let storedCanvas = self.overlayCoordinator.pageToViewMapping[page] {
            page.canvasView = storedCanvas
        } else {
            // create canvasView
            page.canvasView = self.overlayCoordinator.overlayView(for: page)
        }
    }
    
}



extension PDFView {
    func panWithTwoFingers() {
        for view in self.subviews {
            if let subView = view as? UIScrollView {
                subView.panGestureRecognizer.minimumNumberOfTouches = 2
            }
        }
    }
}
