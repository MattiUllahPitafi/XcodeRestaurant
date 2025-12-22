import SwiftUI
import PhotosUI

// MARK: - Category List
let restaurantCategories: [String] = [
    "Desi",
    "Fast Food",
    "Fine Dining",
    "Cafe",
    "Bakery",
    "BBQ",
    "Chinese",
    "Italian",
    "American",
    "Mexican",
    "Seafood",
    "Vegetarian",
    "Vegan",
    "Street Food",
    "Continental",
    "Japanese",
    "Thai",
    "Middle Eastern",
    "Indian",
    "Mediterranean",
    "Bar",
    "Pub"
]

// MARK: - API Models
struct CreateWithAdminResponse: Codable {
    let Success: Bool
    let Message: String
    let RestaurantId: Int?
    let AdminId: Int?
}

// ✅ Fetch model (matches your GET /all response)
struct RestaurantListItem: Codable, Identifiable {
    let id: Int
    let name: String
    let location: String
    let category: String
    let imageUrl: String

    enum CodingKeys: String, CodingKey {
        case id = "restaurantId"
        case name, location, category, imageUrl
    }
}

// ✅ Keep your older model unchanged (for other screens if you use it)
struct Restaurant1: Codable, Identifiable {
    let id: Int
    let name: String
    let location: String
    let category: String
    let imageUrl: String
    let averageRating: Double
    let reviewCount: Int

    enum CodingKeys: String, CodingKey {
        case id = "restaurantId"
        case name
        case location
        case category
        case imageUrl
        case averageRating
        case reviewCount
    }
}

// MARK: - ViewModel
final class RestaurantViewModel: ObservableObject {
    @Published var restaurants: [RestaurantListItem] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var successMessage: String?

    private let baseURL = "\(APIConfig.baseURL)/restaurants"

    func fetchRestaurants() {
        isLoading = true
        errorMessage = nil

        fetchRestaurants { [weak self] result in
            DispatchQueue.main.async {
                self?.isLoading = false
                switch result {
                case .success(let restaurants):
                    self?.restaurants = restaurants
                case .failure(let error):
                    self?.errorMessage = "Failed to fetch restaurants: \(error.localizedDescription)"
                    print("❌ fetchRestaurants error:", error)
                }
            }
        }
    }

