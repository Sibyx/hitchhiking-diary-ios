import SwiftUI

struct ContentView: View {
    @EnvironmentObject var appState: AppState
    @Environment(\.database) var database    

    var body: some View {
        Group {
            if appState.token == nil {
                LoginView()
            }
            else {
                NavigationStack() {
                    TripListView()
                        .navigationTitle("Hitchhiking Diary")
                        .navigationDestination(for: Trip.self) {
                            trip in TripDetailView(trip: trip)
                        }
                        .toolbar {
                            ToolbarItem(placement: .topBarLeading) {
                                Button(action: {
                                    appState.logout()
                                }) {
                                    Image(systemName: "power")
                                        .foregroundColor(.red) // Customize color if needed
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
    }
}
