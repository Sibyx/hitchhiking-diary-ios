import SwiftUI
import MapKit

struct TripRecordDetailView: View {
    var tripRecord: TripRecord
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                Text(tripRecord.type.rawValue)
                    .font(.largeTitle)
                    .fontWeight(.bold)
                
                Text(tripRecord.description)
                    .font(.body)
                
                SingleCoordinateMapView(coordinate: tripRecord.location)
                    .frame(height: 300)
                    .cornerRadius(10)
                
                if !tripRecord.photos.isEmpty {
                    Text("Photos")
                        .font(.headline)
                    
                    ScrollView(.horizontal) {
                        HStack {
                            ForEach(tripRecord.photos, id: \.self) { photo in
                                Image(uiImage: UIImage(contentsOfFile: photo) ?? UIImage())
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 200, height: 200)
                                    .cornerRadius(10)
                                    .padding(.trailing, 10)
                            }
                        }
                    }
                }
            }
            .padding()
        }
        .navigationTitle("Record Details")
    }
}

struct TripRecordDetailView_Previews: PreviewProvider {
    static var previews: some View {
        let sampleTrip = Trip(name: "Sample Trip", createdAt: Date(), updatedAt: Date())
        let sampleRecord = TripRecord(
            tripId: sampleTrip.id,
            type: .camping,
            description: "A beautiful night under the stars by the lake.",
            location: CLLocationCoordinate2D(latitude: 34.0522, longitude: -118.2437),
            photos: []
        )
        TripRecordDetailView(tripRecord: sampleRecord)
    }
}
