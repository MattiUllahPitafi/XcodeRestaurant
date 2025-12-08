import Foundation

struct LoginRequest: Codable {
    let Email: String
    let PasswordHash: String
}
