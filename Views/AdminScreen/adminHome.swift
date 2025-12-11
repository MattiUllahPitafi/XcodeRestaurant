import SwiftUI

struct adminHome: View {
    @EnvironmentObject var userVM: UserViewModel
    @State private var isLoading = true
    
    // 🎨 App Theme Colors
    let themeOrange = Color.orange
    let themeYellow = Color.yellow.opacity(0.85)
    let themeGreen = Color.green
    let themeWhite = Color.white
    
    var body: some View {
        NavigationView {
            ZStack {
                // 🌈 Gradient Background
                LinearGradient(
                    gradient: Gradient(colors: [themeOrange, themeYellow, themeGreen.opacity(0.4)]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
                
                VStack(spacing: 20) {
                    // ✅ Top User Info Card
                    if let user = userVM.user {
                        VStack(spacing: 8) {
                            Text("👤 \(user.name)")
                                .font(.title2)
                                .fontWeight(.bold)
                                .foregroundColor(themeWhite)
                            
                            Text(user.email)
                                .font(.subheadline)
                                .foregroundColor(themeWhite.opacity(0.9))
                            
                            if let restaurantId = userVM.restaurantId {
                                Text("🏢 Restaurant ID: \(restaurantId)")
                                    .font(.headline)
                                    .foregroundColor(themeWhite)
                            }
                        }
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(themeGreen.opacity(0.9))
                        .cornerRadius(20)
                        .shadow(color: .black.opacity(0.3), radius: 5, x: 0, y: 4)
                        .padding(.horizontal)
                    }
                    
                    // ✅ Admin Dashboard Options
                    ScrollView {
                        VStack(spacing: 20) {
                            NavigationLink(destination: MenueAdmin(userId: userVM.user!.userId)) {
                                DashboardCard(icon: "fork.knife", title: "📋 Menu Management", bgColor: themeWhite, accent: themeOrange)
                            }
                            
                            NavigationLink(destination: ShowChef(adminUserId: userVM.user?.userId ?? 0)) {
                                DashboardCard(icon: "person.2", title: "👨‍🍳 Manage Chefs", bgColor: themeWhite, accent: themeGreen)
                            }
                            
                            NavigationLink(destination: showTable(adminUserId: userVM.user?.userId ?? 0)) {
                                DashboardCard(icon: "table", title: "🍽 Manage Tables", bgColor: themeWhite, accent: themeYellow)
                            }
                            
                            NavigationLink(destination: JukeboxView(adminUserId: userVM.user?.userId ?? 0)) {
                                DashboardCard(icon: "music.note", title: "🎧 Music Jukebox", bgColor: themeWhite, accent: themeOrange)
                            }
                            
                            NavigationLink(destination:ShowWaiter(adminUserId:userVM.user?.userId ?? 0).environmentObject(userVM)) {
                              DashboardCard(icon: "person.3", title: "👨‍🍳 Manage             Waiters", bgColor: themeWhite, accent: themeGreen)
                             }
//                            .padding(.horizontal)
                            NavigationLink(destination: OrdersAndBookings(adminUserId: userVM.user?.userId ?? 0)) {
                                DashboardCard(icon: "fork.knife", title: "📦Orders and 🪑Bookings", bgColor: themeWhite, accent: themeOrange)
                            }
                            
                        }
                    }
                    .padding(.vertical)
                }
                .navigationTitle("🏠 Admin Dashboard")
                .navigationBarTitleDisplayMode(.inline)
                .task {
                    if let user = userVM.user, user.isAdmin {
                        await userVM.fetchAdminRestaurant(userId: user.userId)
                    }
                    isLoading = false
                }
            }
        }
    }
    
    // ✅ Reusable Dashboard Card with Theme
    struct DashboardCard: View {
        let icon: String
        let title: String
        let bgColor: Color
        let accent: Color
        
        var body: some View {
            HStack {
                Image(systemName: icon)
                    .font(.system(size: 26, weight: .medium))
                    .foregroundColor(accent)
                    .frame(width: 45)
                
                Text(title)
                    .font(.headline)
                    .foregroundColor(.black)
                
                Spacer()
                
                Image(systemName: "chevron.right.circle.fill")
                    .foregroundColor(accent)
            }
            .padding()
            .frame(maxWidth: .infinity)
            .background(bgColor.opacity(0.95))
            .cornerRadius(18)
            .shadow(color: accent.opacity(0.3), radius: 4, x: 0, y: 3)
            .overlay(
                RoundedRectangle(cornerRadius: 18)
                    .stroke(accent.opacity(0.4), lineWidth: 1)
            )
        }
    }
}
