import SwiftUI

struct JukeboxRequest: Identifiable, Codable {
    let jukeboxId: Int
    let userId: Int
    let userName: String
    let tableName: String
    let musicTitle: String
    let bookingDateTime: String
    let requestedAt: String
    let coinsSpent: Int
    let dedicationNote: String?
    let coinCategory: String
    
    var id: Int { jukeboxId }
}

enum JukeboxFilter: String, CaseIterable {
    case today = "Today"
//    case past = "Past"
    case future = "Future"
}

struct JukeboxView: View {
    let adminUserId: Int
    @State private var requests: [JukeboxRequest] = []
    @State private var isLoading = true
    @State private var errorMessage: String?
    @State private var selectedFilter: JukeboxFilter = .today

    var body: some View {
        NavigationView {
            VStack {
                // MARK: - Filter Picker
                Picker("Filter", selection: $selectedFilter) {
                    ForEach(JukeboxFilter.allCases, id: \.self) { filter in
                        Text(filter.rawValue)
                    }
                }
                .pickerStyle(.segmented)
                .padding(.horizontal)

                // MARK: - Main Content
                if isLoading {
                    ProgressView("Loading Jukebox Queue...")
                        .padding(.top, 100)
                } else if let errorMessage = errorMessage {
                    Text("⚠️ \(errorMessage)")
                        .foregroundColor(.red)
                        .padding()
                } else if filteredRequests.isEmpty {
                    Text("🎶 No \(selectedFilter.rawValue.lowercased()) jukebox requests.")
                        .foregroundColor(.gray)
                        .padding(.top, 100)
                } else {
                    List(filteredRequests) { req in
                        VStack(alignment: .leading, spacing: 6) {
                            HStack {
                                Text(req.musicTitle)
                                    .font(.headline)
                                Spacer()
                                Text(req.coinCategory)
                                    .font(.caption)
                                    .padding(6)
                                    .background(categoryColor(req.coinCategory))
                                    .cornerRadius(8)
                                    .foregroundColor(.white)
                            }

                            Text("🎤 \(req.userName) @ \(req.tableName)")
                                .font(.subheadline)
                                .foregroundColor(.secondary)

                            Text("🕒 \(formatDate(req.bookingDateTime))")
                                .font(.caption)
                                .foregroundColor(.gray)

                            if let note = req.dedicationNote, !note.isEmpty {
                                Text("💌 \(note)")
                                    .font(.caption)
                                    .foregroundColor(.orange)
                            }
                        }
                        .padding(.vertical, 4)
                    }
                    .listStyle(.inset)
                }
            }
            .navigationTitle("🎧 Jukebox Queue")
            .task {
                await fetchJukeboxQueue()
            }
        }
    }

    // MARK: - Filtered Requests
    var filteredRequests: [JukeboxRequest] {
        let calendar = Calendar.current
        let todayStart = calendar.startOfDay(for: Date())
        let todayEnd = calendar.date(byAdding: .day, value: 1, to: todayStart)!

        return requests.filter { req in
            guard let date = dateFormatter.date(from: req.bookingDateTime) else {
                print("Failed to parse date: \(req.bookingDateTime)")
                return false
            }

            switch selectedFilter {
            case .today:
                return date >= todayStart && date < todayEnd
//            case .past:
//                return date < todayStart
            case .future:
                return date >= todayEnd
            }
        }
        .sorted { lhs, rhs in
            let lhsDate = dateFormatter.date(from: lhs.bookingDateTime) ?? .distantPast
            let rhsDate = dateFormatter.date(from: rhs.bookingDateTime) ?? .distantPast
            if lhsDate == rhsDate {
                return coinPriority(lhs.coinCategory) > coinPriority(rhs.coinCategory)
            }
            return lhsDate < rhsDate
        }
    }

    // MARK: - API Fetch
    func fetchJukeboxQueue() async {
        guard let url = APIConfig.url(for: .adminGetJukeboxQueue(adminUserId)) else {
            errorMessage = "Invalid API URL."
            isLoading = false
            return
        }

        do {
            let (data, response) = try await URLSession.shared.data(from: url)
            if let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode != 200 {
                errorMessage = "Server returned error code \(httpResponse.statusCode)"
                isLoading = false
                return
            }

            let decoded = try JSONDecoder().decode([JukeboxRequest].self, from: data)
            await MainActor.run {
                self.requests = decoded
                self.isLoading = false
            }
        } catch {
            await MainActor.run {
                self.errorMessage = "Failed to load jukebox queue: \(error.localizedDescription)"
                self.isLoading = false
            }
        }
    }

    // MARK: - Date Formatter
    var dateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.timeZone = TimeZone.current
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss" // matches your API
        return formatter
    }

    // MARK: - Helpers
    func formatDate(_ dateStr: String) -> String {
        if let date = dateFormatter.date(from: dateStr) {
            let formatter = DateFormatter()
            formatter.dateFormat = "MMM d, h:mm a"
            return formatter.string(from: date)
        }
        return dateStr
    }

    func categoryColor(_ category: String) -> Color {
        switch category {
        case "Platinum": return .purple
        case "Diamond": return .blue
        case "Gold": return .orange
        default: return .gray
        }
    }

    func coinPriority(_ category: String) -> Int {
        switch category {
        case "Platinum": return 3
        case "Diamond": return 2
        case "Gold": return 1
        default: return 0
        }
    }
}
