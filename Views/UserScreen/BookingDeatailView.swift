import SwiftUI

struct BookingDetailView: View {
    let booking: Booking
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Group {
                Text("Restaurant: \(booking.restaurantName)")
                Text("Booking Date: \(formatDate(booking.bookingDateTime))")
                Text("Table ID: \(booking.tableId)")
                Text("Status: \(booking.status)")
                    .foregroundColor(booking.status == "Booked" ? .green : .red)
                if !booking.specialRequest.isEmpty {
                    Text("Special Request: \(booking.specialRequest)")
                        .italic()
                }
            }
            .padding(.horizontal)
            
            Spacer()
        }
        .navigationTitle("Booking Details")
        .navigationBarTitleDisplayMode(.inline)
    }
    
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
