//struct WaiterAssignment: Codable, Identifiable {
//    let waiterUserId: Int
//    let bookingId: Int
//    let booking: BookingData
//    var id: Int { bookingId }
//}
//
//struct BookingData: Codable {
//    let tableId: Int
//    let table: TableData
//}
//
//struct TableData: Codable {
//    let name: String
//    let floor: String
//}
//@MainActor
//class WaiterViewModel: ObservableObject {
//    @Published var assignments: [WaiterAssignment] = []
//    @Published var isLoading = false
//    @Published var errorMessage: String?
//
//    func fetchAssignments(for waiterId: Int) async {
//        guard let url = URL(string: "http://10.211.55.7/BooknowAPI/api/waiters/byid/\(waiterId)") else {
//            errorMessage = "Invalid URL"
//            return
//        }
//
//        isLoading = true
//        errorMessage = nil
//
//        do {
//            let (data, _) = try await URLSession.shared.data(from: url)
//            let decoded = try JSONDecoder().decode([WaiterAssignment].self, from: data)
//            assignments = decoded
//        } catch {
//            errorMessage = "Failed to fetch tables: \(error.localizedDescription)"
//        }
//
//        isLoading = false
//    }
//}
//import SwiftUI
//
//struct waiterHome: View {
//    @EnvironmentObject var userVM: UserViewModel
//    @Binding var rootPath: NavigationPath
//    @StateObject private var viewModel = WaiterViewModel()
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
//                                Text(assignment.booking.table.name)
//                                    .font(.headline)
//                                Text(assignment.booking.table.floor)
//                                    .font(.headline)
//                                Text("Table ID: \(assignment.booking.tableId)")
//                                    .font(.subheadline)
//                                    .foregroundColor(.secondary)
//                            }
//                            Spacer()
//                        }
//                        .padding(.vertical, 6)
//                    }
//                }
//                .listStyle(.insetGrouped)
//            }
//        }
//        .task {
//            if let waiterId = userVM.loggedInUserId {
//                await viewModel.fetchAssignments(for: waiterId)
//            } else {
//                viewModel.errorMessage = "⚠️ Please log in first."
//            }
//        }
//    }
//}
import SwiftUI

struct WaiterDashboard: View {
    @EnvironmentObject var userVM: UserViewModel
    @Binding var rootPath: NavigationPath
    @StateObject private var viewModel = WaiterViewModel()

    var body: some View {
        VStack(spacing: 24) {

            // MARK: - Top Info
            VStack(spacing: 4) {
                Text(userVM.user?.name ?? "waiter")
                    .font(.title3)
                    .fontWeight(.semibold)

                Text("waiter")
                    .font(.subheadline)
                    .foregroundColor(.green)
            }
            .padding(.top, 40)

            // MARK: - My Orders Button
            Button(action: {
                rootPath.append(AppRoute.WaiterHome)
            }) {
                HStack {
                    Image(systemName: "list.bullet.rectangle")
                        .font(.title3)

                    Text("My Orders")
                        .font(.headline)

                    Spacer()

                    Image(systemName: "chevron.right")
                }
                .padding()
                .foregroundColor(.black)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color.orange, lineWidth: 1.2)
                )
            }
            .padding(.horizontal, 24)

            Spacer()
        }
    }
}

