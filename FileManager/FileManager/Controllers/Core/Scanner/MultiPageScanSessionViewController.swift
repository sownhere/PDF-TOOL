//
//  MultiPageScanViewController.swift
//  FileManager
//
//  Created by Macbook on 10/07/2024.
//


import UIKit

public protocol MultiPageScanSessionViewControllerDelegate:NSObjectProtocol {
    func multiPageScanSessionViewController(_ multiPageScanSessionViewController:MultiPageScanSessionViewController, finished session:MultiPageScanSessionViewModel)
}

public class MultiPageScanSessionViewController: UIViewController {

    private var scanSession:MultiPageScanSessionViewModel
    private var pages:Array<ScannedPageViewController> = []
    


    private lazy var cancelButton: UIBarButtonItem = {
        let title = NSLocalizedString("wescan.scanning.cancel",
                                      tableName: nil,
                                      bundle: Bundle(for: EditScanViewController.self),
                                      value: "Cancel",
                                      comment: "A generic cancel button"
        )
        let button = UIBarButtonItem(title: title, style: .plain, target: self, action: #selector(cancelButtonTapped))
        button.tintColor = .red
        return button
    }()
    
    weak public var delegate:MultiPageScanSessionViewControllerDelegate?
    
    lazy private var saveButton: UIBarButtonItem = {
        let title = NSLocalizedString("wescan.edit.button.save", tableName: nil, bundle: Bundle(for: MultiPageScanSessionViewController.self), value: "Save", comment: "Save button")
        let button = UIBarButtonItem(title: title, style: .done, target: self, action: #selector(handleSave))
        button.tintColor = navigationController?.navigationBar.tintColor
        return button
    }()
    
    lazy private var pageController: UIPageViewController = {
        let pageController = UIPageViewController(transitionStyle: .scroll, navigationOrientation: .horizontal, options: nil)
        pageController.dataSource = self
        pageController.delegate = self
        return pageController
    }()
    
    lazy private var pageControl: UIPageControl = {
        let pageControl = UIPageControl()
        pageControl.translatesAutoresizingMaskIntoConstraints = false
        return pageControl
    }()
    
    public init(scanSession:MultiPageScanSessionViewModel){
        self.scanSession = scanSession
        super.init(nibName: nil, bundle: nil)
        setupPages()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) should not be called for this class")
    }
    
    // MARK: - View lifecycle
    
    override public func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .white
        if let firstVC = self.navigationController?.viewControllers.first, firstVC == self {
            navigationItem.leftBarButtonItem = cancelButton
            self.navigationController?.navigationBar.tintColor = UIColor.red

        } else {
            self.navigationController?.navigationBar.tintColor = UIColor.red


            
        }

        self.setupViews()
    }

