//
//  UserModel.swift
//  RestAdvApp
//
//  Created by Matti Ullah on 29/07/2025.
//

import Foundation

struct RegisterRequest: Codable {
    let name: String
    let email: String
    let password: String
    let role: String
}

