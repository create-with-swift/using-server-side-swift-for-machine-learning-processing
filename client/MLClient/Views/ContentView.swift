//
//  ContentView.swift
//  MLClient
//
//  Created by Luca Palmese on 17/04/24.
//

import SwiftUI

struct ContentView: View {
    
    @State private var vm = ViewModel()
    @State private var image: UIImage?
    @State private var showImagePicker: Bool = false
    @State private var showConfirmationDialog: Bool = false
    @State private var sourceType: UIImagePickerController.SourceType = .camera
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 30) {
                Spacer()
                VStack(alignment: .center, spacing: 20) {
                    Group {
                        ZStack {
                            if let image = self.image {
                                Image(uiImage: image)
                                    .resizable()
                                    .scaledToFit()
                                    .clipShape(RoundedRectangle(cornerRadius: 8))
                            } else {
                                Color.secondary.cornerRadius(8).opacity(0.3)
                                RoundedRectangle(cornerRadius: 8)
                                    .stroke(.tertiary, style: StrokeStyle(lineWidth: 2, dash: [10]))
                                VStack(alignment: .center, spacing: 50) {
                                    Image(systemName: "photo.on.rectangle.angled")
                                        .resizable()
                                        .scaledToFit()
                                    Text("Tap to upload an image")
                                        .font(.title2)
                                }
                                .padding(50)
                            }
                        }
                        .foregroundStyle(.tertiary)
                    }
                    .onTapGesture {
                        showConfirmationDialog.toggle()
                    }
                    if vm.results.count != 0 && vm.requestStatus == .success {
                        Text("Classification Results:")
                            .font(.headline)
                        ForEach(vm.results[0..<3], id: \.id) { result in
                            HStack {
                                Text("\(1). \(result.label) - ")
                                    .font(.callout)
                                Text(String(format: "%.2f%%", result.confidence * 100))
                                    .font(.caption2)
                            }
                        }
                    } else if vm.requestStatus == .loading {
                        ProgressView("Classifying image...")
                    } else if vm.requestStatus == .error {
                        Text("Server is not responding, try again...")
                    }
                }
                .padding(20)
                .background(.tertiary.opacity(0.3))
                .cornerRadius(16)
                .padding()
                .animation(.spring(response: 0.6, dampingFraction: 0.8), value: vm.requestStatus)
                Spacer()
                if let image = self.image, vm.requestStatus == .idle || vm.requestStatus == .error {
                    Button("Classify Image") {
                        Task {
                            await vm.classifyImage(image)
                        }
                    }
                    .padding()
                    .background(.blue)
                    .foregroundStyle(.white)
                    .clipShape(Capsule())
                    .padding(.bottom, 20)
                }
            }
            .confirmationDialog("", isPresented: $showConfirmationDialog) {
                Button("Camera") {
                    // Camera action
                    sourceType = .camera
                    showImagePicker = true
                }
                Button("Photo Library") {
                    // Photo Library action
                    sourceType = .photoLibrary
                    showImagePicker = true
                }
            } message: {
                Text("Select an image")
            }
            .sheet(isPresented: $showImagePicker) {
                ImagePicker(sourceType: $sourceType) { image in
                    self.image = image
                    vm.reset()
                }
            }
            .navigationTitle("Image Classification")
        }
    }
}


#Preview {
    ContentView()
}
