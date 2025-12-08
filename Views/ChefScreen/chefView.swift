////
////import SwiftUI
////
//
//import Foundation
//import SwiftUI
//
//import SwiftUI
//
//// MARK: - Models
//struct ChefOrder: Codable, Identifiable {
//    let orderId: Int
//    let order: OrderDetails
//    var id: Int { orderId }
//}
//
//struct OrderDetails: Codable {
//    let orderDate: String
//    let status: String
//    let bookingDateTime: String?
//    let dishes: [DishDetails]
//}
//
//struct DishDetails: Codable, Identifiable {
//    let orderItemId: Int
//    let dishId: Int
//    let dishName: String
//    let quantity: Int
//    let prepTimeMinutes: Int?
//    let skippedIngredients: [String]
//    var id: Int { orderItemId }
//}
//
//// MARK: - ViewModel
//@MainActor
//class ChefOrdersViewModel: ObservableObject {
//
//    @Published var visibleOrders: [ChefOrder] = []
//    @Published var upcomingOrders: [ChefOrder] = []
//    @Published var isLoading = false
//    @Published var errorMessage: String?
//
//    private let isoWithFractional: ISO8601DateFormatter = {
//        let f = ISO8601DateFormatter()
//        f.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
//        return f
//    }()
//
//    private let isoNoFraction: ISO8601DateFormatter = {
//        let f = ISO8601DateFormatter()
//        f.formatOptions = [.withInternetDateTime]
//        return f
//    }()
//
//    private func parseISODate(_ s: String) -> Date? {
//        if let d = isoWithFractional.date(from: s) { return d }
//        if let d = isoNoFraction.date(from: s) { return d }
//        return nil
//    }
//
//    // MARK: Fetch Orders
//    func fetchOrders(for chefId: Int) async {
//
//        guard let url = URL(string: "http://10.211.55.7/BooknowAPI/api/cheforder/byid/\(chefId)") else {
//            errorMessage = "Invalid API URL"
//            return
//        }
//
//        isLoading = true
//        errorMessage = nil
//
//        do {
//            let (data, response) = try await URLSession.shared.data(from: url)
//
//            if let httpResponse = response as? HTTPURLResponse,
//               !(httpResponse.mimeType?.contains("application/json") ?? false)
//            {
//                errorMessage = "Server did not return JSON"
//                isLoading = false
//                return
//            }
//
//            let decoded = try JSONDecoder().decode([ChefOrder].self, from: data)
//            visibleOrders = decoded.filter { $0.order.status.lowercased() != "completed" }
//            upcomingOrders = []
//
//            isLoading = false
//
//        } catch {
//            errorMessage = error.localizedDescription
//            isLoading = false
//        }
//    }
//
//    // MARK: Update Status
//    func updateOrderStatus(orderId: Int, status: String) async -> Bool {
//
//        print("🔥 ENTER updateOrderStatus for order \(orderId)")
//
//        guard let url = URL(string: "http://10.211.55.7/BooknowAPI/api/order/status/\(orderId)") else {
//            print("❌ Invalid URL")
//            return false
//        }
//
//        var request = URLRequest(url: url)
//        request.httpMethod = "PUT"
//        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
//
//        let jsonBody: [String: String] = ["status": status]
//        request.httpBody = try? JSONEncoder().encode(jsonBody)
//
//        do {
//            let (data, response) = try await URLSession.shared.data(for: request)
//
//            guard let http = response as? HTTPURLResponse else { return false }
//
//            print("📡 HTTP CODE:", http.statusCode)
//            print("Server:", String(data: data, encoding: .utf8) ?? "<none>")
//
//            return http.statusCode == 200
//
//        } catch {
//            print("❌ ERROR:", error.localizedDescription)
//            return false
//        }
//    }
//}
//
//// MARK: - Main View
//struct ChefView: View {
//
//    @Binding var rootPath: NavigationPath
//    @EnvironmentObject var userVM: UserViewModel
//    @EnvironmentObject var viewModel: ChefOrdersViewModel
//
//    var body: some View {
//
//        VStack {
//            Text("Chef Home")
//                .font(.title)
//                .foregroundColor(.green)
//
//            if viewModel.isLoading {
//                ProgressView("Loading orders…")
//            }
//            else {
//
//                ScrollView {
//                    VStack(spacing: 24) {
//
//                        if !viewModel.visibleOrders.isEmpty {
//                            Text("Orders To Prepare")
//                                .font(.headline)
//                                .foregroundColor(.orange)
//
//                            LazyVStack(spacing: 16) {
//
//                                ForEach(viewModel.visibleOrders) { order in
//
//                                    ChefOrderCard(order: order) {
//
//                                        Task {
//                                            let ok = await viewModel.updateOrderStatus(orderId: order.orderId, status: "InProgress")
//                                            if ok { await reload() }
//                                        }
//
//                                    } onCompleted: {
//
//                                        Task {
//                                            let ok = await viewModel.updateOrderStatus(orderId: order.orderId, status: "Completed")
//                                            if ok { await reload() }
//                                        }
//                                    }
//                                }
//                            }
//                        }
//                    }
//                    .padding()
//                }
//            }
//        }
//        .task {
//            await load()
//        }
//    }
//
//    func load() async {
//        if let chefId = userVM.loggedInUserId {
//            await viewModel.fetchOrders(for: chefId)
//        }
//    }
//
//    func reload() async {
//        await load()
//    }
//}
//
//// MARK: - Reusable Components
//struct ChefOrderCard: View {
//    let order: ChefOrder
//    let onStartPrep: () -> Void
//    let onCompleted: () -> Void
//
//    init(order: ChefOrder, onStartPrep: @escaping () -> Void, onCompleted: @escaping () -> Void) {
//        self.order = order
//        self.onStartPrep = onStartPrep
//        self.onCompleted = onCompleted
//    }
//
//    var body: some View {
//        VStack(alignment: .leading, spacing: 10) {
//
//            Text("Order #\(order.orderId)")
//                .font(.headline)
//
//            Text("Status: \(order.order.status)")
//                .foregroundColor(.blue)
//
//            ForEach(order.order.dishes) { dish in
//                DishRow(dish: dish)
//            }
//
//            HStack {
//                Button("Start Prep") { onStartPrep() }
//                    .buttonStyle(.borderedProminent)
//
//                Button("Completed") { onCompleted() }
//                    .buttonStyle(.bordered)
//            }
//        }
//        .padding()
//        .background(Color(.systemGray6))
//        .cornerRadius(12)
//        .shadow(radius: 2)
//    }
//}
//
//// MARK: - Dish Row
//struct DishRow: View {
//    let dish: DishDetails
//
//    var body: some View {
//        HStack {
//            Text(dish.dishName)
//            Spacer()
//            Text("x\(dish.quantity)")
//        }
//    }
//}

