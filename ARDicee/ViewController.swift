//
//  ViewController.swift
//  ARDicee
//
//  Created by Raul  Canul on 10/29/18.
//  Copyright © 2018 Raul  Canul. All rights reserved.
//

import UIKit
import SceneKit
import ARKit

class ViewController: UIViewController, ARSCNViewDelegate {

    @IBOutlet var sceneView: ARSCNView!
    var diceArray = [SCNNode]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.sceneView.debugOptions = [ARSCNDebugOptions.showFeaturePoints]
        // Set the view's delegate
        sceneView.delegate = self
        
//        let cube = SCNBox(width: 0.1, height: 0.1, length: 0.1, chamferRadius: 0.01)
//        let sphere = SCNSphere(radius: 0.2)
//
//        let material = SCNMaterial()
//        let moonMaterial = SCNMaterial()
//        let node = SCNNode()
//
//        let moonImg = UIImage(named: "art.scnassets/8k_moon.jpg")
//
//        material.diffuse.contents = UIColor.red
//        moonMaterial.diffuse.contents = moonImg
//        cube.materials = [material]
//        sphere.materials = [moonMaterial]
//
//        node.position = SCNVector3(x: 0, y: 0.1, z: -0.5)
//        //node.geometry = cube
//        node.geometry = sphere
//
//        sceneView.scene.rootNode.addChildNode(node)
        
        

        

        sceneView.autoenablesDefaultLighting = true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Create a session configuration
        let configuration = ARWorldTrackingConfiguration()
        
        configuration.planeDetection = .horizontal

        // Run the view's session
        sceneView.session.run(configuration)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Pause the view's session
        sceneView.session.pause()
    }

    // MARK: - ARSCNViewDelegate
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let touch = touches.first {
            let touchLocation = touch.location(in: sceneView)
            let results = sceneView.hitTest(touchLocation, types: .existingPlaneUsingExtent)
            
            if let hitResult = results.first {
                // Create a new scene
                let diceScene = SCNScene(named: "art.scnassets/diceCollada.scn")!
                
                if let diceNode = diceScene.rootNode.childNode(withName: "Dice", recursively: true) {
                    diceNode.position = SCNVector3(
                        hitResult.worldTransform.columns.3.x,
                        hitResult.worldTransform.columns.3.y + diceNode.boundingSphere.radius,
                        hitResult.worldTransform.columns.3.z
                    )
                    
                    diceArray.append(diceNode)
                    sceneView.scene.rootNode.addChildNode(diceNode)
                    
                    roll(dice: diceNode)
                }
            }
        }
    }
    
    func rolAll() {
        if !diceArray.isEmpty {
            for dice in diceArray {
                roll(dice: dice)
            }
        }
    }
    
    func roll(dice: SCNNode) {
        let randomX = Float(arc4random_uniform(4) + 1) * ( Float.pi / 2 )
        let randomZ = Float(arc4random_uniform(4) + 1) * ( Float.pi / 2 )
        
        dice.runAction(
            SCNAction.rotateBy(
                x: CGFloat(randomX * 5),
                y: 0,
                z: CGFloat(randomZ * 5),
                duration: 0.5)
        )
    }
    
    @IBAction func rollAgain(_ sender: UIBarButtonItem) {
        rolAll()
    }
    
    @IBAction func removeAllDicee(_ sender: UIBarButtonItem) {
        if !diceArray.isEmpty {
            for dice in diceArray {
                dice.removeFromParentNode()
            }
        }
    }
    
    override func motionEnded(_ motion: UIEvent.EventSubtype, with event: UIEvent?) {
        rolAll()
    }
    
    
    func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
        if anchor is ARPlaneAnchor {
            let planeAnchor = anchor as! ARPlaneAnchor
            let plane = SCNPlane(width: CGFloat(planeAnchor.extent.x), height: CGFloat(planeAnchor.extent.z))
            let planeNode = SCNNode()
            
            let gridMaterial = SCNMaterial()
            
            planeNode.position = SCNVector3(planeAnchor.center.x, 0, planeAnchor.center.z)
            planeNode.transform = SCNMatrix4MakeRotation(-Float.pi/2, 0, 0, 0)
            
            gridMaterial.diffuse.contents = UIImage(named: "art.scnassets/grid.png")
            
            plane.materials = [gridMaterial]
            planeNode.geometry = plane
            
            node.addChildNode(planeNode)
            
            
        } else {
            return
        }
    }
/*
    // Override to create and configure nodes for anchors added to the view's session.
    func renderer(_ renderer: SCNSceneRenderer, nodeFor anchor: ARAnchor) -> SCNNode? {
        let node = SCNNode()
     
        return node
    }
*/
    
    func session(_ session: ARSession, didFailWithError error: Error) {
        // Present an error message to the user
        
    }
    
    func sessionWasInterrupted(_ session: ARSession) {
        // Inform the user that the session has been interrupted, for example, by presenting an overlay
        
    }
    
    func sessionInterruptionEnded(_ session: ARSession) {
        // Reset tracking and/or remove existing anchors if consistent tracking is required
        
    }
}
