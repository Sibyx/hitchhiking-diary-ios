import SwiftUI

struct UserDetailView: View {
    @EnvironmentObject var appState: AppState
    
    @State private var isTokenInvalid = false
    @State private var showingErrorAlert = false
    
    @State private var showLogin = false
    @State private var showLogout = false
    
    @State private var errorMessage: String? = nil
    @State private var isSyncing = false

    var body: some View {
        VStack(alignment: .center) {
            Image("Logo")
                .resizable()
                .frame(width: 150, height: 150)
                .cornerRadius(10)

            Text("Hitchhiking Diary")
                .font(.title)
                .fontWeight(.bold)
                .padding(.bottom, 20)
            
            if let errorMessage = self.errorMessage {
                Text(errorMessage)
                    .foregroundColor(.red)
                    .padding()
                    .background(Color.red.opacity(0.1))
                    .cornerRadius(5)
            }
        }
        
        VStack(alignment: .leading) {
            if (self.appState.token != nil) {
                Text(appState.username!)
                    .font(.largeTitle)
                    .foregroundStyle(.primary)
                
                if let lastSyncAt = appState.lastSyncAt {
                    Text("Last sync: \(lastSyncAt, formatter: itemFormatter)").foregroundStyle(.secondary)
                }
                
                if (isTokenInvalid) {
                    Text("(invalid token)").foregroundColor(.red)
                }
                
                if (!isTokenInvalid) {
                    Button(action: {
                        Task {
                            await self.syncTrips()
                        }
                    }) {
                        Text("Manual Synchronization")
                            .font(.body)
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(8)
                    }
                }
                
                Button(action: {
                    self.showLogout = true
                }) {
                    Text("Log out")
                        .font(.body)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.red)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                }
            }
            else {
                Button(action: {
                    self.showLogin = true
                }) {
                    Text("Log in")
                        .font(.body)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                }
            }
        }
        .padding(20)
        .overlay(
            Group {
                if isSyncing {
                    LoaderView()
                }
            }
        )
        .alert(isPresented: $showLogout) {
            Alert(
                title: Text("Warning"),
                message: Text("Logging out will remove all local data. Do you want to proceed?"),
                primaryButton: .destructive(Text("Logout")) {
                    Task {
                        await appState.logout()
                    }
                },
                secondaryButton: .cancel()
            )
        }
        .onAppear {
            if (appState.token != nil) {
                self.fetchUser()
            }
        }
        .sheet(isPresented: $showLogin) {
            LoginView().onDisappear {
                if (appState.token != nil) {
                    Task {
                        await self.syncTrips()
                    }
                }
            }
        }
    }
    
    private func syncTrips() async {
        self.isSyncing = true
        let apiClient = APIClient(baseUrl: appState.apiBaseUrl, token: appState.token)
        let syncService = SyncService(apiClient: apiClient, appState: appState)
        
        await syncService.sync { result in
            DispatchQueue.main.async {
                switch result {
                case .success:
                    self.isSyncing = false
                case .failure(let error):
                    self.errorMessage = error.localizedDescription
                    self.showingErrorAlert = true
                    self.isSyncing = false
                }
            }
        }
    }
    
    private func fetchUser() {
        self.isSyncing = true
        let apiClient = APIClient(baseUrl: appState.apiBaseUrl, token: appState.token)
        
        apiClient.readUser { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let detail):
                    self.isSyncing = false
                    self.isTokenInvalid = false
                    self.appState.username = detail.username
                case .failure(let error):
                    self.errorMessage = error.localizedDescription
                    self.showingErrorAlert = true
                    self.isSyncing = false
                    self.isTokenInvalid = true
                    self.showLogin = true
                }
            }
        }
    }

    private let itemFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .long
        formatter.timeStyle = .short
        return formatter
    }()
}
