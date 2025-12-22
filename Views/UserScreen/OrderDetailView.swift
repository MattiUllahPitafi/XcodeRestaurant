//
//import SwiftUI
//
//struct OrderDetailView: View {
//    @EnvironmentObject var userVM: UserViewModel
//    @State private var orders: [Order] = []
//    @State private var isLoading = true
//    @State private var errorMessage: String?
//
//    var body: some View {
//        VStack {
//            if isLoading {
//                ProgressView("Loading Orders...")
//            } else if let errorMessage = errorMessage {
//                Text(errorMessage).foregroundColor(.red)
//            } else if orders.isEmpty {
//                Text("No orders found").foregroundColor(.gray)
//            } else {
//                List(orders) { order in
//
//                        VStack(alignment: .leading) {
//                            Text("Order #\(order.orderId)")
//                                .font(.headline)
//                            Text("Status: \(order.status)")
//                                .foregroundColor(order.status == "Placed" ? .green : .red)
//                            Text("Total: Rs \(order.totalPrice, specifier: "%.2f")")
//                                .font(.subheadline)
//                                            }
//                }
//            }
//        }
//        .navigationTitle("My Orders")
//        .onAppear {
//            fetchOrders()
//        }
//    }
//
//    private func fetchOrders() {
//        guard let userId = userVM.loggedInUserId else {
//            errorMessage = "User not logged in"
//            isLoading = false
//            return
//        }
//
//        guard let url = URL(string: "http://10.211.55.4/BooknowAPI/api/order/byUser/\(userId)") else {
//            errorMessage = "Invalid API URL"
//            isLoading = false
//            return
//        }
//
//        URLSession.shared.dataTask(with: url) { data, _, error in
//            DispatchQueue.main.async {
//                if let error = error {
//                    errorMessage = "Error: \(error.localizedDescription)"
//                    isLoading = false
//                    return
//                }
//
//                guard let data = data else {
//                    errorMessage = "No data received"
//                    isLoading = false
//                    return
//                }
//
//                do {
//                    orders = try JSONDecoder().decode([Order].self, from: data)
//                } catch {
//                    errorMessage = "Decoding error: \(error.localizedDescription)"
//                }
//
//                isLoading = false
//            }
//        }.resume()
//    }
//}

import SwiftUI

enum OrderStatusFilter: String, CaseIterable {
    case all = "All"
    case placed = "Placed"
    case cancelled = "Cancelled"
    case completed = "Completed"
    case inProgress = "InProgress"
}

enum OrderSortOption: String, CaseIterable {
    case dateRecent = "Date (Recent)"
    case dateOldest = "Date (Oldest)"
    case priceHigh = "Price (High)"
    case priceLow = "Price (Low)"
}

struct OrderDetailView: View {
    @EnvironmentObject var userVM: UserViewModel
    @State private var orders: [Order] = []
    @State private var isLoading = true
    @State private var errorMessage: String?
    @State private var isCancelling = false
    @State private var successMessage: String?
    @State private var selectedOrder: Order?
    @State private var showOrderDetail = false
    
    // Filter states
    @State private var searchText = ""
    @State private var selectedStatus: OrderStatusFilter = .all
    @State private var sortBy: OrderSortOption = .dateRecent
    @State private var dateFilter: DateFilterOption = .all
    
    enum DateFilterOption: String, CaseIterable {
        case all = "All Time"
        case today = "Today"
        case thisWeek = "This Week"
        case thisMonth = "This Month"
    }

    var body: some View {
        VStack(spacing: 0) {
            if isLoading {
                ProgressView("Loading Orders...")
            } else if let errorMessage = errorMessage {
                Text(errorMessage).foregroundColor(.red)
            } else if orders.isEmpty {
                Text("No orders found").foregroundColor(.gray)
            } else {
                mainContent
            }
        }
        .overlay(
            // ✅ Show success message
            Group {
                if let successMessage = successMessage {
                    VStack {
                        Spacer()
                        Text(successMessage)
                            .foregroundColor(.green)
                            .padding()
                            .background(Color.white.opacity(0.9))
                            .cornerRadius(8)
                            .padding()
                    }
                }
            }
        )
        .navigationTitle("My Orders")
        .sheet(isPresented: $showOrderDetail) {
            if let order = selectedOrder {
                UserOrderDetailView(order: order)
            }
        }
        .onAppear {
            fetchOrders()
        }
    }
    
