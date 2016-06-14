//
//  CardView.swift
//  PeakCardArranger
//
//  Created by Guven Iscan on 10/06/16.
//  Copyright © 2016 Guven Iscan. All rights reserved.
//

import UIKit

class CardView : UIImageView
{
    let card : Card
    init(card : Card) {
        self.card = card
        super.init(image: card.image)
        tag = CardView.tagFromCard(card)
        layer.shadowColor = UIColor.blackColor().CGColor
        layer.shadowOffset = CGSizeMake(5.0, 5.0)
        layer.shadowRadius = 15.0
        layer.shadowOpacity = 0.7
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    class func tagFromCard(card : Card) -> Int {
        var tag = 0
        
        switch card.suit {
        case .Heart:
            tag = 1
        case .Spade:
            tag = 2
        case .Diamond:
            tag = 3
        case .Club:
            tag = 4
        }
        
        let cardsInSuit = 13
        tag = tag * cardsInSuit + card.rank.rawValue
        
        return tag
    }
    
}
