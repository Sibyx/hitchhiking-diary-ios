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
        let trips = storageService.fetchTrips(lastSyncAt: self.lastSyncAt)
        let records = storageService.fetchTripRecords(lastSyncAt: self.lastSyncAt)
        let photos = storageService.fetchPhotos(lastSyncAt: self.lastSyncAt)
        
        let syncRequest = SyncRequestSchema(trips: trips, records: records, photos: photos, lastSyncAt: lastSyncAt)
        
        apiClient.sync(syncRequest: syncRequest) { result in
            switch result {
            case .success(let syncResponse):
                self.updateLocalDatabase(with: syncResponse) { updateResult in
                    switch updateResult {
                    case .success:
                        print("sync success")
                        completion(.success(()))
                    case .failure(let error):
                        print("sync fail")
                        completion(.failure(error))
                    }
                }
            case .failure(let error):
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
        
        for item in syncResponse.trips {
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
        }
        
        for item in syncResponse.records {
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
        }
        
        if errors.isEmpty {
            completion(.success(()))
        } else {
            completion(.failure(errors.first!))
        }
        
//        for item in syncResponse.photos {
//            let record = self.getTripRecord(id: item.recordId)
//            
//            if let photo = self.getPhoto(id: item.id) {
//                
//                photo.deletedAt = item.deletedAt
//                
//                if item.mime == nil {
//                    self.uploadPhoto(photo: photo) { result in
//                        if case .failure(let error) = result {
//                            print("Upload error")
//                            errors.append(error)
//                        }
//                    }
//                } else {
//                    self.modelContext.insert(photo)
//                }
//            } else {
//                self.downloadPhoto(photoId: item.id) { result in
//                    switch result {
//                    case .success(let data):
//                        let photo = Photo(
//                            id: item.id, content: data
//                        )
//                        record?.photos.append(photo)
//                    case .failure(let error):
//                        errors.append(error)
//                    }
//                }
//            }
//        }
    }
}
