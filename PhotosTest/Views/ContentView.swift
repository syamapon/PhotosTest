//
//  ContentView.swift
//  PhotosTest
//
//  Created by shinichirou on 2026/01/01.
//

import SwiftUI
import Photos

struct ContentView: View {
    
    var photoGet : PhotoGet
    @Binding var selection: Photo.ID?
    
    let selectedSidebarItem: SidebarItem?
    
    var body: some View {
        VStack {
            List(photos, selection: $selection) { entry in
                NavigationLink(value: entry.id) {
                    HStack {
                        if let asset = entry.asset {
                            PhotoThumbnail(asset: asset)
                        }
                        Text("撮影日: \(entry.photoDt)")
                        
                    }
                }
            }
            
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
        
        switch selectedSidebarItem {
        case .all:
            return photoGet.photos
        case .recents:
            print("recents")
            return photoGet.photos.filter({photo in
                if let creationDate = photo.creationDate {
                    if let todayBefore6Month = Calendar.current.date(byAdding: .month, value: -6, to: Date()) {
                        return creationDate > todayBefore6Month
                    }
                }
                return false
            })
        case .favorites:
            print("favorites")
            return photoGet.photos
        case nil:
            return photoGet.photos
        }
    }
}

#Preview {
    //ContentView(selection: )
}
