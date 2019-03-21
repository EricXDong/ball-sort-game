//
//  Color.swift
//  ball-sort
//
//  Created by Eric Dong on 3/8/19.
//  Copyright © 2019 Tea Club. All rights reserved.
//

import SpriteKit

enum Color: Int, CaseIterable {
    case Blue = 0, Green, Orange, Pink, Red, Teal, Yellow
    
    var colorName: String {
        switch self {
        case .Blue:
            return "blue"
        case .Green:
            return "green"
        case .Orange:
            return "orange"
        case .Pink:
            return "pink"
        case .Red:
            return "red"
        case .Teal:
            return "teal"
        case .Yellow:
            return "yellow"
        }
    }
    
    static var count: UInt32 {
        return UInt32(Color.allCases.count)
    }
    
    static func random() -> Color {
        return Color(rawValue: Int(arc4random_uniform(Color.count)))!
    }
    
    static func getTwoRandomColors() -> (Color, Color) {
        let firstColor = Color.random()
        var secondColor = Color.random()
        while secondColor == firstColor {
            secondColor = Color.random()
        }
        return (firstColor, secondColor)
    }
}
