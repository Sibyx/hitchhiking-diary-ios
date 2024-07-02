import SwiftUI

struct ContentView: View {
    @EnvironmentObject var appState: AppState
    @Environment(\.database) var database

    var body: some View {
        NavigationStack {
            TripListView()
                .navigationTitle("Hitchhiking Diary")
                .navigationDestination(for: Trip.self) { trip in
                    TripDetailView(trip: trip)
                }
                .toolbar {
                    ToolbarItem(placement: .topBarLeading) {
                        NavigationLink(destination: UserDetailView()) {
                            if appState.token == nil {
                                Image(systemName: "person.crop.circle.fill.badge.plus")
                            } else {
                                Image(systemName: "person.crop.circle")
                            }
                        }
                    }
                    ToolbarItem(placement: .topBarTrailing) {
                        NavigationLink(destination: TripFormView(trip: nil)) {
                            Image(systemName: "plus")
                        }
                    }
                }
        }
    }
}
