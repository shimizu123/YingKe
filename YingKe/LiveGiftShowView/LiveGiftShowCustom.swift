//
//  LiveGiftShowCustom.swift
//  YingKe
//
//  Created by 邓康大 on 2018/3/3.
//  Copyright © 2018年 邓康大. All rights reserved.
//

import UIKit

protocol LiveGiftShowCustomDelegate {
    
    func giftDidRemove(showModel: LiveGiftShowModel)
    
    
}

/**
 弹幕展现模式
 
 - fromTopToBottom: 自上而下
 - fromBottomToTop: 自下而上
 */
enum LiveGiftShowMode {
    case LiveGiftShowModeFromTopToBottom, LiveGiftShowModeFromBottomToTop
    
}
/**
 弹幕消失模式
 
 - right: 向右移出
 - left: 向左移出
 */
enum LiveGiftHiddenMode {
    case LiveGiftHiddenModeRight, LiveGiftHiddenModeLeft, LiveGiftHiddenModeNone
}
/**
 弹幕出现模式
 
 - none: 无效果
 - left: 从左到右出现（左进）
 */
enum LiveGiftAppearMode {
    case LiveGiftAppearModeNone, LiveGiftAppearModeLeft
}
/**
 弹幕添加模式（当弹幕达到最大数量后新增弹幕时）,默认替换
 
 - LiveGiftAddModeReplace: 当有新弹幕时会替换
 - LiveGiftAddModeAdd: 当有新弹幕时会进入队列
 */
enum LiveGiftAddMode {
    case LiveGiftAddModeReplace, LiveGiftAddModeAdd
}

class LiveGiftShowCustom: UIView {
    
    /**< 交换动画时长 */
    var kExchangeAnimationTime: TimeInterval!
    /**< 出现时动画时长 */
    var kAppearAnimationTime: TimeInterval!
    /** 弹幕添加模式,默认替换 */
    var addMode: LiveGiftAddMode!
    
    var delegate: LiveGiftShowCustomDelegate?
    
    /**< 两个弹幕之间的高度差 */
    let kGiftViewMargin: CGFloat = 50.0
    /**< 弹幕已移除的key */
    let kGiftViewRemoved = "kGiftViewRemoved"
    var maxGiftShowCount = 3
    
    var showMode: LiveGiftShowMode = .LiveGiftShowModeFromTopToBottom
    var hiddenMode: LiveGiftHiddenMode = .LiveGiftHiddenModeRight
    var appearMode: LiveGiftAppearMode = .LiveGiftAppearModeLeft
    
    /**< key([self getDictKey]):value(LiveGiftShowView*) */
    var showViewDict: [String: LiveGiftShowView] = [:]
    //用来记录模型的顺序
    /**< [LiveGiftShowView, "kGiftViewRemoved"] */
    var showViewArr: NSMutableArray = []
    // 待展示礼物队列
    var waitQueueArr: [LiveGiftShowModel] = []
    
    //初始化
    class func addToView(superView: UIView) -> LiveGiftShowCustom {
        let v = LiveGiftShowCustom()
        v.kExchangeAnimationTime = 0.25
        v.kAppearAnimationTime = 0.5
        v.addMode = .LiveGiftAddModeReplace
        superView.addSubview(v)
        //布局
        v.snp.makeConstraints { (make) in
            //这个改动之后要注意修改LiveGiftShowView.h的kViewWidth
            make.width.equalTo(240)
            make.height.equalTo(44)
            //这个可以任意修改
            make.left.equalTo(superView)
            //这个参数在的设定应该注意最大礼物数量时不要超出屏幕边界
            make.top.equalTo(superView.snp.top).offset(100)
        }
       // v.frame = CGRect(x: 0, y: 100, width: 240, height: 44)
        
        v.backgroundColor = UIColor.clear
        
