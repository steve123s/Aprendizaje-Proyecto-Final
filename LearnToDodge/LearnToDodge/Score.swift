//
//  Score.swift
//  Project23
//
//  Created by Daniel Esteban Salinas Suárez on 6/19/18.
//  Copyright © 2018 Servicio Esteban. All rights reserved.
//

import UIKit
import SpriteKit

class Score: SKLabelNode {
    
    override init() {
        super.init()
        self.fontName = "Chalkduster"
        self.name = "scoreLabel"
        self.position = CGPoint(x: 16, y: screenHeight - 50)
        self.horizontalAlignmentMode = .left
        self.text = "Level \(score)"
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    var score = 1 {
        didSet {
            self.text = "Level \(score)"
        }
    }
    
}
