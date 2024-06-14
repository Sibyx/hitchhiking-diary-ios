import SwiftUI
import CoreLocation

struct TripListItemView: View {
    var trip: Trip
    var records: [TripRecord]

    var body: some View {
        VStack(alignment: .leading, spacing: 5) {
            Text(trip.name)
                .font(.headline)

            Text("Records: \(records.count)")
                .font(.subheadline)
                .foregroundColor(.secondary)

            if let lastRecord = records.sorted(by: { $0.createdAt > $1.createdAt }).first {
                Text("Last Update: \(lastRecord.createdAt, formatter: dateFormatter)")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }

            Text("Duration: \(trip.duration(records: records))")
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
        .padding(.vertical, 10)
    }
}

struct TripListItemView_Previews: PreviewProvider {
    static var previews: some View {
        let sampleTrip = Trip(name: "Sample Trip", createdAt: Date(), updatedAt: Date())
        let tripRecords = [
            TripRecord(tripId: sampleTrip.id, type: .pickup, description: "Picked up by a kind driver.", location: CLLocationCoordinate2D(latitude: 37.7749, longitude: -122.4194), createdAt: Date().addingTimeInterval(-3600)),
            TripRecord(tripId: sampleTrip.id, type: .camping, description: "Camped by the river.", location: CLLocationCoordinate2D(latitude: 34.0522, longitude: -118.2437), createdAt: Date().addingTimeInterval(-7200)),
            TripRecord(tripId: sampleTrip.id, type: .interesting, description: "Visited a beautiful waterfall.", location: CLLocationCoordinate2D(latitude: 36.7783, longitude: -119.4179), createdAt: Date().addingTimeInterval(-10800))
        ]
        TripListItemView(trip: sampleTrip, records: tripRecords)
            .padding()
            .previewLayout(.sizeThatFits)
    }
}
