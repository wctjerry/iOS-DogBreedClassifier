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
    
    // Pridicted and genuine breed
    @State private var predictedBreed: String = "Classifying"
    @State private var genuineBreed: String = "Unknow"
    
    // Shown images
    @State private var selectedImage: String = ""
    @State private var selections: [String] = []
    
    // Alerting and progress
    @State private var alertTitle: String = ""
    @State private var alertMessage: String = ""
    @State private var showingAlert: Bool = false
    @State private var humanScore: Int = 0
    @State private var botScore: Int = 0
    @State private var numRounds: Int = 0
    @State private var gameEnded: Bool = false
    
    // Animation
    @State private var rotateAmount: [String: Double] = [:]
    @State private var opacityAmount: [String: Double] = [:]
    
    var gameData: GameData
    
    
    func initGame() {
        // Reset status
        self.humanScore = 0
        self.botScore = 0
        self.numRounds = 0
        self.gameEnded = false
        
        // Reset alerting message
        self.alertTitle = ""
        self.alertMessage = ""
        self.showingAlert = false
        
        // Initiate round setting
        initRound()
        
    }
    
    func initRound() {
        //  Initiate round setting, including:
        //    1. Randomize and show a dog image on the screen
        //    2. Predict the dog breed by classifier model
        //    3. Find out and store the dog's genuine breed
        //    4. Generate four selections to be selected by the player,
        //       including predicted and genuine breed
        
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
    
    
    func randomImage () -> String {
        // Select a random image to show on the screen
        
        return self.gameData.images.randomElement() ?? "Fail to randomize"
    }
    
    
    func randomBreedSelections (selections: [String]) -> [String] {
        // Generate up to four random and distinct choices of dog breed
        
        var selections = Array(Set(selections)) // Remove duplicates, if the predicted and genuine breed are the same
        
        while selections.count < 4 {
            var randomBreed = self.gameData.dataSet[self.randomImage()]!
            
            while selections.contains(randomBreed) {
                randomBreed = self.gameData.dataSet[self.randomImage()]!
            }
            
            selections.append(randomBreed)
        }
        
        selections = selections.shuffled()
        print("Generated selections: \(selections)")
        
        // Reset and initiate animation amount for these four selection
        self.rotateAmount = [:]
        self.opacityAmount = [:]
        for selection in selections {
            self.rotateAmount[selection] = 0.0
            self.opacityAmount[selection] = 1.0
        }
        
        return selections
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
    
    
    func calculateRoundResult(selection: String) {
        // Identify win or lose in a round
        
        if selection == self.genuineBreed { // Human is correct
            self.humanScore += 1
            self.alertTitle = "You are correct!"
            
            // Add animation
            guard let originAmount = self.rotateAmount[selection] else {
                return
            }
            self.rotateAmount[selection] = originAmount + 360
            
            for s in self.selections {
                if s != selection {
                    self.opacityAmount[s] = 0.25
                }
            }
        } else {
            self.alertTitle = "You are wrong!"
        }
        
        if self.predictedBreed == self.genuineBreed { // Bot is correct
            self.botScore += 1
        }
        
        self.alertMessage = "You've won \(self.humanScore) \(self.humanScore == 0 ? "point" : "points")"
        
        self.alertMessage += ", whereas AI has won \(self.botScore) \(self.botScore == 0 ? "point" : "points")"
        
        self.showingAlert = true
        
        self.numRounds += 1
    }
    
    func calculateFinalResult() {
        self.alertTitle = "Final score"
        
        self.alertMessage = "Thanks for playing this game!\n"
        self.alertMessage += "You've played \(self.numRounds) round\(checkS(num: self.numRounds)) against AI. "
        self.alertMessage += "You've scored \(self.humanScore) point\(checkS(num: self.humanScore)), "
        self.alertMessage += "whereas AI has scored \(self.botScore) point\(checkS(num: self.botScore))"
        
        self.gameEnded = true
        self.showingAlert = true
    }
    
    func checkS(num: Int) -> String {
        // Check if need to add 's' in the string
        if num < 2 {
            return ""
        } else {
            return "s"
        }
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
                        self.calculateRoundResult(selection: selection)
                    }) {
                        styleSelection(with: selection)
                    }
                    .padding(8)
                    .rotation3DEffect(Angle(degrees: self.rotateAmount[selection] ?? 0), axis: (x: 0, y: 1, z: 0))
                    .opacity(self.opacityAmount[selection] ?? 1)
                    .animation(.default)
                }
                
                HStack {
                    Button(action: {
                        self.initRound()
                    }) {
                        HStack{
                            Image(systemName: "arrow.clockwise")
                            
                            Text("Try another")
                        }
                    }
                    .padding()
                    .background(Color.red)
                    
                    Button(action: {
                        self.calculateFinalResult()
                    }) {
                        HStack{
                            Image(systemName: "xmark")
                            
                            Text("End game")
                        }
                    }
                    .padding()
                    .background(Color.gray)
                }
                .font(.subheadline)
                .foregroundColor(.white)
                .cornerRadius(40)
            }
        }.onAppear(){
            self.initGame()
        }
        .alert(isPresented: $showingAlert) {
            Alert(title: Text(self.alertTitle), message: Text(self.alertMessage), dismissButton: .default(Text(self.gameEnded ? "Reset" : "Try another")) {
                if self.gameEnded {
                    self.initGame()
                } else {
                    self.initRound()
                }
                })
        }
    }
    
    struct styleSelection: View {
        // Style for four selections
        var with: String
        
        var body: some View {
            Text(with)
                .font(.title)
                .padding()
                .frame(minWidth: 300, maxWidth: .infinity)
                .background(Color.white)
                .cornerRadius(40)
                .foregroundColor(.black)
                .overlay(RoundedRectangle(cornerRadius: 40)
                    .stroke(Color.blue, lineWidth: 5))
        }
    }
}



struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView(gameData: GameData())
    }
}
