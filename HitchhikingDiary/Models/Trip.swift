import Foundation
import CoreLocation
import SwiftData
import SwiftUI
import AppIntents

enum TripStatus: String, Codable, CaseIterable {
    case inProgress = "in-progress"
    case draft
    case archived
    
    func title() -> String {
        switch self {
        case .draft:
            return NSLocalizedString("Draft", comment: "Trip Status: Interesting")
        case .inProgress:
            return NSLocalizedString("In-progress", comment: "Trip Status: In-progress")
        case .archived:
            return NSLocalizedString("Archived", comment: "Trip Status: Archived")
        }
    }
    
    func icon() -> Image {
        switch self {
        case .draft:
            return Image(systemName: "paperplane")
        case .inProgress:
            return Image(systemName: "point.bottomleft.forward.to.point.topright.scurvepath")
        case .archived:
            return Image(systemName: "archivebox")
        }
    }
    
    func order() -> Int {
        switch self {
        case .inProgress:
            return 0
        case .draft:
            return 1
        case .archived:
            return 2
        }
    }
}

@Model
final class Trip {
    @Attribute(.unique) var id: UUID
    var title: String
    var content: String
    var status: TripStatus
    var createdAt: Date
    var updatedAt: Date
    var deletedAt: Date? = nil
    @Relationship(deleteRule: .cascade, inverse: \TripRecord.trip) var records: [TripRecord]

    init(id: UUID = UUID(), title: String, content: String = "", status: TripStatus = .draft, records: [TripRecord] = [], createdAt: Date = Date(), updatedAt: Date = Date(), deletedAt: Date? = nil) {
        self.id = id
        self.title = title
        self.content = content
        self.status = status
        self.records = records
        self.createdAt = createdAt
        self.updatedAt = updatedAt
        self.deletedAt = deletedAt
    }
}

struct TripIntentItem: Identifiable {
    var id: UUID = UUID()
    var title: String
}


extension TripIntentItem: AppEntity {
    static var typeDisplayRepresentation: TypeDisplayRepresentation = "Trip"
    
    var displayRepresentation: DisplayRepresentation {
        .init(title: LocalizedStringResource(stringLiteral: title))
    }
    
    static var defaultQuery = TripIntentQuery()
}

struct TripIntentQuery: EntityQuery {
    func entities(for identifiers: [UUID]) async throws -> [TripIntentItem] {
        try! await SharedDatabase.shared.database.fetch(#Predicate<Trip> { trip in
            identifiers.contains(trip.id)
        }).compactMap {
            TripIntentItem(id: $0.id, title: $0.title)
        }
    }
    
    func suggestedEntities() async throws -> [TripIntentItem] {
        
        return try await SharedDatabase.shared.database
            .fetch(#Predicate<Trip> { trip in trip.deletedAt == nil})
            .filter({$0.status == TripStatus.inProgress})
            .compactMap {
                TripIntentItem(id: $0.id, title: $0.title)
            }
    }
}
