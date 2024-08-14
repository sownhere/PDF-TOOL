//
//  VIewPDFViewController.swift
//  FileManager
//
//  Created by Macbook on 17/07/2024.
//

import UIKit
import PDFKit
import PhotosUI


class ViewPDFViewController: UIViewController, PDFViewDelegate, PDFDocumentDelegate {
    
    private var fileUrl: URL
    private var isGrayDisplay = true
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
        self.viewPDFViewModel = ViewPDFViewModel(fileUrl: self.fileUrl)
        viewPDFViewModel?.onDocumentOpenSuccess = { [weak self] in
                    self?.loadPDF()
                }
        setupToolbar()
    }
    
    // Set up toolbar
    func setupToolbar() {
        toolbar.translatesAutoresizingMaskIntoConstraints = false
        toolbar.backgroundColor = .white
        
        toolbar.addButtonAction = { [weak self] in
            self!.presentPhotoPicker()
        }
        toolbar.drawButtonAction = {
            self.navigationController?.pushViewController(DrawPDFViewController(fileURL: self.fileUrl), animated: true)
        }
        toolbar.signButtonAction = { [weak self] in
            guard let self = self else { return }
            guard let doc = self.pdfView.document else { return }
            let signPDFPageViewController = SignPDFPageViewController(document: doc, pageIndex: 0)
            self.navigationController?.pushViewController(signPDFPageViewController, animated: true)
        }
        toolbar.toTextButtonAction = {
            print("To text button pressed")
            self.isGrayDisplay.toggle()
            self.pdfView.document = nil
            self.loadPDF()
        }
        toolbar.rotateButtonAction = {
            let currentPage = self.pdfView.currentPage
            currentPage?.rotation += 90
            self.pdfView.document?.write(to: self.fileUrl)
        }
        toolbar.deleteButtonAction = {
            print("Delete button pressed")
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
        
        if let document = viewPDFViewModel.uiDocument?.pdfDocument {
            
            if isGrayDisplay {
                pdfView.document = document
            } else {
                pdfView.document = self.viewPDFViewModel?.uiDocument?.pdfDocument
            }
        } else {
            print("Failed to load the PDF document.")
        }
    }
}

extension ViewPDFViewController: PHPickerViewControllerDelegate {
    func presentPhotoPicker() {
        var configuration = PHPickerConfiguration(photoLibrary: .shared())
        configuration.selectionLimit = 0 // 0 means no limit
        configuration.filter = .images // Only images

        let picker = PHPickerViewController(configuration: configuration)
        picker.delegate = self
        present(picker, animated: true, completion: nil)
    }

    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        picker.dismiss(animated: true, completion: nil)

        // If no image is selected, return
        guard !results.isEmpty else { return }

        let dispatchGroup = DispatchGroup()
        var images: [UIImage] = []
        for result in results {
            dispatchGroup.enter()
            result.itemProvider.loadObject(ofClass: UIImage.self) { (object, error) in
                if let image = object as? UIImage {
                    images.append(image)
                } else {
                    print(error as Any)
                }
                dispatchGroup.leave()
            }
        }

        dispatchGroup.notify(queue: .main) {
            // Convert all images to PDFPage
            // check index of current pdfPage of PDFDocument, add all pag after it
            // Get index of current page
            let currentPage = self.pdfView.currentPage
            guard var currentPageIndex = self.pdfView.document?.index(for: currentPage!) else { return }
            
            for image in images {
                if let imageData = image.pdfData() {  // Use the modified method
                    if let imagePDFDoc = PDFDocument(data: imageData),
                       let page = imagePDFDoc.page(at: 0) {
                        self.pdfView.document?.insert(page, at: currentPageIndex + 1)
                        self.pdfView.document?.write(toFile: self.fileUrl.path)
                    }
                }
                currentPageIndex += 1
                print("Added a new page")
            }
        }
    }
}

extension PDFPage {
    /// Converts a PDFPage to a UIImage
    func toImage() -> UIImage? {
        guard let pageRef = self.pageRef else { return nil }

        let pageRect = pageRef.getBoxRect(.mediaBox)
        let renderer = UIGraphicsImageRenderer(size: pageRect.size)

        return renderer.image { ctx in
            UIColor.white.set()
            ctx.fill(pageRect)

            ctx.cgContext.translateBy(x: 0.0, y: pageRect.height)
            ctx.cgContext.scaleBy(x: 1.0, y: -1.0)

            ctx.cgContext.drawPDFPage(pageRef)
        }
    }
    
    /// Converts a PDFPage to a grayscale UIImage
    func toGrayscaleImage() -> UIImage? {
        guard let image = self.toImage() else { return nil }
        guard let cgImage = image.cgImage else { return nil }

        let colorSpace = CGColorSpaceCreateDeviceGray()
        guard let context = CGContext(
            data: nil,
            width: cgImage.width,
            height: cgImage.height,
            bitsPerComponent: 8,
            bytesPerRow: 0,
            space: colorSpace,
            bitmapInfo: CGImageAlphaInfo.none.rawValue
        ) else { return nil }

        context.draw(cgImage, in: CGRect(origin: .zero, size: image.size))

        guard let grayscaleImage = context.makeImage() else { return nil }
        return UIImage(cgImage: grayscaleImage)
    }
}

