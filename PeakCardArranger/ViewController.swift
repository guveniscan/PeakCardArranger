//
//  ViewController.swift
//  PeakCardArranger
//
//  Created by Guven Iscan on 09/06/16.
//  Copyright © 2016 Guven Iscan. All rights reserved.
//

import UIKit
import SnapKit

class ViewController: UIViewController, CardViewDelegate {
    
    var cardHolder : CardHolder?
    let cardDeck = CardDeck()
    var currentCards : [Card] = []
    
    convenience init() {
        self.init(nibName: nil, bundle: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        self.view.backgroundColor = viewControllerBgColor
        
        setupViews()
        dealRandomCards(animated :false)
    }
    
    func defaultButton() -> UIButton {
        let button = UIButton()
        button.backgroundColor = buttonBgColor
        button.layer.cornerRadius = buttonCornerRadius
        button.titleLabel?.font = buttonFont
        return button
    }
    
    func delay(delay:Double, closure:()->()) {
        dispatch_after(
            dispatch_time(
                DISPATCH_TIME_NOW,
                Int64(delay * Double(NSEC_PER_SEC))
            ),
            dispatch_get_main_queue(), closure)
    }
    
    func dealRandomCards(animated animated : Bool) {
        let delayPeriod  = 0.15
        currentCards = cardDeck.drawRandomCards()
        var i = 0
        for card in currentCards {
            let cardView = CardView(card: card)
            if animated {
                delay (Double(i) * delayPeriod) {
                    self.cardHolder?.appendCardView(cardView, animated: animated)
                }
            }
            else {
                cardHolder?.appendCardView(cardView, animated: animated)
            }
            
            i += 1
        }
    }
    
    func dealButtonPressed(sender : AnyObject) {
        if cardHolder?.currentCardViews.count != 0 {
            cardHolder?.removeAllCardViews()
        }
        
        dealRandomCards(animated :true)
    }
    
    func inferCardIndices(cards : [Card], newCards : [Card]) -> [Int] {
        return newCards.map { (card) -> Int in
            cards.indexOf(card)!
        }
    }
    
    func order123ButtonPressed(sender:AnyObject) {
        let (orderedCards, _) = CardOrderOrganizer.arrangeCardsIn123Order(currentCards)
        cardHolder?.rearrangeCards(byIndices: inferCardIndices(currentCards, newCards: orderedCards))
        currentCards = orderedCards
    }
    
    func order777ButtonPressed(sender:AnyObject) {
        let (orderedCards, _) = CardOrderOrganizer.arrangeCardsIn777Order(currentCards)
        cardHolder?.rearrangeCards(byIndices: inferCardIndices(currentCards, newCards: orderedCards))
        currentCards = orderedCards
    }
    
    func orderSmartButtonPressed(sender:AnyObject) {
        let orderedCards = CardOrderOrganizer.arrangeCardsInMixedOrder(currentCards)
        cardHolder?.rearrangeCards(byIndices: inferCardIndices(currentCards, newCards: orderedCards))
        currentCards = orderedCards
    }
    
    func sizeForCard(inHolder holder: CardHolder, atIndex index: Int) -> CGSize {
        return CGSizeMake(92, 130)
    }
    
    func cardDealingAnimationPoint() -> CGPoint {
        let firstButtonCenter = CGPointMake(mainViewPadding + buttonWidth / 2, mainViewPadding + buttonHeight / 2)
        return view.convertPoint(firstButtonCenter, toView: cardHolder)
    }
    
    func cardsDidSwap(cardIndex1: Int, cardIndex2: Int) {
        currentCards.swapElements(cardIndex1, index2: cardIndex2)
    }
    
    func calculateButtonMargin(numberOfButtons : Int) -> CGFloat {
        guard numberOfButtons > 1 else {
            return 0.0
        }
        let screenWidth = UIScreen.mainScreen().bounds.size.width
        
        let neededWidthForButtons = mainViewPadding * 2 + CGFloat(numberOfButtons) * buttonWidth
        return (screenWidth - neededWidthForButtons) / CGFloat(numberOfButtons - 1)
    }
    
    func setupButtonConstraints(button : UIButton, index : Int, buttonMargin : CGFloat) {
        button.snp_makeConstraints { (make) in
            make.top.equalTo(view).offset(mainViewPadding)
            make.left.equalTo(view).offset(mainViewPadding + CGFloat(index) * (buttonWidth + buttonMargin))
            make.height.equalTo(buttonHeight)
            make.width.equalTo(buttonWidth)
        }
    }
    
    func setupViews() {
        let buttonMargin = calculateButtonMargin(4)
        var order = 0
        
        //Deal button
        let dealButton = self.defaultButton()
        dealButton.setTitle("DEAL", forState: .Normal)
        dealButton.addTarget(self, action: #selector(dealButtonPressed), forControlEvents: .TouchUpInside)
        view.addSubview(dealButton)
        
        setupButtonConstraints(dealButton, index: order, buttonMargin: buttonMargin)
        order += 1
        
        //1-2-3 Order button
        let order123Button = self.defaultButton()
        order123Button.setTitle("1-2-3", forState: .Normal)
        order123Button.addTarget(self, action: #selector(order123ButtonPressed), forControlEvents: .TouchUpInside)
        view.addSubview(order123Button)
        
        setupButtonConstraints(order123Button, index: order, buttonMargin: buttonMargin)
        order += 1
        
        //7-7-7 Order button
        let order777Button = self.defaultButton()
        order777Button.setTitle("7-7-7", forState: .Normal)
        order777Button.addTarget(self, action: #selector(order777ButtonPressed), forControlEvents: .TouchUpInside)
        view.addSubview(order777Button)
        
        setupButtonConstraints(order777Button, index: order, buttonMargin: buttonMargin)
        order += 1
        
        //Deal button
        let orderSmartButton = self.defaultButton()
        orderSmartButton.setTitle("Akıllı", forState: .Normal)
        orderSmartButton.addTarget(self, action: #selector(orderSmartButtonPressed), forControlEvents: .TouchUpInside)
        view.addSubview(orderSmartButton)
        
        setupButtonConstraints(orderSmartButton, index: order, buttonMargin: buttonMargin)
        order += 1
        
        cardHolder = CardHolder(frame: CGRectZero)
        cardHolder?.delegate = self
        view.addSubview(cardHolder!)
        
        cardHolder?.snp_makeConstraints(closure: { (make) in
            make.height.equalTo(self.view).multipliedBy(0.5)
            make.bottom.left.right.equalTo(self.view)
        })
        
        view.layoutIfNeeded()
//        cardHolder?.drawBezierPath()
    }
}

