import SwiftUI
import PhotosUI

struct IngredientInput: Identifiable {
    let id = UUID()
    var name: String = ""
    var quantityRequired: String = ""
}

struct AddDishView: View {
    let userId: Int
    var onDishAdded: () -> Void

    @Environment(\.dismiss) private var dismiss

    @State private var name = ""
    @State private var price = ""
    @State private var prepTime = ""
    @State private var category = ""
    @State private var baseQuantity = ""
    @State private var unit = "plate"
    @State private var estimatedMinutesToDine = ""
    @State private var selectedImage: PhotosPickerItem? = nil
    @State private var dishImage: UIImage? = nil
    @State private var ingredients: [IngredientInput] = [IngredientInput()]
    @State private var isSubmitting = false

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Dish Details")) {
                    TextField("Dish Name", text: $name)
                    TextField("Price (pkr)", text: $price)
                        .keyboardType(.decimalPad)
                    TextField("Preparation Time (minutes)", text: $prepTime)
                        .keyboardType(.numberPad)
                    TextField("Menu Category Name", text: $category)
                    TextField("Base Quantity", text: $baseQuantity)
                        .keyboardType(.decimalPad)
                    TextField("Unit (e.g. plate, bowl)", text: $unit)
                    TextField("Estimated Minutes to Dine", text: $estimatedMinutesToDine)
                        .keyboardType(.numberPad)
                }

                Section(header: Text("Ingredients")) {
                    ForEach($ingredients) { $ingredient in
                        VStack(alignment: .leading) {
                            TextField("Ingredient Name", text: $ingredient.name)
                            TextField("Quantity Required (gm)", text: $ingredient.quantityRequired)
                                .keyboardType(.decimalPad)
                        }
                    }
                    Button(action: { ingredients.append(IngredientInput()) }) {
                        Label("Add Ingredient", systemImage: "plus.circle.fill")
                    }
                }

                Section(header: Text("Dish Image")) {
                    if let image = dishImage {
                        Image(uiImage: image)
                            .resizable()
                            .scaledToFit()
                            .frame(height: 180)
                            .cornerRadius(12)
                    }

                    PhotosPicker(selection: $selectedImage, matching: .images) {
                        HStack {
                            Image(systemName: "photo.on.rectangle")
                            Text("Select Dish Image")
                        }
                    }
                    .onChange(of: selectedImage) { newValue in
                        Task {
                            if let data = try? await newValue?.loadTransferable(type: Data.self),
                               let uiImage = UIImage(data: data) {
                                dishImage = uiImage
                            }
                        }
                    }
                }

                Section {
                    Button(action: addDish) {
                        if isSubmitting {
                            ProgressView()
                        } else {
                            Text("Add Dish")
                                .fontWeight(.semibold)
                        }
                    }
                    .disabled(isSubmitting)
                }
            }
            .navigationTitle("Add New Dish")
            .toolbar {
                Button("Close") { dismiss() }
            }
        }
    }

    private func addDish() {
        guard
            let priceVal = Double(price),
            let prepVal = Int(prepTime),
            let baseQty = Double(baseQuantity),
            let estimatedDineTime = Int(estimatedMinutesToDine)
        else {
            print("⚠️ Missing or invalid numeric input")
            return
        }

        isSubmitting = true

        guard let url = APIConfig.url(for: .adminCreateDish) else {
            print("❌ Invalid API URL")
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"

        let boundary = UUID().uuidString
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")

        var body = Data()

        func appendFormField(name: String, value: String) {
            body.append("--\(boundary)\r\n")
            body.append("Content-Disposition: form-data; name=\"\(name)\"\r\n\r\n")
            body.append("\(value)\r\n")
        }

        // 🧾 Add text fields
        appendFormField(name: "UserId", value: "\(userId)")
        appendFormField(name: "Name", value: name)
        appendFormField(name: "Price", value: "\(priceVal)")
        appendFormField(name: "PrepTimeMinutes", value: "\(prepVal)")
        appendFormField(name: "MenuCategoryName", value: category)
        appendFormField(name: "BaseQuantity", value: "\(baseQty)")
        appendFormField(name: "Unit", value: unit)
        appendFormField(name: "EstimatedMinutesToDine", value: "\(estimatedDineTime)")

        // 🍽️ Convert ingredients to JSON
        let ingredientsArray = ingredients
            .filter { !$0.name.isEmpty && !$0.quantityRequired.isEmpty }
            .map { ["Name": $0.name, "QuantityRequired": Double($0.quantityRequired) ?? 0] }

        if let jsonData = try? JSONSerialization.data(withJSONObject: ingredientsArray),
           let jsonString = String(data: jsonData, encoding: .utf8) {
            appendFormField(name: "Ingredients", value: jsonString)
        }

        // 🖼️ Add image if selected
        if let image = dishImage,
           let imageData = image.jpegData(compressionQuality: 0.8) {
            body.append("--\(boundary)\r\n")
            body.append("Content-Disposition: form-data; name=\"DishImage\"; filename=\"\(UUID().uuidString).jpg\"\r\n")
            body.append("Content-Type: image/jpeg\r\n\r\n")
            body.append(imageData)
            body.append("\r\n")
        }

        body.append("--\(boundary)--\r\n")
        request.httpBody = body

        // 🚀 Send request
        URLSession.shared.dataTask(with: request) { data, response, error in
            DispatchQueue.main.async {
                isSubmitting = false

                if let error = error {
                    print("❌ Upload failed:", error.localizedDescription)
                    return
                }

                guard let httpResponse = response as? HTTPURLResponse else {
                    print("⚠️ No valid response")
                    return
                }

                print("✅ Response status:", httpResponse.statusCode)

                if let data = data,
                   let responseString = String(data: data, encoding: .utf8) {
                    print("📦 Server response:", responseString)
                }

                onDishAdded()
                dismiss()
            }
        }.resume()
    }
}

extension Data {
    mutating func append(_ string: String) {
        if let data = string.data(using: .utf8) {
            append(data)
        }
    }
}

