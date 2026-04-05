//
//  ContentView.swift
//  PhotosTest
//
//  Created by shinichirou on 2026/01/01.
//

import SwiftUI
import Photos

/// 写真データの一覧表示
struct ContentView: View {
    
    /// 写真データ取得
    @ObservedObject var photoGet : PhotoGet
    
    /// 選択中の写真データ
    @Binding var selectPhoto: Photo?
    
    /// 左端で選択されている項目（カテゴリー）
    let selectedSidebarItem: PlantCategory.Category?
    
    /// 検索文字列
    @State var searchName: String = ""
    
    /// Body
    var body: some View {
        VStack {
            HStack {
                TextField("検索", text: $searchName, prompt: Text("植物の名前を入力してください"))
                Button(action: {searchName = ""}, label: {Text("クリア")})
            }
            List(photos, selection: $selectPhoto) { entry in
                NavigationLink(value: entry) {
                    HStack {
                        PhotoThumbnail(asset: entry.asset, size: .init(width: 50, height: 50))
                        VStack {
                            Text("\(entry.title ?? "")")
                                .frame(maxWidth: .infinity, alignment: .init(horizontal: .leading, vertical: .top))
                            Text(" \(entry.photoDt) 撮影")
                                .frame(maxWidth: .infinity, alignment: .init(horizontal: .leading, vertical: .top))
                        }
                    }
                }
            }
        }
        .padding()
    }
        
    /// 選択されたカテゴリーに従って
    /// 読み込み写真データリストを返す
    private var photos: [Photo] {
        
        var photos: [Photo] = []
                
        if selectedSidebarItem == nil {
            photos = photoGet.photos
        }
        else if selectedSidebarItem == .all  {
            photos = photoGet.photos
        }
        else {
            photos = photoGet.photos.filter({photo in photo.isBelong(selectedSidebarItem!)})
        }
        
        /*
        else {
            photos = photoGet.photos.filter({photo in photo.plantCategory[index!].isBelong})
        }
         */
    
        if searchName != "" {
            photos = photoGet.photos.filter({
                photo in (photo.title ?? "").contains(searchName)
                || (photo.aliasName ?? "").contains(searchName)
                || (photo.kanjiName ?? "").contains(searchName)
            })
        }
        
        return photos
    }
    
}

#Preview {
    ContentView(photoGet: PhotoGet(), selectPhoto: .constant(nil), selectedSidebarItem: .all)
}
