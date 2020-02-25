//
//  Data.swift
//  DogBreedClassifier
//
//  Created by Jerry Wu on 2020/2/23.
//  Copyright © 2020 Jerry Wu. All rights reserved.
//

import Foundation


struct GameData {
    var dataSet = ["fff7d50d848e8014ac1e9172dc6762a3": "Dog A",
               "fff1ec9e6e413275984966f745a313b0": "Dog B",
               "ffeda8623d4eee33c6d1156a2ecbfcf8": "Dog C",
               "ffe9717b7937c262f849416976f7620a": "Dog D",
               "ffe2315cf566e039516f5a4a5e52ff1b": "Dog A",
               "ffe563b1b8c0dcd0797c4362c6754b96": "Dog B",
               "ffe42f4b4c50d4f18c2b34500f391152": "Dog D",
               "ffd06687c72445b0c6e8a130a0a8711a": "Dog C",
               "ffd304c521f43819f3824177fd9efeb0": "Dog A"
    ]

    var breeds: [String] {
        Array(self.dataSet.values)
    }

    var images: [String] {
        Array(self.dataSet.keys)
    }
    
}





