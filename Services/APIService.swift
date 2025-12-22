import Foundation

class APIService {
    static let shared = APIService()
    
    private init() {}

    // MARK: - Login
    func loginUser(email: String, password: String, completion: @escaping (Result<LoginResponse, Error>) -> Void) {
        guard let url = APIConfig.url(for: .login) else {
            completion(.failure(APIError.invalidURL))
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        let body: [String: Any] = [
            "Email": email,
            "PasswordHash": password
        ]

        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: body)
        } catch {
            completion(.failure(error))
            return
        }

        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }

            guard let data = data,
                  let httpResponse = response as? HTTPURLResponse,
                  (200...299).contains(httpResponse.statusCode) else {
                completion(.failure(APIError.invalidResponse))
                return
            }

            do {
                let decoded = try JSONDecoder().decode(LoginResponse.self, from: data)
                completion(.success(decoded))
            } catch {
                completion(.failure(error))
            }
        }.resume()
    }
    
    func signupUser(name: String, email: String, password: String, completion: @escaping (Result<Bool, Error>) -> Void) {
        guard let url = APIConfig.url(for: .register) else {
            completion(.failure(URLError(.badURL)))
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")

        let params: [String: Any] = [
            "Name": name,
            "Email": email,
            "Password": password,
            "Role": "Customer"
        ]

        request.httpBody = try? JSONSerialization.data(withJSONObject: params)

        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }

            // ✅ Just check if status code is in 200–299 range
            if let httpResponse = response as? HTTPURLResponse, (200...299).contains(httpResponse.statusCode) {
                completion(.success(true))
            } else {
                completion(.success(false))
            }
        }.resume()
    }

//    func fetchRestaurants(completion: @escaping (Result<[Restaurant], Error>) -> Void) {
//        guard let url = URL(string: "\(baseURL)/restaurants/all") else {
//            completion(.failure(APIError.invalidURL))
//            return
//        }
//
//        URLSession.shared.dataTask(with: url) { data, response, error in
//            if let error = error {
//                completion(.failure(error))
//                return
//            }
//
//            guard let httpResponse = response as? HTTPURLResponse else {
//                completion(.failure(APIError.invalidResponse))
//                return
//            }
//
//            guard (200...299).contains(httpResponse.statusCode) else {
//                let errorMessage = HTTPURLResponse.localizedString(forStatusCode: httpResponse.statusCode)
//                print("❌ Server error: \(httpResponse.statusCode) - \(errorMessage)")
//                completion(.failure(APIError.invalidResponse))
//                return
//            }
//
//            guard let data = data else {
//                print("❌ No data received.")
//                completion(.failure(APIError.invalidResponse))
//                return
//            }
//
//            do {
//                let decoded = try JSONDecoder().decode([Restaurant].self, from: data)
//                completion(.success(decoded))
//            } catch {
//                print("❌ Decoding failed with error: \(error.localizedDescription)")
//                if let jsonStr = String(data: data, encoding: .utf8) {
//                    print("🔍 Raw response: \(jsonStr)")
//                }
//                completion(.failure(error))
//            }
//        }.resume()
//    }
//  
    func getUserBookings(userId: Int, completion: @escaping (Result<[Booking], Error>) -> Void) {
        guard let url = APIConfig.url(for: .bookingsByUserId(userId)) else { return }

            URLSession.shared.dataTask(with: url) { data, _, error in
                if let error = error {
                    completion(.failure(error))
                    return
                }

                if let data = data {
                    do {
                        let bookings = try JSONDecoder().decode([Booking].self, from: data)
                        completion(.success(bookings))
                    } catch {
                        completion(.failure(error))
                    }
                }
            }.resume()
        }

    // MARK: - Get User Orders
    func getUserOrders(userId: Int, completion: @escaping (Result<[Order], Error>) -> Void) {
        guard let url = APIConfig.url(for: .orderByUser(userId)) else { return }

            URLSession.shared.dataTask(with: url) { data, _, error in
                if let error = error {
                    completion(.failure(error))
                    return
                }

                if let data = data {
                    do {
                        let orders = try JSONDecoder().decode([Order].self, from: data)
                        completion(.success(orders))
                    } catch {
                        completion(.failure(error))
                    }
                }
        }.resume()
    }
}

// MARK: - API Error Types
enum APIError: Error {
    case invalidURL
    case invalidResponse
}

