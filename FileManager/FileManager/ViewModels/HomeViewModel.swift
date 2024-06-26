//
//  HomeViewModel.swift
//  FileManager
//
//  Created by Macbook on 19/06/2024.
//

import Foundation
import UIKit


class HomeViewModel {
//    private var folders: [Folder] = []
//    private var files: [File] = []
    var parentFolder: URL? = nil
    
    private var files: [URL] = []
    private var folders: [URL] = []
    
    let manager = FileAndFolderManager()
    

    
    
//    enum FolderOrFile {
//        case folder(Folder)
//        case file(File)
//    }

    
    
    var reloadUI: (() -> Void)?

    var numberOfSections: Int {
        return (folders.isEmpty && files.isEmpty) ? 0 : ((folders.isEmpty || files.isEmpty) ? 1 : 2)
    }

    func numberOfItemsInSection(_ section: Int) -> Int {
        if section == 0 && !folders.isEmpty {
            return folders.count
        } else {
            return files.count
        }
    }

    func itemForIndexPath(_ indexPath: IndexPath) -> URL {
        return indexPath.section == 0 ? folders[indexPath.row] : files[indexPath.row]
    }


    func fetchItems() {
        let directory = parentFolder ?? manager.getDirectory()!
        folders.removeAll()
        files.removeAll()

        if let fetchedItems = manager.listContentsOfDirectory(directory: directory) {
            for item in fetchedItems {
                var isDirectory: ObjCBool = false
                if FileManager.default.fileExists(atPath: item.path, isDirectory: &isDirectory) {
                    if isDirectory.boolValue {
                        folders.append(item)
                    } else {
                        files.append(item)
                    }
                }
            }
            print("Folders:", folders.map { $0.lastPathComponent })
            print("Files:", files.map { $0.lastPathComponent })
            reloadUI?()
        }
    }

    // Save new folder or file to the set directory or default to ScannerPDF if parentFolder is nil
    func saveNewItem(isFolder: Bool, name: String, image: UIImage?) {
        let directory = parentFolder ?? manager.getDirectory()!
        let newPath = directory.appendingPathComponent(name)
        if isFolder {
            try? FileManager.default.createDirectory(at: newPath, withIntermediateDirectories: true, attributes: nil)
            print("Directory \(name) created.")
        } else {
            FileManager.default.createFile(atPath: newPath.path, contents: image?.pngData(), attributes: nil)
            print("File \(name) created.")
        }
        fetchItems()  // Refresh the items list
    }

    // Delete an item from the set directory or default to ScannerPDF if parentFolder is nil
    func deleteItem(at indexPath: IndexPath) {
        let itemURL = indexPath.section == 0 ? folders[indexPath.row] : files[indexPath.row]
        try? FileManager.default.removeItem(at: itemURL)
        print("Item at \(itemURL) deleted.")
        if indexPath.section == 0 {
            folders.remove(at: indexPath.row)
        } else {
            files.remove(at: indexPath.row)
        }
        reloadUI?()
    }
}
    

