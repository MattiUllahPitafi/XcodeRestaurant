////
////  AppAdminDashboard.swift
////  RestAdvApp
////
////  Created by Matti Ullah on 07/12/2025.
////
//
//import SwiftUI
//
//struct AppAdminDashboard: View {
//    var body: some View {
//        Text("This is App Admin")
//    }
//}
//
//struct AppAdminDashboard_Previews: PreviewProvider {
//    static var previews: some View {
//        AppAdminDashboard()
//    }
//}
//  AppAdminDashboard.swift
//  RestAdvApp
//
//  Created by Matti Ullah on 07/12/2025.
//
//  AppAdminDashboard.swift
//  RestAdvApp
//
//  Created by Matti Ullah on 07/12/2025.
//
//  AppAdminDashboard.swift
//  RestAdvApp
//
//  Created by Matti Ullah on 07/12/2025.
//
//  AppAdminDashboard.swift
//  RestAdvApp
//
//  Created by Matti Ullah on 07/12/2025.
//

import SwiftUI
import PhotosUI

class RestaurantViewModel: ObservableObject {
    @Published var restaurants: [Restaurant] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var successMessage: String?
    
    private let baseURL = "http://10.211.55.7/BooknowAPI/api/restaurants"
    
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
                    print("Error fetching restaurants: \(error)")
                }
            }
        }
    }
    
    private func fetchRestaurants(completion: @escaping (Result<[Restaurant], Error>) -> Void) {
        guard let url = URL(string: "\(baseURL)/all") else {
            completion(.failure(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Invalid URL"])))
            return
        }
        
        URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
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
                let decoded = try JSONDecoder().decode([Restaurant].self, from: data)
                completion(.success(decoded))
            } catch {
                completion(.failure(error))
            }
        }.resume()
    }
    
    func createRestaurant(name: String, location: String, category: String, image: UIImage?, completion: @escaping (Bool) -> Void) {
        guard !name.isEmpty, !location.isEmpty, !category.isEmpty else {
            errorMessage = "Please fill all required fields"
            completion(false)
            return
        }
        
        isLoading = true
        errorMessage = nil
        successMessage = nil
        
        guard let url = URL(string: "\(baseURL)/create") else {
            errorMessage = "Invalid URL"
            isLoading = false
            completion(false)
            return
        }
        
        // Generate boundary for multipart form
        let boundary = UUID().uuidString
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        request.timeoutInterval = 30
        
        // Create multipart form data
        let httpBody = createMultipartBody(
            name: name,
            location: location,
            category: category,
            image: image,
            boundary: boundary
        )
        
        request.httpBody = httpBody
        
        URLSession.shared.dataTask(with: request) { [weak self] data, response, error in
            DispatchQueue.main.async {
                self?.isLoading = false
                
                if let error = error {
                    self?.errorMessage = "Network error: \(error.localizedDescription)"
                    completion(false)
                    return
                }
                
                guard let httpResponse = response as? HTTPURLResponse else {
                    self?.errorMessage = "Invalid response from server"
                    completion(false)
                    return
                }
                
                print("Create restaurant response status: \(httpResponse.statusCode)")
                
                if let data = data, let responseString = String(data: data, encoding: .utf8) {
                    print("Response: \(responseString)")
                }
                
                switch httpResponse.statusCode {
                case 200...299:
                    self?.successMessage = "Restaurant created successfully!"
                    self?.fetchRestaurants()
                    completion(true)
                    
                case 400:
                    if let data = data, let responseString = String(data: data, encoding: .utf8) {
                        print("Validation errors: \(responseString)")
                        self?.errorMessage = "Validation failed: \(responseString)"
                    } else {
                        self?.errorMessage = "Validation failed. Please check your inputs."
                    }
                    completion(false)
                    
                default:
                    self?.errorMessage = "Server error: \(httpResponse.statusCode)"
                    completion(false)
                }
            }
        }.resume()
    }
    
    private func createMultipartBody(name: String, location: String, category: String, image: UIImage?, boundary: String) -> Data {
        var body = Data()
        
        // Add name field
        body.append("--\(boundary)\r\n".data(using: .utf8)!)
        body.append("Content-Disposition: form-data; name=\"Name\"\r\n\r\n".data(using: .utf8)!)
        body.append("\(name)\r\n".data(using: .utf8)!)
        
        // Add location field
        body.append("--\(boundary)\r\n".data(using: .utf8)!)
        body.append("Content-Disposition: form-data; name=\"Location\"\r\n\r\n".data(using: .utf8)!)
        body.append("\(location)\r\n".data(using: .utf8)!)
        
        // Add category field
        body.append("--\(boundary)\r\n".data(using: .utf8)!)
        body.append("Content-Disposition: form-data; name=\"Category\"\r\n\r\n".data(using: .utf8)!)
        body.append("\(category)\r\n".data(using: .utf8)!)
        
        // Add image if exists
        if let image = image, let imageData = image.jpegData(compressionQuality: 0.8) {
            body.append("--\(boundary)\r\n".data(using: .utf8)!)
            body.append("Content-Disposition: form-data; name=\"Image\"; filename=\"restaurant_\(Int(Date().timeIntervalSince1970)).jpg\"\r\n".data(using: .utf8)!)
            body.append("Content-Type: image/jpeg\r\n\r\n".data(using: .utf8)!)
            body.append(imageData)
            body.append("\r\n".data(using: .utf8)!)
        }
        
        // Add closing boundary
        body.append("--\(boundary)--\r\n".data(using: .utf8)!)
        
        return body
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
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
        let parent: ImagePicker
        
        init(_ parent: ImagePicker) {
            self.parent = parent
        }
        
        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            if let editedImage = info[.editedImage] as? UIImage {
                parent.selectedImage = editedImage
            } else if let originalImage = info[.originalImage] as? UIImage {
                parent.selectedImage = originalImage
            }
            
            parent.presentationMode.wrappedValue.dismiss()
        }
        
        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            parent.presentationMode.wrappedValue.dismiss()
        }
    }
}

