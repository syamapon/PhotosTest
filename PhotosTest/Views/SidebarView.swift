//
//  SidebarView.swift
//  PhotosTest
//
//  Created by shinichirou on 2026/01/10.
//

import SwiftUI

struct SidebarView: View {
        
    /// 選択されている大分類
    @Binding var selectedSidebarItem: PlantCategory.Category?
    
    var body: some View {
        List(selection: $selectedSidebarItem, content: {
            Section(header: Text("ライブラリ")) {
                ForEach(PlantCategory.Category.allCases, id: \.self) { category in
                    NavigationLink(value: category, label: {Text(category.name)})
                }
            }
        })
    }
}

#Preview {
    //SidebarView()
}
