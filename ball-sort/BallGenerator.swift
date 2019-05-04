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
    let periodError: Int = 1000
    
    //  How many ms until next new ball
    let basePeriod = 1000
    let minPeriod = 400
    
    //  Higher level means balls spawn more frequently
    let levelMultiplier = 200
    
    var levelColors: (Color, Color)!
    
    //  Where on the x axis to spawn the ball
    var xCoordRange: (Int, Int)
    
    //  Where the last ball was spawned, next ball shouldn't be too close
    var lastSpawnX: Float = 0
    let minDistanceFromLastSpawn: Float = 50
    
    let delegate: VCDelegate
    
    //  Stuff for timing new balls
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
        
        //  Check if it's time to generate a ball
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
        let base = self.basePeriod - (self.delegate.getCurrentLevel() * self.levelMultiplier);
        let error = Int.random(in: -self.periodError ... self.periodError)
        let spawnTime = base + error
        return spawnTime > self.minPeriod ? spawnTime : self.minPeriod
    }
    
    func getRandomSpawnPoint() -> CGPoint {
        return CGPoint(x: Int.random(in: self.xCoordRange.0 ..< self.xCoordRange.1), y: -20)
    }
    
    func getRandomBall() -> Ball {
        //  Random position along top of screen that's not too close to the last spawned ball
        var position = self.getRandomSpawnPoint()
        while abs(Float(position.x) - self.lastSpawnX) < self.minDistanceFromLastSpawn {
            position = self.getRandomSpawnPoint()
        }
        self.lastSpawnX = Float(position.x)
        
        //  Randomly pick the color based on current level colors
        let colorIdx = Int.random(in: 0...1)
        let color = colorIdx == 0 ? self.levelColors.0 : self.levelColors.1
        
        let ball = Ball(color: color, startingPosition: position)
        return ball
    }
    
    func setLevelColors(colors: (Color, Color)) {
        self.levelColors = colors
    }
}
