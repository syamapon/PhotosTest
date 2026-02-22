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
    
    // 写真データ取得
    @ObservedObject var photoGet : PhotoGet
  
    // 検索文字列
    @State var searchName: String = ""
    
    // 左端で選択されている項目
    let selectedSidebarItem: SidebarItem?
    
    // 選択中の写真データ
    @Binding var selectPhoto: Photo?
    
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
                            Text("タイトル:\(entry.title ?? "")")
                            Text("撮影日: \(entry.photoDt)")
                        }
                    }
                }
            }
        }
        .padding()
    }
        
    /// 読み込み写真データリスト
    private var photos: [Photo] {
        
        var photos: [Photo] = photoGet.photos
        
        switch selectedSidebarItem {
        case .all, nil:
            var seen = Set<Photo>()
            // 重複除去
            photos = photos.filter({photo in seen.insert(photo).inserted})
        case .tree:
            // 木
            photos = photos.filter({photo in isAlbum(albumTitle: "木", photo)})
        case .flower:
            // 花
            photos = photos.filter({photo in isAlbum(albumTitle: "花", photo)})
        }
        
        if searchName != "" {
            //photos = photos.filter({$0.title.contains(searchName)})
            photos = photos.filter({photo in (photo.title ?? "").contains(searchName)})
        }
        
        return photos
    }
    
    /// 写真データがアルバムに属している時、trueを返す
    /// - Parameters:
    ///   - title: アルバムのタイトル
    ///   - photo: 写真データ
    /// - Returns: 写真データがアルバムに属している時、true
    private func isAlbum(albumTitle title: String, _ photo : Photo) -> Bool {
        
        if photo.albumTitle == title {
            return true
        }
        else {
            return false
        }
    }
}

#Preview {
    //ContentView(selection: )
}
