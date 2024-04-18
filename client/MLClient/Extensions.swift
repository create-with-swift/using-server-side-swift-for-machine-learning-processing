//
//  Extensions.swift
//  MLClient
//
//  Created by Luca Palmese on 17/04/24.
//

import Foundation

// Function to append data to multipart/form-data body for URL Requests
extension Data {
    mutating func append(_ string: String) {
        if let data = string.data(using: .utf8) {
            append(data)
        }
    }
}