    private func fetchRestaurants(completion: @escaping (Result<[RestaurantListItem], Error>) -> Void) {
        guard let url = URL(string: "\(baseURL)/all") else {
            completion(.failure(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Invalid URL"])))
            return
        }

        URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error { completion(.failure(error)); return }

            guard let httpResponse = response as? HTTPURLResponse else {
                completion(.failure(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Invalid response"])))
                return
            }

            guard (200...299).contains(httpResponse.statusCode) else {
                completion(.failure(NSError(domain: "", code: httpResponse.statusCode, userInfo: [NSLocalizedDescriptionKey: "Server error: \(httpResponse.statusCode)"])))
                return
            }

            guard let data = data else {
                completion(.failure(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "No data received"])))
                return
            }

            do {
                let decoded = try JSONDecoder().decode([RestaurantListItem].self, from: data)
                completion(.success(decoded))
            } catch {
                // helpful debug
                print("❌ decode error:", error)
                if let raw = String(data: data, encoding: .utf8) { print("📦 raw:", raw) }
                completion(.failure(error))
            }
        }.resume()
    }

    func createRestaurantWithAdmin(
        name: String,
        location: String,
        category: String,
        image: UIImage?,
        adminName: String,
        adminEmail: String,
        adminPassword: String,
        completion: @escaping (Bool, Int?, Int?) -> Void
    ) {
        guard !name.isEmpty, !location.isEmpty, !category.isEmpty,
              !adminName.isEmpty, !adminEmail.isEmpty, !adminPassword.isEmpty else {
            errorMessage = "Please fill all required fields"
            completion(false, nil, nil)
            return
        }

        if !isValidEmail(adminEmail) {
            errorMessage = "Please enter a valid email address"
            completion(false, nil, nil)
            return
        }

        isLoading = true
        errorMessage = nil
        successMessage = nil

        guard let url = URL(string: "\(baseURL)/createwithadmin") else {
            errorMessage = "Invalid URL"
            isLoading = false
            completion(false, nil, nil)
            return
        }

        let boundary = UUID().uuidString

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        request.timeoutInterval = 60

        request.httpBody = createRestaurantWithAdminMultipartBody(
            name: name,
            location: location,
            category: category,
            image: image,
            adminName: adminName,
            adminEmail: adminEmail,
            adminPassword: adminPassword,
            boundary: boundary
        )

        URLSession.shared.dataTask(with: request) { [weak self] data, response, error in
            DispatchQueue.main.async {
                self?.isLoading = false

                if let error = error {
                    self?.errorMessage = "Network error: \(error.localizedDescription)"
                    completion(false, nil, nil)
                    return
                }

                guard let httpResponse = response as? HTTPURLResponse else {
                    self?.errorMessage = "Invalid response from server"
                    completion(false, nil, nil)
                    return
                }

                print("✅ createwithadmin status:", httpResponse.statusCode)
                if let data = data, let raw = String(data: data, encoding: .utf8) { print("📦 raw:", raw) }

                switch httpResponse.statusCode {
                case 200:
                    do {
                        guard let data = data else {
                            self?.errorMessage = "No data received from server"
                            completion(false, nil, nil)
                            return
                        }

                        let res = try JSONDecoder().decode(CreateWithAdminResponse.self, from: data)
                        if res.Success {
                            self?.successMessage = res.Message
                            self?.fetchRestaurants()
                            completion(true, res.RestaurantId, res.AdminId)
                        } else {
                            self?.errorMessage = res.Message
                            completion(false, nil, nil)
                        }
                    } catch {
                        self?.errorMessage = "Failed to process response"
                        completion(false, nil, nil)
                    }

                case 400:
                    if let data = data, let raw = String(data: data, encoding: .utf8) {
                        self?.errorMessage = raw
                    } else {
                        self?.errorMessage = "Validation failed. Please check your inputs."
                    }
                    completion(false, nil, nil)

                default:
                    self?.errorMessage = "Server error: \(httpResponse.statusCode)"
                    completion(false, nil, nil)
                }
            }
        }.resume()
    }

    private func createRestaurantWithAdminMultipartBody(
        name: String,
        location: String,
        category: String,
        image: UIImage?,
        adminName: String,
        adminEmail: String,
        adminPassword: String,
        boundary: String
    ) -> Data {
        var body = Data()

        func appendString(_ string: String) {
            if let data = string.data(using: .utf8) { body.append(data) }
        }

        // Restaurant fields
        appendString("--\(boundary)\r\n")
        appendString("Content-Disposition: form-data; name=\"Name\"\r\n\r\n")
        appendString("\(name)\r\n")

        appendString("--\(boundary)\r\n")
        appendString("Content-Disposition: form-data; name=\"Location\"\r\n\r\n")
        appendString("\(location)\r\n")

        appendString("--\(boundary)\r\n")
        appendString("Content-Disposition: form-data; name=\"Category\"\r\n\r\n")
        appendString("\(category)\r\n")

        // Admin fields
        appendString("--\(boundary)\r\n")
        appendString("Content-Disposition: form-data; name=\"AdminName\"\r\n\r\n")
        appendString("\(adminName)\r\n")

        appendString("--\(boundary)\r\n")
        appendString("Content-Disposition: form-data; name=\"AdminEmail\"\r\n\r\n")
        appendString("\(adminEmail)\r\n")

        appendString("--\(boundary)\r\n")
        appendString("Content-Disposition: form-data; name=\"AdminPassword\"\r\n\r\n")
        appendString("\(adminPassword)\r\n")

        // Image
        if let image = image, let imageData = image.jpegData(compressionQuality: 0.8) {
            appendString("--\(boundary)\r\n")
            appendString("Content-Disposition: form-data; name=\"Image\"; filename=\"restaurant_\(Int(Date().timeIntervalSince1970)).jpg\"\r\n")
            appendString("Content-Type: image/jpeg\r\n\r\n")
            body.append(imageData)
            appendString("\r\n")
        }

        appendString("--\(boundary)--\r\n")
        return body
    }

    private func isValidEmail(_ email: String) -> Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        return NSPredicate(format: "SELF MATCHES %@", emailRegEx).evaluate(with: email)
    }
}

