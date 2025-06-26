//
//  PhysicsCategory.swift
//  TiltBallGame
//
//  Created by EMILY on 26/06/2025.
//

import Foundation

struct PhysicsCategory {
    static let ball: UInt32 = 0x1 << 0
    static let path: UInt32 = 0x1 << 1
    static let goal: UInt32 = 0x1 << 2
}
