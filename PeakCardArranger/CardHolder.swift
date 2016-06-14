//
//  CardHolder.swift
//  PeakCardArranger
//
//  Created by Guven Iscan on 10/06/16.
//  Copyright © 2016 Guven Iscan. All rights reserved.
//

import UIKit

protocol CardViewDelegate {
    func cardDealingAnimationPoint() -> CGPoint
    func sizeForCard(inHolder holder: CardHolder, atIndex index : Int) -> CGSize
}

extension Array {
    mutating func swapElements(index1 : Int, index2 : Int) {
        (self[index1], self[index2]) = (self[index2], self[index1])
    }
}

class CardHolder : UIView {
    
    var delegate : CardViewDelegate?
    var numberOfCards : Int = 11
    
    private let cardSpanAngle : CGFloat = CGFloat(15.0 * M_PI / 180)
    private let cardSpanRadius : CGFloat = UIScreen.mainScreen().bounds.width * 1.3
    private var arcCenterYOffset : CGFloat {
        get {
            return cardSpanRadius * (1 - sin(cardSpanAngle))
        }
    }
    
    //Angle between 2 cards
    private var angleBetweenCards : CGFloat {
        get {
            guard numberOfCards > 1 else {
                return 0.0
            }
            return cardSpanAngle * 2 / CGFloat(numberOfCards - 1)
        }
    }
    //Array of card views at hand
    var currentCardViews : [UIView] = []
    
    //The arc path which all cards have their center's on
    private var arcPath : UIBezierPath {
        get {
            if bounds.size == CGSizeZero {
                return UIBezierPath()
            } else {
                return UIBezierPath(arcCenter: CGPointMake(center.x, center.y + arcCenterYOffset), radius: cardSpanRadius, startAngle: -cardSpanAngle - CGFloat(M_PI_2), endAngle: cardSpanAngle - CGFloat(M_PI_2), clockwise: true)
            }
        }
    }
    
    func drawBezierPath() {
        
        // Create a CAShapeLayer
        let shapeLayer = CAShapeLayer()
        
        // The Bezier path that we made needs to be converted to
        // a CGPath before it can be used on a layer.
        shapeLayer.path = arcPath.CGPath
        
        // apply other properties related to the path
        shapeLayer.strokeColor = UIColor.blueColor().CGColor
        shapeLayer.fillColor = UIColor.whiteColor().CGColor
        shapeLayer.lineWidth = 1.0
        shapeLayer.position = CGPoint(x: 0, y: 0)
        
        // add the new layer to our custom view
        self.layer.addSublayer(shapeLayer)
        
        for i in 0..<numberOfCards {
            let dot = UIView()
            dot.backgroundColor = UIColor.blackColor()
            addSubview(dot)
            
            dot.snp_makeConstraints(closure: { (make) in
                make.center.equalTo(self).offset(centerOfCard(atIndex: i))
                make.height.width.equalTo(5)
            })
        }
    }
    
    //Calculates the center position of card view with given index
    func centerOfCard(atIndex index : Int) -> CGPoint {
        guard numberOfCards != 0 else {
            return CGPointZero
        }
        
        //At which angle card center is positioned
        let angularCardPosition = cardSpanAngle - angleBetweenCards * CGFloat(index)
        
        //Calculate pixel offset given angular position, radius
        let cardCenter = CGPointMake(-sin(angularCardPosition) * cardSpanRadius, (1 - cos(angularCardPosition)) * cardSpanRadius - frame.size.height * 0.2)
        return cardCenter
    }
    
    //Calculates the rotation transformation of the card with index
    func transformationOfCard(atIndex index : Int) -> CGAffineTransform {
        guard numberOfCards != 0 else {
            return CGAffineTransformIdentity
        }
        return CGAffineTransformMakeRotation(angleBetweenCards * CGFloat(index) - cardSpanAngle)
    }
    
    //Brings cards front one by one to assure each card appears above
    //cards to its left
    func rearrangeZOrder() {
        for view in currentCardViews {
            bringSubviewToFront(view)
        }
    }
    
    //Sets up a CGAffineTransform for all cards except the card with index
    //cardToSkip
    func setupCardTransforms(cardToSkip cardToSkip: Int? = nil) {
        for (index, view) in currentCardViews.enumerate() {
            if index == cardToSkip {
                continue
            }
            view.transform = transformationOfCard(atIndex: index)
        }
    }
    
    //Updates center constraints of all cards except the card with index
    //cardToSkip
    func updateCardCenterConstraints(cardToSkip cardToSkip: Int? = nil) {
        for (index, view) in currentCardViews.enumerate() {
            if index == cardToSkip {
                continue
            }
            view.snp_updateConstraints { (make) in
                make.center.equalTo(self).offset(centerOfCard(atIndex: index))
            }
        }
    }
    
