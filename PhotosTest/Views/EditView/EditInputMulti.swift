//
//  EditInputMulti.swift
//  PhotosTest
//
//  Created by shinichirou on 2026/05/25.
//

import SwiftUI

struct EditInputMulti: View {
    /// 項目タイトル
    let itemTitle: String
    
    /// 項目値
    @Binding var itemValue: String
    
    var body: some View {
        Text(itemTitle)
            .font(.headline)
            .frame(maxWidth: .infinity, alignment: .leading)
        TextEditor(text: $itemValue)
            .scrollContentBackground(.hidden)
            .padding(6) // 外側パディング
            .background(
                RoundedRectangle(cornerRadius: 4)
                    .fill(Color(.darkGray))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 4)
                    .stroke(Color.gray, lineWidth: 0.5)
            )
            .frame(maxWidth: .infinity, minHeight: 120, alignment: .leading)
            .textEditorStyle(.plain)
            .padding(.trailing, 5)
    }
}

#Preview {
    EditInputMulti(itemTitle: "テスト項目", itemValue: .constant("xxxx"))
}
