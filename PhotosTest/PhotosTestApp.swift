//
//  PhotosTestApp.swift
//  PhotosTest
//
//  Created by shinichirou on 2026/01/01.
//

import SwiftUI

@main
struct PhotosTestApp: App {
    
    @StateObject private var photoGet = PhotoGet()
    
    // 選択されている写真ID
    @State var selectPhotoID: Photo.ID?
    
    // 左端で選択されている項目
    @State private var selectedSidebarItem: SidebarItem? = nil
    
    @State var selectPhoto: Photo?
    
    var body: some Scene {
        WindowGroup {
            NavigationSplitView {
                SidebarView(selection: $selectedSidebarItem)
            } content: {
                //ContentView(selection: $selection)
                //ContentView(selection: $selection, selectedSidebarItem: selectedSidebarItem)
                ContentView(photoGet: photoGet, selection: $selectPhotoID, selectedSidebarItem: selectedSidebarItem, selectPhoto: $selectPhoto)
            } detail :{
                //DetailView(selection: selectPhotoID)
                //DetailView(photoGet: photoGet, selection: selectPhotoID, selectPhoto: $selectPhoto)
                DetailView(selection: $selectPhotoID, photoGet: photoGet, selectPhoto: $selectPhoto)
            }
        }
    }
}

