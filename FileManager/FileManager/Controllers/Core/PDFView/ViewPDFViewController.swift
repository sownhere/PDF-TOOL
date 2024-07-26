//
//  VIewPDFViewController.swift
//  FileManager
//
//  Created by Macbook on 17/07/2024.
//

import UIKit
import PDFKit


class ViewPDFViewController: UIViewController, PDFViewDelegate {
    
    private var fileUrl: URL
    var viewPDFViewModel: ViewPDFViewModel?
    private var lastContentOffset: CGFloat = 0
    
    private lazy var toolbar: CustomToolbarButtonForPDF = {
        let toolbar = CustomToolbarButtonForPDF()
        toolbar.translatesAutoresizingMaskIntoConstraints = false
        return toolbar
    }()
    
    private lazy var pdfView: PDFView = {
        var pdfView = PDFView()
        pdfView.translatesAutoresizingMaskIntoConstraints = false
        return pdfView
    }()

    public init(fileURL:URL){
        self.fileUrl = fileURL
        super.init(nibName: nil, bundle: nil)
        self.viewPDFViewModel = ViewPDFViewModel(fileUrl: fileURL)
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) should not be called for this class")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpPDFView()
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        loadPDF()
        setupToolbar()
    }
    
    // Set up toolbar
    func setupToolbar() {
        toolbar.translatesAutoresizingMaskIntoConstraints = false
        toolbar.backgroundColor = .white
        toolbar.drawButtonAction = {
            self.navigationController?.pushViewController(DrawPDFViewController(fileURL: self.fileUrl), animated: true)
        }
        toolbar.signButtonAction = {
            print("Sign button pressed")
        }
        toolbar.toTextButtonAction = {
            print("To text button pressed")
        }
        toolbar.rotateButtonAction = {
            var currentPage = self.pdfView.currentPage
            currentPage?.rotation += 90
            self.pdfView.document?.write(to: self.fileUrl)
        }
        
        self.view.addSubview(toolbar)
        toolbar.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        toolbar.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        toolbar.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        toolbar.heightAnchor.constraint(equalToConstant: 50).isActive = true
    }

    // Set up the PDFView
    func setUpPDFView() {
        // Optional: Set up the display mode
        pdfView.autoScales = true  // Automatically scale the PDF to fit the view
        pdfView.displayDirection = .vertical
        pdfView.displayMode = .singlePageContinuous
        self.view.backgroundColor = .white
        self.view.addSubview(pdfView)
        pdfView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        pdfView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        pdfView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        pdfView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
    }
    
    
    private func loadPDF() {

        guard let viewPDFViewModel = self.viewPDFViewModel else {
            print("ERROR")
            return
        }
        
        if let document = viewPDFViewModel.document {
            pdfView.document = document
        } else {
            print("Failed to load the PDF document.")
        }
    }
}

