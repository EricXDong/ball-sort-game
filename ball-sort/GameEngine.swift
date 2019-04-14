//
//  GameEngine.swift
//  ball-sort
//
//  Created by Eric Dong on 3/7/19.
//  Copyright © 2019 Tea Club. All rights reserved.
//

import Foundation

let pointsUntilColorChange = 5

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
        
        //  Check if time to change colors
        if (self.score % pointsUntilColorChange == 0) {
            self.levelColors = Color.getTwoRandomColors()
            self.delegate.setLevelColors(colors: self.levelColors)
            
            //  Randomly change colors of balls already on screen
            self.ballsLock.lock()
            for (_, ball) in self.balls {
                ball.color = Int.random(in: 0 ... 1) == 0 ? self.levelColors.0 : self.levelColors.1
                self.delegate.setBallColor(ball: ball, color: ball.color)
            }
            self.ballsLock.unlock()
        }
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
