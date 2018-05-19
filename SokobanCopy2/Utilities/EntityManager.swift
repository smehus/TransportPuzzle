//
//  EntityManager.swift
//  SokobanCopy2
//
//  Created by scott mehus on 5/6/18.
//  Copyright © 2018 ScottMehus. All rights reserved.
//

import Foundation
import GameplayKit

protocol ToucheDetector {
    func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?)
}

protocol CollisionDetector {
    func didBegin(_ contact: SKPhysicsContact)
}

class ComponentSystem: GKComponentSystem<GKComponent> {

    func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        for component in components {
            if let detector = component as? ToucheDetector {
                detector.touchesBegan(touches, with: event)
            }
        }
    }
    
    func didBegin(_ contact: SKPhysicsContact) {
        for component in components {
            if let detector = component as? CollisionDetector {
                detector.didBegin(contact)
            }
        }
    }
}

final class EntityManager: NSObject {
    
    static let shared = EntityManager()
    
    var entities = Set<GKEntity>()
    var toRemove = Set<GKEntity>()
    
    
    lazy var componentSystems: [ComponentSystem] = {
        // Manages all instances of the DirectionalComponent

        let touchControlComponent = ComponentSystem(componentClass: TouchControlComponent.self)
        return [touchControlComponent]
    }()
    
    weak var controller: GameController!
    weak var renderer: SCNSceneRenderer!
    
    
    /// Not sure what i'll use this for yet...
    private var gkScene = GKScene()
    
    override init() {
        super.init()
    }
    
    
    func add(_ entity: GKEntity) {
        entities.insert(entity)
        gkScene.addEntity(entity)
        
        if let overlayScene = entity.component(ofType: TouchControlComponent.self)?.scene {
            renderer.overlaySKScene = overlayScene
        }
        
        for system in componentSystems {
            // Looks through all of the components in the entity,
            // and adds any that match the class for the current iteration of the systems array
            system.addComponent(foundIn: entity)
        }
    }
    
    func removeOrphanComponents() {
        for system in componentSystems {
            for component in system.components {
                if component.entity == nil {
                    system.removeComponent(component)
                }
            }
        }
    }
    
    func remove(_ entity: GKEntity) {

        entities.remove(entity)
        toRemove.insert(entity)
        gkScene.removeEntity(entity)
    }
    
    func update(_ deltaTime: CFTimeInterval) {
        componentSystems.forEach { (system) in
            system.update(deltaTime: deltaTime)
        }
        
        toRemove.forEach { (entity) in
            componentSystems.forEach({ (system) in
                system.removeComponent(foundIn: entity)
            })
        }
        
        toRemove.removeAll()
    }
    
    func didBegin(_ contact: SKPhysicsContact) {
        componentSystems.forEach { (system) in
            system.didBegin(contact)
        }
    }
    
    func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        componentSystems.forEach { (system) in
            system.touchesBegan(touches, with: event)
        }
    }
    
    func entity<T: GKEntity>() -> T? {
        return entities.first(where: { $0 is T }) as? T
    }
}