// MARK: - Supporting Views

struct CategoryPickerView: View {
    @Binding var isPresented: Bool
    @Binding var selectedCategory: String
    let categories: [String]
    
    @State private var searchText = ""
    
    var filteredCategories: [String] {
        if searchText.isEmpty {
            return categories
        } else {
            return categories.filter { $0.lowercased().contains(searchText.lowercased()) }
        }
    }
    
    var body: some View {
        NavigationView {
            List(filteredCategories, id: \.self) { category in
                Button(action: {
                    selectedCategory = category
                    isPresented = false
                }) {
                    HStack {
                        Text(category)
                            .foregroundColor(.primary)
                        Spacer()
                        if selectedCategory == category {
                            Image(systemName: "checkmark")
                                .foregroundColor(.blue)
                                .fontWeight(.bold)
                        }
                    }
                }
            }
            .navigationTitle("Select Category")
            .navigationBarItems(trailing: Button("Done") {
                isPresented = false
            })
            .searchable(text: $searchText, prompt: "Search categories")
        }
    }
}

struct RestaurantListView: View {
    let restaurants: [Restaurant]
    
    var body: some View {
        List {
            ForEach(restaurants) { restaurant in
                RestaurantRowView(restaurant: restaurant)
            }
        }
        .listStyle(PlainListStyle())
    }
}

struct RestaurantRowView: View {
    let restaurant: Restaurant
    
    var body: some View {
        HStack(spacing: 12) {
            // Restaurant Image/Icon
            ZStack {
                if let imageUrl = restaurant.imageUrl, !imageUrl.isEmpty {
                    AsyncImage(url: URL(string: "http://10.211.55.7/BooknowAPI/\(imageUrl)")) { image in
                        image
                            .resizable()
                            .scaledToFill()
                    } placeholder: {
                        Color.gray.opacity(0.1)
                    }
                    .frame(width: 50, height: 50)
                    .clipShape(Circle())
                } else {
                    Circle()
                        .fill(Color.blue.opacity(0.1))
                        .frame(width: 50, height: 50)
                    
                    Image(systemName: "fork.knife")
                        .font(.system(size: 20))
                        .foregroundColor(.blue)
                }
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(restaurant.name)
                    .font(.headline)
                    .foregroundColor(.primary)
                
                HStack(spacing: 8) {
                    Label(restaurant.location, systemImage: "location.fill")
                        .font(.caption)
                        .foregroundColor(.gray)
                    
                    Text("•")
                        .foregroundColor(.gray)
                    
                    Label(restaurant.category, systemImage: "tag.fill")
                        .font(.caption)
                        .foregroundColor(.gray)
                }
            }
            
            Spacer()
            
            Image(systemName: "chevron.right")
                .font(.caption)
                .foregroundColor(.gray)
        }
        .padding(.vertical, 8)
        .padding(.horizontal, 4)
    }
}

