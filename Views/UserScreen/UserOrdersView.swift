//import SwiftUI
//struct UserOrdersView: View {
//    let orders: [Order]
//
//    var body: some View {
//        List(orders) { order in
//            NavigationLink(destination: UserOrdersView(order: order)) {
//                VStack(alignment: .leading, spacing: 5) {
//                    Text("Order Date: \(formatDate(order.orderDate))")
//                        .font(.subheadline)
//                    Text("Total: \(order.totalPrice, specifier: "%.2f")")
//                        .font(.headline)
//                    Text("Status: \(order.status)")
//                        .font(.caption)
//                        .foregroundColor(order.status == "Placed" ? .green : .gray)
//                }
//                .padding(.vertical, 5)
//            }
//        }
//        .navigationTitle("My Orders")
//    }
//
//    // Reuse date formatting helper
//    func formatDate(_ dateString: String) -> String {
//        let formatter = ISO8601DateFormatter()
//        if let date = formatter.date(from: dateString) {
//            let displayFormatter = DateFormatter()
//            displayFormatter.dateStyle = .medium
//            displayFormatter.timeStyle = .short
//            return displayFormatter.string(from: date)
//        }
//        return dateString
//    }
//}
