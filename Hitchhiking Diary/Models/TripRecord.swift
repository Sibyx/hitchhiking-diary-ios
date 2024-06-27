import Foundation
import CoreLocation
import SwiftUI
import SwiftData

enum TripRecordType: String, Codable, CaseIterable {
    case interesting = "Interesting"
    case workout = "Workout"
    case camping = "Camping"
    case pickup = "Pickup"
    case dropoff = "Dropoff"
    case story = "Story"
    
    func icon() -> Image {
        switch self {
        case .interesting:
            return Image(systemName: "star.fill")
        case .camping:
            return Image(systemName: "tent.fill")
        case .workout:
            return Image(systemName: "figure.hiking")
        case .pickup:
            return Image(systemName: "figure.wave")
        case .dropoff:
            return Image(systemName: "car.top.door.front.right.open")
        case .story:
            return Image(systemName: "pencil")
        }
    }
}

@Model
class TripRecord {
    @Attribute(.unique) var id: UUID
    var type: TripRecordType
    var trip: Trip?
    var content: String?
    var location: CLLocationCoordinate2D
    var happenedAt: Date
    @Relationship(deleteRule: .cascade, inverse: \Photo.record) var photos: [Photo]
    var createdAt: Date
    var updatedAt: Date
    var deletedAt: Date? = nil

    init(id: UUID = UUID(), type: TripRecordType, content: String, location: CLLocationCoordinate2D, happenedAt: Date = Date(), photos: [Photo] = [], createdAt: Date = Date(), updatedAt: Date = Date()) {
        self.id = id
        self.type = type
        self.content = content
        self.location = location
        self.happenedAt = happenedAt
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
