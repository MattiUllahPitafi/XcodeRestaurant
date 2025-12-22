////
////  ShowWaiter.swift
////  RestAdvApp
////
////  Created by Matti Ullah on 30/11/2025.
////
//
//import SwiftUI
//
//// MARK: - Waiter Model
//struct WaiterModel: Identifiable, Codable {
//    let id: Int
//    let name: String
//    let email: String
//
//    enum CodingKeys: String, CodingKey {
//        case id = "userId"
//        case name
//        case email
//    }
//}
//
//// MARK: - Add Waiter Request Model
//struct NewWaiterRequest: Codable {
//    let name: String
//    let email: String
//    let passwordHash: String
//    let role: String
//}
//
//// MARK: - Main View (Show + Add)
//struct ShowWaiter: View {
//
//    let adminUserId: Int   // ✅ RECEIVED FROM NAVIGATIONLINK
//
//    @EnvironmentObject var userVM: UserViewModel
//
//    @State private var waiters: [WaiterModel] = []
//    @State private var isLoading = true
//    @State private var errorMessage: String?
//
//    @State private var showAddSheet = false
//
//    var body: some View {
//        NavigationView {
//            VStack {
//
//                if isLoading {
//                    ProgressView("Loading Waiters...")
//                }
//
//                if let error = errorMessage {
//                    Text(error)
//                        .foregroundColor(.red)
//                        .padding()
//                }
//
//                List(waiters) { waiter in
//                    HStack {
//                        VStack(alignment: .leading) {
//                            Text(waiter.name)
//                                .font(.headline)
//
//                            Text(waiter.email)
//                                .font(.subheadline)
//                                .foregroundColor(.gray)
//                        }
//
//                        Spacer()
//
//                        Image(systemName: "person.fill")
//                            .foregroundColor(.blue)
//                    }
//                }
//            }
//            .navigationTitle("Waiters")
//            .navigationBarItems(trailing:
//                Button(action: {
//                    showAddSheet = true
//                }) {
//                    Image(systemName: "plus.circle.fill")
//                        .font(.system(size: 26))
//                        .foregroundColor(.blue)
//                }
//            )
//            .sheet(isPresented: $showAddSheet) {
//                AddWaiterView(adminUserId: adminUserId) {
//                    Task { await fetchWaiters() }
//                }
//                .environmentObject(userVM)
//            }
//            .onAppear {
//                Task {
//                    await fetchWaiters()
//                }
//            }
//        }
//    }
//
//    // MARK: - API Fetch Waiters
//    func fetchWaiters() async {
//
//        if adminUserId == 0 {
//            errorMessage = "Invalid admin id"
//            isLoading = false
//            return
//        }
//
//        let urlString = "\(APIConfig.baseURL)/admin/GetWaitersForAdmin/\(adminUserId)"
//
//        guard let url = URL(string: urlString) else {
//            errorMessage = "Invalid URL"
//            isLoading = false
//            return
//        }
//
//        do {
//            let (data, _) = try await URLSession.shared.data(from: url)
//            let decoded = try JSONDecoder().decode([WaiterModel].self, from: data)
//
//            DispatchQueue.main.async {
//                self.waiters = decoded
//                self.isLoading = false
//            }
//
//        } catch {
//            DispatchQueue.main.async {
//                self.errorMessage = "Failed: \(error.localizedDescription)"
//                self.isLoading = false
//            }
//        }
//    }
//}
//
//// MARK: - Add Waiter View
//struct AddWaiterView: View {
//
//    let adminUserId: Int       // ✅ RECEIVED FROM SHOWWAITER
//
//    @Environment(\.dismiss) var dismiss
//    @EnvironmentObject var userVM: UserViewModel
//
//    @State private var name = ""
//    @State private var email = ""
//    @State private var password = ""
//
//    @State private var errorMessage: String?
//    @State private var successMessage: String?
//
//    var onAdd: () -> Void
//
//    var body: some View {
//        NavigationView {
//            Form {
//
//                Section(header: Text("Waiter Info")) {
//                    TextField("Name", text: $name)
//                    TextField("Email", text: $email)
//                    SecureField("Password", text: $password)
//                }
//
//                if let error = errorMessage {
//                    Text(error)
//                        .foregroundColor(.red)
//                }
//
//                if let success = successMessage {
//                    Text(success)
//                        .foregroundColor(.green)
//                }
//
//                Button("Create Waiter") {
//                    Task { await createWaiter() }
//                }
//                .frame(maxWidth: .infinity)
//                .foregroundColor(.white)
//                .padding()
//                .background(Color.blue)
//                .cornerRadius(10)
//            }
//            .navigationTitle("Add Waiter")
//            .navigationBarItems(leading:
//                Button("Close") { dismiss() }
//            )
//        }
//    }
//
//    // MARK: - API Create Waiter
//    func createWaiter() async {
//
//        if adminUserId == 0 {
//            errorMessage = "Admin not logged in"
//            return
//        }
//
//        let urlString = "http://10.211.55.7/BooknowAPI/api/admin/CreateWaiter/\(adminUserId)"
//
//        guard let url = URL(string: urlString) else {
//            errorMessage = "Invalid URL"
//            return
//        }
//
//        let newWaiter = NewWaiterRequest(
//            name: name,
//            email: email,
//            passwordHash: password,
//            role: "Waiter"
//        )
//
//        guard let encoded = try? JSONEncoder().encode(newWaiter) else {
//            errorMessage = "Encoding failed"
//            return
//        }
//
//        var req = URLRequest(url: url)
//        req.httpMethod = "POST"
//        req.addValue("application/json", forHTTPHeaderField: "Content-Type")
//        req.httpBody = encoded
//
//        do {
//            let (data, _) = try await URLSession.shared.data(for: req)
//
//            if let response = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
//               let msg = response["Message"] as? String {
//                successMessage = msg
//
//                onAdd()
//
//                DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
//                    dismiss()
//                }
//            }
//
//        } catch {
//            errorMessage = "Failed: \(error.localizedDescription)"
//        }
//    }
//}
//
//// MARK: - Preview
//struct ShowWaiter_Previews: PreviewProvider {
//    static var previews: some View {
//        ShowWaiter(adminUserId: 1)
//            .environmentObject(UserViewModel())
//    }
//}
//
//  ShowWaiter.swift
//  RestAdvApp
//
//  Created by Matti Ullah on 30/11/2025.
//

