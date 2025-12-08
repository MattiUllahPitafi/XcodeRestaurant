
// Models/LoginResponse.swift
import Foundation

struct LoginResponse: Codable {
    let userId: Int
    let name: String
    let email: String
    let role: String
    let restaurantId: Int?  
}
