//
//  HomeViewController.swift
//  FileManager
//
//  Created by Macbook on 18/06/2024.
//

import UIKit
import UniformTypeIdentifiers

import PhotosUI

class HomeViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, HeaderCollectionViewDelegate {
    
    
    // MARK: - Setup Custom toolbar
    
    var customToolbar: CustomToolbar!
    
    private func setupCustomToolbar() {
        let tabBarHeight = self.tabBarController?.tabBar.frame.size.height ?? 49
        customToolbar = CustomToolbar(frame: CGRect(x: 0, y: view.frame.size.height - tabBarHeight, width: view.frame.size.width, height: tabBarHeight))
        customToolbar.backgroundColor = .darkGray
        customToolbar.buttonAction = { [weak self] buttonIndex in
            switch buttonIndex {
            case 0:
                self?.cutOrPasteAction()
            case 1:
                self?.copyAction()
            case 2:
                self?.renameAction()
            case 3:
                self?.deleteAction()
            default:
                break
            }
        }
        self.view.addSubview(customToolbar)
        customToolbar.isHidden = true
    }
    
    
    
    private func updateToolbarButtons() {
        customToolbar.refreshToolbarState()
    }
    
    private func exitEditingMode() {
        isEditingMode = false
        ToolbarStateManager.shared.selectedItems.removeAll()
        updateToolbarButtons()
        collectionView.reloadData()
    }
    
    
    
    // MARK: - Header Delegate
    func didTapViewToggleButton() {
        isGrid.toggle()
        collectionView.reloadData()
    }
    
    
    func didTapFolderButton() {
        setupNewFolderAlert()
    }
    
    func didTapSortLabel() {
        // Sorting functionality can be implemented here
        showSortOptions()
    }
    
    
    
    func showSortOptions() {
        let actionSheet = UIAlertController(title: nil, message: "Sort By", preferredStyle: .actionSheet)
        
        let sortByName = UIAlertAction(title: "Name", style: .default) { [weak self] action in
            self?.updateSortPreference(.name)
        }
        let sortBySize = UIAlertAction(title: "Size", style: .default) { [weak self] action in
            self?.updateSortPreference(.size)
        }
        let sortByDate = UIAlertAction(title: "Date", style: .default) { [weak self] action in
            self?.updateSortPreference(.date)
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
        
        if !viewModel.isSearching {
            actionSheet.addAction(sortByName)
        }
        actionSheet.addAction(sortBySize)
        if !viewModel.isSearching {
            actionSheet.addAction(sortByDate)
        }
        actionSheet.addAction(cancelAction)
        
        present(actionSheet, animated: true)
    }
    
    
    
    private func updateSortPreference(_ newPreference: UserDefaultsManager.SortOrder) {
        UserDefaultsManager.shared.sortPreference = newPreference
        viewModel.sortItems()
        collectionView.reloadData()
    }
    
    
    
    func showCameraActionSheet() {
        let cameraActionSheet = CameraActionSheet(nibName: "CameraActionSheet", bundle: nil)
        
        cameraActionSheet.delegate = self
        
        
        
        let nav = UINavigationController(rootViewController: cameraActionSheet)
        
        nav.modalPresentationStyle = .pageSheet
        
        if let sheet = nav.sheetPresentationController {
            sheet.detents = [.medium(), .large()]
        }
        present(nav, animated: true, completion: nil)
    }
    
    @objc func cameraButtonTapped() {
        showCameraActionSheet()
    }
    
    var isEditingMode: Bool = false {
        didSet {
            
            ToolbarStateManager.shared.selectedItems.removeAll()
            updateUIForEditingMode()
            
            
        }
    }
    
    var isGrid: Bool {
        get {
            return UserDefaultsManager.shared.isGrid
        }
        set {
            UserDefaultsManager.shared.isGrid = newValue
            createCollectionViewLayout()
            collectionView.reloadData()
        }
    }
    
    var viewModel = HomeViewModel()
    var backgroundImageView: UIImageView!
    
    @IBOutlet weak var cameraBtn: UIButton!
    @IBOutlet var collectionView: UICollectionView!
    @IBOutlet var searchBarView: UISearchBar!
    
    
    // MARK: - ViewWillAppear
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setupCollectionView()
        self.viewModel.reloadCurrentFolder()
        print(self.viewModel.rootFolder?.name! ?? "Khong in ra được tên root folder")
        print(self.viewModel.currentFolder?.name! ?? "Khong in ra ten cua thu muc hien tai duoc")
    }
    
    
    //MARK: - ViewWillDidLoad
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = viewModel.currentFolder?.url?.lastPathComponent ?? "My Files"
        