import SwiftUI

// MARK: - Waiter Model
struct WaiterModel: Identifiable, Codable {
    let id: Int
    let name: String
    let email: String

    enum CodingKeys: String, CodingKey {
        case id = "userId"
        case name
        case email
    }
}

// MARK: - Add Waiter Request Model
struct NewWaiterRequest: Codable {
    let name: String
    let email: String
    let passwordHash: String
    let role: String
}

// MARK: - Delete Response Model
struct DeleteResponse: Codable {
    let message: String
    let deletedWaiterId: Int
    
    enum CodingKeys: String, CodingKey {
        case message = "Message"
        case deletedWaiterId = "DeletedWaiterId"
    }
}

// MARK: - Main View (Show + Add)
struct ShowWaiter: View {

    let adminUserId: Int   // ✅ RECEIVED FROM NAVIGATIONLINK

    @EnvironmentObject var userVM: UserViewModel

    @State private var waiters: [WaiterModel] = []
    @State private var isLoading = true
    @State private var errorMessage: String?
    @State private var successMessage: String?
    @State private var showAddSheet = false
    @State private var showDeleteAlert = false
    @State private var waiterToDelete: WaiterModel?

    var body: some View {
        NavigationView {
            VStack {
                // Success message
                if let success = successMessage {
                    Text(success)
                        .foregroundColor(.green)
                        .padding()
                        .onAppear {
                            // Auto-hide success message after 3 seconds
                            DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                                successMessage = nil
                            }
                        }
                }

                if isLoading {
                    ProgressView("Loading Waiters...")
                }

                if let error = errorMessage {
                    Text(error)
                        .foregroundColor(.red)
                        .padding()
                }

                if waiters.isEmpty && !isLoading {
                    VStack(spacing: 20) {
                        Image(systemName: "person.2.slash")
                            .font(.system(size: 60))
                            .foregroundColor(.gray)
                        
                        Text("No waiters found")
                            .font(.title2)
                            .foregroundColor(.gray)
                        
                        Text("Tap the + button to add your first waiter")
                            .foregroundColor(.secondary)
                    }
                    .padding()
                    .frame(maxHeight: .infinity)
                } else {
                    List(waiters) { waiter in
                        HStack {
                            Image(systemName: "person.circle.fill")
                                .font(.title2)
                                .foregroundColor(.blue)
                                .frame(width: 40, height: 40)
                            
                            VStack(alignment: .leading, spacing: 4) {
                                Text(waiter.name)
                                    .font(.headline)
                                    .foregroundColor(.primary)
                                
                                Text(waiter.email)
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                            .padding(.leading, 8)

                            Spacer()
                            
                            // Delete icon button on the right
                            Button(action: {
                                waiterToDelete = waiter
                                showDeleteAlert = true
                            }) {
                                Image(systemName: "trash.circle.fill")
                                    .font(.title2)
                                    .foregroundColor(.red)
                            }
                            .buttonStyle(PlainButtonStyle())
                        }
                        .padding(.vertical, 4)
                    }
                }
            }
            .navigationTitle("Waiters")
            .navigationBarItems(trailing:
                HStack {
                    Text("\(waiters.count) waiters")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    Button(action: {
                        showAddSheet = true
                    }) {
                        Image(systemName: "plus.circle.fill")
                            .font(.system(size: 26))
                            .foregroundColor(.blue)
                    }
                }
            )
            .alert("Delete Waiter", isPresented: $showDeleteAlert, presenting: waiterToDelete) { waiter in
                Button("Cancel", role: .cancel) {
                    waiterToDelete = nil
                }
                Button("Delete", role: .destructive) {
                    Task {
                        await deleteWaiter(waiterId: waiter.id)
                    }
                }
            } message: { waiter in
                Text("Are you sure you want to delete \(waiter.name)? This action cannot be undone.")
            }
            .sheet(isPresented: $showAddSheet) {
                AddWaiterView(adminUserId: adminUserId) {
                    Task {
                        await fetchWaiters()
                        successMessage = "Waiter added successfully!"
                    }
                }
                .environmentObject(userVM)
            }
            .onAppear {
                Task {
                    await fetchWaiters()
                }
            }
            .refreshable {
                await fetchWaiters()
            }
        }
    }

