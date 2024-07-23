//
//  ScannerViewController.swift
//  WeScan
//
//  Created by Boris Emorine on 2/8/18.
//  Copyright © 2018 WeTransfer. All rights reserved.
//
//  swiftlint:disable line_length

import AVFoundation
import UIKit


protocol ScannerViewControllerDelegate:NSObjectProtocol{
    func scannerViewController(_ scannerViewController:ScannerViewController, reviewItems inSession:MultiPageScanSessionViewModel)
    func scannerViewController(_ scannerViewController:ScannerViewController, didFail withError:Error)
    func scannerViewControllerDidCancel(_ scannerViewController:ScannerViewController)
}

/// The `ScannerViewController` offers an interface to give feedback to the user regarding quadrilaterals that are detected. It also gives the user the opportunity to capture an image with a detected rectangle.
public final class ScannerViewController: UIViewController {

    private var captureSessionManager: CaptureSessionManager?
    private let videoPreviewLayer = AVCaptureVideoPreviewLayer()
    
    /// The object that acts as the delegate of the `ScannerViewController`.
    weak var delegate: ScannerViewControllerDelegate?
    

    /// The view that shows the focus rectangle (when the user taps to focus, similar to the Camera app)
    private var focusRectangle: FocusRectangleView!

    /// The view that draws the detected rectangles.
    private let quadView = QuadrilateralView()
    
    /// The visual effect (blur) view used on the navigation bar
    private let visualEffectView = UIVisualEffectView(effect: UIBlurEffect(style: .dark))

    /// Whether flash is enabled
    private var flashEnabled = false

    /// The original bar style that was set by the host app
    private var originalBarStyle: UIBarStyle?
    
    /// The object that will hold the scanned items in this session
    var multipageSession:MultiPageScanSessionViewModel!

