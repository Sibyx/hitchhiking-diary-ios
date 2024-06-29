import SwiftData
import Foundation

/**
 To be honest. I have no idea what I am doing here. Trying to have it in "it just work state".
 I am sorry for everybody who read this. If you have a better solution for thread-safety I beg you offer a PR and teach me a lesson.
 @link https://medium.com/@abozaid.ibrahim11/thread-safety-in-swift-a-comparison-of-locking-strategies-locks-vs-lock-free-70e872ac8e29
 */
class StorageService {
    private let modelContext: ModelContext
    private let lock = NSLock()
    
    init(modelContext: ModelContext) {
        self.modelContext = modelContext
    }
 
    func fetchTrips(lastSyncAt: Date?) -> [TripSyncSchema] {
        var descriptor = FetchDescriptor<Trip>()
    
        if let lastSyncAt = lastSyncAt {
            descriptor.predicate = #Predicate {
                $0.updatedAt >= lastSyncAt
            }
        }
        
        lock.lock()
        defer {lock.unlock()}
        guard let trips = try? modelContext.fetch(descriptor) else {
            return []
        }
        
        return trips.map { TripSyncSchema(from: $0) }
    }
    
    func fetchTripRecords(lastSyncAt: Date?) -> [TripRecordSyncSchema] {
        var descriptor = FetchDescriptor<TripRecord>()
    
        if let lastSyncAt = lastSyncAt {
            descriptor.predicate = #Predicate {
                $0.updatedAt >= lastSyncAt
            }
        }
        
        lock.lock()
        defer {lock.unlock()}
        guard let records = try? modelContext.fetch(descriptor) else {
            return []
        }
        
        return records.map { TripRecordSyncSchema(from: $0) }
    }
    
    func fetchPhotos(lastSyncAt: Date?) -> [PhotoSyncSchema] {
        var descriptor = FetchDescriptor<Photo>()
    
        if let lastSyncAt = lastSyncAt {
            descriptor.predicate = #Predicate {
                $0.updatedAt >= lastSyncAt
            }
        }
        
        lock.lock()
        defer {lock.unlock()}
        guard let photos = try? modelContext.fetch(descriptor) else {
            return []
        }
        
        return photos.map { PhotoSyncSchema(from: $0) }
    }
    
    func getTrip(id: UUID) -> Trip? {
        let predicate = #Predicate<Trip> { object in
            object.id == id
        }
        
        var descriptor = FetchDescriptor(predicate: predicate)
        descriptor.fetchLimit = 1
        
        do {
            lock.lock()
            defer {lock.unlock()}
            let object = try modelContext.fetch(descriptor)
            return object.first
        } catch {
            return nil
        }
    }
    
    func getTripRecord(id: UUID) -> TripRecord? {
        let predicate = #Predicate<TripRecord> { object in
            object.id == id
        }
        
        var descriptor = FetchDescriptor(predicate: predicate)
        descriptor.fetchLimit = 1
        
        do {
            lock.lock()
            defer {lock.unlock()}
            let object = try modelContext.fetch(descriptor)
            return object.first
        } catch {
            return nil
        }
    }
    
    func getPhoto(id: UUID) -> Photo? {
        let predicate = #Predicate<Photo> { object in
            object.id == id
        }
        
        var descriptor = FetchDescriptor(predicate: predicate)
        descriptor.fetchLimit = 1
        
        do {
            lock.lock()
            defer {lock.unlock()}
            let object = try modelContext.fetch(descriptor)
            return object.first
        } catch {
            return nil
        }
    }
    
    func insert(model: any PersistentModel) -> Void {
        lock.lock()
        defer {lock.unlock()}
        modelContext.insert(model)
    }
}
