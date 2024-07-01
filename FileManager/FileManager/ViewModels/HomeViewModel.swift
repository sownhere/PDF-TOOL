//
//  HomeViewModel.swift
//  FileManager
//
//  Created by Macbook on 19/06/2024.
//

import Foundation
import UIKit


class HomeViewModel {
    
    
    var filterFolders: [FolderModel] = []
    var filterFiles: [FileModel] = []
    var isSearching = false
    
    func filterContentForSearchText(_ searchText: String) {
        if searchText.isEmpty {
            isSearching = false
        } else {
            isSearching = true
            filterFolders = currentFolder?.subFolders.filter { $0.name!.lowercased().contains(searchText.lowercased()) } ?? []
            filterFiles = currentFolder?.files.filter { $0.name!.lowercased().contains(searchText.lowercased()) } ?? []
        }
        reloadUI?()
    }
    
    
    
    let fileAndFolderManager = FileAndFolderManager.shared
    
    var rootFolder: FolderModel?
    var currentFolder: FolderModel?
    
    enum FolderOrFile {
        case folder(FolderModel)
        case file(FileModel)
    }
    
    
    
    
    var reloadUI: (() -> Void)?
    
    init() {
        if let rootDirectory = fileAndFolderManager.getDirectory() {
            rootFolder = FolderModel(url: rootDirectory)
            currentFolder = rootFolder
        }
    }
    
    
    
    
    var numberOfSections: Int {
        
        if isSearching {
            let hasSubFolders = !filterFolders.isEmpty
            let hasFiles = !filterFiles.isEmpty
            if hasSubFolders && hasFiles {
                return 2
            } else if hasSubFolders || hasFiles {
                return 1
            } else {
                return 0
            }
        } else {
            guard let currentFolder = currentFolder else { return 0 }
            let hasSubFolders = !currentFolder.subFolders.isEmpty
            let hasFiles = !currentFolder.files.isEmpty
            if hasSubFolders && hasFiles {
                return 2
            } else if hasSubFolders || hasFiles {
                return 1
            } else {
                return 0
            }
        }
        
        
    }
    
    
    func numberOfItemsInSection(_ section: Int) -> Int {
        if isSearching {
            if section == 0 && !filterFolders.isEmpty {
                return filterFolders.count
            } else {
                return filterFiles.count
            }
        } else {
            guard let currentFolder = currentFolder else { return 0 }
            if section == 0 && !currentFolder.subFolders.isEmpty {
                return currentFolder.subFolders.count
            } else {
                return currentFolder.files.count
            }
        }
        
    }
    
    
    func itemForIndexPath(_ indexPath: IndexPath) -> FolderOrFile? {
        
        if isSearching {
            if indexPath.section == 0 {
                if filterFolders.count != 0 {
                    return .folder(filterFolders[indexPath.row])
                } else {
                    return .file(filterFiles[indexPath.row])
                }
                
            } else {
                return .file(filterFiles[indexPath.row])
            }
        } else {
            guard let currentFolder = currentFolder else { return nil }
            if indexPath.section == 0 {
                if currentFolder.subFolders.count != 0 {
                    return .folder(currentFolder.subFolders[indexPath.row])
                } else {
                    return .file(currentFolder.files[indexPath.row])
                }
                
            } else {
                return .file(currentFolder.files[indexPath.row])
            }
        }
    }
    
    
    
    // MARK: - Define new HomeViewModel
    
    func cutSelectedItems() {
        ToolbarStateManager.shared.cutSelectedItems()
        reloadUI?()
    }
    
    func pasteCutItems() {
        guard let currentFolderURL = currentFolder?.url else { return }
        ToolbarStateManager.shared.pasteCutItems(to: currentFolderURL) {
            self.reloadCurrentFolder()
            self.reloadUI?()
        }
    }
    
    func pasteCopyItems() {
        guard let currentFolderURL = currentFolder?.url else { return }
        ToolbarStateManager.shared.pasteCopyItems(to: currentFolderURL) {
            self.reloadCurrentFolder()
            self.reloadUI?()
        }
    }
    
    func copySelectedItems() {
        guard let currentFolderURL = currentFolder?.url else { return }
        ToolbarStateManager.shared.copySelectedItems(to: currentFolderURL) {
            self.reloadCurrentFolder()
            self.reloadUI?()
        }
    }
    
    func deleteSelectedItems() {
        ToolbarStateManager.shared.deleteSelectedItems {
            self.reloadCurrentFolder()
            self.reloadUI?()
        }
    }
    
    func renameItem(at url: URL, to newName: String) {
        ToolbarStateManager.shared.renameItem(at: url, to: newName) {
            self.reloadCurrentFolder()
            self.reloadUI?()
        }
    }
    
    func createFolder(named name: String) {
        guard let currentFolder = currentFolder else { return }
        fileAndFolderManager.createFolder(named: name, in: currentFolder.url!)
        reloadCurrentFolder()
        reloadUI?()
    }
    
    func createFile(named name: String, content: Data) {
        guard let currentFolder = currentFolder else {
            return
        }
        
        fileAndFolderManager.createFile(named: name, in: currentFolder.url!, with: content)
    }
    
    func deleteItem(at url: URL) {
        fileAndFolderManager.deleteItem(at: url)
        reloadCurrentFolder()
        reloadUI?()
    }
    
    func moveItem(from: URL, to: URL) {
        fileAndFolderManager.moveItem(from: from, to: to)
        reloadCurrentFolder()
        reloadUI?()
    }
    
    func copyItem(from: URL, to: URL) {
        fileAndFolderManager.copyItem(from: from, to: to)
        reloadCurrentFolder()
        reloadUI?()
    }
    
    func navigateToFolder(_ folder: FolderModel) {
        currentFolder = folder
        reloadUI?()
    }
    
    func navigateBack() {
        if currentFolder?.url != rootFolder?.url {
            currentFolder = rootFolder
            reloadUI?()
        }
    }
    
    func reloadCurrentFolder() {
        if let currentFolderURL = currentFolder?.url {
            currentFolder = FolderModel(url: currentFolderURL)
            sortItems()
            reloadUI?()
        }
    }
    
    
    func sortItems() {
        switch UserDefaultsManager.shared.sortPreference {
        case .name:
            currentFolder?.subFolders.sort { $0.name! < $1.name! }
            currentFolder?.files.sort { $0.name! < $1.name! }
        case .size:
            if isSearching {
                filterFolders.sort {
                    ($0.files.count + $0.subFolders.count) > ($1.files.count + $1.subFolders.count)
                }
                filterFiles.sort {
                    $0.size! < $1.size!
                }
            } else {
                currentFolder?.subFolders.sort {
                    ($0.files.count + $0.subFolders.count) > ($1.files.count + $1.subFolders.count)
                }
                currentFolder?.files.sort {
                    $0.size! < $1.size!
                }
            }
        case .date:
            currentFolder?.files.sort {
                $0.creationDate! > $1.creationDate!
            }
        }
    }
    
}


