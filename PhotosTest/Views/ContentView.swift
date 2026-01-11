//
//  ContentView.swift
//  PhotosTest
//
//  Created by shinichirou on 2026/01/01.
//

import SwiftUI
import Photos

struct ContentView: View {
    
    @StateObject private var photoGet = PhotoGet()
    @Binding var selection: Photo.ID?
    let selectedSidebarItem: SidebarItem?
    
    private var photos: [Photo] {
        
        switch selectedSidebarItem {
        case .all:
            return photoGet.photos
        case .recents:
            let l_photos = photoGet.photos.filter({photo in
                if photo.creationDate == nil {
                    return false
                }
                else {
                    return photo.creationDate! > Calendar.current.date(byAdding: .month, value: -6, to: Date()) ?? Date()
                }
            })
            return l_photos
        case .favorites:
            return photoGet.photos
        case nil:
            return photoGet.photos
        }
    }
    
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
}

#Preview {
    //ContentView(selection: )
}
