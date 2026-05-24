//
//  DetailTextGridRow.swift
//  PhotosTest
//
//  Created by shinichirou on 2026/05/24.
//

import SwiftUI

/// テキストタイプの行
struct DetailTextGridRow<Content: View>: View {
    
    /// 項目タイトル
    let itemNm: String
    // 項目タイトル横幅
    let widthNm: CGFloat
    
    // 項目タイトル高さ
    let heightNm: CGFloat
    
    @ViewBuilder let content: () -> Content
    
    var body: some View {
        GridRow {
            Text(itemNm)
                .frame(width:widthNm, height: heightNm, alignment:.leading)
                .padding(2)
            content()
                .frame(maxWidth: .infinity, alignment:.leading)
                .padding(2)
        }
    }
}
#Preview {
    Grid {
        DetailTextGridRow(itemNm: "名前", widthNm: 80, heightNm: 30) { Text("名前") }
    }

}
