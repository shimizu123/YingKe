//
//  LiveShowView.swift
//  YingKe
//
//  Created by 邓康大 on 2018/3/3.
//  Copyright © 2018年 邓康大. All rights reserved.
//  一个弹幕效果视图


import UIKit
import SnapKit
import SDWebImage

typealias liveGiftShowViewTimeOut = (LiveGiftShowView) -> ()

//背景宽高
let kViewWidth: CGFloat = 240.0
let kViewHeight: CGFloat = 44.0

class LiveGiftShowView: UIView {
    
    //送礼者
    let kNameLabelFont: CGFloat = 12.0
    //送礼者颜色
    let kNameLabelTextColor = UIColor.white
    //送出礼物寄语  字体大小
    let kGiftLabelFont: CGFloat = 10.0
    //礼物寄语 字体颜色
    let kGiftLabelTextColor = UIColor.orange
    let kGiftNumberWidth: CGFloat = 15.0
    
    
    //超时移除时长
    let kTimeOut = 3
    //移除动画时长
    let kRemoveAnimatioTime: TimeInterval = 0.5
    //数字改变动画时长
    let kNumberAnimationTime: TimeInterval = 0.25
    //视图创建时间，用于LiveGiftShow替换旧的视图
    var createDate: Date!
    //用于LiveGiftShow判断是第几个视图
    var index: Int!
    
