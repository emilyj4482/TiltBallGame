//
//  ContentView.swift
//  TiltBallGame
//
//  Created by EMILY on 24/06/2025.
//

import SwiftUI
import SpriteKit

struct ContentView: View {
    
    private var scene: SKScene = GameScene()
    
    var body: some View {
        SpriteView(scene: scene)
            .ignoresSafeArea()
    }
}

#Preview {
    ContentView()
}
