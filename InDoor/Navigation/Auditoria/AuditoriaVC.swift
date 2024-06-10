//
//  AuditoriaVC.swift
//  InDoor
//
//  Created by Sachko_AP on 10.06.2024.
//

import UIKit

class AuditoriaVC: UIViewController, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    let urlAPI = "https://indoor.skbkit.ru/api/locations/1/photos"
    let name: String
    let photoUrls: [String]
    
    var timerConstPer = 1
    
    var listPhotos: [UIImage] = []
    
    let autoScrollInterval: TimeInterval = 5
       
//    var collectionView: UICollectionView!
    var pageControl: UIPageControl!
    var timer: Timer?
    
//    private let caruselImageAuditoria: UIImageView = {
//        let image = UIImageView()
//        image.contentMode = .scaleAspectFill
//        image.translatesAutoresizingMaskIntoConstraints = false
//        image.clipsToBounds = true
//        return image
//    }()
//
    
    private lazy var collectionView: UICollectionView = {
        let flowLayout = UICollectionViewFlowLayout()
        flowLayout.scrollDirection = .horizontal
        
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: flowLayout)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        return collectionView
    }()

    
    init(name: String, photoUrls: [String]) {
        self.name = name
        self.photoUrls = photoUrls
        super.init(nibName: nil, bundle: nil)

    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    

    override func viewDidLoad() {
        super.viewDidLoad()
//
//        print(name)
//        print(photoUrls)
        
        CollectionViewPhotoAuditoriiCell.gifZagruzkaVstoennaia.startAnimating()

//
        for photoUrl in photoUrls {
            if let url = URL(string: urlAPI + photoUrl) {
                URLSession.shared.dataTask(with: url) { (data, response, error) in
                    if let data = data, let image = UIImage(data: data) {
                        DispatchQueue.main.async {
                            self.listPhotos.append(image)
                            CollectionViewPhotoAuditoriiCell.gifZagruzkaVstoennaia.stopAnimating()
                            self.collectionView.reloadData()
                        }
                    }
                }.resume()
            }
        }
                
        // Создание UICollectionView
        collectionView.register(CollectionViewPhotoAuditoriiCell.self, forCellWithReuseIdentifier: CollectionViewPhotoAuditoriiCell.reuseId)
        collectionView.dataSource = self
        
        let flowLayoutService = UICollectionViewFlowLayout()
        flowLayoutService.scrollDirection = .horizontal
        collectionView.collectionViewLayout = flowLayoutService
        collectionView.delegate = self
        collectionView.showsVerticalScrollIndicator = false
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.backgroundColor = .clear
        view.addSubview(collectionView)
        
        // Создание UIPageControl
        pageControl = UIPageControl(frame: CGRect(x: 0, y: view.bounds.height - 50, width: view.bounds.width, height: 50))
        pageControl.numberOfPages = photoUrls.count
        pageControl.currentPage = 0
        pageControl.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(pageControl)
        
//        // Настройка таймера для автоматического перелистывания фотографий
        timer = Timer.scheduledTimer(timeInterval: autoScrollInterval, target: self, selector: #selector(autoScroll), userInfo: nil, repeats: true)
//
        setConstrains()
    }
    
    private func setConstrains() {
        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: view.topAnchor, constant: 0),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            collectionView.heightAnchor.constraint(equalToConstant: 300),
            
            pageControl.topAnchor.constraint(equalTo: collectionView.bottomAnchor, constant: -20),
            pageControl.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        ])
    }
    
    
    @objc func autoScroll() {
        let nextPage = (pageControl.currentPage + 2) % listPhotos.count
//        timerConstPer += 1
        print(nextPage)
        collectionView.scrollToItem(at: IndexPath(item: nextPage, section: 0), at: .centeredHorizontally, animated: true)
    }

    // Добавьте этот метод в ваш код, чтобы обновлять UIPageControl при изменении страницы
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        let currentPage = Int(collectionView.contentOffset.x / collectionView.bounds.width)
        pageControl.currentPage = currentPage
    }


   // MARK: UICollectionViewDataSource
   
   func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
       return listPhotos.count
   }
   
   func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
       let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CollectionViewPhotoAuditoriiCell.reuseId, for: indexPath) as! CollectionViewPhotoAuditoriiCell
       cell.mainImageView.image = listPhotos[indexPath.row]
       return cell
   }
   
   // MARK: UICollectionViewDelegateFlowLayout
   
   func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
       return collectionView.bounds.size
   }
   
   // MARK: UIScrollViewDelegate
   
//   func scrollViewDidScroll(_ scrollView: UIScrollView) {
//       let currentPage = Int(scrollView.contentOffset.x / scrollView.bounds.width)
//       pageControl.currentPage = currentPage
//   }


}
