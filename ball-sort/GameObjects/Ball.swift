//
//  Ball.swift
//  ball-sort
//
//  Created by Eric Dong on 3/8/19.
//  Copyright © 2019 Tea Club. All rights reserved.
//

import SpriteKit

class Ball {
    let id: String
    var color: Color
    var startingPosition: CGPoint
    
    var sprite: SKSpriteNode!
    
    var name: String {
        return self.color.colorName
    }
    
    init(color: Color, startingPosition: CGPoint) {
        self.id = UUID().uuidString
        self.color = color
        self.startingPosition = startingPosition
    }
}
