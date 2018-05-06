//
//  ColliderType.swift
//  SokobanCopy2
//
//  Created by scott mehus on 5/6/18.
//  Copyright © 2018 ScottMehus. All rights reserved.
//

import Foundation

struct ColliderType: OptionSet, Hashable, CustomDebugStringConvertible {
    // MARK: Static properties
    
    static var shouldNotify = [ColliderType: Bool]()
    
    /// A dictionary to specify which `ColliderType`s should be notified of contacts with other `ColliderType`s.
    static var requestedContactNotifications = [ColliderType: [ColliderType]]()
    
    /// A dictionary of which `ColliderType`s should collide with other `ColliderType`s.
    static var definedCollisions = [ColliderType: [ColliderType]]()
    
    // MARK: Properties
    
    let rawValue: Int
    
    // MARK: Options
    
    static var player: ColliderType  { return self.init(rawValue: 1 << 0) }
    static var box: ColliderType { return self.init(rawValue: 1 << 1) }
    static var plane: ColliderType   { return self.init(rawValue: 1 << 2) }
    
    // MARK: Hashable
    
    var hashValue: Int {
        return Int(rawValue)
    }
    
    // MARK: CustomDebugStringConvertible
    
    var debugDescription: String {
        return "UnknownColliderType(\(self.rawValue))"
    }
    
    // MARK: SpriteKit Physics Convenience
    
    /// A value that can be assigned to a 'SKPhysicsBody`'s `categoryMask` property.
    var categoryMask: Int {
        return rawValue
    }
    
    /// A value that can be assigned to a 'SKPhysicsBody`'s `collisionMask` property.
    var collisionMask: Int {
        // Combine all of the collision requests for this type using a bitwise or.
        let mask = ColliderType.definedCollisions[self]?.reduce(ColliderType()) { initial, colliderType in
            return initial.union(colliderType)
        }
        
        // Provide the rawValue of the resulting mask or 0 (so the object doesn't collide with anything).
        return mask?.rawValue ?? 0
    }
    
    /// A value that can be assigned to a 'SKPhysicsBody`'s `contactMask` property.
    var contactMask: Int {
        // Combine all of the contact requests for this type using a bitwise or.
        let mask = ColliderType.requestedContactNotifications[self]?.reduce(ColliderType()) { initial, colliderType in
            return initial.union(colliderType)
        }
        
        // Provide the rawValue of the resulting mask or 0 (so the object doesn't need contact callbacks).
        return mask?.rawValue ?? 0
    }
    
    // MARK: ContactNotifiableType Convenience
    
    /**
     Returns `true` if the `ContactNotifiableType` associated with this `ColliderType` should be
     notified of contact with the passed `ColliderType`.
     */
    func notifyOnContactWith(_ colliderType: ColliderType) -> Bool {
        guard let notify = ColliderType.shouldNotify[self], notify else { return false }
        if let requestedContacts = ColliderType.requestedContactNotifications[self] {
            return requestedContacts.contains(colliderType)
        }
        
        return false
    }
}
