//
//  ViewModel.swift
//  MLClient
//
//  Created by Luca Palmese on 17/04/24.
//

import Foundation
import UIKit
import Observation

@Observable
class ViewModel {
    
    enum RequestStatus {
        case idle, loading, success, error
    }
    
    private var apiManager = APIManager.shared
    var results: [APIManager.ClassificationResult] = []
    var requestStatus: RequestStatus = .idle
    
    // Resets the status and removes previous ML results
    func reset() {
        results.removeAll()
        requestStatus = .idle
    }
    
    // Function that calls the manager that sends the URL Request
    func classifyImage(_ image: UIImage) async {
        do {
            requestStatus = .loading
            results = try await apiManager.classifyImage(image)
            requestStatus = .success
        } catch {
            print(error.localizedDescription)
            requestStatus = .error
        }
    }
}
