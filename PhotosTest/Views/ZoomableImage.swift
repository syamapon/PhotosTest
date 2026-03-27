//
//  ZoomableImage.swift
//  PhotosTest
//
//  Created by shinichirou on 2026/03/21.
//

import SwiftUI

struct ZoomableImage: View {

    let image: NSImage
    let initImageSize: CGSize

    // Clamp a value to the given closed range (replaces use of inaccessible .clamped)
    @State private var scale: CGFloat = 1.0
    
    @Binding var lastDoubleTapPoint: CGPoint
    

    init(image: NSImage, initImageSize: CGSize, lastDoubleTapPoint: Binding<CGPoint>) {
        self.image = image
        self.initImageSize = initImageSize
        self._lastDoubleTapPoint = lastDoubleTapPoint
    }

    var body: some View {
        
        DoubleClickCapture {
            Image(nsImage: image)
                .resizable()
                .scaledToFit()
                .frame(
                    width: self.initImageSize.width * scale,
                    height: self.initImageSize.height * scale
                )
                .contentShape(Rectangle())
                .onTapGesture(count: 3) {
                    withAnimation(.easeInOut) {
                        scale = 1.0
                    }
                }
        } onDoubleClick: {  point in
            // point は DoubleClickCapture の NSHostingView のローカル座標
            // ここでズーム中心を point に合わせるなどの処理が可能
            withAnimation(.easeInOut) {
                if scale < 8.0 {
                    scale = min(scale * 2, 8.0)
                } else {
                    scale = 1.0
                }
            }
            lastDoubleTapPoint = point
        }

        /*
        Image(nsImage: image)
            .resizable()
            .scaledToFit()
            .frame(
                width: self.initImageSize.width * scale,
                height: self.initImageSize.height * scale
            )
            .contentShape(Rectangle())
            // ダブルクリックでズーム切り替え（任意）
            .onTapGesture(count: 2) {
                withAnimation(.easeInOut) {
                    if scale < 8.0 {
                        scale = min(scale * 2, 8.0)
                    } else {
                        scale = 1.0
                    }
                }
            }
            .onTapGesture(count: 3) {
                withAnimation(.easeInOut) {
                    scale = 1.0
                }
            }
         */

    }

}

#Preview {
    //ZoomableImage(image: .constant(nil))
}

