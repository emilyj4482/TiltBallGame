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
        
        let path = createRandomCurvedPath(size: size)
        createShape(with: path)
        createBall()
        createGoal()
    }
    
    private func createRandomCurvedPath(size: CGSize) -> UIBezierPath {
        let xPoint: CGFloat = size.width / 2
        let yOffset: CGFloat = 100
        
        let startPoint = CGPoint(x: xPoint, y: size.height - yOffset)
        let endPoint = CGPoint(x: xPoint, y: yOffset)
        
        // Divide the height into sections to ensure points are distributed vertically
        let sectionHeight = (size.height - 2 * yOffset) / 4
        
        // Randomly decide if we start curving left or right
        let startLeft = Bool.random()
        
        // Generate 3 corner points with alternating sides based on random start
        let corner1 = CGPoint(
            x: startLeft ?
            CGFloat.random(in: 80...(size.width * 0.4)) :  // Left side
            CGFloat.random(in: (size.width * 0.6)...(size.width - 80)), // Right side
            y: size.height - yOffset - sectionHeight
        )
        
        let corner2 = CGPoint(
            x: startLeft ?
            CGFloat.random(in: (size.width * 0.6)...(size.width - 80)) : // Right side
            CGFloat.random(in: 80...(size.width * 0.4)), // Left side
            y: size.height - yOffset - (sectionHeight * 2)
        )
        
        let corner3 = CGPoint(
            x: startLeft ?
            CGFloat.random(in: 80...(size.width * 0.4)) :  // Left side again
            CGFloat.random(in: (size.width * 0.6)...(size.width - 80)), // Right side again
            y: size.height - yOffset - (sectionHeight * 3)
        )
        
        let path = UIBezierPath()
        path.move(to: startPoint)
        
        // Create control points closer to the path for smoother connections
        let controlPoint1 = CGPoint(
            x: (startPoint.x + corner1.x) / 2 + (corner1.x > startPoint.x ? -40 : 40),
            y: (startPoint.y + corner1.y) / 2
        )
        
        path.addQuadCurve(to: corner1, controlPoint: controlPoint1)
        
        let controlPoint2 = CGPoint(
            x: (corner1.x + corner2.x) / 2 + (corner2.x > corner1.x ? -60 : 60),
            y: (corner1.y + corner2.y) / 2
        )
        
        path.addQuadCurve(to: corner2, controlPoint: controlPoint2)
        
        let controlPoint3 = CGPoint(
            x: (corner2.x + corner3.x) / 2 + (corner3.x > corner2.x ? -60 : 60),
            y: (corner2.y + corner3.y) / 2
        )
        
        path.addQuadCurve(to: corner3, controlPoint: controlPoint3)
        
        let controlPoint4 = CGPoint(
            x: (corner3.x + endPoint.x) / 2 + (endPoint.x > corner3.x ? -40 : 40),
            y: (corner3.y + endPoint.y) / 2
        )
        
        path.addQuadCurve(to: endPoint, controlPoint: controlPoint4)
        
        return path
    }
    
    private func createShape(with path: UIBezierPath) {
        let shape = SKShapeNode(path: path.cgPath)
        
        shape.lineWidth = 60
        shape.strokeColor = .brown
        shape.lineJoin = .round
        
        // add physicsbody
        shape.physicsBody = SKPhysicsBody(edgeChainFrom: path.cgPath)
        shape.physicsBody?.categoryBitMask = PhysicsCategory.path
        shape.physicsBody?.contactTestBitMask = PhysicsCategory.ball
        shape.physicsBody?.isDynamic = false
        
        addChild(shape)
    }
    
    private func createBall() {
        let shape = SKShapeNode(rectOf: CGSize(width: 40, height: 40), cornerRadius: 20)
        
        shape.fillColor = [.systemTeal, .systemMint, .systemPink].randomElement() ?? .systemGray
        shape.strokeColor = .clear
        shape.zPosition = 3
        shape.position = CGPoint(x: size.width / 2, y: size.height - 100)
        
        // add physicsbody
        shape.physicsBody = SKPhysicsBody(circleOfRadius: 20)
        shape.physicsBody?.categoryBitMask = PhysicsCategory.ball
        shape.physicsBody?.contactTestBitMask = PhysicsCategory.path | PhysicsCategory.goal
        
        addChild(shape)
    }
    
    private func createGoal() {
        let position = CGPoint(x: size.width / 2, y: 100)
        
        let border = SKShapeNode(rectOf: CGSize(width: 60, height: 60), cornerRadius: 30)
        border.fillColor = .gray
        border.strokeColor = .clear
        border.zPosition = 1
        border.position = position
        
        addChild(border)
                
        let goal = SKShapeNode(rectOf: CGSize(width: 40, height: 40), cornerRadius: 20)
        goal.fillColor = .black
        goal.strokeColor = .clear
        goal.zPosition = 2
        goal.position = position
        
        // add physicsbody
        goal.physicsBody = SKPhysicsBody(circleOfRadius: 20)
        goal.physicsBody?.categoryBitMask = PhysicsCategory.goal
        goal.physicsBody?.contactTestBitMask = PhysicsCategory.ball
        goal.physicsBody?.isDynamic = false
        
        addChild(goal)
    }
    
    // debugging
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let location = touch.location(in: self)
        
        print(location)
    }
}
