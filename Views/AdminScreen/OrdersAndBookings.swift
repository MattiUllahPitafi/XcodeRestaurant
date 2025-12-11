// OrdersAndBookings.swift
import SwiftUI

// Renamed models to avoid conflicts with existing ones
struct RestaurantBooking: Codable, Identifiable {
    let id = UUID()
    let bookingId: Int
    let bookingDateTime: String
    let bookingStatus: String
    let specialRequest: String?
    let maxEstimatedMinutes: Int
    let tableId: Int
    let tableName: String
    let tableLocation: String
    let customer: RestaurantCustomer
    let orders: [RestaurantOrder]
    let hasOrders: Bool
    let totalOrders: Int
    let totalOrderAmount: Double
    
    var formattedDateTime: String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
        
        if let date = dateFormatter.date(from: bookingDateTime) {
            dateFormatter.dateFormat = "MMM d, yyyy 'at' h:mm a"
            return dateFormatter.string(from: date)
        } else {
            return bookingDateTime
        }
    }
    
    var statusColor: Color {
        switch bookingStatus.lowercased() {
        case "booked", "confirmed":
            return .green
        case "pending":
            return .orange
        case "cancelled":
            return .red
        case "completed":
            return .blue
        default:
            return .gray
        }
    }
}

struct RestaurantCustomer: Codable {
    let userId: Int?
    let userName: String
    let userEmail: String
    let userPhone: String?
}

struct RestaurantOrder: Codable, Identifiable {
    let id = UUID()
    let orderId: Int
    let orderDate: String
    let totalPrice: Double
    let orderStatus: String
    let itemCount: Int
    let items: [RestaurantOrderItem]
    
    var formattedDate: String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
        
        if let date = dateFormatter.date(from: orderDate) {
            dateFormatter.dateFormat = "MMM d, h:mm a"
            return dateFormatter.string(from: date)
        } else {
            return orderDate
        }
    }
    
    var statusColor: Color {
        switch orderStatus.lowercased() {
        case "placed", "pending":
            return .orange
        case "inprogress", "preparing":
            return .blue
        case "served":
            return .purple
        case "completed":
            return .green
        case "cancelled":
            return .red
        default:
            return .gray
        }
    }
    
    var formattedPrice: String {
        return String(format: "Rs %.2f", totalPrice)
    }
}

struct RestaurantOrderItem: Codable, Identifiable {
    let id = UUID()
    let orderItemId: Int
    let dishName: String
    let quantity: Int
    let price: Double?
    let specialInstructions: String?
    
    var formattedPrice: String {
        if let price = price {
            return String(format: "Rs %.2f", price)
        }
        return "Rs -"
    }
}

struct RestaurantBookingsResponse: Codable {
    let restaurantId: Int
    let totalBookings: Int
    let bookings: [RestaurantBooking]
    let summary: RestaurantSummary
}

struct RestaurantSummary: Codable {
    let totalBookings: Int
    let totalOrders: Int
    let totalRevenue: Double
    let bookingsWithOrders: Int
    let bookingsWithoutOrders: Int
    
    var formattedRevenue: String {
        return String(format: "Rs %.2f", totalRevenue)
    }
}
//
struct OrdersAndBookings: View {
    let adminUserId: Int
    @State private var bookings: [RestaurantBooking] = []
    @State private var summary: RestaurantSummary?
    @State private var isLoading = false
    @State private var errorMessage: String?
    @State private var selectedFilter: BookingFilter = .all
    @State private var searchText = ""
    @State private var selectedBooking: RestaurantBooking?
    @State private var showOrderDetail = false
    @State private var selectedOrder: RestaurantOrder?
    
    enum BookingFilter: String, CaseIterable {
        case all = "All"
        case withOrders = "With Orders"
        case withoutOrders = "Without Orders"
        case active = "Active"
        case completed = "Completed"
    }
    