// MARK: - Image Picker
struct ImagePicker: UIViewControllerRepresentable {
    @Binding var selectedImage: UIImage?
    @Environment(\.presentationMode) var presentationMode
    var sourceType: UIImagePickerController.SourceType

    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.delegate = context.coordinator
        picker.sourceType = sourceType
        picker.allowsEditing = true
        return picker
    }

    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}

    func makeCoordinator() -> Coordinator { Coordinator(self) }

    final class Coordinator: NSObject, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
        let parent: ImagePicker
        init(_ parent: ImagePicker) { self.parent = parent }

        func imagePickerController(_ picker: UIImagePickerController,
                                   didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            if let edited = info[.editedImage] as? UIImage {
                parent.selectedImage = edited
            } else if let original = info[.originalImage] as? UIImage {
                parent.selectedImage = original
            }
            parent.presentationMode.wrappedValue.dismiss()
        }

        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            parent.presentationMode.wrappedValue.dismiss()
        }
    }
}

// MARK: - Category Picker
struct CategoryPickerView: View {
    @Binding var selectedCategory: String
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationView {
            List(restaurantCategories, id: \.self) { category in
                HStack {
                    Text(category).font(.headline)
                    Spacer()
                    if selectedCategory == category {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundColor(.blue)
                    }
                }
                .contentShape(Rectangle())
                .onTapGesture {
                    selectedCategory = category
                    dismiss()
                }
            }
            .navigationTitle("Select Category")
        }
    }
}

// MARK: - Restaurant List UI
struct RestaurantListView: View {
    let restaurants: [RestaurantListItem]

    var body: some View {
        ScrollView {
            LazyVStack(spacing: 10) {
                ForEach(restaurants) { restaurant in
                    RestaurantRowView(restaurant: restaurant)
                }
            }
            .padding(.top, 10)
            .padding(.bottom, 20)
        }
    }
}

struct RestaurantRowView: View {
    let restaurant: RestaurantListItem

    var body: some View {
        HStack(spacing: 14) {
            ZStack {
                Circle()
                    .fill(Color.orange.opacity(0.15))
                    .frame(width: 52, height: 52)

                Image(systemName: "fork.knife")
                    .foregroundColor(.orange)
                    .font(.system(size: 22, weight: .semibold))
            }

            VStack(alignment: .leading, spacing: 6) {
                Text(restaurant.name)
                    .font(.headline)
                    .foregroundColor(.primary)

                HStack(spacing: 8) {
                    Label(restaurant.location, systemImage: "location.fill")
                        .font(.caption)
                        .foregroundColor(.green)

                    Text("•").foregroundColor(.gray)

                    Label(restaurant.category, systemImage: "tag.fill")
                        .font(.caption)
                        .foregroundColor(.orange)
                }
            }

            Spacer()

            Image(systemName: "chevron.right")
                .foregroundColor(.gray)
                .font(.caption)
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 14)
                .fill(Color(.systemBackground))
                .shadow(color: .black.opacity(0.06), radius: 6, x: 0, y: 3)
        )
        .padding(.horizontal)
    }
}

struct EmptyStateView: View {
    var body: some View {
        VStack(spacing: 18) {
            Spacer()
            Image(systemName: "fork.knife.circle")
                .font(.system(size: 72))
                .foregroundColor(.gray.opacity(0.5))
            Text("No Restaurants Yet")
                .font(.title2)
                .fontWeight(.semibold)
            Text("Add your first restaurant from the button above.")
                .foregroundColor(.gray)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)
            Spacer()
        }
    }
}

