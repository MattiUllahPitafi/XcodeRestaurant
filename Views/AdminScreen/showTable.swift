
//
//  showTable.swift
//  RestAdvApp
//
//  Created by Matti Ullah on 09/10/2025.
//

import SwiftUI

// MARK: - Table Model
struct TableModel: Identifiable, Codable {
    var id: Int { tableId }
    let tableId: Int
    let name: String
    let floor: Int        // 🔹 Changed to Int (backend returns number)
    let status: String
    let price: Double
    let location: String?
    let capacity: Int
}

// MARK: - ViewModel
@MainActor
class TableViewModel: ObservableObject {
    @Published var tables: [TableModel] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var successMessage: String?

    // ✅ Fetch tables linked to admin’s restaurant (backend handles restaurant lookup)
    func fetchTables(adminUserId: Int) {
        guard let url = URL(string: "http://10.211.55.7/BooknowAPI/api/admin/GetTablesByAdmin/\(adminUserId)") else {
            errorMessage = "Invalid URL"
            return
        }

        isLoading = true
        errorMessage = nil

        Task {
            do {
                let (data, response) = try await URLSession.shared.data(from: url)
                guard let httpRes = response as? HTTPURLResponse, httpRes.statusCode == 200 else {
                    errorMessage = "Failed to load tables."
                    isLoading = false
                    return
                }

                let tables = try JSONDecoder().decode([TableModel].self, from: data)
                await MainActor.run {
                    self.tables = tables
                }
            } catch {
                await MainActor.run {
                    self.errorMessage = "⚠️ \(error.localizedDescription)"
                }
            }
            await MainActor.run { self.isLoading = false }
        }
    }

    // ✅ Add a new table (restaurant is derived from adminUserId)
    func addTable(adminUserId: Int, name: String, floor: String, price: Double, location: String, capacity: Int) async -> Bool {
        guard let url = URL(string: "http://10.211.55.7/BooknowAPI/api/admin/AddTable/\(adminUserId)") else {
            errorMessage = "Invalid URL"
            return false
        }

        let payload: [String: Any] = [
            "Name": name,
            "Floor": floor,
            "Price": price,
            "Location": location,
            "Capacity": capacity,
            "Status": "Available"
        ]

        guard let jsonData = try? JSONSerialization.data(withJSONObject: payload) else {
            errorMessage = "Invalid data"
            return false
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = jsonData

        do {
            let (data, response) = try await URLSession.shared.data(for: request)
            guard let httpRes = response as? HTTPURLResponse else { return false }

            if httpRes.statusCode == 200 {
                await MainActor.run {
                    self.successMessage = "✅ Table added successfully!"
                }
                return true
            } else {
                let err = String(data: data, encoding: .utf8) ?? "Unknown error"
                await MainActor.run {
                    self.errorMessage = "⚠️ \(err)"
                }
                return false
            }
        } catch {
            await MainActor.run {
                self.errorMessage = "⚠️ \(error.localizedDescription)"
            }
            return false
        }
    }
}

// MARK: - Main View
struct showTable: View {
    @StateObject private var viewModel = TableViewModel()
    @State private var showingAddTable = false
    let adminUserId: Int

    var body: some View {
        NavigationView {
            VStack {
                if viewModel.isLoading {
                    ProgressView("Loading Tables...")
                } else if let error = viewModel.errorMessage {
                    Text(error).foregroundColor(.red)
                } else {
                    if viewModel.tables.isEmpty {
                        Text("No tables found yet.")
                            .foregroundColor(.gray)
                            .padding()
                    } else {
                        List(viewModel.tables) { table in
                            VStack(alignment: .leading, spacing: 6) {
                                Text("🪑 \(table.name)")
                                    .font(.headline)
                                Text("Floor: \(table.floor)")
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                                Text("💰 Price: $\(table.price, specifier: "%.2f") | 👥 Capacity: \(table.capacity)")
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                                Text("Status: \(table.status)")
                                    .font(.footnote)
                                    .foregroundColor(table.status == "Available" ? .green : .red)
                            }
                            .padding(.vertical, 4)
                        }
                    }
                }
            }
            .navigationTitle("Manage Tables")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { showingAddTable = true }) {
                        Label("Add Table", systemImage: "plus.circle.fill")
                    }
                }
            }
            .onAppear {
                viewModel.fetchTables(adminUserId: adminUserId)
            }
            .sheet(isPresented: $showingAddTable) {
                AddTableView(adminUserId: adminUserId, viewModel: viewModel)
            }
        }
    }
}

// MARK: - Add Table View
struct AddTableView: View {
    let adminUserId: Int
    @ObservedObject var viewModel: TableViewModel

    @State private var name = ""
    @State private var floor = ""
    @State private var price = ""
    @State private var location = ""
    @State private var capacity = ""
    @State private var isSubmitting = false
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Table Details")) {
                    TextField("Table Name", text: $name)
                    TextField("Floor (e.g. 1)", text: $floor)
                        .keyboardType(.numberPad)
                    TextField("Location", text: $location)
                    TextField("Capacity", text: $capacity)
                        .keyboardType(.numberPad)
                    TextField("Price", text: $price)
                        .keyboardType(.decimalPad)
                }

                if let message = viewModel.successMessage ?? viewModel.errorMessage {
                    Text(message)
                        .foregroundColor(message.contains("✅") ? .green : .red)
                        .multilineTextAlignment(.center)
                }

                Button(action: submitTable) {
                    HStack {
                        if isSubmitting { ProgressView() }
                        Text("Add Table").bold()
                    }
                    .frame(maxWidth: .infinity)
                }
                .disabled(isSubmitting)
            }
            .navigationTitle("Add Table")
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") { dismiss() }
                }
            }
        }
    }

    private func submitTable() {
        guard !name.isEmpty,
              !floor.isEmpty,
              !price.isEmpty,
              !location.isEmpty,
              let priceValue = Double(price),
              let capacityValue = Int(capacity)
        else {
            viewModel.errorMessage = "⚠️ Please fill all fields correctly."
            return
        }

        isSubmitting = true
        Task {
            let success = await viewModel.addTable(
                adminUserId: adminUserId,
                name: name,
                floor: floor,
                price: priceValue,
                location: location,
                capacity: capacityValue
            )

            if success {
                viewModel.fetchTables(adminUserId: adminUserId)
                dismiss()
            }
            isSubmitting = false
        }
    }
}
