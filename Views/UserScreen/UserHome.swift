//import SwiftUI
//
//struct UserHome: View {
//    @Binding var rootPath: NavigationPath
//    @EnvironmentObject var userVM: UserViewModel
//
//    @State private var restaurants: [Restaurant] = []
//    @State private var bookings: [Booking] = []
//    @State private var orders: [Order] = []
//    @State private var isLoading = true
//    @State private var errorMessage: String?
//    @State private var searchText = ""
//
//    private var filteredRestaurants: [Restaurant] {
//        if searchText.isEmpty {
//            return restaurants
//        } else {
//            return restaurants.filter { r in
//                r.name.localizedCaseInsensitiveContains(searchText) ||
//                r.location.localizedCaseInsensitiveContains(searchText) ||
//                r.category.localizedCaseInsensitiveContains(searchText)
//            }
//        }
//    }
//
//    var body: some View {
//        TabView {
//            homeTab
//                .tabItem {
//                    Label("Home", systemImage: "house")
//                }
//
//            profileTab
//                .tabItem {
//                    Label("Profile", systemImage: "person.circle")
//                }
//        }
//        .onAppear {
//            fetchRestaurants()
//            fetchUserBookingsAndOrders()
//        }
//    }
//
//    // MARK: - Home Tab
//    private var homeTab: some View {
//        VStack {
//            SearchBar(text: $searchText)
//
//            if isLoading {
//                ProgressView("Loading restaurants...")
//                    .padding()
//            } else if let error = errorMessage {
//                Text("Error: \(error)")
//                    .foregroundColor(.red)
//                    .padding()
//            } else {
//                ScrollView {
//                    LazyVStack(spacing: 16) {
//                        ForEach(filteredRestaurants) { restaurant in
//                            RestaurantCardView(
//                                restaurant: restaurant,
////                                onMenuTap: {
////                                    rootPath.append(AppRoute.booking(restaurantId: restaurant.id))
////                                },
//                                onCardTap: {
//                                    rootPath.append(AppRoute.booking(restaurantId: restaurant.id))
//                                }
//                            )
//                        }
//                    }
//                    .padding()
//                }
//            }
//        }
//    }
//
//    // MARK: - Profile Tab
//    private var profileTab: some View {
//        ProfileView(bookings: $bookings, orders: $orders)
//            .environmentObject(userVM)
//    }
//
//    // MARK: - API Calls
//    private func fetchRestaurants() {
//        APIService.shared.fetchRestaurants { result in
//            DispatchQueue.main.async {
//                isLoading = false
//                switch result {
//                case .success(let res):
//                    restaurants = res
//                case .failure(let err):
//                    errorMessage = err.localizedDescription
//                }
//            }
//        }
//    }
//
//    private func fetchUserBookingsAndOrders() {
//        guard let userId = userVM.user?.userId else { return }
//
//        APIService.shared.getUserBookings(userId: userId) { result in
//            DispatchQueue.main.async {
//                if case .success(let res) = result {
//                    bookings = res
//                }
//            }
//        }
//
//        APIService.shared.getUserOrders(userId: userId) { result in
//            DispatchQueue.main.async {
//                if case .success(let res) = result {
//                    orders = res
//                }
//            }
//        }
//    }
//}
//


//
//
//Rating show ho rhi hain isky lia  resturntcard wla comment krna h phr apiservice mn ja k fetchRestaurants()wla hide krna hai or error wla last mn wo b or model mn restaurant ka model b

import SwiftUI

struct UserHome: View {
    @Binding var rootPath: NavigationPath
    @EnvironmentObject var userVM: UserViewModel

    @State private var restaurants: [Restaurant] = []
    @State private var bookings: [Booking] = []
    @State private var orders: [Order] = []
    @State private var isLoading = true
    @State private var errorMessage: String?
    @State private var searchText = ""

    private var filteredRestaurants: [Restaurant] {
        if searchText.isEmpty {
            return restaurants.sorted { $0.averageRating > $1.averageRating } // Sort by rating
        } else {
            return restaurants.filter { r in
                r.name.localizedCaseInsensitiveContains(searchText) ||
                r.location.localizedCaseInsensitiveContains(searchText) ||
                r.category.localizedCaseInsensitiveContains(searchText)
            }
            .sorted { $0.averageRating > $1.averageRating }
        }
    }

    var body: some View {
        TabView {
            homeTab
                .tabItem {
                    Label("Home", systemImage: "house")
                }

            profileTab
                .tabItem {
                    Label("Profile", systemImage: "person.circle")
                }
        }
        .onAppear {
            fetchRestaurants()
            fetchUserBookingsAndOrders()
        }
        .refreshable {
            await refreshData()
        }
    }

