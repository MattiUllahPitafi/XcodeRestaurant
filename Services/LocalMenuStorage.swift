import Foundation

/// Manages local storage of custom menus using UserDefaults
class LocalMenuStorage {
    static let shared = LocalMenuStorage()
    private let key = "savedCustomMenus"
    
    private init() {}
    
    // MARK: - Save Custom Menu
    func saveCustomMenu(_ menu: CustomMenu) {
        var savedMenus = loadAllCustomMenus()
        
        // Remove existing menu with same ID if exists
        savedMenus.removeAll { $0.id == menu.id }
        
        // Add the new/updated menu
        savedMenus.append(menu)
        
        // Save to UserDefaults
        if let encoded = try? JSONEncoder().encode(savedMenus) {
            UserDefaults.standard.set(encoded, forKey: key)
            print("✅ Saved custom menu: \(menu.name) for restaurant \(menu.restaurantId)")
        } else {
            print("❌ Failed to encode custom menu")
        }
    }
    
    // MARK: - Load All Custom Menus
    func loadAllCustomMenus() -> [CustomMenu] {
        guard let data = UserDefaults.standard.data(forKey: key),
              let menus = try? JSONDecoder().decode([CustomMenu].self, from: data) else {
            return []
        }
        return menus
    }
    
    // MARK: - Load Custom Menus for Restaurant
    func loadCustomMenus(for restaurantId: Int) -> [CustomMenu] {
        return loadAllCustomMenus().filter { $0.restaurantId == restaurantId }
    }
    
    // MARK: - Load Specific Custom Menu
    func loadCustomMenu(id: UUID) -> CustomMenu? {
        return loadAllCustomMenus().first { $0.id == id }
    }
    
    // MARK: - Delete Custom Menu
    func deleteCustomMenu(id: UUID) {
        var savedMenus = loadAllCustomMenus()
        savedMenus.removeAll { $0.id == id }
        
        if let encoded = try? JSONEncoder().encode(savedMenus) {
            UserDefaults.standard.set(encoded, forKey: key)
            print("✅ Deleted custom menu with id: \(id)")
        }
    }
    
    // MARK: - Delete All Custom Menus for Restaurant
    func deleteCustomMenus(for restaurantId: Int) {
        var savedMenus = loadAllCustomMenus()
        savedMenus.removeAll { $0.restaurantId == restaurantId }
        
        if let encoded = try? JSONEncoder().encode(savedMenus) {
            UserDefaults.standard.set(encoded, forKey: key)
            print("✅ Deleted all custom menus for restaurant: \(restaurantId)")
        }
    }
}

