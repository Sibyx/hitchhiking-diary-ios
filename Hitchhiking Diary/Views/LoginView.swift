import SwiftUI

struct LoginView: View {
    @EnvironmentObject var appState: AppState

    var body: some View {
        VStack {
            Spacer()

            Text("Hitchhiking Diary")
                .font(.largeTitle)
                .fontWeight(.bold)
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

            Spacer()
        }
        .padding()
    }
}

#Preview {
    LoginView().environmentObject(AppState())
}
