
//
//  FileManager.swift
//  FileManager
//
//  Created by Macbook on 24/06/2024.
//

import Foundation

class FileAndFolderManager {
    static let shared = FileAndFolderManager()
    private let fileManager = FileManager.default

    // Private initializer to enforce singleton usage
    private init() {}

    // Get the root directory of the application, create it if it does not exist
    func getDirectory() -> URL? {
        guard let documentsDirectory = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first else {
            print("Documents directory not found.")
            return nil
        }
        
        // Create directory if it does not exist
        if !fileManager.fileExists(atPath: documentsDirectory.path) {
            do {
                try fileManager.createDirectory(at: documentsDirectory, withIntermediateDirectories: true, attributes: nil)
                print("FileManager directory created.")
            } catch {
                print("Failed to create FileManager directory: \(error)")
                return nil
            }
        }
        return documentsDirectory
    }
    
    // List all items in a given directory
    func listContentsOfDirectory(directory: URL) -> [URL]? {
        do {
            let items = try fileManager.contentsOfDirectory(at: directory, includingPropertiesForKeys: nil)
            return items
        } catch {
            print("Failed to list contents of directory: \(error)")
            return nil
        }
    }

    // Create a folder in a specified directory
    func createFolder(named name: String, in directory: URL) {
        let folderPath = directory.appendingPathComponent(name)
        if !fileManager.fileExists(atPath: folderPath.path) {
            do {
                try fileManager.createDirectory(at: folderPath, withIntermediateDirectories: true, attributes: nil)
                print("Folder \(name) created.")
            } catch {
                print("Failed to create folder \(name): \(error)")
            }
        } else {
            print("Folder \(name) already exists.")
        }
    }

    // Delete an item at a specified URL
    func deleteItem(at url: URL) {
        if fileManager.fileExists(atPath: url.path) {
            do {
                try fileManager.removeItem(at: url)
                print("Item at \(url) deleted.")
            } catch {
                print("Failed to delete item: \(error)")
            }
        } else {
            print("Item does not exist.")
        }
    }

    // Rename or move an item
    func moveItem(from: URL, to: URL) {
        do {
            try fileManager.moveItem(at: from, to: to)
            print("Item moved from \(from) to \(to)")
        } catch {
            print("Failed to move item: \(error)")
        }
    }

    // Copy an item
    func copyItem(from: URL, to: URL) {
        do {
            try fileManager.copyItem(at: from, to: to)
            print("Item copied from \(from) to \(to)")
        } catch {
            print("Failed to copy item: \(error)")
        }
    }
}

// Example usage
// let manager = FileAndFolderManager.shared
