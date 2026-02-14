//
//  EditView.swift
//  PhotosTest
//
//  Created by shinichirou on 2026/01/30.
//

import SwiftUI

struct EditView: View {
    
    @Binding var selectPhoto: Photo?
    
    @Binding var isShowUpdateDlg: Bool
    
    @State private var inputName: String = ""
    @State private var inputUrl: String = ""
    
    /*
    init(selectPhoto: Binding<Photo?>) {
        //self._selectPhoto = selectPhoto
        //self._inputName = State(initialValue: selectPhoto.wrappedValue?.title ?? "")
    }
     */
    
    var body: some View {
        Form {
            Section(header: Text("Edit")) {
                if let _ = selectPhoto {
                    TextField("タイトル", text: $inputName, prompt: Text("名前を入力してください"))
                    TextField("URL", text: $inputUrl, prompt: Text("URLを入力してください"))
                } else {
                    Text("写真が選択されていません")
                }
            }
        }
        .toolbar {
            ToolbarItem(placement: .confirmationAction, content: {
                Button(action: {
                    // 保存ボタンの押下
                    guard var photo = selectPhoto else {
                        return
                    }
                    
                    photo.title = inputName
                    photo.url = inputUrl
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
            /*
            ToolbarItem(placement: .confirmationAction, content: {
                Button(action: {
                    if var photo = selectPhoto {
                    if var photo = selectPhoto {
                        photo.title = inputName
                    }
                }, label: {Text("SAVE")})
            })
             */
        }
        .onAppear {
            if let photo = self.selectPhoto {
                inputName = photo.title ?? ""
                inputUrl = photo.url ?? ""
            }
        }
    }
}

#Preview {
    //EditView(selectPhoto: .constant(nil))
}
