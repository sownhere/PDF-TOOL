//
//  ToolbarStateManager.swift
//  FileManager
//
//  Created by Macbook on 01/07/2024.
//

import Foundation


class ToolbarStateManager {
    static let shared = ToolbarStateManager()
    private init() {}  // Private initialization to ensure singleton instance

    var selectedItems: [URL] = []
    var cutItems: [URL] = []
    var copyItems: [URL] = []

    func cutSelectedItems() {
        cutItems.append(contentsOf: selectedItems)
        selectedItems.removeAll()
    }
    
    func pasteCutItems(to currentFolderURL: URL, completion: @escaping () -> Void) {
        for item in cutItems {
            let newPath = currentFolderURL.appendingPathComponent(item.lastPathComponent)
            FileAndFolderManager.shared.moveItem(from: item, to: newPath)
        }
        cutItems.removeAll()
        completion()
    }
    
    func pasteCopyItems(to currentFolderURL: URL, completion: @escaping () -> Void) {
        for item in copyItems {
            let newPath = currentFolderURL.appendingPathComponent(item.lastPathComponent)
            FileAndFolderManager.shared.copyItem(from: item, to: newPath)
        }
        copyItems.removeAll()
        completion()
    }
    
    func copySelectedItems(to currentFolderURL: URL, completion: @escaping () -> Void) {
        copyItems.append(contentsOf: selectedItems)
        
        selectedItems.removeAll()
        completion()
    }
    
    func deleteSelectedItems(completion: @escaping () -> Void) {
        for item in selectedItems {
            FileAndFolderManager.shared.deleteItem(at: item)
        }
        selectedItems.removeAll()
        completion()
    }
    
    func renameItem(at url: URL, to newName: String, completion: @escaping () -> Void) {
        FileAndFolderManager.shared.renameItem(at: url, newName: newName)
        completion()
    }
}
