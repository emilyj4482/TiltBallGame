//
//  GameScene.swift
//  TiltBallGame
//
//  Created by EMILY on 24/06/2025.
//

import SpriteKit
import CoreMotion

class GameScene: SKScene {
    
    private var motionManager = CMMotionManager()
    
    private var pathNode: SKShapeNode!
    private var ballNode: SKShapeNode!
    private var goalNode: SKShapeNode!
    
    override func didMove(to view: SKView) {
        size = view.bounds.size
        backgroundColor = .white
        
        let path = createRandomCurvedPath(size: size)
        setupPathNode(with: path)
        setupBallNode()
        setupGoalNode()
        
        physicsWorld.contactDelegate = self
        startDeviceMotionUpdates()
    }
    
    private func createRandomCurvedPath(size: CGSize) -> CGMutablePath {
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
        
        let path = CGMutablePath()
        path.move(to: startPoint)
        
        // Create control points closer to the path for smoother connections
        let controlPoint1 = CGPoint(
            x: (startPoint.x + corner1.x) / 2 + (corner1.x > startPoint.x ? -40 : 40),
            y: (startPoint.y + corner1.y) / 2
        )
        
        path.addQuadCurve(to: corner1, control: controlPoint1)
        
        let controlPoint2 = CGPoint(
            x: (corner1.x + corner2.x) / 2 + (corner2.x > corner1.x ? -60 : 60),
            y: (corner1.y + corner2.y) / 2
        )
        
        path.addQuadCurve(to: corner2, control: controlPoint2)
        
        let controlPoint3 = CGPoint(
            x: (corner2.x + corner3.x) / 2 + (corner3.x > corner2.x ? -60 : 60),
            y: (corner2.y + corner3.y) / 2
        )
        
        path.addQuadCurve(to: corner3, control: controlPoint3)
        
        let controlPoint4 = CGPoint(
            x: (corner3.x + endPoint.x) / 2 + (endPoint.x > corner3.x ? -40 : 40),
            y: (corner3.y + endPoint.y) / 2
        )
        
        path.addQuadCurve(to: endPoint, control: controlPoint4)
        
        return path
    }
    
    private func setupPathNode(with path: CGMutablePath) {
        // node for view - expanded path has weird white triangle blank. make clean and filled shape node.
        let subNode = SKShapeNode(path: path)
        
        subNode.strokeColor = .brown
        subNode.lineWidth = 60
        subNode.lineCap = .round
        subNode.lineJoin = .round
        
        addChild(subNode)
        
        // node for physics - to give all bounds physics body not just center line of the path, strokingWithWidth is needed
        let expandedPath = path.copy(strokingWithWidth: 60, lineCap: .round, lineJoin: .round, miterLimit: 0)
        
        pathNode = SKShapeNode(path: expandedPath)
        pathNode.strokeColor = .clear
        
        pathNode.physicsBody = SKPhysicsBody(edgeChainFrom: expandedPath)
        pathNode.physicsBody?.categoryBitMask = PhysicsCategory.path
        pathNode.physicsBody?.contactTestBitMask = PhysicsCategory.ball
        pathNode.physicsBody?.collisionBitMask = PhysicsCategory.none
        pathNode.physicsBody?.isDynamic = false
        
        addChild(pathNode)
    }
    
    private func setupBallNode() {
        ballNode = SKShapeNode(circleOfRadius: 20)
        
        ballNode.fillColor = [.systemTeal, .systemMint, .systemPink].randomElement() ?? .systemGray
        ballNode.strokeColor = .clear
        ballNode.lineWidth = 0
        ballNode.zPosition = 3
        ballNode.position = CGPoint(x: size.width / 2, y: size.height - 100)
        
        // add physicsbody
        ballNode.physicsBody = SKPhysicsBody(circleOfRadius: 20)
        ballNode.physicsBody?.categoryBitMask = PhysicsCategory.ball
        ballNode.physicsBody?.contactTestBitMask = PhysicsCategory.path | PhysicsCategory.goal
        ballNode.physicsBody?.collisionBitMask = PhysicsCategory.none
        ballNode.physicsBody?.isDynamic = true
        ballNode.physicsBody?.affectedByGravity = false
        ballNode.physicsBody?.linearDamping = 1.0
        
        addChild(ballNode)
    }
    
