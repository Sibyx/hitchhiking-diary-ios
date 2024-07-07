import Foundation
import CoreLocation
import SwiftUI
import SwiftData
import AppIntents

enum TripRecordType: String, Codable, CaseIterable {
    case interesting
    case workout
    case camping
    case pickup
    case dropoff
    case story
    
    func title() -> String {
        switch self {
        case .interesting:
            return NSLocalizedString("Interesting", comment: "Trip Record Type: Interesting")
        case .camping:
            return NSLocalizedString("Camping", comment: "Trip Record Type: Camping")
        case .workout:
            return NSLocalizedString("Workout", comment: "Trip Record Type: Workout")
        case .pickup:
            return NSLocalizedString("Pickup", comment: "Trip Record Type: Pickup")
        case .dropoff:
            return NSLocalizedString("Dropoff", comment: "Trip Record Type: Dropoff")
        case .story:
            return NSLocalizedString("Story", comment: "Trip Record Type: Story")
        }
    }
    
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

extension TripRecordType: AppEnum {
    static var typeDisplayRepresentation: TypeDisplayRepresentation = "Trip Record Type"
    
    // FIXME: This sucks very much. Problem is, that I cannot cast Image (TripRecordType->icon()) to DisplayRepresentation.Image. Thats why no reduce() right now
    static var caseDisplayRepresentations: [TripRecordType: DisplayRepresentation] = [
        .interesting: DisplayRepresentation(title: "Interesting", image: DisplayRepresentation.Image(systemName: "star.fill")),
        .camping: DisplayRepresentation(title: "Camping", image: DisplayRepresentation.Image(systemName: "tent.fill")),
        .workout: DisplayRepresentation(title: "Workout", image: DisplayRepresentation.Image(systemName: "figure.hiking")),
        .pickup: DisplayRepresentation(title: "Pickup", image: DisplayRepresentation.Image(systemName: "figure.wave")),
        .dropoff: DisplayRepresentation(title: "Dropoff", image: DisplayRepresentation.Image(systemName: "car.top.door.front.right.open")),
        .story: DisplayRepresentation(title: "Story", image: DisplayRepresentation.Image(systemName: "pencil")),
    ]
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

    init(id: UUID = UUID(), type: TripRecordType, content: String, location: CLLocationCoordinate2D, happenedAt: Date = Date(), photos: [Photo] = [], createdAt: Date = Date(), updatedAt: Date = Date(), deletedAt: Date? = nil) {
        self.id = id
        self.type = type
        self.content = content
        self.location = location
        self.happenedAt = happenedAt
        self.photos = photos
        self.createdAt = createdAt
        self.updatedAt = updatedAt
        self.deletedAt = deletedAt
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
