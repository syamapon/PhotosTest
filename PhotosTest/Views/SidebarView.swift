//
//  SidebarView.swift
//  PhotosTest
//
//  Created by shinichirou on 2026/01/10.
//

import SwiftUI

enum SidebarItem: Hashable {
    case all, tree, flower
    
    var title: String {
        switch self {
        case .all: return "全て"
        case .tree: return "木"
        case .flower: return "花"
        }
    }
}

struct SidebarView: View {
    
    @Binding var selection: SidebarItem?
    
    var body: some View {
        List(selection: $selection, content: {
            Section(header: Text("ライブラリ")) {
                NavigationLink(value: SidebarItem.all, label: {Text(SidebarItem.all.title)})
                NavigationLink(value: SidebarItem.tree, label: {Text(SidebarItem.tree.title)})
                NavigationLink(value: SidebarItem.flower, label: {Text(SidebarItem.flower.title)})
            }
        })
    }
}

#Preview {
    //SidebarView()
}
