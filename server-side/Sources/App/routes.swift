import Vapor
import CoreImage

func routes(_ app: Application) throws {
    app.post("mobilenetv2") { req -> [ClassificationResult] in
        
        // Decoding the request content that has been uploaded
        let requestContent = try req.content.decode(RequestContent.self)
        let fileData = requestContent.file.data
        
        // Getting the file data
        guard let imageData = fileData.getData(at: fileData.readerIndex, length: fileData.readableBytes),
              let ciImage = CIImage(data: imageData) else {
            throw DataFormatError.wrongDataFormat
        }
        
        // Creating instance of the MobileNetV2Manager
        let mobileNetV2 = MobileNetV2Manager()
        
        // This is were the classification happens
        do {
            return try mobileNetV2.classify(image: ciImage)
        } catch {
            print(error.localizedDescription)
            return []
        }
    }
}

enum DataFormatError: Error {
    case wrongDataFormat
}

struct RequestContent: Content {
    var file: File
}
