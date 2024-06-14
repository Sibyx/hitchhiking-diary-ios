import Foundation
import CoreLocation
import SwiftUI

enum TripRecordType: String, Codable, CaseIterable {
    case interesting = "Interesting"
    case camping = "Camping"
    case pickup = "Pickup"
    case dropoff = "Dropoff"
    
    func icon() -> Image {
        switch self {
        case .interesting:
            return Image(systemName: "star.fill")
        case .camping:
            return Image(systemName: "tent.fill")
        case .pickup:
            return Image(systemName: "car.fill")
        case .dropoff:
            return Image(systemName: "car.2.fill")
        }
    }
}

struct TripRecord: Identifiable, Codable {
    var id: UUID
    var tripId: UUID
    var type: TripRecordType
    var description: String
    var location: CLLocationCoordinate2D
    var photos: [String]
    var createdAt: Date
    var updatedAt: Date

    init(tripId: UUID, type: TripRecordType, description: String, location: CLLocationCoordinate2D, photos: [String] = [], createdAt: Date = Date(), updatedAt: Date = Date()) {
        self.id = UUID()
        self.tripId = tripId
        self.type = type
        self.description = description
        self.location = location
        self.photos = photos
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }
}

// Extension to conform to Codable for CLLocationCoordinate2D
extension CLLocationCoordinate2D: Codable {
    enum CodingKeys: String, CodingKey {
        case latitude
        case longitude
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(latitude, forKey: .latitude)
        try container.encode(longitude, forKey: .longitude)
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let latitude = try container.decode(CLLocationDegrees.self, forKey: .latitude)
        let longitude = try container.decode(CLLocationDegrees.self, forKey: .longitude)
        self.init(latitude: latitude, longitude: longitude)
    }
}
