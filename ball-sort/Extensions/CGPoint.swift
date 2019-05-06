//
//  CGPoint.swift
//  ball-sort
//
//  Created by Eric Dong on 5/5/19.
//  Copyright © 2019 Tea Club. All rights reserved.
//

import SpriteKit

extension CGPoint {
    
    /**
     Calculates a distance to the given point.
     https://stackoverflow.com/questions/21251706/ios-spritekit-how-to-calculate-the-distance-between-two-nodes
     
     :param: point - the point to calculate a distance to
     
     :returns: distance between current and the given points
     */
    func distance(point: CGPoint) -> CGFloat {
        let dx = self.x - point.x
        let dy = self.y - point.y
        return sqrt(dx * dx + dy * dy);
    }
}
