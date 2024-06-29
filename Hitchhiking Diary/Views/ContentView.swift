import SwiftUI

struct ContentView: View {
    @EnvironmentObject var appState: AppState
    @Environment(\.database) var database
    
    @State private var showingErrorAlert = false
    @State private var errorMessage = ""
    @State private var isSyncing = false

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
                                Button(action: {
                                    Task {
                                        await syncTrips()
                                    }
                                }) {
                                    Image(systemName: "arrow.triangle.2.circlepath")
                                }
                                .disabled(isSyncing)
                            }
                            ToolbarItem(placement: .topBarTrailing) {
                                NavigationLink(destination: TripFormView(trip: nil)) {
                                    Image(systemName: "plus")
                                }
                            }
                        }
                        .alert(isPresented: $showingErrorAlert) {
                            Alert(title: Text("Sync Failed"), message: Text(errorMessage), dismissButton: .default(Text("OK")))
                        }
                        .overlay(
                            Group {
                                if isSyncing {
                                    LoaderView()
                                }
                            }
                        )
                }
            }
        }
    }
    
    private func syncTrips() async {
        guard !isSyncing else { return }
        
        self.isSyncing = true
        
        let apiClient = APIClient(token: appState.token)
        let syncService = SyncService(apiClient: apiClient)
        
        await syncService.sync { result in
            DispatchQueue.main.async {
                switch result {
                case .success:
                    self.isSyncing = false
                    print("Sync successful")
                case .failure(let error):
                    self.errorMessage = error.localizedDescription
                    self.showingErrorAlert = true
                    self.isSyncing = false
                }
            }
        }
    }
}