    private lazy var shutterButton: ShutterButton = {
        let button = ShutterButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(captureImage(_:)), for: .touchUpInside)
        return button
    }()

    private lazy var cancelButton: UIButton = {
        let button = UIButton()
        button.setTitle(NSLocalizedString("wescan.scanning.cancel", tableName: nil, bundle: Bundle(for: ScannerViewController.self), value: "Cancel", comment: "The cancel button"), for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(cancelImageScannerController), for: .touchUpInside)
        return button
    }()
    
    lazy private var counterButton: UIButton = {
        let button = UIButton()
        button.setTitle("0 >", for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.backgroundColor = UIColor.init(red: 0.0, green: 0.0, blue: 0.0, alpha: 0.5)
        button.layer.borderColor = UIColor.white.cgColor
        button.layer.borderWidth = 1.0
        button.layer.cornerRadius = 5.0
        button.setTitleColor(UIColor.white, for: .normal)
        button.isHidden = true
        button.addTarget(self, action: #selector(counterImageScannerController), for: .touchUpInside)
        return button
    }()
    
    /// A black UIView, used to quickly display a black screen when the shutter button is presseed.
    internal let blackFlashView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(white: 0.0, alpha: 0.5)
        view.isHidden = true
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    private lazy var autoScanButton: UIBarButtonItem = {
        let title = NSLocalizedString("wescan.scanning.auto", tableName: nil, bundle: Bundle(for: ScannerViewController.self), value: "Auto", comment: "The auto button state")
        let button = UIBarButtonItem(title: title, style: .plain, target: self, action: #selector(toggleAutoScan))
        button.tintColor = .black

        return button
    }()

    private lazy var flashButton: UIBarButtonItem = {
        let image = UIImage(systemName: "bolt.fill", named: "flash", in: Bundle(for: ScannerViewController.self), compatibleWith: nil)
        let button = UIBarButtonItem(image: image, style: .plain, target: self, action: #selector(toggleFlash))
        button.tintColor = .white

        return button
    }()

    private lazy var activityIndicator: UIActivityIndicatorView = {
        let activityIndicator = UIActivityIndicatorView(style: .gray)
        activityIndicator.hidesWhenStopped = true
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        return activityIndicator
    }()

    // MARK: - Life Cycle

    override public func viewDidLoad() {
        super.viewDidLoad()

        title = nil
        view.backgroundColor = UIColor.black

        setupViews()
        setupNavigationBar()
        setupConstraints()

        captureSessionManager = CaptureSessionManager(videoPreviewLayer: videoPreviewLayer, delegate: self)
        CaptureSession.current.isAutoScanEnabled = false

        originalBarStyle = navigationController?.navigationBar.barStyle

        NotificationCenter.default.addObserver(self, selector: #selector(subjectAreaDidChange), name: Notification.Name.AVCaptureDeviceSubjectAreaDidChange, object: nil)
    }

    override public func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setNeedsStatusBarAppearanceUpdate()

        CaptureSession.current.isEditing = false
        quadView.removeQuadrilateral()
        captureSessionManager?.start()
        UIApplication.shared.isIdleTimerDisabled = true
        navigationController?.navigationBar.isTranslucent = true
        navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        navigationController?.navigationBar.addSubview(visualEffectView)
        navigationController?.navigationBar.sendSubviewToBack(visualEffectView)
        navigationController?.navigationBar.barStyle = .blackTranslucent
        
        navigationController?.setToolbarHidden(true, animated: true)
        
        updateCounterButton()
    }

    override public func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        videoPreviewLayer.frame = view.layer.bounds
        
        let statusBarHeight = UIApplication.shared.statusBarFrame.size.height
        let visualEffectRect = self.navigationController?.navigationBar.bounds.insetBy(dx: 0, dy: -(statusBarHeight)).offsetBy(dx: 0, dy: -statusBarHeight)
        
        visualEffectView.frame = visualEffectRect ?? CGRect.zero
    }

    override public func viewWillDisappear(_ animated: Bool) {
//        super.viewWillDisappear(animated)
//        UIApplication.shared.isIdleTimerDisabled = false
//
//        navigationController?.navigationBar.isTranslucent = false
////        navigationController?.navigationBar.barStyle = originalBarStyle ?? .default
//        navigationController?.navigationBar.barStyle = .default
//        captureSessionManager?.stop()
//        guard let device = AVCaptureDevice.default(for: AVMediaType.video) else { return }
//        if device.torchMode == .on {
//            toggleFlash()
//        }
        super.viewWillDisappear(animated)
        UIApplication.shared.isIdleTimerDisabled = false
        
        visualEffectView.removeFromSuperview()
        navigationController?.navigationBar.isTranslucent = false
        navigationController?.navigationBar.barStyle = originalBarStyle ?? .default
        
        guard let device = AVCaptureDevice.default(for: AVMediaType.video) else { return }
        if device.torchMode == .on {
            toggleFlash()
        }
    }

    // MARK: - Setups

    private func setupViews() {
        view.backgroundColor = .darkGray
//        view.layer.addSublayer(videoPreviewLayer)
//        quadView.translatesAutoresizingMaskIntoConstraints = false
//        quadView.editable = false
//        view.addSubview(quadView)
//        view.addSubview(cancelButton)
//        view.addSubview(shutterButton)
//        view.addSubview(activityIndicator)
        view.layer.addSublayer(videoPreviewLayer)
        quadView.translatesAutoresizingMaskIntoConstraints = false
        quadView.editable = false
        view.addSubview(quadView)
        view.addSubview(cancelButton)
        view.addSubview(counterButton)
        view.addSubview(shutterButton)
        view.addSubview(activityIndicator)
        view.addSubview(blackFlashView)
    }

    private func setupNavigationBar() {
//        navigationItem.setLeftBarButton(flashButton, animated: false)
//        navigationItem.setRightBarButton(autoScanButton, animated: false)
//
//        if UIImagePickerController.isFlashAvailable(for: .rear) == false {
//            let flashOffImage = UIImage(systemName: "bolt.slash.fill", named: "flashUnavailable", in: Bundle(for: ScannerViewController.self), compatibleWith: nil)
//            flashButton.image = flashOffImage
//            flashButton.tintColor = UIColor.lightGray
//        }
        navigationItem.setLeftBarButton(flashButton, animated: false)
        navigationItem.setRightBarButton(autoScanButton, animated: false)
        
        if UIImagePickerController.isFlashAvailable(for: .rear) == false {
//            let flashOffImage = UIImage(named: "flashUnavailable", in: Bundle(for: ScannerViewController.self), compatibleWith: nil)
            let flashOffImage = UIImage(systemName: "bolt.slash.fill", named: "flashUnavailable", in: Bundle(for: ScannerViewController.self), compatibleWith: nil)
            flashButton.image = flashOffImage
            flashButton.tintColor = UIColor.lightGray
        }
    }

    private func setupConstraints() {
        var quadViewConstraints = [NSLayoutConstraint]()
        var cancelButtonConstraints = [NSLayoutConstraint]()
        var counterButtonConstraints = [NSLayoutConstraint]()
        var shutterButtonConstraints = [NSLayoutConstraint]()
        var activityIndicatorConstraints = [NSLayoutConstraint]()
        var blackFlashViewConstraints = [NSLayoutConstraint]()

        quadViewConstraints = [
            quadView.topAnchor.constraint(equalTo: view.topAnchor),
            view.bottomAnchor.constraint(equalTo: quadView.bottomAnchor),
            view.trailingAnchor.constraint(equalTo: quadView.trailingAnchor),
            quadView.leadingAnchor.constraint(equalTo: view.leadingAnchor)
        ]

        shutterButtonConstraints = [
            shutterButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            shutterButton.widthAnchor.constraint(equalToConstant: 65.0),
            shutterButton.heightAnchor.constraint(equalToConstant: 65.0)
        ]

        activityIndicatorConstraints = [
            activityIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            activityIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ]
        
        blackFlashViewConstraints = [
            blackFlashView.topAnchor.constraint(equalTo: view.topAnchor),
            blackFlashView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            view.bottomAnchor.constraint(equalTo: blackFlashView.bottomAnchor),
            view.trailingAnchor.constraint(equalTo: blackFlashView.trailingAnchor)
        ]
        

        if #available(iOS 11.0, *) {
            cancelButtonConstraints = [
                cancelButton.leftAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leftAnchor, constant: 24.0),
                view.safeAreaLayoutGuide.bottomAnchor.constraint(equalTo: cancelButton.bottomAnchor, constant: (65.0 / 2) - 10.0)
            ]
            
            counterButtonConstraints = [
                counterButton.centerYAnchor.constraint(equalTo: shutterButton.centerYAnchor),
                counterButton.rightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.rightAnchor, constant: -24.0),
                counterButton.widthAnchor.constraint(equalToConstant: 44.0),
                counterButton.heightAnchor.constraint(equalToConstant: 44.0)
            ]
            

            let shutterButtonBottomConstraint = view.safeAreaLayoutGuide.bottomAnchor.constraint(equalTo: shutterButton.bottomAnchor, constant: 8.0)
            shutterButtonConstraints.append(shutterButtonBottomConstraint)
        } else {
            cancelButtonConstraints = [
                cancelButton.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 24.0),
                view.bottomAnchor.constraint(equalTo: cancelButton.bottomAnchor, constant: (65.0 / 2) - 10.0)
            ]

            let shutterButtonBottomConstraint = view.bottomAnchor.constraint(equalTo: shutterButton.bottomAnchor, constant: 8.0)
            shutterButtonConstraints.append(shutterButtonBottomConstraint)
        }