    // MARK: - Home Tab
    private var homeTab: some View {
        VStack {
            // Search Bar
            HStack {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(.gray)

                TextField("Search restaurants...", text: $searchText)
                    .textFieldStyle(RoundedBorderTextFieldStyle())

                if !searchText.isEmpty {
                    Button(action: { searchText = "" }) {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(.gray)
                    }
                }
            }
            .padding(.horizontal)
            .padding(.top, 8)

            // Restaurant Count
            if !isLoading && errorMessage == nil {
                Text("\(filteredRestaurants.count) restaurants found")
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .padding(.top, 4)
            }

            // Content
            if isLoading {
                Spacer()
                ProgressView("Loading restaurants...")
                    .padding()
                Spacer()
            } else if let error = errorMessage {
                Spacer()
                VStack(spacing: 16) {
                    Image(systemName: "exclamationmark.triangle")
                        .font(.largeTitle)
                        .foregroundColor(.red)

                    Text("Error loading restaurants")
                        .font(.headline)

                    Text(error)
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)

                    Button("Try Again") {
                        isLoading = true
                        fetchRestaurants()
                    }
                    .buttonStyle(.bordered)
                }
                .padding()
                Spacer()
            } else if restaurants.isEmpty {
                Spacer()
                VStack(spacing: 16) {
                    Image(systemName: "fork.knife")
                        .font(.largeTitle)
                        .foregroundColor(.gray)

                    Text("No restaurants available")
                        .font(.headline)

                    Text("Check back later for new restaurants")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                .padding()
                Spacer()
            } else {
                ScrollView {
                    LazyVStack(spacing: 16) {
                        ForEach(filteredRestaurants) { restaurant in
                            RestaurantCardView(
                                restaurant: restaurant,
                                onCardTap: {
                                    rootPath.append(AppRoute.booking(restaurantId: restaurant.id))
                                }
                            )
                        }
                    }
                    .padding()
                }
            }
        }
    }

    // MARK: - Profile Tab
    private var profileTab: some View {
        ProfileView(bookings: $bookings, orders: $orders)
            .environmentObject(userVM)
    }

    // MARK: - API Calls
    private func fetchRestaurants() {
        APIService.shared.fetchRestaurants { result in
            DispatchQueue.main.async {
                isLoading = false
                switch result {
                case .success(let res):
                    restaurants = res
                    print("✅ Loaded \(res.count) restaurants with ratings")
                    if let first = res.first {
                        print("📊 Sample restaurant: \(first.name) - Rating: \(first.averageRating) (\(first.reviewCount) reviews)")
                    }
                case .failure(let err):
                    errorMessage = err.localizedDescription
                    print("❌ Error loading restaurants: \(err.localizedDescription)")
                }
            }
        }
    }

    private func fetchUserBookingsAndOrders() {
        guard let userId = userVM.user?.userId else { return }

        APIService.shared.getUserBookings(userId: userId) { result in
            DispatchQueue.main.async {
                if case .success(let res) = result {
                    bookings = res
                }
            }
        }

        APIService.shared.getUserOrders(userId: userId) { result in
            DispatchQueue.main.async {
                if case .success(let res) = result {
                    orders = res
                }
            }
        }
    }

    private func refreshData() async {
        await withCheckedContinuation { continuation in
            fetchRestaurants()
            fetchUserBookingsAndOrders()
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                continuation.resume()
            }
        }
    }
}

// MARK: - RestaurantCardView with Ratings
struct RestaurantCardView: View {
    var restaurant: Restaurant
    var onCardTap: () -> Void
    let apiurl = APIConfig.imageBaseURL + "/"

    var body: some View {
        VStack(spacing: 0) {
            // Restaurant image
            AsyncImage(url: URL(string: apiurl + restaurant.imageUrl)) { phase in
                switch phase {
                case .empty:
                    Color.gray.opacity(0.2)
                        .overlay(ProgressView())
                case .success(let image):
                    image
                        .resizable()
                        .scaledToFill()
                case .failure:
                    Color.gray.opacity(0.2)
                        .overlay(
                            Image(systemName: "photo")
                                .foregroundColor(.gray)
                        )
                @unknown default:
                    EmptyView()
                }
            }
            .frame(height: 160)
            .clipped()

            VStack(alignment: .leading, spacing: 8) {
                // Name and Rating in one line
                HStack {
                    Text(restaurant.name)
                        .font(.headline)
                        .lineLimit(1)

                    Spacer()

                    // Rating display
                    RatingStarsView(rating: restaurant.averageRating, reviewCount: restaurant.reviewCount)
                }

                // Location and category
                VStack(alignment: .leading, spacing: 4) {
                    HStack {
                        Image(systemName: "mappin.circle.fill")
                            .font(.caption2)
                            .foregroundColor(.blue)

                        Text(restaurant.location)
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .lineLimit(1)
                    }

                    Text(restaurant.category.uppercased())
                        .font(.system(size: 10, weight: .semibold))
                        .foregroundColor(.white)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(LinearGradient(gradient: Gradient(colors: [Color.blue, Color.purple]), startPoint: .leading, endPoint: .trailing))
                        .cornerRadius(6)
                }
            }
            .padding()

            // Menu button
            NavigationLink(destination: MenuBeforeBooking(restaurantId: restaurant.id)) {
                HStack {
                    Image(systemName: "menucard.fill")
                    Text("View Menu")
                        .fontWeight(.semibold)
                }
                .frame(maxWidth: .infinity)
                .frame(height: 40)
                .background(LinearGradient(gradient: Gradient(colors: [Color.orange, Color.red]), startPoint: .leading, endPoint: .trailing))
                .foregroundColor(.white)
            }
        }
        .background(Color.white)
        .cornerRadius(16)
        .shadow(color: .gray.opacity(0.2), radius: 10, x: 0, y: 5)
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color.gray.opacity(0.1), lineWidth: 1)
        )
        .padding(.horizontal, 4)
        .onTapGesture {
            onCardTap()
        }
    }
}

