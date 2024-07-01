//
//  EditImageScannerViewController.swift
//  FileManager
//
//  Created by Macbook on 04/07/2024.
//
import AVFoundation
import UIKit


/// A protocol that your delegate object will get results of EditImageViewController.
public protocol EditImageScannerViewDelegate: AnyObject {
    /// A method that your delegate object must implement to get cropped image.
    func cropped(image: UIImage)
}

class EditImageScannerViewController: UIViewController {

    @IBOutlet weak var nextBarButton: UIBarButtonItem!
    @IBOutlet weak var cancelBarButton: UIBarButtonItem!
    
    @IBOutlet weak var scrollView: UIScrollView!
    
    
    @IBOutlet weak var horizontalStackView: UIStackView!
    
    private lazy var imageContainerView: UIView = {
            let view = UIView()
            view.translatesAutoresizingMaskIntoConstraints = false
            view.backgroundColor = .clear // Đặt màu nền tùy ý
            return view
        }()
    
    private lazy var nextPageButton: UIButton = {
        let nextPageButton = UIButton()
        nextPageButton.isEnabled = true
        nextPageButton.titleLabel?.text = "nextPage"
        nextPageButton.translatesAutoresizingMaskIntoConstraints = false
        nextPageButton.tintColor = .red
        return nextPageButton
    }()
    
    /// The image the quadrilateral was detected on.
    private var images: [UIImage] = []
    private var image: UIImage

    /// The detected quadrilateral that can be edited by the user. Uses the image's coordinates.
    private var quads: [Quadrilateral] = []
    private var quad: Quadrilateral
    private var zoomGestureController: ZoomGestureController!
    private var quadViewWidthConstraint = NSLayoutConstraint()
    private var quadViewHeightConstraint = NSLayoutConstraint()
    public weak var delegate: EditImageScannerViewDelegate?

    private lazy var imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.clipsToBounds = true
        imageView.isOpaque = true
        imageView.image = image
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()

    private lazy var quadView: QuadrilateralView = {
        let quadView = QuadrilateralView()
        quadView.editable = true
        quadView.translatesAutoresizingMaskIntoConstraints = false
        return quadView
    }()


    

    
    
    // MARK: - Life Cycle

    public init(images: [UIImage]?, quads: [Quadrilateral?]?, rotateImage: Bool = true, strokeColor: CGColor? = nil, image: UIImage, quad: Quadrilateral?) {
//        self.image = rotateImage ? image.applyingPortraitOrientation() : image
        self.image = image
        self.quad = quad ?? EditImageScannerViewController.defaultQuad(forImage: image)


        super.init(nibName: nil, bundle: nil)
    }

