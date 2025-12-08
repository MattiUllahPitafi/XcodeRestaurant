import SwiftUI
let apiurl = "http://10.211.55.7/"
struct RestaurantCardView: View {
    var restaurant: Restaurant
//    var onMenuTap: () -> Void
    var onCardTap: () -> Void

    var body: some View {
        VStack(spacing: 0) {
            // Restaurant image
            AsyncImage(url: URL(string: apiurl + restaurant.imageUrl)) { image in
                image.resizable()
            } placeholder: {
                Color.gray.opacity(0.2)
            }
            .frame(height: 160)
            .clipped()

            VStack(alignment: .leading, spacing: 6) {
                Text(restaurant.name)
                    .font(.headline)

                Text(restaurant.location)
                    .font(.subheadline)
                    .foregroundColor(.secondary)

                Text(restaurant.category)
                    .font(.subheadline)
                    .foregroundColor(.gray)
            }
            .padding()
          NavigationLink(destination: MenuBeforeBooking(restaurantId: restaurant.id)) {
                           Rectangle()
                               .fill(Color.orange)
                               .frame(height: 40)
                               .overlay(
                                   Text("View Menu")
                                       .foregroundColor(.white)
                                       .bold()
                               )
                       }
        }
        .background(Color.white)
        .cornerRadius(12)
        .shadow(radius: 3)
        .onTapGesture {
            onCardTap()
        }
    }
}
