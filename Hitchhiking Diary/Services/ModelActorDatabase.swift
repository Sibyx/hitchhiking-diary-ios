import Foundation
import SwiftData
import SwiftUI

public protocol Database {
    func delete<T>(_ model: T) async where T: PersistentModel
    func insert<T>(_ model: T) async where T: PersistentModel
    func save() async throws
    func fetch<T>(_ descriptor: FetchDescriptor<T>) async throws -> [T] where T: PersistentModel
    func delete<T: PersistentModel>(where predicate: Predicate<T>?) async throws
}

public extension Database {
    func fetch<T: PersistentModel>(where predicate: Predicate<T>?, sortBy: [SortDescriptor<T>]) async throws -> [T] {
        try await self.fetch(FetchDescriptor<T>(predicate: predicate, sortBy: sortBy))
    }
    
    func fetch<T: PersistentModel>(_ predicate: Predicate<T>, sortBy: [SortDescriptor<T>] = []) async throws -> [T] {
        try await self.fetch(where: predicate, sortBy: sortBy)
    }
    
    func fetch<T: PersistentModel>(_: T.Type, predicate: Predicate<T>? = nil, sortBy: [SortDescriptor<T>] = []) async throws -> [T] {
        try await self.fetch(where: predicate, sortBy: sortBy)
    }

    func delete<T: PersistentModel>(model _: T.Type, where predicate: Predicate<T>? = nil) async throws {
        try await self.delete(where: predicate)
    }
}

struct DefaultDatabase: Database {
    static let instance = DefaultDatabase()
    
    struct NotImplmentedError: Error {
        static let instance = NotImplmentedError()
    }
    
    func delete<T>(where predicate: Predicate<T>?) async throws where T : PersistentModel {
        assertionFailure("No Database Set.")
        throw NotImplmentedError.instance
    }
    

    func fetch<T>(_: FetchDescriptor<T>) async throws -> [T] where T: PersistentModel {
        assertionFailure("No Database Set.")
        throw NotImplmentedError.instance
    }
    
    func delete(_: some PersistentModel) async {
        assertionFailure("No Database Set.")
    }

    func insert(_: some PersistentModel) async {
        assertionFailure("No Database Set.")
    }
    
    func save() async throws {
        assertionFailure("No Database Set.")
        throw NotImplmentedError.instance
    }
}

@ModelActor
public actor ModelActorDatabase: Database {
    public func delete(_ model: some PersistentModel) async {
        self.modelContext.delete(model)
    }

    public func insert(_ model: some PersistentModel) async {
        self.modelContext.insert(model)
    }

    public func delete<T: PersistentModel>(where predicate: Predicate<T>?) async throws {
        try self.modelContext.delete(model: T.self, where: predicate)
    }

    public func save() async throws {
        try self.modelContext.save()
    }

    public func fetch<T>(_ descriptor: FetchDescriptor<T>) async throws -> [T] where T: PersistentModel {
        return try self.modelContext.fetch(descriptor)
    }
}


private struct DatabaseKey: EnvironmentKey {
    static var defaultValue: any Database {
        DefaultDatabase.instance
    }
}

public extension EnvironmentValues {
    var database: any Database {
        get { self[DatabaseKey.self] }
        set { self[DatabaseKey.self] = newValue }
    }
}

public extension Scene {
    func database(_ database: any Database) -> some Scene {
        self.environment(\.database, database)
    }
}

public extension View {
    func database(_ database: any Database) -> some View {
        self.environment(\.database, database)
    }
}

public struct SharedDatabase {
    public static let shared: SharedDatabase = .init()
    public let modelContainer: ModelContainer
    public let database: any Database
    
    private init(
        database: (any Database)? = nil
    ) {
        do {
            self.modelContainer = try ModelContainer(for: Trip.self)
        } catch {
            fatalError("Could not initialize ModelContainer")
        }
        self.database = database ?? BackgroundDatabase(modelContainer: modelContainer)
    }
}


public class BackgroundDatabase: Database {
    private actor DatabaseContainer {
        private let factory: @Sendable () -> any Database
        private var wrappedTask: Task<any Database, Never>?
        
        fileprivate init(factory: @escaping @Sendable () -> any Database) {
            self.factory = factory
        }
        
        fileprivate var database: any Database {
            get async {
                if let wrappedTask {
                    return await wrappedTask.value
                }
                let task = Task {
                    factory()
                }
                self.wrappedTask = task
                return await task.value
            }
        }
    }
    
    
    private let container: DatabaseContainer
    
    private var database: any Database {
        get async {
            await container.database
        }
    }
    
    internal init(_ factory: @Sendable @escaping () -> any Database) {
        self.container = .init(factory: factory)
    }
    
    public func delete(where predicate: Predicate<some PersistentModel>?) async throws {
        return try await self.database.delete(where: predicate)
    }
    
    public func delete<T>(_ model: T) async where T : PersistentModel {
        return await self.database.delete(model)
    }
    
    public func fetch<T>(_ descriptor: FetchDescriptor<T>) async throws -> [T] where T: PersistentModel {
        return try await self.database.fetch(descriptor)
    }
    
    public func insert(_ model: some PersistentModel) async {
        return await self.database.insert(model)
    }
    
    public func save() async throws {
        return try await self.database.save()
    }
    
    convenience init(modelContainer: ModelContainer) {
      self.init {
        return ModelActorDatabase(modelContainer: modelContainer)
      }
    }
}
