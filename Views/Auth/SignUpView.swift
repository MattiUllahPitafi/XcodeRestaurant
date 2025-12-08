import SwiftUI
struct SignUpView: View {
    @State private var name = ""
    @State private var email = ""
    @State private var password = ""
    @State private var errorMessage: String?
    @Binding var path: NavigationPath

    var body: some View {
        ZStack {
            Color.white.ignoresSafeArea()

            VStack {
                Spacer()
                HStack {
                    Spacer()
                    Image("pasta")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 300)
                        .opacity(0.1)
                        .offset(x: 40, y: 20)
                }
            }

            VStack(spacing: 20) {
                Spacer()

                VStack(spacing:5) {
                    Text("Advance-Restaurant")
                        .foregroundColor(.green)
                    Text(" BOOKING")
                        .bold()
                        .foregroundColor(.orange)
                }
                .font(.largeTitle)
                .fontWeight(.bold)
                Spacer()
                Text("Create your account")
                    .font(.headline)
                    .foregroundColor(.black.opacity(0.7))

                VStack(spacing: 16) {
                    TextField("Name", text: $name)
                        .padding()
                        .background(Color.white)
                        .overlay(RoundedRectangle(cornerRadius: 8).stroke(Color.gray.opacity(0.4)))

                    TextField("Email", text: $email)
                        .keyboardType(.emailAddress)
                        .autocapitalization(.none)
                        .padding()
                        .background(Color.white)
                        .overlay(RoundedRectangle(cornerRadius: 8).stroke(Color.gray.opacity(0.4)))

                    SecureField("Password", text: $password)
                        .padding()
                        .background(Color.white)
                        .overlay(RoundedRectangle(cornerRadius: 8).stroke(Color.gray.opacity(0.4)))
                }
                .padding(.horizontal)

                if let errorMessage = errorMessage {
                    Text(errorMessage)
                        .foregroundColor(.red)
                        .font(.caption)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                }

                Button(action: {
                    APIService.shared.signupUser(name: name, email: email, password: password) { result in
                        DispatchQueue.main.async {
                            switch result {
                            case .success(let registered):
                                if registered {
                                    path.append(AppRoute.login)
                                } else {
                                    errorMessage = "Signup failed. Please try again."
                                }
                            case .failure(let error):
                                errorMessage = "Error: \(error.localizedDescription)"
                            }
                        }
                    }
                }) {
                    Text("Sign Up")
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.orange)
                        .cornerRadius(8)
                }
                .padding(.horizontal)
                .padding(.top, 10)

                HStack {
                    Text("Already have an account?")
                    Button(action: {
                        path.append(AppRoute.login)
                    }) {
                        Text("Login")
                            .foregroundColor(.orange)
                            .fontWeight(.semibold)
                    }
                }
                .font(.subheadline)
                .padding(.top, 10)

                Spacer()

                Image("header")
                    .resizable()
                    .scaledToFit()
                    .frame(height: 100)
            }
            .padding()
        }
        .navigationBarBackButtonHidden(true)
    }
}

struct SignUpView_Previews: PreviewProvider {
    static var previews: some View {
        SignUpView(path: .constant(NavigationPath()))
    }
}
