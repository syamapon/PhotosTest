//
//  PhotoGet.swift
//  PhotosTest
//
//  Created by shinichirou on 2026/01/02.
//

import SwiftUI
import Combine
import Photos

class PhotoGet :ObservableObject {
    
    @Published var photos: [Photo] = []
    
    init()
    {
        setPhotos()
    }
    
    func setPhotos() {
        
        PHPhotoLibrary.requestAuthorization(for: .readWrite) { status in
            switch status {
            case .authorized, .limited:
               
                // アルバム取得
                let fetchOptions = PHFetchOptions()
                fetchOptions.predicate = NSPredicate(format: "title == %@", "植物")
                let collection = PHAssetCollection.fetchAssetCollections(with: .album, subtype: .any, options: fetchOptions)
                print(collection.count)
                
                // 先頭のアルバムを取得してから、そのアルバム内のアセットをフェッチ
                guard let album = collection.firstObject else {
                    print("指定したタイトルのアルバムが見つかりませんでした")
                    return
                }
                
                // アルバムに登録されたイメージの取得
                let fetchOptionsByAlbum = PHFetchOptions()
                fetchOptionsByAlbum.sortDescriptors = [
                    NSSortDescriptor(key: "creationDate", ascending: false)
                ]
                
                let assets = PHAsset.fetchAssets(in: album, options: fetchOptionsByAlbum)
                
                var fetchedPhotos: [Photo] = []
                
                assets.enumerateObjects { asset, _, _ in
                    print(asset.creationDate ?? "")
                    
                    print(asset.localIdentifier)
                    let locationDescription = asset.location.map { "\($0.coordinate.latitude), \($0.coordinate.longitude)" } ?? "nil"
                    print("location: \(locationDescription)")
                    
                    
                    // 画像オブジェクトを作成
                    var _photo = Photo(title: "", asset: asset)
                    _photo.creationDate = asset.creationDate
                    //self.photos.append(contentsOf: [_photo])
                    //self.photos.append(_photo)
                    //_self.photos.append(_photo)
                    

                    fetchedPhotos.append(_photo)
                }
                
                DispatchQueue.main.async {
                    // ここで @Published / @StateObject が持つ状態を更新する
                    self.photos = fetchedPhotos
                }
                
            case .denied:
                print("アクセス不可(denied)")
            case .restricted:
                print("アクセス不可(restricted)")
            default:
                break
            }
        }
    }
    

    
    
    
}


