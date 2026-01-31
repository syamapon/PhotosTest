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

struct Photo: Identifiable, Hashable {
    
    // ID
    var id: String {
        guard let creationDate else { return "Empty" }
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ja_JP")
        formatter.dateFormat = "yyyyMMddHHmmss"
        
        return formatter.string(from: creationDate)
    }
    var image: Image?
    
    // 画像タイトル
    var title: String
    
    // 撮影日
    var creationDate: Date?
    
    // イメージ
    var asset: PHAsset?
    
    // 緯度
    var locLatitude: CLLocationDegrees?
    
    // 経度
    var locLongitude: CLLocationDegrees?
    
    // WEBサイトURL
    var url: String?
    
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
        
    static func == (lhs: Photo, rhs: Photo) -> Bool {
        lhs.id == rhs.id
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    init(title: String, asset: PHAsset?) {
        self.title = title
        self.asset = asset
        
        do {
            try setData()
        } catch {
            print("ERROR")
        }
        

    }
    
    // Dataの保存先のパスをURLで取得
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
    
    // 写真データを保存
    mutating func storePhoto() throws {

        let dbPath = try databaseURL().path
        let db = try Connection(dbPath)
        
        let plants = Table("plants")
        
        let id = Expression<String>("id")
        let createdAt = Expression<Date?>("createdAt")
        let title = Expression<String>("title")
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
        

        
        do {
            try self.setData()
        }
        catch {
            print("ERROR")
        }

        
        /*
        for plant in try db.prepare(plants) {
            print(plant[id], plant[createdAt], plant[title])
        }
         */
        
        /*
        let select = plants.filter(id == self.id)
        for plant in try db.prepare(select) {
            print(plant[id], plant[createdAt], plant[title])
        }
         */
        
    }
    
    mutating func setData() throws {
        
        let dbPath = try databaseURL().path
        let db = try Connection(dbPath)
        let plants = Table("plants")

        // Define column expressions in this scope to match the schema
        let id = Expression<String>("id")
        let createdAt = Expression<Date?>("createdAt")
        let title = Expression<String>("title")
        let url = Expression<String?>("url")

        // Ensure table exists (matches storePhoto schema)
        try db.run(plants.create(ifNotExists: true) { t in
            t.column(id, primaryKey: true)
            t.column(createdAt)
            t.column(title, unique: true)
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
        
        print("title: \(self.title)")
    }
    
    
}

