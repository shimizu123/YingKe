//
//  GiftMessageModel.swift
//  YingKe
//
//  Created by 邓康大 on 2018/3/15.
//  Copyright © 2018年 邓康大. All rights reserved.
//

import UIKit

class GiftMessageModel: NSObject {
    
    var senderName = ""
    var senderURL = ""
    var giftName = ""
    var giftURL = ""
    
    init(senderName : String, senderURL : String, giftName : String, giftURL : String) {
        self.senderName = senderName
        self.senderURL = senderURL
        self.giftName = giftName
        self.giftURL = giftURL
    }
    
}


