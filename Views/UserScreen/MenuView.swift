//
//
//import SwiftUI
//
//// MARK: - 1. REQUIRED EXTERNAL DATA STRUCTURES
//
//// NOTE: Placeholder structures for Dish and Ingredient (assuming they are defined elsewhere)
//// You should ensure your actual Dish/Ingredient structs match the API payload.
//
//// ✅ FINAL FIXED STRUCTURE for OrderSummaryResponse
//// ✅ OrderSummaryResponse: Manual parsing to handle ANY server format quirks
//struct OrderSummaryResponse: Codable {
//    let orderId: Int
//    let bookingId: Int
//    let userId: Int
//    let totalPrice: Double
//    let status: String
//
//    // Standard init for internal use
//    init(orderId: Int, bookingId: Int, userId: Int, totalPrice: Double, status: String) {
//        self.orderId = orderId
//        self.bookingId = bookingId
//        self.userId = userId
//        self.totalPrice = totalPrice
//        self.status = status
//    }
//
//    // 🔥 Bulletproof Initializer: Takes a raw dictionary and finds the data no matter what
//    init?(from dictionary: [String: Any]) {
//        // 1. Helper to find a key (case-insensitive check)
//        func getValue(_ keys: [String]) -> Any? {
//            for key in keys {
//                if let val = dictionary[key] { return val }
//            }
//            return nil
//        }
//
//        // 2. Helper to convert anything to Int
//        func toInt(_ value: Any?) -> Int? {
//            if let i = value as? Int { return i }
//            if let s = value as? String, let i = Int(s) { return i }
//            if let d = value as? Double { return Int(d) }
//            return nil
//        }
//
//        // 3. Helper to convert anything to Double
//        func toDouble(_ value: Any?) -> Double? {
//            if let d = value as? Double { return d }
//            if let s = value as? String, let d = Double(s) { return d }
//            if let i = value as? Int { return Double(i) }
//            return nil
//        }
//
//        // --- Parse Fields (Checking multiple casing options) ---
//
//        guard let oId = toInt(getValue(["OrderId", "orderId", "order_id"])),
//              let bId = toInt(getValue(["BookingId", "bookingId", "booking_id"])),
//              let uId = toInt(getValue(["UserId", "userId", "user_id"])),
//              let price = toDouble(getValue(["TotalPrice", "totalPrice", "total_price"])),
//              let stat = getValue(["Status", "status"]) as? String
//        else {
//            print("❌ FAILED TO PARSE DICTIONARY: \(dictionary)")
//            return nil
//        }
//
//        self.orderId = oId
//        self.bookingId = bId
//        self.userId = uId
//        self.totalPrice = price
//        self.status = stat
//    }
//}
//// MARK: - 2. Order Summary View (The Confirmation Popup)
//
//// Helper Row
//struct SummaryRow: View {
//    let label: String
//    let value: String
//
//    var body: some View {
//        HStack {
//            Text(label + ":").fontWeight(.medium).foregroundColor(.gray)
//            Spacer()
//            Text(value).foregroundColor(.primary)
//        }
//    }
//}
//
//struct OrderSummaryView: View {
//    let order: OrderSummaryResponse
//    @Binding var isPresented: Bool // Control for dismissing the modal
//
//    var body: some View {
//        VStack(spacing: 20) {
//            Image(systemName: "hand.thumbsup.fill")
//                .resizable()
//                .frame(width: 70, height: 70)
//                .foregroundColor(.green)
//
//            Text("Order Placed Successfully!").font(.title).bold()
//
//            VStack(alignment: .leading, spacing: 10) {
//                // Displaying the required fields
//                SummaryRow(label: "Order ID", value: String(order.orderId))
//                SummaryRow(label: "Booking ID", value: String(order.bookingId))
//                SummaryRow(label: "User ID", value: String(order.userId))
//                SummaryRow(label: "Status", value: order.status)
//                // Corrected formatting using String(format:)
//                SummaryRow(label: "Total Price", value: String(format: "Rs %.0f", order.totalPrice))
//            }
//            .padding()
//            .background(Color(.systemGray6))
//            .cornerRadius(10)
//
//            Button("Got It!") {
//                isPresented = false // Dismiss the modal
//            }
//            .buttonStyle(.borderedProminent)
//            .tint(.blue)
//        }
//        .padding(30)
//        .background(Color.white)
//        .cornerRadius(20)
//        .shadow(radius: 10)
//    }
//}
//
//
//// MARK: - 3. Ingredient and Checkbox Helpers
//
//struct IngredientRow: View {
//    let dishId: Int
//    let quantity: Int
//    let index: Int
//    let ingredient: Ingredient
//    @Binding var skippedIngredients: [Int: [[Int]]]
//
//    private var binding: Binding<Bool> {
//        let currentSets = skippedIngredients[dishId] ?? Array(repeating: [], count: quantity)
//        let isSelected = !currentSets[index].contains(ingredient.ingredientId)
//
//        return Binding<Bool>(
//            get: { isSelected },
//            set: { newValue in
//                var sets = skippedIngredients[dishId] ?? Array(repeating: [], count: quantity)
//                if newValue {
//                    sets[index].removeAll { $0 == ingredient.ingredientId }
//                } else {
//                    sets[index].append(ingredient.ingredientId)
//                }
//                skippedIngredients[dishId] = sets
//            }
//        )
//    }
//
//    var body: some View {
//        HStack {
//            CheckboxView(isOn: binding)
//            Text(ingredient.name)
//                .font(.footnote)
//        }
//    }
//};
//
//struct CheckboxView: View {
//    @Binding var isOn: Bool
//
//    var body: some View {
//        Button(action: { isOn.toggle() }) {
//            Image(systemName: isOn ? "checkmark.square.fill" : "square")
//                .foregroundColor(isOn ? .blue : .gray)
//        }
//        .buttonStyle(.plain)
//    }
//}
//
//
//// MARK: - 4. MENU VIEW
//
//struct MenuView: View {
//    let restaurantId: Int
//    let bookingId: Int
//
//    @EnvironmentObject var userVM: UserViewModel
//
//    @State private var dishes: [Dish] = []
//    @State private var quantities: [Int: Int] = [:]
//    @State private var skippedIngredients: [Int: [[Int]]] = [:]
//
//    @State private var isLoading = true
//    @State private var errorMessage: String?
//
//    @State private var isSubmittingOrder = false
//    @State private var orderMessage: String?
//
//    @State private var successfulOrder: OrderSummaryResponse?
//    @State private var showingOrderSummary = false
//
//    // ✅ Total bill calculation
//    var totalBill: Double {
//        dishes.reduce(0.0) { result, dish in
//            result + (dish.price * Double(quantities[dish.dishId] ?? 0))
//        }
//    }
//
//    // ✅ Helper: Binding for ingredient checkbox
//    private func bindingForIngredient(dishId: Int, quantity: Int, index: Int, ingredientId: Int) -> Binding<Bool> {
//        let currentSets = skippedIngredients[dishId] ?? Array(repeating: [], count: quantity)
//        let isSelected = !currentSets[index].contains(ingredientId)
//
//        return Binding<Bool>(
//            get: { isSelected },
//            set: { newValue in
//                var sets = skippedIngredients[dishId] ?? Array(repeating: [], count: quantity)
//                if newValue {
//                    sets[index].removeAll { $0 == ingredientId }
//                } else {
//                    sets[index].append(ingredientId)
//                }
//                skippedIngredients[dishId] = sets
//            }
//        )
//    }
//
//    var body: some View {
//        VStack {
//            if isLoading {
//                ProgressView("Loading Menu...")
//            } else if let error = errorMessage {
//                Text("Error: \(error)").foregroundColor(.red)
//            } else {
//                List {
//                    ForEach(dishes) { dish in
//                        VStack(alignment: .leading, spacing: 6) {
//                            // 🔹 Dish row with + / - controls
//                            HStack {
//                                AsyncImage(url: URL(string: "http://10.211.55.7/\(dish.dishImageUrl)")) { image in
//                                    image.resizable().aspectRatio(contentMode: .fill)
//                                } placeholder: {
//                                    Color.gray.opacity(0.1)
//                                }
//                                .frame(width: 60, height: 60)
//                                .cornerRadius(8)
//
//                                VStack(alignment: .leading) {
//                                    Text(dish.dishName).font(.headline)
//                                    Text("Rs \(dish.price, specifier: "%.0f") • \(dish.prepTimeMinutes) min")
//                                        .font(.subheadline)
//                                        .foregroundColor(.gray)
//                                }
//
//                                Spacer()
//
//                                // ✅ Quantity controls
//                                HStack(spacing: 12) {
//                                    // Minus button
//                                    Button(action: {
//                                        let current = quantities[dish.dishId] ?? 0
//                                        if current > 0 {
//                                            let newQuantity = current - 1
//                                            quantities[dish.dishId] = newQuantity
//
//                                            // Keep skippedIngredients in sync
//                                            var sets = skippedIngredients[dish.dishId] ?? []
//                                            if sets.count > newQuantity {
//                                                sets.removeLast(sets.count - newQuantity)
//                                            }
//                                            skippedIngredients[dish.dishId] = sets
//                                        }
//                                    }) {
//                                        Image(systemName: "minus.circle.fill")
//                                            .foregroundColor(.red)
//                                            .font(.title2)
//                                    }
//                                    .buttonStyle(BorderlessButtonStyle())
//
//                                    Text("\(quantities[dish.dishId] ?? 0)")
//                                        .frame(width: 30)
//
//                                    // Plus button
//                                    Button(action: {
//                                        let current = quantities[dish.dishId] ?? 0
//                                        let newQuantity = current + 1
//                                        quantities[dish.dishId] = newQuantity
//
//                                        // Keep skippedIngredients in sync
//                                        var sets = skippedIngredients[dish.dishId] ?? []
//                                        while sets.count < newQuantity {
//                                            sets.append([]) // add empty skipped set
//                                        }
//                                        skippedIngredients[dish.dishId] = sets
//                                    }) {
//                                        Image(systemName: "plus.circle.fill")
//                                            .foregroundColor(.green)
//                                            .font(.title2)
//                                    }
//                                    .buttonStyle(BorderlessButtonStyle())
//                                }
//                            } // end HStack
//
//                            // 🔹 Ingredients per quantity (below HStack)
//                            if let quantity = quantities[dish.dishId], quantity > 0, !dish.ingredients.isEmpty {
//                                VStack(alignment: .leading, spacing: 8) {
//                                    ForEach(0..<quantity, id: \.self) { index in
//                                        VStack(alignment: .leading, spacing: 4) {
//                                            Text("\(dish.dishName) #\(index + 1)")
//                                                .font(.subheadline)
//                                                .foregroundColor(.blue)
//
//                                            ForEach(dish.ingredients) { ingredient in
//                                                IngredientRow(
//                                                    dishId: dish.dishId,
//                                                    quantity: quantity,
//                                                    index: index,
//                                                    ingredient: ingredient,
//                                                    skippedIngredients: $skippedIngredients
//                                                )
//                                            }
//                                        }
//                                        .padding(.leading, 70)
//                                    }
//                                }
//                            }
//                        }
//                        .padding(.vertical, 6)
//                    }
//
//                    // ✅ Summary & Place Order section
//                    VStack(spacing: 12) {
//                        HStack {
//                            Spacer()
//                            Text("Total: Rs \(totalBill, specifier: "%.0f")")
//                                .font(.title2)
//                                .fontWeight(.bold)
//                                .foregroundColor(.orange)
//                            Spacer()
//                        }
//
//                        Button(action: submitOrder) {
//                            if isSubmittingOrder {
//                                ProgressView()
//                                    .frame(maxWidth: .infinity)
//                                    .padding()
//                            } else {
//                                Text("Place Order")
//                                    .frame(maxWidth: .infinity)
//                                    .padding()
//                                    .background(totalBill > 0 ? Color.blue : Color.gray)
//                                    .foregroundColor(.white)
//                                    .cornerRadius(10)
//                            }
//                        }
//                        .disabled(isSubmittingOrder || totalBill == 0)
//
//                        if let message = orderMessage {
//                            Text(message)
//                                .foregroundColor(orderMessage == "Order placed successfully!" ? .green : .red)
//                                .padding(.horizontal)
//                        }
//                    }
//                    .padding()
//                }
//            }
//        }
//        .navigationTitle("Menu")
//        .onAppear {
//            fetchMenu()
//        }
//        // 👇 MODAL PRESENTATION FOR ORDER SUMMARY
//        .sheet(isPresented: $showingOrderSummary) {
//            if let order = successfulOrder {
//                OrderSummaryView(order: order, isPresented: $showingOrderSummary)
//            }
//        }
//    }
//
//    // MARK: - API Functions
//
//    func fetchMenu() {
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
//
//    // ✅ Submit order to API (Uses the resilient OrderSummaryResponse)
//    func submitOrder() {
//        guard let userId = userVM.loggedInUserId else {
//            orderMessage = "Please log in to place an order."
//            return
//        }
//
//        // 🔥 Split items logic remains unchanged
//        var orderItems: [[String: Any]] = []
//
//        for (dishId, quantity) in quantities where quantity > 0 {
//            let skippedSets = skippedIngredients[dishId] ?? Array(repeating: [], count: quantity)
//
//            if skippedSets.allSatisfy({ $0 == skippedSets.first }) {
//                orderItems.append([
//                    "DishId": dishId,
//                    "Quantity": quantity,
//                    "SkippedIngredients": skippedSets.first ?? []
//                ])
//            } else {
//                for set in skippedSets {
//                    orderItems.append([
//                        "DishId": dishId,
//                        "Quantity": 1,
//                        "SkippedIngredients": set
//                    ])
//                }
//            }
//        }
//
//        guard !orderItems.isEmpty else {
//            orderMessage = "Please select at least one dish."
//            return
//        }
//
//        let orderData: [String: Any] = [
//            "UserId": userId,
//            "BookingId": bookingId,
//            "OrderItems": orderItems
//        ]
//
//        guard let url = URL(string: "http://10.211.55.7/BooknowAPI/api/order/add") else {
//            orderMessage = "Invalid order URL."
//            return
//        }
//
//        guard let jsonData = try? JSONSerialization.data(withJSONObject: orderData) else {
//            orderMessage = "Failed to encode order data."
//            return
//        }
//
//        var request = URLRequest(url: url)
//        request.httpMethod = "POST"
//        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
//        request.httpBody = jsonData
//
//        isSubmittingOrder = true
//        orderMessage = nil
//        self.successfulOrder = nil // Clear previous success state before starting request
//
//        URLSession.shared.dataTask(with: request) { data, response, error in
//            DispatchQueue.main.async {
//                isSubmittingOrder = false
//
//                if let error = error {
//                    orderMessage = "Error: \(error.localizedDescription)"
//                    return
//                }
//
//                guard let httpResponse = response as? HTTPURLResponse else {
//                    orderMessage = "No response from server."
//                    return
//                }
//
//                if (200...299).contains(httpResponse.statusCode) {
//
//                    // 1. Decode the detailed order response using the resilient struct
//                    if let data = data,
//                       let orderResponse = try? JSONDecoder().decode(OrderSummaryResponse.self, from: data) {
//
//                        // 2. Store the response and trigger the modal
//                        self.successfulOrder = orderResponse
//                        self.showingOrderSummary = true
//
//                        // 3. Clear shopping state
//                        self.quantities = [:]
//                        self.skippedIngredients = [:]
//                        self.orderMessage = nil
//
//                    } else {
//                        // This indicates a mismatch in the JSON structure/types.
//                        // The resilient decoder should catch string/int issues, so this is likely a structural mismatch.
//
//                        // DEBUGGING TIP: Print the raw JSON here if you still see this error:
//                        /*
//                        if let data = data, let rawResponse = String(data: data, encoding: .utf8) {
//                             print("API returned 2xx but failed to decode. Raw Response:")
//                             print(rawResponse)
//                        }
//                        */
//                        self.orderMessage = "Order placed, but failed to read confirmation details."
//                    }
//
//                } else {
//                    // Handle server errors (non-200)
//                    let serverMsg = String(data: data ?? Data(), encoding: .utf8) ?? "Unknown server error."
//                    orderMessage = "Server error (\(httpResponse.statusCode)): \(serverMsg)"
//                }
//            }
//        }.resume()
//    }
//}

