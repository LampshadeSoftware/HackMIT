//
//  Bubble.swift
//  The Bubble App
//
//  Created by Cowboy Lynk on 9/14/19.
//  Copyright © 2019 Lampshade Software. All rights reserved.
//

import Foundation

class Bubble {
    var content: String
    let startTime: Int
    var editable: Bool
    
    init() {
        content = ""
        startTime = 0
        editable = true
    }
    
    func setContent(revResponse: [RevElement]) {
        var newContent = ""
        for element in revResponse {
            if element.type != "punct" {
                newContent += " "
            }
            newContent += element.value
        }
        self.content = newContent
    }
}
