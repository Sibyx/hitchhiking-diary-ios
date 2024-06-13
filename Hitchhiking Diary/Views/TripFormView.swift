import SwiftUI

struct NewTripView: View {
    @Environment(\.presentationMode) var presentationMode
    @State private var tripName: String = ""
    var viewModel: TripListViewModel
    
    var body: some View {
        NavigationView {
            Form {
                TextField("Trip Name", text: $tripName)
                
                Button(action: {
                    viewModel.addTrip(name: tripName)
                    presentationMode.wrappedValue.dismiss()
                }) {
                    Text("Save")
                }
            }
            .navigationTitle("New Trip")
            .navigationBarItems(trailing: Button(action: {
                presentationMode.wrappedValue.dismiss()
            }) {
                Text("Cancel")
            })
        }
    }
}

struct NewTripView_Previews: PreviewProvider {
    static var previews: some View {
        NewTripView(viewModel: TripListViewModel())
    }
}