        setupCollectionView()
        
        cameraBtn.addTarget(self, action: #selector(cameraButtonTapped), for: .touchUpInside)
        viewModel.reloadCurrentFolder()
        viewModel.reloadUI = { [weak self] in
            self?.collectionView.reloadData()
            self?.updateBackgroundImageViewVisibility()
        }
        updateBackgroundImageViewVisibility()
        setupSearchController()
        setupEditingBarButton()
        setupCustomToolbar()
        
    }
    
    
    func setupEditingBarButton() {
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Edit", style: .plain, target: self, action: #selector(toggleEditingMode))
    }
    
    @objc func toggleEditingMode() {
        isEditingMode = !isEditingMode
        print("Chế độ chỉnh sửa được chuyển sang: \(isEditingMode)")
        collectionView.reloadData()
        collectionView.layoutIfNeeded()
    }
    
    
    
    func updateUIForEditingMode() {
        navigationItem.rightBarButtonItem?.title = isEditingMode ? "Done" : "Edit"
        collectionView.reloadData()  // Reload to update cell configuration based on editing mode
        customToolbar.refreshToolbarState()
        customToolbar.isHidden = !isEditingMode
        self.tabBarController?.tabBar.isHidden = isEditingMode
    }
    
    
    
    
    // MARK: - CollectionView Delegate
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        
        return viewModel.numberOfSections
        
    }
    
    
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        return viewModel.numberOfItemsInSection(section)

    }
    
    
    
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if isGrid {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: GridCell.reuseIdentifier, for: indexPath) as! GridCell
            if let item = viewModel.itemForIndexPath(indexPath) {
                cell.configure(with: item, isEditingMode: isEditingMode)
            }
            cell.delegate = self
            return cell
        } else {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: OneCellCollectionViewCell.reuseIdentifier, for: indexPath) as! OneCellCollectionViewCell
            if let item = viewModel.itemForIndexPath(indexPath) {
                cell.configure(with: item, isEditingMode: isEditingMode)
            }
            cell.delegate = self
            return cell
        }
    }
    
    
    
    
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        guard kind == UICollectionView.elementKindSectionHeader else {
            return UICollectionReusableView()
        }
        
        let headerView = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: HeaderCollectionView.reuseIdentifier, for: indexPath) as! HeaderCollectionView
        headerView.delegate = self
        
        // Update sort label with current sort preference
        let currentSortPreference = UserDefaultsManager.shared.sortPreference
        headerView.sortLabel.text = "↑ \(currentSortPreference.description)"
        
        configureHeaderView(headerView, at: indexPath)
        
        return headerView
    }
    
    
    
    
    
    private func configureHeaderView(_ headerView: HeaderCollectionView, at indexPath: IndexPath) {
        // Determine if it's a folder-only or file-only section when there's exactly one section
        if viewModel.numberOfSections == 1 {
            let hasFolders = !(viewModel.currentFolder?.subFolders.isEmpty)!
            let hasFiles = !(viewModel.currentFolder?.files.isEmpty)!
            
            if hasFolders && !hasFiles {
                headerView.typeLabel.text = "Folders"
                headerView.folderBtn.isHidden = viewModel.isSearching
                headerView.viewToggleBtn.isHidden = viewModel.isSearching
                headerView.sortLabel.isHidden = false
            } else if hasFiles && !hasFolders {
                headerView.typeLabel.text = "Files"
                headerView.folderBtn.isHidden = viewModel.isSearching
                headerView.viewToggleBtn.isHidden = viewModel.isSearching
                headerView.sortLabel.isHidden = false
            }
        } else if viewModel.numberOfSections == 2 {
            if indexPath.section == 0 {
                // First section is always folders if there are two sections
                headerView.typeLabel.text = "Folders"
                headerView.folderBtn.isHidden = viewModel.isSearching
                headerView.viewToggleBtn.isHidden = viewModel.isSearching
                headerView.sortLabel.isHidden = false
            } else {
                // Second section is always files
                headerView.typeLabel.text = "Files"
                headerView.folderBtn.isHidden = true
                headerView.viewToggleBtn.isHidden = true
                headerView.sortLabel.isHidden = false
            }
        }
    }
    
    
    
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if isEditingMode {
            if let cell = collectionView.cellForItem(at: indexPath) as? OneCellCollectionViewCell {
                cell.moreBtn.isSelected = !cell.moreBtn.isSelected
                
                guard let item = viewModel.itemForIndexPath(indexPath) else { return }
                switch item {
                case .file(let file):
                    if cell.moreBtn.isSelected {
                        ToolbarStateManager.shared.selectedItems.append(file.url!)
                    } else {
                        ToolbarStateManager.shared.selectedItems.removeAll { URL in
                            URL == file.url
                        }
                    }
                  
                    customToolbar.refreshToolbarState()
                case .folder(let folder):
                    if cell.moreBtn.isSelected {
                        ToolbarStateManager.shared.selectedItems.append(folder.url!)
                    } else {
                        ToolbarStateManager.shared.selectedItems.removeAll { URL in
                            URL == folder.url
                        }
                    }
                    
                    customToolbar.refreshToolbarState()
                }
            } else {
                if let cell = collectionView.cellForItem(at: indexPath) as? GridCell {
                    cell.moreBtn.isSelected = !cell.moreBtn.isSelected
                    guard let item = viewModel.itemForIndexPath(indexPath) else { return }
                    switch item {
                    case .file(let file):
                        if cell.moreBtn.isSelected {
                            ToolbarStateManager.shared.selectedItems.append(file.url!)
                        } else {
                            ToolbarStateManager.shared.selectedItems.removeAll { URL in
                                URL == file.url
                            }
                        }
                      
                        customToolbar.refreshToolbarState()
                    case .folder(let folder):
                        if cell.moreBtn.isSelected {
                            ToolbarStateManager.shared.selectedItems.append(folder.url!)
                        } else {
                            ToolbarStateManager.shared.selectedItems.removeAll { URL in
                                URL == folder.url
                            }
                        }
                        customToolbar.refreshToolbarState()
                    }
                }
            }
        } else {
            guard let item = viewModel.itemForIndexPath(indexPath) else { return }
            
            switch item {
            case .folder(let folder):
                showNewHomeView(with: folder)
            case .file(_):
                // Handle file selection, if needed
                break
            }
        }
    }
    
    // MARK: - Define any view set up
    
    private func showNewHomeView(with folder: FolderModel) {
        guard let homeViewController = UIStoryboard(name: "Main", bundle: .main).instantiateViewController(withIdentifier: HomeViewController.identifier) as? HomeViewController else {
            fatalError("Unable to Instantiate Home View Controller")
        }
        
        let newViewModel = HomeViewModel()
        newViewModel.navigateToFolder(folder,viewModel.currentFolder!)
        homeViewController.viewModel = newViewModel
        
        if let navigationController = self.navigationController {
            navigationController.pushViewController(homeViewController, animated: true)
        } else {
            print("NavigationController is nil")
        }
    }
    
    func createCollectionViewLayout() {
        
        collectionView.collectionViewLayout.invalidateLayout()
        
        let layout = UICollectionViewFlowLayout()
        layout.invalidateLayout()
        
        if isGrid {
            let width = (collectionView.frame.width - 60) * (1/3)
            layout.itemSize = CGSize(width: width, height: width * (7/6))
        } else {
            layout.itemSize = CGSize(width: collectionView.frame.width * 0.9, height: 80)
        }
        
        layout.headerReferenceSize = CGSize(width: collectionView.frame.width * 0.9, height: 50)
        layout.sectionInset = UIEdgeInsets(top: 10.0, left: 10, bottom: 10.0, right: 10)
        
        collectionView.collectionViewLayout = layout
    }
    
    
    func setupSearchController() {
        let searchController = UISearchController(searchResultsController: nil)
        searchController.searchBar.delegate = self
        
        navigationItem.searchController = searchController
        navigationItem.hidesSearchBarWhenScrolling = false
        definesPresentationContext = true
        
        // Make the search bar active
        searchController.isActive = true
        searchController.searchBar.becomeFirstResponder() // This will make the keyboard appear when the search bar is tapped.
    }
    
    
    func setupCollectionView() {
        createCollectionViewLayout()
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.register(UINib(nibName: OneCellCollectionViewCell.nibName, bundle: nil), forCellWithReuseIdentifier: OneCellCollectionViewCell.reuseIdentifier)
        collectionView.register(UINib(nibName: GridCell.nibName, bundle: nil), forCellWithReuseIdentifier: GridCell.reuseIdentifier)
        collectionView.isPagingEnabled = true
        collectionView.alwaysBounceVertical = true
        setupBackgroundImageView()
        collectionView.backgroundView = backgroundImageView
    }
    
    func setupBackgroundImageView() {
        backgroundImageView = UIImageView(image: UIImage(named: "backgroundCollectionView"))
        backgroundImageView.contentMode = .scaleAspectFill
        backgroundImageView.frame = self.view.bounds
        backgroundImageView.isUserInteractionEnabled = true
        
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(backgroundImageTapped))
        backgroundImageView.addGestureRecognizer(tapGestureRecognizer)
        backgroundImageView.isHidden = true
    }
    
    @objc func backgroundImageTapped() {
        print("Background image tapped")
        setupNewFolderAlert()
    }
    
    func setupNewFolderAlert() {
        let alertController = UIAlertController(title: "New Folder", message: "Enter a name for this folder.", preferredStyle: .alert)
        alertController.addTextField { textField in
            textField.placeholder = "Folder Name"
        }
        
        let saveAction = UIAlertAction(title: "Save", style: .default) { [weak self] _ in
            guard let textField = alertController.textFields?.first, let folderName = textField.text, !folderName.isEmpty else { return }
            self?.viewModel.createFolder(named: folderName)
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
        alertController.addAction(saveAction)
        alertController.addAction(cancelAction)
        
        present(alertController, animated: true, completion: nil)
    }
    
    private func updateBackgroundImageViewVisibility() {
        guard let currentFolder = viewModel.currentFolder else {
            backgroundImageView.isHidden = false
            return
        }
        
        let hasItems = !(currentFolder.subFolders.isEmpty && currentFolder.files.isEmpty)
        if hasItems {
            backgroundImageView.isHidden = hasItems
        } else {
            backgroundImageView.isHidden = false
        }
    }
    
    func showMoreButtonActionSheet(viewModel: HomeViewModel, url: URL) {
        let moreButtonActionSheet = MoreButtonActionSheetViewController(nibName: MoreButtonActionSheetViewController.nibName, bundle: nil)
        moreButtonActionSheet.itemURL = url
        moreButtonActionSheet.viewModel = self.viewModel
        let nav = UINavigationController(rootViewController: moreButtonActionSheet)
        
        nav.modalPresentationStyle = .pageSheet
        
        if let sheet = nav.sheetPresentationController {
            sheet.detents = [.medium(), .large()]
        }
        present(nav, animated: true, completion: nil)
    }
}