//
//import SwiftUI
//
//// MARK: - Models
//struct ChefOrder: Codable, Identifiable {
//    let orderId: Int
//    let order: OrderDetails
//    var id: Int { orderId }
//}
//
//struct OrderDetails: Codable {
//    let orderDate: String
//    let status: String
//    let bookingDateTime: String?
//    let dishes: [DishDetails]
//}
//
//struct DishDetails: Codable, Identifiable {
//    let orderItemId: Int
//    let dishId: Int
//    let dishName: String
//    let quantity: Int
//    let prepTimeMinutes: Int?
//    let skippedIngredients: [String]
//    var id: Int { orderItemId }
//}
//
//// MARK: - ViewModel
//@MainActor
//class ChefOrdersViewModel: ObservableObject {
//
//    @Published var visibleOrders: [ChefOrder] = []
//    @Published var upcomingOrders: [ChefOrder] = []
//    @Published var isLoading = false
//    @Published var errorMessage: String?
//
//    private let isoWithFractional: ISO8601DateFormatter = {
//        let f = ISO8601DateFormatter()
//        f.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
//        return f
//    }()
//
//    private let isoNoFraction: ISO8601DateFormatter = {
//        let f = ISO8601DateFormatter()
//        f.formatOptions = [.withInternetDateTime]
//        return f
//    }()
//
//    private func parseISODate(_ s: String) -> Date? {
//        if let d = isoWithFractional.date(from: s) { return d }
//        if let d = isoNoFraction.date(from: s) { return d }
//        return nil
//    }
//
//    // MARK: Fetch Orders
//    func fetchOrders(for chefId: Int) async {
//
//        guard let url = URL(string: "http://10.211.55.7/BooknowAPI/api/cheforder/byid/\(chefId)") else {
//            errorMessage = "Invalid API URL"
//            return
//        }
//
//        isLoading = true
//        errorMessage = nil
//
//        do {
//            let (data, response) = try await URLSession.shared.data(from: url)
//
//            if let httpResponse = response as? HTTPURLResponse,
//               !(httpResponse.mimeType?.contains("application/json") ?? false)
//            {
//                errorMessage = "Server did not return JSON"
//                isLoading = false
//                return
//            }
//
//            let decoded = try JSONDecoder().decode([ChefOrder].self, from: data)
//            visibleOrders = decoded.filter { $0.order.status.lowercased() != "completed" }
//            upcomingOrders = []
//
//            isLoading = false
//
//        } catch {
//            errorMessage = error.localizedDescription
//            isLoading = false
//        }
//    }
//
//    // MARK: Update Status
//    func updateOrderStatus(orderId: Int, status: String) async -> Bool {
//
//        print("🔥 ENTER updateOrderStatus for order \(orderId)")
//
//        guard let url = URL(string: "http://10.211.55.7/BooknowAPI/api/order/status/\(orderId)") else {
//            print("❌ Invalid URL")
//            return false
//        }
//
//        var request = URLRequest(url: url)
//        request.httpMethod = "PUT"
//        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
//
//        let jsonBody: [String: String] = ["status": status]
//        request.httpBody = try? JSONEncoder().encode(jsonBody)
//
//        do {
//            let (data, response) = try await URLSession.shared.data(for: request)
//
//            guard let http = response as? HTTPURLResponse else { return false }
//
//            print("📡 HTTP CODE:", http.statusCode)
//            print("Server:", String(data: data, encoding: .utf8) ?? "<none>")
//
//            return http.statusCode == 200
//
//        } catch {
//            print("❌ ERROR:", error.localizedDescription)
//            return false
//        }
//    }
//}
//
//// MARK: - Main View
//struct ChefView: View {
//
//    @Binding var rootPath: NavigationPath
//    @EnvironmentObject var userVM: UserViewModel
//    @EnvironmentObject var viewModel: ChefOrdersViewModel
//
//    var body: some View {
//
//        VStack {
//            Text("Chef Home")
//                .font(.title)
//                .foregroundColor(.green)
//
//            if viewModel.isLoading {
//                ProgressView("Loading orders…")
//            }
//            else {
//
//                ScrollView {
//                    VStack(spacing: 24) {
//
//                        if !viewModel.visibleOrders.isEmpty {
//                            Text("Orders To Prepare")
//                                .font(.headline)
//                                .foregroundColor(.orange)
//
//                            LazyVStack(spacing: 16) {
//
//                                ForEach(viewModel.visibleOrders) { order in
//
//                                    ChefOrderCard(order: order) {
//
//                                        Task {
//                                            let ok = await viewModel.updateOrderStatus(orderId: order.orderId, status: "InProgress")
//                                            if ok { await reload() }
//                                        }
//
//                                    } onCompleted: {
//
//                                        Task {
//                                            let ok = await viewModel.updateOrderStatus(orderId: order.orderId, status: "Completed")
//                                            if ok { await reload() }
//                                        }
//                                    }
//                                }
//                            }
//                        }
//                    }
//                    .padding()
//                }
//            }
//        }
//        .task {
//            await load()
//        }
//    }
//
//    func load() async {
//        if let chefId = userVM.loggedInUserId {
//            await viewModel.fetchOrders(for: chefId)
//        }
//    }
//
//    func reload() async {
//        await load()
//    }
//}
//
//// MARK: - Reusable Components
//struct ChefOrderCard: View {
//    let order: ChefOrder
//    let onStartPrep: () -> Void
//    let onCompleted: () -> Void
//
//    init(order: ChefOrder, onStartPrep: @escaping () -> Void, onCompleted: @escaping () -> Void) {
//        self.order = order
//        self.onStartPrep = onStartPrep
//        self.onCompleted = onCompleted
//    }
//
//    var body: some View {
//        VStack(alignment: .leading, spacing: 12) {
//
//            Text("Order #\(order.orderId)")
//                .font(.headline)
//
//            Text("Status: \(order.order.status)")
//                .foregroundColor(.blue)
//
//            VStack(alignment: .leading, spacing: 8) {
//                ForEach(order.order.dishes) { dish in
//                    DishRow(dish: dish)
//                }
//            }
//            .padding(.vertical, 4)
//
//            HStack {
//                Button("Start Prep") { onStartPrep() }
//                    .buttonStyle(.borderedProminent)
//                    .tint(.orange)
//
//                Button("Completed") { onCompleted() }
//                    .buttonStyle(.bordered)
//                    .tint(.green)
//            }
//        }
//        .padding()
//        .background(Color(.systemGray6))
//        .cornerRadius(12)
//        .shadow(radius: 2)
//    }
//}
//
//// MARK: - Dish Row
//struct DishRow: View {
//    let dish: DishDetails
//
//    var body: some View {
//        VStack(alignment: .leading, spacing: 4) {
//            // Dish name and quantity
//            HStack {
//                Text(dish.dishName)
//                    .font(.body)
//                    .fontWeight(.medium)
//                Spacer()
//                Text("x\(dish.quantity)")
//                    .font(.body)
//                    .foregroundColor(.secondary)
//            }
//
//            // Skipped ingredients section
//            if !dish.skippedIngredients.isEmpty {
//                VStack(alignment: .leading, spacing: 2) {
//                    Text("Skipped Ingredients:")
//                        .font(.caption)
//                        .fontWeight(.semibold)
//                        .foregroundColor(.red)
//
//                    ForEach(dish.skippedIngredients, id: \.self) { ingredient in
//                        HStack(alignment: .top, spacing: 4) {
//                            Image(systemName: "xmark.circle.fill")
//                                .font(.caption)
//                                .foregroundColor(.red)
//                            Text(ingredient)
//                                .font(.caption)
//                                .foregroundColor(.secondary)
//                        }
//                    }
//                }
//                .padding(.leading, 8)
//                .padding(.top, 2)
//            }
//
//            // Preparation time (if available)
//            if let prepTime = dish.prepTimeMinutes {
//                HStack {
//                    Image(systemName: "clock")
//                        .font(.caption)
//                        .foregroundColor(.blue)
//                    Text("Prep time: \(prepTime) min")
//                        .font(.caption)
//                        .foregroundColor(.blue)
//                }
//                .padding(.top, 2)
//            }
//        }
//        .padding(.vertical, 4)
//        .padding(.horizontal, 8)
//        .background(
//            RoundedRectangle(cornerRadius: 8)
//                .fill(Color(.systemBackground))
//                .overlay(
//                    RoundedRectangle(cornerRadius: 8)
//                        .stroke(Color.gray.opacity(0.3), lineWidth: 1)
//                )
//        )
//    }
//}
//
//// MARK: - Preview
//struct ChefView_Previews: PreviewProvider {
//    static var previews: some View {
//        let sampleDish = DishDetails(
//            orderItemId: 1,
//            dishId: 101,
//            dishName: "Vegetable Pizza",
//            quantity: 2,
//            prepTimeMinutes: 20,
//            skippedIngredients: ["Onions", "Mushrooms", "Extra Cheese"]
//        )
//
//        let sampleOrder = ChefOrder(
//            orderId: 123,
//            order: OrderDetails(
//                orderDate: "2024-01-15",
//                status: "Pending",
//                bookingDateTime: "2024-01-15T19:30:00",
//                dishes: [sampleDish]
//            )
//        )
//
//        NavigationStack {
//            ChefView(rootPath: .constant(NavigationPath()))
//                .environmentObject(UserViewModel())
//                .environmentObject(ChefOrdersViewModel())
//        }
//    }
//}

