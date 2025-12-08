//struct Dish: Codable, Identifiable {
//    let dishId: Int
//    let dishName: String
//    let price: Double
//    let prepTimeMinutes: Int
//    let dishImageUrl: String
//
//    var id: Int { dishId }
//
//    enum CodingKeys: String, CodingKey {
//        case dishId      = "dishId"
//        case dishName    = "name"
//        case price       = "price"
//        case prepTimeMinutes = "prepTimeMinutes"
//        case dishImageUrl    = "dishImageUrl"
//    }
//}

struct Ingredient: Codable, Identifiable {
    let ingredientId: Int
    let name: String
    
    var id: Int { ingredientId }
}

struct Dish: Codable, Identifiable {
    let dishId: Int
    let dishName: String
    let price: Double
    let prepTimeMinutes: Int
    let dishImageUrl: String
    let ingredients: [Ingredient]   // ✅ Added

    var id: Int { dishId }

    enum CodingKeys: String, CodingKey {
        case dishId
        case dishName        = "name"
        case price
        case prepTimeMinutes
        case dishImageUrl
        case ingredients
    }
}
