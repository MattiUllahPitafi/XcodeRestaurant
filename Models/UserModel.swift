import Foundation

struct UserModel: Codable {
    let userId: Int
    let name: String
    let email: String
    var passwordHash: String?
    let role: String
    let coins: [Coin]
    
    // Computed property → normalize role so it doesn't matter if backend sends "customer" or "Customer"
    var normalizedRole: String {
        return role.capitalized   // e.g. "customer" → "Customer"
    }
    
    // Quick check helpers
    var isCustomer: Bool { normalizedRole == "Customer" }
    var isChef: Bool { normalizedRole == "Chef" }
    var isAdmin: Bool { normalizedRole == "Admin" }
    var isWaiter: Bool { normalizedRole == "Waiter" }
}

struct Coin: Codable {
    let categoryId: Int
    let categoryName: String
    let balance: Int
}
//import founfdation
//struct UserModel: Codable {
//    let userId: Int
//    let name: String
//    let email: String
//    var passwordHash: String?
//    let role: String
//    let coins: [Coin]
//}
//
//struct Coin: Codable {
//    let categoryId: Int
//    let categoryName: String
//    let balance: Int
//}
