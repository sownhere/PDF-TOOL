//
//  BottomSheetController.swift
//  FileManager
//
//  Created by Macbook on 26/06/2024.
//

import UIKit
import MobileCoreServices
import UniformTypeIdentifiers

class CameraActionSheet: UIViewController, UIDocumentPickerDelegate  {
    
    
    @IBOutlet weak var exitBtn: UIView!
    @IBOutlet weak var importFilesBtn: UIView!
    @IBOutlet weak var photosBtn: UIView!
    @IBOutlet weak var cameraBtn: UIView!
    
    var viewModel: HomeViewModel?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        // Initialize tap gesture recognizer for exit button
        let exitTapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissActionSheet))
        exitBtn.isUserInteractionEnabled = true
        exitBtn.addGestureRecognizer(exitTapGesture)
        
        // Initialize tap gesture recognizer for import files button
        let importTapGesture = UITapGestureRecognizer(target: self, action: #selector(openDocumentPicker))
        importFilesBtn.isUserInteractionEnabled = true
        importFilesBtn.addGestureRecognizer(importTapGesture)
        
    }
    
    @objc func dismissActionSheet() {
        // Dismiss the current view controller
        dismiss(animated: true, completion: nil)
    }
    

    @objc func openDocumentPicker() {
        let documentTypes: [String] = [UTType.content.identifier, UTType.data.identifier, UTType.fileURL.identifier]
        let documentPicker = UIDocumentPickerViewController(forOpeningContentTypes: documentTypes.map { UTType($0)! }, asCopy: true)
        documentPicker.delegate = self
        documentPicker.modalPresentationStyle = .fullScreen
        present(documentPicker, animated: true, completion: nil)
    }
    
    func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
        guard let pickedFileURL = urls.first else {
                print("No file selected.")
                return
            }

            do {
                // Read the content of the selected file
                let fileContent = try Data(contentsOf: pickedFileURL)
                
                // Get the directory where you want to save the copy
                
                    // Extract the file name from the picked file URL
                    let fileName = pickedFileURL.lastPathComponent
                    
                    // Use the createFile method to create a copy of the file in the desired directory
                    viewModel?.createFile(named: fileName, content: fileContent)
                    viewModel!.reloadCurrentFolder()
                    print("Đã chọn file: \(fileName)")
                    dismissActionSheet()
               
            } catch {
                print("Error reading file content: \(error)")
            }
    }
    
    func documentPickerWasCancelled(_ controller: UIDocumentPickerViewController) {
        print("Người dùng đã hủy chọn file")
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