    override public func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.navigationController?.setToolbarHidden(false, animated: true)
        navigationController?.interactivePopGestureRecognizer?.isEnabled = false
    }


    
    // MARK: - Private
    
    private func setupPages(){
        self.scanSession.imageScannerResults.forEach { (imageScannerResult) in
            let vc = ScannedPageViewController(imageScannerResult: imageScannerResult)
            vc.view.isUserInteractionEnabled = false
            self.pages.append(vc)
        }
        self.gotoLastPage()
    }
    
    private func setupViews(){
        // Page Controller
        let constraints = [self.pageController.view.topAnchor.constraint(equalTo: self.view.topAnchor, constant: 0.0),
                           self.pageController.view.bottomAnchor.constraint(equalTo: self.view.bottomAnchor, constant: 0.0),
                           self.pageController.view.leftAnchor.constraint(equalTo: self.view.leftAnchor, constant: 0.0),
                           self.pageController.view.rightAnchor.constraint(equalTo: self.view.rightAnchor, constant: 0.0)]
        self.view.addSubview(self.pageController.view)
        NSLayoutConstraint.activate(constraints)
        self.addChild(self.pageController)
        
        // Page Control
        let pageControlConstraints = [self.pageControl.bottomAnchor.constraint(equalTo: self.view!.bottomAnchor, constant:0.0),
                                      self.pageControl.centerXAnchor.constraint(equalTo: self.view.centerXAnchor)]
        self.view.addSubview(self.pageControl)
        NSLayoutConstraint.activate(pageControlConstraints)
        
        // Navigation

        self.navigationItem.rightBarButtonItem = self.saveButton
        
        // Toolbar


        // Create a UIBarButtonItem
        let editItem = UIBarButtonItem(barButtonSystemItem: .edit, target: self, action: #selector(handleEdit))
        let drawItem = UIBarButtonItem(image: UIImage(systemName: "pencil"), style: .plain, target: self, action: #selector(customButtonPressed))
        let signItem = UIBarButtonItem(image: UIImage(systemName: "signature"), style: .plain, target: self, action: #selector(customButtonPressed))
        let totextItem = UIBarButtonItem(image: UIImage(systemName: "doc.text"), style: .plain, target: self, action: #selector(customButtonPressed))
        let deleteItem = UIBarButtonItem(barButtonSystemItem: .trash, target: self, action: #selector(handleTrash))
        let rotateIconImage = UIImage(named: "rotate", in: Bundle(for: MultiPageScanSessionViewController.self), compatibleWith: nil)
        let rotateItem = UIBarButtonItem(image: rotateIconImage, style: .plain, target: self, action: #selector(handleRotate))
        
        let flexibleItem = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        
        self.toolbarItems = [editItem, flexibleItem, drawItem, flexibleItem, signItem, flexibleItem, rotateItem, flexibleItem, totextItem, flexibleItem, deleteItem]
    }
    
    private func getCurrentViewController()->ScannedPageViewController{
        return self.pageController.viewControllers!.first! as! ScannedPageViewController
    }
    
    private func getCurrentPageIndex()->Int?{
        let currentViewController = self.getCurrentViewController()
        return self.pages.firstIndex(of:currentViewController)
    }
    
    private func getCurrentItem()->ImageScannerResults?{
        if let currentIndex = self.getCurrentPageIndex(){
            return self.scanSession.imageScannerResults[currentIndex]
        }
        return nil
    }
    
    private func updateTitle(index:Int){
        self.title = "\(index + 1) / \(self.pages.count)"
    }
    
    private func gotoLastPage(direction:UIPageViewController.NavigationDirection? = .forward){
        let lastIndex = self.pages.count - 1
        self.gotoPage(index: lastIndex, direction: direction)
    }
    
    private func gotoPage(index:Int, direction:UIPageViewController.NavigationDirection? = .forward){
        self.pageController.setViewControllers([self.pages[index]], direction: direction!, animated: true, completion: nil)
        self.pageControl.numberOfPages = self.pages.count
        self.pageControl.currentPage = index
        self.updateTitle(index: index)
    }
    
    private func trashCurrentPage(){
        if let currentIndex = self.getCurrentPageIndex(){
            self.scanSession.remove(index: currentIndex)
            self.pages.remove(at: currentIndex)
            if (self.scanSession.imageScannerResults.count > 0){
                let previousIndex  = currentIndex - 1
                let newIndex = (previousIndex >= 0 ? previousIndex : 0)
                let direction:UIPageViewController.NavigationDirection = (newIndex == 0 ? .forward : .reverse)
                self.gotoPage(index: newIndex, direction: direction)
            } else {
                if let imageScannerController = navigationController as? ImageScannerController {
                    if let firstViewController = navigationController?.viewControllers.first, firstViewController == self {
                        imageScannerController.imageScannerDelegate?.imageScannerControllerDidCancel(imageScannerController)
                    } else {
                        self.navigationController?.popViewController(animated: true)
                    }
                }
            }
        }
    }
    
    // MARK: Button handlers
    
    @objc func cancelButtonTapped() {
        if let imageScannerController = navigationController as? ImageScannerController {
            imageScannerController.imageScannerDelegate?.imageScannerControllerDidCancel(imageScannerController)
        }
    }

    
    @objc private func handleSave(){
        self.delegate?.multiPageScanSessionViewController(self, finished: self.scanSession)
    }
    
    @objc private func handleRotate(){
        print("xu ly xoay anh o day")
    }
    
    @objc func customButtonPressed() {
        for index in scanSession.imageScannerResults.indices {
            scanSession.imageScannerResults[index].doesUserPreferEnhancedScan?.toggle()
        }
        // reload all pages
        for page in pages {
            page.reRender(item: scanSession.imageScannerResults[pages.firstIndex(of: page)!])
        }
    }
    
    @objc private func handleTrash(){
        let alertController = UIAlertController(title: "Confirm",
                                                message: "Are you sure you want to delete this page?",
                                                preferredStyle: .alert)
        let okAction = UIAlertAction(title: "Delete", style: .destructive) { (action) in
            self.trashCurrentPage()
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        alertController.addAction(okAction)
        alertController.addAction(cancelAction)
        self.present(alertController, animated: true, completion: nil)
    }
    
    @objc private func handleEdit(){
        if let currentIndex = self.getCurrentPageIndex(){
            let currentItem = self.scanSession.imageScannerResults[currentIndex]
            
            let editViewController = EditScanViewController(imagecannerResult: currentItem, rotateImage: false)
            editViewController.delegate = self
            editViewController.modalPresentationStyle = .fullScreen
            let navController = UINavigationController(rootViewController: editViewController)
            self.present(navController, animated: true, completion: nil)
        } else {
            fatalError("Current viewcontroller cannot be found")
        }
    }
    
}

extension MultiPageScanSessionViewController: EditScanViewControllerDelegate {
    func editScanViewControllerDidCancel(_ editScanViewController: EditScanViewController) {
        self.dismiss(animated: true, completion: nil)
    }
    
    func editScanViewController(_ editScanViewController: EditScanViewController, finishedEditing item: ImageScannerResults) {
        self.dismiss(animated: true, completion: {
            if let index = self.getCurrentPageIndex() {
                
                self.scanSession.updateImageScannerResult(at: index, with: item)
                self.reloadCurrentPage()
            }
        })
    }
    
    private func reloadCurrentPage() {
        DispatchQueue.main.async { // Đảm bảo mọi thay đổi giao diện đều trên main thread
            if let currentPageIndex = self.getCurrentPageIndex() {
                let currentViewController = self.pages[currentPageIndex] as ScannedPageViewController
                currentViewController.reRender(item: self.scanSession.imageScannerResults[currentPageIndex])
            }
        }
    }
    

}

extension MultiPageScanSessionViewController:UIPageViewControllerDataSource{
    
    public func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        if let index = pages.firstIndex(of: (viewController as! ScannedPageViewController)){
            let previousIndex = index - 1
            if (previousIndex >= 0){
                return self.pages[previousIndex]
            }
        }
        return nil
    }
    
    public func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        if let index = pages.firstIndex(of: (viewController as! ScannedPageViewController)){
            let nextIndex = index + 1
            if (nextIndex < pages.count){
                return self.pages[nextIndex]
            }
        }
        return nil
    }
}

extension MultiPageScanSessionViewController:UIPageViewControllerDelegate{
    
    public func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
        
        guard completed else { return }
        
        let currentViewController = self.getCurrentViewController()
        let index = self.pages.firstIndex(of:currentViewController)
        
        if let index = index {
            self.updateTitle(index:index)
            self.pageControl.currentPage = index
        }
    }
    
    
}