    //  消失模式
    var hiddenMode: LiveGiftHiddenMode!
    //  弹幕效果数字变化的视图
    lazy var numberView: LiveGiftShowNumberView = {
        let numberV = LiveGiftShowNumberView()
        self.addSubview(numberV)
        return numberV
    }()
    //是否正处于动画，用于上下视图交换位置时使用
    var isAnimation = false
    //是否正处于动画，用于视图正在向右飞出时不要交换位置
    var isLeavingAnimation = false
    //是否正处于动画，用于出现动画时和交换位置的动画冲突
    var isAppearAnimation = false
    //闭包
    var closure: liveGiftShowViewTimeOut?
    
    
    /**< 背景图 */
    lazy var backIV: UIImageView = {
        let back = UIImageView()
        back.image = UIImage(named: "w_liveGiftBack")
        self.addSubview(back)
        return back
    }()
    /**< 头像 */
    lazy var iconIV: UIImageView = {
        let icon = UIImageView()
        icon.image = UIImage(named: "LiveDefaultIcon")
        icon.layer.cornerRadius = 15
        icon.layer.masksToBounds = true
        self.addSubview(icon)
        return icon
    }()
    /**< 名称 */
    lazy var nameLabel: UILabel = {
        let name = UILabel()
        name.textColor = kNameLabelTextColor
        name.font = UIFont.systemFont(ofSize: kNameLabelFont)
        self.addSubview(name)
        return name
    }()
    /**< 送出 */
    lazy var sendLabel: UILabel = {
        let send = UILabel()
        send.font = UIFont.systemFont(ofSize: kGiftLabelFont)
        send.textColor = kGiftLabelTextColor
        self.addSubview(send)
        return send
    }()
    /**< 礼物图片 */
    lazy var giftIV: UIImageView = {
        let gift = UIImageView()
        self.addSubview(gift)
        return gift
    }()
    /**< 定时器控制自身移除 */
    var liveTimer: Timer?
    var liveTimerForSecond = 0
    var isSetNumber = true
    //数据源
    var model: LiveGiftShowModel! {
        didSet {
            nameLabel.text = model.user.name
            iconIV.sd_setImage(with: URL(string: model.user.iconUrl), placeholderImage: UIImage(named: "LiveDefaultIcon.jpeg"))
            
            sendLabel.text = model.giftModel.rewardMsg
            giftIV.sd_setImage(with: URL(string: model.giftModel.picUrl), placeholderImage: nil )
            
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
    }
    
    override init(frame: CGRect) {
        super.init(frame: CGRect(x: frame.origin.x, y: frame.origin.y, width: kViewWidth, height: kViewHeight))
        liveTimerForSecond = 0
        setupContentConstraints()
        createDate = Date()
       
    }
    
   
    /**
     重置定时器和计数
     
     @param number 计数
     */
    func resetTimeAndNumberFrom(number: Int)  {
        numberView.num = number
        addGiftNumberFrom(number: number)
    }
    /**
     获取用户名
     
     @return 获取用户名
     */
    func getUserName() -> String {
        return nameLabel.text!
    }
    
    /*
    礼物数量自增1使用该方法
    
    @param number 从多少开始计数
    */
    func addGiftNumberFrom(number: Int)  {
        if (!isSetNumber) {
            numberView.num = number
            isSetNumber = true
        }
        //每调用一次self.numberView.number get方法 自增1
        let num = numberView.num
        numberView.changeNumber(number: num)
        handleNumber(number: num)
        model.currentNumber = num
        createDate = Date()
        
    }
    /**
     设置任意数字时使用该方法
     
     @param number 任意数字 >9999 则显示9999
     */
    func changeGiftNumber(number: Int)  {
        DispatchQueue.main.async {
            self.numberView.changeNumber(number: number)
            self.handleNumber(number: number)
        }
                 
        
    }
    /**
     处理显示数字 开启定时器
     
     @param number 显示数字的值
     */
    func handleNumber(number: Int)  {
        liveTimerForSecond = 0
        //根据数字修改self.giftIV的约束 比如 1 占 10 的宽度，10 占 20的宽度
        let numStr = NSString(format: "%d", number)
        let giftRight = CGFloat(numStr.length) * kGiftNumberWidth + kGiftNumberWidth
        
        giftIV.snp.makeConstraints { (make) in
            make.right.equalToSuperview().offset(-kGiftNumberWidth - giftRight)
        }
        
        if (numStr.length >= 4) {
            giftIV.snp.makeConstraints({ (make) in
                make.right.equalToSuperview().offset(-kGiftNumberWidth * 6)
            })
            
        }
        if (!numberView.transform.isIdentity) {
            numberView.layer.removeAllAnimations()
        }
        numberView.transform = .identity
        
        UIView.animate(withDuration: kNumberAnimationTime, animations: {
            self.numberView.transform = CGAffineTransform(scaleX: 1.5, y: 1.5)
        }) { (finished) in
            self.numberView.transform = .identity
        }
        
        addTimer()
           
    }
    
    @objc func liveTimerRunning()  {
      liveTimerForSecond += 1
      if (liveTimerForSecond > kTimeOut) {
            if (isAnimation) {
                isAnimation = false
                return
            }        
        isAnimation = true
        isLeavingAnimation = true
        var xChanged = UIScreen.main.bounds.size.width
        
        switch (hiddenMode) {
        case .LiveGiftHiddenModeLeft:
            xChanged = -xChanged
            
        default:
            break
        }
        if hiddenMode == .LiveGiftHiddenModeNone {
            isLeavingAnimation = false
            if let close = closure {
                close(self)
            }
            self.removeFromSuperview()
            
        }else {
            UIView.animate(withDuration: kRemoveAnimatioTime, delay: kNumberAnimationTime , options: .curveEaseIn, animations: {
                self.transform = CGAffineTransform(translationX: xChanged, y: 0)
            }) { (finished) in
                self.isLeavingAnimation = false
                if let close = self.closure {
                    close(self)
                }
                self.removeFromSuperview()
            }
        }
        stopTimer()
            
      }
    }
    func setupContentConstraints()  {
        backIV.snp.makeConstraints { (make) in
            make.edges.equalTo(0)
        }
        iconIV.snp.makeConstraints { (make) in
            make.left.equalTo(6)
            make.width.height.equalTo(30)
            make.centerY.equalToSuperview()
        }
        nameLabel.snp.makeConstraints { (make) in
            make.top.equalToSuperview().offset(9)
            make.left.equalTo(iconIV.snp.right).offset(6)
            make.width.equalTo(86)
        }
        sendLabel.snp.makeConstraints { (make) in
            make.bottom.equalToSuperview().offset(-9)
            make.left.equalTo(nameLabel)
        }
        giftIV.snp.makeConstraints { (make) in
            make.left.equalTo(nameLabel.snp.right).offset(5).priority(750)
            make.width.equalTo(32)
            make.height.equalTo(24)
            make.centerY.equalToSuperview()
    
        }
        numberView.snp.makeConstraints { (make) in
            make.right.equalToSuperview().offset(-kGiftNumberWidth)
            make.centerY.height.equalToSuperview()
        }
        
        
    }
    
   
    
    
    
    func addTimer()  {
        liveTimer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(liveTimerRunning), userInfo: nil, repeats: true)
        RunLoop.current.add(liveTimer!, forMode: .commonModes)
        
    }
    
    func stopTimer()  {
        liveTimer?.invalidate()
        liveTimer = nil
    }
    
    

}
