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
    let id: UUID
    let username: String
    let createdAt: Date
    let updatedAt: Date

    enum CodingKeys: String, CodingKey {
        case id
        case username
        case createdAt = "created_at"
        case updatedAt = "updated_at"
    }
}

// MARK: - PhotoDetailSchema
struct PhotoDetailSchema: Codable {
    let id: UUID
    let recordId: UUID
    let mime: String?
    let createdAt: Date
    let updatedAt: Date
    let deletedAt: Date?

    enum CodingKeys: String, CodingKey {
        case id
        case recordId = "record_id"
        case mime
        case createdAt = "created_at"
        case updatedAt = "updated_at"
        case deletedAt = "deleted_at"
    }
}

// MARK: - SyncRequestSchema
struct SyncRequestSchema: Codable {
    let trips: [TripSyncSchema]
    let records: [TripRecordSyncSchema]
    let photos: [PhotoSyncSchema]
    let lastSyncAt: Date?
    
    init(trips: [TripSyncSchema], records: [TripRecordSyncSchema], photos: [PhotoSyncSchema], lastSyncAt: Date?) {
        self.trips = trips
        self.records = records
        self.photos = photos
        self.lastSyncAt = lastSyncAt
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
    let id: UUID
    let userId: UUID
    let title: String
    let content: String?
    let status: TripStatus
    let createdAt: Date
    let updatedAt: Date
    let deletedAt: Date?

    enum CodingKeys: String, CodingKey {
        case id
        case userId = "user_id"
        case title
        case content
        case status
        case createdAt = "created_at"
        case updatedAt = "updated_at"
        case deletedAt = "deleted_at"
    }
}

// MARK: - TripRecordDetailSchema
struct TripRecordDetailSchema: Codable {
    let id: UUID
    let tripId: UUID
    let type: TripRecordType
    let latitude: Double
    let longitude: Double
    let happenedAt: Date
    let content: String?
    let createdAt: Date
    let updatedAt: Date
    let deletedAt: Date?

    enum CodingKeys: String, CodingKey {
        case id
        case tripId = "trip_id"
        case type
        case latitude
        case longitude
        case happenedAt = "happened_at"
        case content
        case createdAt = "created_at"
        case updatedAt = "updated_at"
        case deletedAt = "deleted_at"
    }
}

// MARK: - TripSyncSchema
struct TripSyncSchema: Codable {
    let id: UUID
    let title: String
    let content: String?
    let status: TripStatus
    let updatedAt: Date
    let deletedAt: Date?
    
    init(from trip: Trip) {
        self.id = trip.id
        self.title = trip.title
        self.content = trip.content
        self.status = trip.status
        self.updatedAt = trip.updatedAt
        self.deletedAt = trip.deletedAt
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
    let id: UUID
    let tripId: UUID
    let type: TripRecordType
    let content: String?
    let latitude: Double
    let longitude: Double
    let happenedAt: Date
    let updatedAt: Date
    let deletedAt: Date?
    
    init(from record: TripRecord) {
        self.id = record.id
        self.tripId = record.trip!.id
        self.type = record.type
        self.content = record.content
        self.latitude = record.location.latitude
        self.longitude = record.location.longitude
        self.happenedAt = record.happenedAt
        self.updatedAt = record.updatedAt
        self.deletedAt = record.deletedAt
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
    let id: UUID
    let recordId: UUID
    let createdAt: Date
    let updatedAt: Date
    let deletedAt: Date?
    
    init(from photo: Photo) {
        self.id = photo.id
        self.recordId = photo.record!.id
        self.createdAt = photo.createdAt
        self.updatedAt = photo.updatedAt
        self.deletedAt = photo.deletedAt
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
    private let baseURL = URL(string: "https://exploring.hitchhikingdiary.app")!
//    private let baseURL = URL(string: "http://192.168.0.197:8000")!
//    private let baseURL = URL(string: "http://10.24.149.234:8000")!
//    private let baseURL = URL(string: "http://172.20.10.5:8000")!
    private var token: String?
    
    private let encoder = JSONEncoder()
    private let decoder = JSONDecoder()

    init(token: String? = nil) {
        self.token = token
        
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions =  [.withInternetDateTime, .withFractionalSeconds]
        
        self.encoder.dateEncodingStrategy = .custom({ date, encoder in
            var container = encoder.singleValueContainer()
            let dateString = formatter.string(from: date)
            try container.encode(dateString)
        })
        
        self.decoder.dateDecodingStrategy = .custom({ decoder in
            let container = try decoder.singleValueContainer()
            let dateString = try container.decode(String.self)
            
            if let date = formatter.date(from: dateString) {
                return date
            }
            
            throw DecodingError.dataCorruptedError(in: container, debugDescription: "Cannot decode date string \(dateString)")
        })
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
        request.httpBody = try? self.encoder.encode(tokenForm)
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data, error == nil else {
                completion(.failure(error!))
                return
            }
            do {
                let tokenDetail = try self.decoder.decode(TokenDetailSchema.self, from: data)
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
                let userDetail = try self.decoder.decode(UserDetailSchema.self, from: data)
                completion(.success(userDetail))
            } catch {
                completion(.failure(error))
            }
        }.resume()
    }

    func uploadPhoto(photoId: UUID, file: Data, completion: @escaping (Result<PhotoDetailSchema, Error>) -> Void) {
        NSLog("ApiClient: Preparing POST /api/v1/photos/\(photoId.uuidString)")
        
        let url = baseURL.appendingPathComponent("/api/v1/photos/\(photoId.uuidString)")
        var request = URLRequest(url: url)
        
        let boundary = "Boundary-\(UUID().uuidString)"
        request.httpMethod = "POST"
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(token ?? "")", forHTTPHeaderField: "Authorization")
        
        let paramName = "file"
        let fileName = "\(UUID().uuidString).jpg"
        var body = Data()
        
        body.append("\r\n--\(boundary)\r\n".data(using: .utf8)!)
        body.append("Content-Disposition: form-data; name=\"\(paramName)\"; filename=\"\(fileName)\"\r\n".data(using: .utf8)!)
        body.append("Content-Type: image/jpeg\r\n\r\n".data(using: .utf8)!)
        body.append(file)
        body.append("\r\n--\(boundary)--\r\n".data(using: .utf8)!)
        
        request.httpBody = body
        request.setValue("\(body.count)", forHTTPHeaderField: "Content-Length")
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data, error == nil else {
                NSLog("ApiClient: POST /api/v1/photos/\(photoId.uuidString) failed bigly - \(String(describing: error))")
                completion(.failure(error!))
                return
            }
            do {
                NSLog("ApiClient: POST /api/v1/photos/\(photoId.uuidString) success")
                let photoDetail = try self.decoder.decode(PhotoDetailSchema.self, from: data)
                NSLog("ApiClient: POST /api/v1/photos/\(photoId.uuidString) returned \(photoDetail.id)")
                completion(.success(photoDetail))
            } catch {
                NSLog("ApiClient: POST /api/v1/photos/\(photoId.uuidString) failed bigly - \(String(describing: error))")
                completion(.failure(error))
            }
        }.resume()
    }

    func downloadPhoto(photoId: UUID, completion: @escaping (Result<Data, Error>) -> Void) {
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

        request.httpBody = try? self.encoder.encode(syncRequest)

        URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data, error == nil else {
                completion(.failure(error!))
                return
            }
            do {
                let syncResponse = try self.decoder.decode(SyncResponseSchema.self, from: data)
                completion(.success(syncResponse))
            } catch {
                completion(.failure(error))
            }
        }.resume()
    }
}
