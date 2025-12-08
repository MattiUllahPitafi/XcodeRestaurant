import SwiftUI

@main
struct FYPApp: App {
    @StateObject private var userVM = UserViewModel()
    @StateObject private var chefVM = ChefOrdersViewModel()   // <-- REQUIRED

    @State private var path = NavigationPath()

    var body: some Scene {
        WindowGroup {
            NavigationStack(path: $path) {
                ContentView(path: $path)
                    .environmentObject(userVM)
                    .navigationDestination(for: AppRoute.self) { route in
                        switch route {
                        case .landing:
                            ContentView(path: $path)
                                .environmentObject(userVM)
                                .environmentObject(chefVM)     // <-- Inject ViewModel Globallyy


                        case .login:
                            LoginView(path: $path)
                                .environmentObject(userVM)

                        case .signup:
                            SignUpView(path: $path)
                                .environmentObject(userVM)

                        case .userHome:
                            UserHome(rootPath: $path)
                                .environmentObject(userVM)
                        case .adminHome:
                            adminHome()
                                .environmentObject(userVM)
                        
                        case.AppAdminDashboard:
                            AppAdminDashboard()
                                .environmentObject(userVM)

//                        case .chefView:
//                            chefView()
//                                .environmentObject(userVM)// Replace with ChefHomeView()
                        
                        case .ChefView:
                            ChefView(rootPath: $path)
                                .environmentObject(userVM)
                                .environmentObject(chefVM)   // <-- IMPORTANT


                        case .menu(let restaurantId, let bookingId):
                            MenuView(restaurantId: restaurantId, bookingId: bookingId)
                                .environmentObject(userVM)

                        case .profile:
                            EmptyView()
                        case .booking(let restaurantId):
                            BookingView(restaurantId: restaurantId, path: $path)
                                .environmentObject(userVM)
                        case .waiterDashboard:
                            WaiterDashboard(rootPath: $path)
                                .environmentObject(userVM)

                        case .WaiterHome:
                            WaiterHome(rootPath: $path)
                                .environmentObject(userVM)

                        
                        }
                    }
            }
        }
    }
}
