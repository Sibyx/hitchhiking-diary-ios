import SwiftUI
import CoreLocation

struct TripRecordFormView: View {
    @Environment(\.presentationMode) var presentationMode
    @State private var selectedType: TripRecordType
    @State private var description: NSAttributedString
    @ObservedObject private var locationManager = LocationManager()
    var trip: Trip
    var viewModel: TripDetailViewModel
    var isEditing: Bool
    var recordToEdit: TripRecord?

    init(trip: Trip, viewModel: TripDetailViewModel, isEditing: Bool = false, recordToEdit: TripRecord? = nil) {
        self.trip = trip
        self.viewModel = viewModel
        self.isEditing = isEditing
        self.recordToEdit = recordToEdit
        
        _selectedType = State(initialValue: recordToEdit?.type ?? .interestingPoint)
        _description = State(initialValue: NSAttributedString(string: recordToEdit?.description ?? ""))
    }

    var body: some View {
        NavigationView {
            VStack {
                Form {
                    Picker("Type", selection: $selectedType) {
                        ForEach(TripRecordType.allCases, id: \.self) { type in
                            Text(type.rawValue).tag(type)
                        }
                    }
                    .pickerStyle(SegmentedPickerStyle())
                    
                    Section(header: Text("Description")) {
                        RichTextView(text: $description)
                            .frame(height: 200)
                            .cornerRadius(8)
                            .overlay(
                                RoundedRectangle(cornerRadius: 8)
                                    .stroke(Color.gray, lineWidth: 1)
                            )
                    }
                    
                    if let location = locationManager.lastLocation {
                        Text("Current Location: \(location.coordinate.latitude), \(location.coordinate.longitude)")
                    } else {
                        Text("Fetching current location...")
                    }
                }

                Button(action: saveRecord) {
                    Text(isEditing ? "Update" : "Save")
                        .font(.headline)
                        .foregroundColor(.white)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.blue)
                        .cornerRadius(15.0)
                        .padding()
                }
            }
            .navigationTitle(isEditing ? "Edit Trip Record" : "New Trip Record")
            .navigationBarItems(trailing: Button(action: {
                presentationMode.wrappedValue.dismiss()
            }) {
                Text("Cancel")
            })
        }
    }

    private func saveRecord() {
        if let location = locationManager.lastLocation {
            let locationCoordinate = location.coordinate
            let record = TripRecord(
                tripID: trip.id,
                type: selectedType,
                description: description.string,
                location: locationCoordinate,
                photos: [],
                createdAt: recordToEdit?.createdAt ?? Date(),
                updatedAt: Date()
            )
            if isEditing {
                viewModel.updateTripRecord(tripRecord: record)
            } else {
                viewModel.addTripRecord(tripRecord: record)
            }
            presentationMode.wrappedValue.dismiss()
        }
    }
}

struct TripRecordFormView_Previews: PreviewProvider {
    static var previews: some View {
        TripRecordFormView(trip: Trip(name: "Sample Trip"), viewModel: TripDetailViewModel())
    }
}
