import Foundation
import CoreLocation

class Persistence: ObservableObject {
    @Published var trips: [Trip] = []
    @Published var tripRecords: [UUID: [TripRecord]] = [:]
    
    private let tripsKey = "trips"
    private let tripRecordsKey = "tripRecords"
    
    init() {
        loadTrips()
        loadTripRecords()
    }
    
    private func loadTrips() {
        if let data = UserDefaults.standard.data(forKey: tripsKey),
           let savedTrips = try? JSONDecoder().decode([Trip].self, from: data) {
            self.trips = savedTrips
        }
    }
    
    private func loadTripRecords() {
        if let data = UserDefaults.standard.data(forKey: tripRecordsKey),
           let savedTripRecords = try? JSONDecoder().decode([UUID: [TripRecord]].self, from: data) {
            self.tripRecords = savedTripRecords
        }
    }
    
    private func saveTrips() {
        if let data = try? JSONEncoder().encode(trips) {
            UserDefaults.standard.set(data, forKey: tripsKey)
        }
    }
    
    private func saveTripRecords() {
        if let data = try? JSONEncoder().encode(tripRecords) {
            UserDefaults.standard.set(data, forKey: tripRecordsKey)
        }
    }
    
    func addTrip(_ trip: Trip) {
        var newTrip = trip
        newTrip.createdAt = Date()
        newTrip.updatedAt = Date()
        trips.append(newTrip)
        saveTrips()
    }
    
    func updateTrip(_ trip: Trip) {
        if let index = trips.firstIndex(where: { $0.id == trip.id }) {
            var updatedTrip = trip
            updatedTrip.updatedAt = Date()
            trips[index] = updatedTrip
            saveTrips()
        }
    }
    
    func addTripRecord(_ record: TripRecord) {
        var newRecord = record
        newRecord.createdAt = Date()
        newRecord.updatedAt = Date()
        
        if tripRecords[newRecord.tripId] == nil {
            tripRecords[newRecord.tripId] = []
        }
        tripRecords[newRecord.tripId]?.append(newRecord)
        saveTripRecords()
    }
    
    func updateTripRecord(_ record: TripRecord) {
        if var records = tripRecords[record.tripId],
           let index = records.firstIndex(where: { $0.id == record.id }) {
            var updatedRecord = record
            updatedRecord.updatedAt = Date()
            records[index] = updatedRecord
            tripRecords[record.tripId] = records
            saveTripRecords()
        }
    }
    
    func removeTrip(_ trip: Trip) {
        if let index = trips.firstIndex(where: { $0.id == trip.id }) {
            trips.remove(at: index)
            tripRecords[trip.id] = nil
            saveTrips()
            saveTripRecords()
        }
    }
    
    func sortedTrips() -> [Trip] {
        return trips.sorted {
            let records1 = tripRecords[$0.id] ?? []
            let records2 = tripRecords[$1.id] ?? []
            return $0.lastUpdate(records: records1) > $1.lastUpdate(records: records2)
        }
    }
    
    func deleteAll() {
        trips = []
        tripRecords = [:]
        UserDefaults.standard.removeObject(forKey: tripsKey)
        UserDefaults.standard.removeObject(forKey: tripRecordsKey)
    }
    
    func preloadData() {
        deleteAll()
        
        let sampleTrip = Trip(name: "Sample Trip")
        addTrip(sampleTrip)
        
        let tripRecords = [
            TripRecord(tripId: sampleTrip.id, type: .pickup, description: "Picked up by a kind driver.", location: CLLocationCoordinate2D(latitude: 37.7749, longitude: -122.4194), createdAt: Date().addingTimeInterval(-3600)),
            TripRecord(tripId: sampleTrip.id, type: .camping, description: "Camped by the river.", location: CLLocationCoordinate2D(latitude: 34.0522, longitude: -118.2437), createdAt: Date().addingTimeInterval(-7200)),
            TripRecord(tripId: sampleTrip.id, type: .interesting, description: "Visited a beautiful waterfall.", location: CLLocationCoordinate2D(latitude: 36.7783, longitude: -119.4179), createdAt: Date().addingTimeInterval(-10800))
        ]
        
        for record in tripRecords {
            addTripRecord(record)
        }
    }
}
