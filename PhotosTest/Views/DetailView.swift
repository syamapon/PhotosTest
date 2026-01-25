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
    
    //@Binding var selection: Photo.ID?
    
    @ObservedObject var photoGet : PhotoGet
    
    @Binding var selectPhoto : Photo?
    
    @State private var inputName: String = ""
    
    @State private var cameraPosition: MapCameraPosition = .automatic
        
    //@State private var photo: Photo?
    
    /*
    init(photoGet:PhotoGet, selection: Photo.ID? = nil) {
        self.photoGet = photoGet
        self.selection = selection
        
        _photo = State(initialValue: photoGet.getPhoto(selection))
        _inputName = State(initialValue: photoGet.getPhoto(selection)?.title ?? "")
    }
     */
    
    var body: some View {
        VStack {
           
            //if (pphotoGet.getPhoto())
            
            //Text(photoGet.getPhoto()?.title)
            
            if var _selectPhoto = self.selectPhoto {
                
                //Text(inputName)
                //Text(self.selectPhoto?.title ?? "no name")
  
                TextField("名前", text: $inputName)
                Button("設定") {
                    do {
                        _selectPhoto.title = inputName
                        try _selectPhoto.storePhoto()
                    }
                    catch {
                        print("Failed to store photo: \(error)")
                    }
                }
                if let creationDate = _selectPhoto.creationDate {
                    Text(creationDate.description)
                }
                if let getNsImage = getImage(asset: _selectPhoto.asset) {
                    Image(nsImage: getNsImage)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: 400, height: 500)
                }
                Map(position: $cameraPosition) {
                    if let photo = selectPhoto {
                        let coordinate = CLLocationCoordinate2D(latitude: photo.locLatitude ?? 0.0, longitude: photo.locLongitude ?? 0.0)
                        Marker(photo.title, coordinate: coordinate)
                    }
                }
                .mapControls({
                    MapZoomStepper()
                    MapCompass()
                    MapScaleView()
                })
                .ignoresSafeArea()
            }

            
            /*
            if let photo = self.photo  {

                Text(photo.title)
                TextField("名前", text: $inputName)
                    .padding(10)
                Button("保存") {
                    do {
                        // Persist the new title back to state and storage
                        self.photo?.title = inputName
                        try self.photo?.storePhoto()
                        photoGet.setTitle(photo.id, setTitle: photo.title)
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
             */
        }
        .onChange(of: selectPhoto, initial: true, { _, newValue in
            inputName = newValue?.title ?? ""
            cameraPosition = newValue?.position ?? .automatic
        })
        /*
        .onChange(of: selection) { oldSelection, newSelection in
            if let selectionID = newSelection {
                self.photo = photoGet.getPhoto(selectionID)
                // Reflect the current title in the text field
                self.inputName = self.photo?.title ?? ""
            } else {
                // Clear state when there's no selection
                self.photo = nil
                self.inputName = ""
            }
        }
        .onAppear {
            // Keep existing behavior minimal; state is initialized in init
        }
         */
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