// MARK: - RatingStarsView Component
struct RatingStarsView: View {
    let rating: Double
    let reviewCount: Int
    let maxRating: Int = 5

    var body: some View {
        HStack(spacing: 4) {
            // Stars
            HStack(spacing: 1) {
                ForEach(1...maxRating, id: \.self) { index in
                    Image(systemName: starType(for: index))
                        .foregroundColor(.yellow)
                        .font(.system(size: 12))
                }
            }

            // Rating number
            Text(String(format: "%.1f", rating))
                .font(.system(size: 14, weight: .bold))
                .foregroundColor(.orange)

            // Review count
            if reviewCount > 0 {
                Text("(\(reviewCount))")
                    .font(.system(size: 12))
                    .foregroundColor(.secondary)
            }
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .background(Color.yellow.opacity(0.1))
        .cornerRadius(8)
    }

    private func starType(for index: Int) -> String {
        let doubleIndex = Double(index)

        if doubleIndex <= rating {
            return "star.fill"
        } else if doubleIndex - rating <= 0.5 {
            return "star.leadinghalf.fill"
        } else {
            return "star"
        }
    }
}

// MARK: - Restaurant Model
struct Restaurant: Codable, Identifiable {
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

// MARK: - APIService Extension
private let baseURL = APIConfig.baseURL

extension APIService {
    func fetchRestaurants(completion: @escaping (Result<[Restaurant], Error>) -> Void) {
        guard let url = URL(string: "\(baseURL)/restaurants/allR") else {
            completion(.failure(APIError1.invalidURL))
            return
        }

        print("🌐 Fetching restaurants from: \(url.absoluteString)")

        URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                print("❌ Network error: \(error.localizedDescription)")
                DispatchQueue.main.async {
                    completion(.failure(error))
                }
                return
            }

            guard let httpResponse = response as? HTTPURLResponse else {
                DispatchQueue.main.async {
                    completion(.failure(APIError1.invalidResponse))
                }
                return
            }

            print("📡 Response status: \(httpResponse.statusCode)")

            guard (200...299).contains(httpResponse.statusCode) else {
                let errorMessage = HTTPURLResponse.localizedString(forStatusCode: httpResponse.statusCode)
                print("❌ Server error: \(httpResponse.statusCode) - \(errorMessage)")
                DispatchQueue.main.async {
                    completion(.failure(APIError1.serverError(statusCode: httpResponse.statusCode)))
                }
                return
            }

            guard let data = data else {
                print("❌ No data received")
                DispatchQueue.main.async {
                    completion(.failure(APIError1.noData))
                }
                return
            }

            // Print raw response for debugging
            if let jsonString = String(data: data, encoding: .utf8) {
                print("📦 Raw response received (first 300 chars): \(String(jsonString.prefix(300)))...")
            }

            do {
                let decoder = JSONDecoder()
                let restaurants = try decoder.decode([Restaurant].self, from: data)
                print("✅ Successfully decoded \(restaurants.count) restaurants")

                DispatchQueue.main.async {
                    completion(.success(restaurants))
                }
            } catch let decodingError {
                print("❌ Decoding error: \(decodingError)")

                // Try to see what's in the response
                if let jsonString = String(data: data, encoding: .utf8) {
                    print("🔍 Full response: \(jsonString)")
                }

                DispatchQueue.main.async {
                    completion(.failure(decodingError))
                }
            }
        }.resume()
    }
}

enum APIError1: Error, LocalizedError {
    case invalidURL
    case invalidResponse
    case noData
    case serverError(statusCode: Int)

    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "Invalid URL"
        case .invalidResponse:
            return "Invalid response from server"
        case .noData:
            return "No data received"
        case .serverError(let statusCode):
            return "Server error: \(statusCode)"
        }
    }
}
