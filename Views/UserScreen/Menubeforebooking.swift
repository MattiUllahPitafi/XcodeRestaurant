//import SwiftUI
//
//struct MenuBeforeBooking: View {
//    let restaurantId: Int
//
//    @State private var dishes: [Dish] = []
//    @State private var isLoading = true
//    @State private var errorMessage: String?
//    @State private var quantities: [Int: Int] = [:] // dishId : quantity
//
//    var body: some View {
//        VStack {
//            if isLoading {
//                ProgressView("Loading Menu...")
//            } else if let errorMessage = errorMessage {
//                Text("Error: \(errorMessage)")
//                    .foregroundColor(.red)
//                    .padding()
//            } else {
//                List {
//                    ForEach(dishes) { dish in
//                        HStack(spacing: 12) {
//                            // Dish image
//                            AsyncImage(url: APIConfig.imageURL(for: dish.dishImageUrl)) { image in
//                                image.resizable()
//                                    .aspectRatio(contentMode: .fill)
//                            } placeholder: {
//                                Color.gray.opacity(0.2)
//                            }
//                            .frame(width: 70, height: 70)
//                            .clipShape(RoundedRectangle(cornerRadius: 10))
//
//                            // Dish details
//                            VStack(alignment: .leading, spacing: 4) {
//                                Text(dish.dishName)
//                                    .font(.headline)
//
//                                Text("Rs \(dish.price, specifier: "%.0f") • ⏱ \(dish.prepTimeMinutes) min")
//                                    .font(.subheadline)
//                                    .foregroundColor(.gray)
//                            }
//
//                            Spacer()
//
//
//                        }
//                        .padding(.vertical, 6)
//                    }
//                }
//                .listStyle(.insetGrouped)
//            }
//        }
//        .navigationTitle("Menu")
//        .onAppear {
//            fetchMenu()
//        }
//    }
//
//    // MARK: - API Call
//    private func fetchMenu() {
//        guard let url = APIConfig.url(for: .menuByRestaurant(restaurantId)) else {
//            errorMessage = "Invalid menu URL"
//            isLoading = false
//            return
//        }
//
//        URLSession.shared.dataTask(with: url) { data, response, error in
//            DispatchQueue.main.async {
//                isLoading = false
//                if let error = error {
//                    errorMessage = error.localizedDescription
//                    return
//                }
//
//                guard let data = data else {
//                    errorMessage = "No data received"
//                    return
//                }
//
//                do {
//                    dishes = try JSONDecoder().decode([Dish].self, from: data)
//                } catch {
//                    errorMessage = "Decoding failed: \(error.localizedDescription)"
//                }
//            }
//        }.resume()
//    }
//}
////
//


//frontend filters Name Pricelowtohigh highto low prep timme and name

import SwiftUI

struct MenuBeforeBooking: View {
    let restaurantId: Int

    @State private var dishes: [Dish] = []
    @State private var isLoading = true
    @State private var errorMessage: String?
    @State private var quantities: [Int: Int] = [:] // dishId : quantity
    @State private var skippedIngredients: [Int: [[Int]]] = [:]
    @State private var searchText = ""
    @State private var minPrice: Double?
    @State private var maxPrice: Double?
    @State private var sortBy: SortOption = .name
    
    // MARK: - Save/Load Menu States
    @State private var showingSaveMenuSheet = false
    @State private var showingSavedMenus = false
    @State private var menuNameToSave = ""
    @State private var restaurantName: String?

    // Filtered dishes based on all criteria
    private var filteredDishes: [Dish] {
        var filtered = dishes

        // Apply search filter
        if !searchText.isEmpty {
            filtered = filtered.filter { dish in
                dish.dishName.localizedCaseInsensitiveContains(searchText)
            }
        }

        // Apply price range filter
        if let minPrice = minPrice {
            filtered = filtered.filter { $0.price >= minPrice }
        }

        if let maxPrice = maxPrice {
            filtered = filtered.filter { $0.price <= maxPrice }
        }

        // Apply sorting
        filtered.sort { dish1, dish2 in
            switch sortBy {
            case .name:
                return dish1.dishName < dish2.dishName
            case .priceAsc:
                return dish1.price < dish2.price
            case .priceDesc:
                return dish1.price > dish2.price
            case .prepTime:
                return dish1.prepTimeMinutes < dish2.prepTimeMinutes
            }
        }

        return filtered
    }

    // Price range for sliders
    private var priceRange: ClosedRange<Double> {
        let prices = dishes.map { $0.price }
        return (prices.min() ?? 0)...(prices.max() ?? 1000)
    }
    
    // Check if there are items selected
    private var hasSelectedItems: Bool {
        quantities.values.contains { $0 > 0 }
    }
    
