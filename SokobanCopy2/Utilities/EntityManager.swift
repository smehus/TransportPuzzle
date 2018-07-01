//
//  EntityManager.swift
//  SokobanCopy2
//
//  Created by scott mehus on 5/6/18.
//  Copyright © 2018 ScottMehus. All rights reserved.
//

import Foundation
import GameplayKit

protocol ControlOverlayResponder {
    func didSelect(direction: ControlDirection)
    func selectionChanged(direction: ControlDirection) 
    func selectionDidEnd(direction: ControlDirection)
}

protocol CollisionDetector {
    func didBegin(_ contact: SCNPhysicsContact)
    func didEnd(_ contact: SCNPhysicsContact)
}

protocol TouchResponder {
    func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?)
    func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?)
    func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?)
}

class ComponentSystem: GKComponentSystem<GKComponent> {
    
    // Control Direction
    
    func didSelect(direction: ControlDirection) {
        for component in components {
            if let responder = component as? ControlOverlayResponder {
                responder.didSelect(direction: direction)
            }
        }
    }
    
    func selectionChanged(direction: ControlDirection) {
        for component in components {
            if let responder = component as? ControlOverlayResponder {
                responder.selectionChanged(direction: direction)
            }
        }
    }
    
    func selectionDidEnd(direction: ControlDirection) {
        for component in components {
            if let responder = component as? ControlOverlayResponder {
                responder.selectionDidEnd(direction: direction)
            }
        }
    }
    
    // Collision Detector
    
    func didBegin(_ contact: SCNPhysicsContact) {
        for component in components {
            if let detector = component as? CollisionDetector {
                detector.didBegin(contact)
            }
        }
    }
    
    func didEnd(_ contact: SCNPhysicsContact) {
        for component in components {
            if let detector = component as? CollisionDetector {
                detector.didEnd(contact)
            }
        }
    }
    
    // Touch Responder
    
    func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        for component in components {
            if let responder = component as? TouchResponder {
                responder.touchesBegan(touches, with: event)
            }
        }
    }
    
    func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        for component in components {
            if let responder = component as? TouchResponder {
                responder.touchesMoved(touches, with: event)
            }
        }
    }
    
    func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        for component in components {
            if let responder = component as? TouchResponder {
                responder.touchesEnded(touches, with: event)
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

        let characterTouchComponent = ComponentSystem(componentClass: CharacterTouchControlComponent.self)
        let highlightComponent = ComponentSystem(componentClass: RemoveOnContactComponent.self)
        let touchControlComponent = ComponentSystem(componentClass: TouchControlComponent.self)
        let hidddenCollisionComponent = ComponentSystem(componentClass: HiddenCollisionComponent.self)
        let pathCreatorComponent = ComponentSystem(componentClass: PathCreatorComponent.self)
        let cameraFollowComponent = ComponentSystem(componentClass: CameraFollowComponent.self)
        let nearestCoordinate = ComponentSystem(componentClass: NearestCoordinateComponent.self)
        return [touchControlComponent,
                hidddenCollisionComponent,
                pathCreatorComponent,
                highlightComponent,
                cameraFollowComponent,
                characterTouchComponent,
                nearestCoordinate]
    }()
    
    weak var controller: GameController!
    weak var renderer: SCNSceneRenderer!
    
    
    /// Not sure what i'll use this for yet...
    private var gkScene = GKScene()
    
    override init() {
        super.init()
    }
    
    
    func add(_ entity: GKEntity, parent: SCNNode? = nil) {
        entities.insert(entity)
        gkScene.addEntity(entity)
        
        if let node = entity.component(ofType: GKSCNNodeComponent.self)?.node, let parent = parent {
            parent.addChildNode(node)
        }
         
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
        
        if let node = entity.component(ofType: GKSCNNodeComponent.self)?.node {
            node.removeFromParentNode()
        }
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
    
    func entity<T: GKEntity>() -> T? {
        return entities.first(where: { $0 is T }) as? T
    }
}

extension EntityManager {
    func controlOverlayDidSelect(direction: ControlDirection) {
        componentSystems.forEach { (system) in
            system.didSelect(direction: direction)
        }
    }
    
    func controlOverlayChangedSelection(direction: ControlDirection) {
        componentSystems.forEach { (system) in
            system.selectionChanged(direction: direction)
        }
    }
    
    func controlOverlayDidEndSelection(direction: ControlDirection) {
        componentSystems.forEach { (system) in
            system.selectionDidEnd(direction: direction)
        }
    }
}

extension EntityManager {
    func didBegin(_ contact: SCNPhysicsContact) {
        componentSystems.forEach { (system) in
            system.didBegin(contact)
        }
    }
    
    func didEnd(_ contact: SCNPhysicsContact) {
        componentSystems.forEach { (system) in
            system.didEnd(contact)
        }
    }
}

extension EntityManager {
    func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        componentSystems.forEach { (system) in
            system.touchesBegan(touches, with: event)
        }
    }
    
    func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        componentSystems.forEach { (system) in
            system.touchesMoved(touches, with: event)
        }
    }
    
    func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        componentSystems.forEach { (system) in
            system.touchesEnded(touches, with: event)
        }
    }
}
