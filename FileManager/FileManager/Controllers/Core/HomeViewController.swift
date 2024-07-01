//
//  HomeViewController.swift
//  FileManager
//
//  Created by Macbook on 18/06/2024.
//

import UIKit

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
        cameraActionSheet.viewModel = self.viewModel
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
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.viewModel.reloadCurrentFolder()
        print(self.viewModel.rootFolder?.name! ?? "Khong in ra được tên root folder")
        print(self.viewModel.currentFolder?.name! ?? "Khong in ra ten cua thu muc hien tai duoc")
    }
    
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
        self.updateBackgroundImageViewVisibility()
        
        //        let searchController = UISearchController(searchResultsController: nil)
        //        navigationItem.searchController = searchController
        //        navigationItem.searchController?.searchBar.delegate = self
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
        newViewModel.navigateToFolder(folder)
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