extension HomeViewController {
    static var identifier: String {
        return "HomeViewController"
    }
}

extension HomeViewController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        viewModel.filterContentForSearchText(searchText)
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.text = ""
        searchBar.resignFirstResponder()
        viewModel.isSearching = false
        viewModel.reloadUI?()
    }
}

extension HomeViewController: GridCellDelegate, OneCellDelegate {
    
    func didTapMoreButton(in cell: GridCell, isEditing: Bool) {
        if !isEditing {
            guard let indexPath = collectionView.indexPath(for: cell),
                  let item = viewModel.itemForIndexPath(indexPath) else {
                print("Failed to get item for index path")
                return
            }
            
            switch item {
            case .file(let file):
                let url = file.url
                if let url = url {
                    showMoreButtonActionSheet(viewModel: viewModel, url: url)
                }
            case .folder(let folder):
                let url = folder.url
                if let url = url {
                    showMoreButtonActionSheet(viewModel: viewModel, url: url)
                }
            }
        } else {
            customToolbar.refreshToolbarState()
        }
        
    }
    
    func didTapMoreButton(in cell: OneCellCollectionViewCell, isEditing: Bool) {
        if !isEditing {
            guard let indexPath = collectionView.indexPath(for: cell),
                  let item = viewModel.itemForIndexPath(indexPath) else {
                print("Failed to get item for index path")
                return
            }
            
            switch item {
            case .file(let file):
                let url = file.url
                if let url = url {
                    showMoreButtonActionSheet(viewModel: viewModel, url: url)
                }
            case .folder(let folder):
                let url = folder.url
                if let url = url {
                    showMoreButtonActionSheet(viewModel: viewModel, url: url)
                }
            }
        } else {
            customToolbar.refreshToolbarState()
        }
    }
}


