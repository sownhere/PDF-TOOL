//
//  EditPDFViewController.swift
//  FileManager
//
//  Created by SownFrenky on 26/7/24.
//

import UIKit

import PDFKit


class DrawPDFViewController: UIViewController, PDFViewDelegate {
    
    private var fileUrl: URL
    
    var document: Document?

    var overlayCoordinator: MyOverlayCoordinator = MyOverlayCoordinator()

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
        self.pdfView.pageOverlayViewProvider = self.overlayCoordinator
        self.pdfView.isInMarkupMode = true
        self.pdfView.panWithTwoFingers()

        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        loadPDF()
//        setupToolbar()
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
//            pdfView.document = document
            self.viewPDFViewModel?.uiDocument?.open(completionHandler: { (succes) in
                if succes {
                    self.viewPDFViewModel?.uiDocument?.pdfDocument?.delegate = self// PDFDocumentDelegate
                    self.pdfView.document = self.viewPDFViewModel?.uiDocument?.pdfDocument
                    self.displaysDocument()

                } else {
                    print("Fail to load pdf")
                }
            })
            
        } else {
            print("Failed to load the PDF document.")
        }
    }

    private func displaysDocument() {
        guard let document = self.pdfView.document,
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

extension DrawPDFViewController: PDFDocumentDelegate {
    public func classForPage() -> AnyClass {
        print(" 1.4 - Request custom page type?")
        return MyPDFPage.self
    }

    public func `class`(forAnnotationType annotationType: String) -> AnyClass {
        switch annotationType {
        case MyPDFAnnotation.drawingDataKey:
            return MyPDFAnnotation.self
        default:
            return PDFAnnotation.self
        }
    }
}
