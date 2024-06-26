import SwiftUI
import CoreLocation
import SwiftData
import MapKit

struct TripRecordFormView: View {
    @Environment(\.modelContext) private var modelContext: ModelContext
    @Environment(\.dismiss) private var dismiss
    @ObservedObject private var locationManager = LocationManager()
    
    @State var tripRecord: TripRecord?
    let trip: Trip
    
    @State private var type: TripRecordType = .interesting
    @State private var content: String = ""
    @State private var location: CLLocationCoordinate2D?
    @State private var photos: [UIImage] = []
    
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
                                Text(type.rawValue)
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
                                        photos.remove(at: index)
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
                        if let tripRecord = tripRecord {
                            tripRecord.content = content
                            tripRecord.type = type
                            tripRecord.updatedAt = Date()
                            modelContext.insert(tripRecord)
                            
                            var checksums: [String] = [String]()
                            for i in photos {
                                let photo = Photo(content: i.jpegData(compressionQuality: 1)!)
                                checksums.append(photo.checksum)
                                if tripRecord.photos.filter({$0.checksum == photo.checksum}).isEmpty {
                                    tripRecord.photos.append(photo)
                                }
                            }
                            
                            tripRecord.photos.removeAll(where: {!checksums.contains($0.checksum)})
                            
                            dismiss()
                        } else {
                            if let location {
                                let tripRecord = TripRecord(type: type, content: content, location: location)
                                trip.records.append(tripRecord)
                                
                                for i in photos {
                                    let photo = Photo(content: i.jpegData(compressionQuality: 1)!)
                                    if tripRecord.photos.filter({$0.checksum == photo.checksum}).isEmpty {
                                        tripRecord.photos.append(photo)
                                    }
                                }
                                
                                dismiss()
                            }
                            else {
                                showAlert = true
                            }
                        }
                    }) {Text("Save")}
                }
            }
            .onAppear {
                if let tripRecord = tripRecord {
                    type = tripRecord.type
                    content = tripRecord.content ?? ""
                    location = tripRecord.location
                    photos = tripRecord.photos.compactMap { UIImage(data: $0.content) }
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


#Preview {
    do {
        let previewer = try Previewer()

        return TripRecordFormView(trip: previewer.trip)
            .modelContainer(previewer.container)
    } catch {
        return Text("Failed to create preview: \(error.localizedDescription)")
    }
}
