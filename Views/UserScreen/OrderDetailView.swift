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

struct OrderDetailView: View {
    @EnvironmentObject var userVM: UserViewModel
    @State private var orders: [Order] = []
    @State private var isLoading = true
    @State private var errorMessage: String?
    @State private var isCancelling = false
    @State private var successMessage: String?

    var body: some View {
        VStack {
            if isLoading {
                ProgressView("Loading Orders...")
            } else if let errorMessage = errorMessage {
                Text(errorMessage).foregroundColor(.red)
            } else if orders.isEmpty {
                Text("No orders found").foregroundColor(.gray)
            } else {
                List {
                    ForEach(orders) { order in
                        VStack(alignment: .leading, spacing: 6) {
                            Text("Order #\(order.orderId)")
                                .font(.headline)
                            Text("Status: \(order.status)")
                                .foregroundColor(order.status == "Placed" ? .green : .red)
                            Text("Total: Rs \(order.totalPrice, specifier: "%.2f")")
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
                }
            }

            // ✅ Show success message
            if let successMessage = successMessage {
                Text(successMessage)
                    .foregroundColor(.green)
                    .padding()
            }
        }
        .navigationTitle("My Orders")
        .onAppear {
            fetchOrders()
        }
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

