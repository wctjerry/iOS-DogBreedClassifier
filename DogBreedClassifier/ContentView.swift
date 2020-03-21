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
    @State var genuineBreed: String = "Unknow"
    @State private var selectionIndex = 0
    @State var selectedImage: String = ""
    @State var selections: [String] = []
    
    var gameData: GameData
    
    func randomImage () -> String {
        // Select a random image to show
        
        return self.gameData.images.randomElement()!
    }
    
    func initGame() {
        //         Initiate game setting, including:
        //         1. Randomize and show a dog image
        //         2. Predict and store the dog breed in the image
        //         3. Find out and store the dog's genuine breed
        //           Note this will modify ContentView's property
        self.selectedImage = self.randomImage()
        self.predictedBreed = self.runClassifier(image: self.selectedImage)
        print("Predicted breed: \(self.predictedBreed)")
        self.genuineBreed = gameData.dataSet[self.selectedImage]!
        print("Genuine breed: \(self.genuineBreed)")
        
        var selections: [String] = []
        selections.append(self.predictedBreed)
        selections.append(self.genuineBreed)
        
        self.selections = self.randomBreedSelections(selections: selections)
        
    }
    
    func randomBreedSelections (selections: [String]) -> [String] {
        // Generate up to four random and distinct choices of dog breed
        
        var selections = Array(Set(selections)) // Remove duplicates
        
        while selections.count < 4 {
            var randomBreed = self.gameData.dataSet[self.randomImage()]!
            
            while selections.contains(randomBreed) {
                randomBreed = self.gameData.dataSet[self.randomImage()]!
            }
            
            selections.append(randomBreed)
        }
        
        selections = selections.shuffled()
        print("Generated selections: \(selections)")
        return selections
    }
    
    var body: some View {
        
        ZStack {
            LinearGradient(gradient: Gradient(colors: [.blue, .black]), startPoint: .top, endPoint: .bottom)
                .edgesIgnoringSafeArea(.all)
            
            
            VStack {
                Image(selectedImage)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 300, height: 300, alignment: .center)
                    .fixedSize()
                
                ForEach(self.selections, id: \.self) { selection in
                    Button(action: {
                        // Click to do something
                    }) {
                        Text(selection)
                            .font(.title)
                            .padding()
                            .frame(minWidth: 300, maxWidth: .infinity)
                            .background(Color.white)
                            .cornerRadius(40)
                            .foregroundColor(.black)
                            .overlay(RoundedRectangle(cornerRadius: 40)
                                .stroke(Color.blue, lineWidth: 5))
                    }
                    .padding(8)
                }
                
                Button(action: {
                    self.initGame()
                }) {
                    HStack{
                        Image(systemName: "arrow.clockwise")
                            .font(.title)
                        
                        Text("Try another image")
                            .font(.title)
                    }
                .padding()
                    .foregroundColor(.white)
                    .background(Color.red)
                .cornerRadius(40)
                    
                    
                }
                
            }
        }.onAppear(){
            self.initGame()
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
        return predictedBreed
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView(gameData: GameData())
    }
}