    var filteredBookings: [RestaurantBooking] {
        var filtered = bookings
        
        // Apply search filter
        if !searchText.isEmpty {
            filtered = filtered.filter { booking in
                booking.customer.userName.localizedCaseInsensitiveContains(searchText) ||
                booking.tableName.localizedCaseInsensitiveContains(searchText) ||
                booking.bookingStatus.localizedCaseInsensitiveContains(searchText)
            }
        }
        
        // Apply status filter
        switch selectedFilter {
        case .all:
            return filtered
        case .withOrders:
            return filtered.filter { $0.hasOrders }
        case .withoutOrders:
            return filtered.filter { !$0.hasOrders }
        case .active:
            return filtered.filter { $0.bookingStatus.lowercased() == "booked" }
        case .completed:
            return filtered.filter { $0.bookingStatus.lowercased() == "completed" }
        }
    }
    
    var body: some View {
        ZStack {
            Color(.systemGroupedBackground).edgesIgnoringSafeArea(.all)
            
            if isLoading {
                ProgressView("Loading bookings...")
                    .scaleEffect(1.5)
            } else if let error = errorMessage {
                VStack(spacing: 20) {
                    Image(systemName: "exclamationmark.triangle")
                        .font(.system(size: 50))
                        .foregroundColor(.orange)
                    Text("Error")
                        .font(.title2)
                        .fontWeight(.bold)
                    Text(error)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                    Button("Retry") {
                        fetchBookings()
                    }
                    .buttonStyle(.borderedProminent)
                }
            } else if bookings.isEmpty {
                VStack(spacing: 20) {
                    Image(systemName: "calendar.badge.exclamationmark")
                        .font(.system(size: 50))
                        .foregroundColor(.gray)
                    Text("No Bookings Found")
                        .font(.title2)
                        .fontWeight(.bold)
                    Text("There are no bookings for your restaurant yet.")
                        .foregroundColor(.secondary)
                }
            } else {
                ScrollView {
                    VStack(spacing: 16) {
                        // Summary Cards
                        summarySection
                        
                        // Filters
                        filterSection
                        
                        // Search Bar
                        searchSection
                        
                        // Bookings List
                        bookingsList
                    }
                    .padding()
                }
            }
        }
        .navigationTitle("Bookings & Orders")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            fetchBookings()
        }
        .sheet(item: $selectedBooking) { booking in
            RestaurantBookingDetailView(booking: booking)
        }
        .sheet(item: $selectedOrder) { order in
            RestaurantOrderDetailView(order: order)
        }
    }
    
    // MARK: - Summary Section
    private var summarySection: some View {
        VStack(spacing: 12) {
            HStack {
                Text("Restaurant Summary")
                    .font(.headline)
                    .foregroundColor(.primary)
                Spacer()
                Text("Total: \(bookings.count)")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            
            if let summary = summary {
                HStack(spacing: 12) {
                    SummaryCard(
                        title: "Orders",
                        value: "\(summary.totalOrders)",
                        icon: "bag",
                        color: .blue
                    )
                    
                    SummaryCard(
                        title: "Revenue",
                        value: summary.formattedRevenue,
                        icon: "dollarsign.circle",
                        color: .green
                    )
                    
                    SummaryCard(
                        title: "Active",
                        value: "\(summary.bookingsWithOrders)",
                        icon: "checkmark.circle",
                        color: .orange
                    )
                }
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.05), radius: 5, x: 0, y: 2)
    }
    
    // MARK: - Filter Section
    private var filterSection: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                ForEach(BookingFilter.allCases, id: \.self) { filter in
                    FilterChip(
                        title: filter.rawValue,
                        isSelected: selectedFilter == filter,
                        count: countForFilter(filter)
                    ) {
                        selectedFilter = filter
                    }
                }
            }
            .padding(.vertical, 4)
        }
    }
    
    // MARK: - Search Section
    private var searchSection: some View {
        HStack {
            Image(systemName: "magnifyingglass")
                .foregroundColor(.secondary)
            TextField("Search by customer, table, or status", text: $searchText)
                .textFieldStyle(PlainTextFieldStyle())
            if !searchText.isEmpty {
                Button(action: { searchText = "" }) {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(.secondary)
                }
            }
        }
        .padding(10)
        .background(Color(.systemBackground))
        .cornerRadius(10)
        .shadow(color: .black.opacity(0.05), radius: 2, x: 0, y: 1)
    }
    
    // MARK: - Bookings List
    private var bookingsList: some View {
        LazyVStack(spacing: 12) {
            ForEach(filteredBookings) { booking in
                RestaurantBookingCard(booking: booking) {
                    selectedBooking = booking
                } onOrderTap: { order in
                    selectedOrder = order
                }
            }
        }
    }
    
    // MARK: - Helper Methods
    private func countForFilter(_ filter: BookingFilter) -> Int {
        switch filter {
        case .all:
            return bookings.count
        case .withOrders:
            return bookings.filter { $0.hasOrders }.count
        case .withoutOrders:
            return bookings.filter { !$0.hasOrders }.count
        case .active:
            return bookings.filter { $0.bookingStatus.lowercased() == "booked" }.count
        case .completed:
            return bookings.filter { $0.bookingStatus.lowercased() == "completed" }.count
        }
    }
    
    private func fetchBookings() {
        isLoading = true
        errorMessage = nil
        
        guard let url = URL(string: "http://10.211.55.7/BooknowAPI/api/admin/GetBookingsAndOrderByRestaurant/\(adminUserId)") else {
            errorMessage = "Invalid URL"
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
                    let response = try JSONDecoder().decode(RestaurantBookingsResponse.self, from: data)
                    self.bookings = response.bookings
                    self.summary = response.summary
                } catch {
                    print("Decoding error: \(error)")
                    errorMessage = "Failed to parse data"
                    
                    // Try to print the raw response for debugging
                    if let jsonString = String(data: data, encoding: .utf8) {
                        print("Raw response: \(jsonString)")
                    }
                }
            }
        }.resume()
    }
}

