//
//  LiveUserModel.swift
//  YingKe
//
//  Created by 邓康大 on 2018/3/3.
//  Copyright © 2018年 邓康大. All rights reserved.
//

import Foundation

class LiveUserModel: NSObject {
    var name = ""
    var iconUrl = ""
    
    
    override init() {
        super.init()
    }
    
    init(dict: [String: Any]) {
        super.init()
        name = (dict["name"] as? String)!
        iconUrl = (dict["iconUrl"] as? String)!
        
    }
    
    override func setValue(_ value: Any?, forUndefinedKey key: String) {
        
    }
}
