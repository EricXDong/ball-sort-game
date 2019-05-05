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
    
    var vcDelegate: VCDelegate?
    
    var isTicking: Bool = false
    
    //  Avoid weird inherited constructor funkiness
    func initalize(view: UIView) {
        self.size = CGSize(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)
        self.anchorPoint = CGPoint(x: 0, y: 1)
        
        self.addChild(self.gameLayer)
        self.gameLayer.addChild(self.ballLayer)
        
        self.leftWall = getWallBy(name: "LeftWall")
        self.rightWall = getWallBy(name: "RightWall")
        self.rightWall.position.x = self.size.width - self.rightWall.size.width
        
        self.physicsWorld.gravity = CGVector(dx: 0, dy: 0)
    }
    
    override func update(_ currentTime: TimeInterval) {
        //  Game can be paused
        if !self.isTicking {
            return
        }
        
        self.vcDelegate!.didTick()
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
        sprite.physicsBody?.velocity = CGVector(dx: 0, dy: -100)
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
    
    //  Returns IDs of balls off screen
    func getOffscreenBalls(_ balls: [Ball]) -> ([Ball], Bool) {
        //  y positions are negative
        let allOffscreen = balls.filter { !self.intersects($0.sprite!) }
        let isOffBottomScreen = allOffscreen.contains { $0.sprite.position.y < -self.size.height }
        return (allOffscreen, isOffBottomScreen)
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
