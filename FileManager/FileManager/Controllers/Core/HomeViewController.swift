//
//  HomeViewController.swift
//  FileManager
//
//  Created by Macbook on 18/06/2024.
//

import UIKit

class HomeViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, HeaderCollectionViewDelegate {
    
    // MARK: - Header Delegate
    func didTapViewToggleButton() {
        isGrid.toggle()
        createCollectionViewLayout()
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
        print(self.viewModel.currentFolder as Any)
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
                cell.configure(with: item)
            }
            
            return cell
        } else {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: OneCellCollectionViewCell.reuseIdentifier, for: indexPath) as! OneCellCollectionViewCell
            if let item = viewModel.itemForIndexPath(indexPath) {
                cell.configure(with: item)
            }
            
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
        guard let item = viewModel.itemForIndexPath(indexPath) else { return }
        
        switch item {
        case .folder(let folder):
            showNewHomeView(with: folder)
        case .file(_):
            // Handle file selection, if needed
            break
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
        let layout = UICollectionViewFlowLayout()
        
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