struct ErrorMessageView: View {
    let message: String
    var body: some View {
        HStack {
            Image(systemName: "exclamationmark.triangle.fill")
                .foregroundColor(.white)
                .font(.caption)
            Text(message)
                .foregroundColor(.white)
                .font(.caption)
                .lineLimit(2)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(Color.red)
        .cornerRadius(10)
        .padding(.horizontal)
    }
}

struct SuccessMessageView: View {
    let message: String
    var body: some View {
        HStack {
            Image(systemName: "checkmark.circle.fill")
                .foregroundColor(.white)
                .font(.caption)
            Text(message)
                .foregroundColor(.white)
                .font(.caption)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(Color.green)
        .cornerRadius(10)
        .padding(.horizontal)
    }
}

// MARK: - Create Restaurant Form
struct CreateRestaurantForm: View {
    @Binding var isPresented: Bool
    @ObservedObject var viewModel: RestaurantViewModel

    @State private var restaurantName = ""
    @State private var restaurantLocation = ""
    @State private var restaurantCategory = ""
    @State private var selectedImage: UIImage?

    @State private var adminName = ""
    @State private var adminEmail = ""
    @State private var adminPassword = ""
    @State private var confirmPassword = ""

    @State private var showCategoryPicker = false
    @State private var showImageSourcePicker = false
    @State private var showCamera = false
    @State private var showPhotoLibrary = false
    @State private var showPassword = false
    @State private var showConfirmPassword = false

    private var isFormValid: Bool {
        !restaurantName.isEmpty &&
        !restaurantLocation.isEmpty &&
        !restaurantCategory.isEmpty &&
        !adminName.isEmpty &&
        !adminEmail.isEmpty &&
        !adminPassword.isEmpty &&
        !confirmPassword.isEmpty &&
        adminPassword == confirmPassword &&
        adminPassword.count >= 6 &&
        isValidEmail(adminEmail)
    }

    private func isValidEmail(_ email: String) -> Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        return NSPredicate(format:"SELF MATCHES %@", emailRegEx).evaluate(with: email)
    }

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Restaurant Details").font(.headline)) {
                    VStack(alignment: .leading, spacing: 6) {
                        Text("Restaurant Name *").font(.caption).foregroundColor(.gray)
                        TextField("e.g., Pizza Palace", text: $restaurantName)
                            .textContentType(.name)
                            .autocapitalization(.words)
                    }
                    .padding(.vertical, 4)

                    VStack(alignment: .leading, spacing: 6) {
                        Text("Location *").font(.caption).foregroundColor(.gray)
                        TextField("e.g., Islamabad", text: $restaurantLocation)
                            .textContentType(.fullStreetAddress)
                            .autocapitalization(.words)
                    }
                    .padding(.vertical, 4)

                    VStack(alignment: .leading, spacing: 6) {
                        Text("Category *").font(.caption).foregroundColor(.gray)
                        Button {
                            showCategoryPicker = true
                        } label: {
                            HStack {
                                Text(restaurantCategory.isEmpty ? "Select Category" : restaurantCategory)
                                    .foregroundColor(restaurantCategory.isEmpty ? .gray : .primary)
                                Spacer()
                                Image(systemName: "chevron.down").foregroundColor(.gray).font(.caption)
                            }
                        }
                    }
                    .padding(.vertical, 4)
                    .sheet(isPresented: $showCategoryPicker) {
                        CategoryPickerView(selectedCategory: $restaurantCategory)
                    }