//        NSLayoutConstraint.activate(quadViewConstraints + cancelButtonConstraints + shutterButtonConstraints + activityIndicatorConstraints)
        
        NSLayoutConstraint.activate(quadViewConstraints + cancelButtonConstraints + shutterButtonConstraints + activityIndicatorConstraints + counterButtonConstraints + blackFlashViewConstraints)
    }
    
    private func flashToBlack() {
        view.bringSubviewToFront(blackFlashView)
        blackFlashView.isHidden = false
        let flashDuration = DispatchTime.now() + 0.05
        DispatchQueue.main.asyncAfter(deadline: flashDuration) {
            self.blackFlashView.isHidden = true
        }
    }

    // MARK: - Tap to Focus

    /// Called when the AVCaptureDevice detects that the subject area has changed significantly. When it's called, we reset the focus so the camera is no longer out of focus.
    @objc private func subjectAreaDidChange() {
//        /// Reset the focus and exposure back to automatic
//        do {
//            try CaptureSession.current.resetFocusToAuto()
//        } catch {
//            let error = ImageScannerControllerError.inputDevice
//            guard let captureSessionManager else { return }
//            captureSessionManager.delegate?.captureSessionManager(captureSessionManager, didFailWithError: error)
//            return
//        }
//
//        /// Remove the focus rectangle if one exists
//        CaptureSession.current.removeFocusRectangleIfNeeded(focusRectangle, animated: true)
        /// Reset the focus and exposure back to automatic
        do {
            try CaptureSession.current.resetFocusToAuto()
        } catch {
            let error = ImageScannerControllerError.inputDevice
            guard let captureSessionManager = captureSessionManager else { return }
            captureSessionManager.delegate?.captureSessionManager(captureSessionManager, didFailWithError: error)
            return
        }
        
        /// Remove the focus rectangle if one exists
        CaptureSession.current.removeFocusRectangleIfNeeded(focusRectangle, animated: true)
    }

    override public func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
