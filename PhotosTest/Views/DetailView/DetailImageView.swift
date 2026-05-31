//
//  DetailImageView.swift
//  PhotosTest
//
//  Created by shinichirou on 2026/05/24.
//

import SwiftUI
import Photos

struct DetailImageView: View {
    
    /// 選択中の写真データ
    let selectPhoto : Photo?
    
    @State private var doubleClickPoint: CGPoint = .zero
    
    var body: some View {
        if let _selectPhoto = selectPhoto {
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
        }
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
    DetailImageView(selectPhoto: nil)
}
