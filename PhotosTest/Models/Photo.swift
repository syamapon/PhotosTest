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
    
    /// 登録される、テーブルの名前
    let tblName: String = "plantsInToyama"
    
    /// オブジェクトに紐づく写真
    let asset: PHAsset
    
    /// 撮影日
    var creationDate: Date? {
        return asset.creationDate
    }
    
    /// 写真を撮影した緯度
    var locLatitude: CLLocationDegrees? {
        return self.asset.location?.coordinate.latitude
    }
    
    /// 写真を撮影した経度
    var locLongitude: CLLocationDegrees? {
        return self.asset.location?.coordinate.longitude
    }
    
    /// オブジェクトを識別するID
    var id: String {
        guard let creationDate else { return "Empty" }
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ja_JP")
        formatter.dateFormat = "yyyyMMddHHmmss"
        
        return formatter.string(from: creationDate)
    }
    /// 画像タイトル
    var title: String?
    
    /// 別名
    var aliasName: String?
    
    /// 漢字名
    var kanjiName: String?
    
    // WEBサイトURL
    var url: String?
    
    // 登録されているアルバムのタイトル
    var albumTitle: String?
    
    /// 四季
    var bloomSeasons: [BloomSeason] = BloomSeason.GetFourSeasons()
    
    /// 所属カテゴリー
    var plantCategory: [PlantCategory] = PlantCategory.PlantCategories()
    
    /// 特徴
    var features: String?
    
    /// コメント
    var comment: String?
    
    /// 撮影日を文字列を取得
    var photoDt: String {
        guard let creationDate else { return "不明" }
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ja_JP")
        formatter.dateFormat = "yyyy年MM月dd日 HH時mm分"
        
        return formatter.string(from: creationDate)
    }
    
    /// 撮影座標を取得
    var position: MapCameraPosition? {
        guard let locLatitude, let locLongitude else { return nil }
        
        return MapCameraPosition.region(MKCoordinateRegion(
            center: CLLocationCoordinate2D(latitude: locLatitude, longitude: locLongitude), // 東京駅
            span: MKCoordinateSpan(latitudeDelta: 0.02, longitudeDelta: 0.02)))
    }
    
    /// イニシャライザ
    /// - Parameter asset: 写真
    init(setImage asset: PHAsset) {
        
        // 写真データ
        self.asset = asset
                
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
    
    func isBelong(_ category: PlantCategory.Category) -> Bool {
        
        let _category = self.plantCategory.filter( { $0.category == category }).first
        
        if _category?.isBelong ?? false {
            return true
        }
        else {
            return false
        }
    }
    
    /// 写真データを保存
    ///
    func storeData() throws {
        
        let dbPath = try databaseURL().path
        let db = try Connection(dbPath)
        
        let plants = Table(tblName)
        
        let id = Expression<String>("id")
        let title = Expression<String?>("title")
        let aliasName = Expression<String?>("aliasName")
        let kanjiName = Expression<String?>("kanjiName")
        let createdAt = Expression<Date?>("createdAt")
        let url = Expression<String>("url")
        let seasons = Expression<String?>("bloomSeasons")
        let comment = Expression<String?>("comment")
        let features = Expression<String?>("features")
        let category = Expression<String?>("category")
        
        // チェックされている季節を取得
        let _seasons = self.bloomSeasons.filter{$0.isOn}.map{$0.season.name}.joined(separator: ",")
        
        // チェックされているカテゴリーを取得
        let _category = self.plantCategory.filter{$0.isBelong}.map{$0.category.name}.joined(separator: ",")
        
        // 更新
        let target = plants.filter(id == self.id)
        let updated = try db.run(target.update(title <- self.title,
                                               url <- self.url ?? "",
                                               aliasName <- self.aliasName ?? "",
                                               seasons <- _seasons,
                                               comment <- comment,
                                               features <- features,
                                               kanjiName <- kanjiName,
                                               category <- _category))
        if updated == 0 {
            // 未登録であれば、追加する
            let insert = plants.insert(id <- self.id,
                                       title <- self.title,
                                       createdAt <- self.creationDate,
                                       url <- self.url ?? "",
                                       aliasName <- self.aliasName ?? "",
                                       seasons <- _seasons,
                                       comment <- self.comment,
                                       features <- self.features,
                                       kanjiName <- self.kanjiName,
                                       category <- _category)
            try db.run(insert)
        }
        
    }
    
    /// データ設定
    func setData() throws {
        
        let dbPath = try databaseURL().path
        print("dbPath:\(dbPath)")
        
        let db = try Connection(dbPath)
        let plants = Table(tblName)
        
        // Define column expressions in this scope to match the schema
        let id = Expression<String>("id")
        let title = Expression<String>("title")
        let aliasName = Expression<String?>("aliasName")
        let kanjiName = Expression<String?>("kanjiName")
        let createdAt = Expression<Date?>("createdAt")
        let url = Expression<String?>("url")
        let seasons = Expression<String?>("bloomSeasons")
        let comment = Expression<String?>("comment")
        let features = Expression<String?>("features")
        let category = Expression<String?>("category")
        
        // Ensure table exists (matches storePhoto schema)
        try db.run(plants.create(ifNotExists: true) { t in
            t.column(id, primaryKey: true)
            t.column(title)
            t.column(aliasName)
            t.column(kanjiName)
            t.column(createdAt)
            t.column(url)
            t.column(seasons)
            t.column(comment)
            t.column(features)
            t.column(category)
        })
        
        // Build a type-safe filter comparing Expression<String> to String
        let select = plants.filter(id == self.id)
        
        // Example: iterate results (optional)
        for plant in try db.prepare(select) {
            print(plant[id], plant[createdAt] ?? "Not set", plant[title])
        }
        
        if let plant = try db.pluck(select) {
            self.title = plant[title]
            self.aliasName = plant[aliasName]
            self.kanjiName = plant[kanjiName]
            self.url = plant[url]
            self.comment = plant[comment]
            self.features = plant[features]
                        
            if let _seasons = plant[seasons] {
                let _seasonNames: [String] = _seasons.components(separatedBy: ",")
                bloomSeasons.indices.forEach { i in
                    if _seasonNames.contains(bloomSeasons[i].season.name) {
                        bloomSeasons[i].isOn = true
                    }
                }
            }
            
            if let _category = plant[category] {
                let _categoryNames: [String] = _category.components(separatedBy: ",")
                self.plantCategory.indices.forEach { i in
                    if _categoryNames.contains(self.plantCategory[i].category.name) {
                        self.plantCategory[i].isBelong = true
                    }
                }
            }
        }
    }
}