// MARK: - Supporting Views (Renamed to avoid conflicts)

struct SummaryCard: View {
    let title: String
    let value: String
    let icon: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(color)
            Text(value)
                .font(.headline)
                .fontWeight(.bold)
                .foregroundColor(.primary)
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 12)
        .background(color.opacity(0.1))
        .cornerRadius(10)
    }
}

struct FilterChip: View {
    let title: String
    let isSelected: Bool
    let count: Int
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 4) {
                Text(title)
                    .font(.caption)
                    .fontWeight(isSelected ? .semibold : .regular)
                if count > 0 {
                    Text("(\(count))")
                        .font(.caption2)
                        .fontWeight(.medium)
                }
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .background(isSelected ? Color.blue : Color(.systemGray5))
            .foregroundColor(isSelected ? .white : .primary)
            .cornerRadius(20)
        }
    }
}

struct RestaurantBookingCard: View {
    let booking: RestaurantBooking
    let onTap: () -> Void
    let onOrderTap: (RestaurantOrder) -> Void
    
    var body: some View {
        Button(action: onTap) {
            VStack(alignment: .leading, spacing: 12) {
                // Header
                HStack {
                    VStack(alignment: .leading) {
                        Text(booking.formattedDateTime)
                            .font(.subheadline)
                            .fontWeight(.semibold)
                            .foregroundColor(.primary)
                        Text("Table: \(booking.tableName) (\(booking.tableLocation))")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    
                    Spacer()
                    
                    VStack(alignment: .trailing) {
                        Text(booking.bookingStatus)
                            .font(.caption)
                            .fontWeight(.medium)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(booking.statusColor.opacity(0.2))
                            .foregroundColor(booking.statusColor)
                            .cornerRadius(6)
                        
                        if booking.hasOrders {
                            Text(String(format: "Rs %.2f", booking.totalOrderAmount))
                                .font(.caption)
                                .fontWeight(.semibold)
                                .foregroundColor(.green)
                        }
                    }
                }
                
                // Customer Info
                HStack {
                    Image(systemName: "person.circle")
                        .foregroundColor(.secondary)
                    Text(booking.customer.userName)
                        .font(.caption)
                        .fontWeight(.medium)
                    Spacer()
                    Text(booking.customer.userEmail)
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }
                
                Divider()
                
                // Orders Summary
                if booking.hasOrders {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Orders (\(booking.totalOrders))")
                            .font(.caption)
                            .fontWeight(.semibold)
                            .foregroundColor(.secondary)
                        
                        ForEach(booking.orders.prefix(2)) { order in
                            Button(action: { onOrderTap(order) }) {
                                RestaurantOrderRow(order: order)
                            }
                        }
                        
                        if booking.orders.count > 2 {
                            Text("+ \(booking.orders.count - 2) more orders")
                                .font(.caption2)
                                .foregroundColor(.blue)
                                .padding(.top, 2)
                        }
                    }
                } else {
                    HStack {
                        Image(systemName: "exclamationmark.circle")
                            .foregroundColor(.orange)
                        Text("No orders placed")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        Spacer()
                    }
                }
                
                // Special Request
                if let request = booking.specialRequest, !request.isEmpty {
                    Divider()
                    HStack(alignment: .top) {
                        Image(systemName: "text.bubble")
                            .foregroundColor(.secondary)
                        Text(request)
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .lineLimit(2)
                    }
                }
            }
            .padding()
            .background(Color(.systemBackground))
            .cornerRadius(12)
            .shadow(color: .black.opacity(0.05), radius: 5, x: 0, y: 2)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct RestaurantOrderRow: View {
    let order: RestaurantOrder
    
    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                Text(order.formattedDate)
                    .font(.caption2)
                    .foregroundColor(.secondary)
                Text("\(order.itemCount) items")
                    .font(.caption)
                    .fontWeight(.medium)
            }
            
            Spacer()
            
            VStack(alignment: .trailing) {
                Text(order.formattedPrice)
                    .font(.caption)
                    .fontWeight(.semibold)
                Text(order.orderStatus)
                    .font(.caption2)
                    .padding(.horizontal, 6)
                    .padding(.vertical, 2)
                    .background(order.statusColor.opacity(0.2))
                    .foregroundColor(order.statusColor)
                    .cornerRadius(4)
            }
        }
        .padding(8)
        .background(Color(.systemGray6))
        .cornerRadius(8)
    }
}

