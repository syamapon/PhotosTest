//
//  Photo.swift
//  PhotosTest
//
//  Created by shinichirou on 2026/01/02.
//

import SwiftUI
import Photos

import SQLite

struct Photo: Identifiable {
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
    
    
    init(title: String, asset: PHAsset?) {
        self.title = title
        self.asset = asset
        
        do {
            try setData()
        } catch {
            print("ERROR")
        }
        

    }
    
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
        
        //let db = try Connection("/Users/shinichirou/tmp/plants.sqlite")
        let plants = Table("plants")
        let id = Expression<String>("id")
        let createdAt = Expression<Date?>("createdAt")
        let title = Expression<String>("title")
        
        try db.run(plants.create(ifNotExists: true) { t in
            t.column(id, primaryKey: true)
            t.column(createdAt)
            t.column(title, unique: true)
        })
        
        /*
        guard let creationDate else { return }
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ja_JP")
        formatter.dateFormat = "yyyyMMddHHmmss"
        self.id = formatter.string(from: creationDate)
        */
        
        let insert = plants.insert(id <- self.id, title <- self.title, createdAt <- self.creationDate)
        
        do {
            try db.run(insert)
            print("Insert OK")
        } catch {
            print("Insert failed:", error)
            throw error
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
        
        print("title: \(self.title ?? "nil")")
    }
    
    
}

