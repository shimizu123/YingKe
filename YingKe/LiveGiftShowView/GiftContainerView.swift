//
//  GiftContentView.swift
//  YingKe
//
//  Created by 邓康大 on 2018/3/16.
//  Copyright © 2018年 邓康大. All rights reserved.
//
/**
 礼物连击动画总结 :
 1> 定义 XJGiftDigitLabel
 * 有描边效果
 * 画两次文字
 * 需要执行动画(弹动效果)
 2> 定义 XJGiftChannelView视图
 * 使用 xib 创建View
 * 定义模型 XJGiftMessageModel
 * 开始执行弹动动画(左侧出,右侧消失)
 * 开始执行XJGiftDigitLabel动画
 * 延迟3s 执行消失动画
 * 定义一个外界可以添加缓存方法: 如果是正在等待消失,则直接执行XJGiftDigitLabel弹动动画,并且添加到缓存中
 * 需要给 channelView自定义状态
 * 给状态进行赋值
 3> 定义 XJGiftContentView 视图
 * 给XJGiftContentView 添加 channelView 视图
 * 让外界可以传入模型
 * 检测是否有正在执行的动画 channelView 和新传入的模型的 userName/ giftname 类型
 * 检测是否有限制 channelView
 * 将模型添加到缓存中
 * 监听 channelView 什么时候执行完动画,判断缓存中是否有内容,从缓存中取出所有相同内容,继续执行动画
 
 
 */

import UIKit


let kChannelCount = 2 // 频道的数量
let kChannelHeight: CGFloat = 40 // 频道的高度
let kChannelMargin: CGFloat = 10 // 频道之间的间距


class GiftContainerView: UIView, GiftChannelViewDelegate {

    // MARK: 懒加载属性
    // 定义一个数组,用来保存所有的频道视图,因为要要从这个数组中进行遍历,根据频道当前的状态来判断当前的 channelView 是否可以使用
    lazy var channelViews : [GiftChannelView] = []
    
    // 定义一个数组.用来保存所有的模型
    lazy var cacheGiftModels: [GiftMessageModel] = []
    
        
    
    // MARK: 构造函数
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    // MARK: 设置 UI 界面
    func setupUI() {
        
        // 1. 根据当前的频道书,创建频道视图
        let w: CGFloat = self.frame.width
        
        for i in 0..<kChannelCount {
            let y = (kChannelHeight + kChannelMargin) * CGFloat(i)
            // 1.1 创建频道视图
            let channelView = GiftChannelView.loadFromNib()
            channelView.frame = CGRect(x: 0, y: y, width: w, height: kChannelHeight)
            channelView.alpha = 0
            
            channelView.delegate = self
            
            self.addSubview(channelView)
            
            channelViews.append(channelView)
            
            
        }
        
    }
    // MARK: 给外界提供一个方法,用来展示礼物视图,让外界传递礼物模型
    func showGiftModelView(giftModel: GiftMessageModel) {
        // 1. 判断正在忙的ChannelView和赠送的新礼物的(username/giftname)
        if let channelView = checkUsingChanelView(giftModel: giftModel) {
            channelView.addOnceToCache()
            return
        }
        // 2. 判断有没有闲置的ChannelView
        if let channelView = checkIdleChannelView() {
            channelView.giftModel = giftModel
            return
        }
        // 3. 将数据放入缓存中
        cacheGiftModels.append(giftModel)
        
        
    }
    
    // MARK: 检查 ChannelView 是否同一个用户传过来的同一个模型 遍历
    func checkUsingChanelView(giftModel : GiftMessageModel) -> GiftChannelView? {
        for channelView in channelViews {
            if giftModel.giftName == channelView.giftModel?.giftName && giftModel.senderName == channelView.giftModel?.senderName && channelView.state != .endAnimating {
                
                return channelView
            }
        }
        
        return nil
    }
        
    // MARK: 判断是否是处于闲置状态
    func checkIdleChannelView() -> GiftChannelView? {
        for channelView in channelViews {
            if channelView.state == .idle {
                return channelView
            }
        }
        
        return nil
    }
    
    // MARK: - XJGiftChannelViewDelegate 实现代理方法
    func giftAnimationDidCompletion(giftChannelView: GiftChannelView) {
        // 取出缓存中的模型
        guard cacheGiftModels.count != 0 else { // 判断有没有缓存
            return
        }
        
        // 取出缓存中的第一个模型
        let firstGiftModel = cacheGiftModels.first
        // 让闲置的 channelView 执行动画
        giftChannelView.giftModel = firstGiftModel
        // 移除数组中第一个模型
        cacheGiftModels.removeFirst()
        
        // 4. 将数组中剩余有和firstGiftModel相同的模型放入到ChanelView缓存中
        for i in 0..<cacheGiftModels.count {
            let giftModel = cacheGiftModels[i]
            
            if giftModel.giftName == firstGiftModel?.giftName && giftModel.senderName == firstGiftModel?.senderName {
                giftChannelView.addOnceToCache()
                
                cacheGiftModels.remove(at: i)
            }
            
        }
        
        
        
        
    }
    
}