//taskkkk
//frontend filters Name Pricelowtohigh highto low prep timme and name
//
//import SwiftUI
//
//// MARK: - 1. REQUIRED EXTERNAL DATA STRUCTURES
//
//// NOTE: Placeholder structures for Dish and Ingredient (assuming they are defined elsewhere)
//// You should ensure your actual Dish/Ingredient structs match the API payload.
//
//// ✅ FINAL FIXED STRUCTURE for OrderSummaryResponse
//// ✅ OrderSummaryResponse: Manual parsing to handle ANY server format quirks
//struct OrderSummaryResponse: Codable {
//    let orderId: Int
//    let bookingId: Int
//    let userId: Int
//    let totalPrice: Double
//    let status: String
//
//    // Standard init for internal use
//    init(orderId: Int, bookingId: Int, userId: Int, totalPrice: Double, status: String) {
//        self.orderId = orderId
//        self.bookingId = bookingId
//        self.userId = userId
//        self.totalPrice = totalPrice
//        self.status = status
//    }
//
//    // 🔥 Bulletproof Initializer: Takes a raw dictionary and finds the data no matter what
//    init?(from dictionary: [String: Any]) {
//        // 1. Helper to find a key (case-insensitive check)
//        func getValue(_ keys: [String]) -> Any? {
//            for key in keys {
//                if let val = dictionary[key] { return val }
//            }
//            return nil
//        }
//
//        // 2. Helper to convert anything to Int
//        func toInt(_ value: Any?) -> Int? {
//            if let i = value as? Int { return i }
//            if let s = value as? String, let i = Int(s) { return i }
//            if let d = value as? Double { return Int(d) }
//            return nil
//        }
//
//        // 3. Helper to convert anything to Double
//        func toDouble(_ value: Any?) -> Double? {
//            if let d = value as? Double { return d }
//            if let s = value as? String, let d = Double(s) { return d }
//            if let i = value as? Int { return Double(i) }
//            return nil
//        }
//
//        // --- Parse Fields (Checking multiple casing options) ---
//
//        guard let oId = toInt(getValue(["OrderId", "orderId", "order_id"])),
//              let bId = toInt(getValue(["BookingId", "bookingId", "booking_id"])),
//              let uId = toInt(getValue(["UserId", "userId", "user_id"])),
//              let price = toDouble(getValue(["TotalPrice", "totalPrice", "total_price"])),
//              let stat = getValue(["Status", "status"]) as? String
//        else {
//            print("❌ FAILED TO PARSE DICTIONARY: \(dictionary)")
//            return nil
//        }
//
//        self.orderId = oId
//        self.bookingId = bId
//        self.userId = uId
//        self.totalPrice = price
//        self.status = stat
//    }
//}
//
//// MARK: - 2. Order Summary View (The Confirmation Popup)
//
//// Helper Row
//struct SummaryRow: View {
//    let label: String
//    let value: String
//
//    var body: some View {
//        HStack {
//            Text(label + ":").fontWeight(.medium).foregroundColor(.gray)
//            Spacer()
//            Text(value).foregroundColor(.primary)
//        }
//    }
//}
//
//struct OrderSummaryView: View {
//    let order: OrderSummaryResponse
//    @Binding var isPresented: Bool // Control for dismissing the modal
//
//    var body: some View {
//        VStack(spacing: 20) {
//            Image(systemName: "hand.thumbsup.fill")
//                .resizable()
//                .frame(width: 70, height: 70)
//                .foregroundColor(.green)
//
//            Text("Order Placed Successfully!").font(.title).bold()
//
//            VStack(alignment: .leading, spacing: 10) {
//                // Displaying the required fields
//                SummaryRow(label: "Order ID", value: String(order.orderId))
//                SummaryRow(label: "Booking ID", value: String(order.bookingId))
//                SummaryRow(label: "User ID", value: String(order.userId))
//                SummaryRow(label: "Status", value: order.status)
//                // Corrected formatting using String(format:)
//                SummaryRow(label: "Total Price", value: String(format: "Rs %.0f", order.totalPrice))
//            }
//            .padding()
//            .background(Color(.systemGray6))
//            .cornerRadius(10)
//
//            Button("Got It!") {
//                isPresented = false // Dismiss the modal
//            }
//            .buttonStyle(.borderedProminent)
//            .tint(.blue)
//        }
//        .padding(30)
//        .background(Color.white)
//        .cornerRadius(20)
//        .shadow(radius: 10)
//    }
//}
//
//// MARK: - 3. Ingredient and Checkbox Helpers
//
//struct IngredientRow: View {
//    let dishId: Int
//    let quantity: Int
//    let index: Int
//    let ingredient: Ingredient
//    @Binding var skippedIngredients: [Int: [[Int]]]
//
//    private var binding: Binding<Bool> {
//        let currentSets = skippedIngredients[dishId] ?? Array(repeating: [], count: quantity)
//        let isSelected = !currentSets[index].contains(ingredient.ingredientId)
//
//        return Binding<Bool>(
//            get: { isSelected },
//            set: { newValue in
//                var sets = skippedIngredients[dishId] ?? Array(repeating: [], count: quantity)
//                if newValue {
//                    sets[index].removeAll { $0 == ingredient.ingredientId }
//                } else {
//                    sets[index].append(ingredient.ingredientId)
//                }
//                skippedIngredients[dishId] = sets
//            }
//        )
//    }
//
//    var body: some View {
//        HStack {
//            CheckboxView(isOn: binding)
//            Text(ingredient.name)
//                .font(.footnote)
//        }
//    }
//}
//
//struct CheckboxView: View {
//    @Binding var isOn: Bool
//
//    var body: some View {
//        Button(action: { isOn.toggle() }) {
//            Image(systemName: isOn ? "checkmark.square.fill" : "square")
//                .foregroundColor(isOn ? .blue : .gray)
//        }
//        .buttonStyle(.plain)
//    }
//}
//
//// MARK: - 4. Sorting Options
//enum SortOption {
//    case name
//    case priceAsc
//    case priceDesc
//    case prepTime
//}
//
//// MARK: - 5. MENU VIEW WITH FILTERS
//
//struct MenuView: View {
//    let restaurantId: Int
//    let bookingId: Int
//
//    @EnvironmentObject var userVM: UserViewModel
//
//    @State private var dishes: [Dish] = []
//    @State private var quantities: [Int: Int] = [:]
//    @State private var skippedIngredients: [Int: [[Int]]] = [:]
//
//    @State private var isLoading = true
//    @State private var errorMessage: String?
//
//    @State private var isSubmittingOrder = false
//    @State private var orderMessage: String?
//
//    @State private var successfulOrder: OrderSummaryResponse?
//    @State private var showingOrderSummary = false
//
//    // FILTER STATES
//    @State private var searchText = ""
//    @State private var minPrice: Double?
//    @State private var maxPrice: Double?
//    @State private var sortBy: SortOption = .name
//
//    // ✅ Total bill calculation
//    var totalBill: Double {
//        dishes.reduce(0.0) { result, dish in
//            result + (dish.price * Double(quantities[dish.dishId] ?? 0))
//        }
//    }
//
//    // Filtered dishes based on all criteria
//    private var filteredDishes: [Dish] {
//        var filtered = dishes
//
//        // Apply search filter
//        if !searchText.isEmpty {
//            filtered = filtered.filter { dish in
//                dish.dishName.localizedCaseInsensitiveContains(searchText)
//            }
//        }
//
//        // Apply price range filter
//        if let minPrice = minPrice {
//            filtered = filtered.filter { $0.price >= minPrice }
//        }
//
//        if let maxPrice = maxPrice {
//            filtered = filtered.filter { $0.price <= maxPrice }
//        }
//
//        // Apply sorting
//        filtered.sort { dish1, dish2 in
//            switch sortBy {
//            case .name:
//                return dish1.dishName < dish2.dishName
//            case .priceAsc:
//                return dish1.price < dish2.price
//            case .priceDesc:
//                return dish1.price > dish2.price
//            case .prepTime:
//                return dish1.prepTimeMinutes < dish2.prepTimeMinutes
//            }
//        }
//
//        return filtered
//    }
//
//    // Price range for sliders
//    private var priceRange: ClosedRange<Double> {
//        let prices = dishes.map { $0.price }
//        return (prices.min() ?? 0)...(prices.max() ?? 1000)
//    }
//
//    // ✅ Helper: Binding for ingredient checkbox
//    private func bindingForIngredient(dishId: Int, quantity: Int, index: Int, ingredientId: Int) -> Binding<Bool> {
//        let currentSets = skippedIngredients[dishId] ?? Array(repeating: [], count: quantity)
//        let isSelected = !currentSets[index].contains(ingredientId)
//
//        return Binding<Bool>(
//            get: { isSelected },
//            set: { newValue in
//                var sets = skippedIngredients[dishId] ?? Array(repeating: [], count: quantity)
//                if newValue {
//                    sets[index].removeAll { $0 == ingredientId }
//                } else {
//                    sets[index].append(ingredientId)
//                }
//                skippedIngredients[dishId] = sets
//            }
//        )
//    }
//
//    // MARK: - Filter Controls View
//    private var filterControlsView: some View {
//        VStack(spacing: 12) {
//            // Sort Options
//            HStack {
//                Text("Sort by:")
//                    .font(.subheadline)
//                    .foregroundColor(.gray)
//
//                Picker("Sort", selection: $sortBy) {
//                    Text("Name").tag(SortOption.name)
//                    Text("Price: Low to High").tag(SortOption.priceAsc)
//                    Text("Price: High to Low").tag(SortOption.priceDesc)
//                    Text("Prep Time").tag(SortOption.prepTime)
//                }
//                .pickerStyle(.segmented)
//            }
//            .padding(.horizontal)
//
//            // Price Filter
//            HStack {
//                Text("Price Range:")
//                    .font(.subheadline)
//                    .foregroundColor(.gray)
//
//                Button(action: {
//                    minPrice = nil
//                    maxPrice = nil
//                }) {
//                    Text("Reset")
//                        .font(.caption)
//                        .padding(.horizontal, 8)
//                        .padding(.vertical, 4)
//                        .background(Color.gray.opacity(0.2))
//                        .cornerRadius(8)
//                }
//            }
//            .padding(.horizontal)
//
//            HStack {
//                Text("Rs \(Int(minPrice ?? priceRange.lowerBound))")
//                    .font(.caption)
//                    .frame(width: 50)
//
//                Slider(
//                    value: Binding(
//                        get: { minPrice ?? priceRange.lowerBound },
//                        set: { minPrice = $0 }
//                    ),
//                    in: priceRange,
//                    step: 50
//                )
//                .onChange(of: minPrice) { newValue in
//                    if let newValue = newValue, let maxPrice = maxPrice, newValue > maxPrice {
//                        self.maxPrice = newValue
//                    }
//                }
//
//                Text("Rs \(Int(maxPrice ?? priceRange.upperBound))")
//                    .font(.caption)
//                    .frame(width: 50)
//            }
//            .padding(.horizontal)
//        }
//        .padding(.vertical, 8)
//        .background(Color(.systemGray6))
//    }
//
//    var body: some View {
//        VStack {
//            if isLoading {
//                ProgressView("Loading Menu...")
//            } else if let error = errorMessage {
//                Text("Error: \(error)").foregroundColor(.red)
//            } else {
//                // Show filter controls
//                filterControlsView
//
//                List {
//                    if filteredDishes.isEmpty {
//                        Text("No dishes match your filters")
//                            .foregroundColor(.gray)
//                            .frame(maxWidth: .infinity, alignment: .center)
//                            .listRowBackground(Color.clear)
//                    } else {
//                        ForEach(filteredDishes) { dish in
//                            VStack(alignment: .leading, spacing: 6) {
//                                // 🔹 Dish row with + / - controls
//                                HStack {
//                                    AsyncImage(url: URL(string: "http://10.211.55.7/\(dish.dishImageUrl)")) { image in
//                                        image.resizable().aspectRatio(contentMode: .fill)
//                                    } placeholder: {
//                                        Color.gray.opacity(0.1)
//                                    }
//                                    .frame(width: 60, height: 60)
//                                    .cornerRadius(8)
//
//                                    VStack(alignment: .leading) {
//                                        Text(dish.dishName).font(.headline)
//                                        Text("Rs \(dish.price, specifier: "%.0f") • \(dish.prepTimeMinutes) min")
//                                            .font(.subheadline)
//                                            .foregroundColor(.gray)
//                                    }
//
//                                    Spacer()
//
//                                    // ✅ Quantity controls
//                                    HStack(spacing: 12) {
//                                        // Minus button
//                                        Button(action: {
//                                            let current = quantities[dish.dishId] ?? 0
//                                            if current > 0 {
//                                                let newQuantity = current - 1
//                                                quantities[dish.dishId] = newQuantity
//
//                                                // Keep skippedIngredients in sync
//                                                var sets = skippedIngredients[dish.dishId] ?? []
//                                                if sets.count > newQuantity {
//                                                    sets.removeLast(sets.count - newQuantity)
//                                                }
//                                                skippedIngredients[dish.dishId] = sets
//                                            }
//                                        }) {
//                                            Image(systemName: "minus.circle.fill")
//                                                .foregroundColor(.red)
//                                                .font(.title2)
//                                        }
//                                        .buttonStyle(BorderlessButtonStyle())
//
//                                        Text("\(quantities[dish.dishId] ?? 0)")
//                                            .frame(width: 30)
//
//                                        // Plus button
//                                        Button(action: {
//                                            let current = quantities[dish.dishId] ?? 0
//                                            let newQuantity = current + 1
//                                            quantities[dish.dishId] = newQuantity
//
//                                            // Keep skippedIngredients in sync
//                                            var sets = skippedIngredients[dish.dishId] ?? []
//                                            while sets.count < newQuantity {
//                                                sets.append([]) // add empty skipped set
//                                            }
//                                            skippedIngredients[dish.dishId] = sets
//                                        }) {
//                                            Image(systemName: "plus.circle.fill")
//                                                .foregroundColor(.green)
//                                                .font(.title2)
//                                        }
//                                        .buttonStyle(BorderlessButtonStyle())
//                                    }
//                                } // end HStack
//
//                                // 🔹 Ingredients per quantity (below HStack)
//                                if let quantity = quantities[dish.dishId], quantity > 0, !dish.ingredients.isEmpty {
//                                    VStack(alignment: .leading, spacing: 8) {
//                                        ForEach(0..<quantity, id: \.self) { index in
//                                            VStack(alignment: .leading, spacing: 4) {
//                                                Text("\(dish.dishName) #\(index + 1)")
//                                                    .font(.subheadline)
//                                                    .foregroundColor(.blue)
//
//                                                ForEach(dish.ingredients) { ingredient in
//                                                    IngredientRow(
//                                                        dishId: dish.dishId,
//                                                        quantity: quantity,
//                                                        index: index,
//                                                        ingredient: ingredient,
//                                                        skippedIngredients: $skippedIngredients
//                                                    )
//                                                }
//                                            }
//                                            .padding(.leading, 70)
//                                        }
//                                    }
//                                }
//                            }
//                            .padding(.vertical, 6)
//                        }
//
//                        // ✅ Summary & Place Order section
//                        VStack(spacing: 12) {
//                            HStack {
//                                Spacer()
//                                Text("Total: Rs \(totalBill, specifier: "%.0f")")
//                                    .font(.title2)
//                                    .fontWeight(.bold)
//                                    .foregroundColor(.orange)
//                                Spacer()
//                            }
//
//                            Button(action: submitOrder) {
//                                if isSubmittingOrder {
//                                    ProgressView()
//                                        .frame(maxWidth: .infinity)
//                                        .padding()
//                                } else {
//                                    Text("Place Order")
//                                        .frame(maxWidth: .infinity)
//                                        .padding()
//                                        .background(totalBill > 0 ? Color.blue : Color.gray)
//                                        .foregroundColor(.white)
//                                        .cornerRadius(10)
//                                }
//                            }
//                            .disabled(isSubmittingOrder || totalBill == 0)
//
//                            if let message = orderMessage {
//                                Text(message)
//                                    .foregroundColor(orderMessage == "Order placed successfully!" ? .green : .red)
//                                    .padding(.horizontal)
//                            }
//                        }
//                        .padding()
//                    }
//                }
//                .searchable(text: $searchText, prompt: "Search dishes...")
//            }
//        }
//        .navigationTitle("Menu")
//        .onAppear {
//            fetchMenu()
//        }
//        // 👇 MODAL PRESENTATION FOR ORDER SUMMARY
//        .sheet(isPresented: $showingOrderSummary) {
//            if let order = successfulOrder {
//                OrderSummaryView(order: order, isPresented: $showingOrderSummary)
//            }
//        }
//    }
//
//    // MARK: - API Functions
//
//    func fetchMenu() {
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
//
//    // ✅ Submit order to API (Uses the resilient OrderSummaryResponse)
//    func submitOrder() {
//        guard let userId = userVM.loggedInUserId else {
//            orderMessage = "Please log in to place an order."
//            return
//        }
//
//        // 🔥 Split items logic remains unchanged
//        var orderItems: [[String: Any]] = []
//
//        for (dishId, quantity) in quantities where quantity > 0 {
//            let skippedSets = skippedIngredients[dishId] ?? Array(repeating: [], count: quantity)
//
//            if skippedSets.allSatisfy({ $0 == skippedSets.first }) {
//                orderItems.append([
//                    "DishId": dishId,
//                    "Quantity": quantity,
//                    "SkippedIngredients": skippedSets.first ?? []
//                ])
//            } else {
//                for set in skippedSets {
//                    orderItems.append([
//                        "DishId": dishId,
//                        "Quantity": 1,
//                        "SkippedIngredients": set
//                    ])
//                }
//            }
//        }
//
//        guard !orderItems.isEmpty else {
//            orderMessage = "Please select at least one dish."
//            return
//        }
//
//        let orderData: [String: Any] = [
//            "UserId": userId,
//            "BookingId": bookingId,
//            "OrderItems": orderItems
//        ]
//
//        guard let url = URL(string: "http://10.211.55.7/BooknowAPI/api/order/add") else {
//            orderMessage = "Invalid order URL."
//            return
//        }
//
//        guard let jsonData = try? JSONSerialization.data(withJSONObject: orderData) else {
//            orderMessage = "Failed to encode order data."
//            return
//        }
//
//        var request = URLRequest(url: url)
//        request.httpMethod = "POST"
//        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
//        request.httpBody = jsonData
//
//        isSubmittingOrder = true
//        orderMessage = nil
//        self.successfulOrder = nil // Clear previous success state before starting request
//
//        URLSession.shared.dataTask(with: request) { data, response, error in
//            DispatchQueue.main.async {
//                isSubmittingOrder = false
//
//                if let error = error {
//                    orderMessage = "Error: \(error.localizedDescription)"
//                    return
//                }
//
//                guard let httpResponse = response as? HTTPURLResponse else {
//                    orderMessage = "No response from server."
//                    return
//                }
//
//                if (200...299).contains(httpResponse.statusCode) {
//
//                    // 1. Decode the detailed order response using the resilient struct
//                    if let data = data,
//                       let orderResponse = try? JSONDecoder().decode(OrderSummaryResponse.self, from: data) {
//
//                        // 2. Store the response and trigger the modal
//                        self.successfulOrder = orderResponse
//                        self.showingOrderSummary = true
//
//                        // 3. Clear shopping state
//                        self.quantities = [:]
//                        self.skippedIngredients = [:]
//                        self.orderMessage = nil
//
//                    } else {
//                        // This indicates a mismatch in the JSON structure/types.
//                        // The resilient decoder should catch string/int issues, so this is likely a structural mismatch.
//
//                        // DEBUGGING TIP: Print the raw JSON here if you still see this error:
//                        /*
//                        if let data = data, let rawResponse = String(data: data, encoding: .utf8) {
//                             print("API returned 2xx but failed to decode. Raw Response:")
//                             print(rawResponse)
//                        }
//                        */
//                        self.orderMessage = "Order placed, but failed to read confirmation details."
//                    }
//
//                } else {
//                    // Handle server errors (non-200)
//                    let serverMsg = String(data: data ?? Data(), encoding: .utf8) ?? "Unknown server error."
//                    orderMessage = "Server error (\(httpResponse.statusCode)): \(serverMsg)"
//                }
//            }
//        }.resume()
//    }
//}

