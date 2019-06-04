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
    func getCurrentLevel() -> Int
    func getLevelColors() -> (Color, Color)
    func setLevelColors(colors: (Color, Color))
    func getBallSpeedIncrease() -> Int
}

//  For storing high score on device
struct UserDataKeys {
    static let HighScore = "high-score"
}

class GameViewController: UIViewController, VCDelegate {
    
    let userData = UserDefaults.standard
    var highScore: Int!
    
    var scene: GameScene!
    var engine: GameEngine!
    var ballGen: BallGenerator!
    
    @IBOutlet var scoreLabel: UILabel!
    @IBOutlet var highScoreLabel: UILabel!
    
    //  Contains the game over label and buttons
    @IBOutlet var gameOverGroup: UIStackView!
    @IBOutlet var gameOverLabel: UILabel!
    @IBOutlet var playAgainButton: UIButton!
    
    ///  GAME INIT
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.gameOverGroup.isHidden = true
        
        //  Hide the labels at start
        self.scoreLabel.alpha = 0
        self.highScoreLabel.alpha = 0
        
        //  High score stuff
        self.highScore = self.userData.integer(forKey: UserDataKeys.HighScore)
        self.updateHighScoreLabel()
        
        //  Set up view
        let view = self.view as! SKView
        view.isMultipleTouchEnabled = false
        
        //  Set up scene in view
        self.scene = GameScene(fileNamed: "GameScene")
        self.scene.initalize(delegate: self)
        self.scene.scaleMode = .aspectFill
        
        //  Set up ball generator
        self.ballGen = BallGenerator(
            xCoordRange: (100, Int(view.bounds.size.width) - 100),
            delegate: self
        )
        
        //  Set up the game engine
        self.engine = GameEngine(delegate: self)
        self.scoreLabel.text = String(self.engine.score)

