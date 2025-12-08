//
//import SwiftUI
//
//struct MusicItem: Identifiable, Codable {
//    let id: Int
//    let title: String
//    let artist: String
//    let genreName: String
//
//    enum CodingKeys: String, CodingKey {
//        case id = "musicId"
//        case title
//        case artist
//        case genreName
//    }
//}
//
//struct BookingResponse: Codable {
//    let bookingId: Int
//    let message: String
//}
//
//struct BookingView: View {
//    let restaurantId: Int
//    @Binding var path: NavigationPath
//    @EnvironmentObject var userVM: UserViewModel
//
//    @State private var selectedDate = Date()
//    @State private var tables: [Table] = []
//    @State private var isLoading = false
//    @State private var errorMessage: String?
//    @State private var selectedTable: Table?
//    @State private var selectedFloor: Int? = nil
//    @State private var showFloorList = false
//    let availableFloors = [1, 2, 3]
//
//    // Music
//    @State private var musicList: [MusicItem] = []
//    @State private var selectedMusicId: Int?
//    @State private var musicLoading = false
//    @State private var musicErrorMessage: String?
//    @State private var showMusicList = false
//
//    // Coin categories
//    let coinCategories = [
//        (id: 1, name: "Gold"),
//        (id: 2, name: "Diamond"),
//        (id: 3, name: "Platinum")
//    ]
//    @State private var selectedCoinCategoryId: Int?
//
//    // Booking
//    @State private var specialRequest = ""
//    @State private var isBooking = false
//    @State private var bookingMessage: String?
//    @State private var dedicationNote = ""
//    let calendar = Calendar.current
//    let today = Date()
//
//    var allowedRange: ClosedRange<Date> {
//        let start = today
//        let end = calendar.date(byAdding: .day, value: 10, to: today)!
//        return start...end
//    }
//
//    var body: some View {
//        VStack(spacing: 16) {
//            if selectedTable == nil {
//                HStack {
//
//
//                    DatePicker("Select Booking Time",
//                               selection: $selectedDate,
//                               in: allowedRange)
//                        .datePickerStyle(.compact)
//
//                    Spacer()
//
//                    Menu {
//                        ForEach(availableFloors, id: \.self) { floor in
//                            Button("Floor \(floor)") {
//                                selectedFloor = floor
//                            }
//                        }
//                    } label: {
//                        HStack {
//                            Text(selectedFloor != nil ? "Floor \(selectedFloor!)" : "Select Floor")
//                            Image(systemName: "chevron.down")
//                        }
//                        .padding(8)
//                        .background(Color(.systemGray6))
//                        .cornerRadius(8)
//                    }
//                }
//                .padding(.horizontal)
//
//                Button("Check Availability") {
//                    fetchTables(for: selectedDate)
//                }
//                .buttonStyle(.borderedProminent)
//                .padding(.bottom)
//
//                if isLoading {
//                    ProgressView("Loading tables...")
//                } else if let error = errorMessage {
//                    Text("Error: \(error)").foregroundColor(.red)
//                } else {
//                    FloorPlanStaticView(
//                        tables: tables,
//                        onSelect: { table in
//                            if table.status == "Available" {
//                                selectedTable = table
//                            }
//                        }
//                    )
//                    .frame(maxWidth: .infinity, maxHeight: .infinity)
//                }
//            } else {
//                VStack(alignment: .leading, spacing: 16) {
//                    Text("Booking Details").font(.title2).bold()
//
//                    Text("Table: \(selectedTable!.name)")
//                    Text("Location: \(selectedTable!.location)")
//                    Text("Person: \(selectedTable!.capacity)")
//                    Text("Price: \(selectedTable!.price, specifier: "%.0f") PKR")
//
//                    DatePicker("Booking Date & Time", selection: $selectedDate, in: Date()..., displayedComponents: [.date, .hourAndMinute])
//
////                    TextField("Special Request", text: $specialRequest)
////                        .textFieldStyle(RoundedBorderTextFieldStyle())
//                    VStack(alignment: .leading, spacing: 8) {
//                        Text("Special Request").font(.subheadline).foregroundColor(.gray)
//                        let options = ["Birthday", "Anniversary", "Graduation Party", "Proposals" ,  "None"]
//                        ForEach(options, id: \.self) { option in
//                            HStack {
//                                Image(systemName: specialRequest == option ? "largecircle.fill.circle" : "circle")
//                                    .foregroundColor(.blue)
//                                Text(option)
//                            }
//                            .onTapGesture {
//                                specialRequest = option
//                            }
//                            .padding(.vertical, 4)
//                        }
//                    }
//
//                    Toggle("Add Music", isOn: $showMusicList)
//                        .onChange(of: showMusicList) { value in
//                            if value && musicList.isEmpty {
//                                fetchMusicList()
//                            }
//                        }
//
//                    if showMusicList {
//                        if musicLoading {
//                            ProgressView("Loading music...")
//                        } else if let error = musicErrorMessage {
//                            Text(error).foregroundColor(.red)
//                        } else {
//                            Picker("Select Music", selection: $selectedMusicId) {
//                                Text("None").tag(nil as Int?)
//                                ForEach(musicList) { music in
//                                    Text("\(music.title) - \(music.artist)").tag(music.id as Int?)
//                                }
//                            }
//                            .pickerStyle(.wheel)
//
//                            if selectedMusicId != nil {
//                                Picker("Coin Category", selection: $selectedCoinCategoryId) {
//                                    Text("Select Coin").tag(nil as Int?)
//                                    ForEach(coinCategories, id: \.id) { coin in
//                                        Text(coin.name).tag(coin.id as Int?)
//                                    }
//                                }
//                                .pickerStyle(.segmented)
//                                TextField("Dedication Note (optional)", text: Binding(
//                                    get: { dedicationNote },
//                                    set: { dedicationNote = $0 }
//                                ))
//                                .textFieldStyle(RoundedBorderTextFieldStyle())
//                                .padding(.top, 8)
//                            }
//                        }
//                    }
//
//                    VStack {
//                        Button(action: confirmBooking) {
//                            HStack {
//                                if isBooking {
//                                    ProgressView().progressViewStyle(CircularProgressViewStyle(tint: .white))
//                                }
//                                Text(isBooking ? "Booking..." : "Confirm Booking")
//                                    .fontWeight(.semibold)
//                            }
//                            .frame(maxWidth: .infinity)
//                            .padding()
//                            .background(isBooking || userVM.user?.userId == nil ? Color.gray : Color.blue)
//                            .foregroundColor(.white)
//                            .cornerRadius(12)
//                            .shadow(radius: 4)
//                            .animation(.easeInOut, value: isBooking)
//                        }
//                        .disabled(isBooking || userVM.user?.userId == nil)
//                        if let message = bookingMessage {
//                            Text(message)
//                                .foregroundColor(.green)
//                                .padding(.top)
//                        }
//                    }
//                    .padding()
//                }
//            }
//        }
//        .navigationTitle("Book Table")
//    }
//
//    // MARK: - Fetch Tables
//    private func fetchTables(for date: Date) {
//        isLoading = true
//        errorMessage = nil
//
//        let isoFormatter = ISO8601DateFormatter()
//        isoFormatter.formatOptions = [.withInternetDateTime]
//        let dateString = isoFormatter.string(from: date)
//
//        var urlString = "http://10.211.55.7/BooknowAPI/api/tables/available/\(restaurantId)?datetime=\(dateString)"
//
//        if let floor = selectedFloor {
//            urlString += "&floor=\(floor)"
//        }
//
//        guard let url = URL(string: urlString) else {
//            errorMessage = "Invalid URL"
//            isLoading = false
//            return
//        }
//
//        URLSession.shared.dataTask(with: url) { data, _, error in
//            DispatchQueue.main.async {
//                isLoading = false
//                if let error = error {
//                    errorMessage = "Error: \(error.localizedDescription)"
//                    return
//                }
//                guard let data = data else {
//                    errorMessage = "No data received"
//                    return
//                }
//                do {
//                    tables = try JSONDecoder().decode([Table].self, from: data)
//                } catch {
//                    errorMessage = "Failed to decode tables: \(error.localizedDescription)"
//                }
//            }
//        }.resume()
//    }
//
//    // MARK: - Fetch Music
//    private func fetchMusicList() {
//        musicLoading = true
//        musicErrorMessage = nil
//
//        guard let url = URL(string: "http://10.211.55.7/BooknowAPI/api/Music/getall") else {
//            musicErrorMessage = "Invalid URL"
//            musicLoading = false
//            return
//        }
//
//        URLSession.shared.dataTask(with: url) { data, _, error in
//            DispatchQueue.main.async {
//                musicLoading = false
//                if let error = error {
//                    musicErrorMessage = "Error: \(error.localizedDescription)"
//                    return
//                }
//                guard let data = data else {
//                    musicErrorMessage = "No data received"
//                    return
//                }
//                do {
//                    musicList = try JSONDecoder().decode([MusicItem].self, from: data)
//                } catch {
//                    musicErrorMessage = "Failed to decode music: \(error.localizedDescription)"
//                }
//            }
//        }.resume()
//    }
//
//    // MARK: - Confirm Booking
//    private func confirmBooking() {
//        guard let userId = userVM.user?.userId else {
//            bookingMessage = "⚠️ Please log in first."
//            return
//        }
//        guard let table = selectedTable else {
//            bookingMessage = "⚠️ Please select a table."
//            return
//        }
//
//        isBooking = true
//        bookingMessage = nil
//
//        // ✅ Format booking date in local time (yyyy-MM-dd HH:mm:ss)
//        let formatter = DateFormatter()
//        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
//        formatter.timeZone = .current
//        let bookingDateString = formatter.string(from: selectedDate)
//
//        let bookingRequest: [String: Any?] = [
//            "userId": userId,
//            "tableId": table.tableId,
//            "bookingDateTime": bookingDateString,   // 👈 send formatted string
//            "specialRequest": specialRequest,
//            "status": "AutoBooked",
//            "restaurantId": restaurantId,
//            "music_Id": selectedMusicId,
//            "coinCategoryIdUsedForMusic": selectedCoinCategoryId,
//            "dedicationNote": dedicationNote
//
//        ]
//
//        guard let url = URL(string: "http://10.211.55.7/BooknowAPI/api/Bookings/create") else {
//            bookingMessage = "Invalid URL"
//            isBooking = false
//            return
//        }
//
//        var request = URLRequest(url: url)
//        request.httpMethod = "POST"
//        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
//
//        do {
//            request.httpBody = try JSONSerialization.data(withJSONObject: bookingRequest.compactMapValues { $0 })
//        } catch {
//            bookingMessage = "Failed to encode booking"
//            isBooking = false
//            return
//        }
//
//        URLSession.shared.dataTask(with: request) { data, response, error in
//            DispatchQueue.main.async {
//                isBooking = false
//                if let error = error {
//                    bookingMessage = "Error: \(error.localizedDescription)"
//                    return
//                }
//                guard let httpResponse = response as? HTTPURLResponse else {
//                    bookingMessage = "No response from server"
//                    return
//                }
//
//                if httpResponse.statusCode == 200 {
//                    bookingMessage = "✅ Booking confirmed successfully!"
//                    if let data = data,
//                       let bookingResponse = try? JSONDecoder().decode(BookingResponse.self, from: data) {
//                        path.append(AppRoute.menu(
//                            restaurantId: restaurantId,
//                            bookingId: bookingResponse.bookingId
//                        ))
//                    }
//                } else {
//                    bookingMessage = "Failed to confirm booking (Status: \(httpResponse.statusCode))"
//                }
//            }
//        }.resume()
//    }
//}
//
//working under
//