                    VStack(alignment: .leading, spacing: 6) {
                        Text("Restaurant Image (Optional)").font(.caption).foregroundColor(.gray)

                        if let img = selectedImage {
                            VStack(spacing: 12) {
                                Image(uiImage: img)
                                    .resizable()
                                    .scaledToFill()
                                    .frame(height: 160)
                                    .frame(maxWidth: .infinity)
                                    .clipShape(RoundedRectangle(cornerRadius: 10))

                                HStack(spacing: 12) {
                                    Button("Change Image") { showImageSourcePicker = true }
                                        .buttonStyle(.bordered)

                                    Button("Remove", role: .destructive) { selectedImage = nil }
                                        .buttonStyle(.bordered)
                                }
                            }
                            .padding(.vertical, 6)
                        } else {
                            Button {
                                showImageSourcePicker = true
                            } label: {
                                VStack(spacing: 10) {
                                    Image(systemName: "photo.on.rectangle.angled")
                                        .font(.system(size: 32))
                                        .foregroundColor(.blue)
                                    Text("Add Restaurant Image").font(.subheadline).foregroundColor(.blue)
                                    Text("Optional").font(.caption2).foregroundColor(.gray)
                                }
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 18)
                                .background(Color.blue.opacity(0.06))
                                .cornerRadius(10)
                            }
                        }
                    }
                    .padding(.vertical, 4)
                }

                Section(header: Text("Restaurant Admin/Manager").font(.headline)) {
                    VStack(alignment: .leading, spacing: 6) {
                        Text("Admin Name *").font(.caption).foregroundColor(.gray)
                        TextField("e.g., John Smith", text: $adminName)
                            .textContentType(.name)
                            .autocapitalization(.words)
                    }
                    .padding(.vertical, 4)

                    VStack(alignment: .leading, spacing: 6) {
                        Text("Admin Email *").font(.caption).foregroundColor(.gray)
                        TextField("e.g., admin@restaurant.com", text: $adminEmail)
                            .textContentType(.emailAddress)
                            .keyboardType(.emailAddress)
                            .autocapitalization(.none)

                        if !adminEmail.isEmpty && !isValidEmail(adminEmail) {
                            Text("Please enter a valid email address").font(.caption).foregroundColor(.red)
                        }
                    }
                    .padding(.vertical, 4)

                    VStack(alignment: .leading, spacing: 6) {
                        Text("Password *").font(.caption).foregroundColor(.gray)
                        HStack {
                            if showPassword {
                                TextField("Enter password", text: $adminPassword)
                            } else {
                                SecureField("Enter password", text: $adminPassword)
                            }
                            Button { showPassword.toggle() } label: {
                                Image(systemName: showPassword ? "eye.slash" : "eye").foregroundColor(.gray)
                            }
                        }

                        if !adminPassword.isEmpty && adminPassword.count < 6 {
                            Text("Password must be at least 6 characters").font(.caption).foregroundColor(.red)
                        }
                    }
                    .padding(.vertical, 4)

                    VStack(alignment: .leading, spacing: 6) {
                        Text("Confirm Password *").font(.caption).foregroundColor(.gray)
                        HStack {
                            if showConfirmPassword {
                                TextField("Confirm password", text: $confirmPassword)
                            } else {
                                SecureField("Confirm password", text: $confirmPassword)
                            }
                            Button { showConfirmPassword.toggle() } label: {
                                Image(systemName: showConfirmPassword ? "eye.slash" : "eye").foregroundColor(.gray)
                            }
                        }

                        if !confirmPassword.isEmpty && adminPassword != confirmPassword {
                            Text("Passwords do not match").font(.caption).foregroundColor(.red)
                        }
                    }
                    .padding(.vertical, 4)
                }

                Section(footer: Text("* Required fields").font(.caption)) {
                    Button {
                        createRestaurantWithAdmin()
                    } label: {
                        HStack {
                            Spacer()
                            if viewModel.isLoading {
                                ProgressView()
                                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                    .scaleEffect(0.9)
                            } else {
                                Text("Create Restaurant & Admin")
                                    .fontWeight(.semibold)
                            }
                            Spacer()
                        }
                        .padding(.vertical, 12)
                    }
                    .disabled(!isFormValid || viewModel.isLoading)
                    .foregroundColor(.white)
                    .listRowBackground((!isFormValid || viewModel.isLoading) ? Color.gray.opacity(0.5) : Color.blue)
                }
            }
            .navigationTitle("New Restaurant & Admin")
            .navigationBarItems(
                leading: Button("Cancel") { isPresented = false },
                trailing: Button("Clear") { clearForm() }
            )
            .confirmationDialog("Select Image Source", isPresented: $showImageSourcePicker) {
                if UIImagePickerController.isSourceTypeAvailable(.camera) {
                    Button("Camera") { showCamera = true }
                }
                Button("Photo Library") { showPhotoLibrary = true }
                Button("Cancel", role: .cancel) {}
            }
            .sheet(isPresented: $showCamera) {
                ImagePicker(selectedImage: $selectedImage, sourceType: .camera)
            }
            .sheet(isPresented: $showPhotoLibrary) {
                ImagePicker(selectedImage: $selectedImage, sourceType: .photoLibrary)
            }
        }
    }

    private func createRestaurantWithAdmin() {
        viewModel.createRestaurantWithAdmin(
            name: restaurantName,
            location: restaurantLocation,
            category: restaurantCategory,
            image: selectedImage,
            adminName: adminName,
            adminEmail: adminEmail,
            adminPassword: adminPassword
        ) { success, _, _ in
            if success {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
                    clearForm()
                    isPresented = false
                }
            }
        }
    }

    private func clearForm() {
        restaurantName = ""
        restaurantLocation = ""
        restaurantCategory = ""
        selectedImage = nil
        adminName = ""
        adminEmail = ""
        adminPassword = ""
        confirmPassword = ""
        showPassword = false
        showConfirmPassword = false
    }
}

