import Foundation

// MARK: - Custom Menu Model
/// Represents a user's customized menu selection for a restaurant
struct CustomMenu: Codable, Identifiable {
    let id: UUID
    let restaurantId: Int
    let restaurantName: String?
    let name: String // User-given name for this custom menu
    let createdAt: Date
    
    // Menu selections
    let selectedDishes: [SelectedDish]
    
    // Calculate total price
    var totalPrice: Double {
        selectedDishes.reduce(0.0) { $0 + ($1.price * Double($1.quantity)) }
    }
    
    init(
        id: UUID = UUID(),
        restaurantId: Int,
        restaurantName: String? = nil,
        name: String,
        createdAt: Date = Date(),
        selectedDishes: [SelectedDish]
    ) {
        self.id = id
        self.restaurantId = restaurantId
        self.restaurantName = restaurantName
        self.name = name
        self.createdAt = createdAt
        self.selectedDishes = selectedDishes
    }
}

// MARK: - Selected Dish Model
/// Represents a dish selected in a custom menu with its customization
struct SelectedDish: Codable {
    let dishId: Int
    let dishName: String
    let price: Double
    let prepTimeMinutes: Int
    let dishImageUrl: String
    let quantity: Int
    let skippedIngredients: [[Int]] // Array of ingredient IDs to skip per quantity
    
    init(
        dishId: Int,
        dishName: String,
        price: Double,
        prepTimeMinutes: Int,
        dishImageUrl: String,
        quantity: Int,
        skippedIngredients: [[Int]]
    ) {
        self.dishId = dishId
        self.dishName = dishName
        self.price = price
        self.prepTimeMinutes = prepTimeMinutes
        self.dishImageUrl = dishImageUrl
        self.quantity = quantity
        self.skippedIngredients = skippedIngredients
    }
    
    // Create from Dish model with quantities and skipped ingredients
    static func from(
        dish: Dish,
        quantity: Int,
        skippedIngredients: [[Int]]
    ) -> SelectedDish {
        return SelectedDish(
            dishId: dish.dishId,
            dishName: dish.dishName,
            price: dish.price,
            prepTimeMinutes: dish.prepTimeMinutes,
            dishImageUrl: dish.dishImageUrl,
            quantity: quantity,
            skippedIngredients: skippedIngredients
        )
    }
}

