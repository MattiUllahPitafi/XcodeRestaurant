import Foundation

// MARK: - Booking Model
struct Booking: Identifiable, Codable {
    let id: Int
    let restaurantName: String
    let bookingDateTime: String
    let specialRequest: String
    let status: String
    let tableId: Int
    let musicId: Int

    enum CodingKeys: String, CodingKey {
        case id = "bookingId"
        case restaurantName
        case bookingDateTime
        case specialRequest
        case status
        case tableId
        case musicId = "music_id"
    }
}