struct EmptyStateView: View {
    var body: some View {
        VStack(spacing: 20) {
            Spacer()
            
            Image(systemName: "fork.knife.circle")
                .font(.system(size: 70))
                .foregroundColor(.gray.opacity(0.5))
            
            VStack(spacing: 8) {
                Text("No Restaurants Yet")
                    .font(.title2)
                    .fontWeight(.semibold)
                    .foregroundColor(.primary)
                
                Text("Get started by adding your first restaurant")
                    .font(.body)
                    .foregroundColor(.gray)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 40)
            }
            
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
        .cornerRadius(8)
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
        .cornerRadius(8)
        .padding(.horizontal)
    }
}

struct AppAdminDashboard: View {
    @StateObject private var viewModel = RestaurantViewModel()
    @State private var showingCreateForm = false
    @State private var newRestaurantName = ""
    @State private var newRestaurantLocation = ""
    @State private var newRestaurantCategory = ""
    @State private var selectedImage: UIImage?
    
    // Common restaurant categories
    let categories = ["Italian", "Chinese", "Indian", "Mexican", "American", "Japanese", "Thai", "Mediterranean", "Fast Food", "Fine Dining", "Vegetarian", "Vegan", "Seafood", "Steakhouse", "Cafe", "Bakery", "Bar", "Pub"]
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Header
                VStack(alignment: .leading, spacing: 8) {
                    Text("Restaurant Management")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                    
                    Text("App Admin Dashboard")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                }
                .padding(.horizontal)
                .padding(.top)
                .frame(maxWidth: .infinity, alignment: .leading)
                
                Divider()
                    .padding(.vertical, 8)
                
                // Action Button and Status
                VStack(spacing: 12) {
                    // Status Messages
                    if let error = viewModel.errorMessage {
                        ErrorMessageView(message: error)
                            .onTapGesture {
                                viewModel.errorMessage = nil
                            }
                    }
                    
                    if let success = viewModel.successMessage {
                        SuccessMessageView(message: success)
                            .onTapGesture {
                                viewModel.successMessage = nil
                            }
                    }
                    
                    // Action Button
                    HStack {
                        Text("Total Restaurants: \(viewModel.restaurants.count)")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                        
                        Spacer()
                        
                        Button(action: {
                            showingCreateForm = true
                        }) {
                            Label("Add Restaurant", systemImage: "plus.circle.fill")
                                .font(.headline)
                                .foregroundColor(.white)
                                .padding(.horizontal, 20)
                                .padding(.vertical, 10)
                                .background(Color.blue)
                                .cornerRadius(10)
                        }
                    }
                    .padding(.horizontal)
                }
                .padding(.vertical, 8)
                
                Divider()
                
                // Restaurants List
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
                    name: $newRestaurantName,
                    location: $newRestaurantLocation,
                    category: $newRestaurantCategory,
                    selectedImage: $selectedImage,
                    categories: categories,
                    onCreate: createNewRestaurant,
                    isLoading: viewModel.isLoading
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
    
    private func createNewRestaurant() {
        viewModel.createRestaurant(
            name: newRestaurantName,
            location: newRestaurantLocation,
            category: newRestaurantCategory,
            image: selectedImage
        ) { success in
            if success {
                // Reset form fields
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    newRestaurantName = ""
                    newRestaurantLocation = ""
                    newRestaurantCategory = ""
                    selectedImage = nil
                    showingCreateForm = false
                }
            }
        }
    }
}

struct CreateRestaurantForm: View {
    @Binding var isPresented: Bool
    @Binding var name: String
    @Binding var location: String
    @Binding var category: String
    @Binding var selectedImage: UIImage?
    let categories: [String]
    let onCreate: () -> Void
    let isLoading: Bool
    
