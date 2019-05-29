//
//  ReferralsProgressBar.swift
//  UITests
//
//  Created by Sam Pettersson on 2019-05-23.
//

import Foundation
import SceneKit
import Flow
import SpriteKit

struct ReferralsProgressBar {
    let amountOfBlocks: Int
    let amountOfCompletedBlocks: Int
}

func radians(_ degrees: Float) -> Float {
    return degrees * Float.pi / 180
}

extension ReferralsProgressBar {
    
    enum ChevronDirection {
        case left, right
    }
    
    enum LabelSize {
        case small, large
    }
    
    func createLabel(
        text: String,
        textColor: UIColor,
        backgroundColor: UIColor,
        chevronDirection: ChevronDirection,
        size: LabelSize
    ) -> SCNNode {
        let textGeometry = SCNText(string: text, extrusionDepth: 1)
        
        if size == .small {
            textGeometry.font = HedvigFonts.circularStdBold?.withSize(175)
        } else {
            textGeometry.font = HedvigFonts.circularStdBold?.withSize(225)
        }
        
        textGeometry.firstMaterial?.diffuse.contents = textColor
        
        let textNode = SCNNode(geometry: textGeometry)
        
        let chamferRadius: CGFloat = 150
        let paddingX: Float = 250
        let paddingY: Float = 150
        
        let backgroundBox = SCNBox(
            width: CGFloat(textGeometry.boundingBox.max.x + paddingX),
            height: CGFloat(textGeometry.boundingBox.max.y + paddingY),
            length: chamferRadius,
            chamferRadius: chamferRadius
        )
        backgroundBox.firstMaterial?.diffuse.contents = backgroundColor
        backgroundBox.firstMaterial?.shininess = 0
        backgroundBox.firstMaterial?.lightingModel = .constant
        
        let backgroundNode = SCNNode(geometry: backgroundBox)
        backgroundNode.eulerAngles = SCNVector3Make(radians(-30), 0, 0)
        backgroundNode.scale = SCNVector3Make(0.01, 0.01, 0.01)
        
        textNode.position = SCNVector3Make(
            -textNode.boundingBox.max.x / 2,
            -(backgroundNode.boundingBox.max.y + (textNode.boundingBox.max.y / 2)) / 2,
            Float(chamferRadius)
        )
        backgroundNode.addChildNode(textNode)
        
        let chevronGeometry = SCNPyramid(width: 50, height: 50, length: 50)
        let chevronNode = SCNNode(geometry: chevronGeometry)
        
        if chevronDirection == .left {
            chevronNode.eulerAngles = SCNVector3Make(0, 0, radians(90))
            chevronNode.position = SCNVector3Make(
                -backgroundNode.boundingBox.max.x,
                0,
                0
            )
        } else {
            chevronNode.eulerAngles = SCNVector3Make(0, 0, radians(-90))
            chevronNode.position = SCNVector3Make(
                backgroundNode.boundingBox.max.x,
                0,
                0
            )
        }
        
        chevronGeometry.firstMaterial?.diffuse.contents = backgroundColor
        chevronGeometry.firstMaterial?.shininess = 0
        chevronGeometry.firstMaterial?.lightingModel = .constant
        
        backgroundNode.addChildNode(chevronNode)
        
        return backgroundNode
    }
    
    func fullPriceLabel() -> SCNNode {
        let node = createLabel(
            text: "-200kr",
            textColor: UIColor.white,
            backgroundColor: UIColor.offBlack,
            chevronDirection: .right,
            size: .small
        )
        
        node.position = SCNVector3Make(
            -113,
            Float(amountOfBlocks * 2) + 1,
            0
        )
        
        let moveIn = SCNAction.moveBy(x: 100, y: 0, z: 0, duration: 0.5)
        moveIn.timingMode = .easeInEaseOut

        let bag = DisposeBag()

        bag += Signal(after: TimeInterval(0.75 + (Float(amountOfBlocks) * 0.1))).onValue {
            bag.dispose()
            node.runAction(moveIn)
        }
        
        return node
    }
    
