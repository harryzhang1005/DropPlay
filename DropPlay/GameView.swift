//
//  GameView.swift
//  DropPlay
//
//  Created by Harvey Zhang on 12/3/15.
//  Copyright © 2015 HappyGuy. All rights reserved.
//

import UIKit

class GameView: UIView {
    
    private var paths = [String:UIBezierPath?]()
    
    func setPath(path: UIBezierPath?, named name: String)
    {
        paths[name] = path
        setNeedsDisplay()   // do not forgot, otherwise you can not see grab line
    }

    // Only override drawRect: if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func drawRect(rect: CGRect) {
        // Drawing code
        for (_, path) in paths {
          path?.stroke() // Draws a line along the receiver’s path using the current drawing properties.
        }
    }

}
