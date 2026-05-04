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
    
    
    /// データ取得URL
    private let baseURL = URL(string: "http://192.168.3.8:8080")!
    
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
                        
                        // 写真リストに追加
                        fetchedPhotos.append(_photo)
                    }
                }
                
                self.setPhotoDatas(fetchedPhotos)
                
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
    
    /// データ取得用写真データ
    struct GetPlantPhoto : Decodable {
        let plant: GetPlant?
        let plantInfo: GetPlantInfo?
    }
    
    /// データ取得用(Plants)
    struct GetPlant: Decodable {
        let id: String
        let createdAt: String
        let title: String?
        let comment: String?
        let category: String?
    }
    
    /// データ取得用(PlantsInfo)
    struct GetPlantInfo: Decodable {
        let id: String
        //let title: String
        let aliasName: String?
        let kanjiName: String?
        let url: String?
        let wiki: String?
        let family: String?
        let bloomSeasons: String?
        let features: String?
        let info: String?
    }
    
    /// 更新用写真データ
    struct UpdatePlantPhoto: Codable {
        let updatePlant: UpdatePlant
        let updatePlantInfo: UpdatePlantInfo?
    }
    
    /// 更新用植物個体データ
    struct UpdatePlant: Codable {
        let id: String
        let createdAt: String
        let title: String?
        let comment: String?
        let category: String?
    }
    
    /// 更新用植物共通データ
    struct UpdatePlantInfo: Codable {
        let id: String
        //let title: String
        let aliasName: String?
        let kanjiName: String?
        let url: String?
        let wiki: String?
        let family: String?
        let bloomSeansons: String?
        let features: String?
        let info: String?
    }
    
    /// 写真から取得したデータにデータ設定を行う
    /// - Parameter photos: 取得済みの写真データリスト
    func setPhotoDatas(_ photos: [Photo]) {
        
        // データ取得URL作成
        let urlPhotos = baseURL.appendingPathComponent("photos")
        // データ取得域
        var getPhotos: [GetPlantPhoto] = []
        
        Task {
            do {
                // Photoデータをサーバから取得
                let (photoData, _) = try await URLSession.shared.data(from: urlPhotos)
                getPhotos = try JSONDecoder().decode([GetPlantPhoto].self, from: photoData)
                
                // 取得データを元にループして、写真データに設定
                for getPhoto in getPhotos {
                    if let setData = photos.filter { $0.id == getPhoto.plant?.id ?? ""}.first {
                        // 植物個体情報を設定
                        setData.title = getPhoto.plant?.title ?? ""
                        setData.comment = getPhoto.plant?.comment ?? ""
                        setData.setCategoryBy(strCategory: getPhoto.plant?.category ?? "")
                        // 植物情報を設定
                        if let plantInfo = getPhoto.plantInfo {
                            setData.aliasName = plantInfo.aliasName
                            setData.kanjiName = plantInfo.kanjiName
                            setData.url = plantInfo.url
                            setData.wiki = plantInfo.wiki
                            setData.family = plantInfo.family
                            setData.features = plantInfo.features
                            setData.info = plantInfo.info
                            setData.setBloomSeasonBy(strSeansons: plantInfo.bloomSeasons ?? "")
                        }
                    }
                }
            } catch {
                print("Failed to fetch photos: \(error)")
            }
        }
    }
    
    
    /// タイトルを指定して、植物の一般情報を取得する
    /// - Parameter id: タイトル
    /// - Returns: 植物（一般情報）
    func getPlantInfo(title id: String) async -> GetPlantInfo? {
        
        // データ取得URL作成
        let urlPlantInfo = baseURL.appendingPathComponent("plantInfo").appendingPathComponent(id)
        
        do {
            // PhotoInfoデータをサーバから取得
            let (photoData, _) = try await URLSession.shared.data(from: urlPlantInfo)
            var getPlantInfo = try JSONDecoder().decode(GetPlantInfo.self, from: photoData)
            
            return getPlantInfo
        } catch {
            print("error:\(error)")
            return nil
        }
    }
    
    /// 写真データを登録/更新します
    /// - Parameter photo: 写真データ
    func updatePhoto(data photo: Photo) {
        // タイトル未設定の場合はスルー
        guard photo.title != nil else {
            print("Not set title")
            return
        }
        let photoTitle = photo.title!
        
        // 登録日付を文字列として取得
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        var dateString:String = ""
        if let cDate = photo.creationDate {
            dateString = formatter.string(from: cDate)
        }
        
        // 登録データ作成
        let updatePlant = UpdatePlant(id: photo.id, createdAt: dateString, title: photoTitle, comment: photo.comment,
                                      category: photo.plantCategoryNames)
        let updatePlantInfo = UpdatePlantInfo(id: photoTitle, aliasName: photo.aliasName, kanjiName: photo.kanjiName,
                                              url: photo.url, wiki: photo.wiki, family: photo.family,
                                              bloomSeansons: photo.bloomSeasonNames, features: photo.features, info: photo.info)
        let updatePhoto = UpdatePlantPhoto(updatePlant: updatePlant, updatePlantInfo: updatePlantInfo)
        
        // DB登録
        let url = baseURL.appendingPathComponent("photo")
        do {
            var request = URLRequest(url: url)
            request.httpMethod = "POST"
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            
            let jsonData = try JSONEncoder().encode(updatePhoto)
            request.httpBody = jsonData
            
            Task {
                let (data, _) = try await URLSession.shared.data(for: request)
                //try validate(response: response)
                
                let decoder = JSONDecoder()
                decoder.dateDecodingStrategy = .iso8601
                let updatedPhoto = try decoder.decode(UpdatePlantPhoto.self, from: data)
                print("UpdatedPhoto: \(updatedPhoto)")
            }
            
        }
        catch {
            print("Error posting data: \(error)")
        }
        
    }
    
    /// 日付を文字列から取得
    /// - Parameter dateString: 日付を表す文字列
    /// - Returns: 文字列が示す日付
    func getCreatedAt(from dateString: String) -> Date? {
        
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        let cdate = formatter.date(from: dateString)
        
        return cdate
    }
}


