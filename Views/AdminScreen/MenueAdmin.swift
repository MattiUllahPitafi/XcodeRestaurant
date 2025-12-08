import SwiftUI

struct AdminDish: Identifiable, Codable {
    var id: Int { dishId }
    let dishId: Int
    let name: String
    let price: Double
    let prepTimeMinutes: Int
    let dishImageUrl: String?
    let menuCategory: String?
    let ingredients: [Ingredient]

    struct Ingredient: Codable, Identifiable {
        var id: Int { ingredientId }
        let ingredientId: Int
        let name: String
        let quantityRequired: Double
        let unit: String
    }
}

struct AdminDishResponse: Codable {
    let restaurantId: Int
    let totalDishes: Int
    let dishes: [AdminDish]
}

struct MenueAdmin: View {
    @State private var dishes: [AdminDish] = []
    @State private var showAddDish = false
    let userId: Int

    // ✅ Base URL without BooknowAPI — since images come from root
    private let baseAPI = "http://10.211.55.7/BooknowAPI"
    private let baseImageURL = "http://10.211.55.7"

    var body: some View {
        NavigationView {
            VStack {
                if dishes.isEmpty {
                    VStack(spacing: 10) {
                        ProgressView()
                        Text("Loading menu...")
                            .foregroundColor(.gray)
                    }
                } else {
                    List {
                        ForEach(dishes) { dish in
                            HStack(spacing: 12) {
                                // ✅ Display image correctly
                                if let path = dish.dishImageUrl,
                                   let url = URL(string: "\(baseImageURL)/\(path)") {
                                    AsyncImage(url: url) { image in
                                        image.resizable()
                                            .aspectRatio(contentMode: .fill)
                                    } placeholder: {
                                        Color.gray.opacity(0.2)
                                    }
                                    .frame(width: 70, height: 70)
                                    .clipShape(RoundedRectangle(cornerRadius: 10))
                                } else {
                                    // Default placeholder
                                    Image(systemName: "photo")
                                        .resizable()
                                        .aspectRatio(contentMode: .fit)
                                        .frame(width: 70, height: 70)
                                        .foregroundColor(.gray)
                                }

                                // ✅ Dish details
                                VStack(alignment: .leading, spacing: 4) {
                                    Text(dish.name)
                                        .font(.headline)
                                    Text("Rs. \(dish.price, specifier: "%.0f")")
                                        .font(.subheadline)
                                    Text("⏱ \(dish.prepTimeMinutes) min")
                                        .font(.caption)
                                        .foregroundColor(.gray)
                                }

                                Spacer()

                                // ✅ Delete button
                                Button(action: {
                                    deleteDish(dishId: dish.dishId)
                                }) {
                                    Image(systemName: "trash")
                                        .foregroundColor(.red)
                                }
                            }
                            .padding(.vertical, 6)
                        }
                    }
                    .listStyle(.insetGrouped)
                }
            }
            .navigationTitle("🍽️ Menu")
            .toolbar {
                Button(action: { showAddDish = true }) {
                    Image(systemName: "plus.circle.fill")
                        .font(.title)
                }
            }
            .onAppear {
                fetchMenu()
            }
            .sheet(isPresented: $showAddDish) {
                AddDishView(userId: userId) {
                    fetchMenu()
                }
            }
        }
    }

    // ✅ Fetch menu for the admin’s restaurant
    private func fetchMenu() {
        guard let url = URL(string: "\(baseAPI)/api/admin/getByAdmin/\(userId)") else {
            print("❌ Invalid menu URL")
            return
        }

        print("🌐 Fetching:", url.absoluteString)

        URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                print("❌ Network error:", error.localizedDescription)
                return
            }

            guard let data = data else {
                print("❌ No data received")
                return
            }

            do {
                let decoded = try JSONDecoder().decode(AdminDishResponse.self, from: data)
                DispatchQueue.main.async {
                    self.dishes = decoded.dishes
                    print("✅ Loaded \(decoded.dishes.count) dishes")
                }
            } catch {
                print("❌ JSON decoding error:", error)
                if let jsonString = String(data: data, encoding: .utf8) {
                    print("🔍 Response body:", jsonString)
                }
            }
        }.resume()
    }

    // ✅ Delete dish from the admin’s menu
    private func deleteDish(dishId: Int) {
        guard let url = URL(string: "\(baseAPI)/api/admin/delete/\(userId)/\(dishId)") else {
            print("❌ Invalid delete URL")
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "DELETE"

        URLSession.shared.dataTask(with: request) { _, _, _ in
            DispatchQueue.main.async {
                fetchMenu()
            }
        }.resume()
    }
}
