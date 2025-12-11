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
//                            AsyncImage(url: URL(string: "http://10.211.55.7/\(dish.dishImageUrl)")) { image in
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
//        guard let url = URL(string: "http://10.211.55.7/BooknowAPI/api/menu/restaurant/\(restaurantId)") else {
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
    @State private var searchText = ""
    @State private var minPrice: Double?
    @State private var maxPrice: Double?
    @State private var sortBy: SortOption = .name

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
            AsyncImage(url: URL(string: "http://10.211.55.7/\(dish.dishImageUrl)")) { image in
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
        }
        .padding(.vertical, 6)
    }

    // MARK: - API Call
    private func fetchMenu() {
        guard let url = URL(string: "http://10.211.55.7/BooknowAPI/api/menu/restaurant/\(restaurantId)") else {
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
}

// MARK: - Supporting Types
//enum SortOption {
//    case name
//    case priceAsc
//    case priceDesc
//    case prepTime
//}
