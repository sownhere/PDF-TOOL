//
//  SignPDFPageViewController.swift
//  FileManager
//
//  Created by SownFrenky on 15/8/24.
//

import Foundation
import UIKit
import PDFKit


class SignPDFPageViewController: UIViewController {
    private lazy var pdfView: PDFView = {
        var pdfView = PDFView()
        pdfView.displayMode = .singlePage
        pdfView.translatesAutoresizingMaskIntoConstraints = false
        return pdfView
    }()
    
    private var document: PDFDocument
    
    private var pageIndex: Int
    
    private var overlayCoordinator: MyOverlayCoordinator = MyOverlayCoordinator()
    
    private var toolbar: CustomToolbarButtonForPDF = {
        let toolbar = CustomToolbarButtonForPDF()
        toolbar.translatesAutoresizingMaskIntoConstraints = false
        return toolbar
    }()
    
    init(document: PDFDocument, pageIndex: Int) {
        self.document = document
        self.pageIndex = pageIndex
        super.init(nibName: nil, bundle: nil)
        self.pdfView.document = self.document
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) should not be called for this class")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupPDFView()
        self.setupNavigationBar()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.setupToolbar()
        self.loadPDF()
    }
    
    private func setupPDFView() {
        self.pdfView.autoScales = true
        self.pdfView.displayDirection = .vertical
        self.pdfView.displayMode = .singlePage
        self.pdfView.usePageViewController(true)
        self.pdfView.pageBreakMargins = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
        self.pdfView.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(self.pdfView)
        self.pdfView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor).isActive = true
        self.pdfView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor).isActive = true
        self.pdfView.topAnchor.constraint(equalTo: self.view.topAnchor).isActive = true
        self.pdfView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor).isActive = true
    }
    
    private func setupNavigationBar() {
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Save", style: .done, target: self, action: #selector(saveButtonTapped))
    }
    
    private func setupToolbar() {
        toolbar.translatesAutoresizingMaskIntoConstraints = false
        toolbar.backgroundColor = .white
        self.toolbar.deleteButtonAction = { [weak self] in
            guard let pdfView = self?.pdfView else {
                return
            }
            let page = pdfView.currentPage

            let textAnnotation = PDFAnnotation(bounds: CGRect(x: 300, y: 200, width: 600, height: 100), forType: PDFAnnotationSubtype(rawValue: PDFAnnotationSubtype.widget.rawValue), withProperties: nil)

                        textAnnotation.widgetFieldType = PDFAnnotationWidgetSubtype(rawValue: PDFAnnotationWidgetSubtype.text.rawValue)

                        textAnnotation.font = UIFont.systemFont(ofSize: 80)

                        textAnnotation.fontColor = .red

                        textAnnotation.isMultiline = true

                        textAnnotation.widgetStringValue = "Text Here"

                        page!.addAnnotation(textAnnotation)
        }
        self.view.addSubview(self.toolbar)
        toolbar.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        toolbar.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        toolbar.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        toolbar.heightAnchor.constraint(equalToConstant: 60).isActive = true
    }
    
    private func loadPDF() {
        guard let page = self.document.page(at: self.pageIndex) else {
            return
        }
        self.pdfView.document = self.document
        self.pdfView.go(to: page)
    }
    
    @objc private func saveButtonTapped() {
        guard let page = self.pdfView.currentPage else {
            return
        }
        let image = page.thumbnail(of: CGSize(width: 200, height: 200), for: .artBox)
        guard let imageData = image.pngData() else {
            return
        }
        let fileManager = FileManager.default
        let url = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first!.appendingPathComponent("image.png")
        do {
            try imageData.write(to: url)
        } catch {
            print("Error: \(error)")
        }
    }
    
    
}
