import SwiftUI
import SwiftData

struct TripListView: View {
    @EnvironmentObject var appState: AppState
    @Environment(\.database) private var database
    
    @State var trips: [Trip] = []

    var body: some View {
        List {
            ForEach(trips) {
                trip in NavigationLink(value: trip) {
                    Text(trip.title)
                }
            }
            .onDelete{offsets in
                Task {
                    for offset in offsets {
                        let trip = trips[offset]
                        trip.updatedAt = Date()
                        trip.deletedAt = Date()
                        await database.insert(trip)
                    }
                }
            }
        }
        .task {
            if (trips.isEmpty) {
                do {
                    trips = try await database.fetch(#Predicate<Trip> { trip in
                        trip.deletedAt == nil
                    })
                } catch {
                    print("Failed to fetch trips: \(error.localizedDescription)")
                }
            }
        }
        .refreshable {
            do {
                trips = try await database.fetch(#Predicate<Trip> { trip in
                    trip.deletedAt == nil
                })
            } catch {
                print("Failed to fetch trips: \(error.localizedDescription)")
            }
        }
    }
}
