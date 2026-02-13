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
        
    @State private var isShowUpdateDlg: Bool = false
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
                
                HStack {
                    if let getNsImage = getImage(asset: _selectPhoto.asset) {
                        Image(nsImage: getNsImage)
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(width: 392, height: 550)
                    }
                    VStack {
                        /*
                        TextField("名前", text: $inputName)
                            .padding(2)
                         */
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
                        /*
                        Button("設定") {
                            do {
                                _selectPhoto.title = inputName
                                try _selectPhoto.storePhoto()
                            }
                            catch {
                                print("Failed to store photo: \(error)")
                            }
                        }.frame(maxWidth: .infinity, alignment:.trailing)
                            .padding(2)
                         */
                        Button("編集") { isShowUpdateDlg.toggle()}
                            .sheet(isPresented: $isShowUpdateDlg, onDismiss: didDismiss) {
                                //Text("編集画面")
                                EditView(selectPhoto: $selectPhoto, isShowUpdateDlg: $isShowUpdateDlg   )
                            }.frame(maxWidth: .infinity, alignment:.trailing)
                            .padding(10)

                    }
                }
                //Text(inputName)
                //Text(self.selectPhoto?.title ?? "no name")

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
    
    func didDismiss() {
        
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

