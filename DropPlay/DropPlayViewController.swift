//
//  DropPlayViewController.swift
//  DropPlay
//
//  Created by Harvey Zhang on 12/3/15.
//  Copyright © 2015 HappyGuy. All rights reserved.
//

import UIKit

class DropPlayViewController: UIViewController
{
    @IBOutlet weak var gameView: GameView!  // Will contain drops and barrier views
    
    var lastDropView: UIView!   // For Grabbing and Pushing the last drop view
    
    let itemsPerRow = 10    // 10 drops every row
    var dropSize: CGFloat { // = gameView.bounds.width / CGFloat(itemsPerRow)   // Error because gameView still nil here
        return gameView.bounds.width / CGFloat(itemsPerRow)
    }
    
    lazy var animator: UIDynamicAnimator = {
        // Here can use gameView because `animator` is a lazy property
        var dynamicAnimator = UIDynamicAnimator(referenceView: self.gameView)
        dynamicAnimator.delegate = self     // for remove the completed rows
        return dynamicAnimator
    }()
    
    // MARK: - Dynamic Behaviors
    
    let dropPlayBehavior = DropPlayBehavior()   // including gravity, collision, and dynamic item behaviors

    var pushBehavior: UIPushBehavior!   // For pushing the last drop view
    
    var attachment: UIAttachmentBehavior? { // For grab the last drop view
        willSet {
            if let atta = attachment {
                animator.removeBehavior(atta)
            }
            gameView.setPath(nil, named: Constants.GrabLinePath)
        }
        didSet {
            if let atta = attachment
            {
                animator.addBehavior(atta)
                
                atta.action = { [unowned self] in   // Key Point
                    if let attachedView = atta.items.first as? UIView {
                        let bPath = UIBezierPath()
                        bPath.moveToPoint(atta.anchorPoint)
                        bPath.addLineToPoint(attachedView.center)
                        self.gameView.setPath(bPath, named: Constants.GrabLinePath)
                    }
                }
            }//if
        }
    }
    
    // MARK: - Actions
    
    // tap to drop a view
    @IBAction func dropIt(sender: UITapGestureRecognizer) {
        drop()
    }
    
    private func drop()
    {
        let frame = CGRect(x: CGFloat(CGFloat.random(itemsPerRow)) * dropSize, y: 0, width: dropSize, height: dropSize)
        let dropView = UIView(frame: frame)
        
        dropView.backgroundColor = UIColor.random
        
        lastDropView = dropView
        
        dropPlayBehavior.addADropView(dropView)
    }
    
    // How to grab a view ?
    @IBAction func grabIt(sender: UIPanGestureRecognizer)
    {
        let pos = sender.locationInView(gameView)
        
        switch sender.state {
        case .Began:
            if let lastDrop = lastDropView
            {
                if let pb = pushBehavior {
                    animator.removeBehavior(pb)
                }
                
                attachment = UIAttachmentBehavior(item: lastDrop, attachedToAnchor: pos)
            }
        case .Changed:
            attachment?.anchorPoint = pos
            
        case .Ended:
            attachment = nil    // Clean temp memory to save memory
            
            if let lastDrop = lastDropView
            {
                /* Ask the gesture for the velocity of the drag.
                Using velocity and your old friend the Pythagorean theorem, you compute the magnitude of the velocity — which is the hypotenuse of the triangle formed from the x direction velocity and the y direction velocity.
                */
                let velocity = sender.velocityInView(gameView)
                let f_x: Float = Float(velocity.x)
                let f_y: Float = Float(velocity.y)
                let magnitude:CGFloat = CGFloat( sqrtf(f_x*f_x + f_y*f_y) )
                
                self.pushBehavior = UIPushBehavior(items: [lastDrop], mode: UIPushBehaviorMode.Instantaneous)
                pushBehavior.pushDirection = CGVector(dx: velocity.x/10, dy: velocity.y/10)
                pushBehavior.magnitude = magnitude/35   // The magnitude of the force vector for the push behavior.
                self.animator.addBehavior(pushBehavior)
            }
            
            lastDropView = nil  // Clean temp memory to save memory
            
        default: break
        }
    }
    
    // MARK: - Handle Device Orientation Change
    
    override func viewWillTransitionToSize(size: CGSize, withTransitionCoordinator coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransitionToSize(size, withTransitionCoordinator: coordinator)
        
        dropPlayBehavior.removeDrops(gameView.subviews)
    }
    
