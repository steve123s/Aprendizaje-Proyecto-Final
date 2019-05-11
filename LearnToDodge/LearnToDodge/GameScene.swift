//
//  GameScene.swift
//  LearnToDodge
//
//  Created by Daniel Salinas on 5/11/19.
//  Copyright © 2019 DanielSteven. All rights reserved.
//

import SpriteKit
import GameplayKit

let screenWidth = UIScreen.main.bounds.size.width
let screenHeight = UIScreen.main.bounds.size.height

class GameScene: SKScene, SKPhysicsContactDelegate {
    
    enum RoadLane: CGFloat {
        case left = 0
        case right = 75
    }
    
    //let goal: UInt = UInt.subtractWithOverflow(0, 1).0
    let goal: UInt = 35764
    let populationSize = 100
    
    var canRestart = false
    
    var player = Player()
    
    var playerPosition: RoadLane = .left
    var scoreLabel = Score()
    var restartLabel: SKLabelNode!
    
    override func didMove(to view: SKView) {
        scene!.size = view.bounds.size
        backgroundColor = UIColor.init(hue: 0.58, saturation: 0.63, brightness: 0.35, alpha: 1)
        
        player = Player()
        scoreLabel = Score()
        
        createBackground()
        
        // Create car sequence for given number
        var sequence: [SKAction] = []
        for bit in goal.bits.reversed() {
            let placeCarAction = SKAction.run {
                bit == false ? self.createCar(inLane: .left) : self.createCar(inLane: .right)
            }
            let waitAction = SKAction.wait(forDuration: 1)
            sequence.append(placeCarAction)
            sequence.append(waitAction)
        }
        let actionsSequence = SKAction.sequence(sequence)
        run(actionsSequence)
        
        addChild(player)
        addChild(scoreLabel)
        
        scoreLabel.score = 0
        
        physicsWorld.gravity = CGVector(dx: 0, dy: 0)
        physicsWorld.contactDelegate = self
        
        let swipeLeft = UISwipeGestureRecognizer(target: self, action: #selector(handleGesture))
        swipeLeft.direction = .left
        self.view?.addGestureRecognizer(swipeLeft)
        
        let swipeRight = UISwipeGestureRecognizer(target: self, action: #selector(handleGesture))
        swipeRight.direction = .right
        self.view?.addGestureRecognizer(swipeRight)
        
    }
    
    @objc func handleGesture(gesture: UISwipeGestureRecognizer) -> Void {
        if gesture.direction == UISwipeGestureRecognizer.Direction.right {
            if playerPosition == .left {
                movePlayer(toLane: .right)
                playerPosition = .right
            }
        }
        else if gesture.direction == UISwipeGestureRecognizer.Direction.left {
            if playerPosition == .right {
                movePlayer(toLane: .left)
                playerPosition = .left
            }
        }
    }
    
    func movePlayer(toLane offset: RoadLane) {
        player.position = CGPoint(x: screenWidth/4 + 45 + offset.rawValue, y: screenHeight/10)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        reset()
    }
    
    func didBegin(_ contact: SKPhysicsContact) {
        if contact.bodyA.node?.name == "player" || contact.bodyB.node?.name == "player" {
            player.name = ""
            gameOver()
        }
    }
    
    override func update(_ currentTime: TimeInterval) {
        // Called before each frame is rendered
    }
    
    func reset(){
        if canRestart {
            let gameScene: GameScene
            gameScene = GameScene(size: self.view!.bounds.size) // create your new scene
            let transition = SKTransition.fade(withDuration: 1.0) // create type of transition (you can check in documentation for more transtions)
            gameScene.scaleMode = .aspectFit
            self.view!.presentScene(gameScene, transition: transition)
        }
    }
    
    func createBackground() {
        let backgroundTexture = SKTexture(imageNamed: "road")
        
        for i in 0 ... 1 {
            let background = SKSpriteNode(texture: backgroundTexture)
            background.zPosition = -30
            background.name = "road"
            background.size = CGSize(width: screenWidth/2, height: background.size.height)
            background.anchorPoint = CGPoint.zero
            background.position = CGPoint(x: screenWidth/4, y: (backgroundTexture.size().height * CGFloat(i)) - CGFloat(1 * i))
            addChild(background)
            
            let moveDown = SKAction.moveBy(x: 0, y: -backgroundTexture.size().height, duration: 10)
            let moveReset = SKAction.moveBy(x: 0, y: backgroundTexture.size().height, duration: 0)
            let moveLoop = SKAction.sequence([moveDown, moveReset])
            let moveForever = SKAction.repeatForever(moveLoop)
            
            background.run(moveForever)
        }
        
    }
    
    func createCar(inLane offset: RoadLane) {
        let carTexture = SKTexture(imageNamed: "pink-car")
        
        let car = SKSpriteNode(texture: carTexture)
        car.zPosition = 20
        car.zRotation = -CGFloat.pi/2
        car.size = CGSize(width: 60, height: 50)
        car.position = CGPoint(x: screenWidth/4 + 40 + offset.rawValue, y: screenHeight+100)
        
        car.physicsBody = SKPhysicsBody(texture: carTexture, size: CGSize(width: 40, height: 50))

        addChild(car)
        
        let moveDown = SKAction.moveBy(x: 0, y: -screenHeight*1.2, duration: 4)
        let delete = SKAction.run {
            car.removeAllActions()
            car.removeFromParent()
        }
        let moveAction = SKAction.sequence([moveDown, delete])
        
        car.run(moveAction)
        
    }
    
    func gameOver() {
        
        removeAllActions()
        self.view?.gestureRecognizers?.removeAll()
        
        for node in children {
            node.removeAllActions()
        }
        
        let background = SKSpriteNode(imageNamed: "gameover")
        background.position = CGPoint(x: screenWidth/2, y: screenHeight/2+screenHeight/10)
        background.zPosition = 30
        addChild(background)
        
        
        restartLabel = SKLabelNode(fontNamed: "Chalkduster")
        restartLabel.text = "Tap anywhere to restart"
        restartLabel.horizontalAlignmentMode = .center
        restartLabel.fontSize = 15
        restartLabel.zPosition = 30
        restartLabel.isHidden = true
        addChild(restartLabel)
        restartLabel.position = CGPoint(x: screenWidth/2, y: screenHeight/2-screenHeight/20)
        
        let fadeIn = SKAction.fadeIn(withDuration: 0.8)
        let fadeOut = SKAction.fadeOut(withDuration: 0.8)
        let wait = SKAction.wait(forDuration: 0.5)
        let seq = SKAction.repeatForever(SKAction.sequence([fadeOut, wait, SKAction.run {
            self.restartLabel.isHidden = false
            }, fadeIn, wait]))
        restartLabel.run(seq)
        
        Timer.scheduledTimer(timeInterval: 2.0, target: self, selector: #selector(gameCanRestart), userInfo: nil, repeats: false)
        
    }
    
    @objc func gameCanRestart() {
        canRestart = true
    }
    
}
