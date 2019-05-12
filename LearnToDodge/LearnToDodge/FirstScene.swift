//
//  GameplayLogic.swift
//  Detective Emoji
//
//  Created by Daniel Salinas on 18.03.19.
//  Copyright © 2019 danielsalinas. All rights reserved.
//

import SpriteKit
import Foundation
import GameKit

public class FirstScene: SKScene {
    
    //------------------------------------
    // MARK: - Properties
    //------------------------------------
    
    let emojis: [String] = ["🚗","🚕","🚙","🚐","🚚"]
    
    private var label : SKLabelNode!
    
    //------------------------------------
    // MARK: - didMove
    //------------------------------------
    
    public override func didMove(to view: SKView) {
        
        backgroundColor = UIColor.black

        let backgroundTexture = SKTexture(imageNamed: "road")
        let background = SKSpriteNode(texture: backgroundTexture)
        background.zPosition = -30
        background.name = "road"
        background.size = CGSize(width: screenWidth/2, height: background.size.height)
        background.anchorPoint = CGPoint.zero
        background.position = CGPoint(x: screenWidth/4, y: 0)
        addChild(background)
        
        let title = SKSpriteNode(imageNamed: "title.png")
        title.zPosition = 2
        title.setScale(0.6)
        title.position = CGPoint(x: frame.midX, y: frame.maxY*0.8)
        title.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: title.frame.width * 1.25 , height: title.frame.height * 1.25))
        title.physicsBody?.isDynamic = false
        addChild(title)
        
        let subtitle = SKSpriteNode(imageNamed: "subtitle.png")
        subtitle.zPosition = 2
        subtitle.setScale(0.55)
        subtitle.position = CGPoint(x: frame.midX, y: frame.maxY*0.75)
        subtitle.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: title.frame.width, height: title.frame.height))
        subtitle.physicsBody?.isDynamic = false
        addChild(subtitle)
        
        let button = AboutButton(texture: SKTexture(imageNamed: "button-play"))
        button.name = "button-play"
        button.setScale(1.5)
        button.position = CGPoint(x: self.frame.midX, y: self.frame.maxY*0.2)
        button.zPosition = 2
        button.delegate = self
        
        let button2 = AboutButton(texture: SKTexture(imageNamed: "button-play2"))
        button2.name = "button-play2"
        button2.setScale(1.5)
        button2.position = CGPoint(x: self.frame.midX, y: self.frame.maxY*0.1)
        button2.zPosition = 2
        button2.alpha = 0
        button2.delegate = self
        
        button.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: button.frame.width * 1.25 , height: button.frame.height * 1.25))
        button.physicsBody?.isDynamic = false
        button.alpha = 0
        let fadeInOut = SKAction.sequence([.fadeIn(withDuration: 0.4),
                                           .fadeOut(withDuration: 2.0)])
        button.run(.repeatForever(fadeInOut))
        addChild(button)
        addChild(button2)
        let fadeInAction = SKAction.fadeIn(withDuration: 1.0)
        button2.run(fadeInAction)
        
        let wait = SKAction.wait(forDuration: 0.1)
        let dropAction = SKAction.run {
            self.dropRandomEmoji()
        }
        let pinAction = SKAction.run {
            for child in self.children {
                child.physicsBody?.isDynamic = false
            }
        }
        let stopAction = SKAction.run {
            if self.children.count > 60 {
                self.removeAllActions()
            }
        }
        run(SKAction.repeatForever(SKAction.sequence([dropAction, wait, pinAction, stopAction])))
    }
    
    //------------------------------------
    // MARK: - Private Methods
    //------------------------------------
    
    private func dropRandomEmoji() {
        let randomIndex = GKRandomSource.sharedRandom().nextInt(upperBound: emojis.count)
        let emojiLabel = SKLabelNode(text: emojis[randomIndex])
        emojiLabel.fontSize = CGFloat(40)
        let xSpawn = CGFloat.random(in: 0.0...frame.maxX)
        let ySpawn = CGFloat.random(in: 0.0...frame.maxY)
        emojiLabel.position = CGPoint(x: xSpawn, y: ySpawn)
        emojiLabel.physicsBody = SKPhysicsBody(circleOfRadius: emojiLabel.fontSize * 1.25)
        
        let xRange = SKRange(lowerLimit: -20,
                             upperLimit: frame.size.width + 20 )
        let yRange = SKRange(lowerLimit: 0,
                             upperLimit: frame.size.height)
        emojiLabel.constraints = [SKConstraint.positionX(xRange,y:yRange)]
        
        addChild(emojiLabel)
    }
    
}

//------------------------------------
// MARK: - Extensions
//------------------------------------

extension FirstScene: PlayButtonDelegate {
    
    func didTapPlay(sender: PlayButton) {
        
        
    }
    
}

extension FirstScene: AboutButtonDelegate {
    
    func didTapAbout(sender: AboutButton) {
        let transition = SKTransition.crossFade(withDuration: 0)
        let scene1 = GameScene(fileNamed:"GameScene")
        if sender.name == "button-play" {
            scene1?.isAutomatic = false
        } else {
            scene1?.isAutomatic = true
        }
        scene1!.scaleMode = SKSceneScaleMode.aspectFill
        self.scene!.view?.presentScene(scene1!, transition: transition)
    }
    
}
