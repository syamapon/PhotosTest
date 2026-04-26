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
    private let baseURL = URL(string: "http://192.168.3.4:8080")!
        
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
    
    /// データ取得用(Plants)
    struct GetPhotoData: Decodable {
        let id: String
        let createdAt: String
        let title: String?
        let comment: String?
        let category: String?
    }
    
    /// データ取得用(PlantsInfo)
    struct GetPhotoInfoData: Decodable {
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
    
    /// データ作成・更新用
    struct UpdatePhotoData: Codable {
        let id: String
        let createdAt: String
        let title: String?
        let comment: String?
        let category: String?
    }
        
    /// 写真から取得したデータにデータ設定を行う
    /// - Parameter photos: 取得済みの写真データリスト
    func setPhotoDatas(_ photos: [Photo]) {

        // データ取得URL作成
        let urlPlants = baseURL.appendingPathComponent("plants")
        let urlPlantsInfo = baseURL.appendingPathComponent("plantsInfo")

        // データ取得
        var getPhotoDatas = [GetPhotoData]()
        var getPhotoInfoDatas = [GetPhotoInfoData]()
        
        Task {
            do {
                // Plantsテーブルからデータ取得
                let (data, _) = try await URLSession.shared.data(from: urlPlants)
                getPhotoDatas = try JSONDecoder().decode([GetPhotoData].self, from: data)
                
                // PlantsInfoテーブルからデータ取得
                let (dataPlantsInfo, _) = try await URLSession.shared.data(from: urlPlantsInfo)
                getPhotoInfoDatas = try JSONDecoder().decode([GetPhotoInfoData].self, from: dataPlantsInfo)
                
                
                for getPhotoData in getPhotoDatas {
                                        
                    if let setData = photos.filter { $0.id == getPhotoData.id }.first {
                        setData.title = getPhotoData.title
                        setData.comment = getPhotoData.comment
                        
                        if let setInfoData = getPhotoInfoDatas.filter { $0.id == setData.title}.first {
                            setData.aliasName = setInfoData.aliasName
                            setData.kanjiName = setInfoData.kanjiName
                            setData.url = setInfoData.url
                            setData.wiki = setInfoData.wiki
                            setData.family = setInfoData.family
                            setData.features = setInfoData.features
                            setData.info = setInfoData.info
                        }
                    }
                    print("id:\(getPhotoData.id),title:\(getPhotoData.title ?? "nil"),comment:\(getPhotoData.comment ?? "nil")")
                }
                
            } catch {
                print("Failed to fetch photos: \(error)")
            }
        }
    }
    
    
    /// IDを指定して、写真データを取得します
    /// - Parameter id: データを示すID
    /// - Returns:  IDに紐づく写真データが存在する場合は写真データを返す
    func getSetPhotoData(ID id: String) async -> Photo? {
        
        let photo = photos.filter({$0.id == id}).first
        
        if (photo != nil) {
            let url = baseURL.appendingPathComponent("plants").appendingPathComponent(id)
            do {
                let (data, _) = try await URLSession.shared.data(from: url)
                let dto = try JSONDecoder().decode(GetPhotoData.self, from: data)
                let cDate = getCreatedAt(from: dto.createdAt)
                
                photo!.title = dto.self.title

            } catch {
                // DBからデータを取得できないケース
                print("Failed to fetch photo by id: \(error)")
                return nil
            }
        }
        
        return photo
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
    
    /// 写真データを更新します
    /// - Parameter photo: 更新データ
    func updatePhoto(ID id: String, data photo: Photo) {
        
        let url = baseURL.appendingPathComponent("plants").appendingPathComponent(id)
        
        // 日付取得
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        var dateString:String = ""
        if let cDate = photo.creationDate {
            dateString = formatter.string(from: cDate)
        }
            
        let updateData = UpdatePhotoData(id: photo.id,
                                         createdAt: dateString,
                                         title: photo.title,
                                         comment: photo.comment,
                                         category: "")
        
        do {
            var request = URLRequest(url: url)
            request.httpMethod = "PUT"
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            
            let jsonData = try JSONEncoder().encode(updateData)
            request.httpBody = jsonData
            
            Task {
                let (data, response) = try await URLSession.shared.data(for: request)
                //try validate(response: response)

                let decoder = JSONDecoder()
                decoder.dateDecodingStrategy = .iso8601
                _ = try decoder.decode(GetPhotoData.self, from: data)
            }
            
        }
        catch {
            print("Error posting data: \(error)")
        }
    }
    
    /// 写真データを登録します
    /// - Parameter photo: 写真データ
    func insertPhoto(data photo: Photo) {
        
        let url = baseURL.appendingPathComponent("plants")
        
        // 日付取得
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        var dateString:String = ""
        if let cDate = photo.creationDate {
            dateString = formatter.string(from: cDate)
        }
            
        let updateData = UpdatePhotoData(id: photo.id,
                                         createdAt: dateString,
                                         title: photo.title,
                                         comment: photo.comment,
                                         category: "")
        
        do {
            var request = URLRequest(url: url)
            request.httpMethod = "POST"
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            
            let jsonData = try JSONEncoder().encode(updateData)
            request.httpBody = jsonData
            
            Task {
                let (data, response) = try await URLSession.shared.data(for: request)
                //try validate(response: response)

                let decoder = JSONDecoder()
                decoder.dateDecodingStrategy = .iso8601
                _ = try decoder.decode(GetPhotoData.self, from: data)
            }
            
        }
        catch {
            print("Error posting data: \(error)")
        }

    }
}


