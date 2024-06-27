import Foundation

// MARK: - TokenFormSchema
struct TokenFormSchema: Codable {
    let username: String
    let password: String
}

// MARK: - TokenDetailSchema
struct TokenDetailSchema: Codable {
    let accessToken: String

    enum CodingKeys: String, CodingKey {
        case accessToken = "access_token"
    }
}

// MARK: - UserDetailSchema
struct UserDetailSchema: Codable {
    let id: String
    let username: String
    let createdAt: String
    let updatedAt: String

    enum CodingKeys: String, CodingKey {
        case id
        case username
        case createdAt = "created_at"
        case updatedAt = "updated_at"
    }
}

// MARK: - PhotoDetailSchema
struct PhotoDetailSchema: Codable {
    let id: String
    let recordId: String
    let checksum: String?
    let mime: String?
    let createdAt: String
    let deletedAt: String?

    enum CodingKeys: String, CodingKey {
        case id
        case recordId = "record_id"
        case checksum
        case mime
        case createdAt = "created_at"
        case deletedAt = "deleted_at"
    }
}

// MARK: - SyncRequestSchema
struct SyncRequestSchema: Codable {
    let trips: [TripSyncSchema]
    let records: [TripRecordSyncSchema]
    let photos: [PhotoSyncSchema]
    let lastSyncAt: String?
    
    init(trips: [TripSyncSchema], records: [TripRecordSyncSchema], photos: [PhotoSyncSchema], lastSyncAt: Date?) {
        self.trips = trips
        self.records = records
        self.photos = photos
        if let lastSyncAt = lastSyncAt {
            self.lastSyncAt = ISO8601DateFormatter().string(from: lastSyncAt)
        } else {
            self.lastSyncAt = nil
        }
    }

    enum CodingKeys: String, CodingKey {
        case trips
        case records
        case photos
        case lastSyncAt = "last_sync_at"
    }
}

// MARK: - SyncResponseSchema
struct SyncResponseSchema: Codable {
    let trips: [TripDetailSchema]
    let records: [TripRecordDetailSchema]
    let photos: [PhotoDetailSchema]
}

// MARK: - TripDetailSchema
struct TripDetailSchema: Codable {
    let id: String
    let userId: String
    let title: String
    let content: String?
    let status: String
    let createdAt: String
    let updatedAt: String

    enum CodingKeys: String, CodingKey {
        case id
        case userId = "user_id"
        case title
        case content
        case status
        case createdAt = "created_at"
        case updatedAt = "updated_at"
    }
}

// MARK: - TripRecordDetailSchema
struct TripRecordDetailSchema: Codable {
    let id: String
    let tripId: String
    let createdAt: String
    let updatedAt: String

    enum CodingKeys: String, CodingKey {
        case id
        case tripId = "trip_id"
        case createdAt = "created_at"
        case updatedAt = "updated_at"
    }
}

// MARK: - TripSyncSchema
struct TripSyncSchema: Codable {
    let id: String
    let title: String
    let content: String?
    let status: String
    let updatedAt: String
    let deletedAt: String?
    
    init(from trip: Trip) {
        let statusMapping = [
            "in-progress": "in_progress",
            "draft": "draft",
            "archived": "archived"
        ]
        
        
        self.id = trip.id.uuidString
        self.title = trip.title
        self.content = trip.content
        self.status = statusMapping[trip.status.rawValue]!
        self.updatedAt = ISO8601DateFormatter().string(from: trip.updatedAt)
        self.deletedAt = trip.deletedAt.map { ISO8601DateFormatter().string(from: $0) }
    }

    enum CodingKeys: String, CodingKey {
        case id
        case title
        case content
        case status
        case updatedAt = "updated_at"
        case deletedAt = "deleted_at"
    }
}

// MARK: - TripRecordSyncSchema
struct TripRecordSyncSchema: Codable {
    let id: String
    let tripId: String
    let type: String
    let content: String?
    let latitude: Double
    let longitude: Double
    let happenedAt: String
    let updatedAt: String
    let deletedAt: String?
    
    init(from record: TripRecord) {
        let typeMapping = [
            "Interesting": "interesting",
            "Workout": "workout",
            "Camping": "camping",
            "Pickup": "pickup",
            "Dropoff": "dropoff",
            "Story": "story",
        ]
        
        self.id = record.id.uuidString
        self.tripId = record.trip?.id.uuidString ?? ""
        self.type = typeMapping[record.type.rawValue]!
        self.content = record.content
        self.latitude = record.location.latitude
        self.longitude = record.location.longitude
        self.happenedAt = ISO8601DateFormatter().string(from: record.happenedAt)
        self.updatedAt = ISO8601DateFormatter().string(from: record.updatedAt)
        self.deletedAt = record.deletedAt.map { ISO8601DateFormatter().string(from: $0) }
    }

