import Foundation
import SwiftData
import MapKit

class SyncService {
    private let apiClient: APIClient
    private let lastSyncAt: Date?
    private let storageService: StorageService
    
    init(apiClient: APIClient, modelContext: ModelContext, lastSyncAt: Date? = nil) {
        self.storageService = StorageService(modelContext: modelContext)
        self.apiClient = apiClient
        self.lastSyncAt = lastSyncAt
    }
    
    func sync(completion: @escaping (Result<Void, Error>) -> Void) {
        NSLog("Sync: Started")
        
        let trips = storageService.fetchTrips(lastSyncAt: self.lastSyncAt)
        let records = storageService.fetchTripRecords(lastSyncAt: self.lastSyncAt)
        let photos = storageService.fetchPhotos(lastSyncAt: self.lastSyncAt)
        
        NSLog("Sync: Local cache loaded")
        
        let syncRequest = SyncRequestSchema(trips: trips, records: records, photos: photos, lastSyncAt: lastSyncAt)
        
        NSLog("Sync: SyncRequestSchema created")
        
        apiClient.sync(syncRequest: syncRequest) { result in
            switch result {
            case .success(let syncResponse):
                self.updateLocalDatabase(with: syncResponse) { updateResult in
                    switch updateResult {
                    case .success:
                        NSLog("Sync: Success")
                        completion(.success(()))
                    case .failure(let error):
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
    
    private func uploadPhoto(photo: Photo, completion: @escaping (Result<PhotoDetailSchema, Error>) -> Void) {
        apiClient.uploadPhoto(photoId: photo.id, file: photo.content) { result in
            completion(result)
        }
    }
    
    private func downloadPhoto(photoId: UUID, completion: @escaping (Result<Data, Error>) -> Void) {
        apiClient.downloadPhoto(photoId: photoId) { result in
            switch result {
            case .success(let data):
                completion(.success(data))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    private func updateLocalDatabase(with syncResponse: SyncResponseSchema, completion: @escaping (Result<Void, Error>) -> Void) {
        var errors: [Error] = []
        let semaphore = DispatchSemaphore(value: 1)
        
        for item in syncResponse.trips {
            semaphore.wait()
            NSLog("Sync: Processing Trip \(item.id)")
            let trip = storageService.getTrip(id: item.id) ?? Trip(
                id: item.id,
                title: item.title,
                content: item.content ?? "",
                status: item.status,
                updatedAt: item.updatedAt,
                deletedAt: item.deletedAt
            )
            
            // Update the trip if it already exists
            trip.title = item.title
            trip.content = item.content ?? ""
            trip.updatedAt = item.updatedAt
            trip.deletedAt = item.deletedAt
            
            self.storageService.insert(model: trip)
            semaphore.signal()
        }
        
        for item in syncResponse.records {
            semaphore.wait()
            NSLog("Sync: Processing TripRecord \(item.id)")
            guard let trip = storageService.getTrip(id: item.tripId) else {
                errors.append(NSError(domain: "SyncService", code: 404, userInfo: [NSLocalizedDescriptionKey: "Trip not found"]))
                continue
            }
            
            let record = storageService.getTripRecord(id: item.id) ?? TripRecord(
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
            
            if record.trip == nil {
                trip.records.append(record)
                self.storageService.insert(model: trip)
            } else {
                self.storageService.insert(model: record)
            }
            semaphore.signal()
        }
        
        for item in syncResponse.photos {
            semaphore.wait()
            NSLog("Sync: Processing Photo \(item.id)")
            let record = self.storageService.getTripRecord(id: item.recordId)!
            
            if let photo = self.storageService.getPhoto(id: item.id) {
                photo.updatedAt = item.updatedAt
                photo.deletedAt = item.deletedAt
                
                if item.mime == nil {
                    NSLog("Sync: Performing upload")
                    self.uploadPhoto(photo: photo) { result in
                        if case .failure(let error) = result {
                            errors.append(error)
                            NSLog("Sync: Upload failed")
                        }
                        semaphore.signal()
                    }
                } else {
                    self.storageService.insert(model: photo)
                    semaphore.signal()
                }
            } else {
                NSLog("Sync: Performing download")
                self.downloadPhoto(photoId: item.id) { result in
                    switch result {
                    case .success(let data):
                        let photo = Photo(
                            id: item.id, content: data
                        )
                        record.photos.append(photo)
                        self.storageService.insert(model: record)
                    case .failure(let error):
                        NSLog("Sync: Download failed")
                        errors.append(error)
                    }
                    semaphore.signal()
                }
            }
        }
        
        completion(errors.isEmpty ? .success(()) : .failure(NSError(domain: "SyncService", code: 500, userInfo: [NSLocalizedDescriptionKey: "One or more errors occurred during sync"])))
    }
}
