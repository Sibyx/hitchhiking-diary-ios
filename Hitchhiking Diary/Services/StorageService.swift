import SwiftData
import Foundation

/**
 Not great. Not terrible.
 I love the guy who wrote the blogpost bellow. Resolved so many issues.
 https://jacobbartlett.substack.com/p/swiftdata-outside-swiftui
 */
@ModelActor
final actor StorageService: ModelActor {
    func fetchTrips(lastSyncAt: Date?) -> [TripSyncSchema] {
//        let context = ModelContext(self.modelContainer)
        var descriptor = FetchDescriptor<Trip>()
    
        if let lastSyncAt = lastSyncAt {
            descriptor.predicate = #Predicate {
                $0.updatedAt >= lastSyncAt
            }
        }
        
        guard let trips = try? modelContext.fetch(descriptor) else {
            return []
        }
        
        return trips.map { TripSyncSchema(from: $0) }
    }
    
    func fetchTripRecords(lastSyncAt: Date?) -> [TripRecordSyncSchema] {
//        let context = ModelContext(self.modelContainer)
        var descriptor = FetchDescriptor<TripRecord>()
    
        if let lastSyncAt = lastSyncAt {
            descriptor.predicate = #Predicate {
                $0.updatedAt >= lastSyncAt
            }
        }
        
        guard let records = try? modelContext.fetch(descriptor) else {
            return []
        }
        
        return records.map { TripRecordSyncSchema(from: $0) }
    }
    
    func fetchPhotos(lastSyncAt: Date?) -> [PhotoSyncSchema] {
//        let context = ModelContext(self.modelContainer)
        var descriptor = FetchDescriptor<Photo>()
    
        if let lastSyncAt = lastSyncAt {
            descriptor.predicate = #Predicate {
                $0.updatedAt >= lastSyncAt
            }
        }
        
        guard let photos = try? modelContext.fetch(descriptor) else {
            return []
        }
        
        return photos.map { PhotoSyncSchema(from: $0) }
    }
    
    func getTrip(id: UUID) -> Trip? {
//        let context = ModelContext(self.modelContainer)
        let predicate = #Predicate<Trip> { object in
            object.id == id
        }
        
        var descriptor = FetchDescriptor(predicate: predicate)
        descriptor.fetchLimit = 1
        
        do {
            let object = try modelContext.fetch(descriptor)
            return object.first
        } catch {
            return nil
        }
    }
    
    func getTripRecord(id: UUID) -> TripRecord? {
//        let context = ModelContext(self.modelContainer)
        let predicate = #Predicate<TripRecord> { object in
            object.id == id
        }
        
        var descriptor = FetchDescriptor(predicate: predicate)
        descriptor.fetchLimit = 1
        
        do {
            let object = try modelContext.fetch(descriptor)
            return object.first
        } catch {
            return nil
        }
    }
    
    func getPhoto(id: UUID) -> Photo? {
//        let context = ModelContext(self.modelContainer)
        let predicate = #Predicate<Photo> { object in
            object.id == id
        }
        
        var descriptor = FetchDescriptor(predicate: predicate)
        descriptor.fetchLimit = 1
        
        do {
            let object = try modelContext.fetch(descriptor)
            return object.first
        } catch {
            return nil
        }
    }
    
    func insert(model: any PersistentModel) throws -> Void {
//        let context = ModelContext(self.modelContainer)
        modelContext.insert(model)
//        try context.save()
    }
    
    func save() throws -> Void {
//        let context = ModelContext(self.modelContainer)
        try modelContext.save()
    }
}