    public required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override public func viewDidLoad() {
        super.viewDidLoad()

        setupViews()
        setupConstraints()
        
        zoomGestureController = ZoomGestureController(image: image, quadView: quadView)
        
        let touchDown = UILongPressGestureRecognizer(target: zoomGestureController, action: #selector(zoomGestureController.handle(pan:)))
        touchDown.minimumPressDuration = 0
        self.horizontalStackView.addGestureRecognizer(touchDown)
        
        cancelBarButton.target = self
        cancelBarButton.action = #selector(cancelButtonTapped)
        
        nextBarButton.target = self
        nextBarButton.action = #selector(pushReviewController)
        
        let nextPageButtonPress = UILongPressGestureRecognizer(target: self, action: #selector(nextPagePress))
        
        nextPageButton.addGestureRecognizer(nextPageButtonPress)

    }
    
    @objc func nextPagePress() {
        print("nextPages was Pressed")
    }

    override public func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        adjustQuadViewConstraints()
        displayQuad()
    }




    // MARK: - Setups

    private func setupViews() {
        horizontalStackView.addSubview(imageContainerView)
        imageContainerView.addSubview(imageView)
        imageContainerView.addSubview(quadView)
        imageContainerView.addSubview(nextPageButton)
    }

    private func setupConstraints() {
        let imageViewConstraints = [
            imageView.topAnchor.constraint(equalTo: view.topAnchor),
            imageView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            view.bottomAnchor.constraint(equalTo: imageView.bottomAnchor),
            view.leadingAnchor.constraint(equalTo: imageView.leadingAnchor)
        ]

        quadViewWidthConstraint = quadView.widthAnchor.constraint(equalToConstant: 0.0)
        quadViewHeightConstraint = quadView.heightAnchor.constraint(equalToConstant: 0.0)

        let quadViewConstraints = [
            quadView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            quadView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            quadViewWidthConstraint,
            quadViewHeightConstraint
        ]

        NSLayoutConstraint.activate(quadViewConstraints + imageViewConstraints)
        
        let widthConstraint = horizontalStackView.widthAnchor.constraint(greaterThanOrEqualTo: scrollView.widthAnchor)
        widthConstraint.priority = UILayoutPriority.defaultLow
        widthConstraint.isActive = true
        
        NSLayoutConstraint.activate([
            

        
            imageContainerView.topAnchor.constraint(equalTo: horizontalStackView.topAnchor),
            horizontalStackView.bottomAnchor.constraint(equalTo: imageContainerView.bottomAnchor),
            horizontalStackView.leadingAnchor.constraint(equalTo: imageContainerView.leadingAnchor),
            
            view.bottomAnchor.constraint(equalTo: nextPageButton.bottomAnchor),
            nextPageButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            nextPageButton.widthAnchor.constraint(equalToConstant: 50),
            nextPageButton.heightAnchor.constraint(equalToConstant: 50)
            
        ])
    }




    
//MARK: - ACTION
    

    
    /// This function allow user to rotate image by 90 degree each and will reload image on image view.


    private func displayQuad() {
        let imageSize = image.size
        let size = CGSize(width: quadViewWidthConstraint.constant, height: quadViewHeightConstraint.constant)
        let imageFrame = CGRect(origin: quadView.frame.origin, size: size)

        let scaleTransform = CGAffineTransform.scaleTransform(forSize: imageSize, aspectFillInSize: imageFrame.size)
        let transforms = [scaleTransform]
        let transformedQuad = quad.applyTransforms(transforms)

        quadView.drawQuadrilateral(quad: transformedQuad, animated: false)
    }

    /// The quadView should be lined up on top of the actual image displayed by the imageView.
    /// Since there is no way to know the size of that image before run time, we adjust the constraints
    /// to make sure that the quadView is on top of the displayed image.
    private func adjustQuadViewConstraints() {
        let frame = AVMakeRect(aspectRatio: image.size, insideRect: imageView.bounds)
        quadViewWidthConstraint.constant = frame.size.width
        quadViewHeightConstraint.constant = frame.size.height
    }

    /// Generates a `Quadrilateral` object that's centered and one third of the size of the passed in image.
    private static func defaultQuad(forImage image: UIImage) -> Quadrilateral {
        let topLeft = CGPoint(x: image.size.width / 3.0, y: image.size.height / 3.0)
        let topRight = CGPoint(x: 2.0 * image.size.width / 3.0, y: image.size.height / 3.0)
        let bottomRight = CGPoint(x: 2.0 * image.size.width / 3.0, y: 2.0 * image.size.height / 3.0)
        let bottomLeft = CGPoint(x: image.size.width / 3.0, y: 2.0 * image.size.height / 3.0)

        let quad = Quadrilateral(topLeft: topLeft, topRight: topRight, bottomRight: bottomRight, bottomLeft: bottomLeft)

        return quad
    }

    /// Generates a `Quadrilateral` object that's cover all of image.
    private static func defaultQuad(allOfImage image: UIImage, withOffset offset: CGFloat = 75) -> Quadrilateral {
        let topLeft = CGPoint(x: offset, y: offset)
        let topRight = CGPoint(x: image.size.width - offset, y: offset)
        let bottomRight = CGPoint(x: image.size.width - offset, y: image.size.height - offset)
        let bottomLeft = CGPoint(x: offset, y: image.size.height - offset)
        let quad = Quadrilateral(topLeft: topLeft, topRight: topRight, bottomRight: bottomRight, bottomLeft: bottomLeft)
        return quad
    }


    // MARK: - Actions
    @objc func cancelButtonTapped() {
        if let editImageScannerViewController = navigationController as? HomeViewController {
            self.dismiss(animated: true)
        }
    }

    @objc func pushReviewController() {
        guard let quad = quadView.quad,
            let ciImage = CIImage(image: image) else {
                if let imageScannerController = navigationController as? ImageScannerController {
                    let error = ImageScannerControllerError.ciImageCreation
                    imageScannerController.imageScannerDelegate?.imageScannerController(imageScannerController, didFailWithError: error)
                }
                return
        }
        let cgOrientation = CGImagePropertyOrientation(image.imageOrientation)
        let orientedImage = ciImage.oriented(forExifOrientation: Int32(cgOrientation.rawValue))
        let scaledQuad = quad.scale(quadView.bounds.size, image.size)
        self.quad = scaledQuad

        // Cropped Image
        var cartesianScaledQuad = scaledQuad.toCartesian(withHeight: image.size.height)
        cartesianScaledQuad.reorganize()

        let filteredImage = orientedImage.applyingFilter("CIPerspectiveCorrection", parameters: [
            "inputTopLeft": CIVector(cgPoint: cartesianScaledQuad.bottomLeft),
            "inputTopRight": CIVector(cgPoint: cartesianScaledQuad.bottomRight),
            "inputBottomLeft": CIVector(cgPoint: cartesianScaledQuad.topLeft),
            "inputBottomRight": CIVector(cgPoint: cartesianScaledQuad.topRight)
        ])

        let croppedImage = UIImage.from(ciImage: filteredImage)
        // Enhanced Image
        let enhancedImage = filteredImage.applyingAdaptiveThreshold()?.withFixedOrientation()
        let enhancedScan = enhancedImage.flatMap { ImageScannerScan(image: $0) }

        let results = ImageScannerResults(
            detectedRectangle: scaledQuad,
            originalScan: ImageScannerScan(image: image),
            croppedScan: ImageScannerScan(image: croppedImage),
            enhancedScan: enhancedScan
        )

        let reviewViewController = ReviewViewController(results: results)
        navigationController?.pushViewController(reviewViewController, animated: true)
    }

    
    
}




extension EditImageScannerViewController {
    
}
