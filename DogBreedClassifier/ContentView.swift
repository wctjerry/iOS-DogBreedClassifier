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
    @State private var selectionIndex = 0
    
    var selections = ["Dog A", "Dog B", "Dog C", "Dog D"]
    
    
    var body: some View {
        NavigationView {
            List {
                VStack {
                    Image(imageName)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 300, height: 300, alignment: .center)
                        .fixedSize()
                    
                    Picker(selection: $selectionIndex, label: Text("Select")) {
                        ForEach(0 ..< selections.count) { index in
                            Text(self.selections[index])
                                .navigationBarTitle(Text("Battle against AI"))
                        }
                    }
                    
                    Text("You selected \(selections[selectionIndex])")
                }
            }
        }
    }
    
    func runClassifier() {
        guard let model = try? VNCoreMLModel(for: DogBreedClassifierModel().model) else {
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
