//import SwiftUI
//
//struct WaiterHome: View {
//    @EnvironmentObject var userVM: UserViewModel
//    @StateObject private var viewModel = WaiterViewModel()
//    @Binding var rootPath: NavigationPath
//
//    var body: some View {
//        VStack {
//            Text("🧾 Tables Assigned")
//                .font(.title2)
//                .fontWeight(.bold)
//                .padding(.top)
//
//            if viewModel.isLoading {
//                ProgressView("Loading...")
//                    .padding()
//            } else if let error = viewModel.errorMessage {
//                Text("⚠️ \(error)")
//                    .foregroundColor(.red)
//                    .padding()
//            } else if viewModel.assignments.isEmpty {
//                Text("No tables assigned.")
//                    .foregroundColor(.gray)
//                    .padding()
//            } else {
//                List {
//                    ForEach(viewModel.assignments) { assignment in
//                        HStack {
//                            VStack(alignment: .leading, spacing: 4) {
//                                // Display table name and floor
//                                Text(assignment.booking.table.name)
//                                    .font(.headline)
//
//                                Text("Floor: \(assignment.booking.table.floor)")
//                                    .font(.subheadline)
//                                    .foregroundColor(.secondary)
//
//                                // Display order status
//                                Text("Order Status: \(assignment.orderStatus)")
//                                    .font(.subheadline)
//                                    .foregroundColor(.gray)
//                            }
//
//                            Spacer()
//
//                            // Serve Button
////                            Button("Serve") {
////                                // Call serveOrder with orderId and waiterUserId
////                                Task {
////                                    await viewModel.serveOrder(orderId: assignment.orderId, waiterUserId: userVM.user?.userId ?? 0)
////                                }
////                            }
////                            .buttonStyle(.borderedProminent)
////                            .padding(.horizontal)
//                        }
//                        .padding(.vertical, 6)
//                    }
//                }
//                .listStyle(.insetGrouped)
//            }
//        }
//        .task {
//            if let waiterUserId = userVM.user?.userId {
//                await viewModel.fetchAssignments(for: waiterUserId)
//            } else {
//                viewModel.errorMessage = "⚠️ Please log in first."
//            }
//        }
//    }
//}
import SwiftUI

struct WaiterHome: View {
    @EnvironmentObject var userVM: UserViewModel
    @StateObject private var viewModel = WaiterViewModel()
    @Binding var rootPath: NavigationPath

    var body: some View {
        VStack {
            Text("🧾 Tables Assigned")
                .font(.title2)
                .fontWeight(.bold)
                .padding(.top)

            if viewModel.isLoading {
                ProgressView("Loading...")
                    .padding()
            } else if let error = viewModel.errorMessage {
                Text("⚠️ \(error)")
                    .foregroundColor(.red)
                    .padding()
            } else if viewModel.assignments.isEmpty {
                Text("No tables assigned.")
                    .foregroundColor(.gray)
                    .padding()
            } else {
                List {
                    ForEach(viewModel.assignments) { assignment in
                        HStack {
                            VStack(alignment: .leading, spacing: 4) {
                                Text(assignment.booking.table.name)
                                    .font(.headline)

                                Text("Floor: \(assignment.booking.table.floor)")
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)

                                // Display order status
                                Text("Order Status: \(assignment.orderStatus)")
                                    .font(.subheadline)
                                    .foregroundColor(.gray)
                                Text("Order ID: \(assignment.orderId)")
                                    .font(.subheadline)
                                    .foregroundColor(.blue)
                            }

                            Spacer()

                            // Serve Button
                            Button("Serve") {
                                // Ensure correct orderId is passed
                                Task {
                                    // Correctly pass orderId and waiterId
                                    await viewModel.serveOrder(orderId: assignment.orderId, waiterId: userVM.user?.userId ?? 0)
                                }
                            }
                            .buttonStyle(.borderedProminent)
                            .padding(.horizontal)
                        }
                        .padding(.vertical, 6)
                    }
                }
                .listStyle(.insetGrouped)
            }
        }
        .task {
            if let waiterId = userVM.user?.userId {
                await viewModel.fetchAssignments(for: waiterId)
            } else {
                viewModel.errorMessage = "⚠️ Please log in first."
            }
        }
    }
}
