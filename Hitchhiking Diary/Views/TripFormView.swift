import SwiftUI

struct TripFormView: View {
    @Environment(\.presentationMode) var presentationMode
    @ObservedObject var viewModel: TripListViewModel
    @State private var name: String
    var trip: Trip?

    init(viewModel: TripListViewModel, trip: Trip? = nil) {
        self.viewModel = viewModel
        self.trip = trip
        _name = State(initialValue: trip?.name ?? "")
    }
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Trip Name")) {
                    TextField("Name", text: $name)
                }
            }
            .navigationTitle(trip == nil ? "New Trip" : "Edit Trip")
            .navigationBarItems(leading: Button("Cancel") {
                presentationMode.wrappedValue.dismiss()
            }, trailing: Button("Save") {
                if let trip = trip {
                    var updatedTrip = trip
                    updatedTrip.name = name
                    viewModel.updateTrip(updatedTrip)
                } else {
                    viewModel.addTrip(name: name)
                }
                presentationMode.wrappedValue.dismiss()
            })
        }
    }
}

struct TripFormView_Previews: PreviewProvider {
    static var previews: some View {
        TripFormView(viewModel: TripListViewModel())
    }
}
