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
    
    var textureCache = [String: SKTexture]()
    var vcDelegate: VCDelegate?
    
    var lastTick: NSDate?
    
    required init(coder aDecoder: NSCoder) {
        fatalError("NSCoder not supported")
    }
    
    override init(size: CGSize) {
        super.init(size: size)
        
        self.anchorPoint = CGPoint(x: 0, y: 1)
        self.addChild(self.gameLayer)
        
        self.gameLayer.addChild(self.ballLayer)
        
        self.physicsWorld.gravity = CGVector(dx: 0, dy: 0)
    }
    
    override func update(_ currentTime: TimeInterval) {
        guard let lastTick = self.lastTick else {
            return
        }
        
        let delta = lastTick.timeIntervalSinceNow * -1000.0
        if delta > 2000 {
            self.lastTick = NSDate()
            self.vcDelegate!.didTick()
        }
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
        sprite.position = ball.position
        ball.sprite = sprite
        
        //  Actual radius doesn't matter since balls don't collide
        sprite.physicsBody = SKPhysicsBody(circleOfRadius: 5)
        sprite.physicsBody?.linearDamping = 0
        sprite.physicsBody?.velocity = CGVector(dx: 0, dy: -30)
        
        //  Add to scene
        self.ballLayer.addChild(sprite)
    }
    
    func startTicking() {
        self.lastTick = NSDate()
    }
}