    enum CodingKeys: String, CodingKey {
        case id
        case tripId = "trip_id"
        case type
        case content
        case latitude
        case longitude
        case happenedAt = "happened_at"
        case updatedAt = "updated_at"
        case deletedAt = "deleted_at"
    }
}

// MARK: - PhotoSyncSchema
struct PhotoSyncSchema: Codable {
    let id: String
    let recordId: String
    let createdAt: String
    let updatedAt: String
    let deletedAt: String?
    
    init(from photo: Photo) {
        self.id = photo.id.uuidString
        self.recordId = photo.record?.id.uuidString ?? ""
        self.createdAt = ISO8601DateFormatter().string(from: photo.createdAt)
        self.updatedAt = ISO8601DateFormatter().string(from: photo.updatedAt)
        self.deletedAt = photo.deletedAt.map { ISO8601DateFormatter().string(from: $0) }
    }

    enum CodingKeys: String, CodingKey {
        case id
        case recordId = "record_id"
        case createdAt = "created_at"
        case updatedAt = "updated_at"
        case deletedAt = "deleted_at"
    }
}

// MARK: - API Client
class APIClient {
    private let baseURL = URL(string: "http://192.168.0.197:8000")!
    private var token: String?

    init(token: String? = nil) {
        self.token = token
    }
    
    func setToken(_ token: String) {
        self.token = token
    }

    func createToken(username: String, password: String, completion: @escaping (Result<TokenDetailSchema, Error>) -> Void) {
        let url = baseURL.appendingPathComponent("/api/v1/tokens")
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let tokenForm = TokenFormSchema(username: username, password: password)
        request.httpBody = try? JSONEncoder().encode(tokenForm)
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data, error == nil else {
                completion(.failure(error!))
                return
            }
            do {
                let tokenDetail = try JSONDecoder().decode(TokenDetailSchema.self, from: data)
                self.token = tokenDetail.accessToken
                completion(.success(tokenDetail))
            } catch {
                completion(.failure(error))
            }
        }.resume()
    }

    func readUser(completion: @escaping (Result<UserDetailSchema, Error>) -> Void) {
        let url = baseURL.appendingPathComponent("/api/v1/users/me")
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("Bearer \(token ?? "")", forHTTPHeaderField: "Authorization")

        URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data, error == nil else {
                completion(.failure(error!))
                return
            }
            do {
                let userDetail = try JSONDecoder().decode(UserDetailSchema.self, from: data)
                completion(.success(userDetail))
            } catch {
                completion(.failure(error))
            }
        }.resume()
    }

    func uploadPhoto(photoId: String, file: Data, completion: @escaping (Result<PhotoDetailSchema, Error>) -> Void) {
        let url = baseURL.appendingPathComponent("/api/v1/photos/\(photoId)")
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("multipart/form-data; boundary=Boundary-\(UUID().uuidString)", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(token ?? "")", forHTTPHeaderField: "Authorization")
        
        let boundary = "Boundary-\(UUID().uuidString)"
        var body = Data()
        
        body.append("--\(boundary)\r\n".data(using: .utf8)!)
        body.append("Content-Disposition: form-data; name=\"file\"; filename=\"photo.jpg\"\r\n".data(using: .utf8)!)
        body.append("Content-Type: image/jpeg\r\n\r\n".data(using: .utf8)!)
        body.append(file)
        body.append("\r\n".data(using: .utf8)!)
        body.append("--\(boundary)--\r\n".data(using: .utf8)!)
        
        request.httpBody = body
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data, error == nil else {
                completion(.failure(error!))
                return
            }
            do {
                let photoDetail = try JSONDecoder().decode(PhotoDetailSchema.self, from: data)
                completion(.success(photoDetail))
            } catch {
                completion(.failure(error))
            }
        }.resume()
    }


    func downloadPhoto(photoId: String, completion: @escaping (Result<Data, Error>) -> Void) {
        let url = baseURL.appendingPathComponent("/api/v1/photos/\(photoId)")
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("Bearer \(token ?? "")", forHTTPHeaderField: "Authorization")

        URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data, error == nil else {
                completion(.failure(error!))
                return
            }
            completion(.success(data))
        }.resume()
    }

    func sync(syncRequest: SyncRequestSchema, completion: @escaping (Result<SyncResponseSchema, Error>) -> Void) {
        let url = baseURL.appendingPathComponent("/api/v1/sync")
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(token ?? "")", forHTTPHeaderField: "Authorization")

        request.httpBody = try? JSONEncoder().encode(syncRequest)

        URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data, error == nil else {
                completion(.failure(error!))
                return
            }
            do {
                let syncResponse = try JSONDecoder().decode(SyncResponseSchema.self, from: data)
                completion(.success(syncResponse))
            } catch {
                completion(.failure(error))
            }
        }.resume()
    }
}
