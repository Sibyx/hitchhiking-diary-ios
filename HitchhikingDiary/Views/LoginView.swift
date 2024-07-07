import SwiftUI

struct LoginView: View {
    @EnvironmentObject var appState: AppState
    @Environment(\.presentationMode) var presentationMode
    @State private var username: String = ""
    @State private var password: String = ""
    @State private var errorMessage: String? = nil

    var body: some View {
        VStack {
            // App Icon
            Image("Logo")
                .resizable()
                .frame(width: 150, height: 150)
                .cornerRadius(10)
                .padding(.bottom, 20)

            Text("Hitchhiking Diary")
                .font(.title)
                .fontWeight(.bold)
                .padding(.bottom, 20)
            
            if let errorMessage = errorMessage {
                Text(errorMessage)
                    .foregroundColor(.red)
                    .padding()
                    .background(Color.red.opacity(0.1))
                    .cornerRadius(5)
            }

            // Username TextField
            TextField("Username", text: $username)
                .padding()
                .background(Color(.secondarySystemBackground))
                .cornerRadius(10)
                .padding(.bottom, 10)
                .disabled(appState.username != nil)

            // Password SecureField
            SecureField("Password", text: $password)
                .padding()
                .background(Color(.secondarySystemBackground))
                .cornerRadius(10)
                .padding(.bottom, 20)

            Button(action: {
                login()
            }) {
                Text("Log In")
                    .font(.headline)
                    .foregroundColor(.white)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.blue)
                    .cornerRadius(10)
            }
            .padding()
        }
        .padding()
        .onAppear{
            self.username = self.appState.username ?? ""
        }
    }
    
    private func login() {
        let apiClient = APIClient(baseUrl: appState.apiBaseUrl)
        
        apiClient.createToken(username: username, password: password) { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let tokenDetail):
                    appState.token = tokenDetail.accessToken
                    appState.username = username
                    errorMessage = nil
                    presentationMode.wrappedValue.dismiss()
                case .failure(let error):
                    errorMessage = "Login failed: \(error.localizedDescription)"
                }
            }
        }
    }
}