// MARK: - set up feature edit toolbar action
extension HomeViewController {
    private func cutOrPasteAction() {
        if ToolbarStateManager.shared.cutItems.isEmpty {
            viewModel.cutSelectedItems()
        } else {
            viewModel.pasteCutItems()
        }
        exitEditingMode()
    }
    
    private func copyAction() {
        if ToolbarStateManager.shared.copyItems.isEmpty {
            viewModel.copySelectedItems()
        } else {
            viewModel.pasteCopyItems()
        }
        
        exitEditingMode()
    }
    
    private func renameAction() {
        guard ToolbarStateManager.shared.selectedItems.count == 1, let itemToRename = ToolbarStateManager.shared.selectedItems.first else { return }
        
        let alertController = UIAlertController(title: "Rename", message: "Enter a new name", preferredStyle: .alert)
        alertController.addTextField { textField in
            textField.text = itemToRename.lastPathComponent
        }
        
        let renameAction = UIAlertAction(title: "Rename", style: .default) { [weak self] _ in
            guard let newName = alertController.textFields?.first?.text, !newName.isEmpty else { return }
            self?.viewModel.renameItem(at: itemToRename, to: newName)
            self?.exitEditingMode()
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
        alertController.addAction(renameAction)
        alertController.addAction(cancelAction)
        
        present(alertController, animated: true, completion: nil)
    }
    
    private func deleteAction() {
        let alertController = UIAlertController(title: "Delete Items", message: "Are you sure you want to delete the selected items?", preferredStyle: .alert)
        
        let deleteAction = UIAlertAction(title: "Delete", style: .destructive) { [weak self] _ in
            self?.viewModel.deleteSelectedItems()
            self?.exitEditingMode()
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
        alertController.addAction(deleteAction)
        alertController.addAction(cancelAction)
        
        present(alertController, animated: true, completion: nil)
    }
}

extension HomeViewController: CameraActionSheetDelegate, UIDocumentPickerDelegate {
    func didTapedImportFile() {
        dismiss(animated: true)
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
                    viewModel.createFile(named: fileName, content: fileContent)
                    viewModel.reloadCurrentFolder()
                    print("Đã chọn file: \(fileName)")
                    
               
            } catch {
                print("Error reading file content: \(error)")
            }
    }
    
    func documentPickerWasCancelled(_ controller: UIDocumentPickerViewController) {
        print("Người dùng đã hủy chọn file")
        
    }
    
    func didTapedPhoto() {
        dismiss(animated: true)
//        let imagePicker = UIImagePickerController()
//        imagePicker.delegate = self
//        imagePicker.sourceType = .photoLibrary
//        present(imagePicker, animated: true)
        presentPhotoPicker()
    }
    
    func didTapedCamera() {
        
        dismiss(animated: true)
        let scannerViewController = ImageScannerController()
        scannerViewController.modalPresentationStyle = .fullScreen
        if #available(iOS 13.0, *) {
            scannerViewController.navigationBar.tintColor = .label
        } else {
            scannerViewController.navigationBar.tintColor = .black
        }
        scannerViewController.imageScannerDelegate = self
//        scannerViewController.navigationBar.barTintColor = .black
        present(scannerViewController, animated: true)
    }
    
    
    
}