struct RestaurantBookingDetailView: View {
    let booking: RestaurantBooking
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    // Booking Info Card
                    bookingInfoCard
                    
                    // Customer Info Card
                    customerInfoCard
                    
                    // Orders Section
                    if booking.hasOrders {
                        ordersSection
                    }
                    
                    // Special Request
                    if let request = booking.specialRequest, !request.isEmpty {
                        specialRequestCard(request: request)
                    }
                }
                .padding()
            }
            .navigationTitle("Booking Details")
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
    
    private var bookingInfoCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            Label("Booking Information", systemImage: "calendar")
                .font(.headline)
                .foregroundColor(.primary)
            
            DetailRow(
                icon: "clock",
                title: "Date & Time",
                value: booking.formattedDateTime
            )
            
            DetailRow(
                icon: "table.furniture",
                title: "Table",
                value: "\(booking.tableName) - \(booking.tableLocation)"
            )
            
            DetailRow(
                icon: "timer",
                title: "Duration",
                value: "\(booking.maxEstimatedMinutes) minutes"
            )
            
            DetailRow(
                icon: "circle.fill",
                title: "Status",
                value: booking.bookingStatus,
                valueColor: booking.statusColor
            )
            
            if booking.hasOrders {
                DetailRow(
                    icon: "bag",
                    title: "Total Orders",
                    value: "\(booking.totalOrders)"
                )
                
                DetailRow(
                    icon: "dollarsign.circle",
                    title: "Total Amount",
                    value: String(format: "Rs %.2f", booking.totalOrderAmount),
                    valueColor: .green
                )
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.05), radius: 5)
    }
    
    private var customerInfoCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            Label("Customer Information", systemImage: "person.circle")
                .font(.headline)
                .foregroundColor(.primary)
            
            DetailRow(
                icon: "person",
                title: "Name",
                value: booking.customer.userName
            )
            
            DetailRow(
                icon: "envelope",
                title: "Email",
                value: booking.customer.userEmail
            )
            
            if let phone = booking.customer.userPhone, !phone.isEmpty {
                DetailRow(
                    icon: "phone",
                    title: "Phone",
                    value: phone
                )
            }
            
            if let userId = booking.customer.userId {
                DetailRow(
                    icon: "number",
                    title: "Customer ID",
                    value: "\(userId)"
                )
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.05), radius: 5)
    }
    
    private var ordersSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Label("Orders (\(booking.totalOrders))", systemImage: "bag")
                .font(.headline)
                .foregroundColor(.primary)
            
            ForEach(booking.orders) { order in
                RestaurantOrderDetailCard(order: order)
                    .padding(.bottom, 8)
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.05), radius: 5)
    }
    
    private func specialRequestCard(request: String) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Label("Special Request", systemImage: "text.bubble")
                .font(.headline)
                .foregroundColor(.primary)
            
            Text(request)
                .font(.body)
                .foregroundColor(.secondary)
                .padding()
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(Color(.systemGray6))
                .cornerRadius(8)
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.05), radius: 5)
    }
}

