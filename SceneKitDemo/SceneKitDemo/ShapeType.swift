//
//  ShapeType.swift
//  SceneKitDemo
//
//  Created by CallMeDaKing on 2017/8/13.
//  Copyright © 2017年 CallMeDaKing. All rights reserved.
//

import Foundation

enum ShapeType:Int {
    
    case box = 0
    case sphere
    case pyramid
    case torus
    case capsule
    case cylinder
    case cone
    case tube
    
    static func random() -> ShapeType{
        let maxValue = tube.rawValue
        let rand = arc4random_uniform(UInt32(maxValue + 1))
        return ShapeType(rawValue: Int(rand))!
        
        /**The code above is relatively straightforward:
         1. You create a new enum named ShapeType that enumerates the various shapes.
         2. You also define a static method named random() that generates a random ShapeType. This feature will come in handy later on in your game.*/
    }
}
