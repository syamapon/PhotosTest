//
//  SidebarView.swift
//  PhotosTest
//
//  Created by shinichirou on 2026/01/10.
//

import SwiftUI

enum SidebarItem: Hashable {
    case all, recents, favorites
    
    var title: String {
        switch self {
        case .all: return "全て"
        case .recents: return "最近"
        case .favorites: return "お気に入り"
        }
    }
    
}

struct SidebarView: View {
    
    @Binding var selection: SidebarItem?
    
    var body: some View {
        List(selection: $selection, content: {
            Section(header: Text("ライブラリ")) {
                NavigationLink(value: SidebarItem.all, label: {Text(SidebarItem.all.title)})
                NavigationLink(value: SidebarItem.recents, label: {Text(SidebarItem.recents.title)})
                NavigationLink(value: SidebarItem.favorites, label: {Text(SidebarItem.favorites.title)})
            }
        })
    }
}

#Preview {
    //SidebarView()
}
