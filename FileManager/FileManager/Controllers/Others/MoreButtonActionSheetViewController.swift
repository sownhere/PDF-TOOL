//
//  MoreButtonActionSheetViewController.swift
//  FileManager
//
//  Created by Macbook on 30/06/2024.
//

import UIKit

class MoreButtonActionSheetViewController: UIViewController {
    var itemURL: URL?
    var viewModel: HomeViewModel?
    
    @IBOutlet weak var shareButton: UIButton!
    @IBOutlet weak var deleteButton: UIButton!
    @IBOutlet weak var renameButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupButtonActions()
    }
    
    private func setupButtonActions() {
        shareButton.addTarget(self, action: #selector(shareItem), for: .touchUpInside)
        deleteButton.addTarget(self, action: #selector(deleteItem), for: .touchUpInside)
        renameButton.addTarget(self, action: #selector(renameItem), for: .touchUpInside)
    }
    
    @objc private func deleteItem() {
        guard let url = itemURL else { return }
        viewModel?.deleteItem(at: url)
        viewModel?.reloadCurrentFolder()
        dismiss(animated: true, completion: nil)
    }
    
    @objc private func renameItem() {
        guard let url = itemURL else { return }
        let alertController = UIAlertController(title: "Rename", message: "Enter a new name", preferredStyle: .alert)
        alertController.addTextField { textField in
            textField.text = url.lastPathComponent
        }
        
        let renameAction = UIAlertAction(title: "OK", style: .default) { [unowned alertController] _ in
            if let newName = alertController.textFields?.first?.text, !newName.isEmpty {
                self.viewModel?.renameItem(at: url, to: newName)
                self.dismiss(animated: true, completion: nil)
            }
        }
        alertController.addAction(renameAction)
        alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        present(alertController, animated: true, completion: nil)
    }
    
    @objc private func shareItem() {
        guard let url = itemURL else { return }
        let activityViewController = UIActivityViewController(activityItems: [url], applicationActivities: nil)
        activityViewController.popoverPresentationController?.sourceView = self.view // For iPad support
        self.present(activityViewController, animated: true, completion: nil)

    }
}



extension MoreButtonActionSheetViewController {
    
    static var identifier: String {
        return "MoreButtonActionSheet"
    }
    
    static var nibName: String {
        return "MoreButtonActionSheet"
    }
}
