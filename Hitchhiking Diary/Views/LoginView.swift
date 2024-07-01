import SwiftUI

struct LoginView: View {
    @EnvironmentObject var appState: AppState
    @State private var username: String = ""
    @State private var password: String = ""
    @State private var errorMessage: String? = nil

    var body: some View {
        VStack {
            // App Icon
            Image("Logo")
                .resizable()
                .frame(width: 250, height: 250)
                .cornerRadius(10)

            Text("Hitchhiking Diary")
                .font(.largeTitle)
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
                    .cornerRadius(15.0)
                    .padding()
            }
        }
        .padding()
    }
    
    private func login() {
        let apiClient = APIClient()
        
        apiClient.createToken(username: username, password: password) { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let tokenDetail):
                    appState.token = tokenDetail.accessToken
                    errorMessage = nil
                case .failure(let error):
                    errorMessage = "Login failed: \(error.localizedDescription)"
                }
            }
        }
    }
}
