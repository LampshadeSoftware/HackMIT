//
//  Bubble.swift
//  The Bubble App
//
//  Created by Cowboy Lynk on 9/14/19.
//  Copyright © 2019 Lampshade Software. All rights reserved.
//

import Foundation
import SpriteKit

class Bubble {
    var content: String
    var editable: Bool
    var node: SKNode? = nil
	var labelNode: SKLabelNode? = nil
	var boxNode: SKShapeNode? = nil
    
    init() {
        content = ""
        editable = true
    }
    
    func setNode(node: SKNode) {
		
        let labelNode = SKLabelNode(text: content)
		labelNode.fontName = "AvenirNext-Bold"
		labelNode.fontColor = .black
		labelNode.numberOfLines = 0
		labelNode.preferredMaxLayoutWidth = 220
		labelNode.fontSize = 20
		labelNode.verticalAlignmentMode = .center
		
		
		let boxNode = SKShapeNode(rect: CGRect(origin: CGPoint(x: 0, y: 0), size: labelNode.frame.size), cornerRadius: 10)
		boxNode.fillColor = .white
		boxNode.strokeColor = .white
		
		node.addChild(boxNode)
        node.addChild(labelNode)
		
		self.node = node
		self.labelNode = labelNode
		self.boxNode = boxNode
    }
    
    func setContent(revElements: [RevElement], final: Bool) {
        var newContent = ""
        var counter = 0
        for element in revElements {
            if element.type != "punct" && !final && counter != 0 {
                newContent += " "
            }
            newContent += element.value
            counter += 1
        }
        self.content = newContent
        
        // Update the label node that stores the content
		self.labelNode?.text = newContent

		if (labelNode != nil) {
			self.boxNode?.removeFromParent()
			self.boxNode = SKShapeNode(rect: CGRect(origin: CGPoint(x: 0, y: 0), size: labelNode!.frame.size), cornerRadius: 10)
			self.node?.addChild(self.boxNode!)
		}
        
        // Once done updating, initial kill sequence
        if (final) {
            node?.run(
                SKAction.sequence([
                    SKAction.wait(forDuration: 3.0),
                    SKAction.removeFromParent()
                    ])
            )
        }
    }
}