import SwiftUI

// MARK: - Models
struct ChefOrder: Codable, Identifiable {
    let orderId: Int
    let order: OrderDetails
    var id: Int { orderId }
}

struct OrderDetails: Codable {
    let orderDate: String
    let status: String
    let bookingDateTime: String?
    let dishes: [DishDetails]
}

struct DishDetails: Codable, Identifiable {
    let orderItemId: Int
    let dishId: Int
    let dishName: String
    let quantity: Int
    let prepTimeMinutes: Int?
    let skippedIngredients: [String]
    var id: Int { orderItemId }
}

// MARK: - ViewModel
@MainActor
class ChefOrdersViewModel: ObservableObject {

    @Published var visibleOrders: [ChefOrder] = []
    @Published var upcomingOrders: [ChefOrder] = []
    @Published var isLoading = false
    @Published var errorMessage: String?

    private let isoWithFractional: ISO8601DateFormatter = {
        let f = ISO8601DateFormatter()
        f.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        return f
    }()

    private let isoNoFraction: ISO8601DateFormatter = {
        let f = ISO8601DateFormatter()
        f.formatOptions = [.withInternetDateTime]
        return f
    }()

    private func parseISODate(_ s: String) -> Date? {
        if let d = isoWithFractional.date(from: s) { return d }
        if let d = isoNoFraction.date(from: s) { return d }
        return nil
    }
    
