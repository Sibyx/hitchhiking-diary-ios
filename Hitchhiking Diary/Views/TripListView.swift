import SwiftUI
import SwiftData

struct TripListView: View {
    @EnvironmentObject var appState: AppState
    @Environment(\.modelContext) var modelContext
    
    @Query(sort: \Trip.createdAt, order: .reverse) var trips: [Trip]

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
            modelContext.delete(trip)
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
