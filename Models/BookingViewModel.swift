import Foundation

@MainActor
class BookingViewModel: ObservableObject {
    @Published var tables: [Table] = []
    @Published var isLoading = false
    @Published var errorMessage: String?

    func fetchTables(for restaurantId: Int) async {
        isLoading = true
        errorMessage = nil
        
        guard let url = URL(string: "https://yourapi.com/api/tables/restaurant/\(restaurantId)") else {
            errorMessage = "Invalid URL"
            isLoading = false
            return
        }
        
        do {
            let (data, response) = try await URLSession.shared.data(from: url)
            
            guard let httpResponse = response as? HTTPURLResponse,
                  httpResponse.statusCode == 200 else {
                errorMessage = "Failed to load tables."
                return
            }
            
            let decodedTables = try JSONDecoder().decode([Table].self, from: data)
            tables = decodedTables
        } catch {
            errorMessage = "Error: \(error.localizedDescription)"
        }
        
        isLoading = false
    }
}

extension Table {
    var isAvailable: Bool {
        status.lowercased() == "available"
    }
}