    func formatBookingDateTime(_ dateString: String?) -> String? {
        guard let dateString = dateString else { return nil }
        
        if let date = parseISODate(dateString) {
            let formatter = DateFormatter()
            formatter.dateStyle = .medium
            formatter.timeStyle = .short
            return formatter.string(from: date)
        }
        return dateString // Return original if can't parse
    }

    // MARK: Fetch Orders
    func fetchOrders(for chefId: Int) async {

        guard let url = URL(string: "http://10.211.55.7/BooknowAPI/api/cheforder/byid/\(chefId)") else {
            errorMessage = "Invalid API URL"
            return
        }

        isLoading = true
        errorMessage = nil

        do {
            let (data, response) = try await URLSession.shared.data(from: url)

            if let httpResponse = response as? HTTPURLResponse,
               !(httpResponse.mimeType?.contains("application/json") ?? false)
            {
                errorMessage = "Server did not return JSON"
                isLoading = false
                return
            }

            let decoded = try JSONDecoder().decode([ChefOrder].self, from: data)
            visibleOrders = decoded.filter { $0.order.status.lowercased() != "completed" }
            upcomingOrders = []

            isLoading = false

        } catch {
            errorMessage = error.localizedDescription
            isLoading = false
        }
    }

    // MARK: Update Status
    func updateOrderStatus(orderId: Int, status: String) async -> Bool {

        print("🔥 ENTER updateOrderStatus for order \(orderId)")

        guard let url = URL(string: "http://10.211.55.7/BooknowAPI/api/order/status/\(orderId)") else {
            print("❌ Invalid URL")
            return false
        }

        var request = URLRequest(url: url)
        request.httpMethod = "PUT"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        let jsonBody: [String: String] = ["status": status]
        request.httpBody = try? JSONEncoder().encode(jsonBody)

        do {
            let (data, response) = try await URLSession.shared.data(for: request)

            guard let http = response as? HTTPURLResponse else { return false }

            print("📡 HTTP CODE:", http.statusCode)
            print("Server:", String(data: data, encoding: .utf8) ?? "<none>")

            return http.statusCode == 200

        } catch {
            print("❌ ERROR:", error.localizedDescription)
            return false
        }
    }
}

