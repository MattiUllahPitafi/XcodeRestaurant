import Foundation

class UserViewModel: ObservableObject {
    @Published var user: UserModel?
    @Published var loggedInUserId: Int?
    @Published var errorMessage: String?

    func fetchUser(userId: Int) async {
        guard let url = URL(string: "http://10.211.55.7/BooknowAPI/api/Users/Get/\(userId)") else {
            DispatchQueue.main.async {
                self.errorMessage = "Invalid profile URL"
            }
            return
        }

        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            let fetchedUser = try JSONDecoder().decode(UserModel.self, from: data)

            DispatchQueue.main.async {
                self.user = fetchedUser
                self.loggedInUserId = fetchedUser.userId
                UserDefaults.standard.set(fetchedUser.userId, forKey: "loggedInUserId")
            }
        } catch {
            DispatchQueue.main.async {
                self.errorMessage = "Profile load failed: \(error.localizedDescription)"
            }
        }
    }
    @Published var restaurantId: Int?

    func fetchAdminRestaurant(userId: Int) async {
        guard let url = URL(string: "http://10.211.55.7/BooknowAPI/api/Admins/GetByUser/\(userId)") else {
            DispatchQueue.main.async {
                self.errorMessage = "Invalid admin URL"
            }
            return
        }

        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            let adminInfo = try JSONDecoder().decode(AdminModel.self, from: data)

            DispatchQueue.main.async {
                self.restaurantId = adminInfo.restaurantId
                UserDefaults.standard.set(adminInfo.restaurantId, forKey: "restaurantId")
            }
        } catch {
            DispatchQueue.main.async {
                self.errorMessage = "Failed to load admin info: \(error.localizedDescription)"
            }
        }
    }

    @MainActor
    func updateUserProfile(userId: Int, name: String, email: String, passwordHash: String) async {
        guard let url = URL(string: "http://10.211.55.7/BooknowAPI/api/Users/Update/\(userId)") else {
            DispatchQueue.main.async {
                self.errorMessage = "Invalid update URL"
            }
            return
        }

        let body: [String: Any] = [
            "UserId": userId,
            "Name": name,
            "Email": email,
            "PasswordHash": passwordHash
        ]

        var request = URLRequest(url: url)
        request.httpMethod = "PUT"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try? JSONSerialization.data(withJSONObject: body)

        do {
            let (data, response) = try await URLSession.shared.data(for: request)

            if let httpResponse = response as? HTTPURLResponse, (200...299).contains(httpResponse.statusCode) {
                print("✅ Update successful: \(String(data: data, encoding: .utf8) ?? "")")
                await fetchUser(userId: userId)
            } else {
                let msg = String(data: data, encoding: .utf8) ?? "Unknown server error"
                DispatchQueue.main.async {
                    self.errorMessage = "Update failed: \(msg)"
                }
            }
        } catch {
            DispatchQueue.main.async {
                self.errorMessage = "Update error: \(error.localizedDescription)"
            }
        }
    }

}
