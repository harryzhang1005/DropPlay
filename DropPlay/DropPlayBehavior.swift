//
//  DropPlayBehavior.swift
//  DropPlay
//
//  Created by Harvey Zhang on 12/3/15.
//  Copyright © 2015 HappyGuy. All rights reserved.
//

import UIKit

class DropPlayBehavior: UIDynamicBehavior
{
    // MARK: - Dynamic Behaviors
    
    let gravity = UIGravityBehavior()
    
    lazy var collison: UICollisionBehavior = {
        let collisionBehavior = UICollisionBehavior()
        // Specifies whether a boundary based on the reference system is active.
        collisionBehavior.translatesReferenceBoundsIntoBoundary = true
        return collisionBehavior
    }()
    
    lazy var dynamicItemBehavior: UIDynamicItemBehavior = {
        let dib = UIDynamicItemBehavior()
        dib.allowsRotation = true
        dib.elasticity = 0.75   // Default value is 0.0 (no bounce upon collision), to 1.0 for completely elastic collisions.
        dib.friction = 0.2 // Default value is 0.0, which corresponds to no friction. Use a value of 1.0 to apply strong friction.
        return dib
    }()
    
    override init() {
        super.init()
        
        addChildBehavior(gravity)
        addChildBehavior(collison)
        addChildBehavior(dynamicItemBehavior)
    }
    
    deinit {
        removeChildBehavior(gravity)
        removeChildBehavior(collison)
        removeChildBehavior(dynamicItemBehavior)
    }
    
    func addADropView(drop: UIView)
    {
        dynamicAnimator?.referenceView?.addSubview(drop) // Key Note: drop view must first be added to gameView
        
        gravity.addItem(drop)
        collison.addItem(drop)
        dynamicItemBehavior.addItem(drop)
    }
    
    func removeDrops(drops: [UIView])
    {
        for v in drops
        {
            gravity.removeItem(v)
            collison.removeItem(v)
            dynamicItemBehavior.removeItem(v)
            
            v.removeFromSuperview()
        }
    }
    
    func bindPath(path: UIBezierPath, named name: String)
    {
        collison.removeBoundaryWithIdentifier(name)
        collison.addBoundaryWithIdentifier(name, forPath: path)
        
        if let gv = dynamicAnimator?.referenceView as? GameView {
            gv.setPath(path, named: name)
        }
    }

}
