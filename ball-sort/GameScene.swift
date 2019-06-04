//
//  GameScene.swift
//  ball-sort
//
//  Created by Eric Dong on 3/7/19.
//  Copyright © 2019 Tea Club. All rights reserved.
//

import SpriteKit
import GameplayKit

class GameScene: SKScene {
    
    let gameLayer = SKNode()
    let ballLayer = SKNode()
    
    var leftWall: SKSpriteNode!
    var rightWall: SKSpriteNode!
    
    var swipeHelp: SKNode!
    var pitHelp: SKNode!
    
    var vcDelegate: VCDelegate!
    
    var isTicking: Bool = false
    
    //  Avoid weird inherited constructor funkiness
    func initalize(delegate: VCDelegate) {
        self.vcDelegate = delegate
        self.size = CGSize(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)
        self.anchorPoint = CGPoint(x: 0, y: 1)
        
        self.addChild(self.gameLayer)
        self.gameLayer.addChild(self.ballLayer)
        
        //  Wall setup
        self.leftWall = getWallBy(name: "LeftWall")
        self.rightWall = getWallBy(name: "RightWall")
        self.rightWall.position.x = self.size.width - self.rightWall.size.width
        
        //  Help text setup
        let centerX = self.size.width / 2
        self.swipeHelp = self.scene?.childNode(withName: "SwipeHelp")
        self.pitHelp = self.scene?.childNode(withName: "PitHelp")
        self.swipeHelp.position = CGPoint(x: centerX, y: -(self.size.height - 300))
        self.pitHelp.position = CGPoint(x: centerX, y: -(self.size.height - 50))
        self.pitHelp.alpha = 0
        self.swipeHelp.alpha = 0
        
        self.physicsWorld.gravity = CGVector(dx: 0, dy: 0)
    }
    
    override func update(_ currentTime: TimeInterval) {
        if !self.isTicking {
            return
        }
        self.vcDelegate.didTick()
    }
    
    //  Get wall by name
    func getWallBy(name: String) -> SKSpriteNode {
        return self.scene?.childNode(withName: name) as! SKSpriteNode
    }
    
    //  Run animations for game start
    func runStartSequence(colors: (Color, Color), time: Double) {
        let y = -self.size.height - 600
        self.leftWall.run(SKAction.move(to: CGPoint(x: self.leftWall.position.x, y: y), duration: time))
        self.rightWall.run(SKAction.move(to: CGPoint(x: self.rightWall.position.x, y: y), duration: time))
        
        //  Fade help text in and out
        self.swipeHelp.run(SKAction.sequence([
            SKAction.wait(forDuration: time),
            SKAction.fadeAlpha(to: 0.5, duration: 1.0),
            SKAction.wait(forDuration: 4.0),
            SKAction.fadeAlpha(to: 0, duration: 1.0),
            SKAction.removeFromParent()
        ]))
        self.pitHelp.run(SKAction.sequence([
            SKAction.wait(forDuration: time),
            SKAction.fadeAlpha(to: 0.5, duration: 1.0),
            SKAction.wait(forDuration: 4.0),
            SKAction.fadeAlpha(to: 0, duration: 1.0),
            SKAction.removeFromParent()
        ]))
    }
    
    //  New ball
    func addBallToScene(ball: Ball) {
        //  Load sprite
        let sprite = SKShapeNode(circleOfRadius: 50)
        sprite.position = ball.startingPosition
        sprite.lineWidth = 0
        ball.sprite = sprite
        
        //  Physics shit
        sprite.physicsBody = SKPhysicsBody(circleOfRadius: 1)
        sprite.physicsBody?.linearDamping = 0
        sprite.physicsBody?.velocity = CGVector(dx: 0, dy: -120 - self.vcDelegate.getBallSpeedIncrease())
        sprite.physicsBody?.categoryBitMask = 0x1 << 1
        sprite.physicsBody?.collisionBitMask = 0
        
        //  Add to scene
        self.ballLayer.addChild(sprite)
        
        //  Particle effects
        let particles = SKEmitterNode(fileNamed: "BallEffect")!
        particles.particleColor = SystemColors[ball.color.colorName]!
        particles.targetNode = sprite
        sprite.addChild(particles)
    }
    
    //  True if a ball hits bottom of screen
    func isBallInPit(_ balls: [Ball]) -> Bool {
        return balls.contains { $0.sprite.position.y < -self.size.height }
    }
    
    //  Set colors of walls
    func setLevelColors(colors: (Color, Color)) {
        let leftColor = SystemColors[colors.0.colorName]!
        let rightColor = SystemColors[colors.1.colorName]!
        self._setWallColors(colors: (leftColor, rightColor))
    }
    
    func _setWallColors(colors: (UIColor, UIColor)) {
        self.leftWall.color = colors.0
        for wall in self.leftWall.children {
            (wall as! SKSpriteNode).color = colors.0
        }
        self.rightWall.color = colors.1
        for wall in self.rightWall.children {
            (wall as! SKSpriteNode).color = colors.1
        }
    }
    
    func startTicking() {
        self.isTicking = true
    }
    
    //  Clean up and reset
    func gameOver() {
        self._setWallColors(colors: (UIColor.red, UIColor.red))
        self.ballLayer.removeAllChildren()
        self.isTicking = false
    }
}
