//
//  utils.swift
//  The Bubble App
//
//  Created by Cowboy Lynk on 9/14/19.
//  Copyright © 2019 Lampshade Software. All rights reserved.
//

import Foundation

let MAX_CONTENT_LENGTH = 300

struct RevResponse: Codable {
    let type: String
    let elements: [RevElement]?
    let ts: String?
    let end_ts: String?
    let id: String?
}

struct RevElement: Codable {
    let type: String
    let value: String
    let ts: String?
    let end_ts: String?
}
