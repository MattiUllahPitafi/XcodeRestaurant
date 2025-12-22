import SwiftUI

struct LoginView: View {
    @EnvironmentObject var userVM: UserViewModel
    @Binding var path: NavigationPath
    
    @State private var email: String = ""
    @State private var password: String = ""
    @State private var showPassword = false
    @State private var showError = false
    @State private var errorMessage = ""
    
    var body: some View {
        ZStack {
            Color.white.ignoresSafeArea()
            
            VStack(spacing: 20) {
                Spacer()
                
                // Logo
                VStack(spacing: 5) {
                    Text("Advance-Restaurant")
                        .foregroundColor(.green)
                    Text(" Booking")
                        .foregroundColor(.orange)
                }
                .font(.largeTitle)
                .fontWeight(.bold)
                
                Text("Welcome back!")
                    .font(.headline)
                    .foregroundColor(.black.opacity(0.7))
                
                // Input fields
                VStack(spacing: 16) {
                    TextField("Email address", text: $email)
                        .keyboardType(.emailAddress)
                        .textInputAutocapitalization(.never)
                        .autocorrectionDisabled(true)
                        .padding()
                        .background(Color.white)
                        .overlay(RoundedRectangle(cornerRadius: 8).stroke(Color.gray.opacity(0.4)))
                    
                    HStack {
                        if showPassword {
                            TextField("Password", text: $password)
                        } else {
                            SecureField("Password", text: $password)
                        }
                        
                        Button(action: {
                            showPassword.toggle()
                        }) {
                            Image(systemName: showPassword ? "eye.slash.fill" : "eye.fill")
                                .foregroundColor(.gray)
                        }
                    }
                    .padding()
                    .background(Color.white)
                    .overlay(RoundedRectangle(cornerRadius: 8).stroke(Color.gray.opacity(0.4)))
                }
                .padding(.horizontal)
                
                // Login Button
                Button(action: login) {
                    Text("Login")
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.orange)
                        .cornerRadius(8)
                }
                .padding(.horizontal)
                .padding(.top, 10)
                
                // Error
                if showError {
                    Text(errorMessage)
                        .foregroundColor(.red)
                        .font(.caption)
                        .padding(.horizontal)
                }
                
                // Sign up prompt
                HStack {
                    Text("Don't have an account?")
                    Button(action: {
                        path.append(AppRoute.signup)
                    }) {
                        Text("Sign up")
                            .foregroundColor(.orange)
                            .fontWeight(.semibold)
                    }
                }
                .font(.subheadline)
                .padding(.top, 10)
                
                Spacer()
                
                // Decorative Image moved here so it doesn't block input
                Image("pasta")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 300)
                    .opacity(0.1)
                    .offset(x: 40, y: 20)
                
                Image("header")
                    .resizable()
                    .scaledToFit()
                    .frame(height: 100)
            }
            .padding()
        }
    }
    func login() {
        APIService.shared.loginUser(email: email, password: password) { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let response):
                    userVM.loggedInUserId = response.userId
                    UserDefaults.standard.set(response.userId, forKey: "loggedInUserId")
                    let user = UserModel(userId: response.userId,
                                         name: response.name,
                                         email: response.email,
                                         role: response.role,
                                         coins: [])
                    userVM.user = user

                    
                    // Navigate by role
                    switch user.role.lowercased() {
                    case "customer":
                        path.append(AppRoute.userHome)
                    case "waiter":
                        path.append(AppRoute.waiterDashboard)
                    case "chef":
                        path.append(AppRoute.ChefView)
                    case "admin":
                        path.append(AppRoute.adminHome)
                    case "appadmin":
                        path.append(AppRoute.AppAdminDashboard)
                    default:
                        self.errorMessage = "Unknown role: \(user.role)"
                        self.showError = true
                    }

                case .failure(let error):
                    self.errorMessage = "Login failed: \(error.localizedDescription)"
                    self.showError = true
                }
            }
        }
    }

//    func login() {
//        APIService.shared.loginUser(email: email, password: password) { result in
//            DispatchQueue.main.async {
//                switch result {
//                case .success(let response):
//                    userVM.loggedInUserId = response.userId
//                    UserDefaults.standard.set(response.userId, forKey: "loggedInUserId")
//
//                    Task {
//                        await userVM.fetchUser(userId: response.userId)
//                        DispatchQueue.main.async {
//                            path.append(AppRoute.userHome) // ✅ navigation done safely
//                        }
//                    }
//
//                case .failure(let error):
//                    self.errorMessage = "Login failed: \(error.localizedDescription)"
//                    self.showError = true
//                }
//            }
//        }
//    }
}
struct LoginView_Previews: PreviewProvider {
    static var previews: some View {
        LoginView(path: .constant(NavigationPath()))
            .environmentObject(UserViewModel())
    }
}