import SwiftUI

// MARK: - 1. REQUIRED EXTERNAL DATA STRUCTURES

// NOTE: Placeholder structures for Dish and Ingredient (assuming they are defined elsewhere)
// You should ensure your actual Dish/Ingredient structs match the API payload.

// ✅ UPDATED: Add dedicationNote field
struct OrderSummaryResponse: Codable {
    let orderId: Int
    let bookingId: Int
    let userId: Int
    let totalPrice: Double
    let status: String
    let dedicationNote: String? // 🆕 Add this line

    // Standard init for internal use
    init(orderId: Int, bookingId: Int, userId: Int, totalPrice: Double, status: String, dedicationNote: String? = nil) {
        self.orderId = orderId
        self.bookingId = bookingId
        self.userId = userId
        self.totalPrice = totalPrice
        self.status = status
        self.dedicationNote = dedicationNote // 🆕 Initialize
    }

    // 🔥 Bulletproof Initializer: Updated to handle dedicationNote
    init?(from dictionary: [String: Any]) {
        // 1. Helper to find a key (case-insensitive check)
        func getValue(_ keys: [String]) -> Any? {
            for key in keys {
                if let val = dictionary[key] { return val }
            }
            return nil
        }

        // 2. Helper to convert anything to Int
        func toInt(_ value: Any?) -> Int? {
            if let i = value as? Int { return i }
            if let s = value as? String, let i = Int(s) { return i }
            if let d = value as? Double { return Int(d) }
            return nil
        }

        // 3. Helper to convert anything to Double
        func toDouble(_ value: Any?) -> Double? {
            if let d = value as? Double { return d }
            if let s = value as? String, let d = Double(s) { return d }
            if let i = value as? Int { return Double(i) }
            return nil
        }

        // --- Parse Fields (Checking multiple casing options) ---
        guard let oId = toInt(getValue(["OrderId", "orderId", "order_id"])),
              let bId = toInt(getValue(["BookingId", "bookingId", "booking_id"])),
              let uId = toInt(getValue(["UserId", "userId", "user_id"])),
              let price = toDouble(getValue(["TotalPrice", "totalPrice", "total_price"])),
              let stat = getValue(["Status", "status"]) as? String
        else {
            print("❌ FAILED TO PARSE DICTIONARY: \(dictionary)")
            return nil
        }

        self.orderId = oId
        self.bookingId = bId
        self.userId = uId
        self.totalPrice = price
        self.status = stat
        
        // 🆕 Parse dedicationNote (optional field)
        if let note = getValue(["DedicationNote", "dedicationNote", "dedication_note"]) as? String {
            self.dedicationNote = note
        } else {
            self.dedicationNote = nil
        }
    }
}

