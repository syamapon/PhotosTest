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
                            
                            var getPhoto: Photo = Photo(setImage: nil)
                            getPhoto.title = self.inputName
                                                        
                            do {
                                // 設定済みの項目を転記
                                try getPhoto.setData()
                                kanjiName = getPhoto.kanjiName ?? ""
                                inputUrl = getPhoto.url ?? ""
                                aliasName = getPhoto.aliasName ?? ""
                                bloomSeasons = getPhoto.bloomSeasons
                                features = getPhoto.features ?? ""
                                info = getPhoto.info ?? ""
                                wikiPedia = getPhoto.wiki ?? ""
                                family = getPhoto.family ?? ""
                                
                                
                            } catch {
                                print("Error. setData")
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
                Text("特徴（見分けるポイント）")
                    .font(.headline)
                    .frame(maxWidth: .infinity, alignment: .leading)
                TextEditor(text: $features)
                    .frame(maxWidth: .infinity, minHeight: 120, alignment: .leading)
                    .textEditorStyle(.plain)
                    .border(Color.gray)
                
                Text("情報（この植物一般に関する情報）")
                    .font(.headline)
                    .frame(maxWidth: .infinity, alignment: .leading)
                TextEditor(text: $info)
                    .frame(maxWidth: .infinity, minHeight: 120, alignment: .leading)
                    .textEditorStyle(.plain)
                    .border(Color.gray)
                
                Text("コメント（この個体の情報）")
                    .font(.headline)
                    .frame(maxWidth: .infinity, alignment: .leading)
                TextEditor(text: $comment)
                    .frame(maxWidth: .infinity, minHeight: 120, alignment: .leading)
                    .textEditorStyle(.plain)
                    .border(Color.gray)
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
                                        
                    do {
                        //try photo.storeData()
                        
                        Task {
                            let _setPhoto = await photoGet.getSetPhotoData(ID: photo.id)
                            if (_setPhoto != nil) {
                                photoGet.updatePhoto(ID: photo.id, data: photo)
                            }
                            else {
                                photoGet.insertPhoto(data: photo)
                            }
                        }
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

#Preview {
    /*
    EditView(
        /// 写真データ取得
        photoGet: .constant(nil),
        selectPhoto: .constant(nil),
        isShowUpdateDlg: .constant(true)
    )
     */
}
