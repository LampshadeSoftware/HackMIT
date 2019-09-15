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
    
    init() {
        content = ""
        editable = true
    }
    
    func setNode(node: SKNode) {
        self.node = node
        labelNode = SKLabelNode(text: content)
        self.node!.addChild(labelNode!)
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
        
        // Once done updating, initial kill sequence
        if (final) {
            node?.run(
                SKAction.sequence([
                    SKAction.wait(forDuration: 2.0),
                    SKAction.removeFromParent()
                    ])
            )
        }
    }
}