struct RestaurantOrderDetailCard: View {
    let order: RestaurantOrder
    
    var body: some View {
        VStack(spacing: 12) {
            // Order Header
            HStack {
                VStack(alignment: .leading) {
                    Text("Order #\(order.orderId)")
                        .font(.headline)
                    Text(order.formattedDate)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                Spacer()
                VStack(alignment: .trailing) {
                    Text(order.formattedPrice)
                        .font(.headline)
                        .fontWeight(.bold)
                        .foregroundColor(.green)
                    Text(order.orderStatus)
                        .font(.caption)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(order.statusColor.opacity(0.2))
                        .foregroundColor(order.statusColor)
                        .cornerRadius(6)
                }
            }
            
            Divider()
            
            // Order Items
            VStack(alignment: .leading, spacing: 8) {
                Text("Items (\(order.itemCount))")
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundColor(.secondary)
                
                ForEach(order.items) { item in
                    HStack {
                        Text("• \(item.dishName)")
                            .font(.body)
                        Spacer()
                        Text("×\(item.quantity)")
                            .font(.body)
                            .fontWeight(.medium)
                        if let price = item.price {
                            Text(String(format: "Rs %.2f", price))
                                .font(.body)
                                .foregroundColor(.secondary)
                        }
                    }
                    
                    if let instructions = item.specialInstructions, !instructions.isEmpty {
                        Text("Note: \(instructions)")
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .padding(.leading, 8)
                    }
                }
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
}

struct RestaurantOrderDetailView: View {
    let order: RestaurantOrder
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            ScrollView {
                RestaurantOrderDetailCard(order: order)
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
}

struct DetailRow: View {
    let icon: String
    let title: String
    let value: String
    var valueColor: Color = .primary
    
    var body: some View {
        HStack {
            Image(systemName: icon)
                .foregroundColor(.secondary)
                .frame(width: 24)
            Text(title)
                .font(.subheadline)
                .foregroundColor(.secondary)
            Spacer()
            Text(value)
                .font(.body)
                .fontWeight(.medium)
                .foregroundColor(valueColor)
        }
    }
}

// Preview
struct OrdersAndBookings_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            OrdersAndBookings(adminUserId: 1)
        }
    }
}