// MARK: - Main View
struct ChefView: View {

    @Binding var rootPath: NavigationPath
    @EnvironmentObject var userVM: UserViewModel
    @EnvironmentObject var viewModel: ChefOrdersViewModel

    var body: some View {

        VStack {
            Text("Chef Home")
                .font(.title)
                .foregroundColor(.green)

            if viewModel.isLoading {
                ProgressView("Loading orders…")
            }
            else {

                ScrollView {
                    VStack(spacing: 24) {

                        if !viewModel.visibleOrders.isEmpty {
                            Text("Orders To Prepare")
                                .font(.headline)
                                .foregroundColor(.orange)

                            LazyVStack(spacing: 16) {

                                ForEach(viewModel.visibleOrders) { order in

                                    ChefOrderCard(order: order, viewModel: viewModel) {

                                        Task {
                                            let ok = await viewModel.updateOrderStatus(orderId: order.orderId, status: "InProgress")
                                            if ok { await reload() }
                                        }

                                    } onCompleted: {

                                        Task {
                                            let ok = await viewModel.updateOrderStatus(orderId: order.orderId, status: "Completed")
                                            if ok { await reload() }
                                        }
                                    }
                                }
                            }
                        }
                    }
                    .padding()
                }
            }
        }
        .task {
            await load()
        }
    }

    func load() async {
        if let chefId = userVM.loggedInUserId {
            await viewModel.fetchOrders(for: chefId)
        }
    }

    func reload() async {
        await load()
    }
}

// MARK: - Reusable Components
struct ChefOrderCard: View {
    let order: ChefOrder
    let viewModel: ChefOrdersViewModel
    let onStartPrep: () -> Void
    let onCompleted: () -> Void