    // MARK: - Filtered Orders
    private var filteredOrders: [Order] {
        var filtered = orders
        
        // Apply status filter
        if selectedStatus != .all {
            filtered = filtered.filter { order in
                order.status.lowercased() == selectedStatus.rawValue.lowercased()
            }
        }
        
        // Apply search filter (by order ID)
        if !searchText.isEmpty {
            filtered = filtered.filter { order in
                "\(order.orderId)".contains(searchText)
            }
        }
        
        // Apply date filter
        let calendar = Calendar.current
        let now = Date()
        filtered = filtered.filter { order in
            guard let orderDate = parseDate(order.orderDate) else { return false }
            
            switch dateFilter {
            case .all:
                return true
            case .today:
                return calendar.isDateInToday(orderDate)
            case .thisWeek:
                return calendar.isDate(orderDate, equalTo: now, toGranularity: .weekOfYear)
            case .thisMonth:
                return calendar.isDate(orderDate, equalTo: now, toGranularity: .month)
            }
        }
        
        // Apply sorting
        filtered.sort { order1, order2 in
            switch sortBy {
            case .dateRecent:
                let date1 = parseDate(order1.orderDate) ?? .distantPast
                let date2 = parseDate(order2.orderDate) ?? .distantPast
                return date1 > date2
            case .dateOldest:
                let date1 = parseDate(order1.orderDate) ?? .distantPast
                let date2 = parseDate(order2.orderDate) ?? .distantPast
                return date1 < date2
            case .priceHigh:
                return order1.totalPrice > order2.totalPrice
            case .priceLow:
                return order1.totalPrice < order2.totalPrice
            }
        }
        
        return filtered
    }
    
    // MARK: - Main Content View
    @ViewBuilder
    private var mainContent: some View {
        // Filter controls
        filterControlsView
        
        // Filtered orders list
        ordersListView
    }
    
    // MARK: - Orders List View
    @ViewBuilder
    private var ordersListView: some View {
        List {
            if filteredOrders.isEmpty {
                Text("No orders match your filters")
                    .foregroundColor(.gray)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .listRowBackground(Color.clear)
            } else {
                ForEach(filteredOrders) { order in
                    orderRowView(order: order)
                }
            }
        }
    }
    
    // MARK: - Order Row View
    @ViewBuilder
    private func orderRowView(order: Order) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Button(action: {
                selectedOrder = order
                showOrderDetail = true
            }) {
                HStack {
                    Text("Order #\(order.orderId)")
                        .font(.headline)
                        .foregroundColor(.primary)
                    Spacer()
                    Image(systemName: "chevron.right")
                        .foregroundColor(.gray)
                        .font(.caption)
                }
            }
            .buttonStyle(PlainButtonStyle())
            
            Text("Status: \(order.status)")
                .foregroundColor(order.status == "Placed" ? .green : .red)
            Text("Total: Rs \(String(format: "%.2f", order.totalPrice))")
                .font(.subheadline)
            Text("Date: \(order.orderDate)")
                .font(.caption)
                .foregroundColor(.gray)

