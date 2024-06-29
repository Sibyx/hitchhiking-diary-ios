import Foundation
import CryptoKit
import SwiftData

@Model
class Photo {
    @Attribute(.unique) var id: UUID
    var record: TripRecord?
    @Attribute(.externalStorage) var content: Data
    var createdAt: Date
    var updatedAt: Date
    var deletedAt: Date? = nil

    init(id: UUID = UUID(), content: Data, createdAt: Date = Date(), updatedAt: Date = Date(), deletedAt: Date? = nil) {
        self.id = id
        self.content = content
        self.createdAt = createdAt
        self.updatedAt = updatedAt
        self.deletedAt = deletedAt
    }
}
