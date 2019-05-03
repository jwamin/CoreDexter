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
    
    let elementStyles:[ElementalType] = [
        .fire,
        .electric,
        .grass,
        .water,
        .ghost,
        .ice,
        .dragon,
        .flying,
        .bug,
        .fairy,
        .psychic
    ]
    
    var viewConstraints:[NSLayoutConstraint]?
    var scrollView:UIScrollView!
    var stackView:UIStackView!
    var label:UILabel!
    var closeButton:UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("loaded")
        self.view.backgroundColor = .lightGray
        print(plist)
        setupViews()

        activateConstraints()
        
    }
    
    @objc func dismissSelf(){
        dismiss(animated: true, completion: nil)
    }
    
    private func setupViews(){
        
        if (viewConstraints == nil){
            
            scrollView = UIScrollView()
            scrollView.translatesAutoresizingMaskIntoConstraints = false
            scrollView.contentInsetAdjustmentBehavior = .never
            
            stackView = UIStackView()
            stackView.translatesAutoresizingMaskIntoConstraints = false
            stackView.axis = .vertical
            stackView.distribution = .fillEqually
            stackView.alignment = .fill
            
            closeButton = UIButton(type: .system)
            closeButton.translatesAutoresizingMaskIntoConstraints = false
            closeButton.setTitle("Close", for: .normal)
            closeButton.addTarget(self, action: #selector(dismissSelf), for: .touchUpInside)
            
            
            for (index,info) in messages.enumerated(){
                
                let label = ArrangedUILabel()
                
                let (message,style) = info.first!
                let element = elementStyles[index]
                //this is very very odd, why does creating a reference to first arranged subview cause it to be removed from the stackview
                
                label.translatesAutoresizingMaskIntoConstraints = false
                label.textAlignment = .center
                label.dataDetectorTypes = [.all]
                label.isEditable = false
                //label.numberOfLines = 0
                
                
                if(message == attributed.string){
                    label.attributedText = attributed
                    label.textAlignment = .center
                    label.font = bodyFont()
                } else {
                    label.text = message
                    switch style{
                    case .title:
                        label.font = headingFont()
                    case .small:
                        label.font = UIFontMetrics(forTextStyle: .footnote).scaledFont(for: rawbodyfont!)
                    default:
                        label.font = bodyFont()
                    }
                }
                

                
                
                let colors = element.getColors()
                label.backgroundColor = colors.backgroundColor
                label.textColor = colors.textColor
                label.setContentHuggingPriority(UILayoutPriority(100), for: .vertical)
                label.setContentHuggingPriority(UILayoutPriority(100), for: .horizontal)
                
                label.layer.opacity = 0.0
                label.transform = CGAffineTransform(translationX: 0, y: 100)
                
                
                
                stackView.addArrangedSubview(label)
                
            }
            //label = stackView.arrangedSubviews.first! as! UILabel
            //print(stackView.arrangedSubviews)
            scrollView.addSubview(stackView)
            view.addSubview(scrollView)
            self.view.addSubview(closeButton)
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
                label.heightAnchor.constraint(equalTo: scrollView.heightAnchor, multiplier: 0.2),
                view.safeAreaLayoutGuide.bottomAnchor.constraint(equalToSystemSpacingBelow: closeButton.bottomAnchor, multiplier: 1.0),
                view.safeAreaLayoutGuide.rightAnchor.constraint(equalToSystemSpacingAfter: closeButton.rightAnchor, multiplier: 1.0)
                
            ]
            
            NSLayoutConstraint.activate(constraints)
            
        }
        self.view.layoutIfNeeded()
        
        
    }
    
    override func viewDidLayoutSubviews() {
        
        //activateConstraints()
        print("layout subviews", stackView.arrangedSubviews.first!.frame.size == .zero)
        animateSubviews()
        
    }
    
}


extension AboutScreenViewController : UIScrollViewDelegate {
    
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        
        animateSubviews()
        
    }
    
    func scrollViewWillBeginDecelerating(_ scrollView: UIScrollView) {
        animateSubviews()
    }
    
    func animateSubviews(){
        
        guard let last = stackView.arrangedSubviews.last as? ArrangedUILabel else {
            return
        }
        
        if(last.animated || last.frame.size == .zero){
            // halt if the final element has already animated
            return
        }
        
        let toAnimate:[ArrangedUILabel] = (stackView!.arrangedSubviews as! [ArrangedUILabel]).compactMap {
            view in
            if(!view.animated && scrollView.bounds.intersects(view.frame)){
                return view
            }
            return nil
        }
        
        for (index,arranged) in toAnimate.enumerated() {
 
                let animatedBool = arranged.animated
                if(!animatedBool){
                    arranged.animated = true
                    print(arranged.description, "will animate with index \(index) with delay: \(TimeInterval(0.1 * Float(index)))")
                    UIView.animate(withDuration: 1.0, delay: TimeInterval(0.1 * Float(index)), options: [.beginFromCurrentState], animations: {
                        
                        arranged.transform = .identity
                        arranged.layer.opacity = 1.0
                        
                    }) { (complete) in
                        print(index, "animated")
                    }
                }

        }
        
        
//        let toAnimate:[ArrangedUILabel] = (stackView!.arrangedSubviews as! [ArrangedUILabel]).compactMap {
//            view in
//            if(!view.animated && scrollView.bounds.intersects(view.frame)){
//                return view
//            }
//            return nil
//        }
        
        
//
//        var animated = 0
//
//        for arranged in stackView.arrangedSubviews as! [ArrangedUILabel]{
//
//            if(arranged.animated){
//                animated += 1
//
//            }
//        }
//
//        print("animated \(animated), stillToAnimate: \(stackView.arrangedSubviews.count-animated)")
        
        
    }
    
}
