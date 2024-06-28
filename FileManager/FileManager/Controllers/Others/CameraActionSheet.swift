//
//  BottomSheetController.swift
//  FileManager
//
//  Created by Macbook on 26/06/2024.
//

import UIKit

class CameraActionSheet: UIViewController {

    
    @IBOutlet weak var exitBtn: UIView!
    @IBOutlet weak var importFilesBtn: UIView!
    @IBOutlet weak var photosBtn: UIView!
    @IBOutlet weak var cameraBtn: UIView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        
        // Initialize tap gesture recognizer for exit button
        let exitTapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissActionSheet))
        exitBtn.isUserInteractionEnabled = true
        exitBtn.addGestureRecognizer(exitTapGesture)
        
    }
    
    @objc func dismissActionSheet() {
            // Dismiss the current view controller
            dismiss(animated: true, completion: nil)
    }
    
    
    
}

extension CameraActionSheet {
    
    static var identifier: String {
        return "CameraActionSheet"
    }
    
    static var nibName: String {
        return "CameraActionSheet"
    }
}

