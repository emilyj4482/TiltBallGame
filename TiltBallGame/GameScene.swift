//
//  GameScene.swift
//  TiltBallGame
//
//  Created by EMILY on 24/06/2025.
//

import SpriteKit

class GameScene: SKScene {
    override func didMove(to view: SKView) {
        size = view.bounds.size
        backgroundColor = .white
        
        let path = createPath()
        createShape(with: path)
    }
    
    private func createPath() -> CGMutablePath {
        let xPoint: CGFloat = size.width / 2
        let yOffset: CGFloat = 100
        
        let startPoint = CGPoint(x: xPoint, y: size.height - yOffset)
        let endPoint = CGPoint(x: xPoint, y: yOffset)
        
        let midPoint = CGPoint(x: xPoint, y: (startPoint.y - endPoint.y) * 0.4)
        
        let path = CGMutablePath()
        path.move(to: startPoint)
        
        path.addCurve(
            to: midPoint,
            control1: CGPoint(x: 100 * 0.1, y: 580 * 0.7),
            control2: CGPoint(x: 300 * 1.5, y: 386 * 1.3)
        )
        
        path.addQuadCurve(
            to: endPoint,
            control: CGPoint(x: 100 * 0.5, y: 193 * 0.9)
        )
        
        return path
    }
    
    private func createShape(with path: CGPath) {
        let shape = SKShapeNode(path: path)
        shape.lineWidth = 70
        shape.strokeColor = .brown
        addChild(shape)
    }
    
    // debugging
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let location = touch.location(in: self)
        
        print(location)
    }
}

