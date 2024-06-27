import Foundation
import CryptoKit
import SwiftData

@Model
class Photo {
    @Attribute(.unique) var id: UUID
    var record: TripRecord?
    var checksum: String
    @Attribute(.externalStorage) var content: Data
    var createdAt: Date
    var updatedAt: Date
    var deletedAt: Date? = nil

    init(id: UUID = UUID(), content: Data, createdAt: Date = Date(), updatedAt: Date = Date()) {
        self.id = id
        self.checksum = SHA256.hash(data: content).compactMap { String(format: "%02x", $0) }.joined()
        self.content = content
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }
}
