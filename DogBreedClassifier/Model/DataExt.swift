//
//  DataExt.swift
//  DogBreedClassifier
//
//  Created by Jerry Wu on 2020/3/4.
//  Copyright © 2020 Jerry Wu. All rights reserved.
//

import Foundation

extension GameData {
    var breeds: [String] {
        Array(self.dataSet.values)
    }

    var images: [String] {
        Array(self.dataSet.keys)
    }
}
