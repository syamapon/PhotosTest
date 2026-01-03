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
    
    init(title: String, asset: PHAsset?) {
        self.title = title
        self.asset = asset
    }
}
