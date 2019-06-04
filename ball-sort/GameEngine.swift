//
//  GameEngine.swift
//  ball-sort
//
//  Created by Eric Dong on 3/7/19.
//  Copyright © 2019 Tea Club. All rights reserved.
//

import Foundation

let pointsPerLevel = 10
let maxSpeedIncrease = 20

class GameEngine {
    var score: Int
    
    var currentLevel: Int
    var levelColors: (Color, Color)!
    
    var balls: [String: Ball]
    let ballsLock: NSLock
    
    let delegate: VCDelegate
    
    init(delegate: VCDelegate) {
        self.delegate = delegate
        self.score = 0
        self.currentLevel = 1
        self.balls = [:]
        self.ballsLock = NSLock()
        self.setNewColors()
    }
    
    func setNewColors() {
        self.levelColors = Color.getTwoRandomColors()
        self.delegate.setLevelColors(colors: self.levelColors)
    }
    
    //  Add new ball
    func addBall(ball: Ball) {
        self.ballsLock.lock()
        self.balls[ball.id] = ball
        self.ballsLock.unlock()
    }
    
    //  Remove ball by key in dictionary (which is the ball ID)
    func removeBallByKey(key: String) {
        self.ballsLock.lock()
        self.balls.removeValue(forKey: key)
        self.ballsLock.unlock()
    }
    
    //  Add 1 point to score
    func addPoint() {
        self.score += 1
        
        //  Check if time to level up
        if self.score % pointsPerLevel == 0 {
            self.currentLevel += 1
        }
    }
    
    //  Increase speed every 25 points
    func getBallSpeedIncrease() -> Int {
        let speedIncrease = (self.score / 25) * 5
        return speedIncrease < maxSpeedIncrease ? speedIncrease : maxSpeedIncrease
    }
    
    //  Clean up and reset
    func gameOver() {
        self.score = 0
        self.currentLevel = 1
        
        self.ballsLock.lock()
        self.balls.removeAll()
        self.ballsLock.unlock()
    }
}