// MARK: - 2. Order Summary View (The Confirmation Popup)

// Helper Row
struct SummaryRow: View {
    let label: String
    let value: String

    var body: some View {
        HStack {
            Text(label + ":").fontWeight(.medium).foregroundColor(.gray)
            Spacer()
            Text(value).foregroundColor(.primary)
        }
    }
}

struct OrderSummaryView: View {
    let order: OrderSummaryResponse
    @Binding var isPresented: Bool // Control for dismissing the modal

    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "hand.thumbsup.fill")
                .resizable()
                .frame(width: 70, height: 70)
                .foregroundColor(.green)

            Text("Order Placed Successfully!").font(.title).bold()

            VStack(alignment: .leading, spacing: 10) {
                // Displaying the required fields
                SummaryRow(label: "Order ID", value: String(order.orderId))
                SummaryRow(label: "Booking ID", value: String(order.bookingId))
                SummaryRow(label: "User ID", value: String(order.userId))
                SummaryRow(label: "Status", value: order.status)
                // Corrected formatting using String(format:)
                SummaryRow(label: "Total Price", value: String(format: "Rs %.0f", order.totalPrice))
                
                // 🆕 Add Dedication Note if exists
                if let note = order.dedicationNote, !note.isEmpty {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Note to Chef:")
                            .font(.caption)
                            .fontWeight(.medium)
                            .foregroundColor(.gray)
                        Text(note)
                            .font(.body)
                            .foregroundColor(.primary)
                            .padding(8)
                            .background(Color.yellow.opacity(0.1))
                            .cornerRadius(8)
                    }
                    .padding(.top, 4)
                }
            }
            .padding()
            .background(Color(.systemGray6))
            .cornerRadius(10)

            Button("Got It!") {
                isPresented = false // Dismiss the modal
            }
            .buttonStyle(.borderedProminent)
            .tint(.blue)
        }
        .padding(30)
        .background(Color.white)
        .cornerRadius(20)
        .shadow(radius: 10)
    }
}

