//
//  DetailView.swift
//  PhotosTest
//
//  Created by shinichirou on 2026/01/11.
//

import SwiftUI
import Photos
import MapKit

struct DetailView: View {
    
    /// 写真データ取得
    @ObservedObject var photoGet : PhotoGet
    
    /// 選択中の写真データ
    @Binding var selectPhoto : Photo?
    
    /// マップ上の写真位置
    @State private var cameraPosition: MapCameraPosition = .automatic
    
    /// ダイアログ表示フラグ
    @State private var isShowUpdateDlg: Bool = false
    
    @State private var doubleClickPoint: CGPoint = .zero
    
    /// １行項目高さ
    private let HEIGHT_NORMAL: CGFloat = 12
    
    /// 複数行項目高さ
    private let HEIGHT_LONG: CGFloat = 60
    
    /// body
    var body: some View {
        
        VStack {
            HStack {
                // 画像表示
                DetailImageView(selectPhoto: self.selectPhoto)
                VStack(alignment: .leading, spacing: 0) {
                    Grid {
                        DetailTextGridRow(itemNm: "名前（かな）", widthNm: 100, heightNm: HEIGHT_NORMAL) { Text(self.selectPhoto?.title ?? "") }
                        DetailTextGridRow(itemNm: "名前（漢字）", widthNm: 100, heightNm: HEIGHT_NORMAL) { Text(self.selectPhoto?.kanjiName ?? "") }
                        DetailTextGridRow(itemNm: "別名", widthNm: 100, heightNm: HEIGHT_NORMAL) { Text(self.selectPhoto?.aliasName ?? "") }
                        DetailTextGridRow(itemNm: "撮影日", widthNm: 100, heightNm: HEIGHT_NORMAL) { Text(self.selectPhoto?.photoDt ?? "") }
                        DetailTextGridRow(itemNm: "科", widthNm: 100, heightNm: HEIGHT_NORMAL) { Text(self.selectPhoto?.family ?? "") }
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
                        DetailTextGridRow(itemNm: "特徴", widthNm: 100, heightNm: HEIGHT_LONG) { Text(self.selectPhoto?.features ?? "") }
                        DetailTextGridRow(itemNm: "情報", widthNm: 100, heightNm: HEIGHT_LONG) { Text(self.selectPhoto?.info ?? "") }
                        DetailTextGridRow(itemNm: "コメント", widthNm: 100, heightNm: HEIGHT_LONG) { Text(self.selectPhoto?.comment ?? "") }
                    }.frame(maxWidth: .infinity, alignment: .topLeading)
                        .padding(2)
                    //.border(Color.white, width: 1)
                    //Divider().gridCellUnsizedAxes(.horizontal)
                    
                    Button("編集") { isShowUpdateDlg.toggle()}
                        .sheet(isPresented: $isShowUpdateDlg, onDismiss: {}) {
                            EditView(
                                photoGet: photoGet,
                                selectPhoto: $selectPhoto,
                                isShowUpdateDlg: $isShowUpdateDlg).onDisappear {
                                    print("disAppear")
                                    for photo in sameNamePhotos {
                                        photo.kanjiName = selectPhoto?.kanjiName
                                        photo.url = selectPhoto?.url
                                        photo.aliasName = selectPhoto?.aliasName
                                        photo.bloomSeasons = selectPhoto?.bloomSeasons ?? []
                                        photo.wiki = selectPhoto?.wiki ?? ""
                                        photo.info = selectPhoto?.info ?? ""
                                        photo.features = selectPhoto?.features ?? ""
                                    }
                                }.frame(width: 700, height: 800)
                        }.frame(maxWidth: .infinity, alignment:.trailing)
                    
                    Spacer()
                    
                    if (sameNamePhotos.count > 0) {
                        Text("同名の写真").frame(maxWidth: .infinity, alignment:.leading)
                        ScrollView(.horizontal) {
                            HStack {
                                ForEach (sameNamePhotos) {
                                    _photo in
                                    PhotoThumbnail(asset: _photo.asset, size: .init(width: 100, height: 100))
                                        .onTapGesture {
                                            selectPhoto = _photo
                                        }
                                }
                            }
                        }
                    }
                }.frame(maxWidth: .infinity,
                        alignment:.init(horizontal: .leading, vertical: .top))
                .onAppear {
                    print("onAppear")
                }
                .frame(maxHeight: .infinity, alignment:.init(horizontal: .leading, vertical: .top))
            }
            Spacer()
            Map(position: $cameraPosition) {
                if let photo = selectPhoto {
                    let coordinate = CLLocationCoordinate2D(latitude: photo.locLatitude ?? 0.0, longitude: photo.locLongitude ?? 0.0)
                    Marker(photo.title ?? "", coordinate: coordinate)
                }
            }
            .mapControls({
                MapZoomStepper()
                MapCompass()
                MapScaleView()
            })
        }
        .onChange(of: selectPhoto, initial: true, { _, newValue in
            cameraPosition = newValue?.position ?? .automatic
        })
    }
    
    /// 同名の写真リストを取得
    private var sameNamePhotos: [Photo] {
        
        // 選択されていない、選択された写真に名前が無い場合
        guard selectPhoto != nil
                && selectPhoto!.title != nil
                && !selectPhoto!.title!.isEmpty else {
            return []
        }
        // 同名の写真を取得
        var photos: [Photo] = photoGet.photos
        photos = photos.filter {photo in
            photo.id != selectPhoto!.id
            && photo.title == selectPhoto!.title
        }
        // 重複除去
        var alreadyAdded: Set<Photo> = []
        let uniquePhotos = photos.filter { alreadyAdded.insert($0).inserted}
        
        return uniquePhotos
    }
    
    /// イメージオブジェクト取得
    /// - Parameter asset: 写真データ
    /// - Returns: 写真データの保持するイメージ
    func getImage(asset: PHAsset?) -> NSImage? {
        
        if let imgAssset = asset {
            // 写真から画像を取得するオプション
            let options = PHImageRequestOptions()
            options.deliveryMode = .highQualityFormat
            options.resizeMode = .exact
            options.isNetworkAccessAllowed = true
            options.isSynchronous = true
            
            // イメージデータの取得
            var getImage: NSImage?
            PHImageManager.default().requestImage(
                for: imgAssset,
                targetSize: CGSize(width: 1000, height: 1400),
                contentMode: .aspectFill,
                options: options
            ) { image, _ in
                getImage = image
            }
            return getImage
        }
        return nil
    }
    
}

#Preview {

    DetailView(photoGet: PhotoGet(), selectPhoto: .constant(nil))
}

