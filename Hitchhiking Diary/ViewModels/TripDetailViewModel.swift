import SwiftUI

class TripDetailViewModel: ObservableObject {
    @Published var tripRecords: [TripRecord] = []
    @Published var showingNewTripRecordView = false

    func fetchTripRecords(for trip: Trip) {
        // Fetch trip records from data source (local storage, database, etc.)
        // For now, we will use some mock data
        self.tripRecords = [
            TripRecord(tripId: trip.id, type: .pickup, description: "Picked up by a kind driver.", location: .init(latitude: 37.7749, longitude: -122.4194)),
            TripRecord(tripId: trip.id, type: .camping, description: "Camped by the river.", location: .init(latitude: 34.0522, longitude: -118.2437))
        ]
    }

    func addTripRecord(tripRecord: TripRecord) {
        tripRecords.append(tripRecord)
        // Save new trip record to data source
    }
}
