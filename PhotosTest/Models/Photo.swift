//
//  Photo.swift
//  PhotosTest
//
//  Created by shinichirou on 2026/01/02.
//

import SwiftUI
import Photos

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
    var title: String
    var creationDate: Date?
    var asset: PHAsset?
    
    var photoDt: String {
        guard let creationDate else { return "不明" }
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ja_JP")
        formatter.dateFormat = "yyyy年MM月dd日 HH時mm分"
        
        return formatter.string(from: creationDate)
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
        
        // 更新
        let target = plants.filter(id == self.id)
        let updated = try db.run(target.update(title <- self.title))
        if updated == 0 {
            // 未登録であれば、追加する
            let insert = plants.insert(id <- self.id, title <- self.title, createdAt <- self.creationDate)
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

        // Ensure table exists (matches storePhoto schema)
        try db.run(plants.create(ifNotExists: true) { t in
            t.column(id, primaryKey: true)
            t.column(createdAt)
            t.column(title, unique: true)
        })

        // Build a type-safe filter comparing Expression<String> to String
        let select = plants.filter(id == self.id)

        // Example: iterate results (optional)
        for plant in try db.prepare(select) {
            print(plant[id], plant[createdAt], plant[title])
        }
        
        if let plant = try db.pluck(select) {
            self.creationDate = plant[createdAt]!
            self.title = plant[title]
        }
        
        print("title: \(self.title)")
    }
    
    
}

