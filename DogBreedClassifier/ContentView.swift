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
    
    func randomBreedSelections (selections: [String]) -> [String] {
        // Generate up to four random distinct choices of dog breed
        
        var selectionsTemp = selections
        
        while selectionsTemp.count < 4 {
            var randomBreedTemp = self.gameData.dataSet[self.randomImage()]!
            
            while selectionsTemp.contains(randomBreedTemp) {
                randomBreedTemp = self.gameData.dataSet[self.randomImage()]!
            }
            
            selectionsTemp.append(randomBreedTemp)
        }
        
        print("Generated selections: \(selectionsTemp)")
        return selectionsTemp
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
                    
                    Text("Model predicts as \(predictedBreed)")
                   
                    Button(action: {
                        self.selectedImage = self.randomImage()
                        self.selections = []
                        self.predictedBreed = self.runClassifier(image: self.selectedImage)
                        self.selections.append(self.predictedBreed)
                        self.selections = self.randomBreedSelections(selections: self.selections)
                        
                    }) {
                        Text("Try another image")
                    }
                }
            }
        }.onAppear(){
            self.selectedImage = self.randomImage()
            self.predictedBreed = self.runClassifier(image: self.selectedImage)
            self.selections.append(self.predictedBreed)
            self.selections = self.randomBreedSelections(selections: self.selections)
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
