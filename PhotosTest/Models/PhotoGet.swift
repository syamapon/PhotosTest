//
//  PhotoGet.swift
//  PhotosTest
//
//  Created by shinichirou on 2026/01/02.
//

import SwiftUI
import Combine
import Photos

/// 写真アクセスを行う
class PhotoGet :ObservableObject {
    
    // 写真リスト
    @Published var photos: [Photo] = []
        
    /// イニシャライザ
    init()
    {
        setPhotos()
    }
        
    /// アルバム画像の読み込み
    func setPhotos() {
        
        PHPhotoLibrary.requestAuthorization(for: .readWrite) { status in
            switch status {
            case .authorized, .limited:
               
                // アルバム(花・木・植物）を取得
                let fetchOptions = PHFetchOptions()
                fetchOptions.predicate = NSPredicate(format: "title IN %@", ["植物"])
                
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
                        let _photo = Photo(setImage: asset)
                        _photo.albumTitle = album.localizedTitle
                        
                        // DBをもとにデータ設定
                        do {
                            try _photo.setData()
                            
                            // 写真リストに追加
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