//        super.touchesBegan(touches, with: event)
//
//        guard  let touch = touches.first else { return }
//        let touchPoint = touch.location(in: view)
//        let convertedTouchPoint: CGPoint = videoPreviewLayer.captureDevicePointConverted(fromLayerPoint: touchPoint)
//
//        CaptureSession.current.removeFocusRectangleIfNeeded(focusRectangle, animated: false)
//
//        focusRectangle = FocusRectangleView(touchPoint: touchPoint)
//        view.addSubview(focusRectangle)
//
//        do {
//            try CaptureSession.current.setFocusPointToTapPoint(convertedTouchPoint)
//        } catch {
//            let error = ImageScannerControllerError.inputDevice
//            guard let captureSessionManager else { return }
//            captureSessionManager.delegate?.captureSessionManager(captureSessionManager, didFailWithError: error)
//            return
//        }
        super.touchesBegan(touches, with: event)
        

            guard  let touch = touches.first else { return }
            let touchPoint = touch.location(in: view)
            let convertedTouchPoint: CGPoint = videoPreviewLayer.captureDevicePointConverted(fromLayerPoint: touchPoint)
            
            CaptureSession.current.removeFocusRectangleIfNeeded(focusRectangle, animated: false)
            
            focusRectangle = FocusRectangleView(touchPoint: touchPoint)
            view.addSubview(focusRectangle)
            
            do {
                try CaptureSession.current.setFocusPointToTapPoint(convertedTouchPoint)
            } catch {
                let error = ImageScannerControllerError.inputDevice
                guard let captureSessionManager = captureSessionManager else { return }
                captureSessionManager.delegate?.captureSessionManager(captureSessionManager, didFailWithError: error)
                return
            }
        
    }
    
    private func updateCounterButton(){
        self.counterButton.isHidden = self.multipageSession.imageScannerResults.count < 1
        self.counterButton.setTitle("\(self.multipageSession.imageScannerResults.count) >", for: .normal)
    }

    // MARK: - Actions

    @objc private func captureImage(_ sender: UIButton) {
        (navigationController as? ImageScannerController)?.flashToBlack()
        shutterButton.isUserInteractionEnabled = false
        captureSessionManager?.capturePhoto()
    }

    @objc private func toggleAutoScan() {
        if CaptureSession.current.isAutoScanEnabled {
            CaptureSession.current.isAutoScanEnabled = false
            autoScanButton.title = NSLocalizedString("wescan.scanning.manual", tableName: nil, bundle: Bundle(for: ScannerViewController.self), value: "Manual", comment: "The manual button state")
        } else {
            CaptureSession.current.isAutoScanEnabled = true
            autoScanButton.title = NSLocalizedString("wescan.scanning.auto", tableName: nil, bundle: Bundle(for: ScannerViewController.self), value: "Auto", comment: "The auto button state")
        }
    }

    @objc private func toggleFlash() {
        let state = CaptureSession.current.toggleFlash()

        let flashImage = UIImage(systemName: "bolt.fill", named: "flash", in: Bundle(for: ScannerViewController.self), compatibleWith: nil)
        let flashOffImage = UIImage(systemName: "bolt.slash.fill", named: "flashUnavailable", in: Bundle(for: ScannerViewController.self), compatibleWith: nil)

        switch state {
        case .on:
            flashEnabled = true
            flashButton.image = flashImage
            flashButton.tintColor = .yellow
        case .off:
            flashEnabled = false
            flashButton.image = flashImage
            flashButton.tintColor = .white
        case .unknown, .unavailable:
            flashEnabled = false
            flashButton.image = flashOffImage
            flashButton.tintColor = UIColor.lightGray
        }
    }

    @objc private func cancelImageScannerController() {
        guard let imageScannerController = navigationController as? ImageScannerController else { return }
        imageScannerController.imageScannerDelegate?.imageScannerControllerDidCancel(imageScannerController)
    }
    
    @objc private func counterImageScannerController(){
        self.delegate?.scannerViewController(self, reviewItems: self.multipageSession)
    }

}

