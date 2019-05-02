//
//  ViewController.swift
//  CoreDexter
//
//  Created by Joss Manger on 5/2/19.
//  Copyright © 2019 Joss Manger. All rights reserved.
//

import UIKit
import PokeAPIKit

class AboutScreenViewController : UIViewController {
    
    let messages:[[String:ElementalType]] = [
        ["CoreDexter":.fire],
        ["v0.1 (2)":.electric],
        ["By Joss Manger":.grass],
        ["some more interesting info":.ghost],
        ["and more":.ice],
        ["copy JM 2019":.dragon],
        ["test":.grass],
        ["test":.ghost],
        ["test":.ice],
        ["test":.dragon]
    ]
    
    var viewConstraints:[NSLayoutConstraint]?
    var scrollView:UIScrollView!
    var stackView:UIStackView!
    var label:UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("loaded")
        self.view.backgroundColor = .white
        
        setupViews()
        
        activateConstraints()
        
    }
    
    private func setupViews(){
        
        if (viewConstraints == nil){
            
            scrollView = UIScrollView()
            scrollView.translatesAutoresizingMaskIntoConstraints = false
            scrollView.backgroundColor = .red
            stackView = UIStackView()
            stackView.translatesAutoresizingMaskIntoConstraints = false
            stackView.axis = .vertical
            stackView.distribution = .fillEqually
            stackView.alignment = .fill
            
            for info in messages{
                
                let label = ArrangedUILabel()
                
                let (message,element) = info.first!
                
                //this is very very odd, why does creating a reference to first arranged subview cause it to be removed from the stackview
                
                label.translatesAutoresizingMaskIntoConstraints = false
                label.textAlignment = .center
                label.text = message
                let colors = element.getColors()
                label.backgroundColor = colors.backgroundColor
                label.textColor = colors.textColor
                label.setContentHuggingPriority(UILayoutPriority(100), for: .vertical)
                label.setContentHuggingPriority(UILayoutPriority(100), for: .horizontal)
                
                label.layer.opacity = 0.1
                label.transform = CGAffineTransform(translationX: 0, y: 100)
                
                
                
                stackView.addArrangedSubview(label)
                
            }
            //label = stackView.arrangedSubviews.first! as! UILabel
            //print(stackView.arrangedSubviews)
            scrollView.addSubview(stackView)
            view.addSubview(scrollView)
            scrollView.delegate = self
        }
        
    }
    
    private func activateConstraints(){
        
        if (viewConstraints == nil){
            
            var constraints = [NSLayoutConstraint]()
            
            guard let stackView = stackView, let scrollView = scrollView, let label = stackView.arrangedSubviews.first else {
                return
            }
            
            let views = ["scrollView":scrollView,"stackView":stackView]
            
            constraints += NSLayoutConstraint.constraints(withVisualFormat: "|-0-[scrollView]-0-|", options: [], metrics: nil, views: views)
            constraints += NSLayoutConstraint.constraints(withVisualFormat: "V:|-0-[scrollView]-0-|", options: [], metrics: nil, views: views)
            
            constraints += NSLayoutConstraint.constraints(withVisualFormat: "|-0-[stackView]-0-|", options: [], metrics: nil, views: views)
            constraints += NSLayoutConstraint.constraints(withVisualFormat: "V:|-0-[stackView]-0-|", options: [], metrics: nil, views: views)
            
            //constraints += NSLayoutConstraint.constraints(withVisualFormat: "[label(==scrollView)]", options: [], metrics: nil, views: views)
            
            constraints += [
                
                label.widthAnchor.constraint(equalTo: scrollView.widthAnchor),
                label.heightAnchor.constraint(equalTo: scrollView.heightAnchor, multiplier: 0.2)
                
            ]
            
            NSLayoutConstraint.activate(constraints)
            
        }
        //self.view.layoutIfNeeded()
        
        
    }
    
    override func viewDidLayoutSubviews() {
        
        //activateConstraints()
        
        //animateSubviews()
        
        //        if stackView != nil {
        //            stackView.arrangedSubviews[0].frame
        //            (stackView.arrangedSubviews[0] as! UILabel).text
        //            stackView.arrangedSubviews.count
        //            //view.layoutIfNeeded()
        //
        //        }
    }
    
}


extension AboutScreenViewController : UIScrollViewDelegate {
    
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        
        animateSubviews()
        
    }
    
    func animateSubviews(){
        for (index,arranged) in (stackView.arrangedSubviews as! [ArrangedUILabel]).enumerated(){
            
            if arranged.frame.size == .zero {
                return
            }
            
            print(scrollView.convert(arranged.bounds, from: stackView))
            
            if scrollView.bounds.intersects(arranged.frame){
                
                let animatedBool = arranged.animated
                if(!animatedBool){
                    arranged.animated = true
                    UIView.animate(withDuration: 1.0, delay: TimeInterval(0.2 * Float(index)), options: [], animations: {
                        
                        arranged.transform = .identity
                        arranged.layer.opacity = 1.0
                        
                    }) { (complete) in
                        print(index, "animated")
                    }
                }
            }
            
        }
        
        var animated = 0
        
        for arranged in stackView.arrangedSubviews as! [ArrangedUILabel]{
            
            if(arranged.animated){
                animated += 1
                
            }
        }
        
        print("animated \(animated), stillToAnimate: \(stackView.arrangedSubviews.count-animated)")
        
        
    }
    
}


class ArrangedUILabel : UILabel{
    
    var animated = false
    
}
