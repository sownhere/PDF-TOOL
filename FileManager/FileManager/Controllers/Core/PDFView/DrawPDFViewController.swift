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
//    var pdfDocument: PDFDocument?
    var document: Document?

    var overlayCoordinator: MyOverlayCoordinator = MyOverlayCoordinator()

    var viewPDFViewModel: ViewPDFViewModel?
    private var lastContentOffset: CGFloat = 0
    
    lazy private var saveButton: UIBarButtonItem = {
        let title = NSLocalizedString("wescan.edit.button.save", tableName: nil, bundle: Bundle(for: MultiPageScanSessionViewController.self), value: "Save", comment: "Save button")
        let button = UIBarButtonItem(title: title, style: .done, target: self, action: #selector(handleSave))
        button.tintColor = navigationController?.navigationBar.tintColor
        return button
    }()
    
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
//        self.pdfDocument = self.viewPDFViewModel?.document
        viewPDFViewModel?.onDocumentOpenSuccess = { [weak self] in
                    self?.loadPDF()
                }
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) should not be called for this class")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupNavigationBar()
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
    
    // Setup Navigation Bar
    func setupNavigationBar() {
        self.navigationItem.rightBarButtonItem = saveButton
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
//        viewPDFViewModel.uiDocument?.open(completionHandler: { (succes) in
//            if succes {
                viewPDFViewModel.uiDocument?.pdfDocument?.delegate = self// PDFDocumentDelegate
                self.pdfView.document = self.viewPDFViewModel?.uiDocument?.pdfDocument
                self.displaysDocument()
//            }
//        })
//        if let document = viewPDFViewModel.document {
//            document.delegate = self
//            pdfView.document = document
//
//            displaysDocument()
//        } else {
//            print("Failed to load the PDF document.")
//        }

    }
    
    @objc func handleSave() {
        save()
    }
    
    private func save() {
    
        print("   2 - Saves document")

        let url = self.fileUrl
        guard let document = self.viewPDFViewModel?.uiDocument else {
            return
        }

        self.pdfView.document = nil
        
        self.dismiss(animated: true)
        
        print("Will then try to save at URL : \(url)")
        
        document.close(completionHandler: { [weak self] (success) in
            guard let self = self else { return }
            if success {
                document.save(to: url,
                              for: .forOverwriting,
                              completionHandler: { (success) in
                    print(" 2.4 - Saved at \(url)")
                })
                self.navigationController?.popViewController(animated: true)
            } else {
                print("Sorry, error !")
            }
        })
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
