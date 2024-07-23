//
//  BottomSheetController.swift
//  FileManager
//
//  Created by Macbook on 26/06/2024.
//

import UIKit
import MobileCoreServices
import UniformTypeIdentifiers



protocol CameraActionSheetDelegate: AnyObject {
    func didTapedImportFile()
    func didTapedPhoto()
    func didTapedCamera()
}
class CameraActionSheet: UIViewController, UIDocumentPickerDelegate  {
    
    weak var delegate: CameraActionSheetDelegate?
    
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
        
        // Initialize tap gesture recognizer for import files button
        let importTapGesture = UITapGestureRecognizer(target: self, action: #selector(didTapImportFile))
        importFilesBtn.isUserInteractionEnabled = true
        importFilesBtn.addGestureRecognizer(importTapGesture)
        
        let cameraTapGesture = UITapGestureRecognizer(target: self, action: #selector(didTapCamera))
        cameraBtn.isUserInteractionEnabled = true
        cameraBtn.addGestureRecognizer(cameraTapGesture)
        
        let photoTapGesture = UITapGestureRecognizer(target: self, action: #selector(didTapPhoto))
        photosBtn.isUserInteractionEnabled = true
        photosBtn.addGestureRecognizer(photoTapGesture)
        
    }
    
    @objc func dismissActionSheet() {
        // Dismiss the current view controller
        dismiss(animated: true, completion: nil)
    }
    

    @objc func didTapImportFile() {
        delegate?.didTapedImportFile()

    }
    
    @objc func didTapCamera() {
        delegate?.didTapedCamera()

        
    }
    
    @objc func didTapPhoto() {
        delegate?.didTapedPhoto()
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

