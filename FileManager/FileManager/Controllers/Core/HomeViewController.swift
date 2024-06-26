    import UIKit

    class HomeViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, HeaderCollectionViewDelegate {
        
        // MARK: - Header Delegate
        func didTapViewToggleButton() {
            isGrid.toggle()
            updateCollectionViewLayout()
            collectionView.reloadData()
            
        }
        
        func updateCollectionViewLayout() {
            let layout = UICollectionViewFlowLayout()
            if isGrid {
                layout.itemSize = CGSize(width: 120, height: 140)
            } else {
                layout.itemSize = CGSize(width: collectionView.frame.width * 0.9, height: 80)
            }
            layout.headerReferenceSize = CGSize(width: collectionView.frame.width * 0.9, height: 50)
            layout.sectionInset = UIEdgeInsets(top: 10.0, left: 5, bottom: 10.0, right: 5)
            collectionView.collectionViewLayout = layout
            collectionView.layoutIfNeeded()
        }
        
        func didTapFolderButton() {

            setupNewFolderAlert()
        }
        
        func didTapSortLabel() {
            
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


        
        var isGrid : Bool = false
        

        var viewModel = HomeViewModel()
        
        var backgroundImageView: UIImageView!
        
        @IBOutlet weak var cameraBtn: UIButton!
        @IBOutlet var collectionView: UICollectionView!
        @IBOutlet var searchBarView: UISearchBar!

        override func viewWillAppear(_ animated: Bool) {
            self.collectionView.reloadData()
            print(self.viewModel.parentFolder as Any)
            
        }
        
        override func viewDidLoad() {
            super.viewDidLoad()
            self.title = viewModel.parentFolder?.lastPathComponent ?? "My Files"

            setupCollectionView()
            
            cameraBtn.addTarget(self, action: #selector(cameraButtonTapped), for: .touchUpInside)
            viewModel.reloadUI = { [weak self] in
                self?.collectionView.reloadData()
                print(self!.viewModel.numberOfSections != 0 )
                print(self!.viewModel.parentFolder as Any)
                self?.backgroundImageView.isHidden = self!.viewModel.numberOfSections != 0
            }
            viewModel.fetchItems()
            
            let searchController = UISearchController(searchResultsController: nil)
            navigationItem.searchController = searchController

        }
        
        
        // MARK: - CollectionView Delegate

        func numberOfSections(in collectionView: UICollectionView) -> Int {

            viewModel.numberOfSections
        }
        

        
        func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
            return viewModel.numberOfItemsInSection(section)
        }
        

        
        func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
            
            if isGrid {
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "GridCell", for: indexPath) as! GridCell
                let item = viewModel.itemForIndexPath(indexPath)
                cell.configure(with: item)
                
                return cell
            }
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "onelineCell", for: indexPath) as! OneCellCollectionViewCell
            
            let item = viewModel.itemForIndexPath(indexPath)
            
            cell.configure(with: item)
            
            return cell
        }

        
        func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
            guard kind == UICollectionView.elementKindSectionHeader else {
                return UICollectionReusableView()
            }
            
            let headerView = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "HeaderCollectionView", for: indexPath) as! HeaderCollectionView
            
            headerView.delegate = self
            headerView.typeLabel.text = indexPath.section == 0 ? "Folders" : "Files"
            
            // Các nút sẽ luôn hiển thị trong header của section folders
            if indexPath.section == 0 {
                headerView.folderBtn.isHidden = false
                headerView.viewToggleBtn.isHidden = false
                headerView.sortLabel.isHidden = false
            } else {
                // Ẩn tất cả các nút trong header của section files
                headerView.folderBtn.isHidden = true
                headerView.viewToggleBtn.isHidden = true
                headerView.sortLabel.isHidden = true
            }
            
            return headerView
        }




        func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
            
            let item = viewModel.itemForIndexPath(indexPath)
            do {
                let resourceValues = try item.resourceValues(forKeys: [.isDirectoryKey])
                
             
                
                if let isDirectory = resourceValues.isDirectory {
                    if isDirectory {
                        
                        showNewHomeView(with: item)
                       
                    } else {
                       
                    }
                }
                
               
            } catch {
                print("Loi khi co gang chuyen item ve resourceValuesKeys")
            }
        }
        
        
        // MARK: - Define any view set up
        
        private func showNewHomeView(with folder: URL) {
            guard let homeViewController = UIStoryboard(name: "Main", bundle: .main).instantiateViewController(withIdentifier: "HomeViewController") as? HomeViewController else {
                fatalError("Unable to Instantiate Home View Controller")
            }
            
            let newViewModel = HomeViewModel()
            newViewModel.parentFolder = folder
            homeViewController.viewModel = newViewModel

            if let navigationController = self.navigationController {
                navigationController.pushViewController(homeViewController, animated: true)
            } else {
                print("NavigationController is nil")
            }

        }

        
        func setupCollectionView() {
            
            let layout = UICollectionViewFlowLayout()
            
            if isGrid {
                layout.itemSize = CGSize(width: 120, height: 140)
                
            } else {
                layout.itemSize = CGSize(width: collectionView.frame.width*0.9, height: 80)
                
            }
            layout.headerReferenceSize = CGSize(width: collectionView.frame.width*0.9, height: 50)
            
            layout.sectionInset = UIEdgeInsets(top: 10.0, left: 5, bottom: 10.0, right: 5)
            
            collectionView.collectionViewLayout = layout
            collectionView.dataSource = self
            collectionView.delegate = self
            collectionView.register(UINib(nibName: "OneCellCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "onelineCell")
            collectionView.register(UINib(nibName: "GridCell", bundle: nil), forCellWithReuseIdentifier: "GridCell")
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
                self!.viewModel.saveNewItem(isFolder: true, name: folderName, image: nil)
                self!.viewModel.fetchItems()
            }

            let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)

            alertController.addAction(saveAction)
            alertController.addAction(cancelAction)

            present(alertController, animated: true, completion: nil)
        }


    }