    func freeLabel() -> SCNNode {
        let node = createLabel(
            text: "Gratis!",
            textColor: UIColor.white,
            backgroundColor: UIColor.offBlack,
            chevronDirection: .right,
            size: .small
        )
        
        node.position = SCNVector3Make(
            -113,
            1,
            0
        )
        
        let moveIn = SCNAction.moveBy(x: 100, y: 0, z: 0, duration: 0.5)
        moveIn.timingMode = .easeInEaseOut

        let bag = DisposeBag()

        bag += Signal(after: TimeInterval(0.75 + (Float(amountOfBlocks) * 0.1))).onValue {
            bag.dispose()
            node.runAction(moveIn)
        }
        
        return node
    }
    
    func currentDiscountLabel() -> SCNNode {
        let node = createLabel(
            text: "-10kr",
            textColor: UIColor.offBlack,
            backgroundColor: UIColor.turquoise,
            chevronDirection: .left,
            size: .large
        )
        
        node.position = SCNVector3Make(
            13 + 100,
            Float((amountOfBlocks - (amountOfCompletedBlocks / 2)) * 2) + 1,
            0
        )
        
        let moveIn = SCNAction.moveBy(x: -100, y: 0, z: 0, duration: 0.5)
        moveIn.timingMode = .easeInEaseOut
        
        let bag = DisposeBag()
        
        bag += Signal(after: TimeInterval(0.75 + (Float(amountOfBlocks) * 0.1))).onValue {
            bag.dispose()
            node.runAction(moveIn)
        }
        
        return node
    }
}

extension ReferralsProgressBar: Viewable {
    func materialize(events: ViewableEvents) -> (SCNView, Disposable) {
        let view = SCNView()
        view.antialiasingMode = .multisampling4X
        let bag = DisposeBag()
        
        let scene = SCNScene()
        scene.background.contents = UIColor.offWhite
        
        let containerNode = SCNNode()
        containerNode.physicsBody?.isAffectedByGravity = true
        containerNode.eulerAngles = SCNVector3Make(0, radians(-45), 0)
        
        for i in 1...amountOfBlocks {
            let boxGeometry = SCNBox(width: 10.0, height: 2.0, length: 10.0, chamferRadius: 0)
            
            if i > amountOfBlocks - amountOfCompletedBlocks {
                let boxColor = UIColor.turquoise.withAlphaComponent(0.9)
                
                boxGeometry.materials = [
                    boxColor,
                    boxColor,
                    boxColor,
                    boxColor,
                    i == amountOfBlocks ? boxColor : UIColor.clear
                    ].map({ color in
                        let material = SCNMaterial()
                        material.diffuse.contents = color
                        material.locksAmbientWithDiffuse = true
                        return material
                    })
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
        
        scene.rootNode.addChildNode(currentDiscountLabel())
        scene.rootNode.addChildNode(fullPriceLabel())
        scene.rootNode.addChildNode(freeLabel())
        
        scene.rootNode.addChildNode(containerNode)
        
        let cameraNode = SCNNode()
        cameraNode.camera = SCNCamera()
        cameraNode.camera?.usesOrthographicProjection = true
        cameraNode.camera?.orthographicScale = Double(42 - Float(amountOfBlocks))
        cameraNode.position = SCNVector3Make(0, Float(amountOfBlocks) * 2, Float(amountOfBlocks) * 1.75)
        cameraNode.eulerAngles = SCNVector3Make(radians(-30), 0, 0)
        scene.rootNode.addChildNode(cameraNode)
        
        let lightTemperature: CGFloat = 6500
        
        let ambientLightNode = SCNNode()
        let ambientLight = SCNLight()
        ambientLight.type = .ambient
        ambientLight.color = UIColor.white
        ambientLight.temperature = lightTemperature
        ambientLight.intensity = 800
        
        ambientLightNode.light = ambientLight
        
        scene.rootNode.addChildNode(ambientLightNode)
        
        let sideLightNode = SCNNode()
        let sideLight = SCNLight()
        sideLight.type = .directional
        sideLight.color = UIColor.white
        sideLight.temperature = lightTemperature
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
        topLight.temperature = lightTemperature
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
            let newAngleY = radians(Float(translation.x)) + radians(-45)
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
