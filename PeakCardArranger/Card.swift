//
//  Card.swift
//  PeakCardArranger
//
//  Created by Guven Iscan on 09/06/16.
//  Copyright © 2016 Guven Iscan. All rights reserved.
//

import UIKit

enum Suit : String {
    case Spade = "spade"
    case Heart = "heart"
    case Club = "club"
    case Diamond = "diamond"
}

enum Rank : Int {
    
    case One = 1
    case Two = 2
    case Three = 3
    case Four = 4
    case Five = 5
    case Six = 6
    case Seven = 7
    case Eight = 8
    case Nine = 9
    case Ten = 10
    case Jack = 11
    case Queen = 12
    case King = 13
    
    var imageFileSuffix : String {
        switch(self) {
        case .One:
            return "1"
        case .Two:
            return "2"
        case .Three:
            return "3"
        case .Four:
            return "4"
        case .Five:
            return "5"
        case .Six:
            return "6"
        case .Seven:
            return "7"
        case .Eight:
            return "8"
        case .Nine:
            return "9"
        case .Ten:
            return "10"
        case .Jack:
            return "jack"
        case .Queen:
            return "queen"
        case .King:
            return "king"
        }
    }
}

struct Card : CustomStringConvertible {
    let suit : Suit
    let rank : Rank
    
    //Returns the image associated with the card
    var image : UIImage
    {
        return UIImage(named: "\(suit.rawValue)s_\(rank.imageFileSuffix)")!
    }
    
    var description: String {
        return "\(suit.rawValue) \(rank.imageFileSuffix)"
    }
    
}

extension Card : Equatable {}

func ==(lhs : Card, rhs :Card) -> Bool {
    return lhs.suit == rhs.suit && lhs.rank == rhs.rank
}


