//
//  APIManager.swift
//  MLClient
//
//  Created by Luca Palmese on 17/04/24.
//

import Foundation
import UIKit

class APIManager {
    
    static let shared = APIManager() // Shared instance
    
    private init() {}
    
    func classifyImage(_ image: UIImage) async throws -> [ClassificationResult] {
        
        // This is the URL of your host's IP address: for the moment we are using localhost for proving the concept, but remember to change it with the real host's IP address when you will run the app on a real host
        guard let requestURL = URL(string: "http://localhost:8080/mobilenetv2") else {
            throw URLError(.badURL)
        }
        
        // Convert image to JPEG with a compressionQuality value of 1 (0 - best quality)
        guard let imageData = image.jpegData(compressionQuality: 1) else {
            throw URLError(.unknown)
        }
        
        // Boundary string with UUID for uploading the image in the URLRequest
        let boundary = "Boundary-\(UUID().uuidString)"
        
        // POST URLRequest instance
        var request = URLRequest(url: requestURL)
        
        request.httpMethod = "POST"
    
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        
        // Create multipart form body
        let body = createMultipartFormDataBody(imageData: imageData, boundary: boundary, fileName: "photo.jpg")
        
        // Upload data to the URL based on the specified URL request and get the classification results
        let (data, response) = try await URLSession.shared.upload(for: request, from: body)
        
        // Check URL Response, statusCode and eventually throw error
        guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
            throw URLError(.badServerResponse)
        }
        
        // Decode the data into an array of ClassificationResult
        return try JSONDecoder().decode([ClassificationResult].self, from: data)
    }
    
    // Creates a multipart/form-data body with the image data.
    private func createMultipartFormDataBody(imageData: Data, boundary: String, fileName: String) -> Data {
        var body = Data()
        
        // Add the image data to the raw http request data
        body.append("\r\n--\(boundary)\r\n")
        body.append("Content-Disposition: form-data; name=\"file\"; filename=\"\(fileName)\"\r\n")
        body.append("Content-Type: image/jpeg\r\n\r\n")
        body.append(imageData)
        body.append("\r\n")
        
        // Add the closing boundary
        body.append("\r\n--\(boundary)--\r\n")
        return body
    }
    
    // Structure to decode results from the server
    struct ClassificationResult: Identifiable, Decodable, Equatable {
        let id: UUID = UUID()
        var label: String
        var confidence: Float
        
        private enum CodingKeys: String, CodingKey {
            case label
            case confidence
        }
        
        init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            let label = try container.decodeIfPresent(String.self, forKey: .label)
            self.label = label ?? "default"
            let confidence = try container.decodeIfPresent(Float.self, forKey: .confidence)
            self.confidence = confidence ?? 0
        }
    }
}
