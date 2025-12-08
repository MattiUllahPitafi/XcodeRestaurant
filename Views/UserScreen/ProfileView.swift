import SwiftUI

struct ProfileView: View {
    @EnvironmentObject var userVM: UserViewModel
    @Binding var bookings: [Booking]
    @Binding var orders: [Order]
    @Environment(\.dismiss) var dismiss

    @State private var isEditing = false
    @State private var editedName = ""
    @State private var editedEmail = ""
    @State private var editedPassword = ""

    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                // Header
                HStack {
                    Text("👤 My Profile")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundColor(.orange)
                    Spacer()
                    HStack(spacing: 20) {
                        Button(action: toggleEdit) {
                            Image(systemName: isEditing ? "checkmark.circle" : "pencil")
                                .foregroundColor(isEditing ? .green : .blue)
                                .imageScale(.large)
                        }

                        Button(action: logout) {
                            Image(systemName: "rectangle.portrait.and.arrow.forward")
                                .foregroundColor(.red)
                                .imageScale(.large)
                        }
                    }
                }

                // Profile Details
                if let user = userVM.user {
                    VStack(spacing: 16) {
                        // Editable fields
                        if isEditing {
                            TextField("Name", text: $editedName)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                            TextField("Email", text: $editedEmail)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                            SecureField("Password", text: $editedPassword)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                        } else {
                            profileRow(label: "Name", value: user.name)
                            profileRow(label: "Email", value: user.email)
                            profileRow(label: "Role", value: user.role)
                        }

                        // Coin Balances (essential info)
                        if !user.coins.isEmpty {
                            VStack(alignment: .leading, spacing: 8) {
                                Text("💰 Coin Balances")
                                    .font(.headline)
                                    .foregroundColor(.green)

                                ForEach(user.coins, id: \.categoryId) { coin in
                                    HStack {
                                        Text("• \(coin.categoryName):")
                                            .fontWeight(.semibold)
                                        Spacer()
                                        Text("\(coin.balance)")
                                            .foregroundColor(.orange)
                                    }
                                }
                            }
                            .padding()
                            .background(Color(.systemGray6))
                            .cornerRadius(12)
                        }

                        // Navigation Links
                        NavigationLink("📦 My Orders") {
                            OrderDetailView()
                                .environmentObject(userVM)
                        }

                        NavigationLink("🪑 My Bookings") {
                            UserBookingsView(bookings: bookings)                                             
                        }
                        .padding(.top)
                    }
                    .padding()
                    .background(Color.white)
                    .cornerRadius(12)
                    .shadow(radius: 5)
                } else if let error = userVM.errorMessage {
                    Text("⚠️ \(error)")
                        .foregroundColor(.red)
                } else {
                    ProgressView("Loading Profile...")
                }

                Spacer()
            }
            .padding()
        }
        .navigationBarBackButtonHidden(false)
        .task {
            if userVM.user == nil {
                let storedId = UserDefaults.standard.integer(forKey: "loggedInUserId")
                if storedId > 0 {
                    await userVM.fetchUser(userId: storedId)
                } else {
                    userVM.errorMessage = "User not logged in."
                }
            }
        }
    }

    // MARK: - Actions
    func toggleEdit() {
        if isEditing {
            Task {
                await userVM.updateUserProfile(
                    userId: userVM.user?.userId ?? 0,
                    name: editedName,
                    email: editedEmail,
                    passwordHash: editedPassword
                )
                isEditing = false
            }
        } else if let user = userVM.user {
            editedName = user.name
            editedEmail = user.email
            editedPassword = user.passwordHash ?? ""
            isEditing = true
        }
    }

    func logout() {
        UserDefaults.standard.removeObject(forKey: "loggedInUserId")
        userVM.user = nil
        dismiss()
    }

    // MARK: - Reusable row view
    @ViewBuilder
    func profileRow(label: String, value: String) -> some View {
        HStack {
            Text("\(label):")
                .fontWeight(.semibold)
            Spacer()
            Text(value)
                .foregroundColor(.gray)
        }
        .padding(.horizontal)
    }
}
