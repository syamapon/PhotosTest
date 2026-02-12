//
//  ContentView.swift
//  PhotosTest
//
//  Created by shinichirou on 2026/01/01.
//

import SwiftUI
import Photos

struct ContentView: View {
    
    @ObservedObject var photoGet : PhotoGet
    @Binding var selection: Photo.ID?
    
    @State var searchName: String = ""
    
    // 左端で選択されている項目
    let selectedSidebarItem: SidebarItem?
    
    @Binding var selectPhoto: Photo?
    
    var body: some View {
        VStack {
            HStack {
                TextField("検索", text: $searchName, prompt: Text("植物の名前を入力してください"))
                Button(action: {searchName = ""}, label: {Text("クリア")})
            }
            List(photos, selection: $selectPhoto) { entry in
                NavigationLink(value: entry) {
                    //Text(entry.title)
                    HStack {
                        if let asset = entry.asset {
                            PhotoThumbnail(asset: asset)
                        }
                        VStack {
                            Text("タイトル:\(entry.title)")
                            Text("撮影日: \(entry.photoDt)")
                        }
                    }
                }
            }
            /*
            List(photos, selection: $selection) { entry in
                NavigationLink(value: entry.id) {
                    HStack {
                        if let asset = entry.asset {
                            PhotoThumbnail(asset: asset)
                        }
                        VStack {
                            Text("タイトル:\(entry.title)")
                            Text("撮影日: \(entry.photoDt)")
                        }
                    }
                }
            }
             */
            
            /*
             List(photoGet.photos) { entry in
             NavigationLink(value: entry.id) {
             HStack {
             
             if let asset = entry.asset {
             PhotoThumbnail(asset: asset)
             }
             Text("撮影日: \(entry.photoDt)")
             
             }
             }
             }
             */
        }
        .padding()
    }
        
    
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
            photos = photos.filter({$0.title.contains(searchName)})
        }
        
        return photos
    }
    
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
