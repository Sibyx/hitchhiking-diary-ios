import SwiftUI

struct ContentView: View {
    @EnvironmentObject var appState: AppState
    @Environment(\.modelContext) var modelContext

    @State private var sortOrder = [SortDescriptor(\Trip.createdAt)]
    @State private var searchText = ""

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
                            Menu("Sort", systemImage: "arrow.up.arrow.down") {
                                Picker("Sort", selection: $sortOrder) {
                                    Text("Title (A-Z)")
                                        .tag([SortDescriptor(\Trip.title)])

                                    Text("Title (Z-A)")
                                        .tag([SortDescriptor(\Trip.title, order: .reverse)])
                                    
                                    Text("Created at")
                                        .tag([SortDescriptor(\Trip.createdAt)])
                                    
                                    Text("Created at (Z-A)")
                                        .tag([SortDescriptor(\Trip.createdAt, order: .reverse)])
                                }
                            }
                            NavigationLink(destination: TripFormView(trip: nil)) {
                                Image(systemName: "plus")
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
