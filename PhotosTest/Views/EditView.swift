//
//  EditView.swift
//  PhotosTest
//
//  Created by shinichirou on 2026/01/30.
//

import SwiftUI

/// Ω
struct EditView: View {
    
    @Binding var selectPhoto: Photo?
    
    @Binding var isShowUpdateDlg: Bool
    
    
    /// タイトル入力
    @State private var inputName: String = ""
        
    /// 別名
    @State private var aliasName: String = ""
    
    /// URL入力
    @State private var inputUrl: String = ""
    
    /// 説明
    @State private var info: String = ""
    
    /// 開花時期
    @State private var bloomSeasons: [BloomSeason] = BloomSeason.GetFourSeasons()
    
    var body: some View {
        Form {
            Section {
                TextField("名前", text: $inputName, prompt: Text("名前を入力してください")).padding(5)
                TextField("別名", text: $aliasName, prompt: Text("別名を入力してください"))
                TextField("URL", text: $inputUrl, prompt: Text("URLを入力してください"))

            }.padding(5)
            Section(header: Text("開花時期")) {
                HStack {
                    ForEach($bloomSeasons) {
                        $bloomSeason in
                        Toggle(bloomSeason.season.name, isOn:$bloomSeason.isOn).padding(.leading, 5)
                    }
                }
            }.padding(5)
            Section(header: Text("説明")) {
                TextEditor(text: $info).frame(height: 80).border(Color.gray)
            }.padding(5)
        }
        .toolbar {
            ToolbarItem(placement: .confirmationAction, content: {
                Button(action: {
                    // 保存ボタンの押下
                    guard let photo = selectPhoto else {
                        return
                    }
                    photo.title = inputName
                    photo.url = inputUrl
                    photo.aliasName = aliasName
                    photo.bloomSeasons = bloomSeasons
                                        
                    do {
                        try photo.storePhoto()
                    }
                    catch {
                        print("Error saving photo: \(error.localizedDescription)")
                    }
                    
                    isShowUpdateDlg = false
                }, label: {Text("保存")})
            })
            
            ToolbarItem(placement: .cancellationAction, content: {
                Button(action: {isShowUpdateDlg = false}, label: {
                    Text("キャンセル")})
            })
        }
        .onAppear {
            if let photo = self.selectPhoto {
                inputName = photo.title ?? ""
                inputUrl = photo.url ?? ""
                aliasName = photo.aliasName ?? ""
                for season in photo.bloomSeasons where season.isOn {
                    if let idx = self.bloomSeasons.firstIndex(where: { $0.season.name == season.season.name }) {
                        self.bloomSeasons[idx].isOn = true
                    }
                }
            }
        }
    }
}

#Preview {
    //EditView(selectPhoto: .constant(nil))
}