// MARK: - 3. Ingredient and Checkbox Helpers

struct IngredientRow: View {
    let dishId: Int
    let quantity: Int
    let index: Int
    let ingredient: Ingredient
    @Binding var skippedIngredients: [Int: [[Int]]]

    private var binding: Binding<Bool> {
        let currentSets = skippedIngredients[dishId] ?? Array(repeating: [], count: quantity)
        let isSelected = !currentSets[index].contains(ingredient.ingredientId)

        return Binding<Bool>(
            get: { isSelected },
            set: { newValue in
                var sets = skippedIngredients[dishId] ?? Array(repeating: [], count: quantity)
                if newValue {
                    sets[index].removeAll { $0 == ingredient.ingredientId }
                } else {
                    sets[index].append(ingredient.ingredientId)
                }
                skippedIngredients[dishId] = sets
            }
        )
    }

    var body: some View {
        HStack {
            CheckboxView(isOn: binding)
            Text(ingredient.name)
                .font(.footnote)
        }
    }
}

struct CheckboxView: View {
    @Binding var isOn: Bool

    var body: some View {
        Button(action: { isOn.toggle() }) {
            Image(systemName: isOn ? "checkmark.square.fill" : "square")
                .foregroundColor(isOn ? .blue : .gray)
        }
        .buttonStyle(.plain)
    }
}