/// 所属カテゴリー
struct PlantCategory: Identifiable {
    
    /// ID
    let id = UUID()
    
    /// カテゴリー
    let category: Category
    
    /// 所属している時はtrue
    var isBelong: Bool = false
    
    /// 所属植物のリスト（の初期値）を返す
    /// - Returns: 所属植物リスト
    static func PlantCategories () -> [PlantCategory] {
        
        var plantCategories: [PlantCategory] = []
        for category in PlantCategory.Category.allCases {
            plantCategories.append(PlantCategory(category: category))
        }
        return plantCategories
    }
    
    /// 植物の種類
    enum Category: CaseIterable {
        case all, fruit, flower, tree, vegitable, herb, grass
        
        var index: Int {
            switch self {
            case .all: return 0
            case .fruit: return 1
            case .flower: return 2
            case .tree: return 3
            case .vegitable: return 4
            case .herb: return 5
            case .grass: return 6
            }
        }
        var name: String {
            switch self {
            case .all: return "全て"
            case .fruit: return "果物"
            case .flower: return "花"
            case .tree: return "木"
            case .vegitable: return "野菜"
            case .herb: return "ハーブ"
            case .grass: return "草"
            }
        }
    }
    
    
}

/// 開花時期
struct BloomSeason: Identifiable {
    
    /// ID
    let id = UUID()
    
    /// 四季
    let season: Season
    
    /// 開花時期の場合はtrue
    var isOn: Bool = false
    
    /// 開花時期の配列を取得
    /// - Returns:  開花時期の配列
    static func GetFourSeasons () -> [BloomSeason] {
        
        var seasons: [BloomSeason] = []
        for season in BloomSeason.Season.allCases {
            seasons.append(BloomSeason(season: season, isOn: false))
        }
        return seasons
    }
    
    /// 四季
    enum Season: CaseIterable {
        case spring, summer, fall, winter
        
        var name: String {
            switch self {
            case .spring: return "春"
            case .summer: return "夏"
            case .fall: return "秋"
            case .winter: return "冬"
            }
        }
    }
}

