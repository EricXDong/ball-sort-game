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
    
    var textureCache = [String: SKTexture]()
    var vcDelegate: VCDelegate?
    
    var isTicking: Bool = false
    
//    required init(coder aDecoder: NSCoder) {
//        fatalError("NSCoder not supported")
//    }
//
//    init(fileNamed: String) {
//        self.isTicking = false
//
//        super.init(size)
////        self.sce = SKScene(fileNamed: "GameScene")
//
//        self.anchorPoint = CGPoint(x: 0, y: 1)
//        self.addChild(self.gameLayer)
//
//        //  Add ball layer
//        self.gameLayer.addChild(self.ballLayer)
//
//        self.physicsWorld.gravity = CGVector(dx: 0, dy: 0)
//    }
    
    //  Avoid weird inherited constructur funkiness
    func initalize(view: UIView) {
        self.size = CGSize(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)
        self.anchorPoint = CGPoint(x: 0, y: 1)
        
        self.addChild(self.gameLayer)
        self.gameLayer.addChild(self.ballLayer)
        
        self.leftWall = getWall(name: "LeftWall")
        self.leftWall.position = CGPoint(x: self.leftWall.size.width, y: -self.size.height / 2)
        self.rightWall = getWall(name: "RightWall")
        self.rightWall.position = CGPoint(x: self.size.width - self.rightWall.size.width, y: -self.size.height / 2)
        
        self.physicsWorld.gravity = CGVector(dx: 0, dy: 0)
    }
    
    override func update(_ currentTime: TimeInterval) {
        //  Game can be paused
        if !self.isTicking {
            return
        }
        
        self.vcDelegate!.didTick()
    }
    
    //  Get wall with name and scale to screen size
    func getWall(name: String) -> SKSpriteNode {
        let wall = self.scene?.childNode(withName: name) as! SKSpriteNode
        let scaleFactor = self.size.height / wall.size.height
        wall.yScale = CGFloat(scaleFactor)
        return wall
    }
    
    //  Load texture from cache or load new and save in cache
    func _getTextureForColor(color: Color) -> SKTexture {
        var texture = self.textureCache[color.colorName]
        if texture == nil {
            texture = SKTexture(imageNamed: color.colorName)
            self.textureCache[color.colorName] = texture
        }
        return texture!
    }
    
    //  New ball
    func addBallToScene(ball: Ball) {
        //  Load sprite
        let sprite = SKSpriteNode(texture: self._getTextureForColor(color: ball.color))
        sprite.position = ball.startingPosition
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
        guard let particles = SKEmitterNode(fileNamed: "BallEffect") else {
            return
        }
        particles.particleColor = SystemColors[ball.color.colorName]!
        particles.targetNode = sprite
        sprite.addChild(particles)

        //  If particles loaded, don't need ball texture
        sprite.texture = nil
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
        
        self.leftWall.color = leftColor
        for wall in self.leftWall.children {
            (wall as! SKSpriteNode).color = leftColor
        }
        self.rightWall.color = SystemColors[colors.1.colorName]!
        for wall in self.rightWall.children {
            (wall as! SKSpriteNode).color = rightColor
        }
    }
    
    func startTicking() {
        self.isTicking = true
    }
    
    //  Clean up and reset
    func gameOver() {
        self.ballLayer.removeAllChildren()
        self.isTicking = false
    }
}
