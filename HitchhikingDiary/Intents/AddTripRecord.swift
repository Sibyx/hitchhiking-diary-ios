import Foundation
import AppIntents
import CoreLocation
import SwiftData

struct AddTripRecord: AppIntent {
    static var title = LocalizedStringResource("Save Trip Record")
    
    @Parameter(title: "Trip")
    var trip: TripIntentItem
    
    @Parameter(title: "Record Type")
    var recordType: TripRecordType
    
    @Parameter(title: "Latitude", default: 0.0)
    var latitude: Double
    
    @Parameter(title: "Longitude", default: 0.0)
    var longitude: Double
    
    func perform() async throws -> some IntentResult {
        let storageService = StorageService()
        let location = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
        let record = TripRecord(type: recordType, content: "", location: location)
        
        let tripObject = await storageService.getTrip(id: trip.id)
        tripObject?.records.append(record)
        try! await SharedDatabase.shared.database.save()
        
        return .result()
    }
}
