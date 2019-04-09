//
//  GameScene.swift
//  ball-sort
//
//  Created by Eric Dong on 3/7/19.
//  Copyright © 2019 Tea Club. All rights reserved.
//

import SpriteKit
import GameplayKit

class GameScene: SKScene, SKPhysicsContactDelegate {
    
    let gameLayer = SKNode()
    let ballLayer = SKNode()
    
    var textureCache = [String: SKTexture]()
    var vcDelegate: VCDelegate?
    
    var isTicking: Bool
    
    required init(coder aDecoder: NSCoder) {
        fatalError("NSCoder not supported")
    }
    
    override init(size: CGSize) {
        self.isTicking = false
        
        super.init(size: size)
        
        self.anchorPoint = CGPoint(x: 0, y: 1)
        self.addChild(self.gameLayer)
        
        //  Add ball layer
        self.gameLayer.addChild(self.ballLayer)
        
        self.physicsWorld.gravity = CGVector(dx: 0, dy: 0)
    }
    
    override func update(_ currentTime: TimeInterval) {
        //  Game can be paused
        if !self.isTicking {
            return
        }
        
        self.vcDelegate!.didTick()
    }
    
    func addBallToScene(ball: Ball) {
        //  Load texture from cache or load new and save in cache
        var texture = self.textureCache[ball.name]
        if texture == nil {
            texture = SKTexture(imageNamed: ball.name)
            self.textureCache[ball.name] = texture
        }
        
        //  Load sprite
        let sprite = SKSpriteNode(texture: texture)
        sprite.position = ball.startingPosition
        ball.sprite = sprite
        
        sprite.physicsBody = SKPhysicsBody(circleOfRadius: 50)
        sprite.physicsBody?.linearDamping = 0
        sprite.physicsBody?.velocity = CGVector(dx: 0, dy: -60)
        
        //  Add to scene
        self.ballLayer.addChild(sprite)
    }
    
    //  Returns IDs of balls off screen
    func getOffscreenBalls(_ balls: [Ball]) -> [Ball] {
        return balls.filter { !self.intersects($0.sprite!) }
    }
    
//    //  Send a ball to the right
//    func swipeBallRight(ball: Ball) {
//        ball.sprite.physicsBody?.velocity = CGVector(dx: 500, dy: 0)
//    }
//
//    //  Send a ball to the left
//    func swipeBallLeft(ball: Ball) {
//        ball.sprite.physicsBody?.velocity = CGVector(dx: -500, dy: 0)
//    }
    
    func startTicking() {
        self.isTicking = true
    }
}
