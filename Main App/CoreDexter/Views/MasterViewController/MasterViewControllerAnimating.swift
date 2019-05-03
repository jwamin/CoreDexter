//
//  MasterViewControllerAnimating.swift
//  CoreDexter
//
//  Created by Joss Manger on 4/23/19.
//  Copyright © 2019 Joss Manger. All rights reserved.
//

import UIKit

extension MasterViewController : UINavigationControllerDelegate{
    
    func navigationController(_ navigationController: UINavigationController, animationControllerFor operation: UINavigationController.Operation, from fromVC: UIViewController, to toVC: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        if operation == .pop{
            return nil
        }
        return (UserDefaults.standard.bool(forKey: "experimental")) ? Animator() : nil
    }
    
    
}

class Animator : NSObject, UIViewControllerAnimatedTransitioning{
    
    var context:UIViewControllerContextTransitioning!
    var toView:UIView!
    var snapshot:UIView!
    
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return 1.0
    }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        
        context = transitionContext
        
        let fromView = transitionContext.viewController(forKey: .from) as! MasterViewController
        let toViewNavigator = transitionContext.viewController(forKey: .to) as! UINavigationController
        let toViewController = toViewNavigator.topViewController as! DetailViewController
        let container = transitionContext.containerView
        
        guard let moveViewIndexPath = fromView.tableView.indexPathForSelectedRow, let cell = fromView.tableView.cellForRow(at: moveViewIndexPath) as? PokeCellTableViewCell, let animateBubble = cell.imgview else {
            transitionContext.completeTransition(true)
            return
        }
        
        let duration = transitionDuration(using: transitionContext)

        snapshot = fromView.view.snapshotView(afterScreenUpdates: false)!
        
        container.addSubview(snapshot)
        container.addSubview(toViewNavigator.view)

        
        
        let cellframe = fromView.tableView.rectForRow(at: moveViewIndexPath)
        let superCellFrame = fromView.tableView.convert(cellframe, to: fromView.tableView.superview!)
        
        
        
        let fromFrame = superCellFrame
        print(fromFrame)
        let toFrame = toViewNavigator.view.bounds
        
        let maskLayer = CAShapeLayer()
        maskLayer.bounds = fromFrame
        maskLayer.position = fromView.tableView.convert(cell.center, to: fromView.tableView.superview!)
        maskLayer.backgroundColor = UIColor.black.cgColor
        toView = toViewController.view
        toView.layer.mask = maskLayer
        
        
        fromView.view.removeFromSuperview()
        
        let toRect = CGRect(origin: .zero, size: toFrame.insetBy(dx: -toFrame.width, dy: -toFrame.height).size)
   
        let animation = CABasicAnimation(keyPath: "bounds")
        animation.fromValue = maskLayer.bounds
        animation.toValue = toRect
        animation.isRemovedOnCompletion = false
        animation.fillMode = .forwards
        animation.delegate = self
        animation.duration = duration
        maskLayer.add(animation, forKey: "bounds")
        
    }
    
    func animationEnded(_ transitionCompleted: Bool) {
        print("animation ended")
    }
    
}

extension Animator : CAAnimationDelegate{
    
    func animationDidStop(_ anim: CAAnimation, finished flag: Bool) {
        
        context.completeTransition(true)
        
    }
    
    
}
