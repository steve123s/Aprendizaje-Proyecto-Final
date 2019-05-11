//
//  Score.swift
//  Project23
//
//  Created by Daniel Esteban Salinas Suárez on 6/19/18.
//  Copyright © 2018 Servicio Esteban. All rights reserved.
//

import UIKit
import SpriteKit

class Player: SKSpriteNode {
    
    var turtleWalkingFrames: [SKTexture] = []
    
    init() {
        
        //Prepare animation
        let turtleAnimatedAtlas = SKTextureAtlas(named: "TurtleImages")
        var turtleWalkFrames: [SKTexture] = []
        let turtleImages = turtleAnimatedAtlas.textureNames.count
        for i in 1...turtleImages {
            let turtleTextureName = "turtle-\(i)"
            turtleWalkFrames.append(turtleAnimatedAtlas.textureNamed(turtleTextureName))
        }
        turtleWalkingFrames = turtleWalkFrames
        let firstFrameTexture = turtleWalkingFrames[0]
        
        super.init(texture: firstFrameTexture, color: UIColor.clear, size: firstFrameTexture.size())
        
        self.name = "player"
        self.position = CGPoint(x: screenWidth/4 + 45, y: screenHeight/10)
        self.size = CGSize(width: 60, height: 60)
        self.zPosition = 0
        self.physicsBody = SKPhysicsBody(texture: self.texture!, size: self.size)
        self.physicsBody?.contactTestBitMask = 1
        
        //Animation
        self.run(SKAction.repeatForever(
            SKAction.animate(with: turtleWalkingFrames,
                             timePerFrame: 0.03,
                             resize: false,
                             restore: true)),
                 withKey:"walkingTurtle")
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    
}