            // ✅ Cancel button (only if not already cancelled)
            if order.status.lowercased() != "cancelled" {
                Button(action: {
                    cancelOrder(orderId: order.orderId)
                }) {
                    if isCancelling {
                        ProgressView()
                    } else {
                        Text("Cancel Order")
                            .foregroundColor(.white)
                            .padding(.vertical, 6)
                            .padding(.horizontal, 12)
                            .background(Color.red)
                            .cornerRadius(8)
                    }
                }
                .padding(.top, 4)
            }
        }
        .padding(.vertical, 6)
    }
    
    // MARK: - Filter Controls View
    private var filterControlsView: some View {
        VStack(spacing: 12) {
            // Search bar
            HStack {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(.gray)
                TextField("Search by Order ID...", text: $searchText)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .autocapitalization(.none)
                if !searchText.isEmpty {
                    Button(action: { searchText = "" }) {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(.gray)
                    }
                }
            }
            .padding(.horizontal)
            
            // Status filter
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 10) {
                    ForEach(OrderStatusFilter.allCases, id: \.self) { status in
                        Button(action: { selectedStatus = status }) {
                            Text(status.rawValue)
                                .font(.subheadline)
                                .padding(.horizontal, 16)
                                .padding(.vertical, 8)
                                .background(selectedStatus == status ? Color.blue : Color.gray.opacity(0.2))
                                .foregroundColor(selectedStatus == status ? .white : .primary)
                                .cornerRadius(8)
                        }
                    }
                }
                .padding(.horizontal)
            }
            
            // Sort and Date filters
            HStack(spacing: 12) {
                // Sort picker
                VStack(alignment: .leading, spacing: 4) {
                    Text("Sort:")
                        .font(.caption)
                        .foregroundColor(.gray)
                    Picker("Sort", selection: $sortBy) {
                        ForEach(OrderSortOption.allCases, id: \.self) { option in
                            Text(option.rawValue).tag(option)
                        }
                    }
                    .pickerStyle(.menu)
                }
                
                Spacer()
                
                // Date filter picker
                VStack(alignment: .trailing, spacing: 4) {
                    Text("Date:")
                        .font(.caption)
                        .foregroundColor(.gray)
                    Picker("Date", selection: $dateFilter) {
                        ForEach(DateFilterOption.allCases, id: \.self) { option in
                            Text(option.rawValue).tag(option)
                        }
                    }
                    .pickerStyle(.menu)
                }
            }
            .padding(.horizontal)
        }
        .padding(.vertical, 8)
        .background(Color(.systemGray6))
    }
    
    // MARK: - Helper Functions
    private func parseDate(_ dateString: String) -> Date? {
        let formatters = [
            "yyyy-MM-dd'T'HH:mm:ss",
            "yyyy-MM-dd'T'HH:mm:ss.SSS",
            "yyyy-MM-dd HH:mm:ss",
            "yyyy-MM-dd"
        ]
        
        for format in formatters {
            let formatter = DateFormatter()
            formatter.dateFormat = format
            formatter.locale = Locale(identifier: "en_US_POSIX")
            if let date = formatter.date(from: dateString) {
                return date
            }
        }
        
        return nil
    }

    // MARK: - Fetch Orders
    private func fetchOrders() {
        guard let userId = userVM.loggedInUserId else {
            errorMessage = "User not logged in"
            isLoading = false
            return
        }

        guard let url = URL(string: "http://10.211.55.7/BooknowAPI/api/order/byUser/\(userId)") else {
            errorMessage = "Invalid API URL"
            isLoading = false
            return
        }

        URLSession.shared.dataTask(with: url) { data, _, error in
            DispatchQueue.main.async {
                if let error = error {
                    errorMessage = "Error: \(error.localizedDescription)"
                    isLoading = false
                    return
                }

                guard let data = data else {
                    errorMessage = "No data received"
                    isLoading = false
                    return
                }

                do {
                    orders = try JSONDecoder().decode([Order].self, from: data)
                } catch {
                    errorMessage = "Decoding error: \(error.localizedDescription)"
                }

                isLoading = false
            }
        }.resume()
    }

//    // MARK: - Cancel Order
//    private func cancelOrder(orderId: Int) {
//        guard let url = URL(string: "http://10.211.55.4/BooknowAPI/api/order/status/\(orderId)") else {
//            errorMessage = "Invalid cancel URL"
//            return
//        }
//
//        var request = URLRequest(url: url)
//        request.httpMethod = "PUT"   // ✅ assuming PUT updates status
//        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
//
//        let body = ["Cancelled"]
//        request.httpBody = try? JSONSerialization.data(withJSONObject: body)
//
//        isCancelling = true
//        successMessage = nil
//        errorMessage = nil
//
//        URLSession.shared.dataTask(with: request) { data, response, error in
//            DispatchQueue.main.async {
//                isCancelling = false
//
//                if let error = error {
//                    errorMessage = "Cancel failed: \(error.localizedDescription)"
//                    return
//                }
//
//                guard let httpResponse = response as? HTTPURLResponse,
//                      (200...299).contains(httpResponse.statusCode) else {
//                    let serverMsg = String(data: data ?? Data(), encoding: .utf8) ?? "Unknown server error"
//                    errorMessage = "Cancel failed: \(serverMsg)"
//                    return
//                }
//
//                // ✅ Update UI
//                successMessage = "Order #\(orderId) cancelled successfully!"
//                fetchOrders()
//            }
//
//
//}.resume()
//    }
    // MARK: - Cancel Order
    private func cancelOrder(orderId: Int) {
        guard let url = URL(string: "http://10.211.55.7/BooknowAPI/api/order/status/\(orderId)") else {
            errorMessage = "Invalid cancel URL"
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "PUT"   // ✅ assuming PUT updates status
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        // ✅ Send raw JSON string e.g. "Cancelled"
        let status = "Cancelled"
        request.httpBody = "\"\(status)\"".data(using: .utf8)

        isCancelling = true
        successMessage = nil
        errorMessage = nil

        URLSession.shared.dataTask(with: request) { data, response, error in
            DispatchQueue.main.async {
                isCancelling = false

                if let error = error {
                    errorMessage = "Cancel failed: \(error.localizedDescription)"
                    return
                }

                guard let httpResponse = response as? HTTPURLResponse,
                      (200...299).contains(httpResponse.statusCode) else {
                    let serverMsg = String(data: data ?? Data(), encoding: .utf8) ?? "Unknown server error"
                    errorMessage = "Cancel failed: \(serverMsg)"
                    return
                }

                // ✅ Update UI
                successMessage = "Order #\(orderId) cancelled successfully!"
                fetchOrders()
            }
        }.resume()
    }
}

