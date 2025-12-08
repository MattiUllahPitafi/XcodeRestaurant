struct Restaurant: Identifiable, Codable {
    let id: Int
    let name: String
    let location: String
    let category: String
    let imageUrl: String

    enum CodingKeys: String, CodingKey {
        case id = "restaurantId"
        case name = "name"
        case location = "location"
        case category = "category"
        case imageUrl = "imageUrl"
    }
}