    //Handles pan gesture and repositions cards
    func handlePan(recognizer : UIPanGestureRecognizer) {
        //Dragged view should be an element of currentCardViews
        guard let view = recognizer.view, index = currentCardViews.indexOf(view) else {
            return
        }
        
        //Drag ended
        if recognizer.state == .Ended {
            
            let currentCenter = view.center
            let newCenterOffset = centerOfCard(atIndex: index)
            //Since dragged cards constraints are going to be updated
            //its transform should be regularized to make the animation look correct
            view.transform = CGAffineTransformTranslate(view.transform, -self.frame.size.width / 2 - newCenterOffset.x + currentCenter.x, -self.frame.size.height / 2 - newCenterOffset.y + currentCenter.y)
            
            UIView.animateWithDuration(0.2, animations: {
                self.updateCardCenterConstraints()
                view.transform = self.transformationOfCard(atIndex: index)
                }, completion: { (success) in
                    self.rearrangeZOrder()
            })
        }
        //Drag began
        else if recognizer.state == .Began {
            bringSubviewToFront(view)
            UIView.animateWithDuration(0.1, animations: {
                view.transform = CGAffineTransformIdentity
            })
        }
        //Dragging
        else if recognizer.state == .Changed {
            let translation = recognizer.translationInView(self)
            view.transform = CGAffineTransformMakeTranslation(translation.x, translation.y)
            
            shiftCardsIfNeeded(view, index: index, translation: translation)
        }
    }
    
    func shiftCardsIfNeeded(draggedCard : UIView, index : Int, translation : CGPoint) {
        let translatedRight = translation.x > 0
        let halfCardHeight = draggedCard.frame.size.height / 2
        let draggedCardCenterY = CGRectGetMidY(draggedCard.frame)
        
        if translatedRight {
            for (cardIndex, card) in currentCardViews[index+1..<currentCardViews.count].enumerate() {
                let overlapsVertically = fabs(CGRectGetMidY(card.frame) - draggedCardCenterY) < halfCardHeight
                if card.frame.origin.x < draggedCard.frame.origin.x && overlapsVertically {
                    let newIndex = cardIndex + index
                    let tempCenter = centerOfCard(atIndex: newIndex)
                    card.center = CGPointMake(self.center.x + tempCenter.x, self.frame.size.height / 2 + tempCenter.y)
                    card.transform = transformationOfCard(atIndex: newIndex)
                    currentCardViews.swapElements(newIndex, index2: newIndex + 1)
                }
                else {
                    break
                }
            }
        }
        else {
            for (cardIndex, card) in currentCardViews[0..<index].reverse().enumerate() {
                let overlapsVertically = fabs(CGRectGetMidY(card.frame) - draggedCardCenterY) < halfCardHeight
                if card.frame.origin.x > draggedCard.frame.origin.x && overlapsVertically {
                    let newIndex = index - cardIndex
                    let tempCenter = centerOfCard(atIndex: newIndex)
                    card.center = CGPointMake(self.center.x + tempCenter.x, self.frame.size.height / 2 + tempCenter.y)
                    card.transform = transformationOfCard(atIndex: newIndex)
                    currentCardViews.swapElements(newIndex, index2: newIndex - 1)
                }
                else {
                    break
                }
            }
        }
    }
    
    //Rearranges cards by the given order array
    func rearrangeCards(byIndices indices:[Int]) {
        //Form up the new order in newCardViews array
        var newCardViews : [UIView] = []
        for newIndex in indices {
            newCardViews.append(currentCardViews[newIndex])
        }
        
        //Update the currentCardViews and reposition all cards
        currentCardViews = newCardViews
        updateCardCenterConstraints()
        
        //Animate new constraints
        UIView.animateWithDuration(0.2, animations: {
            self.layoutIfNeeded()
            }, completion: {(success) in
                self.setupCardTransforms()
                self.rearrangeZOrder()
        })
    }
    
    //Adds new card view to the right of hand, card size should be supplied by the delegate
    func appendCardView(subview : UIView, animated : Bool = true) {
        addSubview(subview)
        let index = currentCardViews.count
        
        let panRecognizer = UIPanGestureRecognizer(target: self, action: #selector(handlePan))
        subview.addGestureRecognizer(panRecognizer)
        subview.userInteractionEnabled = true
        let cardCenterOffset = centerOfCard(atIndex: index)
        //Setup only size constraints here, rest will be set below according animated param
        subview.snp_makeConstraints { (make) in
            if let size = self.delegate?.sizeForCard(inHolder: self, atIndex: index)
            {
                make.size.equalTo(size)
            }
        }
        
        //Setup above uses currentCardViews.count
        currentCardViews.append(subview)
        
        if let animationPoint = delegate?.cardDealingAnimationPoint() where animated  {
            
            subview.snp_makeConstraints { (make) in
                make.center.equalTo(self).offset(animationPoint)
            }
            
            UIView.animateWithDuration(0.2, animations: {
                subview.snp_updateConstraints{ (make) in
                    make.center.equalTo(self).offset(cardCenterOffset)
                }
                self.layoutIfNeeded()
                subview.transform = self.transformationOfCard(atIndex: index)
            })
        }
        else {
            subview.snp_makeConstraints { (make) in
                make.center.equalTo(self).offset(cardCenterOffset)
            }
            subview.transform = self.transformationOfCard(atIndex: index)
        }
    }
    
    func removeAllCardViews() {
        for view in currentCardViews {
            view.removeFromSuperview()
        }
        
        currentCardViews = []
    }
}
