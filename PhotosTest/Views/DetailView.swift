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
                    }
                    VStack {
                        Text("名前:\(_selectPhoto.title ?? "")")
                            .frame(maxWidth: .infinity, alignment:.leading)
                            .padding(2)
                        Text("撮影日: \(_selectPhoto.photoDt)")
                            .frame(maxWidth: .infinity, alignment:.leading)
                            .padding(2)
                        if let url = _selectPhoto.url {
                            if (!url.isEmpty) {
                                Link("サイト", destination: URL(string:url)!)
                                    .frame(maxWidth: .infinity, alignment:.leading)
                                    .padding(2)
                            }
                        }
                        else {
                            Text("サイト未設定")
                                .frame(maxWidth: .infinity, alignment:.leading)
                                .padding(2)
                        }
                        Button("編集") { isShowUpdateDlg.toggle()}
                            .sheet(isPresented: $isShowUpdateDlg, onDismiss: {}) {
                                EditView(selectPhoto: $selectPhoto, isShowUpdateDlg: $isShowUpdateDlg   )
                            }.frame(maxWidth: .infinity, alignment:.trailing)
                            .padding(10)
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

        }
        .onChange(of: selectPhoto, initial: true, { _, newValue in
            cameraPosition = newValue?.position ?? .automatic
        })
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

