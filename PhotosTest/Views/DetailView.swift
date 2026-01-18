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
    
    @State private var inputName: String = ""
    
    init(photoGet:PhotoGet, selection: Photo.ID? = nil) {
        self.photoGet = photoGet
        self.selection = selection
    }
    
    var body: some View {
        VStack {
            if let photo = self.photo {
                
                Text(photo.title ?? "Untitled")
                TextField("名前", text: $inputName)
                    .padding(10)
                Button("保存") {
                    do {
                        var mutablePhoto = photo
                        mutablePhoto.title = inputName
                        try mutablePhoto.storePhoto()
                    } catch {
                        // TODO: Present a user-facing error if needed
                        print("Failed to store photo: \(error)")
                    }
                }
                if let creationDate = photo.creationDate {
                    Text(creationDate.description)
                }
                if let getNsImage = getImage(asset: photo.asset) {
                    Image(nsImage: getNsImage)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: 600, height: 600)
                }
            } else {
                Text("No Selection")
            }
        }
        .onAppear {
            if let title = self.photo?.title {
                self.inputName = title
            }
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

