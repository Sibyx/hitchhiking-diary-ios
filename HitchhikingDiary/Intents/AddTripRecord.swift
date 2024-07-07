import Foundation
import AppIntents
import CoreLocation

/**
 https://www.createwithswift.com/using-app-intents-swiftui-app/
 https://medium.com/@deisycmelo/how-to-add-siri-shortcut-actions-in-your-app-5c8d812b11f1
 https://medium.com/appcent/bring-shortcuts-support-to-your-ios-app-with-swiftui-ee35dc4bf551
 */
class IntentLocationManager: NSObject, ObservableObject, CLLocationManagerDelegate {
    var locationContinuation: CheckedContinuation<CLLocationCoordinate2D?, Error>?
    let manager = CLLocationManager()
    @Published var lastLocation: CLLocation?
    @Published var locationError: CLError?
    @Published var authorizationStatus: CLAuthorizationStatus

    override init() {
        self.authorizationStatus = manager.authorizationStatus
        super.init()
        manager.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyBest
        checkAuthorizationStatus()
    }

    func requestLocation() async throws -> CLLocationCoordinate2D? {
        try await withCheckedThrowingContinuation { continuation in
            locationContinuation = continuation
            manager.requestLocation()
        }
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        NSLog(String(describing: locations.first?.coordinate))
        locationContinuation?.resume(returning: locations.first?.coordinate)
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        NSLog(error.localizedDescription)
        locationContinuation?.resume(throwing: error)
    }
    
    func checkAuthorizationStatus() {
        switch manager.authorizationStatus {
        case .notDetermined, .authorizedWhenInUse:
            manager.requestAlwaysAuthorization()
        case .restricted, .denied:
            self.locationError = CLError(.denied)
        case .authorizedAlways:
            NSLog("startUpdatingLocation")
            manager.startUpdatingLocation()
        @unknown default:
            self.locationError = CLError(.locationUnknown)
        }
        self.authorizationStatus = manager.authorizationStatus
        NSLog(String(describing: manager.isAuthorizedForWidgetUpdates))
    }
}

struct AddTripRecord: AppIntent {
    static var title = LocalizedStringResource("Add a new trip record")
    
    @Parameter(title: "Trip")
    var trip: TripIntentItem
    
    @Parameter(title: "Record Type")
    var recordType: TripRecordType
    
    func perform() async throws -> some IntentResult {
        let locationManager = IntentLocationManager()
        
        let location = try await locationManager.requestLocation()
        
        guard let currentLocation = location else {
            return .result(value: "Failed to get current location")
        }
        
        let recordLocation = CLLocationCoordinate2D(latitude: currentLocation.latitude, longitude: currentLocation.longitude)
        
//        let record = TripRecord(type: recordType, content: "", location: recordLocation)
//        trip.records.append(record)
//        try! await SharedDatabase.shared.database.save()
        
        return .result(value: "Trip record successfuly saved!")
    }
}
