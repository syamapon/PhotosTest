//
//  DetailView.swift
//  PhotosTest
//
//  Created by shinichirou on 2026/01/11.
//

import SwiftUI
import Photos

struct DetailView: View {
    
    var selection: Photo.ID?
    var photoGet : PhotoGet
    
    init(photoGet:PhotoGet, selection: Photo.ID? = nil) {
        self.photoGet = photoGet
        self.selection = selection
    }
    
    var body: some View {
        VStack {
            if let photo = self.photo {
                Text(photo.creationDate!.description)
                
                if let getNsImage = getImage(asset: photo.asset)
                {
                    Image(nsImage: getNsImage)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: 600, height: 600)
                }
                
            }
            
            Text(selection?.uuidString ?? "No Selection")
            
        }

    }
    
    private var photo: Photo? {
        if let selectionID = selection {
            return photoGet.photos.filter( { $0.id == selectionID }).first
        }
        return nil
    }
    
    
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
                targetSize: CGSize(width: 1200, height: 1200),
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

