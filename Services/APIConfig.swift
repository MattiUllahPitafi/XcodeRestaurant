import Foundation

/// Global API Configuration - Single source of truth for all API endpoints
struct APIConfig {
    // MARK: - Base URLs
    static let baseURL = "http://10.211.55.7/BooknowAPI/api"
    static let imageBaseURL = "http://10.211.55.7"
    
    // MARK: - Endpoints
    enum Endpoint {
        // User endpoints
        case login
        case register
        case getUser(Int)
        case updateUser(Int)
        
        // Restaurant endpoints
        case restaurants
        case restaurant(Int)
        case restaurantImage(String)
        
        // Menu endpoints
        case menuByRestaurant(Int)
        
        // Booking endpoints
        case bookings
        case bookingsByUserId(Int)
        case createBooking
        case createMultipleBookings
        
        // Order endpoints
        case orders
        case orderByUser(Int)
        case addOrder
        case updateOrderStatus(Int)
        
        // Table endpoints
        case availableTables(Int, String)
        
        // Music endpoints
        case musicAll
        case musicByDay
        
        // Admin endpoints
        case adminBookingsAndOrders(Int)
        case adminCreateDish
        case adminGetTables(Int)
        case adminAddTable(Int)
        case adminGetWaiters(Int)
        case adminCreateWaiter(Int)
        case adminDeleteWaiter(Int, Int)
        case adminGetJukeboxQueue(Int)
        case adminGetByUser(Int)
        
        // Chef endpoints
        case chefOrders(Int)
        
        // Waiter endpoints
        case waiterAssignments(Int)
        case waiterServeOrder(Int)
        
        // Rating endpoints
        case checkRating(Int)
        case submitRating
        case updateRating(Int)
        
        var path: String {
            switch self {
            case .login: return "/Users/login"
            case .register: return "/Users/Register"
            case .getUser(let id): return "/Users/Get/\(id)"
            case .updateUser(let id): return "/Users/Update/\(id)"
            
            case .restaurants: return "/restaurants"
            case .restaurant(let id): return "/restaurants/\(id)"
            case .restaurantImage(let path): return "/\(path)"
            
            case .menuByRestaurant(let id): return "/menu/restaurant/\(id)"
            
            case .bookings: return "/Bookings"
            case .bookingsByUserId(let id): return "/bookings/byuserId/\(id)"
            case .createBooking: return "/Bookings/create"
            case .createMultipleBookings: return "/bookings/create-multiple"
            
            case .orders: return "/order"
            case .orderByUser(let id): return "/order/byUser/\(id)"
            case .addOrder: return "/order/add"
            case .updateOrderStatus(let id): return "/order/status/\(id)"
            
            case .availableTables(let restaurantId, let datetime): 
                return "/tables/available/\(restaurantId)?datetime=\(datetime)"
            
            case .musicAll: return "/Music/getall"
            case .musicByDay: return "/Music/byday"
            
            case .adminBookingsAndOrders(let id): 
                return "/admin/GetBookingsAndOrderByRestaurant/\(id)"
            case .adminCreateDish: return "/admin/CreateDish"
            case .adminGetTables(let id): return "/admin/GetTablesByAdmin/\(id)"
            case .adminAddTable(let id): return "/admin/AddTable/\(id)"
            case .adminGetWaiters(let id): return "/admin/GetWaitersForAdmin/\(id)"
            case .adminCreateWaiter(let id): return "/admin/CreateWaiter/\(id)"
            case .adminDeleteWaiter(let adminId, let waiterId): 
                return "/admin/DeleteWaiter/\(adminId)/\(waiterId)"
            case .adminGetJukeboxQueue(let id): return "/admin/GetJukeboxQueue/\(id)"
            case .adminGetByUser(let id): return "/Admins/GetByUser/\(id)"
            
            case .chefOrders(let id): return "/cheforder/byid/\(id)"
            
            case .waiterAssignments(let id): return "/waiters/byid/\(id)"
            case .waiterServeOrder(let id): return "/waiters/serve/\(id)"
            
            case .checkRating(let id): return "/ratings/check/booking/\(id)"
            case .submitRating: return "/ratings/submit/bybooking"
            case .updateRating(let id): return "/ratings/update/bybooking/\(id)"
            }
        }
        
        var url: URL? {
            switch self {
            case .restaurantImage(let path):
                return URL(string: "\(APIConfig.imageBaseURL)/\(path)")
            case .availableTables:
                return URL(string: "\(APIConfig.baseURL)\(path)")
            case .musicByDay:
                return URL(string: "\(APIConfig.baseURL)\(path)")
            default:
                return URL(string: "\(APIConfig.baseURL)\(path)")
            }
        }
    }
    
    // MARK: - Helper Methods
    static func url(for endpoint: Endpoint) -> URL? {
        return endpoint.url
    }
    
    static func imageURL(for path: String) -> URL? {
        return URL(string: "\(imageBaseURL)/\(path)")
    }
}

