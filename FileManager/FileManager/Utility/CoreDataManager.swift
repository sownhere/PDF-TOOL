import Foundation
import UIKit
import CoreData

class CoreDataManager {
    static let shared = CoreDataManager()
    
    private init() {}

    // MARK: - Core Data stack
    lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "FileManager")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()
    
    var context: NSManagedObjectContext {
        return persistentContainer.viewContext
    }

    // MARK: - Core Data Operations

    /// Fetches folders and files based on their parent folder.
    func fetchItems(parentFolder: Folder?) throws -> ([Folder], [File]) {
        var fetchedFolders: [Folder] = []
        var fetchedFiles: [File] = []

        // Fetch folders
        let folderRequest: NSFetchRequest<Folder> = Folder.fetchRequest()
        if let parent = parentFolder {
            folderRequest.predicate = NSPredicate(format: "parentFolder == %@", parent)
        } else {
            folderRequest.predicate = NSPredicate(format: "parentFolder == nil")
        }

        // Fetch files
        let fileRequest: NSFetchRequest<File> = File.fetchRequest()
        if let parent = parentFolder {
            fileRequest.predicate = NSPredicate(format: "folder == %@", parent)
        } else {
            fileRequest.predicate = NSPredicate(format: "folder == nil")
        }

        do {
            fetchedFolders = try context.fetch(folderRequest)
            fetchedFiles = try context.fetch(fileRequest)
        } catch let error as NSError {
            throw error
        }

        return (fetchedFolders, fetchedFiles)
    }

    /// Saves a new folder or file to the CoreData.
    func saveItem(isFolder: Bool, name: String, image: UIImage?, parentFolder: Folder?) throws {
        if isFolder {
            let newFolder = Folder(context: context)
            newFolder.id = UUID()
            newFolder.name = name
            newFolder.creationDate = Date()
            newFolder.modificationDate = Date()

            if let parent = parentFolder, parent.id != newFolder.id {
                newFolder.parentFolder = parent
            } else {
                newFolder.parentFolder = nil
            }

            context.insert(newFolder)
        } else {
            let newFile = File(context: context)
            newFile.idFile = UUID()
            newFile.nameFile = name
            if let image = image {
                newFile.image = image.jpegData(compressionQuality: 1.0)
            }
            newFile.creationDateFile = Date()
            newFile.modificationDateFile = Date()
            newFile.folder = parentFolder
            newFile.size = 0  // Default size, update accordingly.
            context.insert(newFile)
        }

        try context.save()
    }


    /// Updates the name or parent of a folder or file.
    func updateItem(item: NSManagedObject, newName: String, newParentFolder: Folder?) throws {
        if let folder = item as? Folder {
            folder.name = newName
            folder.parentFolder = newParentFolder
            folder.modificationDate = Date()
        } else if let file = item as? File {
            file.name = newName
            file.folder = newParentFolder
            file.modificationDate = Date()
        }

        try context.save()
    }

    /// Deletes a folder or file from the CoreData.
    func deleteItem(item: NSManagedObject) throws {
        context.delete(item)
        try context.save()
    }
}
