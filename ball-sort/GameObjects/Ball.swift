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
    let color: Color
    var position: CGPoint
    
    var sprite: SKSpriteNode?
    
    var name: String {
        return self.color.colorName
    }
    
    init(color: Color, position: CGPoint) {
        self.id = UUID().uuidString
        self.color = color
        self.position = position
    }
}
