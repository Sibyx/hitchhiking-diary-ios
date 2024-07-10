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
                    TripListItemView(trip: trip)
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
            self.trips = await fetchTrips()
        }
        .refreshable {
            if !isSyncing && appState.token != nil {
                await syncTrips()
            }
        }
    }
    
    private struct TripListItemView: View {
        let trip: Trip
        
        var body: some View {
            VStack(alignment: .leading) {
                Text(trip.title)
                    .font(.title)
                    .padding(.bottom, 10)
                
                HStack {
                    
                    HStack(alignment: .top) {
                        trip.status.icon()
                            .font(.footnote)
                        Text(trip.status.title().capitalized)
                            .font(.footnote)
                            .foregroundColor(.secondary)
                    }
                    
                    Spacer()
                    
                    HStack(alignment: .top) {
                        Image(systemName: "mappin.circle")
                            .font(.footnote)
                        Text("\(trip.records.filter{$0.deletedAt == nil}.count)")
                            .font(.footnote)
                            .foregroundColor(.secondary)
                    }
                    
                    Spacer()
                    
                    HStack(alignment: .top) {
                        Image(systemName: "calendar.badge.plus")
                            .font(.footnote)
                        Text(trip.createdAt, style: .date)
                            .font(.footnote)
                            .foregroundColor(.secondary)
                    }
                }
            }
            .padding(.vertical, 4)
        }
    }

    
    private func fetchTrips() async -> [Trip] {
        do {
            var trips = try await database.fetch(#Predicate<Trip> { trip in trip.deletedAt == nil})
            
            
            trips.sort {
                if $0.status.order() == $1.status.order() {
                    return $0.createdAt > $1.createdAt
                }
                return $0.status.order() < $1.status.order()
            }
            
            return trips
            
        } catch {
            print("Failed to fetch trips: \(error.localizedDescription)")
            return []
        }
    }
    
    private func syncTrips() async {
        isSyncing = true
        let apiClient = APIClient(baseUrl: appState.apiBaseUrl, token: appState.token)
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
