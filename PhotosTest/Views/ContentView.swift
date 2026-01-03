//
//  ContentView.swift
//  PhotosTest
//
//  Created by shinichirou on 2026/01/01.
//

import SwiftUI
import Photos

struct ContentView: View {
    
    @StateObject private var photoGet = PhotoGet()
    
    var body: some View {
        VStack {
            Button(/*@START_MENU_TOKEN@*/"Button"/*@END_MENU_TOKEN@*/) {
                self.photoGet.setPhotos()
            }
            List(photoGet.photos) { entry in
                HStack {

                    if let asset = entry.asset {
                        PhotoThumbnail(asset: asset)
                    }
                    Text("creationDate: \(entry.creationDate ?? Date())")

                }
            }
        }
        .padding()
    }
}

#Preview {
    ContentView()
}