    // MARK: - API Fetch Waiters
    func fetchWaiters() async {
        isLoading = true
        errorMessage = nil

        if adminUserId == 0 {
            errorMessage = "Invalid admin id"
            isLoading = false
            return
        }

        let urlString = "\(APIConfig.baseURL)/admin/GetWaitersForAdmin/\(adminUserId)"

        guard let url = URL(string: urlString) else {
            errorMessage = "Invalid URL"
            isLoading = false
            return
        }

        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            let decoded = try JSONDecoder().decode([WaiterModel].self, from: data)

            DispatchQueue.main.async {
                self.waiters = decoded
                self.isLoading = false
            }

        } catch {
            DispatchQueue.main.async {
                self.errorMessage = "Failed: \(error.localizedDescription)"
                self.isLoading = false
            }
        }
    }
    
    // MARK: - API Delete Waiter
    func deleteWaiter(waiterId: Int) async {
        errorMessage = nil
        
        let urlString = "\(APIConfig.baseURL)/admin/DeleteWaiter/\(adminUserId)/\(waiterId)"
        
        guard let url = URL(string: urlString) else {
            errorMessage = "Invalid URL"
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "DELETE"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        do {
            let (data, response) = try await URLSession.shared.data(for: request)
            
            if let httpResponse = response as? HTTPURLResponse {
                if httpResponse.statusCode == 200 {
                    // Success
                    if let deleteResponse = try? JSONDecoder().decode(DeleteResponse.self, from: data) {
                        DispatchQueue.main.async {
                            // Remove waiter from local array
                            self.waiters.removeAll { $0.id == waiterId }
                            self.successMessage = deleteResponse.message
                            self.waiterToDelete = nil
                        }
                    }
                } else {
                    // Server error
                    if let errorData = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
                       let errorMsg = errorData["Message"] as? String {
                        DispatchQueue.main.async {
                            self.errorMessage = errorMsg
                        }
                    } else {
                        DispatchQueue.main.async {
                            self.errorMessage = "Failed to delete waiter (Status: \(httpResponse.statusCode))"
                        }
                    }
                }
            }
            
        } catch {
            DispatchQueue.main.async {
                self.errorMessage = "Failed: \(error.localizedDescription)"
            }
        }
    }
}

// MARK: - Add Waiter View
struct AddWaiterView: View {

    let adminUserId: Int       // ✅ RECEIVED FROM SHOWWAITER

    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var userVM: UserViewModel

    @State private var name = ""
    @State private var email = ""
    @State private var password = ""
    @State private var confirmPassword = ""

    @State private var errorMessage: String?
    @State private var successMessage: String?
    @State private var isLoading = false

