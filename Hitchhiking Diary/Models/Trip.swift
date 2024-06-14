import Foundation

struct Trip: Identifiable, Codable {
    var id: UUID
    var name: String
    var createdAt: Date
    var updatedAt: Date

    init(name: String, createdAt: Date = Date(), updatedAt: Date = Date()) {
        self.id = UUID()
        self.name = name
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }
    
    func duration(records: [TripRecord]) -> String {
        guard let first = records.first, let last = records.last else {
            return "N/A"
        }
        
        let duration = Calendar.current.dateComponents([.day], from: first.createdAt, to: last.createdAt)
        if let days = duration.day {
            return "\(days) days"
        }
        
        return "N/A"
    }
    
    func lastUpdate(records: [TripRecord]) -> Date {
        return records.sorted(by: { $0.createdAt > $1.createdAt }).first?.createdAt ?? createdAt
    }
}