        //  Present and run start sequence
        view.presentScene(self.scene)
        self._runStartSequence()
    }

    override var shouldAutorotate: Bool {
        return false
    }

    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    //  Runs the animations for game start
    func _runStartSequence() {
        //  In seconds
        let sequenceTime = 1.25
        self.scene.runStartSequence(colors: self.getLevelColors(), time: sequenceTime)
        Timer.scheduledTimer(withTimeInterval: sequenceTime, repeats: false) { _ in
            self.scene.startTicking()
            self.ballGen.startGenerating()
            //  Also fade in the labels
            UIView.animate(withDuration: 0.5, animations: {
                self.scoreLabel.alpha = 1.0
                self.highScoreLabel.alpha = 1.0
            })
        }
    }
    
    ///  DELEGATE METHODS
    
    func didTick() {
        self.scoreLabel.text = String(self.engine.score)
        
        //  Keep generating balls
        self.ballGen.tick()
        
        //  Game over if ball hits bottom of screen
        let isBallInPit = self.scene.isBallInPit(self.engine.balls.map { $1 })
        if isBallInPit {
            self.gameOver()
        }
    }
    
    func newBall(ball: Ball) {
        self.engine.addBall(ball: ball)
        self.scene.addBallToScene(ball: ball)
    }
    
    //  Getter for the ball gen
    func getCurrentLevel() -> Int {
        return self.engine.currentLevel
    }
    
    func setLevelColors(colors: (Color, Color)) {
        self.ballGen.setLevelColors(colors: colors)
        self.scene.setLevelColors(colors: colors)
    }
    
    func getLevelColors() -> (Color, Color) {
        return self.engine.levelColors
    }
    
    func getBallSpeedIncrease() -> Int {
        return self.engine.getBallSpeedIncrease()
    }

    ///  HANDLING BALLS
    
    func removeBallFromScene(ball: Ball) {
        self.engine.removeBallByKey(key: ball.id)
        ball.sprite.removeFromParent()
    }
    
    //  Return the ball that intersects point the closest, or nil if none
    func getBallAtPoint(point: CGPoint) -> Ball? {
        //  All intersected balls
        let intersected = self.engine.balls
            .map { $1 }
            .filter { ball in ball.sprite.frame.contains(point) }
        
        //  Find closest one
        var closestBall: Ball? = nil
        var closestDistance = 1000.0
        for ball in intersected {
            let distance = Double(point.distance(point: ball.sprite.position))
            if distance < closestDistance {
                closestDistance = distance
                closestBall = ball
            }
        }
        
        return closestBall
    }
    
    //  Get the ball that was swiped, or nil if none
    func getSwipedBall(_ sender: UISwipeGestureRecognizer) -> Ball? {
        //  Get point and convert based on scene's anchor point
        let swipePoint = sender.location(in: self.view)
        let swipePointInScene = self.scene.convertPoint(fromView: swipePoint)
        
        return self.getBallAtPoint(point: swipePointInScene)
    }
    
    //  Swipe particle effects
    func spawnSwipeEffects(ball: Ball, toLeft: Bool, isGameOver: Bool) {
        let color = isGameOver ? UIColor.red : SystemColors[ball.color.colorName]!
        let position = ball.sprite.position
        let fwooshSpeed = 2000
        
        //  Poof effect
        let poof = SKEmitterNode(fileNamed: "Poof")!
        poof.particleColor = color
        poof.position = position
        poof.targetNode = self.scene
        self.scene.addChild(poof)
        
        //  Remove after 0.2 sec
        poof.run(SKAction.sequence([
            SKAction.wait(forDuration: 0.2),
            SKAction.removeFromParent()
        ]))
        
        //  Fwoosh effect
        let spawnFwoosh = {() in
            //  Use an empty node to anchor the fwoosh to, then send it flying
            let empty = SKNode()
            empty.position = position
            empty.physicsBody = SKPhysicsBody(circleOfRadius: 1)
            empty.physicsBody?.linearDamping = 0
            empty.physicsBody?.velocity = CGVector(dx: toLeft ? -fwooshSpeed : fwooshSpeed, dy: 0)
            
            let fwoosh = SKEmitterNode(fileNamed: "Fwoosh")!
            fwoosh.particleColor = color
            fwoosh.targetNode = self.scene
            empty.addChild(fwoosh)
            
            self.scene.addChild(empty)
            
            //  Remove node and fwoosh together
            empty.run(SKAction.sequence([
                SKAction.wait(forDuration: 1.0),
                SKAction.removeFromParent()
            ]))
        }
        
        //  Calculate when to spawn the bang based on position and velocity
        let distance = toLeft ? position.x : self.scene.size.width - position.x
        let timeToSpawnBang = Double(distance) / Double(fwooshSpeed)
        
        self.scene.run(SKAction.sequence([
            SKAction.run { spawnFwoosh() },
            SKAction.wait(forDuration: timeToSpawnBang),
            SKAction.run {
                self.spawnBang(position: CGPoint(x: toLeft ? 0 : self.scene.size.width, y: position.y), color: color)
            }
        ]))
    }
    
    //  Bang!!
    func spawnBang(position: CGPoint, color: UIColor) {
        let bang = SKEmitterNode(fileNamed: "Bang")!
        bang.particleColor = color
        bang.position = position
        bang.targetNode = self.scene
        self.scene.addChild(bang)
    }
    
    ///  ENDGAME STUFF
    
    func updateHighScoreLabel() {
        self.highScoreLabel.text = String(self.highScore)
    }
    
    func gameOver() {
        //  Update high score if necessary
        if self.engine.score > self.highScore {
            self.highScore = self.engine.score
            self.updateHighScoreLabel()
            self.userData.set(self.highScore, forKey: UserDataKeys.HighScore)
        }
        
        self.engine.balls
            .map { $1 }
            .forEach { self.spawnBang(position: $0.sprite.position, color: UIColor.red) }
        
        self.scene.gameOver()
        self.engine.gameOver()
        self.gameOverGroup.isHidden = false
    }
    
    ///  USER INTERACTIONS
    
    //  Ball swiping
    @IBAction func onSwipeRight(_ sender: UISwipeGestureRecognizer) {
        guard let swipedBall = self.getSwipedBall(sender) else {
            return
        }
        
        let isGameOver = swipedBall.color != self.engine.levelColors.1
        self.spawnSwipeEffects(ball: swipedBall, toLeft: false, isGameOver: isGameOver)
        
        if (isGameOver) {
            self.gameOver()
        } else {
            self.engine.addPoint()
        }
        self.removeBallFromScene(ball: swipedBall)
    }
    
    //  Ball swiping
    @IBAction func onSwipeLeft(_ sender: UISwipeGestureRecognizer) {
        guard let swipedBall = self.getSwipedBall(sender) else {
            return
        }
        
        let isGameOver = swipedBall.color != self.engine.levelColors.0
        self.spawnSwipeEffects(ball: swipedBall, toLeft: true, isGameOver: isGameOver)
        
        if (isGameOver) {
            self.gameOver()
        } else {
            self.engine.addPoint()
        }
        self.removeBallFromScene(ball: swipedBall)
    }
    
    //  PLaying again after game over
    @IBAction func onClickPlayAgain(_ sender: UIButton) {
        self.gameOverGroup.isHidden = true
        self.engine.setNewColors()
        self.scene.isTicking = true
    }
}
