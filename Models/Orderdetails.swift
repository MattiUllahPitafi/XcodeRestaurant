//
//  Orderdetails.swift
//  RestAdvApp
//
//  Created by Matti Ullah on 11/09/2025.
//

import Foundation

struct Order: Identifiable, Codable {
    var id: Int { orderId }   // for SwiftUI List/ForEach
    let orderId: Int
    let orderDate: String
    let totalPrice: Double
    let status: String
    let bookingId: Int
    let dishes: [DishInOrder]
}

struct DishInOrder: Identifiable, Codable {
    var id: Int { dishId }
    let dishId: Int
    let dishName: String
    let quantity: Int
}
