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
    let descriptions: String
    let idAuditorii: Int
    
    var timerConstPer = 1
    
    var listPhotos: [UIImage] = []
    
    let autoScrollInterval: TimeInterval = 5
       
    var pageControl: UIPageControl!
    var timer: Timer?
    let buildRouteNotification = Notification.Name("BuildRouteToMarker")

    
    private lazy var collectionView: UICollectionView = {
        let flowLayout = UICollectionViewFlowLayout()
        flowLayout.scrollDirection = .horizontal
        
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: flowLayout)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        return collectionView
    }()
    private let lineBottomCollectionVIew: UIView = {
        let bottomBorder = UIView()
        bottomBorder.translatesAutoresizingMaskIntoConstraints = false
        bottomBorder.backgroundColor = UIColor.white
        bottomBorder.layer.cornerRadius = 19
        return bottomBorder
    }()
    private let nameAuditoria: UILabel = {
        let text = UILabel()
        text.translatesAutoresizingMaskIntoConstraints = false
        text.font = UIFont.systemFont(ofSize: 27, weight: .medium)
        text.textColor = .black
        text.lineBreakMode = .byWordWrapping
        text.numberOfLines = 0
        return text
    }()
    private let closeButtonAuditoria: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        let image = ImageConstants.Image.Auditoria.closeButtonAuditoria
        button.setImage(image, for: .normal)
        return button
    }()
    private let aButtonAuditoria: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        let image = ImageConstants.Image.Auditoria.iconMarshrut
        button.imageEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 12)
        button.setImage(image, for: .normal)
        button.setTitle("Отсюда", for: .normal)
        button.backgroundColor = .systemBlue
        button.layer.cornerRadius = 10
        return button
    }()
    private let bButtonAuditoria: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        let image = ImageConstants.Image.Auditoria.iconMarshrut
        button.setImage(image, for: .normal)
        button.imageEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 12)
        button.setTitle("Сюда", for: .normal)
        button.backgroundColor = .systemBlue
        button.layer.cornerRadius = 10
        return button
    }()
    private let descriptionAuditoria: UILabel = {
        let text = UILabel()
        text.translatesAutoresizingMaskIntoConstraints = false
        text.font = UIFont.systemFont(ofSize: 18, weight: .regular)
        text.textColor = .black
        text.lineBreakMode = .byWordWrapping
        text.numberOfLines = 0
        return text
    }()

    
    init(name: String, photoUrls: [String], descriptions: String, idAuditorii: Int) {
        self.name = name
        self.photoUrls = photoUrls
        self.descriptions = descriptions
        self.idAuditorii = idAuditorii
        super.init(nibName: nil, bundle: nil)

    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidAppear(_ animated: Bool) {
        self.navigationController?.setNavigationBarHidden(true, animated: false)
        nameAuditoria.text = "Аудитория \(name)"
        descriptionAuditoria.text = descriptions
    }
    

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        CollectionViewPhotoAuditoriiCell.gifZagruzkaVstoennaia.startAnimating()

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

        view.addSubview(lineBottomCollectionVIew)
        view.addSubview(nameAuditoria)
        view.addSubview(closeButtonAuditoria)
        view.addSubview(descriptionAuditoria)
        view.addSubview(aButtonAuditoria)
        view.addSubview(bButtonAuditoria)
        setConstrains()
        addActions()
    }
    
    // MARK: AddActions
    private func addActions(){
        closeButtonAuditoria.addAction(UIAction(handler: { [weak self] _ in
            self?.navigationController?.popViewController(animated: false)
        }), for: .touchUpInside)
        
        aButtonAuditoria.addAction(UIAction(handler: { [weak self] _ in
        }), for: .touchUpInside)
        
        bButtonAuditoria.addAction(UIAction(handler: { [weak self] _ in
            NotificationCenter.default.post(name: self!.buildRouteNotification, object: self?.idAuditorii)
            self?.navigationController?.popViewController(animated: false)
        }), for: .touchUpInside)

    }

    private func setConstrains() {
        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: view.topAnchor, constant: -49),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            collectionView.heightAnchor.constraint(equalToConstant: 300),
            
            lineBottomCollectionVIew.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            lineBottomCollectionVIew.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            lineBottomCollectionVIew.centerYAnchor.constraint(equalTo: collectionView.bottomAnchor),
            lineBottomCollectionVIew.heightAnchor.constraint(equalToConstant: 30),
            
            pageControl.topAnchor.constraint(equalTo: collectionView.bottomAnchor, constant: -40),
            pageControl.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            nameAuditoria.topAnchor.constraint(equalTo: lineBottomCollectionVIew.bottomAnchor, constant: -5),
            nameAuditoria.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            
            closeButtonAuditoria.centerYAnchor.constraint(equalTo: nameAuditoria.centerYAnchor),
            closeButtonAuditoria.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -30),
            closeButtonAuditoria.heightAnchor.constraint(equalToConstant: 30),
            closeButtonAuditoria.widthAnchor.constraint(equalToConstant: 30),
            
            aButtonAuditoria.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -50),
            aButtonAuditoria.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 15),
            aButtonAuditoria.heightAnchor.constraint(equalToConstant: 35),
            aButtonAuditoria.widthAnchor.constraint(equalToConstant: 150),
            
            bButtonAuditoria.centerYAnchor.constraint(equalTo: aButtonAuditoria.centerYAnchor),
            bButtonAuditoria.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -15),
            bButtonAuditoria.heightAnchor.constraint(equalToConstant: 35),
            bButtonAuditoria.widthAnchor.constraint(equalToConstant: 150),

            descriptionAuditoria.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 15),
            descriptionAuditoria.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -15),
            descriptionAuditoria.topAnchor.constraint(equalTo: nameAuditoria.bottomAnchor, constant: 20),

        ])
    }
    
    
    @objc func autoScroll() {
        if listPhotos.count == 0 {
            return 
        }
        let nextPage = (pageControl.currentPage + 2) % listPhotos.count
//        timerConstPer += 1
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