        return v
    }
    /**
     *  设置是否打印信息
     *
     *  @param isDebug 开发的时候最好打开，默认是NO
     */
//    func enableInterfaceDebug(isDebug: Bool)  {
//        NSLog( "[%@ in line %d] %@", )
//    }
    /**
     设置最大礼物数量
     
     @param maxGiftCount 默认为3
     */
    func setMaxGiftCount(maxGiftCount: Int)  {
        maxGiftShowCount = maxGiftCount
    }
    /**
     设置弹幕展现模式
     
     @param model 弹幕展现模式
     */
    func setShowMode(mode: LiveGiftShowMode)  {
        showMode = mode
    }
    /**
     设置弹幕消失模式
     
     @param model 弹幕消失模式
     */
    func setHiddenMode(mode: LiveGiftHiddenMode)  {
        hiddenMode = mode
    }
    /**
     设置弹幕出现模式
     
     @param model 弹幕出现模式
     */
    func setAppearMode(mode: LiveGiftAppearMode)  {
        appearMode = mode
    }
    /**
     增加或者更新一个礼物视图
     
     @param showModel 礼物模型
     */
    func addLiveGiftShowModel(model: LiveGiftShowModel)  {
        addLiveGiftShowModel(model: model, showNumber: 0)
    }
    /**
     增加或者更新一个礼物视图
     
     @param showModel 礼物模型
     @param showNumber 如果传值，则显示改值，否则从1开始自增1
     */
    func addLiveGiftShowModel(model: LiveGiftShowModel, showNumber: Int)  {
        
        let key = getDictKey(model: model)
        let oldShowView = showViewDict[key]
        
        //判断是否强制修改显示的数字
        let isResetNumber = showNumber > 0 ? true : false
        
        //如果不存在旧模型
        if (oldShowView == nil) {
            //如果当前弹幕数量大于最大限制
            if (showViewArr.count >= maxGiftShowCount) {
                //判断数组是否包含kGiftViewRemoved , 不包含的时候进行排序
                if (!showViewArr.contains(kGiftViewRemoved)) {
                    if (addMode == .LiveGiftAddModeReplace) {
                         //排序 最小的时间在第一个                        
                       let sortArray = showViewArr.sortedArray(comparator: { (obj1, obj2) -> ComparisonResult in
                           let ob1 = obj1 as! LiveGiftShowView
                           let ob2 = obj2 as! LiveGiftShowView
                        
                           return (ob1.createDate.compare(ob2.createDate))
                       })
                       let oldestView = sortArray.first
                       //重置模型
                        resetView(view: oldestView as! LiveGiftShowView, nowModel: model, isChangeNum: isResetNumber, number: showNumber)
                        
                    }
                    return
                }
            }
            //计算视图Y值
            var showViewY: CGFloat = 0
            if (showMode == .LiveGiftShowModeFromTopToBottom) {
                showViewY = (kViewHeight + kGiftViewMargin) * CGFloat(showViewDict.keys.count)
            }else if (showMode == .LiveGiftShowModeFromBottomToTop){
                showViewY = -(kViewHeight + kGiftViewMargin) * CGFloat(showViewDict.keys.count)
            }
            //获取已移除的key的index
            let kRemovedViewIndex = showViewArr.index(of: kGiftViewRemoved)
            if (showViewArr.contains(kGiftViewRemoved)) {
                if (showMode == .LiveGiftShowModeFromTopToBottom) {
                    showViewY = CGFloat(kRemovedViewIndex) * (kViewHeight + kGiftViewMargin)
                }else if (showMode == .LiveGiftShowModeFromBottomToTop){
                    showViewY = CGFloat(-kRemovedViewIndex) * (kViewHeight + kGiftViewMargin)
                }
            }
            //创建新模型
            var frame = CGRect(x: 0, y: showViewY, width: 0, height: 0)
            if (appearMode == .LiveGiftAppearModeLeft) {
                frame = CGRect(x: -UIScreen.main.bounds.size.width, y: showViewY, width: 0, height: 0)
            }
            let newShowView = LiveGiftShowView(frame: frame)
            //赋值
            newShowView.model = model
            newShowView.hiddenMode = hiddenMode
            //改变礼物数量
            if (isResetNumber) {
                newShowView.resetTimeAndNumberFrom(number: showNumber)
            }else {
                newShowView.addGiftNumberFrom(number: 1)
            }
            appearWith(showView: newShowView)
            
            //超时移除
            //防止闭包循环引用
            weak var this = self
            newShowView.closure = {  (willRemoveShowView) in
                if (this?.delegate != nil) {
                    this?.delegate?.giftDidRemove(showModel: willRemoveShowView.model)
                }
                //从数组移除
                this?.showViewArr.replaceObject(at: willRemoveShowView.index, with: this?.kGiftViewRemoved as Any)
                //从字典移除
                let willRemoveShowViewKey = this?.getDictKey(model: willRemoveShowView.model)
                this?.showViewDict.removeValue(forKey: willRemoveShowViewKey!)
                
                print("移除了第%zi个,移除后数组 = %@ ,词典 = %@")
                
                //比较数量大小排序
                this?.sortShowArr()
                this?.resetY()
                if (this?.addMode == .LiveGiftAddModeAdd) {
                    this?.showWaitView()
                }else if (this?.addMode == .LiveGiftAddModeReplace){
                    willRemoveShowView.model.animatedTimer?.cancel()
                }
                
                
            }
            self.addSubview(newShowView)
            
            //加入数组
            if (showViewArr.contains(kGiftViewRemoved)) {
                newShowView.index = kRemovedViewIndex
                showViewArr.replaceObject(at: kRemovedViewIndex, with: newShowView)
            }else {
                newShowView.index = showViewArr.count
                showViewArr.add(newShowView)
            }
            //加入字典
            showViewDict[getDictKey(model: model)] = newShowView
            
        //如果存在旧模型
        }else {
            //修改数量大小
            if (isResetNumber) {
                oldShowView?.resetTimeAndNumberFrom(number: showNumber)
            }else {
                oldShowView?.addGiftNumberFrom(number: 1)
            }
            //比较数量大小排序
            sortShowArr()
            //排序后调整Y值
            resetY()
        }
    }
    /**
     添加一个礼物视图，若该礼物不在视图上则从数字1显示到指定数字的效果，否则继续增加指定数字
     
     @param showModel 礼物模型
     */
    func animatedWithGiftModel(showModel: LiveGiftShowModel)  {
        var showModel = showModel
        if (addMode == .LiveGiftAddModeAdd) {
            let oldShowView = showViewDict[getDictKey(model: showModel)]
            // 不存在旧视图
            if (oldShowView == nil) {
                var showCount = 0
                for i in showViewArr {
                    if (i is LiveGiftShowView) {
                        showCount += 1
                    }
                }
                //弹幕数量大于最大数量
                if (showCount >= maxGiftShowCount) {
                    addToQueue(showModel: showModel)
                    return
                }
            }
        }
        
        let tt = DispatchSource.makeTimerSource(flags: [], queue: .main)
        tt.schedule(wallDeadline: .now() + showModel.interval, repeating: showModel.interval, leeway: .seconds(0))
        var i = 0
        weak var this = self
        tt.setEventHandler {
            if (i < showModel.toNumber) {
                i += 1
                showModel.animatedTimer = tt
                this?.addLiveGiftShowModel(model: showModel)
                
            }else {
                tt.cancel()
                
            }
        }
        
        tt.resume()
    }
    
