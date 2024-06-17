//
//  ViewController.swift
//  FileManager
//
//  Created by Macbook on 17/06/2024.
//

import UIKit

class HomeViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 3
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell: OneCellCollectionViewCell = collectionView.dequeueReusableCell(withReuseIdentifier: "onelineCell", for: indexPath) as! OneCellCollectionViewCell
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        switch kind {
         // 1
         case UICollectionView.elementKindSectionHeader:
           // 2
           let headerView = collectionView.dequeueReusableSupplementaryView(
             ofKind: kind,
             withReuseIdentifier: "HeaderCollectionView",
             for: indexPath)

           // 3
           guard let typedHeaderView = headerView as? HeaderCollectionView
           else { return headerView }

           // 4
 
           return typedHeaderView
         default:
           // 5
           assert(false, "Invalid element type")
         }
    }
    

    
    
    @IBOutlet var collectionView: UICollectionView!
    
    @IBOutlet var searchBarView: UISearchBar!

    override func viewDidLoad() {
        super.viewDidLoad()
        let searchController = UISearchController(searchResultsController: nil)
        // Do any additional setup after loading the view.
        navigationItem.searchController = searchController
        
        collectionView.dataSource = self
        collectionView.delegate = self
        
        self.collectionView.register(UINib(nibName: "OneCellCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "onelineCell")
        collectionView.isPagingEnabled = true
        collectionView.alwaysBounceVertical = true 
    }


}

