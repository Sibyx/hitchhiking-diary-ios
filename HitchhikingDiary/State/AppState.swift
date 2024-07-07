import SwiftUI
import SwiftData

class AppState: ObservableObject {
    var token: String? {
        didSet {
            UserDefaults.standard.set(token, forKey: "token")
        }
    }
    
    var username: String? {
        didSet {
            UserDefaults.standard.set(username, forKey: "username")
        }
    }
    
    var lastSyncAt: Date? {
        didSet {
            UserDefaults.standard.set(lastSyncAt, forKey: "lastSyncAt")
        }
    }
    
    let apiBaseUrl: String
    
    init() {
        self.token = UserDefaults.standard.string(forKey: "token")
        self.username = UserDefaults.standard.string(forKey: "username")
        self.lastSyncAt = UserDefaults.standard.object(forKey: "lastSyncAt") as? Date
        self.apiBaseUrl = "https://explore.hitchhikingdiary.app"
    }

    func logout() async {
        self.token = nil
        self.username = nil
        self.lastSyncAt = nil
        try! await SharedDatabase.shared.database.delete(model: Trip.self)
    }
}
