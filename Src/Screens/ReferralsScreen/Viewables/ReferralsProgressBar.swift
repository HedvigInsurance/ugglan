//
//  ReferralsProgressBar.swift
//  UITests
//
//  Created by Sam Pettersson on 2019-05-23.
//

import Flow
import Foundation
import SceneKit
import SpriteKit

struct ReferralsProgressBar {
    let incentiveSignal: ReadSignal<Int?>
    let grossPremiumSignal: ReadSignal<Int?>
    let netPremiumSignal: ReadSignal<Int?>
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
        let backgroundBoxHeight = textGeometry.boundingBox.max.y + paddingY
        let backgroundBoxWidth = textGeometry.boundingBox.max.x + paddingX

        let backgroundBox = SCNBox(
            width: CGFloat(backgroundBoxWidth),
            height: CGFloat(backgroundBoxHeight),
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
            -backgroundBoxHeight / 2 + (paddingY / 2) - 15,
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

    func fullPriceLabel(grossPremium: Int, amountOfBlocks: Int, blockHeight: CGFloat, dividerHeight: CGFloat) -> SCNNode {
        let node = createLabel(
            text: "\(grossPremium)kr",
            textColor: UIColor.white,
            backgroundColor: UIColor.offBlack,
            chevronDirection: .right,
            size: .small
        )

        node.position = SCNVector3Make(
            -13,
            Float(Float(amountOfBlocks - 1) * Float(blockHeight + dividerHeight)) + Float((blockHeight + dividerHeight) / 2),
            0
        )

        return node
    }

    func freeLabel(blockHeight: CGFloat, dividerHeight: CGFloat) -> SCNNode {
        let node = createLabel(
            text: "Gratis!",
            textColor: UIColor.white,
            backgroundColor: UIColor.offBlack,
            chevronDirection: .right,
            size: .small
        )

        node.position = SCNVector3Make(
            -13,
            -Float((blockHeight + dividerHeight) / 2),
            0
        )

        return node
    }

    func currentDiscountLabel(
        discount: Int,
        amountOfBlocks: Int,
        amountOfCompletedBlocks: Int,
        blockHeight: CGFloat,
        dividerHeight: CGFloat
    ) -> SCNNode {
        let hasDiscount = discount > 0

        let node = createLabel(
            text: hasDiscount ? "-\(String(discount))kr" : "Bjud in",
            textColor: hasDiscount ? UIColor.offBlack : UIColor.white,
            backgroundColor: hasDiscount ? UIColor.turquoise : UIColor.purple,
            chevronDirection: .left,
            size: .large
        )

        node.position = SCNVector3Make(
            13,
            Float((Float(amountOfBlocks - 1 - (amountOfCompletedBlocks / 2))) * Float(blockHeight + dividerHeight)) + (hasDiscount ? Float(0) : Float((blockHeight + dividerHeight) / 2)),
            0
        )

        return node
    }

    func render(
        view: SCNView,
        scene: SCNScene,
        containerNode: SCNNode,
        incentive: Int,
        grossPremium: Int,
        netPremium: Int
    ) -> Disposable {
        let bag = DisposeBag()

        var blocks: [SCNNode] = []
        let amountOfBlocks = Int(ceil(Float(grossPremium) / Float(incentive)))
        let amountOfCompletedBlocks = (grossPremium - netPremium) / incentive
        let discount = grossPremium - netPremium
        
        let blockHeight: CGFloat = 2.0
        let dividerHeight: CGFloat = 0.20

        for i in 1 ... amountOfBlocks {
            let boxGeometry = SCNBox(width: 10.0, height: blockHeight, length: 10.0, chamferRadius: 0)

            if i >= amountOfBlocks - amountOfCompletedBlocks && amountOfCompletedBlocks != 0 {
                let boxColor = UIColor.turquoise

                boxGeometry.materials = [
                    boxColor,
                    boxColor,
                    boxColor,
                    boxColor,
                    i == amountOfBlocks ? boxColor : UIColor.clear,
                ].map { color in
                    let material = SCNMaterial()
                    material.diffuse.contents = color
                    material.locksAmbientWithDiffuse = true
                    return material
                }
            } else {
                boxGeometry.firstMaterial?.diffuse.contents = UIColor.purple
            }

            let boxNode = SCNNode(geometry: boxGeometry)
            boxNode.position = SCNVector3Make(0, Float((blockHeight + dividerHeight) * CGFloat(i - 1)), 0)
            boxNode.physicsBody?.isAffectedByGravity = true
            containerNode.addChildNode(boxNode)
            blocks.append(boxNode)
            
            if (i != amountOfBlocks) {
                let dividerGeometry = SCNBox(width: 10.0, height: dividerHeight, length: 10.0, chamferRadius: 0)
                dividerGeometry.firstMaterial?.diffuse.contents = i > amountOfBlocks - amountOfCompletedBlocks - 1 ? UIColor.turquoise.lighter(amount: 0.1) : UIColor.purple.lighter(amount: 0.1)
                
                let dividerNode = SCNNode(geometry: dividerGeometry)
                dividerNode.position = SCNVector3Make(
                    0,
                    Float((blockHeight + dividerHeight) / 2 + (blockHeight + dividerHeight) * CGFloat(i - 1)),
                    0
                )
                dividerNode.physicsBody?.isAffectedByGravity = true
                containerNode.addChildNode(dividerNode)
                blocks.append(dividerNode)
            }
            
        }

        let discountLabelNode = currentDiscountLabel(
            discount: discount,
            amountOfBlocks: amountOfBlocks,
            amountOfCompletedBlocks: amountOfCompletedBlocks,
            blockHeight: blockHeight,
            dividerHeight: dividerHeight
        )
        discountLabelNode.opacity = 0
        scene.rootNode.addChildNode(discountLabelNode)

        let fullPriceLabelNode = fullPriceLabel(grossPremium: grossPremium, amountOfBlocks: amountOfBlocks, blockHeight: blockHeight, dividerHeight: dividerHeight)
        fullPriceLabelNode.opacity = 0
        scene.rootNode.addChildNode(fullPriceLabelNode)

        let freeLabelNode = freeLabel(blockHeight: blockHeight, dividerHeight: dividerHeight)
        freeLabelNode.opacity = 0
        scene.rootNode.addChildNode(freeLabelNode)

        bag += Signal(after: 1).onValue { _ in
            let duration = 0.5

            let action = SCNAction.customAction(duration: duration, action: { node, progress in
                let realProgress = 1.0 / (Float(duration) / Float(progress))
                node.eulerAngles = SCNVector3Make(0, radians(-45 * (realProgress * 5)), 0)
                node.scale = SCNVector3(x: 1, y: realProgress, z: 1)
                node.opacity = 1

                if realProgress > 0.8 {
                    let opacityProgress = CGFloat((realProgress - 0.8) / 0.2)
                    discountLabelNode.opacity = opacityProgress
                    fullPriceLabelNode.opacity = opacityProgress
                    freeLabelNode.opacity = opacityProgress
                }
            })

            action.timingMode = SCNActionTimingMode.easeOut

            containerNode.runAction(action)
        }
        
        func transitionColor(from: UIColor, to: UIColor, percentage: CGFloat) -> UIColor {
            let fromComponents = from.cgColor.components!
            let toComponents = to.cgColor.components!
            
            let color = UIColor(red: fromComponents[0] + (toComponents[0] - fromComponents[0]) * percentage,
                                green: fromComponents[1] + (toComponents[1] - fromComponents[1]) * percentage,
                                blue: fromComponents[2] + (toComponents[2] - fromComponents[2]) * percentage,
                                alpha: fromComponents[3] + (toComponents[3] - fromComponents[3]) * percentage)
            return color
        }
        
        if (discount == 0) {
            bag += Signal(after: 3).onValue { _ in
                var blockActions: [SCNAction] = []
                let idleAction = SCNAction.wait(duration: 7)
                let duration = 0.2
                
                for i in stride(from: blocks.count - 1, to: -1, by: -2) {
                    let action = SCNAction.customAction(duration: duration, action: { node, progress in
                        let percentage = progress / CGFloat(duration)
                        
                        blocks[i].geometry?.firstMaterial?.diffuse.contents = transitionColor(
                            from: UIColor.purple,
                            to: UIColor.turquoise,
                            percentage: percentage
                        )
                        if i > 0 {
                            blocks[i - 1].geometry?.firstMaterial?.diffuse.contents = transitionColor(
                                from: UIColor.purple.lighter(amount: 0.1),
                                to: UIColor.turquoise.lighter(amount: 0.1),
                                percentage: percentage
                            )
                        }
                    })
                    
                    action.timingMode = SCNActionTimingMode.easeInEaseOut
                    blockActions.append(action)
                }
                
                let blockDelayAction = SCNAction.wait(duration: 0.7)
                blockActions.append(blockDelayAction)
                
                let finalBlockAction = SCNAction.customAction(duration: duration, action: { node, progress in
                    for i in stride(from: blocks.count - 1, to: -1, by: -2) {
                        let percentage = progress / CGFloat(duration)
                        blocks[i].geometry?.firstMaterial?.diffuse.contents = transitionColor(
                            from: UIColor.turquoise,
                            to: UIColor.purple,
                            percentage: percentage
                        )
                        if i > 0 {
                            blocks[i - 1].geometry?.firstMaterial?.diffuse.contents = transitionColor(
                                from: UIColor.turquoise.lighter(amount: 0.1),
                                to: UIColor.purple.lighter(amount: 0.1),
                                percentage: percentage
                            )
                        }
                    }
                })
                
                finalBlockAction.timingMode = SCNActionTimingMode.easeOut
                blockActions.append(finalBlockAction)
                blockActions.append(idleAction)
                
                var labelActions: [SCNAction] = []
                
                for i in stride(from: blocks.count - 1, to: -1, by: -2) {
                    let action = SCNAction.move(by: SCNVector3Make(
                        0,
                        -Float(blockHeight + dividerHeight),
                        0
                    ), duration: 0.2)
                    
                    action.timingMode = SCNActionTimingMode.linear
                    labelActions.append(action)
                    
                    let stringAction = SCNAction.customAction(duration: 0.0, action: { node, progress in
                        let blockIndex = Int(ceil(Float(i) / 2.0))
                        
                        (discountLabelNode.childNodes[0].geometry as! SCNText).string = blockIndex == 0 ? "Gratis!" : "-\((amountOfBlocks - blockIndex) * 10) kr"
                    });
                    
                    labelActions.append(stringAction)
                }
                
                let labelDelayAction = SCNAction.wait(duration: 0.6)
                labelActions.append(labelDelayAction)
                
                let finalLabelStringAction = SCNAction.customAction(duration: 0.0, action: { node, progress in
                    (discountLabelNode.childNodes[0].geometry as! SCNText).string = "Bjud in"
                });
                
                labelActions.append(finalLabelStringAction)
                
                let finalLabelAction = SCNAction.move(by: SCNVector3Make(
                    0,
                    Float(blockHeight + dividerHeight) * Float(amountOfBlocks),
                    0
                ), duration: 0.3)
                
                finalLabelAction.timingMode = SCNActionTimingMode.easeInEaseOut
                labelActions.append(finalLabelAction)
                labelActions.append(idleAction)
                
                let act = SCNAction.repeatForever(SCNAction.sequence(blockActions))
                containerNode.runAction(act)
                
                let labelAct = SCNAction.repeatForever(SCNAction.sequence(labelActions))
                discountLabelNode.runAction(labelAct)
            }
        }

        scene.rootNode.addChildNode(containerNode)

        let cameraNode = SCNNode()
        cameraNode.camera = SCNCamera()
        cameraNode.camera?.usesOrthographicProjection = true
        cameraNode.camera?.orthographicScale = (Double(amountOfBlocks) * 1.1) + 3
        cameraNode.position = SCNVector3Make(0, Float(amountOfBlocks) * Float(blockHeight), Float(amountOfBlocks) * Float(blockHeight) * 0.875)
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

        view.snp.makeConstraints { make in
            make.height.equalTo(amountOfBlocks * 22)
        }

        return Disposer {
            bag.dispose()

            blocks.forEach { block in
                block.removeFromParentNode()
            }

            containerNode.scale = SCNVector3(x: 1, y: 0, z: 1)
            containerNode.opacity = 0

            ambientLightNode.removeFromParentNode()
            cameraNode.removeFromParentNode()

            discountLabelNode.removeFromParentNode()
            fullPriceLabelNode.removeFromParentNode()
            freeLabelNode.removeFromParentNode()
        }
    }
}

extension ReferralsProgressBar: Viewable {
    func materialize(events _: ViewableEvents) -> (SCNView, Disposable) {
        let view = SCNView()
        view.antialiasingMode = .multisampling4X
        let bag = DisposeBag()

        let scene = SCNScene()
        scene.background.contents = UIColor.offWhite

        let containerNode = SCNNode()
        containerNode.physicsBody?.isAffectedByGravity = true
        containerNode.eulerAngles = SCNVector3Make(0, radians(-45), 0)

        bag +=
            combineLatest(
                incentiveSignal.atOnce().compactMap { $0 }.distinct(),
                grossPremiumSignal.atOnce().compactMap { $0 }.distinct(),
                netPremiumSignal.atOnce().compactMap { $0 }.distinct()
            )
            .onValueDisposePrevious { (arg) -> Disposable? in
                let (incentive, grossPremium, netPremium) = arg
                return self.render(
                    view: view,
                    scene: scene,
                    containerNode: containerNode,
                    incentive: incentive,
                    grossPremium: grossPremium,
                    netPremium: netPremium
                )
            }
        
        containerNode.scale = SCNVector3(x: 1, y: 0, z: 1)
        containerNode.opacity = 0

        view.scene = scene
        view.autoenablesDefaultLighting = false

        let pan = PanDirectionGestureRecognizer(direction: .horizontal)

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