// MARK: - 4. Sorting Options
enum SortOption {
    case name
    case priceAsc
    case priceDesc
    case prepTime
}

// MARK: - 5. MENU VIEW WITH FILTERS

struct MenuView: View {
    let restaurantId: Int
    let bookingId: Int

    @EnvironmentObject var userVM: UserViewModel

    @State private var dishes: [Dish] = []
    @State private var quantities: [Int: Int] = [:]
    @State private var skippedIngredients: [Int: [[Int]]] = [:]
    @State private var dedicationNote = "" // 🆕 Add dedication note state

    @State private var isLoading = true
    @State private var errorMessage: String?

    @State private var isSubmittingOrder = false
    @State private var orderMessage: String?

    @State private var successfulOrder: OrderSummaryResponse?
    @State private var showingOrderSummary = false

    // FILTER STATES
    @State private var searchText = ""
    @State private var minPrice: Double?
    @State private var maxPrice: Double?
    @State private var sortBy: SortOption = .name

    // ✅ Total bill calculation
    var totalBill: Double {
        dishes.reduce(0.0) { result, dish in
            result + (dish.price * Double(quantities[dish.dishId] ?? 0))
        }
    }

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

    var body: some View {
        VStack {
            if isLoading {
                ProgressView("Loading Menu...")
            } else if let error = errorMessage {
                Text("Error: \(error)").foregroundColor(.red)
            } else {
                // Show filter controls
                filterControlsView

                List {
                    if filteredDishes.isEmpty {
                        Text("No dishes match your filters")
                            .foregroundColor(.gray)
                            .frame(maxWidth: .infinity, alignment: .center)
                            .listRowBackground(Color.clear)
                    } else {
                        ForEach(filteredDishes) { dish in
                            VStack(alignment: .leading, spacing: 6) {
                                // 🔹 Dish row with + / - controls
                                HStack {
                                    AsyncImage(url: URL(string: "http://10.211.55.7/\(dish.dishImageUrl)")) { image in
                                        image.resizable().aspectRatio(contentMode: .fill)
                                    } placeholder: {
                                        Color.gray.opacity(0.1)
                                    }
                                    .frame(width: 60, height: 60)
                                    .cornerRadius(8)

                                    VStack(alignment: .leading) {
                                        Text(dish.dishName).font(.headline)
                                        Text("Rs \(dish.price, specifier: "%.0f") • \(dish.prepTimeMinutes) min")
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
                                } // end HStack

                                // 🔹 Ingredients per quantity (below HStack)
                                if let quantity = quantities[dish.dishId], quantity > 0, !dish.ingredients.isEmpty {
                                    VStack(alignment: .leading, spacing: 8) {
                                        ForEach(0..<quantity, id: \.self) { index in
                                            VStack(alignment: .leading, spacing: 4) {
                                                Text("\(dish.dishName) #\(index + 1)")
                                                    .font(.subheadline)
                                                    .foregroundColor(.blue)

                                                ForEach(dish.ingredients) { ingredient in
                                                    IngredientRow(
                                                        dishId: dish.dishId,
                                                        quantity: quantity,
                                                        index: index,
                                                        ingredient: ingredient,
                                                        skippedIngredients: $skippedIngredients
                                                    )
                                                }
                                            }
                                            .padding(.leading, 70)
                                        }
                                    }
                                }
                            }
                            .padding(.vertical, 6)
                        }

                        // ✅ Summary & Place Order section
                        VStack(spacing: 12) {
                            // 🆕 Dedication Note Field (only show if items are selected)
                            if totalBill > 0 {
                                VStack(alignment: .leading, spacing: 8) {
                                    Text("Note to Chef (Optional)")
                                        .font(.subheadline)
                                        .fontWeight(.medium)
                                        .foregroundColor(.gray)
                                    
                                    TextField("e.g., Less spicy, no nuts, extra crispy...", text: $dedicationNote)
                                        .textFieldStyle(RoundedBorderTextFieldStyle())
                                        .font(.body)
                                        .submitLabel(.done)
                                    
                                    HStack {
                                        Spacer()
                                        Text("\(dedicationNote.count)/200 characters")
                                            .font(.caption)
                                            .foregroundColor(dedicationNote.count > 200 ? .red : .gray)
                                    }
                                }
                                .padding(.horizontal)
                                .padding(.top, 8)
                            }
                            
                            HStack {
                                Spacer()
                                Text("Total: Rs \(totalBill, specifier: "%.0f")")
                                    .font(.title2)
                                    .fontWeight(.bold)
                                    .foregroundColor(.orange)
                                Spacer()
                            }

                            Button(action: submitOrder) {
                                if isSubmittingOrder {
                                    ProgressView()
                                        .frame(maxWidth: .infinity)
                                        .padding()
                                } else {
                                    Text("Place Order")
                                        .frame(maxWidth: .infinity)
                                        .padding()
                                        .background(totalBill > 0 ? Color.blue : Color.gray)
                                        .foregroundColor(.white)
                                        .cornerRadius(10)
                                }
                            }
                            .disabled(isSubmittingOrder || totalBill == 0 || dedicationNote.count > 200)

                            if let message = orderMessage {
                                Text(message)
                                    .foregroundColor(orderMessage == "Order placed successfully!" ? .green : .red)
                                    .padding(.horizontal)
                            }
                        }
                        .padding()
                    }
                }
                .searchable(text: $searchText, prompt: "Search dishes...")
            }
        }
        .navigationTitle("Menu")
        .onAppear {
            fetchMenu()
        }
        // 👇 MODAL PRESENTATION FOR ORDER SUMMARY
        .sheet(isPresented: $showingOrderSummary) {
            if let order = successfulOrder {
                OrderSummaryView(order: order, isPresented: $showingOrderSummary)
            }
        }
    }

    // MARK: - API Functions

    func fetchMenu() {
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

    // ✅ Submit order to API (Uses the resilient OrderSummaryResponse)
    func submitOrder() {
        // 🆕 Validate dedication note length
        if dedicationNote.count > 200 {
            orderMessage = "Note to chef must be 200 characters or less."
            return
        }
        
        guard let userId = userVM.loggedInUserId else {
            orderMessage = "Please log in to place an order."
            return
        }

        // 🔥 Split items logic remains unchanged
        var orderItems: [[String: Any]] = []

        for (dishId, quantity) in quantities where quantity > 0 {
            let skippedSets = skippedIngredients[dishId] ?? Array(repeating: [], count: quantity)

            if skippedSets.allSatisfy({ $0 == skippedSets.first }) {
                orderItems.append([
                    "DishId": dishId,
                    "Quantity": quantity,
                    "SkippedIngredients": skippedSets.first ?? []
                ])
            } else {
                for set in skippedSets {
                    orderItems.append([
                        "DishId": dishId,
                        "Quantity": 1,
                        "SkippedIngredients": set
                    ])
                }
            }
        }

        guard !orderItems.isEmpty else {
            orderMessage = "Please select at least one dish."
            return
        }

        // 🆕 Create order data with dedicationNote
        var orderData: [String: Any] = [
            "UserId": userId,
            "BookingId": bookingId,
            "OrderItems": orderItems
        ]
        
        // 🆕 Add dedicationNote only if not empty
        if !dedicationNote.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            orderData["DedicationNote"] = dedicationNote.trimmingCharacters(in: .whitespacesAndNewlines)
        }

        guard let url = URL(string: "http://10.211.55.7/BooknowAPI/api/order/add") else {
            orderMessage = "Invalid order URL."
            return
        }

        guard let jsonData = try? JSONSerialization.data(withJSONObject: orderData) else {
            orderMessage = "Failed to encode order data."
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = jsonData

        isSubmittingOrder = true
        orderMessage = nil
        self.successfulOrder = nil // Clear previous success state before starting request

        URLSession.shared.dataTask(with: request) { data, response, error in
            DispatchQueue.main.async {
                isSubmittingOrder = false

                if let error = error {
                    orderMessage = "Error: \(error.localizedDescription)"
                    return
                }

                guard let httpResponse = response as? HTTPURLResponse else {
                    orderMessage = "No response from server."
                    return
                }

                if (200...299).contains(httpResponse.statusCode) {
                    // 1. Try to parse as dictionary first
                    if let data = data {
                        // Try to parse as dictionary first, then create OrderSummaryResponse
                        if let jsonDict = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
                           let orderResponse = OrderSummaryResponse(from: jsonDict) {
                            
                            // 2. Store the response and trigger the modal
                            self.successfulOrder = orderResponse
                            self.showingOrderSummary = true

                            // 3. Clear shopping state
                            self.quantities = [:]
                            self.skippedIngredients = [:]
                            self.dedicationNote = "" // 🆕 Clear the note field
                            self.orderMessage = nil
                            
                        } else {
                            // Fallback to standard JSONDecoder
                            do {
                                let orderResponse = try JSONDecoder().decode(OrderSummaryResponse.self, from: data)
                                self.successfulOrder = orderResponse
                                self.showingOrderSummary = true
                                self.quantities = [:]
                                self.skippedIngredients = [:]
                                self.dedicationNote = "" // 🆕 Clear the note field
                                self.orderMessage = nil
                            } catch {
                                print("Decoding error: \(error)")
                                self.orderMessage = "Order placed, but failed to read confirmation details."
                            }
                        }
                    } else {
                        self.orderMessage = "Order placed, but failed to read confirmation details."
                    }
                } else {
                    // Handle server errors (non-200)
                    let serverMsg = String(data: data ?? Data(), encoding: .utf8) ?? "Unknown server error."
                    orderMessage = "Server error (\(httpResponse.statusCode)): \(serverMsg)"
                }
            }
        }.resume()
    }
}
