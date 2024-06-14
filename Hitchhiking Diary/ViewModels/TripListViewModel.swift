import SwiftUI

class TripListViewModel: ObservableObject {
    @Published var trips: [Trip] = []
    @Published var showingTripFormView = false
    @Published var tripToEdit: Trip? = nil
    @ObservedObject var persistence = Persistence()
    
    init() {
        fetchTrips()
    }
    
    func fetchTrips() {
        self.trips = persistence.sortedTrips()
    }
    
    func addTrip(name: String) {
        let newTrip = Trip(name: name)
        persistence.addTrip(newTrip)
        fetchTrips() // Refresh the list
    }
    
    func editTrip(_ trip: Trip) {
        self.tripToEdit = trip
        self.showingTripFormView = true
    }
    
    func updateTrip(_ trip: Trip) {
        persistence.updateTrip(trip)
        fetchTrips() // Refresh the list
    }
    
    func removeTrip(_ trip: Trip) {
        persistence.removeTrip(trip)
        fetchTrips() // Refresh the list
    }
}
