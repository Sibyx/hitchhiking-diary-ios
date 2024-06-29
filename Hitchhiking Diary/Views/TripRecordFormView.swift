import SwiftUI
import CoreLocation
import SwiftData
import MapKit

struct TripRecordFormView: View {
    @Environment(\.database) private var database
    @Environment(\.dismiss) private var dismiss
    @ObservedObject private var locationManager = LocationManager()
    
    @State var tripRecord: TripRecord?
    let trip: Trip
    
    @State private var type: TripRecordType = .interesting
    @State private var content: String = ""
    @State private var location: CLLocationCoordinate2D?
    @State private var photos: [UIImage] = []
    @State private var photoMapping: [UIImage: Photo] = [:]
    
    @State private var showAlert = false
    @State private var showPhotoPicker = false
    
    var body: some View {
        VStack {
            Form {
                Section {
                    Picker("Type", selection: $type) {
                        ForEach(TripRecordType.allCases, id: \.self) { type in
                            HStack {
                                type.icon()
                                Text(type.title())
                            }.tag(type)
                        }
                    }
                    
                    if let location = location {
                        Map() {
                            Marker("I am here!", coordinate: location)
                        }
                        .frame(height: 200)
                        .cornerRadius(10)
                        .padding()
                    } else {
                        Text("Acquiring location...")
                            .foregroundColor(.gray)
                            .padding()
                    }
                    
                }
                
                Section(header: Text("Photos")) {
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack {
                            ForEach(photos.indices, id: \.self) { index in
                                VStack {
                                    Image(uiImage: photos[index])
                                        .resizable()
                                        .frame(width: 100, height: 100)
                                        .cornerRadius(10)
                                    Button(action: {
                                        let removedPhoto = photos.remove(at: index)
                                        if let photo = photoMapping[removedPhoto] {
                                            photoMapping.removeValue(forKey: removedPhoto)
                                        }
                                    }) {
                                        Image(systemName: "minus.circle.fill")
                                            .foregroundColor(.red)
                                    }
                                    .padding(.top, 5)
                                }
                            }
                        }
                    }
                    Button(action: {
                        showPhotoPicker = true
                    }) {
                        Label("Add photos", systemImage: "photo.on.rectangle.angled")
                    }
                }
                
                Section(header: Text("Description")) {
                    TextEditor(text: $content)
                        .frame(minHeight: 200, maxHeight: .infinity)
                }
            }
            .navigationTitle(tripRecord == nil ? "New Trip Record" : "Edit Trip Record")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        Task {
                            if let tripRecord = tripRecord {
                                tripRecord.content = content
                                tripRecord.type = type
                                tripRecord.updatedAt = Date()
                                await database.insert(tripRecord)
                                
                                // Update photos
                                for uiImage in photos {
                                    if photoMapping[uiImage] == nil {
                                        let newPhoto = Photo(content: uiImage.jpegData(compressionQuality: 1)!)
                                        tripRecord.photos.append(newPhoto)
                                        photoMapping[uiImage] = newPhoto
                                    }
                                }
                                
                                for photo in tripRecord.photos.filter({ !photoMapping.values.contains($0) }) {
                                    photo.updatedAt = Date()
                                    photo.deletedAt = Date()
                                    await database.insert(photo)
                                }

                                dismiss()
                            } else {
                                if let location {
                                    let tripRecord = TripRecord(type: type, content: content, location: location)
                                    trip.records.append(tripRecord)
                                    
                                    for uiImage in photos {
                                        if photoMapping[uiImage] == nil {
                                            let newPhoto = Photo(content: uiImage.jpegData(compressionQuality: 1)!)
                                            tripRecord.photos.append(newPhoto)
                                            photoMapping[uiImage] = newPhoto
                                        }
                                    }
                                    
                                    dismiss()
                                } else {
                                    showAlert = true
                                }
                            }
                        }
                    }) { Text("Save") }
                }
            }
            .onAppear {
                if let tripRecord = tripRecord {
                    type = tripRecord.type
                    content = tripRecord.content ?? ""
                    location = tripRecord.location
                    photos = tripRecord.photos.filter { $0.deletedAt == nil }.compactMap {
                        let uiImage = UIImage(data: $0.content)
                        if let uiImage = uiImage {
                            photoMapping[uiImage] = $0
                        }
                        return uiImage
                    }
                } else {
                    location = locationManager.lastLocation?.coordinate
                }
            }
            .alert(isPresented: $showAlert) {
                Alert(title: Text("Location Required"),
                      message: Text("Please wait until your location is acquired before saving the trip record."),
                      dismissButton: .default(Text("OK")))
            }
            .sheet(isPresented: $showPhotoPicker) {
                PhotoPicker(photos: $photos)
            }
        }
    }
}