extension ScannerViewController: RectangleDetectionDelegateProtocol {
    func captureSessionManager(_ captureSessionManager: CaptureSessionManager, didFailWithError error: Error) {

        activityIndicator.stopAnimating()
        shutterButton.isUserInteractionEnabled = true

        guard let imageScannerController = navigationController as? ImageScannerController else { return }
        imageScannerController.imageScannerDelegate?.imageScannerController(imageScannerController, didFailWithError: error)
    }

    func didStartCapturingPicture(for captureSessionManager: CaptureSessionManager) {
        activityIndicator.startAnimating()
        captureSessionManager.stop()
        shutterButton.isUserInteractionEnabled = false
    }

    func captureSessionManager(_ captureSessionManager: CaptureSessionManager, didCapturePicture picture: UIImage, withQuad quad: Quadrilateral?) {
        activityIndicator.stopAnimating()
//
////        let editVC = EditScanViewController(image: picture, quad: quad)
////        editVC.modalPresentationStyle = .fullScreen
////        navigationController?.pushViewController(editVC, animated: false)
//
//        shutterButton.isUserInteractionEnabled = true
        activityIndicator.stopAnimating()
        


        self.multipageSession.add(image: picture, quad: quad)
        self.updateCounterButton()
        
        shutterButton.isUserInteractionEnabled = true
        self.captureSessionManager?.start()

    }

    func captureSessionManager(_ captureSessionManager: CaptureSessionManager, didDetectQuad quad: Quadrilateral?, _ imageSize: CGSize) {
        guard let quad else {
            // If no quad has been detected, we remove the currently displayed on on the quadView.
            quadView.removeQuadrilateral()
            return
        }

        let portraitImageSize = CGSize(width: imageSize.height, height: imageSize.width)

        let scaleTransform = CGAffineTransform.scaleTransform(forSize: portraitImageSize, aspectFillInSize: quadView.bounds.size)
        let scaledImageSize = imageSize.applying(scaleTransform)

        let rotationTransform = CGAffineTransform(rotationAngle: CGFloat.pi / 2.0)

        let imageBounds = CGRect(origin: .zero, size: scaledImageSize).applying(rotationTransform)

        let translationTransform = CGAffineTransform.translateTransform(fromCenterOfRect: imageBounds, toCenterOfRect: quadView.bounds)

        let transforms = [scaleTransform, rotationTransform, translationTransform]

        let transformedQuad = quad.applyTransforms(transforms)

        quadView.drawQuadrilateral(quad: transformedQuad, animated: true)
    }

}