import SwiftUI

struct MusicItem: Identifiable, Codable {
    let id: Int
    let title: String
    let artist: String
    let genreName: String

    enum CodingKeys: String, CodingKey {
        case id = "musicId"
        case title
        case artist
        case genreName
    }
}

struct BookingResponse: Codable {
    let bookingId: Int
    let message: String
}

struct BookingView: View {
    let restaurantId: Int
    @Binding var path: NavigationPath
    @EnvironmentObject var userVM: UserViewModel

    @State private var selectedDate = Date()
    @State private var tables: [Table] = []
    @State private var isLoading = false
    @State private var errorMessage: String?
    @State private var selectedTable: Table?
    @State private var selectedFloor: Int? = nil
    @State private var showFloorList = false
    let availableFloors = [1, 2, 3]

    // Music
    @State private var musicList: [MusicItem] = []
    @State private var selectedMusicId: Int?
    @State private var musicLoading = false
    @State private var musicErrorMessage: String?
    @State private var showMusicList = false
    @State private var artistSearchText = "" // <--- State for Singer Filter

    // Coin categories
    let coinCategories = [
        (id: 1, name: "Gold"),
        (id: 2, name: "Diamond"),
        (id: 3, name: "Platinum")
    ]
    @State private var selectedCoinCategoryId: Int?