    @State private var showCategoryPicker = false
    @State private var showImageSourcePicker = false
    @State private var showCamera = false
    @State private var showPhotoLibrary = false
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Restaurant Details").font(.headline)) {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Restaurant Name *")
                            .font(.caption)
                            .foregroundColor(.gray)
                        TextField("e.g., Pizza Palace", text: $name)
                            .textContentType(.name)
                            .autocapitalization(.words)
                    }
                    .padding(.vertical, 4)
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Location *")
                            .font(.caption)
                            .foregroundColor(.gray)
                        TextField("e.g., 123 Main St, City", text: $location)
                            .textContentType(.fullStreetAddress)
                            .autocapitalization(.words)
                    }
                    .padding(.vertical, 4)
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Category *")
                            .font(.caption)
                            .foregroundColor(.gray)
                        Button(action: {
                            showCategoryPicker = true
                        }) {
                            HStack {
                                Text(category.isEmpty ? "Select Category" : category)
                                    .foregroundColor(category.isEmpty ? .gray : .primary)
                                Spacer()
                                Image(systemName: "chevron.down")
                                    .foregroundColor(.gray)
                                    .font(.caption)
                            }
                        }
                    }
                    .padding(.vertical, 4)
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Restaurant Image")
                            .font(.caption)
                            .foregroundColor(.gray)
                        
                        if let selectedImage = selectedImage {
                            VStack(spacing: 12) {
                                Image(uiImage: selectedImage)
                                    .resizable()
                                    .scaledToFill()
                                    .frame(height: 200)
                                    .frame(maxWidth: .infinity)
                                    .clipShape(RoundedRectangle(cornerRadius: 10))
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 10)
                                            .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                                    )
                                
                                HStack(spacing: 16) {
                                    Button("Change Image") {
                                        showImageSourcePicker = true
                                    }
                                    .buttonStyle(.bordered)
                                    
                                    Button("Remove", role: .destructive) {
                                        self.selectedImage = nil
                                    }
                                    .buttonStyle(.bordered)
                                }
                            }
                            .padding(.vertical, 8)
                        } else {
                            Button(action: {
                                showImageSourcePicker = true
                            }) {
                                VStack(spacing: 12) {
                                    Image(systemName: "photo.on.rectangle.angled")
                                        .font(.system(size: 40))
                                        .foregroundColor(.blue)
                                    
                                    Text("Add Restaurant Image")
                                        .font(.subheadline)
                                        .foregroundColor(.blue)
                                    
                                    Text("Optional - Tap to select from camera or gallery")
                                        .font(.caption)
                                        .foregroundColor(.gray)
                                        .multilineTextAlignment(.center)
                                }
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 30)
                                .background(Color.blue.opacity(0.05))
                                .cornerRadius(10)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 10)
                                        .stroke(Color.blue.opacity(0.3), style: StrokeStyle(lineWidth: 1, dash: [5]))
                                )
                            }
                        }
                    }
                    .padding(.vertical, 4)
                }
                
                Section(footer: Text("* Required fields")) {
                    Button(action: {
                        onCreate()
                    }) {
                        HStack {
                            Spacer()
                            if isLoading {
                                ProgressView()
                                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                            } else {
                                Text("Create Restaurant")
                                    .fontWeight(.semibold)
                            }
                            Spacer()
                        }
                    }
                    .disabled(name.isEmpty || location.isEmpty || category.isEmpty || isLoading)
                    .foregroundColor(.white)
                    .listRowBackground(
                        (name.isEmpty || location.isEmpty || category.isEmpty || isLoading) ?
                        Color.gray : Color.blue
                    )
                }
            }
            .navigationTitle("New Restaurant")
            .navigationBarItems(
                leading: Button("Cancel") {
                    isPresented = false
                },
                trailing: Button("Clear") {
                    name = ""
                    location = ""
                    category = ""
                    selectedImage = nil
                }
                .disabled(name.isEmpty && location.isEmpty && category.isEmpty && selectedImage == nil)
            )
            .sheet(isPresented: $showCategoryPicker) {
                CategoryPickerView(
                    isPresented: $showCategoryPicker,
                    selectedCategory: $category,
                    categories: categories
                )
            }
            .confirmationDialog("Select Image Source", isPresented: $showImageSourcePicker) {
                if UIImagePickerController.isSourceTypeAvailable(.camera) {
                    Button("Camera") {
                        showCamera = true
                    }
                }
                
                Button("Photo Library") {
                    showPhotoLibrary = true
                }
                
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
}

struct AppAdminDashboard_Previews: PreviewProvider {
    static var previews: some View {
        AppAdminDashboard()
    }
}
