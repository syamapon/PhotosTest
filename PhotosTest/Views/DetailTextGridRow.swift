//
//  DetailTextGridRow.swift
//  PhotosTest
//
//  Created by shinichirou on 2026/05/24.
//

import SwiftUI

/// テキストタイプの行
struct DetailTextGridRow: View {
    
    /// 項目タイトル
    let itemNm: String
    
    /// 項目値
    let itemVal: String?
    
    // 項目タイトル横幅
    let widthNm: CGFloat
    
    var body: some View {
        GridRow {
            Text(itemNm)
                .frame(width:widthNm, alignment:.leading)
                .padding(2)
            Text("\(itemVal ?? "")")
                .frame(maxWidth: .infinity, alignment:.leading)
                .padding(2)
        }
    }
}
#Preview {
    Grid {
        DetailTextGridRow(itemNm: "名前", itemVal: "オーチャードグラス", widthNm: 80)
    }

}
