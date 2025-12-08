//
//  Table.swift
//  RestAdvApp
//
//  Created by Matti Ullah on 03/08/2025.
//

import Foundation
struct Table: Codable, Identifiable {
    var id: Int { tableId }

    let tableId: Int
    let name: String
    let location: String
    let floor: Int
    let price: Double
    let status: String
    let capacity: Int
    let restaurantId: Int
}
