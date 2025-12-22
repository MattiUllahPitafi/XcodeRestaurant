import Foundation

class WaiterViewModel: ObservableObject {
    @Published var assignments: [WaiterAssignment] = []
    @Published var errorMessage: String?
    @Published var isLoading = false
    
    private let apiBase = "\(APIConfig.baseURL)/waiters"
    
    // Fetch assignments for waiter
    func fetchAssignments(for waiterUserId: Int) async {
        guard let url = URL(string: "\(apiBase)/byid/\(waiterUserId)") else {
            errorMessage = "Invalid API URL"
            return
        }

        isLoading = true
        errorMessage = nil

        do {
            let (data, response) = try await URLSession.shared.data(from: url)

            // Debugging the response type
            if let httpResponse = response as? HTTPURLResponse {
                print("HTTP Response Code: \(httpResponse.statusCode)")
                print("Response Mime Type: \(httpResponse.mimeType ?? "No MIME Type")")
                print("Raw Response Data: \(String(data: data, encoding: .utf8) ?? "No response data")")
            }

            // Check if the response is JSON
            if let httpResponse = response as? HTTPURLResponse,
               !(httpResponse.mimeType?.contains("application/json") ?? false) {
                errorMessage = "Server did not return JSON"
                isLoading = false
                return
            }

            // Decode the JSON response
            let decoded = try JSONDecoder().decode([WaiterAssignment].self, from: data)
            DispatchQueue.main.async {
                self.assignments = decoded
                self.isLoading = false
            }

        } catch {
            DispatchQueue.main.async {
                self.errorMessage = "Failed to load assignments: \(error.localizedDescription)"
                self.isLoading = false
            }
        }
    }

    // Serve order function
    func serveOrder(orderId: Int, waiterId: Int) async {
        guard let url = APIConfig.url(for: .waiterServeOrder(orderId)) else {
            errorMessage = "Invalid API URL"
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "PUT"
        request.setValue("text/plain", forHTTPHeaderField: "Content-Type")  // Set correct Content-Type for plain text

        // Sending the status as plain text
        let status = "Served"
        request.httpBody = status.data(using: .utf8)

        do {
            let (_, response) = try await URLSession.shared.data(for: request)

            if let httpResponse = response as? HTTPURLResponse,
               httpResponse.statusCode == 200 {
                // Success - Update the assignments after serving the order
                await fetchAssignments(for: waiterId)  // Use the real waiterId instead of hardcoded '1'
            } else {
                errorMessage = "Failed to update status to 'Served'. HTTP Status Code: \(String(describing: response))"
            }
        } catch {
            errorMessage = "Failed to update order: \(error.localizedDescription)"
        }
    }


}
struct WaiterAssignment: Codable, Identifiable {
    let waiterUserId: Int
    let bookingId: Int
    let booking: BookingData
    let orderStatus: String
    let orderId:Int
    var id: Int { bookingId }
}

struct BookingData: Codable {
    let tableId: Int
    let table: TableData
}

struct TableData: Codable {
    let name: String
    let floor: Int
}