    // Booking
    @State private var specialRequest = ""
    @State private var isBooking = false
    @State private var bookingMessage: String?
    @State private var dedicationNote = ""
    let calendar = Calendar.current
    let today = Date()

    // ✅ Time Constraint: Start 2 hours from now, max 10 days out
    var allowedRange: ClosedRange<Date> {
        let now = Date()
        let calendar = Calendar.current

        // 1. START of the range: Current Time + 2 hours.
        let start = calendar.date(byAdding: .hour, value: 2, to: now)!

        // 2. END of the range: Today + 10 days.
        let end = calendar.date(byAdding: .day, value: 10, to: now)!

        return start...end
    }

    var body: some View {
        VStack(spacing: 16) {
            if selectedTable == nil {
                // --- TABLE SELECTION VIEW ---
                HStack {
                    DatePicker("Select Booking Time",
                               selection: $selectedDate,
                               in: allowedRange)
                        .datePickerStyle(.compact)

                    Spacer()

                    Menu {
                        ForEach(availableFloors, id: \.self) { floor in
                            Button("Floor \(floor)") {
                                selectedFloor = floor
                            }
                        }
                    } label: {
                        HStack {
                            Text(selectedFloor != nil ? "Floor \(selectedFloor!)" : "Select Floor")
                            Image(systemName: "chevron.down")
                        }
                        .padding(8)
                        .background(Color(.systemGray6))
                        .cornerRadius(8)
                    }
                }
                .padding(.horizontal)

                Button("Check Availability") {
                    fetchTables(for: selectedDate)
                }
                .buttonStyle(.borderedProminent)
                .padding(.bottom)

                if isLoading {
                    ProgressView("Loading tables...")
                } else if let error = errorMessage {
                    Text("Error: \(error)").foregroundColor(.red)
                } else {
                    // Assuming FloorPlanStaticView is defined elsewhere
                    //
                    FloorPlanStaticView(
                        tables: tables,
                        onSelect: { table in
                            if table.status == "Available" {
                                selectedTable = table
                            }
                        }
                    )
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                }
            } else {
                // --- BOOKING DETAILS VIEW ---
                ScrollView {
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Booking Details").font(.title2).bold()

                        Text("Table: \(selectedTable!.name)")
                        Text("Location: \(selectedTable!.location)")
                        Text("Person: \(selectedTable!.capacity)")
//                        Text("Price: \(selectedTable!.price, specifier: "%.0f") PKR")

                        DatePicker("Booking Date & Time", selection: $selectedDate, in: allowedRange, displayedComponents: [.date, .hourAndMinute])
                             // Ensure DatePicker uses the restricted range here too
                            .onChange(of: selectedDate) { _ in
                                // If user changes date, reset music selection as genre might change
                                if showMusicList {
                                    selectedMusicId = nil
                                    fetchMusicList() // Refetch for new date
                                }
                            }

                        VStack(alignment: .leading, spacing: 8) {
                            Text("Special Request").font(.subheadline).foregroundColor(.gray)
                            let options = ["Birthday", "Anniversary", "Graduation Party", "Proposals" , "None"]
                            ForEach(options, id: \.self) { option in
                                HStack {
                                    Image(systemName: specialRequest == option ? "largecircle.fill.circle" : "circle")
                                        .foregroundColor(.blue)
                                    Text(option)
                                }
                                .onTapGesture {
                                    specialRequest = option
                                }
                                .padding(.vertical, 4)
                            }
                        }

                        // --- MUSIC SECTION START ---
                        Toggle("Add Music", isOn: $showMusicList)
                            .onChange(of: showMusicList) { value in
                                if value {
                                    fetchMusicList() // Fetch immediately using selectedDate
                                }
                            }

                        if showMusicList {
                            VStack(alignment: .leading, spacing: 10) {

                                // 1. Artist Filter UI
                                HStack {
                                    TextField("Filter by Singer (e.g., Nusrat)", text: $artistSearchText)
                                        .textFieldStyle(RoundedBorderTextFieldStyle())
                                        .autocapitalization(.none)

                                    Button(action: {
                                        fetchMusicList() // Refetch with artist filter
                                    }) {
                                        Image(systemName: "magnifyingglass")
                                            .foregroundColor(.white)
                                            .padding(8)
                                            .background(Color.blue)
                                            .cornerRadius(8)
                                    }
                                }

                                if musicLoading {
                                    ProgressView("Loading music...")
                                } else if let error = musicErrorMessage {
                                    Text(error).foregroundColor(.red).font(.caption)
                                } else {
                                    // 2. Music Picker
                                    if musicList.isEmpty {
                                        Text("No music found for this date/artist.").font(.caption).foregroundColor(.gray)
                                    } else {
                                        Picker("Select Music", selection: $selectedMusicId) {
                                            Text("Select Song").tag(nil as Int?)
                                            ForEach(musicList) { music in
                                                Text("\(music.title) - \(music.artist) (\(music.genreName))").tag(music.id as Int?)
                                            }
                                        }
                                        .pickerStyle(.wheel)
                                    }

                                    // 3. Coin & Dedication (Only show if music selected)
                                    if selectedMusicId != nil {
                                        Text("Select Coin to Pay (10 Coins)").font(.caption).foregroundColor(.gray)
                                        Picker("Coin Category", selection: $selectedCoinCategoryId) {
                                            Text("Select Coin").tag(nil as Int?)
                                            ForEach(coinCategories, id: \.id) { coin in
                                                Text(coin.name).tag(coin.id as Int?)
                                            }
                                        }
                                        .pickerStyle(.segmented)

                                        TextField("Dedication Note (optional)", text: Binding(
                                            get: { dedicationNote },
                                            set: { dedicationNote = $0 }
                                        ))
                                        .textFieldStyle(RoundedBorderTextFieldStyle())
                                        .padding(.top, 8)
                                    }
                                }
                            }
                            .padding()
                            .background(Color(.systemGray6))
                            .cornerRadius(10)
                        }
                        // --- MUSIC SECTION END ---

                        VStack {
                            Button(action: confirmBooking) {
                                HStack {
                                    if isBooking {
                                        ProgressView().progressViewStyle(CircularProgressViewStyle(tint: .white))
                                    }
                                    Text(isBooking ? "Booking..." : "Confirm Booking")
                                        .fontWeight(.semibold)
                                }
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(isBooking || userVM.user?.userId == nil ? Color.gray : Color.blue)
                                .foregroundColor(.white)
                                .cornerRadius(12)
                                .shadow(radius: 4)
                                .animation(.easeInOut, value: isBooking)
                            }
                            .disabled(isBooking || userVM.user?.userId == nil)
                            if let message = bookingMessage {
                                Text(message)
                                    .foregroundColor(message.contains("Error") || message.contains("Failed") || message.contains("⚠️") ? .red : .green)
                                    .padding(.top)
                                    .multilineTextAlignment(.center)
                            }
                        }
                        .padding()
                    }
                    .padding()
                }
            }
        }
        .navigationTitle("Book Table")
    }

    // MARK: - Fetch Tables
    private func fetchTables(for date: Date) {
        isLoading = true
        errorMessage = nil

        let isoFormatter = ISO8601DateFormatter()
        isoFormatter.formatOptions = [.withInternetDateTime]
        let dateString = isoFormatter.string(from: date)

        var urlString = "http://10.211.55.7/BooknowAPI/api/tables/available/\(restaurantId)?datetime=\(dateString)"

        if let floor = selectedFloor {
            urlString += "&floor=\(floor)"
        }

        guard let url = URL(string: urlString) else {
            errorMessage = "Invalid URL"
            isLoading = false
            return
        }

        URLSession.shared.dataTask(with: url) { data, _, error in
            DispatchQueue.main.async {
                isLoading = false
                if let error = error {
                    errorMessage = "Error: \(error.localizedDescription)"
                    return
                }
                guard let data = data else {
                    errorMessage = "No data received"
                    return
                }
                do {
                    // Assuming 'Table' struct is defined elsewhere
                    tables = try JSONDecoder().decode([Table].self, from: data)
                } catch {
                    errorMessage = "Failed to decode tables: \(error.localizedDescription)"
                }
            }
        }.resume()
    }

    // MARK: - Fetch Music (UPDATED to pass Day of Week)
    private func fetchMusicList() {
        musicLoading = true
        musicErrorMessage = nil
        selectedMusicId = nil // Ensure music selection is reset when refetching
        musicList = [] // Clear existing list while loading

        // 1. Prepare the Day of the Week string for the API
        let weekdayFormatter = DateFormatter()
        // Use "EEEE" to get the full day name (e.g., "Friday")
        weekdayFormatter.dateFormat = "EEEE"
        let dayOfWeekString = weekdayFormatter.string(from: selectedDate) // e.g., "Friday"

        // 2. Build URL with Query Parameters using URLComponents
        var components = URLComponents(string: "http://10.211.55.7/BooknowAPI/api/Music/byday")!

        var queryItems = [
            // Pass the day of the week string as the 'day' parameter
            URLQueryItem(name: "day", value: dayOfWeekString)
        ]

        // 3. Add Artist Filter if provided
        if !artistSearchText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            queryItems.append(URLQueryItem(name: "artistName", value: artistSearchText))
        }

        components.queryItems = queryItems

        guard let url = components.url else {
            musicErrorMessage = "Invalid URL"
            musicLoading = false
            return
        }

        // 4. Make Request
        URLSession.shared.dataTask(with: url) { data, response, error in
            DispatchQueue.main.async {
                musicLoading = false

                if let error = error {
                    musicErrorMessage = "Error: \(error.localizedDescription)"
                    return
                }

                guard let httpResponse = response as? HTTPURLResponse else {
                    musicErrorMessage = "No response"
                    return
                }

                // Safely unwrap data once at the top of the processing flow
                guard let data = data else {
                    musicErrorMessage = "No data received"
                    return
                }

                // Handle 404 specifically (No music found for that day/artist)
                if httpResponse.statusCode == 404 {
                    if let errStr = String(data: data, encoding: .utf8) {
                        musicErrorMessage = errStr.replacingOccurrences(of: "\"", with: "")
                    } else {
                        musicErrorMessage = "No music found for this date/artist."
                    }
                    return
                }

                // Handle non-404 errors (like 400 Bad Request)
                guard httpResponse.statusCode == 200 else {
                    if let errStr = String(data: data, encoding: .utf8) {
                        musicErrorMessage = "Server Error (\(httpResponse.statusCode)): \(errStr.replacingOccurrences(of: "\"", with: ""))"
                    } else {
                        musicErrorMessage = "Failed to load music (Status: \(httpResponse.statusCode))"
                    }
                    return
                }

                do {
                    musicList = try JSONDecoder().decode([MusicItem].self, from: data)
                } catch {
                    musicErrorMessage = "Failed to decode music: \(error.localizedDescription)"
                }
            }
        }.resume()
    }

    // MARK: - Confirm Booking
    private func confirmBooking() {
        guard let userId = userVM.user?.userId else {
            bookingMessage = "⚠️ Please log in first."
            return
        }
        guard let table = selectedTable else {
            bookingMessage = "⚠️ Please select a table."
            return
        }

        isBooking = true
        bookingMessage = nil

        // Format booking date
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        formatter.timeZone = .current
        let bookingDateString = formatter.string(from: selectedDate)

        let bookingRequest: [String: Any?] = [
            "userId": userId,
            "tableId": table.tableId,
            "bookingDateTime": bookingDateString,
            "specialRequest": specialRequest,
            "status": "AutoBooked",
            "restaurantId": restaurantId,
            "music_Id": selectedMusicId,
            "coinCategoryIdUsedForMusic": selectedCoinCategoryId,
            "dedicationNote": dedicationNote
        ]

        guard let url = URL(string: "http://10.211.55.7/BooknowAPI/api/Bookings/create") else {
            bookingMessage = "Invalid URL"
            isBooking = false
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: bookingRequest.compactMapValues { $0 })
        } catch {
            bookingMessage = "Failed to encode booking"
            isBooking = false
            return
        }

        URLSession.shared.dataTask(with: request) { data, response, error in
            DispatchQueue.main.async {
                isBooking = false

                if let error = error {
                    bookingMessage = "Error: \(error.localizedDescription)"
                    return
                }

                guard let httpResponse = response as? HTTPURLResponse else {
                    bookingMessage = "No response from server"
                    return
                }

                // ⭐️ FIX APPLIED HERE: Data is guaranteed to be optional (Data?) from the closure parameter.
                // We use optional chaining and conditional binding correctly.
                if httpResponse.statusCode == 200 {
                    bookingMessage = "✅ Booking confirmed successfully!"


                    if let data = data,
                       let bookingResponse = try? JSONDecoder().decode(BookingResponse.self, from: data) {

                        // Delay slightly so user sees success message
                        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                            path.append(AppRoute.menu(
                                restaurantId: restaurantId,
                                bookingId: bookingResponse.bookingId
                            ))
                        }
                    } else {
                        // This handles cases where status 200 is received, but the response body is empty or malformed.
                         bookingMessage = "Failed to decode success message from server."
                    }
                } else {
                    // Try to read error message from server body
                    if let data = data, let errStr = String(data: data, encoding: .utf8) {
                        // Clean up error string (remove quotes if raw string)
                        bookingMessage = "Failed: \(errStr.replacingOccurrences(of: "\"", with: ""))"
                    } else {
                        bookingMessage = "Failed to confirm booking (Status: \(httpResponse.statusCode))"
                    }
                }
            }
        }.resume()
    }
}
