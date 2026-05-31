//
//  DetailTextGrid.swift
//  PhotosTest
//
//  Created by shinichirou on 2026/05/31.
//

import SwiftUI

struct DetailTextGrid: View {
    
    /// 選択中の写真データ
    let selectPhoto : Photo?
    
    /// １行項目高さ
    private let HEIGHT_NORMAL: CGFloat = 12
    
    /// 複数行項目高さ
    private let HEIGHT_LONG: CGFloat = 60
    
    var body: some View {
        Grid {
            DetailTextGridRow(itemNm: "名前（かな）", widthNm: 100, heightNm: HEIGHT_NORMAL) {
                Text(self.selectPhoto?.title ?? "") }
            DetailTextGridRow(itemNm: "名前（漢字）", widthNm: 100, heightNm: HEIGHT_NORMAL) { Text(self.selectPhoto?.kanjiName ?? "") }
            DetailTextGridRow(itemNm: "別名", widthNm: 100, heightNm: HEIGHT_NORMAL) {
                Text(self.selectPhoto?.aliasName ?? "") }
            DetailTextGridRow(itemNm: "撮影日", widthNm: 100, heightNm: HEIGHT_NORMAL) {
                Text(self.selectPhoto?.photoDt ?? "") }
            DetailTextGridRow(itemNm: "科", widthNm: 100, heightNm: HEIGHT_NORMAL) {
                Text(self.selectPhoto?.family ?? "") }
            DetailTextGridRow(itemNm: "サイト", widthNm: 100, heightNm: HEIGHT_NORMAL) {
                if let url = self.selectPhoto?.url {
                    if (!url.isEmpty) {
                        Link("URL", destination: URL(string:url)!)
                    }
                    else {
                        Text("未設定")
                    }
                }
                else {
                    Text("未設定")
                }
            }
            DetailTextGridRow(itemNm: "WIKI", widthNm: 100, heightNm: HEIGHT_NORMAL) {
                if let wiki = self.selectPhoto?.wiki {
                    if (!wiki.isEmpty) {
                        Link("wikipedia", destination: URL(string:wiki)!)
                    }
                    else {
                        Text("未設定")
                    }
                }
                else {
                    Text("未設定")
                }
            }
            DetailTextGridRow(itemNm: "開花季節", widthNm: 100, heightNm: HEIGHT_NORMAL) {
                HStack {
                    if let _bloomSeasons = self.selectPhoto?.bloomSeasons {
                        ForEach(_bloomSeasons) {
                            season in if (season.isOn) {Text(season.season.name)}
                        }
                    }
                }
            }
            DetailTextGridRow(itemNm: "種別", widthNm: 100, heightNm: HEIGHT_NORMAL) {
                HStack {
                    if let _plantCategory = self.selectPhoto?.plantCategory {
                        ForEach(_plantCategory) {
                            category in if (category.isBelong) {Text(category.category.name)}
                        }
                    }
                }
            }
            DetailTextGridRow(itemNm: "特徴", widthNm: 100, heightNm: HEIGHT_LONG) {
                Text(self.selectPhoto?.features ?? "") }
            DetailTextGridRow(itemNm: "情報", widthNm: 100, heightNm: HEIGHT_LONG) {
                Text(self.selectPhoto?.info ?? "") }
            DetailTextGridRow(itemNm: "コメント", widthNm: 100, heightNm: HEIGHT_LONG) {
                Text(self.selectPhoto?.comment ?? "") }
        }
    }
}

#Preview {
    DetailTextGrid(selectPhoto: nil)
}
