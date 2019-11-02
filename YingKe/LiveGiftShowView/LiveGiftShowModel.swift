//
//  LiveGiftShowModel.swift
//  YingKe
//
//  Created by 邓康大 on 2018/3/3.
//  Copyright © 2018年 邓康大. All rights reserved.
//  包含用户信息和礼物信息

import Foundation
import UIKit

struct LiveGiftShowModel {
    var giftModel: LiveGiftListModel!
    var user: LiveUserModel!
    //当前送礼数量
    var currentNumber: Int!
    
   //连续动画时使用
    //连续增加的数量
    var toNumber: Int = 1
    //连续增加时动画间隔
    var interval: DispatchTimeInterval = .seconds(Int(0.35))
    var animatedTimer: DispatchSourceTimer?
    
    
    static func initModel(giftModel: LiveGiftListModel, userModel: LiveUserModel) -> LiveGiftShowModel {
        var model = LiveGiftShowModel()
        model.giftModel = giftModel
        model.user = userModel
        
        return model
    }
    
}
