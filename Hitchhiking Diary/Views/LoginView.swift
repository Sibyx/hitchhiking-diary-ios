import SwiftUI

struct LoginView: View {
    @EnvironmentObject var appState: AppState
    @State private var username: String = ""
    @State private var password: String = ""

    var body: some View {
        VStack {
            Spacer()
            
            // App Icon
            Image("Logo")
                .resizable()
                .frame(width: 250, height: 250)
                .cornerRadius(10)

            Text("Hitchhiking Diary")
                .font(.largeTitle)
                .fontWeight(.bold)
                .padding(.bottom, 20)

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
                appState.login()
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
}

#Preview {
    LoginView().environmentObject(AppState())
}
