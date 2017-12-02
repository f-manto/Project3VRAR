//
//  ChartCreator.swift
//  ARKitBasics
//
//  Created by Francesco Mantovani on 26/11/2017.
//  Copyright © 2017 Apple. All rights reserved.
//

import Foundation
import SceneKit


class ChartCreator{
//    var scene:SCNScene!
//    var floor:SCNFloor!
    
    func createChart()-> SCNNode{
        
//        scene = SCNScene()
//        floor = SCNFloor()
//        floor.firstMaterial?.diffuse.contents = [UIColor.white]
//        floor.reflectivity = 0.15
//        floor.reflectionFalloffEnd = 15
        
        let node = SCNNode()
        
//        var floorNode = SCNNode(geometry: floor)
        
        var aNode = SCNNode()
        var val :Float
        val = 10
        aNode = SCNNode(geometry: SCNCylinder(radius: 1.0, height: CGFloat(val)))
//        let posX = min.x + Float(j) * Float(gridSize) + Float(gridSize/2)
//        let posY = min.y + Float(i) * Float(gridSize) + Float(gridSize/2)
        aNode.position = SCNVector3(x: 0, y:0 , z: val/2)
        aNode.rotation = SCNVector4(x: 1, y: 0, z: 0, w: Float(-M_PI_2))
        aNode.geometry?.firstMaterial?.diffuse.contents = [UIColor.blue]
        node.addChildNode(aNode)
        
        return node
    }

}
