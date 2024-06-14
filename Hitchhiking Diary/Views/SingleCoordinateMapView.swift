import SwiftUI
import MapKit

struct SingleCoordinateMapView: UIViewRepresentable {
    var coordinate: CLLocationCoordinate2D

    func makeUIView(context: Context) -> MKMapView {
        MKMapView(frame: .zero)
    }

    func updateUIView(_ view: MKMapView, context: Context) {
        view.removeAnnotations(view.annotations)
        
        let annotation = MKPointAnnotation()
        annotation.coordinate = coordinate
        view.addAnnotation(annotation)
        
        let region = MKCoordinateRegion(
            center: coordinate,
            span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
        )
        view.setRegion(region, animated: true)
    }
}

struct SingleCoordinateMapView_Previews: PreviewProvider {
    static var previews: some View {
        SingleCoordinateMapView(coordinate: CLLocationCoordinate2D(latitude: 34.0522, longitude: -118.2437))
    }
}
