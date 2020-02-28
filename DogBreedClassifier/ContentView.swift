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
    @State var predictedBreed: String = "Classifying"
    @State var defaultImageName: String = "123"
    @State private var selectionIndex = 0
    @State var selectedImage: String = "123"
    @State var selections: [String] = []
    
    var gameData: GameData
        
    func randomImage () -> String {
        // Select a random image to show
        
        return self.gameData.images.randomElement()!
    }
    
    func randomBreedSelections (predictImage: String) -> [String] {
        // Generate up to four random and distinct choices of dog breed
        // One of which is the classifier's prediction
        
        var selections: [String] = []
        let predictedBreed = self.runClassifier(image: predictImage)
        selections.append(predictedBreed) // This means predicted breed will always be the first selection
        
        while selections.count < 4 {
            var randomBreed = self.gameData.dataSet[self.randomImage()]!
            
            while selections.contains(randomBreed) {
                randomBreed = self.gameData.dataSet[self.randomImage()]!
            }
            
            selections.append(randomBreed)
        }
        
        print("Generated selections: \(selections)")
        return selections
    }
    
    var body: some View {
        NavigationView {
            List {
                VStack {
                    Image(selectedImage)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 300, height: 300, alignment: .center)
                        .fixedSize()
                    
                    Picker(selection: $selectionIndex, label: Text("Select")) {
                        ForEach(self.selections, id: \.self) { selection in
                            Text(selection)
                                .navigationBarTitle(Text("Battle against AI"))
                        }
                    }
                    .id(self.selections)
                    
//                    Text("You selected \(selections[selectionIndex] ?? "None")")
                    
//                    Text("Model predicts as \(predictedBreed)")
                   
                    Button(action: {
                        self.selectedImage = self.randomImage()
                        self.selections = self.randomBreedSelections(predictImage: self.selectedImage)
                    }) {
                        Text("Try another image")
                    }
                }
            }
        }.onAppear(){
            self.selectedImage = self.randomImage()
            self.selections = self.randomBreedSelections(predictImage: self.selectedImage)
        }
    }
    
    func runClassifier(image: String) -> String {
        // Return a predicted breed of the shown image dog
        
        var predictedBreed = ""
        
        guard let model = try? VNCoreMLModel(for: DogBreedClassifierModel().model) else {
            predictedBreed = "Error converting model..."
            return predictedBreed
        }
        
        guard let uiImage = UIImage(named: image) else {
            predictedBreed = "Error converting to UIImage"
            return predictedBreed
        }
        
        guard let ciImage = CIImage(image: uiImage) else {
            predictedBreed = "Error converting to CIIamge"
            return predictedBreed
        }
        
        let request = VNCoreMLRequest(model: model) { request, error in
            let results = request.results?.first as? VNClassificationObservation
            predictedBreed = results?.identifier ?? "Failed to classify"
        }
        
        let handler = VNImageRequestHandler(ciImage: ciImage)
        do {
            try handler.perform([request])
        } catch {
            print(error)
        }
        print(predictedBreed)
        return predictedBreed
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView(gameData: GameData())
    }
}
