//
//  Color.swift
//  ball-sort
//
//  Created by Eric Dong on 3/8/19.
//  Copyright © 2019 Tea Club. All rights reserved.
//

import SpriteKit

//  Maps color string to matching system color
let SystemColors: [String: UIColor] = [
    "blue": UIColor(red: 0, green: 0.294, blue: 1.0, alpha: 1.0),
    "green": UIColor.green,
    "orange": UIColor.orange,
    "pink": UIColor.init(red: 1, green: 0.078, blue: 0.576, alpha: 1.0),
    "teal": UIColor.cyan,
    "yellow": UIColor.yellow
]

enum Color: Int, CaseIterable {
    case Blue = 0, Green, Orange, Pink, Teal, Yellow
    
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