// MARK: - Main Dashboard
struct AppAdminDashboard: View {
    @StateObject private var viewModel = RestaurantViewModel()
    @State private var showingCreateForm = false

    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Restaurant Management")
                        .font(.largeTitle)
                        .fontWeight(.bold)

                    Text("App Admin Dashboard - Add new Restaurants")
                        .font(.subheadline)
                        .foregroundColor(.orange)
                }
                .padding(.horizontal)
                .padding(.top)
                .frame(maxWidth: .infinity, alignment: .leading)

                Divider().padding(.vertical, 8)

                VStack(spacing: 12) {
                    if let error = viewModel.errorMessage {
                        ErrorMessageView(message: error)
                            .onTapGesture { viewModel.errorMessage = nil }
                    }

                    if let success = viewModel.successMessage {
                        SuccessMessageView(message: success)
                            .onTapGesture { viewModel.successMessage = nil }
                    }

                    HStack {
                        Text("Total Restaurants: \(viewModel.restaurants.count)")
                            .font(.headline)
                            .foregroundColor(.purple)

                        Spacer()

                        Button {
                            showingCreateForm = true
                        } label: {
                            Label("New Restaurant", systemImage: "plus.circle.fill")
                                .font(.headline)
                                .foregroundColor(.white)
                                .padding(.horizontal, 18)
                                .padding(.vertical, 10)
                                .background(Color.blue)
                                .cornerRadius(10)
                        }
                    }
                    .padding(.horizontal)
                }
                .padding(.bottom, 10)

                Divider()

                if viewModel.isLoading && viewModel.restaurants.isEmpty {
                    VStack {
                        Spacer()
                        ProgressView("Loading restaurants...")
                            .padding()
                        Spacer()
                    }
                } else if viewModel.restaurants.isEmpty {
                    EmptyStateView()
                } else {
                    RestaurantListView(restaurants: viewModel.restaurants)
                }
            }
            .navigationBarHidden(true)
            .sheet(isPresented: $showingCreateForm) {
                CreateRestaurantForm(
                    isPresented: $showingCreateForm,
                    viewModel: viewModel
                )
            }
            .onAppear {
                if viewModel.restaurants.isEmpty {
                    viewModel.fetchRestaurants()
                }
            }
            .refreshable {
                viewModel.fetchRestaurants()
            }
        }
    }
}

// MARK: - Preview
struct AppAdminDashboard_Previews: PreviewProvider {
    static var previews: some View {
        AppAdminDashboard()
    }
}
