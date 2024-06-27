import SwiftUI
import SwiftData

struct TripListView: View {
    @EnvironmentObject var appState: AppState
    @Environment(\.modelContext) var modelContext
    
    @Query(filter: #Predicate<Trip> { trip in
        trip.deletedAt == nil
    }, sort: \Trip.createdAt, order: .reverse) var trips: [Trip]
    
    @State private var showingErrorAlert = false
    @State private var errorMessage = ""

    var body: some View {
        List {
            ForEach(trips) {
                trip in NavigationLink(value: trip) {
                    Text(trip.title)
                }
            }
            .onDelete(perform: deleteTrip)
        }
        .refreshable {
            syncTrips()
        }
        .alert(isPresented: $showingErrorAlert) {
            Alert(title: Text("Sync Failed"), message: Text(errorMessage), dismissButton: .default(Text("OK")))
        }
    }
    
    func deleteTrip(at offsets: IndexSet) {
        for offset in offsets {
            let trip = trips[offset]
            trip.updatedAt = Date()
            trip.deletedAt = Date()
            modelContext.insert(trip)
        }
    }
    
    private func syncTrips() {
        let apiClient = APIClient(token: appState.token)
        let syncService = SyncService(apiClient: apiClient, modelContext: modelContext)
        
        syncService.sync { result in
            DispatchQueue.main.async {
                switch result {
                case .success:
                    print("Sync successful")
                case .failure(let error):
                    self.errorMessage = error.localizedDescription
                    self.showingErrorAlert = true
                }
            }
        }
    }
}
#Preview {
    do {
        let previewer = try Previewer()

        return TripListView()
            .modelContainer(previewer.container)
            .environmentObject(AppState())
    } catch {
        return Text("Failed to create preview: \(error.localizedDescription)")
    }
}
