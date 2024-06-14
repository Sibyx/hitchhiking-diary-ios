import SwiftUI

class AppState: ObservableObject {
    @Published var isLoggedIn: Bool = false

    init() {
        // Check if the user is logged in (for now, it's always false)
        self.isLoggedIn = false
    }

    func login() {
        // Set login status (this is where you would handle authentication)
        self.isLoggedIn = true
    }

    func logout() {
        // Set logout status
        self.isLoggedIn = false
    }
}
