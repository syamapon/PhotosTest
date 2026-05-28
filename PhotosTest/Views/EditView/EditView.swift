//
//  EditView.swift
//  PhotosTest
//
//  Created by shinichirou on 2026/01/30.
//

import SwiftUI


/// 入力画面
struct EditView: View {
    
    /// 写真データ取得
    @ObservedObject var photoGet : PhotoGet
    
    @Binding var selectPhoto: Photo?
    
    @Binding var isShowUpdateDlg: Bool
    
    
    /// タイトル入力
    @State private var inputName: String = ""
    @FocusState private var isInputNameFocused: Bool
    
    /// 別名入力
    @State private var aliasName: String = ""
    
    /// 漢字名入力
    @State private var kanjiName: String = ""
    
    /// 科
    @State private var family: String = ""
    
    /// URL入力
    @State private var inputUrl: String = ""
    
    /// WIKIPEDIA URL
    @State private var wikiPedia: String = ""
    
    /// 説明入力
    @State private var comment: String = ""
    
    /// 特徴入力
    @State private var features: String = ""
    
    /// 情報入力
    @State private var info: String = ""
    
    /// 開花時期入力
    @State private var bloomSeasons: [BloomSeason] = BloomSeason.GetFourSeasons()
    
    /// カテゴリー入力
    @State private var plantCategory: [PlantCategory] = PlantCategory.PlantCategories()
    
    var body: some View {
        Form {
            Section() {
                TextField("名前（カナ）", text: $inputName, prompt: Text("名前（カナ）を入力してください")).padding(5)
                    .focused($isInputNameFocused)
                    .onChange(of: isInputNameFocused) { focused in
                        if focused == false {
                            // フォーカスが外れたタイミングで行いたい処理
                            //validateName()
                            print("kana input2.")
                            
                            
                            Task {
                                var getPlantInfo = await photoGet.getPlantInfo(title: self.inputName)
                                if let gPinf = getPlantInfo {
                                    self.kanjiName = gPinf.kanjiName ?? ""
                                    self.aliasName = gPinf.aliasName ?? ""
                                    if let bSeanson = gPinf.bloomSeasons {
                                        var _seansons = bSeanson.split(separator: ",").map{String($0)}
                                        self.bloomSeasons.indices.forEach { i in
                                            if _seansons.contains(self.bloomSeasons[i].season.name) {
                                                self.bloomSeasons[i].isOn = true
                                            }
                                        }
                                    }
                                    
                                    //self.bloomSeasons = gPinf.bloomSeansons
                                    self.inputUrl = gPinf.url ?? ""
                                    self.wikiPedia = gPinf.wiki ?? ""
                                    self.features = gPinf.features ?? ""
                                    self.info = gPinf.info ?? ""
                                    self.family = gPinf.family ?? ""
                                }
                                
                            }
                            
                        }
                    }
                TextField("名前（漢字）", text: $kanjiName, prompt: Text("名前（漢字）を入力してください"))
                TextField("別名", text: $aliasName, prompt: Text("別名を入力してください"))
                TextField("URL", text: $inputUrl, prompt: Text("URLを入力してください"))
                TextField("wikipedia", text: $wikiPedia, prompt: Text("WikiPedia URLを入力してください"))
                TextField("科", text: $family, prompt: Text("科を入力してください"))
                
                LabeledContent("開花時期") {
                    HStack {
                        ForEach($bloomSeasons) {
                            $bloomSeason in
                            Toggle(bloomSeason.season.name, isOn:$bloomSeason.isOn).toggleStyle(.button)
                                .padding(.leading, 5)
                        }
                    }
                }
                
                LabeledContent("カテゴリー") {
                    HStack {
                        ForEach($plantCategory) {
                            $category in
                            Toggle(category.category.name, isOn: $category.isBelong)
                                .toggleStyle(.button)
                                .padding(.leading, 5)
                        }
                    }
                }
                
            }.padding(5)
            Section {
                EditInputMulti(itemTitle: "特徴（見分けるポイント）", itemValue: $features)
                    .padding(.trailing, 10)
                EditInputMulti(itemTitle: "情報（この植物一般に関する情報）", itemValue: $info)
                    .padding(.trailing, 10)
                EditInputMulti(itemTitle: "コメント（この個体の情報）", itemValue: $comment)
                    .padding(.trailing, 10)
                
                //InputTextEdit(itemTitle: "特徴（見分けるポイント）", itemValue: $features)
                //InputTextEdit(itemTitle: "情報（この植物一般に関する情報）", itemValue: $info)
                //InputTextEdit(itemTitle: "コメント（この個体の情報）", itemValue: $comment)
            }
        }
        .toolbar {
            ToolbarItem(placement: .confirmationAction, content: {
                Button(action: {
                    // 保存ボタンの押下
                    guard let photo = selectPhoto else {
                        return
                    }
                    photo.title = inputName
                    photo.kanjiName = kanjiName
                    photo.url = inputUrl
                    photo.aliasName = aliasName
                    photo.bloomSeasons = bloomSeasons
                    photo.features = features
                    photo.comment = comment
                    photo.info = info
                    photo.plantCategory = plantCategory
                    photo.wiki = wikiPedia
                    photo.family = family
                    
                    // DB登録
                    do {
                        photoGet.updatePhoto(data: photo)
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
                wikiPedia = photo.wiki ?? ""
                aliasName = photo.aliasName ?? ""
                kanjiName = photo.kanjiName ?? ""
                features = photo.features ?? ""
                comment = photo.comment ?? ""
                
                for category in photo.plantCategory where category.isBelong {
                    if let idx = self.plantCategory.firstIndex(where: { $0.category.name == category.category.name }) {
                        self.plantCategory[idx].isBelong = true
                    }
                }
                
                for season in photo.bloomSeasons where season.isOn {
                    if let idx = self.bloomSeasons.firstIndex(where: { $0.season.name == season.season.name }) {
                        self.bloomSeasons[idx].isOn = true
                    }
                }
                
            }
        }
    }
}

/// 複数行の入力項目
struct InputTextEdit: View {
    
    /// 項目タイトル
    let itemTitle: String
    
    /// 項目値
    @Binding var itemValue: String
    
    var body: some View {
        Text(itemTitle)
            .font(.headline)
            .frame(maxWidth: .infinity, alignment: .leading)
        TextEditor(text: $itemValue)
            .frame(maxWidth: .infinity, minHeight: 120, alignment: .leading)
            .textEditorStyle(.plain)
            .border(Color.gray)
    }
}

#Preview {
    /*
    struct Demo: View {
        
        private var photoGet = PhotoGet()
        
        @State private var showUpDlg = false
        
        var body: some View {
            EditView(photoGet: photoGet,
                     selectPhoto: .constant(nil),
                     isShowUpdateDlg: $showUpDlg)
            .frame(width: 700, height: 800)
        }
    }
    return Demo()
     */
    EditView(photoGet: PhotoGet(),
             selectPhoto: .constant(nil),
             isShowUpdateDlg: .constant(false))
    .frame(width: 700, height: 800)
}