    func appearWith(showView: LiveGiftShowView)  {
        // 出现的动画
        if (appearMode == .LiveGiftAppearModeLeft) {
            showView.isAppearAnimation = true
            UIView.animate(withDuration: kAppearAnimationTime, animations: {
                var f = showView.frame
                f.origin.x = 0
                showView.frame = f
                
            }, completion: { (finished) in
                showView.isAppearAnimation = false
            })
        }
        
    }
    func resetY()  {
        for i in 0..<showViewArr.count {
            if let show = showViewArr[i] as? LiveGiftShowView {
                var showY = CGFloat(i) * (kViewHeight + kGiftViewMargin)
                if (showMode == .LiveGiftShowModeFromBottomToTop) {
                    showY = -showY
                }
                if (show.frame.origin.y != showY) {
                    if (!show.isLeavingAnimation) {
                        // 避免出现动画和交换动画冲突
                        if (show.isAppearAnimation) {
                            show.layer.removeAllAnimations()
                        }
                        UIView.animate(withDuration: kExchangeAnimationTime, animations: {
                            var showF = show.frame
                            showF.origin.y = showY
                            show.frame = showF
                            
                        }, completion: { (finished) in
                            
                        })
                        show.isAnimation = true
                        NSLog("%@ 重置动画",show)
                    }
                }
                
            }
        }
    }
    
    
    func sortShowArr()  {
        //如果当前数组包含kGiftViewRemoved 则将kGiftViewRemoved替换到LiveGiftShowView之后
        for i in 0..<showViewArr.count {
            if (showViewArr[i] is String) {
                if (i + 1 < showViewArr.count) {
                    searchLiveShowViewFrom(i: i + 1)
                    
                }
            }
        }
        //以当前 数字大小 比较，降序
        for i in 0..<showViewArr.count {
            for j in i..<showViewArr.count {
                if let showViewI = showViewArr[i] as? LiveGiftShowView, let showViewJ = showViewArr[j] as? LiveGiftShowView {
                    if (showViewI.numberView.getLastNumber() < showViewJ.numberView.getLastNumber()) {
                        showViewI.index = j
                        showViewI.isAnimation = true
                        showViewJ.index = i
                        showViewJ.isAnimation = true
                        showViewArr.exchangeObject(at: i, withObjectAt: j)
                    }
                }
                
                
            }
        }
        NSLog("排序后数组==>>> %@",showViewArr)
    }
    
