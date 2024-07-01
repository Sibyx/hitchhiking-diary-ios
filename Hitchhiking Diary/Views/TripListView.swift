import SwiftUI
import SwiftData

struct TripListView: View {
    @EnvironmentObject var appState: AppState
    @Environment(\.database) private var database
    
    @State private var showingErrorAlert = false
    @State private var errorMessage = ""
    @State private var isSyncing = false
    
    @State var trips: [Trip] = []

    var body: some View {
        List {
            ForEach(trips) { trip in
                NavigationLink(value: trip) {
                    Text(trip.title)
                }
            }
            .onDelete { offsets in
                Task {
                    for offset in offsets {
                        let trip = trips[offset]
                        trip.updatedAt = Date()
                        trip.deletedAt = Date()
                        await database.insert(trip)
                    }
                    self.trips = await fetchTrips() // Refresh the trip list after deletion
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
        .task {
            if appState.token != nil {
                self.trips = await fetchTrips()
            }
        }
        .refreshable {
            if !isSyncing && appState.token != nil {
                await syncTrips()
            }
        }
    }
    
    private func fetchTrips() async -> [Trip] {
        do {
            return try await database.fetch(#Predicate<Trip> { trip in
                trip.deletedAt == nil
            })
        } catch {
            print("Failed to fetch trips: \(error.localizedDescription)")
            return []
        }
    }
    
    private func syncTrips() async {
        isSyncing = true
        let apiClient = APIClient(token: appState.token)
        let syncService = SyncService(apiClient: apiClient, appState: appState)
        
        await syncService.sync { result in
            DispatchQueue.main.async {
                switch result {
                case .success:
                    self.isSyncing = false
                    Task {
                        self.trips = await fetchTrips()
                    }
                case .failure(let error):
                    self.errorMessage = error.localizedDescription
                    self.showingErrorAlert = true
                    self.isSyncing = false
                }
            }
        }
    }
}
