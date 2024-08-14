//
//  ScannedPageViewController.swift
//  FileManager
//
//  Created by Macbook on 10/07/2024.
//


import UIKit

class ScannedPageViewController: UIViewController {


    var imageScannerResult: ImageScannerResults
    private var renderedImageView:UIImageView!
    private var activityIndicator:UIActivityIndicatorView!
    

    
    init(imageScannerResult: ImageScannerResults){
        self.imageScannerResult = imageScannerResult
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) should not be called for this class")
    }
    
    // MARK: - View lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setUpViews()
    }
        
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.render()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        self.renderedImageView.image = nil
        super.viewDidDisappear(animated)
    }

    // MARK: - Private methods

    private func setUpViews(){
        self.view.backgroundColor = .white
        // Image View
        self.renderedImageView = UIImageView(image: nil)
        self.renderedImageView.translatesAutoresizingMaskIntoConstraints = false
        self.renderedImageView.contentMode = .scaleAspectFit
        
        let constraints = [self.renderedImageView.topAnchor.constraint(equalTo: self.view.topAnchor, constant: 0.0),
                           self.renderedImageView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor, constant: 0.0),
                           self.renderedImageView.leftAnchor.constraint(equalTo: self.view.leftAnchor, constant: 0.0),
                           self.renderedImageView.rightAnchor.constraint(equalTo: self.view.rightAnchor, constant: 0.0)]
        self.view.addSubview(self.renderedImageView)
        NSLayoutConstraint.activate(constraints)
        
        // Spinner
        if #available(iOS 13, *) {
            self.activityIndicator = UIActivityIndicatorView(style: .medium)
        } else {
            self.activityIndicator = UIActivityIndicatorView(style: .white)
        }
        self.activityIndicator.startAnimating()
        self.activityIndicator.hidesWhenStopped = true
        self.activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        let activityIndicatorConstraints = [self.activityIndicator.centerXAnchor.constraint(equalTo: self.view.centerXAnchor),
                                            self.activityIndicator.centerYAnchor.constraint(equalTo: self.view.centerYAnchor)]
        self.view.addSubview(activityIndicator)
        NSLayoutConstraint.activate(activityIndicatorConstraints)
        
    }

    // MARK: - Public methods

    public func render() {
        if self.renderedImageView.image == nil {
            self.activityIndicator.isHidden = false
            self.activityIndicator.startAnimating()
            if imageScannerResult.doesUserPreferEnhancedScan == true {
                self.renderedImageView.image = self.imageScannerResult.enhancedScan?.image
                self.activityIndicator.stopAnimating()
            } else {
                self.renderedImageView.image = self.imageScannerResult.croppedScan.image
                self.activityIndicator.stopAnimating()
            }
            
            
        }
    } 
    
    // MARK: - Public methods
    
    public func reRender(item:ImageScannerResults){
//        if imageScannerResult.doesUserPreferEnhancedScan == true {
//            self.renderedImageView.image = self.imageScannerResult.enhancedScan?.image
//        } else {
//            self.renderedImageView.image = self.imageScannerResult.croppedScan.image
//        }
        self.renderedImageView.image = nil
        self.imageScannerResult = item
        self.render()
    }

}
