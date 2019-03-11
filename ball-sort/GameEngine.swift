//
//  GameEngine.swift
//  ball-sort
//
//  Created by Eric Dong on 3/7/19.
//  Copyright © 2019 Tea Club. All rights reserved.
//

class GameEngine {
    var balls: [String: Ball]
    
    init() {
        self.balls = [:]
    }
    
    func addBall(ball: Ball) {
        self.balls[ball.id] = ball
    }
}