extension HomeViewController: ImageScannerControllerDelegate {
    func imageScannerController(_ scanner: ImageScannerController, didFailWithError error: Error) {
        // You are responsible for carefully handling the error
        print(error)
    }

    func imageScannerController(_ scanner: ImageScannerController, didFinishScanningWithResults results: ImageScannerResults) {
        // The user successfully scanned an image, which is available in the ImageScannerResults
        // You are responsible for dismissing the ImageScannerController
        scanner.dismiss(animated: true)
    }

    func imageScannerControllerDidCancel(_ scanner: ImageScannerController) {
        // The user tapped 'Cancel' on the scanner
        // You are responsible for dismissing the ImageScannerController
        scanner.dismiss(animated: true)
    }
    
}

extension HomeViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true)
    }

    func imagePickerController(_ picker: UIImagePickerController,
                               didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
        picker.dismiss(animated: true)

        guard let image = info[.originalImage] as? UIImage else { return }
        let scannerViewController = ImageScannerController(image: image, delegate: self)
        present(scannerViewController, animated: true)
    }
}

extension HomeViewController: PHPickerViewControllerDelegate {
    func presentPhotoPicker() {
        var configuration = PHPickerConfiguration(photoLibrary: .shared())
        configuration.selectionLimit = 0 // 0 means no limit
        configuration.filter = .images // Only images

        let picker = PHPickerViewController(configuration: configuration)
        picker.delegate = self
        present(picker, animated: true, completion: nil)
    }

    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        picker.dismiss(animated: true, completion: nil)