    /* How to hide status bar in iOS 6+ ?
    http://stackoverflow.com/questions/18059703/cannot-hide-status-bar-in-ios7
    
    There are so many combinations suggested for this issue, but the problem is that iOS 6 and 7 use different methods to hide the status bar. I have never been successful setting the plist settings to enable the iOS6-style behaviour on iOS 7, but if you are building your app to support iOS 6+, you need to use 3 methods at once to ensure a particular view controller hides the status bar:
    
    // for ios 7
    - (BOOL)prefersStatusBarHidden{
        return YES;
    }
    
    // for ios 6
    - (void)viewWillAppear:(BOOL)animated {
        [super viewWillAppear:animated];
        [[UIApplication sharedApplication] setStatusBarHidden:YES];
    }
    - (void)viewWillDisappear:(BOOL)animated {
        [super viewWillDisappear:animated];
        // explicitly set the bar to show or it will remain hidden for other view controllers
        [[UIApplication sharedApplication] setStatusBarHidden:NO];
    }
    
    This should work regardless of your plist settings.
    
    If you also want to hide status bar in Launch Screen view controller, you should go to Project -> Targets -> Deploy Info / Status Bar Style / Hide status bar
    */
    override func prefersStatusBarHidden() -> Bool { // works for current view controller
        return true
    }

    // MARK: - VC Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        //UIApplication.sharedApplication().statusBarHidden = true // not working, no clue why?

        animator.addBehavior(dropPlayBehavior)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        addBarrier()
    }
    
    // Add a circle barrier to game view
    func addBarrier()
    {
        let barrierSize = dropSize
        var origin = CGPoint(x: gameView.bounds.midX - barrierSize/2, y: gameView.bounds.midY - barrierSize/2)
        let size = CGSize(width: barrierSize, height: barrierSize)
        
        let frame = CGRect(origin: origin, size: size)
        let bezierPath = UIBezierPath(ovalInRect: frame)
        
        origin.x -= 3 * dropSize
        let leftBarrierFrame = CGRect(origin: origin, size: size)
        let leftBezierPath = UIBezierPath(ovalInRect: leftBarrierFrame)
        
        origin.x += 6 * dropSize
        let rightBarrierFrame = CGRect(origin: origin, size: size)
        let rightBezierPath = UIBezierPath(ovalInRect: rightBarrierFrame)
        
        dropPlayBehavior.bindPath(bezierPath, named: Constants.BarrierViewPath)
        dropPlayBehavior.bindPath(leftBezierPath, named: Constants.BarrierLeft)
        dropPlayBehavior.bindPath(rightBezierPath, named: Constants.BarrierRight)
    }
    
    // MARK: - Constants
    struct Constants {
        static let BarrierViewPath = "BarrierViewPath"
        static let BarrierLeft = "BarrierLeft"
        static let BarrierRight = "BarrierRight"
        static let GrabLinePath = "GrabLinePath"
    }

}

// MARK: - Dynamic Animator Delegate method

extension DropPlayViewController: UIDynamicAnimatorDelegate
{
    // Called when a dynamic animator pauses the animations for its behaviors’ associated dynamic items.
    func dynamicAnimatorDidPause(animator: UIDynamicAnimator) {
        cleanCompletedRows()
    }

    // Clean these completed rows
    private func cleanCompletedRows()
    {
        let drops = needRemoveDrops()       // Step-1: Find drops to clean
        dropPlayBehavior.removeDrops(drops) // Step-2: Remove these drops
    }
    
    private func needRemoveDrops() -> [UIView]
    {
        var removeDrops = [UIView]()
        var dropFrame = CGRect(x: 0, y: gameView.frame.maxY, width: dropSize, height: dropSize)
        
        repeat {
            dropFrame.origin.y -= dropSize  // row by row from bottom to up
            dropFrame.origin.x = 0          // here need reset every time
            var drops = [UIView]()          // will remove drops in current row
            var completeRowFlag = true      // current row is completed or not
            
            for _ in 0 ..< itemsPerRow
            {
                if let hitDrop = gameView.hitTest(CGPoint(x: dropFrame.midX, y: dropFrame.midY), withEvent: nil)
                {
                    if hitDrop.superview == gameView {
                        drops.append(hitDrop)
                    } else {
                        completeRowFlag = false; break;
                    }
                }
                
                dropFrame.origin.x += dropSize  // drop by drop from left to right
            }
        
            if completeRowFlag {
                removeDrops += drops
            }
        
        } while dropFrame.origin.y > 0 && removeDrops.count == 0
        
        return removeDrops
    }
    
}

// MARK: - Extensions Helper

private extension CGFloat {
    static func random(max: Int) -> UInt32 {
        return arc4random() % UInt32(max)
    }
}

private extension UIColor {
    class var random: UIColor {
        switch arc4random()%5 {
        case 0: return UIColor.orangeColor()
        case 1: return UIColor.redColor()
        case 2: return UIColor.greenColor()
        case 3: return UIColor.blueColor()
        case 4: return UIColor.blackColor()
        default: return UIColor.grayColor()
        }
    }
}
