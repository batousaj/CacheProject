//
//  ViewController.swift
//  CacheSample
//
//  Created by Mac Mini 2021_1 on 17/09/2022.
//

import UIKit

class ViewController: UIViewController {
    
    var collectionView:UICollectionView!
    
    var imageList = [Package.ImageCache]()

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        self.createCollection()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.createNavigator()
        self.fecthData { results in
            if results {
                DispatchQueue.main.async {
                    self.collectionView.reloadData()
                }
            }
        }
    }
    
    func createNavigator() {
        self.title = "Image Caching"
        self.navigationController?.navigationBar.backgroundColor = .systemGray6
        let barButton = UIBarButtonItem.init(image: UIImage.init(systemName: "plus.circle.fill")!, style: .done, target: self, action: #selector(OnAddPictureFromWeb))
        barButton.tintColor = .black
        
        self.navigationItem.rightBarButtonItem = barButton
    }
    
    func createCollection() {
        let layout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
        layout.sectionInset = UIEdgeInsets(top: 20, left: 20, bottom: 10, right: 10)
        layout.itemSize = CGSize(width: 300, height: 200)
        
        collectionView = UICollectionView.init(frame: CGRect(x: 0, y: 100, width: self.view.frame.width, height: self.view.frame.height - 100), collectionViewLayout: layout)
        self.view.addSubview(collectionView)
        
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.register(CollectionViewImage.self, forCellWithReuseIdentifier: "myCollection")
    }
    
    func fecthData(_ completion: @escaping (Bool) -> Void) {
        RequestManager.sharedInstance.requestSearchImageList(query: "puppies") { imageCache, error in
            if let error_ = error {
                print("error : \(error_)")
                completion(false)
                return
            }
            
            if let imageSearch = imageCache {
                self.imageList = imageSearch
                completion(true)
            }
        }
        completion(false)
    }

}

// MARK: - Collection Extension

extension ViewController : UICollectionViewDelegate, UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return imageList.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "myCollection", for: indexPath) as! CollectionViewImage
        
        if let url = URL(string: self.imageList[indexPath.row].urls.regular) {
            RequestManager.sharedInstance.downloadImage(url) { image, error in
                if let error_ = error {
                    print("error : \(error_)")
                }
                
                if let imageCache = image {
                    cell.image = imageCache
                }
            }
        } else {
            cell.image = UIImage(systemName: "picture")
        }
        
        cell.title = self.imageList[indexPath.row].alt_description
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        print("collectionView select at \(indexPath.row)")
    }
}

// MARK: - Objective C extension

extension ViewController {
    
    @objc func OnAddPictureFromWeb() {
        print("On Click Remove all cache")
        RequestManager.sharedInstance.imageCache.removeAllValue()
    }
    
}


