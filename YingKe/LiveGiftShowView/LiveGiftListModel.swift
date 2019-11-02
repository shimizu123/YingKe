//
//  LiveGiftListModel.swift
//  YingKe
//
//  Created by 邓康大 on 2018/3/3.
//  Copyright © 2018年 邓康大. All rights reserved.
//

import Foundation

class LiveGiftListModel: NSObject {
    //礼物图片
    var picUrl = ""
    //礼物文字
    var rewardMsg = ""
    //礼物类型
    var type = 0
    var name = ""
    //var highlightedImage = ""
    var personSort = 0
    var goldCount = 0
    
    override init() {
        super.init()
    }
    
    init(dict: [String: Any]) {
        super.init()
        picUrl = (dict["picUrl"] as? String)!
        rewardMsg = (dict["rewardMsg"] as? String)!
        type = (dict["type"] as? Int)!
        name = (dict["name"] as? String)!
        //highlightedImage = (dict["highlightedImage"] as? String)!
        personSort = (dict["personSort"] as? Int)!
        goldCount = (dict["goldCount"] as? Int)!
        
        
    }
    
    override func setValue(_ value: Any?, forUndefinedKey key: String) {
        
    }
    
    
    
}
