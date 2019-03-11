//
//  GameViewController.swift
//  ball-sort
//
//  Created by Eric Dong on 3/7/19.
//  Copyright © 2019 Tea Club. All rights reserved.
//

import UIKit
import SpriteKit
import GameplayKit

protocol VCDelegate {
    func didTick()
    func newBall(ball: Ball)
}

class GameViewController: UIViewController, VCDelegate {
    
    var scene: GameScene!
    var engine: GameEngine!
    var ballGen: BallGenerator!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        //  Set up view
        let view = self.view as! SKView
        view.isMultipleTouchEnabled = false
        
        //  Set up scene in view
        self.scene = GameScene(size: view.bounds.size)
        self.scene.scaleMode = .aspectFill
        self.scene.vcDelegate = self
        self.scene.startTicking()
        
        //  Set up ball generator
        self.ballGen = BallGenerator(
            xCoordRange: (50, Int(view.bounds.size.width) - 50),
            delegate: self
        )
        self.ballGen.startGenerating()
        
        //  Set up the game engine
        self.engine = GameEngine()
        
        view.presentScene(self.scene)
    }

    override var shouldAutorotate: Bool {
        return false
    }

    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    func didTick() {
        self.ballGen.tick()
    }
    
    func newBall(ball: Ball) {
        self.engine.addBall(ball: ball)
        self.scene.addBallToScene(ball: ball)
    }
}
