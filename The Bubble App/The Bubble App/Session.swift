//
//  Session.swift
//  The Bubble App
//
//  Created by Cowboy Lynk on 9/14/19.
//  Copyright © 2019 Lampshade Software. All rights reserved.
//

import Foundation

class Session {
    var bubbles: [Bubble]
    
    init() {
        bubbles = [Bubble()]
    }
    
    func updateBubbleContent(revResponse: [RevElement], final: Bool) {
        let currentBubble = getCurrentBubble()
        currentBubble.setContent(revResponse: revResponse)
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
            if lastBubble.editable{
                return lastBubble
            }
        }
        let newBubble = Bubble()
        bubbles.append(newBubble)
        return newBubble
    }
}
