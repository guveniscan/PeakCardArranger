//
//  CardDeck.swift
//  PeakCardArranger
//
//  Created by Guven Iscan on 11/06/16.
//  Copyright © 2016 Guven Iscan. All rights reserved.
//

import Foundation

class CardDeck : NSObject {
    let cards : [Card]
    let suits = [.Heart, .Diamond, .Club, .Spade] as [Suit]
    let ranks = [.One, .Two, .Three, .Four, .Five, .Six, .Seven,
                 .Eight, .Nine, .Ten, .Jack, .Queen, .King] as [Rank]
    
    override init() {
        var _cards : [Card] = []
        for suit in suits {
            for rank in ranks {
                _cards.append(Card(suit: suit, rank: rank))
            }
        }
        cards = _cards
        super.init()
    }
    
    func testCards1() -> [Card] {
        return [Card(suit : .Spade, rank: .One),
                Card(suit : .Spade, rank: .Two),
                Card(suit : .Spade, rank: .Three),
                Card(suit : .Spade, rank: .Four),
                Card(suit : .Heart, rank: .Four),
                Card(suit : .Heart, rank: .One),
                Card(suit : .Diamond, rank: .One),
                Card(suit : .Diamond, rank: .Four),
                Card(suit : .Diamond, rank: .Five),
                Card(suit : .Club, rank: .Four),
                Card(suit : .Diamond, rank: .Three)]
    }
    
    func testCards2() -> [Card] {
        return [Card(suit : .Spade, rank: .One),
                Card(suit : .Spade, rank: .Two),
                Card(suit : .Spade, rank: .Three),
                Card(suit : .Spade, rank: .Four),
                Card(suit : .Heart, rank: .One),
                Card(suit : .Heart, rank: .Four),
                Card(suit : .Club, rank: .Two),
                Card(suit : .Club, rank: .King),
                Card(suit : .Spade, rank: .Five),
                Card(suit : .Diamond, rank: .Two),
                Card(suit : .Diamond, rank: .Queen)]
    }
    
    func drawRandomCards(count count : Int = 11) -> [Card] {
        
        var deck = cards
        var selection : [Card] = []
        for _ in 0..<count {
            let randIndex = Int(arc4random_uniform(UInt32(deck.count)))
            let card = deck[randIndex]
            selection.append(card)
            deck.removeAtIndex(randIndex)
        }
        
        return selection
    }
}