// MARK: - User Order Detail View
struct UserOrderDetailView: View {
    let order: Order
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    // Order Info Card
                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            Text("Order #\(order.orderId)")
                                .font(.title2)
                                .fontWeight(.bold)
                            Spacer()
                            StatusBadge(status: order.status)
                        }
                        
                        Divider()
                        
                        UserOrderDetailRow(
                            icon: "calendar",
                            title: "Order Date",
                            value: formatDate(order.orderDate)
                        )
                        
                        UserOrderDetailRow(
                            icon: "tag.fill",
                            title: "Total Price",
                            value: String(format: "Rs %.2f", order.totalPrice)
                        )
                        
                        UserOrderDetailRow(
                            icon: "number",
                            title: "Booking ID",
                            value: "\(order.bookingId)"
                        )
                    }
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(12)
                    
                    // Dishes Section
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Order Items (\(order.dishes.count))")
                            .font(.headline)
                            .padding(.horizontal)
                        
                        ForEach(order.dishes) { dish in
                            HStack {
                                VStack(alignment: .leading, spacing: 4) {
                                    Text(dish.dishName)
                                        .font(.body)
                                        .fontWeight(.medium)
                                    Text("Quantity: \(dish.quantity)")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }
                                Spacer()
                                Text("×\(dish.quantity)")
                                    .font(.body)
                                    .fontWeight(.semibold)
                                    .foregroundColor(.primary)
                            }
                            .padding()
                            .background(Color(.systemBackground))
                            .cornerRadius(8)
                            .shadow(color: Color.black.opacity(0.05), radius: 2, x: 0, y: 1)
                        }
                        .padding(.horizontal)
                    }
                }
                .padding()
            }
            .navigationTitle("Order Details")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }
    
    private func formatDate(_ dateString: String) -> String {
        let formatters = [
            "yyyy-MM-dd'T'HH:mm:ss",
            "yyyy-MM-dd'T'HH:mm:ss.SSS",
            "yyyy-MM-dd HH:mm:ss",
            "yyyy-MM-dd"
        ]
        
        for format in formatters {
            let formatter = DateFormatter()
            formatter.dateFormat = format
            formatter.locale = Locale(identifier: "en_US_POSIX")
            if let date = formatter.date(from: dateString) {
                let displayFormatter = DateFormatter()
                displayFormatter.dateFormat = "MMM d, yyyy 'at' h:mm a"
                return displayFormatter.string(from: date)
            }
        }
        
        return dateString
    }
}

struct StatusBadge: View {
    let status: String
    
    var body: some View {
        Text(status)
            .font(.caption)
            .fontWeight(.semibold)
            .padding(.horizontal, 10)
            .padding(.vertical, 4)
            .background(statusColor.opacity(0.2))
            .foregroundColor(statusColor)
            .cornerRadius(8)
    }
    
    private var statusColor: Color {
        switch status.lowercased() {
        case "placed", "pending":
            return .orange
        case "completed", "served":
            return .green
        case "cancelled":
            return .red
        case "inprogress", "preparing":
            return .blue
        default:
            return .gray
        }
    }
}

struct UserOrderDetailRow: View {
    let icon: String
    let title: String
    let value: String
    
    var body: some View {
        HStack {
            Image(systemName: icon)
                .foregroundColor(.blue)
                .frame(width: 20)
            Text(title)
                .foregroundColor(.secondary)
            Spacer()
            Text(value)
                .fontWeight(.medium)
        }
    }
}


