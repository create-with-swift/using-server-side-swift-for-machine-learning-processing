//
//  ImagePicker.swift
//  MLClient
//
//  Created by Luca Palmese on 17/04/24.
//

import SwiftUI

struct ImagePicker: UIViewControllerRepresentable {
    
    @Binding var sourceType: UIImagePickerController.SourceType
    @Environment(\.presentationMode) private var presentationMode
    var completion: (UIImage) -> Void
    
    func makeUIViewController(context: Context) -> some UIViewController {
        let picker = UIImagePickerController()
        picker.sourceType = sourceType
        picker.delegate = context.coordinator
        return picker
    }
    
    func updateUIViewController(_: UIViewControllerType, context _: Context) {
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
        var parent: ImagePicker
        
        init(_ parent: ImagePicker) {
            self.parent = parent
        }
        
        func imagePickerController(_: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
            if let image = info[.originalImage] as? UIImage {
                parent.completion(image)
            }
            parent.presentationMode.wrappedValue.dismiss()
        }
    }
}
