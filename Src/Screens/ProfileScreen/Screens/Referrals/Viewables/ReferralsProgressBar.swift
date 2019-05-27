//
//  ReferralsProgressBar.swift
//  UITests
//
//  Created by Sam Pettersson on 2019-05-23.
//

import Foundation
import SceneKit
import Flow

struct ReferralsProgressBar {
    let amountOfBlocks: Int
}

func radians(_ degrees: Float) -> Float {
    return degrees * Float.pi / 180
}

extension ReferralsProgressBar: Viewable {
    func materialize(events: ViewableEvents) -> (SCNView, Disposable) {
        let view = SCNView()
        let bag = DisposeBag()
        
        let scene = SCNScene()
        scene.background.contents = UIColor.offWhite
        
        let containerNode = SCNNode()
        containerNode.physicsBody?.isAffectedByGravity = true
        
        for i in 1...amountOfBlocks {
            let boxGeometry = SCNBox(width: 12.0, height: 2.0, length: 12.0, chamferRadius: 0)
            
            if i > 8 {
                boxGeometry.firstMaterial?.diffuse.contents = UIColor.turquoise
            } else {
                boxGeometry.firstMaterial?.diffuse.contents = UIColor.purple
            }
            
            let boxNode = SCNNode(geometry: boxGeometry)
            boxNode.position = SCNVector3Make(0, Float(2 * i + (20 * i)), 0)
            boxNode.physicsBody?.isAffectedByGravity = true
            containerNode.addChildNode(boxNode)
            
            let moveDown = SCNAction.moveBy(x: 0, y: CGFloat(-20 * i), z: 0, duration: TimeInterval(0.75 + (0.1 * Float(i))))
            moveDown.timingMode = .easeInEaseOut
            boxNode.runAction(moveDown)
        }
        
        scene.rootNode.addChildNode(containerNode)
        
        let cameraNode = SCNNode()
        cameraNode.camera = SCNCamera()
        cameraNode.position = SCNVector3Make(-30, Float(amountOfBlocks) + 25, 36)
        cameraNode.eulerAngles = SCNVector3Make(radians(-15), radians(-40), 0)
        scene.rootNode.addChildNode(cameraNode)
        
        let ambientLightNode = SCNNode()
        let ambientLight = SCNLight()
        ambientLight.type = .ambient
        ambientLight.color = UIColor.white
        ambientLight.temperature = 5500
        ambientLight.intensity = 800
        
        ambientLightNode.light = ambientLight
        
        scene.rootNode.addChildNode(ambientLightNode)
        
        let sideLightNode = SCNNode()
        let sideLight = SCNLight()
        sideLight.type = .directional
        sideLight.color = UIColor.white
        sideLight.temperature = 5500
        sideLight.intensity = 200
        sideLight.spotOuterAngle = 55
        sideLightNode.eulerAngles = SCNVector3Make(0, radians(-55), 0)
        sideLightNode.position = SCNVector3Make(-70, 35, 60)
        
        sideLightNode.light = sideLight
        cameraNode.addChildNode(sideLightNode)
        
        let topLightNode = SCNNode()
        let topLight = SCNLight()
        topLight.type = .directional
        topLight.color = UIColor.white
        topLight.temperature = 5500
        topLight.intensity = 250
        topLight.spotOuterAngle = 55
        topLightNode.eulerAngles = SCNVector3Make(radians(-90), radians(-55), 0)
        topLightNode.position = SCNVector3Make(-50, 35, 60)
        
        topLightNode.light = topLight
        cameraNode.addChildNode(topLightNode)
        
        view.scene = scene
        view.autoenablesDefaultLighting = false
        
        let pan = UIPanGestureRecognizer()
        
        let originalAngleY = containerNode.eulerAngles.y
        
        bag += pan.signal(forState: .changed).onValue {
            let translation = pan.translation(in: pan.view)
            let newAngleY = radians(Float(translation.x))
            containerNode.eulerAngles.y = newAngleY
        }
        
        bag += pan.signal(forState: .ended).onValue {
            SCNTransaction.begin()
            SCNTransaction.animationDuration = 0.5
            
            let velocity = pan.velocity(in: pan.view)
            
            containerNode.physicsBody?.applyForce(SCNVector3(0, velocity.y, 0), asImpulse: true)
            containerNode.eulerAngles.y = originalAngleY
            SCNTransaction.commit()
        }
        
        bag += view.install(pan)
        
        return (view, bag)
    }
}