    private func setupGoalNode() {
        let position = CGPoint(x: size.width / 2, y: 100)
        
        let border = SKShapeNode(circleOfRadius: 30)
        border.fillColor = .gray
        border.strokeColor = .clear
        border.zPosition = 1
        border.position = position
        
        addChild(border)
                
        goalNode = SKShapeNode(circleOfRadius: 20)
        goalNode.fillColor = .black
        goalNode.strokeColor = .clear
        goalNode.zPosition = 2
        goalNode.position = position
        
        // add physicsbody
        goalNode.physicsBody = SKPhysicsBody(circleOfRadius: 5)
        goalNode.physicsBody?.categoryBitMask = PhysicsCategory.goal
        goalNode.physicsBody?.contactTestBitMask = PhysicsCategory.ball
        goalNode.physicsBody?.collisionBitMask = PhysicsCategory.none
        goalNode.physicsBody?.isDynamic = false
        
        addChild(goalNode)
    }
    
    override func update(_ currentTime: TimeInterval) {
        // current ball position
        let position = ballNode.position
        
        // make ball node never disappear from the frame
        if position.x > frame.maxX {
            ballNode.position.x = frame.minX
        } else if position.x < frame.minX {
            ballNode.position.x = frame.maxX
        }
        
        if position.y > frame.maxY {
            ballNode.position.y = frame.minY
        } else if position.y < frame.minY {
            ballNode.position.y = frame.maxY
        }
        
        if let path = pathNode.path, !path.contains(ballNode.position) {
            print("ball out of path")
        }
    }
    
    // debugging
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let location = touch.location(in: self)
        
        print(location)
    }
    
    deinit {
        motionManager.stopDeviceMotionUpdates()
    }
}

extension GameScene: SKPhysicsContactDelegate {
    private func startDeviceMotionUpdates() {
        guard motionManager.isDeviceMotionAvailable else { return }
        
        // update interval : 60 updates per 1 second
        motionManager.deviceMotionUpdateInterval = 1.0 / 60.0
        
        // start device motion updates
        motionManager.startDeviceMotionUpdates(to: .main) { [weak self] (motion, error) in
            guard let motion = motion else {
                print("[Error] Failed to get device motion data")
                return
            }
            
            if let error = error {
                print("[Error] \(error.localizedDescription)")
                return
            }
            
            self?.handleDeviceMotionUpdates(motion)
        }
    }
    
    private func handleDeviceMotionUpdates(_ motion: CMDeviceMotion) {
        // getting device orientation data
        let attitude = motion.attitude
        
        /*
         configuration
         - sensitivity : high
         - deadzone : ignore small movements to reduce jitter
         */
        let sensitivity: CGFloat = 600.0
        let deadZone: Double = 0.1
        
        // roll : left/right tilt
        var roll = attitude.roll
        // pitch : forward/backward tilt
        var pitch = attitude.pitch
        
        // apply dead zone
        if abs(roll) < deadZone { roll = 0 }
        if abs(pitch) < deadZone { pitch = 0 }
        
        // calculate velocities : convert gradient to velocity
        let velocityX = CGFloat(roll) * sensitivity
        let velocityY = CGFloat(-pitch) * sensitivity   // negative for intuitive control
        
        // apply movement using physics body
        if let physicsBody = ballNode.physicsBody {
            physicsBody.velocity = CGVector(dx: velocityX, dy: velocityY)
        }
    }
    
    func didBegin(_ contact: SKPhysicsContact) {
        if (contact.bodyA.categoryBitMask == PhysicsCategory.ball && contact.bodyB.categoryBitMask == PhysicsCategory.goal) ||
            (contact.bodyB.categoryBitMask == PhysicsCategory.ball && contact.bodyA.categoryBitMask == PhysicsCategory.goal) {
            print("goal")
        }
    }
}
