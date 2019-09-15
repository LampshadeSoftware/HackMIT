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
    let node: SKNode
	let labelNode: SKLabelNode
    
    init(node: SKNode) {
        content = ""
        editable = true
        self.node = node
		
		labelNode = SKLabelNode(text: content)
		self.node.addChild(labelNode)
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
        // TODO: Update the node
		self.labelNode.text = newContent
    }
}
