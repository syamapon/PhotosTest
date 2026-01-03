//
//  Photo.swift
//  PhotosTest
//
//  Created by shinichirou on 2026/01/02.
//

import SwiftUI
import Photos

struct Photo: Identifiable {
    var id: UUID = UUID()
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
    }
    
    
}
