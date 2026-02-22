//
//  PhotoThumbnail.swift
//  PhotosTest
//
//  Created by shinichirou on 2026/01/03.
//

import SwiftUI
import Photos
//import UIKit

struct PhotoThumbnail: View {
    
    let asset: PHAsset
    let size: CGSize
    
    @State private var image: NSImage?
    
    var body: some View {
        Group {
            if let image {
                Image(nsImage: image)
                    .resizable()
                //    .frame(width: 50, height: 50)
                    .frame(width: self.size.width, height: self.size.height)
                
            } else {
                Color.gray
            }
        }
        .onAppear {
            loadImage()
        }
    }
    
    func loadImage() {
        PHImageManager.default().requestImage(
            for: asset,
            targetSize: size,
            contentMode: .aspectFill,
            options: nil
        ) { image, _ in
            self.image = image
        }
    }
}

#Preview {
    //PhotoThumbnail()
}