    // MARK: - Save/Load Menu Buttons View
    private var saveLoadMenuButtonsView: some View {
        HStack(spacing: 12) {
            // Save Menu Button
            Button {
                if hasSelectedItems {
                    showingSaveMenuSheet = true
                }
            } label: {
                HStack {
                    Image(systemName: "bookmark.fill")
                    Text("Save Menu")
                }
                .font(.subheadline)
                .foregroundColor(.white)
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(hasSelectedItems ? Color.blue : Color.gray)
                .cornerRadius(8)
            }
            .disabled(!hasSelectedItems)
            
            // Load Saved Menus Button
            Button {
                showingSavedMenus = true
            } label: {
                HStack {
                    Image(systemName: "bookmark")
                    Text("Load Saved")
                }
                .font(.subheadline)
                .foregroundColor(.white)
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(Color.green)
                .cornerRadius(8)
            }
            
            Spacer()
        }
        .padding(.horizontal)
        .padding(.vertical, 8)
        .background(Color(.systemGray6))
    }

    var body: some View {
        VStack {
            if isLoading {
                ProgressView("Loading Menu...")
            } else if let errorMessage = errorMessage {
                Text("Error: \(errorMessage)")
                    .foregroundColor(.red)
                    .padding()
            } else {
                // Filter controls
                filterControlsView
                
                // Save/Load menu buttons
                saveLoadMenuButtonsView

                // Main list
                List {
                    if filteredDishes.isEmpty {
                        Text("No dishes match your filters")
                            .foregroundColor(.gray)
                            .frame(maxWidth: .infinity, alignment: .center)
                            .listRowBackground(Color.clear)
                    } else {
                        ForEach(filteredDishes) { dish in
                            dishRowView(dish)
                        }
                    }
                }
                .listStyle(.insetGrouped)
                .searchable(text: $searchText, prompt: "Search dishes...")
            }
        }
        .navigationTitle("Menu")
        .onAppear {
            fetchMenu()
            fetchRestaurantName()
        }
        // 👇 MODAL FOR SAVE MENU
        .sheet(isPresented: $showingSaveMenuSheet) {
            SaveMenuNameView(
                menuName: $menuNameToSave,
                isPresented: $showingSaveMenuSheet,
                onSave: saveCurrentMenu
            )
        }
        // 👇 MODAL FOR SAVED MENUS
        .sheet(isPresented: $showingSavedMenus) {
            SavedMenusView(restaurantId: restaurantId) { savedMenu in
                loadCustomMenu(savedMenu)
            }
        }
    }

    // MARK: - Filter Controls View
    private var filterControlsView: some View {
        VStack(spacing: 12) {
            // Sort Options
            HStack {
                Text("Sort by:")
                    .font(.subheadline)
                    .foregroundColor(.gray)

                Picker("Sort", selection: $sortBy) {
                    Text("Name").tag(SortOption.name)
                    Text("Price: Low to High").tag(SortOption.priceAsc)
                    Text("Price: High to Low").tag(SortOption.priceDesc)
                    Text("Prep Time").tag(SortOption.prepTime)
                }
                .pickerStyle(.segmented)
            }
            .padding(.horizontal)

            // Price Filter
            HStack {
                Text("Price Range:")
                    .font(.subheadline)
                    .foregroundColor(.gray)

                Button(action: {
                    minPrice = nil
                    maxPrice = nil
                }) {
                    Text("Reset")
                        .font(.caption)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(Color.gray.opacity(0.2))
                        .cornerRadius(8)
                }
            }
            .padding(.horizontal)

            HStack {
                Text("Rs \(Int(minPrice ?? priceRange.lowerBound))")
                    .font(.caption)
                    .frame(width: 50)

                Slider(
                    value: Binding(
                        get: { minPrice ?? priceRange.lowerBound },
                        set: { minPrice = $0 }
                    ),
                    in: priceRange,
                    step: 50
                )
                .onChange(of: minPrice) { newValue in
                    if let newValue = newValue, let maxPrice = maxPrice, newValue > maxPrice {
                        self.maxPrice = newValue
                    }
                }

                Text("Rs \(Int(maxPrice ?? priceRange.upperBound))")
                    .font(.caption)
                    .frame(width: 50)
            }
            .padding(.horizontal)
        }
        .padding(.vertical, 8)
        .background(Color(.systemGray6))
    }

