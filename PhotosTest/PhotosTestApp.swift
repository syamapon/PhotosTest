//
//  PhotosTestApp.swift
//  PhotosTest
//
//  Created by shinichirou on 2026/01/01.
//

import SwiftUI

@main
struct PhotosTestApp: App {
    
    
    /// 写真アクセスクラス
    @StateObject private var photoGet = PhotoGet()
    
    /// 左端で選択されている項目
    @State private var selectedSidebarItem: PlantCategory.Category? = nil
    
    /// 選択されている写真
    @State var selectPhoto: Photo? = nil
    
    var body: some Scene {
        WindowGroup {
            NavigationSplitView {
                SidebarView(selectedSidebarItem: $selectedSidebarItem)
            } content: {
                ContentView(photoGet: photoGet, selectPhoto: $selectPhoto, selectedSidebarItem: selectedSidebarItem)
            } detail :{
                DetailView(photoGet: photoGet, selectPhoto: $selectPhoto)
            }
        }
    }
}

