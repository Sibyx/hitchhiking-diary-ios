import SwiftUI
import SwiftData

struct TripListView: View {
    @EnvironmentObject var appState: AppState
    @Environment(\.modelContext) var modelContext
    
    @Query(filter: #Predicate<Trip> { trip in
        trip.deletedAt == nil
    }, sort: \Trip.createdAt, order: .reverse) var trips: [Trip]

    var body: some View {
        List {
            ForEach(trips) {
                trip in NavigationLink(value: trip) {
                    Text(trip.title)
                }
            }
            .onDelete(perform: deleteTrip)
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
