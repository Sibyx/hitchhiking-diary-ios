import SwiftUI
import SwiftData

class AppState: ObservableObject {
    @Published var token: String? {
        didSet {
            UserDefaults.standard.set(token, forKey: "token")
        }
    }
    
    @Published var lastSyncAt: Date? {
        didSet {
            UserDefaults.standard.set(lastSyncAt, forKey: "lastSyncAt")
        }
    }
    
    init() {
        self.token = UserDefaults.standard.string(forKey: "token")
        self.lastSyncAt = UserDefaults.standard.object(forKey: "lastSyncAt") as? Date
    }

    func logout() {
        self.token = nil
        self.lastSyncAt = nil
    }
}
