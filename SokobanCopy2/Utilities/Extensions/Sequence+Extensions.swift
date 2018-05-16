//
//  Sequence+Extensions.swift
//  SokobanCopy2
//
//  Created by Scott Mehus on 5/15/18.
//  Copyright © 2018 ScottMehus. All rights reserved.
//

import Foundation

extension Sequence where Iterator.Element: SignedNumeric & Comparable {
    
    /// Finds the nearest (offset, element) to the specified element.
    func nearestOffsetAndElement(to toElement: Iterator.Element) -> (offset: Int, element: Iterator.Element) {
        
        guard let nearest = enumerated().min( by: {
            let left = $0.1 - toElement
            let right = $1.1 - toElement
            return abs(left) <= abs(right)
        } ) else {
            return (offset: 0, element: toElement)
        }
        
        return nearest
    }
    
    func nearestElement(to element: Iterator.Element) -> Iterator.Element {
        return nearestOffsetAndElement(to: element).element
    }
    
    func indexOfNearestElement(to element: Iterator.Element) -> Int {
        return nearestOffsetAndElement(to: element).offset
    }
    
}
