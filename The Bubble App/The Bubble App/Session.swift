//
//  Session.swift
//  The Bubble App
//
//  Created by Cowboy Lynk on 9/14/19.
//  Copyright © 2019 Lampshade Software. All rights reserved.
//

import Foundation
import SpriteKit

class Session {
    var bubbles: [Bubble]
	var addToScene: (_ bubble: Bubble) -> Void
    
	init(addToScene: @escaping (_ bubble: Bubble) -> Void) {
        bubbles = []
        self.addToScene = addToScene
    }
    
    func updateBubbleContent(revResponse: RevResponse) {
        let elements = revResponse.elements ?? []
        if elements.count == 0 {
            return
        }
        
        let final = revResponse.type == "final"
        let currentBubble = getCurrentBubble()
        currentBubble.setContent(revElements: elements, final: final)
        if (final) {
            currentBubble.editable = false
        }
    }
    
    /**
     Returns the next editable bubble in the list of bubbles.
     If there is no editable bubble, we make a new one.
     */
    private func getCurrentBubble() -> Bubble {
        if let lastBubble = bubbles.last {
            if lastBubble.editable {
                return lastBubble
            }
        }
        
        let newBubble = Bubble()
		addToScene(newBubble)
        bubbles.append(newBubble)
        return newBubble
    }
}
