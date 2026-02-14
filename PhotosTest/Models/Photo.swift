//
//  Photo.swift
//  PhotosTest
//
//  Created by shinichirou on 2026/01/02.
//

import SwiftUI
import Photos
import MapKit

import SQLite

class Photo: Identifiable, Hashable {
    
    // ID
    var id: String {
        guard let creationDate else { return "Empty" }
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ja_JP")
        formatter.dateFormat = "yyyyMMddHHmmss"
        
        return formatter.string(from: creationDate)
    }
    // 画像タイトル
    var title: String?
    
    // 別名
    var alias: String?
    
    // 開花時期
    var bloomTime: String?
    
    // 撮影日
    var creationDate: Date?
    
    // 写真
    let asset: PHAsset
    
    // 緯度
    var locLatitude: CLLocationDegrees?
    
    // 経度
    var locLongitude: CLLocationDegrees?
    
    // WEBサイトURL
    var url: String?
    
    // 登録されているアルバムのタイトル
    var albumTitle: String?
    
    // 登録される、テーブルの名前
    let tblName: String = "plantsInToyama"
    
    // 撮影日を文字列を取得
    var photoDt: String {
        guard let creationDate else { return "不明" }
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ja_JP")
        formatter.dateFormat = "yyyy年MM月dd日 HH時mm分"
        
        return formatter.string(from: creationDate)
    }
    
    // 撮影座標を取得
    var position: MapCameraPosition? {
        guard let locLatitude, let locLongitude else { return nil }
        
        return MapCameraPosition.region(MKCoordinateRegion(
            center: CLLocationCoordinate2D(latitude: locLatitude, longitude: locLongitude), // 東京駅
            span: MKCoordinateSpan(latitudeDelta: 0.02, longitudeDelta: 0.02)))
    }
            
    /// イニシャライザ
    /// - parameter setImage    Mac上の写真
    init(setImage asset: PHAsset) {
        
        // 写真データ
        self.asset = asset
        
        // 作成日
        self.creationDate = asset.creationDate

        // 位置情報を設定
        self.locLatitude = asset.location?.coordinate.latitude
        self.locLongitude = asset.location?.coordinate.longitude
    }
    
    static func == (lhs: Photo, rhs: Photo) -> Bool {
        lhs.id == rhs.id
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    /// Dataの保存先のパスをURLで取得
    /// - returns:Data保存先ファイルのパス
    func databaseURL() throws -> URL {
        let fm = FileManager.default
        let appSupport = try fm.url(
            for: .applicationSupportDirectory,
            in: .userDomainMask,
            appropriateFor: nil,
            create: true
        )
        // App Support 配下にアプリ用のサブディレクトリを作るのも良い
        let dir = appSupport.appendingPathComponent("Database", isDirectory: true)
        if !fm.fileExists(atPath: dir.path) {
            try fm.createDirectory(at: dir, withIntermediateDirectories: true)
        }
        return dir.appendingPathComponent("plants.sqlite")
    }
    
    /// 写真データを保存
    ///
    func storePhoto() throws {

        let dbPath = try databaseURL().path
        let db = try Connection(dbPath)
        
        let plants = Table(tblName)
        
        let id = Expression<String>("id")
        let createdAt = Expression<Date?>("createdAt")
        let title = Expression<String?>("title")
        let url = Expression<String>("url")
        
        // 更新
        let target = plants.filter(id == self.id)
        let updated = try db.run(target.update(title <- self.title,
                                           url <- self.url ?? ""))
        if updated == 0 {
            // 未登録であれば、追加する
            let insert = plants.insert(id <- self.id,
                                    title <- self.title,
                                    createdAt <- self.creationDate,
                                    url <- self.url ?? "")
            try db.run(insert)
        }
        
        //try self.setData()
    }
    
    /// データ設定処理
    /// 
     func setData() throws {
        
        let dbPath = try databaseURL().path
        let db = try Connection(dbPath)
        let plants = Table(tblName)

        // Define column expressions in this scope to match the schema
        let id = Expression<String>("id")
        let createdAt = Expression<Date?>("createdAt")
        let title = Expression<String>("title")
        let url = Expression<String?>("url")

        // Ensure table exists (matches storePhoto schema)
        try db.run(plants.create(ifNotExists: true) { t in
            t.column(id, primaryKey: true)
            t.column(createdAt)
            t.column(title)
            t.column(url)
        })

        // Build a type-safe filter comparing Expression<String> to String
        let select = plants.filter(id == self.id)

        // Example: iterate results (optional)
        for plant in try db.prepare(select) {
            print(plant[id], plant[createdAt] ?? "Not set", plant[title])
        }
        
        if let plant = try db.pluck(select) {
            self.creationDate = plant[createdAt]!
            self.title = plant[title]
            self.url = plant[url]
        }
    }
}

