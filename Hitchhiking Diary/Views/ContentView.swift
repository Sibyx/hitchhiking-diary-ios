import SwiftUI

struct ContentView: View {
    @EnvironmentObject var appState: AppState
    @Environment(\.modelContext) var modelContext

    var body: some View {
        Group {
            if appState.isLoggedIn {
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
            } else {
                LoginView()
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView().environmentObject(AppState())
    }
}
