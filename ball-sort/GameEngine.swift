//
//  GameEngine.swift
//  ball-sort
//
//  Created by Eric Dong on 3/7/19.
//  Copyright © 2019 Tea Club. All rights reserved.
//

class GameEngine {
    var currentLevel: Int
    var levelColors: (Color, Color)
    
    var balls: [String: Ball]
    
    let delegate: VCDelegate
    
    init(delegate: VCDelegate) {
        self.delegate = delegate
        self.currentLevel = 1
        self.balls = [:]
        self.levelColors = Color.getTwoRandomColors()
        
        self.delegate.setLevelColors(colors: self.levelColors)
    }
    
    //  Add new ball
    func addBall(ball: Ball) {
        self.balls[ball.id] = ball
    }
    
    //  Remove ball by key in dictionary (which is the ball ID)
    func removeBallByKey(key: String) {
        self.balls.removeValue(forKey: key)
    }
    
    
}
