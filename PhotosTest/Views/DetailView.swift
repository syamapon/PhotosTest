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
           
            if let _selectPhoto = self.selectPhoto {
                
                HStack {
                    if let getNsImage = getImage(asset: _selectPhoto.asset) {
                        ScrollViewReader { proxy in
                            
                            ScrollView([.horizontal, .vertical]) {
                                ZStack {
                                    Color.red.frame(width:1, height: 1
                                    ).id("anchor")
                                        .position(x: doubleClickPoint.x, y: doubleClickPoint.y)
                                    ZoomableImage(image: getNsImage, initImageSize: CGSize(width: 392, height: 550),
                                                  lastDoubleTapPoint: $doubleClickPoint)
                                    .draggable(getNsImage)
                                }
                            }
                            .frame(width: 392, height: 550)
                            .onChange(of: doubleClickPoint) { _, newPoint in
                                // ダブルクリック位置が更新されたら、その近辺へスクロール
                                withAnimation {
                                    print("newPoint:\(newPoint.x),\(newPoint.y)")
                                    proxy.scrollTo("anchor", anchor: .center)
                                }
                            }
                        }
                    }
                    VStack(alignment: .leading, spacing: 0) {
                        Grid {
                            GridRow {
                                Text("名前（かな）")
                                    .frame(width:100, alignment:.leading)
                                Text("\(_selectPhoto.title ?? "")")
                                    .frame(maxWidth: .infinity, alignment:.leading)
                            }
                            GridRow {
                                Text("名前（漢字）")
                                    .frame(width:100, alignment:.leading)
                                Text("\(_selectPhoto.kanjiName ?? "")")
                                    .frame(maxWidth: .infinity, alignment:.leading)
                            }
                            GridRow {
                                Text("別名")
                                    .frame(width:100, alignment:.leading)
                                Text("\(_selectPhoto.aliasName ?? "")")
                                    .frame(maxWidth: .infinity, alignment:.leading)
                            }
                            GridRow {
                                Text("撮影日")
                                    .frame(width:100, alignment:.leading)
                                Text("\(_selectPhoto.photoDt)")
                                    .frame(maxWidth: .infinity, alignment:.leading)
                            }
                            GridRow {
                                Text("科")
                                    .frame(width:100, alignment:.leading)
                                Text("\(_selectPhoto.family ?? "")")
                                    .frame(maxWidth: .infinity, alignment:.leading)
                            }
                            GridRow {
                                Text("サイト")
                                    .frame(width:100, alignment:.leading)
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
                            GridRow {
                                Text("WIKI")
                                    .frame(width:100, alignment:.leading)
                                if let wiki = _selectPhoto.wiki {
                                    if (!wiki.isEmpty) {
                                        Link("wikipedia", destination: URL(string:wiki)!)
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
                            GridRow {
                                Text("開花季節")
                                    .frame(width:100, alignment:.leading)
                                HStack {
                                    ForEach(_selectPhoto.bloomSeasons) {
                                        season in if (season.isOn) {Text(season.season.name)}
                                    }
                                }.frame(maxWidth: .infinity, alignment:.leading)
                            }
                            GridRow {
                                Text("種別")
                                    .frame(width:100, alignment:.leading)
                                HStack {
                                    ForEach(_selectPhoto.plantCategory) {
                                        category in if (category.isBelong) {Text(category.category.name)}
                                    }
                                }.frame(maxWidth: .infinity, alignment:.leading)
                            }
                            GridRow {
                                Text("特徴")
                                    .frame(width:100, height:50, alignment:.leading)
                                Text("\(_selectPhoto.features ?? "")")
                                    .frame(maxWidth: .infinity, alignment:.leading)
                            }
                            GridRow {
                                Text("情報")
                                    .frame(width:100, height:50, alignment:.leading)
                                Text("\(_selectPhoto.info ?? "")")
                                    .frame(maxWidth: .infinity, alignment:.leading)
                            }
                            GridRow {
                                Text("コメント")
                                    .frame(width:100, height:50, alignment:.leading)
                                Text("\(_selectPhoto.comment ?? "")")
                                    .frame(maxWidth: .infinity, alignment:.leading)
                            }
                            /*
                            GridRow {
                                Text("クリック位置")
                                Text("\(doubleClickPoint.x), \(doubleClickPoint.y)")
                            }
                             */
                        }.frame(maxWidth: .infinity, alignment: .topLeading)
                         .padding(2)
                        Divider().gridCellUnsizedAxes(.horizontal)
                        
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
                                    }
                            }.frame(maxWidth: .infinity, alignment:.trailing)
                            .padding(10)
                        
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
                    }.frame(maxWidth: .infinity, alignment:.init(horizontal: .leading, vertical: .top))
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
            }

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
    //DetailView(photoGet: PhotoGet(), selectPhoto: .constant(nil))
}

