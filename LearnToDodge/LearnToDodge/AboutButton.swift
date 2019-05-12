//
//  AboutButton.swift
//  Detective Emoji
//
//  Created by Daniel Salinas on 18.03.19.
//  Copyright © 2019 danielsalinas. All rights reserved.
//

import SpriteKit

//------------------------------------
// MARK: - Protocol
//------------------------------------

protocol AboutButtonDelegate: class {
    func didTapAbout(sender: AboutButton)
}

public class AboutButton: SKSpriteNode {
    
    //------------------------------------
    // MARK: - Properties
    //------------------------------------
    
    weak var delegate: AboutButtonDelegate?
    
    //------------------------------------
    // MARK: - Initializers
    //------------------------------------
    
    init() {
        let texture = SKTexture(imageNamed: "aboutButton")
        
        let color = SKColor.red
        let size = CGSize(width: 120, height: 36)
        super.init(texture: texture, color: color, size: size)
        
        isUserInteractionEnabled = true
        zPosition = 1
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //------------------------------------
    // MARK: - Touches
    //------------------------------------
    
    public override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        alpha = 0.5
    }
    
    public override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesMoved(touches, with: event)
        let alphaAction = SKAction.fadeAlpha(to: 0.5, duration: 0.10)
        alphaAction.timingMode = .easeInEaseOut
        run(alphaAction)
    }
    
    public override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesEnded(touches, with: event)
        performButtonAppearanceResetAnimation()
        delegate?.didTapAbout(sender: self)
        
    }
    
    public override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesCancelled(touches, with: event)
        performButtonAppearanceResetAnimation()
    }
    
    //------------------------------------
    // MARK: - Private Methods
    //------------------------------------
    
    private func performButtonAppearanceResetAnimation() {
        let alphaAction = SKAction.fadeAlpha(to: 1.0, duration: 0.10)
        alphaAction.timingMode = .easeInEaseOut
        run(alphaAction)
    }
    
}

