import SwiftUI

struct UserBookingsView: View {
    let bookings: [Booking]

    var body: some View {
        List(bookings) { booking in
            NavigationLink(destination: BookingDetailView(booking: booking)) {
                VStack(alignment: .leading, spacing: 5) {
                    Text("Restaurant: \(booking.restaurantName)")
                        .font(.headline)
                    Text("Booking Date: \(formatDate(booking.bookingDateTime))")
                        .font(.subheadline)
                    Text("Table ID: \(booking.tableId)")
                        .font(.caption)
                        .foregroundColor(.gray)
                    Text("Status: \(booking.status)")
                        .font(.caption)
                        .foregroundColor(booking.status == "Booked" ? .green : .red)
                }
                .padding(.vertical, 5)
            }
        }
        .navigationTitle("My Bookings")
    }

    // Reuse ISO8601 formatting
    func formatDate(_ dateString: String) -> String {
        let formatter = ISO8601DateFormatter()
        if let date = formatter.date(from: dateString) {
            let displayFormatter = DateFormatter()
            displayFormatter.dateStyle = .medium
            displayFormatter.timeStyle = .short
            return displayFormatter.string(from: date)
        }
        return dateString
    }
}


//rating wala kam booking mn iska lia  profile mn ja k extra argumentlgana h NavigationLink("🪑 My Bookings") {
//UserBookingsView(bookings: bookings,
//                 userId: userVM.loggedInUserId ?? 0)
//}is trah
//import SwiftUI
//
//struct UserBookingsView: View {
//    let bookings: [Booking]
//    let userId: Int
//
//    @StateObject private var ratingManager = RatingManager()
//    @State private var selectedBookingForRating: Booking?
//    @State private var selectedStars = 0
//
//    var body: some View {
//        List(bookings) { booking in
//            VStack(alignment: .leading, spacing: 8) {
//                // Booking Info
//                NavigationLink(destination: BookingDetailView(booking: booking)) {
//                    VStack(alignment: .leading, spacing: 4) {
//                        Text("Restaurant: \(booking.restaurantName)")
//                            .font(.headline)
//                        Text("Booking Date: \(formatDate(booking.bookingDateTime))")
//                            .font(.subheadline)
//                        Text("Table ID: \(booking.tableId)")
//                            .font(.caption)
//                            .foregroundColor(.gray)
//                        Text("Status: \(booking.status)")
//                            .font(.caption)
//                            .foregroundColor(statusColor(for: booking.status))
//                    }
//                }
//
//                // ALWAYS show rating section for ALL bookings
//                Divider()
//
//                // Check if this booking already has a rating
//                let existingRating = ratingManager.getRating(for: booking.id)
//
//                if let existingRating = existingRating {
//                    // Show existing rating with edit option
//                    HStack {
//                        Text("Your Rating:")
//                            .font(.caption)
//                            .foregroundColor(.secondary)
//
//                        // Show stars for existing rating
//                        HStack(spacing: 2) {
//                            ForEach(0..<5) { index in
//                                Image(systemName: index < existingRating.stars ? "star.fill" : "star")
//                                    .resizable()
//                                    .frame(width: 12, height: 12)
//                                    .foregroundColor(.yellow)
//                            }
//                        }
//
//                        Text("\(existingRating.stars) stars")
//                            .font(.caption)
//                            .foregroundColor(.secondary)
//
//                        Spacer()
//
//                        // Edit button
//                        Button("Edit") {
//                            selectedStars = existingRating.stars
//                            selectedBookingForRating = booking
//                        }
//                        .font(.caption)
//                        .foregroundColor(.blue)
//                    }
//                } else {
//                    // Show rate button for ALL bookings (even if not rated yet)
//                    Button(action: {
//                        selectedBookingForRating = booking
//                        selectedStars = 0 // Reset stars for new rating
//                    }) {
//                        HStack {
//                            Image(systemName: "star")
//                                .font(.caption)
//                            Text("Rate This Visit")
//                                .font(.caption)
//                        }
//                        .padding(.horizontal, 12)
//                        .padding(.vertical, 6)
//                        .background(Color.blue.opacity(0.1))
//                        .cornerRadius(8)
//                    }
//                    .buttonStyle(PlainButtonStyle())
//                }
//            }
//            .padding(.vertical, 8)
//        }
//        .navigationTitle("My Bookings")
//        .onAppear {
//            // Load ratings for all bookings
//            print("📱 UserBookingsView appeared - Loading ratings for \(bookings.count) bookings")
//            ratingManager.loadRatingsForBookings(bookings)
//        }
//        .refreshable {
//            // Refresh ratings on pull-to-refresh
//            ratingManager.loadRatingsForBookings(bookings)
//        }
//        .sheet(item: $selectedBookingForRating) { booking in
//            SimpleRatingSheet(
//                existingRating: ratingManager.getRating(for: booking.id),
//                selectedStars: $selectedStars,
//                onSubmit: {
//                    submitRating(for: booking)
//                },
//                onUpdate: {
//                    updateRating(for: booking)
//                }
//            )
//        }
//        // Fixed: Use ratingManager.ratings.count instead of ratingManager.ratings
//        .onChange(of: ratingManager.ratings.count) { _ in
//            // Refresh UI when ratings change (when count changes)
//            print("🔄 Ratings updated, refreshing UI")
//        }
//    }
//
//    // MARK: - Helper Methods
//    private func statusColor(for status: String) -> Color {
//        switch status.lowercased() {
//        case "booked", "confirmed", "completed":
//            return .green
//        case "cancelled":
//            return .red
//        case "pending":
//            return .orange
//        default:
//            return .gray
//        }
//    }
//
//    private func submitRating(for booking: Booking) {
//        guard selectedStars > 0 else { return }
//
//        print("⭐ Submitting \(selectedStars) stars for booking \(booking.id)")
//        ratingManager.submitRatingByBooking(
//            bookingId: booking.id,
//            stars: selectedStars
//        )
//    }
//
//    private func updateRating(for booking: Booking) {
//        guard selectedStars > 0 else { return }
//
//        print("✏️ Updating to \(selectedStars) stars for booking \(booking.id)")
//        ratingManager.updateRatingByBooking(
//            bookingId: booking.id,
//            stars: selectedStars
//        )
//    }
//
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
//
//// MARK: - Simple Rating Sheet
//struct SimpleRatingSheet: View {
//    let existingRating: Rating?
//    @Binding var selectedStars: Int
//    let onSubmit: () -> Void
//    let onUpdate: () -> Void
//
//    @Environment(\.dismiss) var dismiss
//
//    var body: some View {
//        NavigationView {
//            VStack(spacing: 24) {
//                Text(existingRating == nil ? "Rate Your Experience" : "Update Your Rating")
//                    .font(.title2)
//                    .fontWeight(.semibold)
//
//                Text("How would you rate your experience at this restaurant?")
//                    .font(.body)
//                    .foregroundColor(.secondary)
//                    .multilineTextAlignment(.center)
//                    .padding(.horizontal)
//
//                // Star selector
//                HStack(spacing: 12) {
//                    ForEach(1...5, id: \.self) { star in
//                        Button(action: {
//                            selectedStars = star
//                            print("🌟 Selected \(star) stars")
//                        }) {
//                            Image(systemName: star <= selectedStars ? "star.fill" : "star")
//                                .resizable()
//                                .frame(width: 40, height: 40)
//                                .foregroundColor(star <= selectedStars ? .yellow : .gray)
//                        }
//                    }
//                }
//                .padding(.vertical)
//
//                // Rating label
//                Text(ratingLabel)
//                    .font(.headline)
//                    .foregroundColor(.primary)
//
//                Spacer()
//
//                // Submit/Update button
//                Button(action: {
//                    print("✅ \(existingRating == nil ? "Submitting" : "Updating") rating: \(selectedStars) stars")
//                    if existingRating == nil {
//                        onSubmit()
//                    } else {
//                        onUpdate()
//                    }
//                    dismiss()
//                }) {
//                    Text(existingRating == nil ? "Submit Rating" : "Update Rating")
//                        .font(.headline)
//                        .foregroundColor(.white)
//                        .frame(maxWidth: .infinity)
//                        .padding()
//                        .background(selectedStars > 0 ? Color.blue : Color.gray)
//                        .cornerRadius(10)
//                }
//                .disabled(selectedStars == 0)
//                .padding(.horizontal)
//            }
//            .padding()
//            .navigationBarItems(
//                leading: Button("Cancel") {
//                    dismiss()
//                }
//            )
//        }
//        .onAppear {
//            // Set initial stars
//            selectedStars = existingRating?.stars ?? 0
//            print("📊 RatingSheet appeared: existingRating=\(existingRating?.stars ?? 0), selectedStars=\(selectedStars)")
//        }
//    }
//
//    private var ratingLabel: String {
//        switch selectedStars {
//        case 1: return "Poor"
//        case 2: return "Fair"
//        case 3: return "Good"
//        case 4: return "Very Good"
//        case 5: return "Excellent"
//        default: return "Select a rating"
//        }
//    }
//}
//
//// MARK: - Rating Manager
//class RatingManager: ObservableObject {
//    @Published var ratings: [Int: Rating] = [:] // bookingId: Rating
//
//    private let apiService = APIService.shared
//
//    func loadRatingsForBookings(_ bookings: [Booking]) {
//        print("📊 RatingManager: Loading ratings for \(bookings.count) bookings")
//
//        for booking in bookings {
//            checkIfBookingIsRated(bookingId: booking.id)
//        }
//    }
//
//    private func checkIfBookingIsRated(bookingId: Int) {
//        print("📡 API Call: Checking if booking \(bookingId) is rated")
//
//        apiService.checkBookingRating(bookingId: bookingId) { [weak self] result in
//            DispatchQueue.main.async {
//                switch result {
//                case .success(let response):
//                    print("✅ API Response for booking \(bookingId): hasRated=\(response.hasRated), stars=\(String(describing: response.stars))")
//
//                    if response.hasRated, let ratingId = response.ratingId, let stars = response.stars {
//                        let rating = Rating(
//                            id: ratingId,
//                            bookingId: bookingId,
//                            stars: stars
//                        )
//                        self?.ratings[bookingId] = rating
//                        print("✅ Stored rating for booking \(bookingId): \(stars) stars")
//                    } else {
//                        self?.ratings[bookingId] = nil
//                        print("❌ No rating found for booking \(bookingId)")
//                    }
//
//                case .failure(let error):
//                    print("❌ Error checking rating for booking \(bookingId): \(error.localizedDescription)")
//                }
//            }
//        }
//    }
//
//    func getRating(for bookingId: Int) -> Rating? {
//        let rating = ratings[bookingId]
//        print("📋 Getting rating for booking \(bookingId): \(rating?.stars ?? 0) stars")
//        return rating
//    }
//
//    func submitRatingByBooking(bookingId: Int, stars: Int) {
//        print("🚀 Submitting rating: bookingId=\(bookingId), stars=\(stars)")
//
//        let request = RatingByBookingRequest(
//            bookingId: bookingId,
//            stars: stars
//        )
//
//        apiService.submitRatingByBooking(request) { [weak self] result in
//            DispatchQueue.main.async {
//                switch result {
//                case .success(let response):
//                    print("✅ Rating submitted successfully: \(response)")
//
//                    // Store the new rating
//                    let rating = Rating(
//                        id: response.ratingId,
//                        bookingId: bookingId,
//                        stars: stars
//                    )
//                    self?.ratings[bookingId] = rating
//
//                    // Show success alert or notification
//                    print("✅ Rating stored locally for booking \(bookingId): \(stars) stars")
//
//                case .failure(let error):
//                    print("❌ Error submitting rating: \(error.localizedDescription)")
//                }
//            }
//        }
//    }
//
//    func updateRatingByBooking(bookingId: Int, stars: Int) {
//        print("🔄 Updating rating: bookingId=\(bookingId), stars=\(stars)")
//
//        apiService.updateRatingByBooking(bookingId: bookingId, stars: stars) { [weak self] result in
//            DispatchQueue.main.async {
//                switch result {
//                case .success(let response):
//                    print("✅ Rating updated successfully: \(response)")
//
//                    // Update existing rating
//                    self?.ratings[bookingId]?.stars = stars
//                    print("✅ Rating updated locally for booking \(bookingId): \(stars) stars")
//
//                case .failure(let error):
//                    print("❌ Error updating rating: \(error.localizedDescription)")
//                }
//            }
//        }
//    }
//}
//
//// MARK: - Data Models (Updated with Equatable)
//struct Rating: Codable, Equatable {
//    let id: Int
//    let bookingId: Int?
//    var stars: Int
//
//    enum CodingKeys: String, CodingKey {
//        case id = "ratingId"
//        case bookingId
//        case stars = "Stars"
//    }
//
//    // Implement Equatable
//    static func == (lhs: Rating, rhs: Rating) -> Bool {
//        return lhs.id == rhs.id &&
//               lhs.bookingId == rhs.bookingId &&
//               lhs.stars == rhs.stars
//    }
//}
//
//struct RatingByBookingRequest: Codable {
//    let bookingId: Int
//    let stars: Int
//}
//
//struct RatingResponse: Codable {
//    let ratingId: Int
//    let bookingId: Int?
//    let stars: Int
//    let restaurantId: Int?
//    let restaurantName: String?
//    let message: String
//}
//
//struct BookingRatingCheckResponse: Codable {
//    let bookingId: Int?
//    let userId: Int?
//    let restaurantId: Int?
//    let hasRated: Bool
//    let ratingId: Int?
//    let stars: Int?
//    let message: String?
//}
//
//struct UpdateRatingRequest: Codable {
//    let stars: Int
//}
//
//// MARK: - APIService Extension
//extension APIService {
//    func checkBookingRating(bookingId: Int, completion: @escaping (Result<BookingRatingCheckResponse, Error>) -> Void) {
//        let urlString = "http://10.211.55.7/BooknowAPI/api/ratings/check/booking/\(bookingId)"
//
//        print("🌐 Checking rating at URL: \(urlString)")
//
//        guard let url = URL(string: urlString) else {
//            print("❌ Invalid URL: \(urlString)")
//            completion(.failure(NSError(domain: "Invalid URL", code: 0)))
//            return
//        }
//
//        URLSession.shared.dataTask(with: url) { data, response, error in
//            if let error = error {
//                print("❌ Network error: \(error.localizedDescription)")
//                completion(.failure(error))
//                return
//            }
//
//            if let httpResponse = response as? HTTPURLResponse {
//                print("📡 HTTP Status: \(httpResponse.statusCode)")
//            }
//
//            guard let data = data else {
//                print("❌ No data received")
//                completion(.failure(NSError(domain: "No data", code: 0)))
//                return
//            }
//
//            // Print raw response for debugging
//            if let responseString = String(data: data, encoding: .utf8) {
//                print("📦 Raw response: \(responseString)")
//            }
//
//            do {
//                let response = try JSONDecoder().decode(BookingRatingCheckResponse.self, from: data)
//                print("✅ Successfully decoded rating check response")
//                completion(.success(response))
//            } catch {
//                print("❌ Decoding error: \(error)")
//                completion(.failure(error))
//            }
//        }.resume()
//    }
//
//    func submitRatingByBooking(_ request: RatingByBookingRequest, completion: @escaping (Result<RatingResponse, Error>) -> Void) {
//        let urlString = "http://10.211.55.7/BooknowAPI/api/ratings/submit/bybooking"
//
//        print("🌐 Submitting rating at URL: \(urlString)")
//        print("📤 Request data: bookingId=\(request.bookingId), stars=\(request.stars)")
//
//        guard let url = URL(string: urlString) else {
//            print("❌ Invalid URL: \(urlString)")
//            completion(.failure(NSError(domain: "Invalid URL", code: 0)))
//            return
//        }
//
//        var urlRequest = URLRequest(url: url)
//        urlRequest.httpMethod = "POST"
//        urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
//
//        do {
//            let jsonData = try JSONEncoder().encode(request)
//            urlRequest.httpBody = jsonData
//
//            // Print JSON being sent
//            if let jsonString = String(data: jsonData, encoding: .utf8) {
//                print("📤 JSON being sent: \(jsonString)")
//            }
//        } catch {
//            print("❌ Encoding error: \(error)")
//            completion(.failure(error))
//            return
//        }
//
//        URLSession.shared.dataTask(with: urlRequest) { data, response, error in
//            if let error = error {
//                print("❌ Network error: \(error.localizedDescription)")
//                completion(.failure(error))
//                return
//            }
//
//            if let httpResponse = response as? HTTPURLResponse {
//                print("📡 HTTP Status: \(httpResponse.statusCode)")
//            }
//
//            guard let data = data else {
//                print("❌ No data received")
//                completion(.failure(NSError(domain: "No data", code: 0)))
//                return
//            }
//
//            // Print raw response for debugging
//            if let responseString = String(data: data, encoding: .utf8) {
//                print("📦 Raw response: \(responseString)")
//            }
//
//            do {
//                let response = try JSONDecoder().decode(RatingResponse.self, from: data)
//                print("✅ Successfully decoded rating submission response")
//                completion(.success(response))
//            } catch {
//                print("❌ Decoding error: \(error)")
//                completion(.failure(error))
//            }
//        }.resume()
//    }
//
//    func updateRatingByBooking(bookingId: Int, stars: Int, completion: @escaping (Result<RatingResponse, Error>) -> Void) {
//        let urlString = "http://10.211.55.7/BooknowAPI/api/ratings/update/bybooking/\(bookingId)"
//
//        print("🌐 Updating rating at URL: \(urlString)")
//        print("📤 Request data: stars=\(stars)")
//
//        guard let url = URL(string: urlString) else {
//            print("❌ Invalid URL: \(urlString)")
//            completion(.failure(NSError(domain: "Invalid URL", code: 0)))
//            return
//        }
//
//        var urlRequest = URLRequest(url: url)
//        urlRequest.httpMethod = "PUT"
//        urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
//
//        let updateRequest = UpdateRatingRequest(stars: stars)
//
//        do {
//            let jsonData = try JSONEncoder().encode(updateRequest)
//            urlRequest.httpBody = jsonData
//
//            // Print JSON being sent
//            if let jsonString = String(data: jsonData, encoding: .utf8) {
//                print("📤 JSON being sent: \(jsonString)")
//            }
//        } catch {
//            print("❌ Encoding error: \(error)")
//            completion(.failure(error))
//            return
//        }
//
//        URLSession.shared.dataTask(with: urlRequest) { data, response, error in
//            if let error = error {
//                print("❌ Network error: \(error.localizedDescription)")
//                completion(.failure(error))
//                return
//            }
//
//            if let httpResponse = response as? HTTPURLResponse {
//                print("📡 HTTP Status: \(httpResponse.statusCode)")
//            }
//
//            guard let data = data else {
//                print("❌ No data received")
//                completion(.failure(NSError(domain: "No data", code: 0)))
//                return
//            }
//
//            // Print raw response for debugging
//            if let responseString = String(data: data, encoding: .utf8) {
//                print("📦 Raw response: \(responseString)")
//            }
//
//            do {
//                let response = try JSONDecoder().decode(RatingResponse.self, from: data)
//                print("✅ Successfully decoded rating update response")
//                completion(.success(response))
//            } catch {
//                print("❌ Decoding error: \(error)")
//                completion(.failure(error))
//            }
//        }.resume()
//    }
//}
