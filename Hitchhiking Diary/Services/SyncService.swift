import Foundation
import SwiftData
import MapKit

actor ErrorCollector {
    private(set) var errors: [Error] = []

    func add(_ error: Error) {
        errors.append(error)
    }
}

class SyncService {
    private let apiClient: APIClient
    private let lastSyncAt: Date?
    private let storageService: StorageService
    
    init(apiClient: APIClient, container: ModelContainer, lastSyncAt: Date? = nil) {
        self.storageService = StorageService(modelContainer: container)
        self.apiClient = apiClient
        self.lastSyncAt = lastSyncAt
    }
    
    func sync(completion: @escaping (Result<Void, Error>) -> Void) async {
        NSLog("Sync: Started")
        
        let trips = await storageService.fetchTrips(lastSyncAt: self.lastSyncAt)
        let records = await storageService.fetchTripRecords(lastSyncAt: self.lastSyncAt)
        let photos = await storageService.fetchPhotos(lastSyncAt: self.lastSyncAt)
        
        NSLog("Sync: Local cache loaded")
        
        let syncRequest = SyncRequestSchema(trips: trips, records: records, photos: photos, lastSyncAt: lastSyncAt)
        
        NSLog("Sync: SyncRequestSchema created")
        
        apiClient.sync(syncRequest: syncRequest) { result in
            switch result {
            case .success(let syncResponse):
                Task {
                    do {
                        try await self.updateLocalDatabase(with: syncResponse)
                        NSLog("Sync: Success")
                        completion(.success(()))
                    } catch {
                        NSLog("Sync: Failed updating local database and photos")
                        completion(.failure(error))
                    }
                }
            case .failure(let error):
                NSLog("Sync: Failed while performing sync request")
                completion(.failure(error))
            }
        }
    }
    
    private func uploadPhoto(photo: Photo) async throws -> PhotoDetailSchema {
        try await withCheckedThrowingContinuation { continuation in
            apiClient.uploadPhoto(photoId: photo.id, file: photo.content) { result in
                continuation.resume(with: result)
            }
        }
    }
    
    private func downloadPhoto(photoId: UUID) async throws -> Data {
        try await withCheckedThrowingContinuation { continuation in
            apiClient.downloadPhoto(photoId: photoId) { result in
                continuation.resume(with: result)
            }
        }
    }
    
    private func updateLocalDatabase(with syncResponse: SyncResponseSchema) async throws {
        let errorCollector = ErrorCollector()
        
        // Sync Trips
        await withTaskGroup(of: Void.self) { group in
            for item in syncResponse.trips {
                do {
                    NSLog("Sync: Processing Trip \(item.id)")
                    let trip = await self.storageService.getTrip(id: item.id) ?? Trip(
                        id: item.id,
                        title: item.title,
                        content: item.content ?? "",
                        status: item.status,
                        updatedAt: item.updatedAt,
                        deletedAt: item.deletedAt
                    )
                    
                    trip.title = item.title
                    trip.content = item.content ?? ""
                    trip.updatedAt = item.updatedAt
                    trip.deletedAt = item.deletedAt
                    
                    try await self.storageService.insert(model: trip)
                } catch {
                    await errorCollector.add(error)
                }
            }
        }
        
        // Sync TripRecords
        await withTaskGroup(of: Void.self) { group in
            for item in syncResponse.records {
                do {
                    NSLog("Sync: Processing TripRecord \(item.id)")
                    guard let trip = await self.storageService.getTrip(id: item.tripId) else {
                        await errorCollector.add(NSError(domain: "SyncService", code: 404, userInfo: [NSLocalizedDescriptionKey: "Trip not found"]))
                        return
                    }
                    
                    let record = await self.storageService.getTripRecord(id: item.id) ?? TripRecord(
                        id: item.id,
                        type: item.type,
                        content: item.content ?? "",
                        location: CLLocationCoordinate2D(latitude: item.latitude, longitude: item.longitude),
                        happenedAt: item.happenedAt,
                        updatedAt: item.updatedAt,
                        deletedAt: item.deletedAt
                    )
                    
                    record.type = item.type
                    record.content = item.content
                    record.location = CLLocationCoordinate2D(latitude: item.latitude, longitude: item.longitude)
                    record.happenedAt = item.happenedAt
                    record.updatedAt = item.updatedAt
                    record.deletedAt = item.deletedAt
                    
                    try await self.storageService.insert(model: record)
                    
                    record.trip = trip
                    
                    try await self.storageService.save()
                    
                    
                    
                    
//                        if record.trip == nil {
//                            trip.records.append(record)
//                            try await self.storageService.insert(model: trip)
//                        } else {
//                            try await self.storageService.insert(model: record)
//                        }
                } catch {
                    await errorCollector.add(error)
                }
            }
        }
        
        // Sync Photos
        await withTaskGroup(of: Void.self) { group in
            for item in syncResponse.photos {
                do {
                    NSLog("Sync: Processing Photo \(item.id)")
                    guard let record = await self.storageService.getTripRecord(id: item.recordId) else {
                        await errorCollector.add(NSError(domain: "SyncService", code: 404, userInfo: [NSLocalizedDescriptionKey: "TripRecord not found"]))
                        return
                    }
                    
                    if let photo = await self.storageService.getPhoto(id: item.id) {
                        photo.updatedAt = item.updatedAt
                        photo.deletedAt = item.deletedAt
                        photo.record = record
                        
                        if item.mime == nil {
                            NSLog("Sync: Performing upload")
                            let _ = try await self.uploadPhoto(photo: photo)
                        }
                        
                        try await self.storageService.insert(model: photo)
                    } else {
                        NSLog("Sync: Performing download")
                        let data = try await self.downloadPhoto(photoId: item.id)
                        let photo = Photo(id: item.id, content: data)
                        
                        try await self.storageService.insert(model: photo)
                        
                        photo.record = record
                        try await self.storageService.save()
                        
//                        record.photos.append(photo)
                        
                        
                    }
                } catch {
                    await errorCollector.add(error)
                }
            }
        }
        
        let collectedErrors = await errorCollector.errors
        if !collectedErrors.isEmpty {
            throw NSError(domain: "SyncService", code: 500, userInfo: [NSLocalizedDescriptionKey: "One or more errors occurred during sync"])
        }
    }
}
