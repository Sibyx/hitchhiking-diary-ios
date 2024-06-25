import Foundation
import CryptoKit
import SwiftData

@Model
class Photo {
    @Attribute(.unique) var id: UUID
    var record: TripRecord?
    var hash: String
    @Attribute(.externalStorage) var content: Data
    var createdAt: Date

    init(id: UUID = UUID(), content: Data, createdAt: Date = Date()) {
        self.id = id
        self.hash = SHA256.hash(data: content).compactMap { String(format: "%02x", $0) }.joined()
        self.content = content
        self.createdAt = createdAt
    }
}
