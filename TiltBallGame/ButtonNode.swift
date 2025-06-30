//
//  GameEndView.swift
//  TiltBallGame
//
//  Created by EMILY on 30/06/2025.
//

import SpriteKit

enum GameState {
    case over
    case clear
    
    var title: String {
        switch self {
        case .over:
            return "Game Over"
        case .clear:
            return "Game Clear"
        }
    }
    
    var buttonText: String {
        switch self {
        case .over:
            return "retry"
        case .clear:
            return "restart"
        }
    }
    
    var textColor: UIColor {
        switch self {
        case .over:
            return .red
        case .clear:
            return .blue
        }
    }
}

class ButtonNode: SKSpriteNode {
    
    var action: (() -> Void)?
    
    init(state: GameState) {
        super.init(texture: nil, color: .clear, size: .zero)
        isUserInteractionEnabled = true
        setupLabel(state: state)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupLabel(state: GameState) {
        let label = SKLabelNode(text: state.buttonText)
        label.name = state.buttonText
        label.fontName = "HelveticaNeue-Light"
        label.fontSize = 40
        label.fontColor = state.textColor
        label.zPosition = 11
        addChild(label)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        action?()
    }
}
