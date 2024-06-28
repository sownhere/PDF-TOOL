//
//  FolderModel.swift
//  FileManager
//
//  Created by Macbook on 27/06/2024.
//

import Foundation


struct FolderModel {
    
    var url: URL?
    var name: String?
    var creationDate: Date?
    var modificationDate: Date?
    var subFolders: [FolderModel]
    var files: [FileModel]
    
    init(url: URL) {
        
        self.url = url
        subFolders = []
        files = []
        
        do {
            let resourceValues = try url.resourceValues(forKeys: [.nameKey, .creationDateKey, .contentModificationDateKey, .isDirectoryKey])
            
            self.name = resourceValues.name
            self.creationDate = resourceValues.creationDate
            self.modificationDate = resourceValues.contentModificationDate
            
            if let directoryContents = FileAndFolderManager.shared.listContentsOfDirectory(directory: url) {
                
                for item in directoryContents {
                    let itemResourceValues = try item.resourceValues(forKeys: [.isDirectoryKey])
                    if itemResourceValues.isDirectory == true {
                        subFolders.append(FolderModel(url: item))
                    } else {
                        files.append(FileModel(url: item))
                    }
                }
            }
        } catch {
            print("Error initializing FolderModel: \(error)")
        }
    }
    
    
}
