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
    @State var defaultImageName: String = "123"
    @State private var selectionIndex = 0
    @State var selectedImage: String = "123"
    @State var selections = ["Dog A"]
    
    var gameData: GameData
        
    func randomImage () -> String {
        return self.gameData.images.randomElement()!
    }
    
    func randomBreedSelections (selections: [String]) -> [String] {
        // Generate up to four random distinct choices of dog breed
        
        var selectionsTemp = selections
        
        while selectionsTemp.count < 4 {
            var randomBreedTemp = self.gameData.dataSet[self.randomImage()]!
            
            while selectionsTemp.contains(randomBreedTemp) {
                print("Inside loop, selections: \(randomBreedTemp)")
                randomBreedTemp = self.gameData.dataSet[self.randomImage()]!
            }
            
            selectionsTemp.append(randomBreedTemp)
            print("Outside loop, selections: \(selectionsTemp)")
        }
        
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
                    
                    Text("You selected \(selections[selectionIndex])")
                   
                    Button(action: {
                        self.selectedImage = self.randomImage()
                        self.selections = self.randomBreedSelections(selections: self.selections)
                        
                    }) {
                        Text("Try another image")
                    }
                }
            }
        }
    }
    
    func runClassifier() {
        guard let model = try? VNCoreMLModel(for: DogBreedClassifierModel().model) else {
            label = "Error converting model..."
            return
        }
        
        guard let uiImage = UIImage(named: defaultImageName) else {
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
        ContentView(gameData: GameData())
    }
}
