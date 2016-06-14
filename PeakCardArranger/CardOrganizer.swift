//
//  CardOrganizer.swift
//  PeakCardArranger
//
//  Created by Guven Iscan on 12/06/16.
//  Copyright © 2016 Guven Iscan. All rights reserved.
//

import Foundation

enum CardOrder {
    case Order123
    case Order777
    case OrderMixed
}

class CardOrderOrganizer: NSObject
{
    //Filters cards of specified suit and returns a sorted array of them
    class func getSortedSuit(cards : [Card], suit : Suit) -> [Card] {
        //Filter
        var cardsInSuit = cards.filter { (card) -> Bool in
            return card.suit == suit
        }
        
        //Sort according to rank
        cardsInSuit.sortInPlace { (card1, card2) -> Bool in
            return card1.rank.rawValue < card2.rank.rawValue
        }
        
        return cardsInSuit
    }
    
    class func getSeriesIn(cards cards : [Card], condition seriesConditionHolds: (Card, Card) -> Bool) -> (series : [[Card]], leftOuts : [Card]) {
        
        var allSeries : [[Card]] = []
        var currentSeries : [Card] = []
        var leftOuts : [Card] = []
        for card in cards {
            //First card of the set
            if currentSeries.count == 0 {
                currentSeries.append(card)
            }
            //Current card is last card plus 1
            else if let lastCard = currentSeries.last where seriesConditionHolds(lastCard, card) {
                currentSeries.append(card)
            }
            //Current card is not a consecutive one
            else {
                //Append to series list if length is above 3
                if currentSeries.count >= 3 {
                    allSeries.append(currentSeries)
                }
                //Append to lefouts otherwise
                else {
                    leftOuts.appendContentsOf(currentSeries)
                }
                
                //Start a new series candidate with the current card
                currentSeries = [card]
            }
        }
        
        //Do the same check as in above loop to position cards in
        //current series
        if currentSeries.count >= 3 {
            allSeries.append(currentSeries)
        } else {
            leftOuts.appendContentsOf(currentSeries)
        }
        
        return (series:allSeries, leftOuts :leftOuts)
    }
    
    class func arrangeCardsIn123Order(cards:[Card]) -> (sortedCards :[Card], cardSeries : [[Card]]) {
        var sorted : [Card] = []
        var leftOuts : [Card] = []
        var cardSeries : [[Card]] = []
        let order123Condition = { (card1 : Card, card2 : Card) -> Bool in
            return card1.rank.rawValue + 1 == card2.rank.rawValue
        }
        for suit in [.Club,.Heart,.Spade,.Diamond] as [Suit] {
            //Get sorted cards of same suit
            let sortedSuit = CardOrderOrganizer.getSortedSuit(cards, suit: suit)
            //Check if they contain any series (ie 1,2,3) with length above 3
            let (suitSeries, suitLeftOuts) = CardOrderOrganizer.getSeriesIn(cards: sortedSuit, condition: order123Condition)
            //Store the result in two different lists
            cardSeries.appendContentsOf(suitSeries)
            sorted.appendContentsOf(suitSeries.flatten())
            leftOuts.appendContentsOf(suitLeftOuts)
        }
        
        //Sorted elements will be in the beginning followed by left out
        //cards
        return (sortedCards: sorted + leftOuts, cardSeries : cardSeries)
    }
    
    class func arrangeCardsIn777Order(cards:[Card]) -> (sortedCards :[Card], cardSeries : [[Card]]) {
        let order777Condition = { (card1 : Card, card2 : Card) -> Bool in
            return card1.rank.rawValue == card2.rank.rawValue
        }
        
        let sortedCards = cards.sort { (card1, card2) -> Bool in
            card1.rank.rawValue < card2.rank.rawValue
        }
        
        let (series, leftOuts) = CardOrderOrganizer.getSeriesIn(cards: sortedCards, condition: order777Condition)
        
        return (sortedCards :series.flatten() + leftOuts, cardSeries : series)
    }
    
    //Computes the subseries with length above 3 of a given series
    //ie [1,2,3,4] return [[1,2,3],[2,3,4],[1,2,3,4]]
    class func expandSeriesWithSubseries(series : [Card]) -> [[Card]] {
        var expandedSeries : [[Card]] = []
        for i in 3...series.count {
            for j in 0...series.count - i {
                expandedSeries.append(Array(series[j..<j+i]))
            }
        }
        return expandedSeries
    }
    
    class func expandSeriesListWithSubseries(seriesList : [[Card]]) -> [[Card]] {
        return seriesList.reduce([], combine: { (list : [[Card]], series : [Card]) -> [[Card]] in
            list + expandSeriesWithSubseries(series)
        })
    }
    
    //Removes members of cardsToDelete from cards
    class func deleteCards(cards : [Card], cardsToDelete : [Card]) -> [Card] {
        return cards.filter { (card) -> Bool in
            return !cardsToDelete.contains(card)
        }
    }
    
    //Recursive search to find the arrangement with lowest residue
    class func searchOptimalArrangement(left : [Card], used:[Card], residue : Int) -> ([Card], [Card], Int) {
        //Find all series with the form 1-2-3, 7-7-7
        let (_,series777) = arrangeCardsIn777Order(left)
        let (_,series123) = arrangeCardsIn123Order(left)
        let expandedSeries = expandSeriesListWithSubseries(series123 + series777)
        
        //Variables to control and store optimal arrangement
        var smallestResidue = residue
        var smallestLeftCards : [Card] = left
        var smallestUsedCards : [Card] = used
        
        //Traverse series, trying them one-by-one
        for series in expandedSeries {
            let seriesSum = series.reduce(0) { (sum, card) -> Int in
                sum + card.rank.rawValue
            }
            let (leftCards, usedCards, tempResidue) = searchOptimalArrangement(deleteCards(left, cardsToDelete: series), used: used + series, residue: residue - seriesSum)
            
            if tempResidue < smallestResidue {
                smallestResidue = tempResidue
                smallestLeftCards = leftCards
                smallestUsedCards = usedCards
            }
        }
        
        return (smallestLeftCards, smallestUsedCards, smallestResidue)
    }
    
    class func arrangeCardsInMixedOrder(cards : [Card]) -> [Card] {
        
        let totalResidue = cards.reduce(0) { (sum, card) -> Int in
            sum + card.rank.rawValue
        }
        
        let (left, used, _) = searchOptimalArrangement(cards, used : [], residue: totalResidue)
        
        return used + left
    }
}
