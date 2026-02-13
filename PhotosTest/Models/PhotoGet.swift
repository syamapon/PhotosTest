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
               
                // アルバム(花・木・植物）を取得
                let fetchOptions = PHFetchOptions()
                fetchOptions.predicate = NSPredicate(format: "title IN %@", ["花", "木", "植物"])
                
                // アルバムのコレクションを取得
                let albumCollection = PHAssetCollection.fetchAssetCollections(with: .album, subtype: .any, options: fetchOptions)
                print(albumCollection.count)
                
                // 内部で保持する、写真データ配列
                var fetchedPhotos: [Photo] = []
                
                // 読み込んだアルバムの数だけループ
                for i in 0..<albumCollection.count {
                    
                    // アルバム取得
                    let album = albumCollection.object(at: i)
                    print(album.localizedTitle ?? "NoTitle")
                    
                    // アルバムに登録された写真リストの取得
                    let fetchOptionsByAlbum = PHFetchOptions()
                    fetchOptionsByAlbum.sortDescriptors = [
                        NSSortDescriptor(key: "creationDate", ascending: false)
                    ]
                    let assets = PHAsset.fetchAssets(in: album, options: fetchOptionsByAlbum)
                    
                    // アルバム内の写真を列挙して、写真の配列を作成
                    assets.enumerateObjects { asset, idx, _ in
                        
                        print("Album:\(album.localizedTitle ?? "NoTitle")　Photo:\(idx + 1)")

                        // 写真をもとにデータ設定
                        var _photo = Photo(setImage: asset)
                        _photo.albumTitle = album.localizedTitle
                        
                        // DBをもとにデータ設定
                        do {
                            try _photo.setData()
                            
                            fetchedPhotos.append(_photo)
                        }
                        catch {
                            print ("Photo SetData Error: \(error)")
                        }
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


