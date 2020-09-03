//
//  SelectImageVC.swift
//  instagramCopy
//
//  Created by 김광수 on 2020/05/31.
//  Copyright © 2020 김광수. All rights reserved.
//

import UIKit
import Photos

private let reuseIdentifier = "SelectPhotoCell"
private let headerIdentifier = "SelectPhotoHeader"

class SelectImageVC: UICollectionViewController, UICollectionViewDelegateFlowLayout {
  
  //MARK: - Properties
  var images = [UIImage]()
  var assets = [PHAsset]()
  var selectedImage: UIImage?
  var header: SelectPhotoHeader?
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    collectionView?.register(SelectPhotoCell.self, forCellWithReuseIdentifier: reuseIdentifier)
    collectionView?.register(SelectPhotoHeader.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: headerIdentifier)
    
    collectionView?.backgroundColor = .white
    
    // configure Navigation Button
    configureNabigationButtons()
    
    fetchPhotos()
  }
  
  //MARK: - UICollectionVeiwFlowLayout
  
  func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
    let width = view.frame.width
    // 정사각형으로 유지하기 위해서
    return CGSize(width: width, height: width)
  }
  
  func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
    let width = (view.frame.width - 3)/4 // spacing between image
    return CGSize(width: width, height: width)
  }
  
  //spaing between collectionView images
  func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
    return 1
  }
  
  
  func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
    return 1
  }
  
  
  //MARK: - UICollectionView DataSource
  
  override func numberOfSections(in collectionView: UICollectionView) -> Int {
    return 1
  }
  
  override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    return images.count
  }
  
  override func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
    
    let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: headerIdentifier, for: indexPath) as! SelectPhotoHeader
    
    self.header = header
    
    if let selectedImage = self.selectedImage {
      
      // index selected imga
      if let index = self.images.firstIndex(of: selectedImage) {
        
        //asset associated with selected imgae
        let selectedAsset = self.assets[index]
        
        let imageManager = PHImageManager.default()
        let targetSize = CGSize(width: 600, height: 600)
        
        //request image
        imageManager.requestImage(for: selectedAsset, targetSize: targetSize, contentMode: .default, options: nil, resultHandler: { (image, info) in
          
          header.photoImageView.image = image
        })
      }
    }
    return header
  }
  
  override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! SelectPhotoCell
    
    cell.photoImageView.image = images[indexPath.row]
    
    return cell
  }
  
  override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
    
    self.selectedImage = images[indexPath.row]
    self.collectionView.reloadData()
    
    let indexPath = IndexPath(item: 0, section: 0)
    collectionView.scrollToItem(at: indexPath, at: .bottom, animated: true)
  }
  
  //MARK: - Handlers
  
  @objc func handleCancel() {
    self.dismiss(animated: true, completion: nil)
  }
  
  @objc func handleNext() {
    let uploadPostVC = UploadPostVC()
    uploadPostVC.selectedImage = header?.photoImageView.image
    uploadPostVC.uploadAction = UploadPostVC.UploadAction(index: 1)
    navigationController?.pushViewController(uploadPostVC, animated: true)
  }
  
  func configureNabigationButtons() {
    
    navigationItem.leftBarButtonItem = UIBarButtonItem(title: "cancel", style: .plain, target: self, action: #selector(handleCancel))
    
    navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Next", style: .plain, target: self, action: #selector(handleNext))
  }
  
  func getAssetFetchOptions() -> PHFetchOptions {
    let options = PHFetchOptions()
    
    //가져올 사진의 갯수 제한
    options.fetchLimit = 30
    
    // 가져온 데이터를 생성일을 기준으로 정렬
    let sortDescription = NSSortDescriptor(key: "creationDate", ascending: false)
    
    //set sort description for options
    options.sortDescriptors = [sortDescription]
    
    // retrun options
    return options
  }
  
  func fetchPhotos() {
    // 애플 디바이스내 이미지를 가져옴 ( 카메라롤, 사진첩, photo library )
    
    let allPhotos = PHAsset.fetchAssets(with: .image, options: getAssetFetchOptions())
    
    DispatchQueue.global(qos: .background).async {
      
      //enumerate objects
      allPhotos.enumerateObjects({ (asset, count, stop) in
        
        let imageManager = PHImageManager.default()
        let targetSize = CGSize(width: 200, height: 200)
        let options = PHImageRequestOptions()
        options.isSynchronous = true
        
        imageManager.requestImage(for: asset, targetSize: targetSize, contentMode: .aspectFill, options: options) { (image, info) in
          
          if let image = image {
            
            // append image to data Source
            self.images.append(image)
            
            // append asset to data source
            self.assets.append(asset)
            
            // set selected with first image
            if self.selectedImage == nil {
              self.selectedImage = image
            }
            
            // reload collection view with images once count has completed
            if count == allPhotos.count - 1 {
              DispatchQueue.main.async {
                self.collectionView?.reloadData()
              }
            }
          }
        }
      })
    }
  }
}
