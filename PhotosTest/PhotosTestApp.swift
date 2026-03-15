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
    @State private var selectedSidebarItem: PlantCategory.Category? = nil
    
    @State var selectPhoto: Photo?
    
    var body: some Scene {
        WindowGroup {
            NavigationSplitView {
                SidebarView(selectedSidebarItem: $selectedSidebarItem)
                //SidebarView()
            } content: {
                ContentView(photoGet: photoGet, selectPhoto: $selectPhoto, selectedSidebarItem: selectedSidebarItem)
            } detail :{
                DetailView(photoGet: photoGet, selectPhoto: $selectPhoto)
            }
        }
    }
}

