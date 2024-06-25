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
    
    @State private var showAlert = false
    
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
                            dismiss()
                        } else {
                            if let location {
                                let tripRecord = TripRecord(type: type, content: content, location: location)
                                //modelContext.insert(tripRecord)
                                trip.records.append(tripRecord)
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
                } else {
                    location = locationManager.lastLocation?.coordinate
                }
            }
            .alert(isPresented: $showAlert) {
                Alert(title: Text("Location Required"),
                      message: Text("Please wait until your location is acquired before saving the trip record."),
                      dismissButton: .default(Text("OK")))
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
