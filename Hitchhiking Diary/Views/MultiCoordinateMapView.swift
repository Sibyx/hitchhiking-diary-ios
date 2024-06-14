import SwiftUI
import MapKit

struct MultiCoordinateMapView: UIViewRepresentable {
    var tripRecords: [TripRecord]

    func makeUIView(context: Context) -> MKMapView {
        MKMapView(frame: .zero)
    }

    func updateUIView(_ view: MKMapView, context: Context) {
        view.removeAnnotations(view.annotations)
        
        let annotations = tripRecords.map { record -> MKPointAnnotation in
            let annotation = MKPointAnnotation()
            annotation.coordinate = record.location
            annotation.title = record.type.rawValue
            annotation.subtitle = dateFormatter.string(from: record.createdAt)
            return annotation
        }
        
        view.addAnnotations(annotations)
        
        if let firstRecord = tripRecords.first {
            let region = MKCoordinateRegion(
                center: firstRecord.location,
                span: MKCoordinateSpan(latitudeDelta: 0.5, longitudeDelta: 0.5)
            )
            view.setRegion(region, animated: true)
        }
    }
}

struct MultiCoordinateMapView_Previews: PreviewProvider {
    static var previews: some View {
        let sampleTrip = Trip(name: "Sample Trip", createdAt: Date(), updatedAt: Date())
        return MultiCoordinateMapView(tripRecords: [
            TripRecord(tripId: sampleTrip.id, type: .pickup, description: "Picked up by a kind driver.", location: CLLocationCoordinate2D(latitude: 37.7749, longitude: -122.4194), createdAt: Date().addingTimeInterval(-3600)),
            TripRecord(tripId: sampleTrip.id, type: .camping, description: "Camped by the river.", location: CLLocationCoordinate2D(latitude: 34.0522, longitude: -118.2437), createdAt: Date().addingTimeInterval(-7200))
        ])
    }
}
