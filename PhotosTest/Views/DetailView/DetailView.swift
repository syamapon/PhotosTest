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
    
    /// body
    var body: some View {
        
        VStack {
            HStack {
                // 画像表示
                DetailImageView(selectPhoto: self.selectPhoto)
                
                VStack(alignment: .leading, spacing: 0) {
                    
                    // 詳細情報表示
                    DetailTextGrid(selectPhoto: selectPhoto)
                        .frame(maxWidth: .infinity, alignment: .topLeading)
                        .padding(2)
                    
                    // 編集ボタン
                    Button("編集") { isShowUpdateDlg.toggle()}
                        .sheet(isPresented: $isShowUpdateDlg, onDismiss: {}) {
                            EditView(
                                photoGet: photoGet,
                                selectPhoto: $selectPhoto,
                                isShowUpdateDlg: $isShowUpdateDlg).onDisappear {
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
                        }
                        .frame(alignment:.trailing)
                    
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

