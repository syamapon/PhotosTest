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

    init(image: NSImage, initImageSize: CGSize) {
        self.image = image
        self.scale = 1.0
        self.initImageSize = initImageSize
    }

    var body: some View {

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

    }

}

#Preview {
    //ZoomableImage(image: .constant(nil))
}
