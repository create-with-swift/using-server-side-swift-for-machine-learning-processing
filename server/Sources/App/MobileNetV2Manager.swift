//
//  MobileNetV2Manager.swift
//
//
//  Created by Luca Palmese on 17/04/24.
//

import Vapor
import CoreImage
import Vision

struct MobileNetV2Manager {
    
    enum MLError: Error {
        case modelNotFound
        case noResults
    }
    
    func classify(image: CIImage) throws -> [ClassificationResult] {
        
        // Creating an instance of the MobileNetV2 model
        let url = Bundle.module.url(forResource: "MobileNetV2", withExtension: "mlmodelc")!
        guard let model = try? VNCoreMLModel(for: MobileNetV2(contentsOf: url, configuration: MLModelConfiguration()).model) else {
            throw MLError.modelNotFound
        }
        
        // Creating an image analysis request to process the image
        let request = VNCoreMLRequest(model: model)
        
        // Creating the handler that processes the image analysis request
        let handler = VNImageRequestHandler(ciImage: image)
        try? handler.perform([request])
        
        guard let results = request.results as? [VNClassificationObservation] else {
            throw MLError.noResults
        }
        
        // Mapping the results to return [ClassificationResult]
        let classificationResults = results.map { result in
            ClassificationResult(label: result.identifier, confidence: result.confidence)
        }
        
        return classificationResults
    }
}

struct ClassificationResult: Encodable, Content {
    var label: String
    var confidence: Float
}
