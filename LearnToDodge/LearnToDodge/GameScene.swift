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

var algorithm: GeneticAlgorithm!

class GameScene: SKScene, SKPhysicsContactDelegate {
    
    //------------------------------------
    // MARK: - Enums
    //------------------------------------
    
    enum RoadLane: CGFloat {
        case left = 0
        case right = 75
    }
    
    //------------------------------------
    // MARK: - Properties
    //------------------------------------
    
    //let goal: UInt16 = UInt16.subtractWithOverflow(0, 1).0
    var goal: UInt16 = 7351
    let populationSize = 100
    
    var canRestart = false
    var isAutomatic = false
    
    var player = Player()
    
    var level: Double = 0.0
    var difficultyMultiplier: Double = 1
    
    var playerPosition: RoadLane = .left
    var scoreLabel = Score()
    
    //------------------------------------
    // MARK: - Overloaded Methods
    //------------------------------------
    
    override func didMove(to view: SKView) {
        scene!.size = view.bounds.size
        backgroundColor = UIColor.init(hue: 0.58, saturation: 0.63, brightness: 0.35, alpha: 1)
        
        difficultyMultiplier = 1 - (level * 0.1)
        
        createBackground()
        
        // Create car sequence for given number
        var sequence: [SKAction] = []
        for bit in goal.bits.reversed() {
            let placeCarAction = SKAction.run {
                bit == false ? self.createCar(inLane: .left) : self.createCar(inLane: .right)
            }
            let waitAction = SKAction.wait(forDuration: 1.0 * difficultyMultiplier)
            sequence.append(placeCarAction)
            sequence.append(waitAction)
        }
        
        sequence.append(SKAction.wait(forDuration: 3))
        let finish = SKAction.run {
            self.levelWon()
        }
        sequence.append(finish)
        
        let actionsSequence = SKAction.sequence(sequence)
        run(actionsSequence)
        
        addChild(player)
        addChild(scoreLabel)
        
        physicsWorld.gravity = CGVector(dx: 0, dy: 0)
        physicsWorld.contactDelegate = self
        
        if isAutomatic {
            automaticTraining()
        } else {
            let swipeLeft = UISwipeGestureRecognizer(target: self, action: #selector(handleGesture))
            swipeLeft.direction = .left
            self.view?.addGestureRecognizer(swipeLeft)
            
            let swipeRight = UISwipeGestureRecognizer(target: self, action: #selector(handleGesture))
            swipeRight.direction = .right
            self.view?.addGestureRecognizer(swipeRight)
        }
        
    }
    
    //------------------------------------
    // MARK: - Handlers
    //------------------------------------
    
    @objc private func handleGesture(gesture: UISwipeGestureRecognizer) -> Void {
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
    
    @objc private func gameCanRestart() {
        canRestart = true
    }
    
    private func movePlayer(toLane offset: RoadLane) {
        player.position = CGPoint(x: screenWidth/4 + 45 + offset.rawValue, y: screenHeight/10)
    }
    
    //------------------------------------
    // MARK: - Physics
    //------------------------------------
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        reset()
    }
    
    func didBegin(_ contact: SKPhysicsContact) {
        if contact.bodyA.node?.name == "player" || contact.bodyB.node?.name == "player" {
            player.name = ""
            gameOver()
        }
    }
 
}

//------------------------------------
// MARK: - Genetic Extension
//------------------------------------

private extension GameScene {
    
    func automaticTraining() {
        
        if algorithm == nil {
            print("Looking for:\t\t \(goal.asBinaryString)")
            algorithm = GeneticAlgorithm(numberToSolve: goal, populationSize: populationSize)
        }
        
        let bestIndividual = algorithm.population.first!
        let fitness = bestIndividual.fitness(towards: goal)
        let fitnessPercentage = Int(Double(fitness) / 16 * 100)
        
        print("Fittest individual:\t \(bestIndividual.number.asBinaryString) (fitness: \(fitnessPercentage)%)")
        
        // Move player
        var sequence: [SKAction] = []
        let initialWait = SKAction.wait(forDuration: 3.2)
        sequence.append(initialWait)
        
        for bit in bestIndividual.number.bits.reversed() {
            let movePlayerAction = SKAction.run {
                bit == false ? self.movePlayer(toLane: .right) : self.movePlayer(toLane: .left)
            }
            let waitAction = SKAction.wait(forDuration: 1.0 * difficultyMultiplier)
            sequence.append(movePlayerAction)
            sequence.append(waitAction)
        }
        
        let finish = SKAction.run {
            self.levelWon()
        }
        
        sequence.append(finish)
        let actionsSequence = SKAction.sequence(sequence)
        run(actionsSequence)
        
    }
    
}

//------------------------------------
// MARK: - Gameplay Extension
//------------------------------------

private extension GameScene {
    
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
        car.zPosition = 0
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
        
        if isAutomatic {
            algorithm.runGeneration()
            gameCanRestart()
            reset()
            return
        }
        
        let title = SKSpriteNode(imageNamed: "oops.png")
        title.zPosition = 2
        title.setScale(0.6)
        title.position = CGPoint(x: self.frame.midX, y: self.frame.maxY*0.8)
        title.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: title.frame.width * 1.25 , height: title.frame.height * 1.25))
        title.physicsBody?.isDynamic = false
        self.addChild(title)
        