    // MARK: - Dish Row View
    private func dishRowView(_ dish: Dish) -> some View {
        HStack(spacing: 12) {
            // Dish image
            AsyncImage(url: APIConfig.imageURL(for: dish.dishImageUrl)) { image in
                image.resizable()
                    .aspectRatio(contentMode: .fill)
            } placeholder: {
                Color.gray.opacity(0.2)
            }
            .frame(width: 70, height: 70)
            .clipShape(RoundedRectangle(cornerRadius: 10))

            // Dish details
            VStack(alignment: .leading, spacing: 4) {
                Text(dish.dishName)
                    .font(.headline)

                Text("Rs \(dish.price, specifier: "%.0f") • ⏱ \(dish.prepTimeMinutes) min")
                    .font(.subheadline)
                    .foregroundColor(.gray)
            }

            Spacer()
            
            // ✅ Quantity controls
            HStack(spacing: 12) {
                // Minus button
                Button(action: {
                    let current = quantities[dish.dishId] ?? 0
                    if current > 0 {
                        let newQuantity = current - 1
                        quantities[dish.dishId] = newQuantity
                        
                        // Keep skippedIngredients in sync
                        var sets = skippedIngredients[dish.dishId] ?? []
                        if sets.count > newQuantity {
                            sets.removeLast(sets.count - newQuantity)
                        }
                        skippedIngredients[dish.dishId] = sets
                    }
                }) {
                    Image(systemName: "minus.circle.fill")
                        .foregroundColor(.red)
                        .font(.title2)
                }
                .buttonStyle(BorderlessButtonStyle())
                
                Text("\(quantities[dish.dishId] ?? 0)")
                    .frame(width: 30)
                
                // Plus button
                Button(action: {
                    let current = quantities[dish.dishId] ?? 0
                    let newQuantity = current + 1
                    quantities[dish.dishId] = newQuantity
                    
                    // Keep skippedIngredients in sync
                    var sets = skippedIngredients[dish.dishId] ?? []
                    while sets.count < newQuantity {
                        sets.append([]) // add empty skipped set
                    }
                    skippedIngredients[dish.dishId] = sets
                }) {
                    Image(systemName: "plus.circle.fill")
                        .foregroundColor(.green)
                        .font(.title2)
                }
                .buttonStyle(BorderlessButtonStyle())
            }
        }
        .padding(.vertical, 6)
    }

    // MARK: - API Call
    private func fetchMenu() {
        guard let url = APIConfig.url(for: .menuByRestaurant(restaurantId)) else {
            errorMessage = "Invalid menu URL"
            isLoading = false
            return
        }

        URLSession.shared.dataTask(with: url) { data, response, error in
            DispatchQueue.main.async {
                isLoading = false
                if let error = error {
                    errorMessage = error.localizedDescription
                    return
                }

                guard let data = data else {
                    errorMessage = "No data received"
                    return
                }

                do {
                    dishes = try JSONDecoder().decode([Dish].self, from: data)
                } catch {
                    errorMessage = "Decoding failed: \(error.localizedDescription)"
                }
            }
        }.resume()
    }
    
    // MARK: - Save/Load Menu Functions
    private func fetchRestaurantName() {
        // Try to fetch restaurant name from API
        guard let url = APIConfig.url(for: .restaurant(restaurantId)) else {
            return
        }
        
        URLSession.shared.dataTask(with: url) { data, response, error in
            if let data = data,
               let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
               let name = json["name"] as? String {
                DispatchQueue.main.async {
                    self.restaurantName = name
                }
            }
        }.resume()
    }
    
    private func saveCurrentMenu() {
        guard !menuNameToSave.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            return
        }
        
        // Create selected dishes from current state
        var selectedDishes: [SelectedDish] = []
        
        for (dishId, quantity) in quantities where quantity > 0 {
            if let dish = dishes.first(where: { $0.dishId == dishId }) {
                let skippedSets = skippedIngredients[dishId] ?? Array(repeating: [], count: quantity)
                selectedDishes.append(SelectedDish.from(
                    dish: dish,
                    quantity: quantity,
                    skippedIngredients: skippedSets
                ))
            }
        }
        
        guard !selectedDishes.isEmpty else {
            return
        }
        
        // Create custom menu
        let customMenu = CustomMenu(
            restaurantId: restaurantId,
            restaurantName: restaurantName,
            name: menuNameToSave.trimmingCharacters(in: .whitespacesAndNewlines),
            selectedDishes: selectedDishes
        )
        
        // Save to local storage
        LocalMenuStorage.shared.saveCustomMenu(customMenu)
        
        // Clear the menu name field
        menuNameToSave = ""
        
        print("✅ Menu saved: \(customMenu.name)")
    }
    
    private func loadCustomMenu(_ menu: CustomMenu) {
        // Clear current selections
        quantities = [:]
        skippedIngredients = [:]
        
        // Load each dish from the saved menu
        for selectedDish in menu.selectedDishes {
            // Check if dish still exists in current menu
            if dishes.contains(where: { $0.dishId == selectedDish.dishId }) {
                quantities[selectedDish.dishId] = selectedDish.quantity
                skippedIngredients[selectedDish.dishId] = selectedDish.skippedIngredients
            } else {
                // Dish no longer exists, skip it
                print("⚠️ Dish \(selectedDish.dishName) no longer available in menu")
            }
        }
    }
}

