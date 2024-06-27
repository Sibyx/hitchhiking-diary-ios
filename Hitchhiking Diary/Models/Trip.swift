import Foundation
import CoreLocation
import SwiftData
import SwiftUI

enum TripStatus: String, Codable, CaseIterable {
    case draft
    case inProgress = "in-progress"
    case archived
    
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
}

@Model
class Trip {
    @Attribute(.unique) var id: UUID
    var title: String
    var content: String
    var status: TripStatus
    var createdAt: Date
    var updatedAt: Date
    var deletedAt: Date? = nil
    @Relationship(deleteRule: .cascade, inverse: \TripRecord.trip) var records: [TripRecord]

    init(id: UUID = UUID(), title: String, content: String = "", status: TripStatus = .draft, records: [TripRecord] = [], createdAt: Date = Date(), updatedAt: Date = Date()) {
        self.id = id
        self.title = title
        self.content = content
        self.status = status
        self.records = records
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }
}
