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
    
    private var ballNode: SKShapeNode!
    private var goalNode: SKShapeNode!
    
    private var pathPhysicalNode: SKShapeNode!
    private var pathVisualNode: SKShapeNode!
    
    override func didMove(to view: SKView) {
        size = view.bounds.size
        backgroundColor = .white
        
        let path = makePath(size: size)
        setupPathNode(with: path)
        setupBallNode()
        setupGoalNode()
        
        physicsWorld.contactDelegate = self
        startDeviceMotionUpdates()
    }
    
    private func makePath(size: CGSize) -> CGMutablePath {
        let xPoint: CGFloat = size.width / 2
        let yOffset: CGFloat = 100
        
        let startPoint = CGPoint(x: xPoint, y: size.height - yOffset)
        let endPoint = CGPoint(x: xPoint, y: yOffset)
        
        let randomControlPoints = makeRandomControlPoints(from: startPoint, to: endPoint)
        
        let path = CGMutablePath()
        path.move(to: startPoint)
        path.addCurve(
            to: endPoint,
            control1: randomControlPoints.control1,
            control2: randomControlPoints.control2
        )
        
        return path
    }
    
    private func makeRandomControlPoints(from startPoint: CGPoint, to endPoint: CGPoint) -> (control1: CGPoint, control2: CGPoint) {
        let startLeft = Bool.random()
        
        // Calculate the vertical distance and split into sections
        let totalHeight = startPoint.y - endPoint.y
        let firstThird = totalHeight / 3
        let secondThird = totalHeight * 2 / 3
        
        // Define horizontal offset range for more dramatic curves
        let minOffset: CGFloat = size.width * 0.5  // 50% of screen width
        let maxOffset: CGFloat = size.width * 1.1   // 110% of screen width
        
        let centerX = startPoint.x
        
        // First control point - in the upper third, curved to one side
        let control1X: CGFloat
        let control1Y = startPoint.y - firstThird + CGFloat.random(in: -50...50)
        
        if startLeft {
            // Curve to the left
            control1X = centerX - CGFloat.random(in: minOffset...maxOffset)
        } else {
            // Curve to the right
            control1X = centerX + CGFloat.random(in: minOffset...maxOffset)
        }
        
        let controlPoint1 = CGPoint(x: control1X, y: control1Y)
        
        // Second control point - in the lower third, curved to the opposite side
        let control2X: CGFloat
        let control2Y = startPoint.y - secondThird + CGFloat.random(in: -50...50)
        
        if startLeft {
            // Curve to the right (opposite of first control point)
            control2X = centerX + CGFloat.random(in: minOffset...maxOffset)
        } else {
            // Curve to the left (opposite of first control point)
            control2X = centerX - CGFloat.random(in: minOffset...maxOffset)
        }
        
        let controlPoint2 = CGPoint(x: control2X, y: control2Y)
        
        return (controlPoint1, controlPoint2)
    }
    
    private func setupPathNode(with path: CGMutablePath) {
        // node for view
        pathVisualNode = SKShapeNode(path: path)
        
        pathVisualNode.strokeColor = .brown
        pathVisualNode.lineWidth = 60
        pathVisualNode.lineCap = .round
        pathVisualNode.lineJoin = .round
        
        addChild(pathVisualNode)
        
        // node for actual physics - to give outer line physicsbody not the centre line
        let expandedPath = path.copy(strokingWithWidth: 80, lineCap: .round, lineJoin: .round, miterLimit: 0)
        
        pathPhysicalNode = SKShapeNode(path: expandedPath)
        pathPhysicalNode.strokeColor = .clear
        
        pathPhysicalNode.physicsBody = SKPhysicsBody(edgeChainFrom: expandedPath)
        pathPhysicalNode.physicsBody?.categoryBitMask = PhysicsCategory.path
        pathPhysicalNode.physicsBody?.contactTestBitMask = PhysicsCategory.ball
        pathPhysicalNode.physicsBody?.collisionBitMask = PhysicsCategory.none
        pathPhysicalNode.physicsBody?.isDynamic = false
        
        addChild(pathPhysicalNode)
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
    
    deinit {
        motionManager.stopDeviceMotionUpdates()
    }
    
    private var isGameEndScreenVisible = false
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
            ballNode.physicsBody?.isDynamic = false
            
            let moveAction = SKAction.move(to: goalNode.position, duration: 0.5)
            ballNode.run(moveAction) { [weak self] in
                self?.gameEnd(.clear)
            }
        }
        
        if (contact.bodyA.categoryBitMask == PhysicsCategory.ball && contact.bodyB.categoryBitMask == PhysicsCategory.path) ||
            (contact.bodyB.categoryBitMask == PhysicsCategory.ball && contact.bodyA.categoryBitMask == PhysicsCategory.path) {
            ballNode.physicsBody?.isDynamic = false
            gameEnd(.over)
        }
    }
    
    private func gameEnd(_ state: GameState) {
        // prevent multiple gray covers from quick multiple times of calls
        guard !isGameEndScreenVisible else { return }
        isGameEndScreenVisible = true
        
        // gray scale visible background cover
        let grayCover = SKSpriteNode(color: .gray.withAlphaComponent(0.5), size: size)
        grayCover.anchorPoint = .zero
        grayCover.zPosition = 10
        grayCover.alpha = 0
        addChild(grayCover)
        
        grayCover.run(SKAction.fadeIn(withDuration: 0.3))
        
        let titleLabel = SKLabelNode(text: state.title)
        titleLabel.fontName = "HelveticaNeue-Light"
        titleLabel.fontSize = 60
        titleLabel.fontColor = .black
        titleLabel.zPosition = 11
        titleLabel.position = CGPoint(x: size.width / 2, y: size.height / 2 + 100)
        grayCover.addChild(titleLabel)
        
        let button = ButtonNode(state: state)
        button.position = CGPoint(x: size.width / 2, y: size.height / 2 - 50)
        
        button.action = { [weak self] in
            self?.resetBallPosition()
            
            if state == .clear {
                self?.restart()
            }
            
            grayCover.run(SKAction.fadeOut(withDuration: 0.2)) {
                grayCover.removeFromParent()
                self?.isGameEndScreenVisible = false
                self?.isUserInteractionEnabled = true
            }
        }
        
        grayCover.addChild(button)
    }
    
    private func resetBallPosition() {
        guard ballNode.parent != nil else { return }
        ballNode.position = CGPoint(x: size.width / 2, y: size.height - 100)
        ballNode.physicsBody?.isDynamic = true
    }
    
    private func restart() {
        pathPhysicalNode.removeFromParent()
        pathVisualNode.removeFromParent()
        
        let path = makePath(size: size)
        setupPathNode(with: path)
    }
}
