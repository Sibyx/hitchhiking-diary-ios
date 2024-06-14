import SwiftUI

struct TripListView: View {
    @StateObject private var viewModel = TripListViewModel()
    @EnvironmentObject var appState: AppState

    var body: some View {
        NavigationView {
            List {
                ForEach(viewModel.trips) { trip in
                    let records = viewModel.persistence.tripRecords[trip.id] ?? []
                    NavigationLink(destination: TripDetailView(trip: trip)) {
                        TripListItemView(trip: trip, records: records)
                    }
                    .swipeActions(edge: .trailing) {
                        Button(action: {
                            viewModel.editTrip(trip)
                        }) {
                            Label("Edit", systemImage: "pencil")
                        }
                        .tint(.blue)

                        Button(role: .destructive, action: {
                            viewModel.removeTrip(trip)
                        }) {
                            Label("Delete", systemImage: "trash")
                        }
                    }
                }
            }
            .navigationTitle("My Trips")
            .navigationBarItems(
                leading: HStack {
                    Button(action: {
                        appState.logout()
                    }) {
                        Text("Log Out")
                    }
                },
                trailing: Button(action: {
                    viewModel.tripToEdit = nil
                    viewModel.showingTripFormView = true
                }) {
                    Image(systemName: "plus")
                }
            )
            .sheet(isPresented: $viewModel.showingTripFormView) {
                TripFormView(viewModel: viewModel, trip: viewModel.tripToEdit)
            }
            .onAppear {
                viewModel.fetchTrips()
            }
        }
    }
}

struct TripListView_Previews: PreviewProvider {
    static var previews: some View {
        TripListView().environmentObject(AppState())
    }
}
