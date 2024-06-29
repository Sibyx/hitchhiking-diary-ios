import SwiftData
import Foundation

/**
 Not great. Not terrible.
 I love the guy who wrote the blogpost bellow. Resolved so many issues.
 https://jacobbartlett.substack.com/p/swiftdata-outside-swiftui
 */

final actor StorageService {
    func fetchTrips(lastSyncAt: Date?) async -> [TripSyncSchema] {
        var descriptor = FetchDescriptor<Trip>()
    
        if let lastSyncAt = lastSyncAt {
            descriptor.predicate = #Predicate {
                $0.updatedAt >= lastSyncAt
            }
        }
        
        guard let trips = try? await SharedDatabase.shared.database.fetch(descriptor) else {
            return []
        }
        
        return trips.map { TripSyncSchema(from: $0) }
    }
    
    func fetchTripRecords(lastSyncAt: Date?) async -> [TripRecordSyncSchema] {
        var descriptor = FetchDescriptor<TripRecord>()
    
        if let lastSyncAt = lastSyncAt {
            descriptor.predicate = #Predicate {
                $0.updatedAt >= lastSyncAt
            }
        }
        
        guard let records = try? await SharedDatabase.shared.database.fetch(descriptor) else {
            return []
        }
        
        return records.map { TripRecordSyncSchema(from: $0) }
    }
    
    func fetchPhotos(lastSyncAt: Date?) async -> [PhotoSyncSchema] {
        var descriptor = FetchDescriptor<Photo>()
    
        if let lastSyncAt = lastSyncAt {
            descriptor.predicate = #Predicate {
                $0.updatedAt >= lastSyncAt
            }
        }
        
        guard let photos = try? await SharedDatabase.shared.database.fetch(descriptor) else {
            return []
        }
        
        return photos.map { PhotoSyncSchema(from: $0) }
    }
    
    func getTrip(id: UUID) async -> Trip? {
        let predicate = #Predicate<Trip> { object in
            object.id == id
        }
        
        var descriptor = FetchDescriptor(predicate: predicate)
        descriptor.fetchLimit = 1
        
        do {
            let object = try await SharedDatabase.shared.database.fetch(descriptor)
            return object.first
        } catch {
            return nil
        }
    }
    
    func getTripRecord(id: UUID) async -> TripRecord? {
        let predicate = #Predicate<TripRecord> { object in
            object.id == id
        }
        
        var descriptor = FetchDescriptor(predicate: predicate)
        descriptor.fetchLimit = 1
        
        do {
            let object = try await SharedDatabase.shared.database.fetch(descriptor)
            return object.first
        } catch {
            return nil
        }
    }
    
    func getPhoto(id: UUID) async -> Photo? {
        let predicate = #Predicate<Photo> { object in
            object.id == id
        }
        
        var descriptor = FetchDescriptor(predicate: predicate)
        descriptor.fetchLimit = 1
        
        do {
            let object = try await SharedDatabase.shared.database.fetch(descriptor)
            return object.first
        } catch {
            return nil
        }
    }
    
    func insert(model: any PersistentModel) async throws -> Void {
        await SharedDatabase.shared.database.insert(model)
    }
    
    func save() async throws -> Void {
        try await SharedDatabase.shared.database.save()
    }
}
