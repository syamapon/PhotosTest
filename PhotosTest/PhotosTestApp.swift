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
    
    @State var selection: Photo.ID?
    @State private var selectedSidebarItem: SidebarItem? = nil
    
    var body: some Scene {
        WindowGroup {
            NavigationSplitView {
                SidebarView(selection: $selectedSidebarItem)
            } content: {
                //ContentView(selection: $selection)
                //ContentView(selection: $selection, selectedSidebarItem: selectedSidebarItem)
                ContentView(photoGet: photoGet, selection: $selection, selectedSidebarItem: selectedSidebarItem)
            } detail :{
                
            }
            
            
        }
    }
}
