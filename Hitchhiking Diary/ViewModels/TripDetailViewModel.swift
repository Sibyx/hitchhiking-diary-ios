import SwiftUI

class TripDetailViewModel: ObservableObject {
    @Published var tripRecords: [TripRecord] = []
    @Published var showingNewTripRecordView = false
    private let persistence = Persistence()
    
    func fetchTripRecords(for trip: Trip) {
        self.tripRecords = persistence.tripRecords[trip.id] ?? []
    }
    
    func addTripRecord(tripRecord: TripRecord) {
        persistence.addTripRecord(tripRecord)
        fetchTripRecords(for: tripRecord.tripId) // Refresh the list
    }

    func updateTripRecord(tripRecord: TripRecord) {
        persistence.updateTripRecord(tripRecord)
        fetchTripRecords(for: tripRecord.tripId) // Refresh the list
    }

    private func fetchTripRecords(for tripId: UUID) {
        self.tripRecords = persistence.tripRecords[tripId] ?? []
    }
}