    func searchLiveShowViewFrom(i: Int)  {
        for  j  in i..<showViewArr.count {
            if let next = showViewArr[j] as? LiveGiftShowView{
                if (next.frame.origin.x == UIScreen.main.bounds.size.width) {
                    continue
                }
                next.index = i - 1
                showViewArr.exchangeObject(at: i - 1, withObjectAt: j)
                return
            }
        }
    }
    
    func addToQueue(showModel: LiveGiftShowModel)  {
        var showModel = showModel
        let key = getDictKey(model: showModel)
        var oldNumber = 0
        for i in 0..<waitQueueArr.count {
            let oldModel = waitQueueArr[i]
            let oldKey = getDictKey(model: oldModel)
            if (oldKey == key) {
                oldNumber = oldModel.toNumber
                showModel.toNumber += oldNumber
                waitQueueArr.remove(at: i)
                break
            }
            
        }
        
        waitQueueArr.append(showModel)
    }
    
    
    
    func showWaitView()  {
        var showCount = 0
        for i in showViewArr {
            if (i is LiveGiftShowView) {
               showCount += 1
            }
        }
        if (showCount < maxGiftShowCount) {
            
            if let model = waitQueueArr.first {
                animatedWithGiftModel(showModel: model)
                waitQueueArr.removeFirst()
            }
        }
        
    }
    
    func resetView(view: LiveGiftShowView, nowModel: LiveGiftShowModel, isChangeNum: Bool, number: Int)  {
        let oldKey = getDictKey(model: view.model)
        let dictKey = getDictKey(model: nowModel)
         //找到时间早的那个视图 替换模型 重置数字
        view.model = nowModel
        if (isChangeNum) {
            view.resetTimeAndNumberFrom(number: number)
        }else {
            view.resetTimeAndNumberFrom(number: 1)
        }
        showViewDict.removeValue(forKey: oldKey)
        showViewDict[dictKey] = view
        
    }
    
    
    func getDictKey(model: LiveGiftShowModel) -> String {
        //默认以 用户名+礼物类型 为key
        let key = String(format: "%@%d", model.user.name, model.giftModel.type)
        
        return key
    }
    

}
