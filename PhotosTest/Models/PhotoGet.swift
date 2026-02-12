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
    
    func getPhoto(_ sectionID: Photo.ID?) -> Photo? {
        if let _selectionID = sectionID {
            let photo = photos.first(where: { $0.id == _selectionID })
            
            if var p = photo {
                do {
                    try p.setData()
                    //self.photo = p
                } catch {
                    print("setData error:", error)
                }
                return p
            }
            // self.inputName = self.photo?.title ?? ""
        }
        return nil
    }
    
    func setTitle(_ id: Photo.ID?, setTitle title: String) {
        if var _photo = getPhoto(id) {
            _photo.title = title
        }
    }
    
    func setPhotos() {
        
        PHPhotoLibrary.requestAuthorization(for: .readWrite) { status in
            switch status {
            case .authorized, .limited:
               
                // アルバム取得
                let fetchOptions = PHFetchOptions()
                /*
                let p1 = NSPredicate(format: "title == %@", "植物")
                let p2 = NSPredicate(format: "title == %@", "花")
                 */
                //let predicate = NSCompoundPredicate(orPredicateWithSubpredicates: [p1, p2])
                //fetchOptions.predicate = NSCompoundPredicate(orPredicateWithSubpredicates: [p1, p2])
                fetchOptions.predicate = NSPredicate(format: "title IN %@", ["花", "木", "植物"])
                let collection = PHAssetCollection.fetchAssetCollections(with: .album, subtype: .any, options: fetchOptions)
                print(collection.count)
                
                var fetchedPhotos: [Photo] = []
                
                for i in 0..<collection.count {
                    let album = collection.object(at: i)
                    print(album.localizedTitle ?? "NoTitle")
                    
                    // アルバムに登録されたイメージの取得
                    let fetchOptionsByAlbum = PHFetchOptions()
                    fetchOptionsByAlbum.sortDescriptors = [
                        NSSortDescriptor(key: "creationDate", ascending: false)
                    ]
                    
                    let assets = PHAsset.fetchAssets(in: album, options: fetchOptionsByAlbum)
                    
                    assets.enumerateObjects { asset, _, _ in
                        print(asset.creationDate ?? "")
                        
                        print(asset.localIdentifier)
                        let locationDescription = asset.location.map { "\($0.coordinate.latitude), \($0.coordinate.longitude)" } ?? "nil"
                        print("location: \(locationDescription)")
                        
                        
                        
                        
                        var _photoTitle: String = ""
                        
                        
                        // 画像オブジェクトを作成
                        var _photo = Photo(title: _photoTitle, asset: asset)
                        _photo.creationDate = asset.creationDate
                        _photo.albumTitle = album.localizedTitle
                        
                        do {
                            try _photo.setData()
                        }
                        catch {
                            print ("ERROR")
                        }
                        
                        // 位置情報を設定
                        _photo.locLatitude = asset.location?.coordinate.latitude
                        _photo.locLongitude = asset.location?.coordinate.longitude
                        
                        fetchedPhotos.append(_photo)
                    }
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


