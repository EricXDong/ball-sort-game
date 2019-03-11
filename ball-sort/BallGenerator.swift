//
//  BallGenerator.swift
//  ball-sort
//
//  Created by Eric Dong on 3/9/19.
//  Copyright © 2019 Tea Club. All rights reserved.
//

import SpriteKit

class BallGenerator {
    //  Random error added to period
    let periodError: Int = 250
    
    //  How many ms until next new ball
    let basePeriod = 1000
    
    //  Higher level means balls spawn more frequently
    let levelMultiplier = 100
    var currentLevel = 0
    
    //  Where on the x axis to spawn the ball
    var xCoordRange: (Int, Int)
    let delegate: VCDelegate
    
    var lastBallTimestamp: NSDate?
    var timeUntilNextBall: Int?
    
    init(xCoordRange: (Int, Int), delegate: VCDelegate) {
        self.xCoordRange = xCoordRange
        self.delegate = delegate
    }
    
    func tick() {
        guard let last = self.lastBallTimestamp else {
            return;
        }
        
        let elapsed = -Int(last.timeIntervalSinceNow * 1000)
        if elapsed >= self.timeUntilNextBall! {
            //  Generate a ball and set new time
            delegate.newBall(ball: self.getRandomBall())
            self.lastBallTimestamp = NSDate()
            self.timeUntilNextBall = self.getTimeUntilNextBall()
        }
    }
    
    func startGenerating() {
        self.lastBallTimestamp = NSDate()
        self.timeUntilNextBall = self.getTimeUntilNextBall()
    }
    
    func getTimeUntilNextBall() -> Int {
        let base = self.basePeriod - (self.currentLevel * self.levelMultiplier);
        let error = Int.random(in: -self.periodError ..< self.periodError)
        return base + error
    }
    
    func getRandomBall() -> Ball {
        let position = CGPoint(x: Int.random(in: self.xCoordRange.0 ..< self.xCoordRange.1), y: -20)
        let ball = Ball(color: Color.allCases.randomElement()!, position: position)
        return ball
    }
}
