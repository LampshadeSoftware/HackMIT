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
		
        let labelNode = SKLabelNode()
		labelNode.fontName = "AvenirNext-Bold"
		labelNode.fontColor = .black
		labelNode.numberOfLines = 0
		labelNode.preferredMaxLayoutWidth = 220
		labelNode.fontSize = 20
		labelNode.verticalAlignmentMode = .center
        node.addChild(labelNode)
        
        updateUI(text: content)
		
		self.node = node
		self.labelNode = labelNode
    }
    
    func updateUI(text: String) {
        self.labelNode?.text = text
        
        // Remove and re-make the box node (because it's stupid and can't be re-sized)
        if (labelNode != nil) {
            self.boxNode?.removeFromParent()
            let labelSize = labelNode!.frame.size
            let size = CGSize(width: labelSize.width + 40, height: labelSize.height + 40)
            let boxNode = SKShapeNode(rect: CGRect(origin: CGPoint(x: size.width / -2, y: size.height / -2), size: size), cornerRadius: 20)
            boxNode.fillColor = .white
            boxNode.strokeColor = .white
            self.boxNode = boxNode
            
            self.node?.addChild(self.boxNode!)
        }
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
        
        // Update the bubble UI
        updateUI(text: newContent)
        
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