    var onAdd: () -> Void

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Waiter Info")) {
                    TextField("Full Name", text: $name)
                    TextField("Email Address", text: $email)
                        .keyboardType(.emailAddress)
                        .autocapitalization(.none)
                    
                    SecureField("Password", text: $password)
                    SecureField("Confirm Password", text: $confirmPassword)
                }
                
                if password != confirmPassword && !confirmPassword.isEmpty {
                    Section {
                        Text("Passwords do not match")
                            .foregroundColor(.red)
                            .font(.caption)
                    }
                }

                if let error = errorMessage {
                    Section {
                        Text(error)
                            .foregroundColor(.red)
                    }
                }

                if let success = successMessage {
                    Section {
                        Text(success)
                            .foregroundColor(.green)
                    }
                }

                Section {
                    Button(action: {
                        Task { await createWaiter() }
                    }) {
                        HStack {
                            Spacer()
                            if isLoading {
                                ProgressView()
                                    .progressViewStyle(CircularProgressViewStyle())
                            } else {
                                Text("Create Waiter")
                                    .fontWeight(.semibold)
                            }
                            Spacer()
                        }
                        .padding(.vertical, 12)
                    }
                    .disabled(name.isEmpty || email.isEmpty || password.isEmpty || password != confirmPassword || isLoading)
                    .background(buttonColor)
                    .foregroundColor(.white)
                    .cornerRadius(10)
                    .listRowInsets(EdgeInsets())
                }
            }
            .navigationTitle("Add Waiter")
            .navigationBarItems(
                leading: Button("Cancel") { dismiss() }
            )
        }
    }
    
    private var buttonColor: Color {
        if name.isEmpty || email.isEmpty || password.isEmpty || password != confirmPassword {
            return .gray
        }
        return .blue
    }

    // MARK: - API Create Waiter
    func createWaiter() async {
        // Validate passwords match
        guard password == confirmPassword else {
            errorMessage = "Passwords do not match"
            return
        }
        
        // Validate email format
        guard email.contains("@"), email.contains(".") else {
            errorMessage = "Please enter a valid email address"
            return
        }
        
        // Validate password length
        guard password.count >= 6 else {
            errorMessage = "Password must be at least 6 characters"
            return
        }

        isLoading = true
        errorMessage = nil

        if adminUserId == 0 {
            errorMessage = "Admin not logged in"
            isLoading = false
            return
        }

        let urlString = "http://10.211.55.7/BooknowAPI/api/admin/CreateWaiter/\(adminUserId)"

        guard let url = URL(string: urlString) else {
            errorMessage = "Invalid URL"
            isLoading = false
            return
        }

        let newWaiter = NewWaiterRequest(
            name: name.trimmingCharacters(in: .whitespacesAndNewlines),
            email: email.trimmingCharacters(in: .whitespacesAndNewlines).lowercased(),
            passwordHash: password,
            role: "Waiter"
        )

        guard let encoded = try? JSONEncoder().encode(newWaiter) else {
            errorMessage = "Encoding failed"
            isLoading = false
            return
        }

        var req = URLRequest(url: url)
        req.httpMethod = "POST"
        req.addValue("application/json", forHTTPHeaderField: "Content-Type")
        req.httpBody = encoded

        do {
            let (data, response) = try await URLSession.shared.data(for: req)
            
            if let httpResponse = response as? HTTPURLResponse {
                if httpResponse.statusCode == 200 {
                    // Success
                    if let responseDict = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
                       let msg = responseDict["Message"] as? String {
                        
                        DispatchQueue.main.async {
                            successMessage = msg
                            isLoading = false
                            
                            // Call the onAdd callback and dismiss after 1 second
                            onAdd()
                            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                                dismiss()
                            }
                        }
                    }
                } else {
                    // Server error
                    if let errorDict = try? JSONSerialization.jsonObject(with: data) as? [String: String],
                       let errorMsg = errorDict["Message"] {
                        DispatchQueue.main.async {
                            errorMessage = errorMsg
                            isLoading = false
                        }
                    } else {
                        DispatchQueue.main.async {
                            errorMessage = "Failed to create waiter (Status: \(httpResponse.statusCode))"
                            isLoading = false
                        }
                    }
                }
            }

        } catch {
            DispatchQueue.main.async {
                errorMessage = "Failed: \(error.localizedDescription)"
                isLoading = false
            }
        }
    }
}

// MARK: - Preview
struct ShowWaiter_Previews: PreviewProvider {
    static var previews: some View {
        ShowWaiter(adminUserId: 1)
            .environmentObject(UserViewModel())
    }
}
