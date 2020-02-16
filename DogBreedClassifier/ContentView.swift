//
//  ContentView.swift
//  DogBreedClassifier
//
//  Created by Jerry Wu on 2020/2/16.
//  Copyright © 2020 Jerry Wu. All rights reserved.
//

import SwiftUI
import CoreML
import Vision

struct ContentView: View {
    @State var label: String = "Classifying"
    @State var imageName: String = "123"
    
    var body: some View {
        VStack {
            Image("\(imageName)")
             
            Text("\(label)")
        }.onAppear(perform: runClassifier)
    }
    
    func runClassifier() {
        guard let model = try? VNCoreMLModel(for: DogBreedClassifier().model) else {
            label = "Error converting model..."
            return
        }
        
        guard let uiImage = UIImage(named: imageName) else {
            label = "Error converting to UIImage"
            return
        }
        
        guard let ciImage = CIImage(image: uiImage) else {
            label = "Error converting to CIIamge"
            return
        }
        
        let request = VNCoreMLRequest(model: model) { request, error in
            let results = request.results?.first as? VNClassificationObservation
            self.label = results?.identifier ?? "Failed to classify"
        }
        
        let handler = VNImageRequestHandler(ciImage: ciImage)
        DispatchQueue.global(qos: .userInteractive).async {
            do {
                try handler.perform([request])
            } catch {
                print(error)
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