    init(order: ChefOrder, viewModel: ChefOrdersViewModel, onStartPrep: @escaping () -> Void, onCompleted: @escaping () -> Void) {
        self.order = order
        self.viewModel = viewModel
        self.onStartPrep = onStartPrep
        self.onCompleted = onCompleted
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {

            // Order header
            HStack {
                Text("Order #\(order.orderId)")
                    .font(.headline)
                    .fontWeight(.bold)
                
                Spacer()
                
                Text(order.order.status)
                    .font(.caption)
                    .fontWeight(.semibold)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(statusColor(for: order.order.status))
                    .foregroundColor(.white)
                    .cornerRadius(8)
            }
            
            // Booking date and time
            if let bookingDateTime = viewModel.formatBookingDateTime(order.order.bookingDateTime) {
                HStack {
                    Image(systemName: "calendar.badge.clock")
                        .font(.caption)
                        .foregroundColor(.blue)
                    Text("Serving Time: \(bookingDateTime)")
                        .font(.subheadline)
                        .foregroundColor(.primary)
                }
                .padding(.vertical, 2)
            }
            
            // Order date
            if let orderDate = viewModel.formatBookingDateTime(order.order.orderDate) {
                HStack {
                    Image(systemName: "clock.arrow.circlepath")
                        .font(.caption)
                        .foregroundColor(.gray)
                    Text("Order placed: \(orderDate)")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                .padding(.vertical, 2)
            }
            
            Divider()
                .padding(.vertical, 4)

            // Dishes section
            Text("Dishes:")
                .font(.subheadline)
                .fontWeight(.semibold)
                .foregroundColor(.primary)
            
            VStack(alignment: .leading, spacing: 8) {
                ForEach(order.order.dishes) { dish in
                    DishRow(dish: dish)
                }
            }
            .padding(.vertical, 4)

            Divider()
                .padding(.vertical, 4)

            // Action buttons
            HStack {
                Button("Start Preparation") { onStartPrep() }
                    .buttonStyle(.borderedProminent)
                    .tint(.orange)

                Spacer()

                Button("Mark as Completed") { onCompleted() }
                    .buttonStyle(.bordered)
                    .tint(.green)
            }
            .padding(.top, 4)
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
        .shadow(radius: 2)
    }
    
    private func statusColor(for status: String) -> Color {
        switch status.lowercased() {
        case "pending", "received":
            return .orange
        case "inprogress", "preparing", "cooking":
            return .blue
        case "ready", "completed":
            return .green
        default:
            return .gray
        }
    }
}

// MARK: - Dish Row
struct DishRow: View {
    let dish: DishDetails
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            // Dish name and quantity
            HStack {
                Text(dish.dishName)
                    .font(.body)
                    .fontWeight(.medium)
                Spacer()
                Text("x\(dish.quantity)")
                    .font(.body)
                    .foregroundColor(.secondary)
            }
            
            // Skipped ingredients section
            if !dish.skippedIngredients.isEmpty {
                VStack(alignment: .leading, spacing: 2) {
                    Text("Skipped Ingredients:")
                        .font(.caption)
                        .fontWeight(.semibold)
                        .foregroundColor(.red)
                    
                    ForEach(dish.skippedIngredients, id: \.self) { ingredient in
                        HStack(alignment: .top, spacing: 4) {
                            Image(systemName: "xmark.circle.fill")
                                .font(.caption)
                                .foregroundColor(.red)
                            Text(ingredient)
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                }
                .padding(.leading, 8)
                .padding(.top, 2)
            }
            
            // Preparation time (if available)
            if let prepTime = dish.prepTimeMinutes {
                HStack {
                    Image(systemName: "clock")
                        .font(.caption)
                        .foregroundColor(.blue)
                    Text("Prep time: \(prepTime) min")
                        .font(.caption)
                        .foregroundColor(.blue)
                }
                .padding(.top, 2)
            }
        }
        .padding(.vertical, 4)
        .padding(.horizontal, 8)
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(Color(.systemBackground))
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                )
        )
    }
}

// MARK: - Preview
struct ChefView_Previews: PreviewProvider {
    static var previews: some View {
        let sampleDish = DishDetails(
            orderItemId: 1,
            dishId: 101,
            dishName: "Vegetable Pizza",
            quantity: 2,
            prepTimeMinutes: 20,
            skippedIngredients: ["Onions", "Mushrooms", "Extra Cheese"]
        )
        
        let sampleOrder = ChefOrder(
            orderId: 123,
            order: OrderDetails(
                orderDate: "2024-01-15T14:30:00",
                status: "Pending",
                bookingDateTime: "2024-01-15T19:30:00",
                dishes: [sampleDish]
            )
        )
        
        NavigationStack {
            ChefView(rootPath: .constant(NavigationPath()))
                .environmentObject(UserViewModel())
                .environmentObject(ChefOrdersViewModel())
        }
    }
}
