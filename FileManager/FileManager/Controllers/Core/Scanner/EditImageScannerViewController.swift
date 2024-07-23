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
    
    
    

    
    // MARK: - Life Cycle




    override public func viewDidLoad() {
        super.viewDidLoad()

    

    }


    
}




extension EditImageScannerViewController {
    
}