        let button = AboutButton(texture: SKTexture(imageNamed: "button-to-menu"))
        button.name = "button-to-menu"
        button.setScale(1.5)
        button.position = CGPoint(x: self.frame.midX, y: self.frame.maxY*0.2)
        button.zPosition = 2
        button.delegate = self
        addChild(button)
        
        let button2 = AboutButton(texture: SKTexture(imageNamed: "button-try-again"))
        button2.name = "button-try-again"
        button2.setScale(1.5)
        button2.position = CGPoint(x: self.frame.midX, y: self.frame.maxY*0.3)
        button2.zPosition = 2
        button2.delegate = self
        addChild(button2)
        
        let fadeIn = SKAction.fadeIn(withDuration: 0.8)
        let fadeOut = SKAction.fadeOut(withDuration: 0.8)
        let wait = SKAction.wait(forDuration: 0.5)
        let seq = SKAction.repeatForever(SKAction.sequence([fadeOut, wait, SKAction.run {
            button2.isHidden = false
            }, fadeIn, wait]))
        button2.run(seq)
        
        Timer.scheduledTimer(timeInterval: 2.0, target: self, selector: #selector(gameCanRestart), userInfo: nil, repeats: false)
        
    }
    
    func reset(){
        if canRestart {
            let gameScene: GameScene
            gameScene = GameScene(size: self.view!.bounds.size)
            gameScene.isAutomatic = isAutomatic ? true : false
            gameScene.level = level
            gameScene.scoreLabel.score = Int(level) + 1
            gameScene.goal = goal
            let transition = SKTransition.fade(withDuration: 1.0)
            gameScene.scaleMode = .aspectFit
            self.view!.presentScene(gameScene, transition: transition)
        }
    }
    
     func levelWon() {
        
        print("WINNNN")
        
        if let algorithm = algorithm {
            print("!Solved! after \(algorithm.generationNumber) generations")
        }
        
        let title = SKSpriteNode(imageNamed: "you-win.png")
        title.zPosition = 2
        title.setScale(0.6)
        title.position = CGPoint(x: self.frame.midX, y: self.frame.maxY*0.8)
        title.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: title.frame.width * 1.25 , height: title.frame.height * 1.25))
        title.physicsBody?.isDynamic = false
        self.addChild(title)
        
        let button = AboutButton(texture: SKTexture(imageNamed: "button-next-level"))
        button.name = "button-next-level"
        button.setScale(1.5)
        button.position = CGPoint(x: self.frame.midX, y: self.frame.maxY*0.3)
        button.zPosition = 2
        button.delegate = self
        self.addChild(button)
        
        let button2 = AboutButton(texture: SKTexture(imageNamed: "button-to-menu"))
        button2.name = "button-to-menu"
        button2.setScale(1.5)
        button2.position = CGPoint(x: self.frame.midX, y: self.frame.maxY*0.2)
        button2.zPosition = 2
        button2.delegate = self
        self.addChild(button2)
        
    }
    
    func moveToNextLevel() {
        
        let transition = SKTransition.crossFade(withDuration: 0)
        let scene = GameScene(fileNamed:"GameScene")
        scene!.scaleMode = SKSceneScaleMode.aspectFill
        scene!.level = level + 1
        scene!.isAutomatic = isAutomatic ? true : false
        scene!.scoreLabel.score = Int(level) + 2
        scene!.goal = UInt16.random(in: 0...UInt16.max)
        algorithm = nil
        self.scene!.view?.presentScene(scene!, transition: transition)
        
    }
    
}

//------------------------------------
// MARK: - Button Extensions
//------------------------------------

extension GameScene: AboutButtonDelegate {
    
    func didTapAbout(sender: AboutButton) {
        if sender.name == "button-try-again" {
            reset()
        } else if sender.name == "button-to-menu" {
            let transition = SKTransition.crossFade(withDuration: 0)
            let scene = FirstScene(fileNamed:"FirstScene")
            scene!.scaleMode = SKSceneScaleMode.aspectFill
            self.scene!.view?.presentScene(scene!, transition: transition)
        } else {
            moveToNextLevel()
        }
    }
    
}