        let dispatchGroup = DispatchGroup()
        var selectedImages: [UIImage] = []
        var quads: [Quadrilateral] = []

        for result in results {
            dispatchGroup.enter()
            result.itemProvider.loadObject(ofClass: UIImage.self) { [weak self] (object, error) in
                if let image = object as? UIImage {
                    selectedImages.append(image)
                    self!.detect(image: image) {
                        detectedQuad in
                        guard let detectedQuad else {
                            return
                        }
                        quads.append(detectedQuad)
                    }
                }
                dispatchGroup.leave()
            }
        }

        dispatchGroup.notify(queue: .main) {
            // Handle the selected images here
            
            let scannerViewController = EditImageScannerViewController(images: selectedImages, quads: quads, image: selectedImages.first!, quad: quads.first)
                self.present(scannerViewController, animated: true)
            
        }
    }
}

extension HomeViewController {
    private func detect(image: UIImage, completion: @escaping (Quadrilateral?) -> Void) {
        // Whether or not we detect a quad, present the edit view controller after attempting to detect a quad.
        // *** Vision *requires* a completion block to detect rectangles, but it's instant.
        // *** When using Vision, we'll present the normal edit view controller first, then present the updated edit view controller later.

        guard let ciImage = CIImage(image: image) else { return }
        let orientation = CGImagePropertyOrientation(image.imageOrientation)
        let orientedImage = ciImage.oriented(forExifOrientation: Int32(orientation.rawValue))

        if #available(iOS 11.0, *) {
            // Use the VisionRectangleDetector on iOS 11 to attempt to find a rectangle from the initial image.
            VisionRectangleDetector.rectangle(forImage: ciImage, orientation: orientation) { quad in
                let detectedQuad = quad?.toCartesian(withHeight: orientedImage.extent.height)
                completion(detectedQuad)
            }
        } else {
            // Use the CIRectangleDetector on iOS 10 to attempt to find a rectangle from the initial image.
            let detectedQuad = CIRectangleDetector.rectangle(forImage: ciImage)?.toCartesian(withHeight: orientedImage.extent.height)
            completion(detectedQuad)
        }
    }
}
