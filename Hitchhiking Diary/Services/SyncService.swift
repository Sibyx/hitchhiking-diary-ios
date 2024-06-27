import Foundation
import SwiftData

class SyncService {
    private let apiClient: APIClient
    private let lastSyncAt: Date?
    private let modelContext: ModelContext
    
    init(apiClient: APIClient, modelContext: ModelContext, lastSyncAt: Date? = nil) {
        self.modelContext = modelContext
        self.apiClient = apiClient
        self.lastSyncAt = lastSyncAt
    }
    
    func sync(completion: @escaping (Result<Void, Error>) -> Void) {
        let trips = fetchTrips()
        let records = fetchTripRecords()
        let photos = fetchPhotos()
        
        let syncRequest = SyncRequestSchema(trips: trips, records: records, photos: photos, lastSyncAt: lastSyncAt)
        
        apiClient.sync(syncRequest: syncRequest) { result in
            switch result {
            case .success(let syncResponse):
                self.updateLocalDatabase(with: syncResponse)
                completion(.success(()))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    private func fetchTrips() -> [TripSyncSchema] {
        var descriptor = FetchDescriptor<Trip>()
    
        if let lastSyncAt = lastSyncAt {
            descriptor.predicate = #Predicate{
                $0.updatedAt >= lastSyncAt
            }
        }
        
        guard let trips = try? modelContext.fetch(descriptor) else {
            return []
        }
        
        return trips.map { TripSyncSchema(from: $0) }
    }
    
    private func fetchTripRecords() -> [TripRecordSyncSchema] {
        var descriptor = FetchDescriptor<TripRecord>()
    
        if let lastSyncAt = lastSyncAt {
            descriptor.predicate = #Predicate{
                $0.updatedAt >= lastSyncAt
            }
        }
        
        guard let records = try? modelContext.fetch(descriptor) else {
            return []
        }
        
        return records.map { TripRecordSyncSchema(from: $0) }
    }
    
    private func fetchPhotos() -> [PhotoSyncSchema] {
        var descriptor = FetchDescriptor<Photo>()
    
        if let lastSyncAt = lastSyncAt {
            descriptor.predicate = #Predicate{
                $0.updatedAt >= lastSyncAt
            }
        }
        
        guard let photos = try? modelContext.fetch(descriptor) else {
            return []
        }
        
        return photos.map { PhotoSyncSchema(from: $0) }
    }
    
    private func updateLocalDatabase(with syncResponse: SyncResponseSchema) {
        NSLog("Rceived response")
    }
}
