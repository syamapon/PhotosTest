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
    
    var body: some View {
        
        VStack {
           
            if let _selectPhoto = self.selectPhoto {
                
                HStack {
                    if let getNsImage = getImage(asset: _selectPhoto.asset) {
                        Image(nsImage: getNsImage)
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(width: 392, height: 550)
                            .padding(5)
                    }
                    VStack {
                        Grid {
                            GridRow {
                                Text("名前")
                                Text("\(_selectPhoto.title ?? "")")
                                    .frame(maxWidth: .infinity, alignment:.leading)
                            }
                            GridRow {
                                Text("撮影日")
                                Text("\(_selectPhoto.photoDt)")
                                    .frame(maxWidth: .infinity, alignment:.leading)
                            }
                            GridRow {
                                Text("別名")
                                Text("\(_selectPhoto.aliasName ?? "")")
                                    .frame(maxWidth: .infinity, alignment:.leading)
                            }
                            GridRow {
                                Text("開花季節")
                                HStack {
                                    ForEach(_selectPhoto.bloomSeasons) {
                                        season in if (season.isOn) {Text(season.name)}
                                    }
                                }.frame(maxWidth: .infinity, alignment:.leading)
                            }
                            GridRow {
                                Text("サイト")
                                if let url = _selectPhoto.url {
                                    if (!url.isEmpty) {
                                        Link("URL", destination: URL(string:url)!)
                                            .frame(maxWidth: .infinity, alignment:.leading)
                                            .padding(2)
                                    }
                                    else {
                                        Text("未設定")
                                            .frame(maxWidth: .infinity, alignment:.leading)
                                    }
                                }
                                else {
                                    Text("未設定").frame(maxWidth: .infinity, alignment:.leading)
                                }
                                
                            }
 
                        }.frame(maxWidth: .infinity, alignment:.leading)
                         .padding(2)
                        Button("編集") { isShowUpdateDlg.toggle()}
                                .sheet(isPresented: $isShowUpdateDlg, onDismiss: {}) {
                                EditView(selectPhoto: $selectPhoto, isShowUpdateDlg: $isShowUpdateDlg   )
                            }.frame(maxWidth: .infinity, alignment:.trailing)
                            .padding(10)
                        
                        if (photos.count > 0) {
                            Text("同名の写真").frame(maxWidth: .infinity, alignment:.leading)
                            ScrollView(.horizontal) {
                                HStack {
                                    ForEach (photos) {
                                        _photo in
                                            PhotoThumbnail(asset: _photo.asset, size: .init(width: 100, height: 100))
                                                .onTapGesture {
                                                    selectPhoto = _photo
                                                }
                                    }
                                }
                            }
                        }

                        Spacer()
                    }
                }
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
                .ignoresSafeArea()
            }
            Spacer()

        }
        .onChange(of: selectPhoto, initial: true, { _, newValue in
            cameraPosition = newValue?.position ?? .automatic
        })
    }
    
    
    private var photos: [Photo] {
        
        guard selectPhoto != nil && selectPhoto!.title != nil && !selectPhoto!.title!.isEmpty else {
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
            var getImage: NSImage?
            let options = PHImageRequestOptions()
            options.deliveryMode = .highQualityFormat
            options.resizeMode = .exact
            options.isNetworkAccessAllowed = true
            options.isSynchronous = true
            
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
    //DetailView()
}

