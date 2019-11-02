//
//  GiftChannelView.swift
//  YingKe
//
//  Created by 邓康大 on 2018/3/15.
//  Copyright © 2018年 邓康大. All rights reserved.
//

import UIKit
import Kingfisher

/**
 思路分析 :
 当处于正在实行动画的时候,需要判断是不是同一个用户传过来的是否是同一个模型,
 如果是同一个用户 在执行同一个操作,需要将动画 Label 数字加1;
 如果是同一个用户或者不同用户 执行的不同操作,需要判断另外一个频道是否处于闲置,如果是处于闲置状态,则在另外一个频道中执行,否则将任务添加到缓存池中,等待有任务结束后,在从缓存池中取出任务来执行
 */
// 频道视图的状态
enum GiftChannelState {
    case idle, // 空闲时候
     animating, // 正在实行动画 这个状态时候:需要判断是不是同一个用户传过来的是否是同一个模型,
     willEnd, // 动画结束,停顿3s 的状态
     endAnimating // 消失动画状态
}

protocol GiftChannelViewDelegate: class {
    func giftAnimationDidCompletion(giftChannelView: GiftChannelView)
}

class GiftChannelView: UIView {
    
    // MARK: 设置代理属性
    var delegate: GiftChannelViewDelegate?
    
    @IBOutlet weak var bgView: UIView!
    @IBOutlet weak var iconImageView: UIImageView!
    @IBOutlet weak var sendLabel: UILabel!
    @IBOutlet weak var giftDescLabel: UILabel!
    @IBOutlet weak var giftImageView: UIImageView!
    @IBOutlet weak var digitLabel: GiftDigitLabel!
    
    // 定义一个属性,用来记录当前的数
    var currentNumber = 0
    // 定义一个缓存数据,当动画处于 animating 状态时,用来保存同一个user发送的同一个礼物
    var cacheNumber = 0
    // 定义当前频道视图的状态, 默认是空闲状态
    var state: GiftChannelState = .idle
    
    // 数据源
    var giftModel: GiftMessageModel! {
        didSet {
            // 1.对模型进行校验
            guard let giftModel = giftModel else {
                return
            }
            // 2.给控件设置信息
            let iconUrl = URL(string: giftModel.senderURL)
            let giftUrl = URL(string: giftModel.giftURL)
            
            iconImageView.kf.setImage(with: iconUrl)
            giftImageView.kf.setImage(with: giftUrl)
                        
            sendLabel.text = giftModel.senderName
            giftDescLabel.text = "送出礼物：\(giftModel.giftName)"
            
            
            // 3.将ChanelView弹出,将数据传递给频道视图的时候,此时的状态为正在执行动画状态
            state = .animating
            performAnimation()
            
        }
    }
    // MARK: 设置 UI
    override func layoutSubviews() {
        super.layoutSubviews()
        
        bgView.layer.cornerRadius = self.frame.height * 0.5
        iconImageView.layer.cornerRadius = self.frame.height * 0.5
        bgView.layer.masksToBounds = true
        iconImageView.layer.masksToBounds = true
        iconImageView.layer.borderWidth = 1
        iconImageView.layer.borderColor = UIColor.green.cgColor
    }
    
    // MARK:- 对外提供的函数
    // 增加缓存
    func addOnceToCache() {
        //当处于正在等待任务的时候3.0s 时候,直接执行动画,动画结束后,然后再取消任务 ,然后在执行动画
        if state == .willEnd {
            performDigitAnimation()
            // 取消任务: 这个方法的作用是取消  self.perform(#selector(self.performEndAnimation) 方法
            NSObject.cancelPreviousPerformRequests(withTarget: self)
            
        }else {
            // 当不是处于在等待任务的时候,才可以在缓存池中数据+1,如果处于等待的状态,直接执行动画,就不需要将任务添加到缓存池当中
            cacheNumber += 1
        }
        
    }
    
    // 从 Xib 加载视图
    class func loadFromNib() -> GiftChannelView {
        return Bundle.main.loadNibNamed("GiftChannelView", owner: nil, options: nil)?.first as! GiftChannelView
    }
    
    

    // MARK: 执行动画代码
    /**
     思路分析: 先将 ChannelView 视图弹出,弹出后执行倍数Label的跳动动画
     */
    // 显示频道视图
    func performAnimation() {
       self.frame.origin.x = -self.frame.width
        digitLabel.text = "x1"
        
        // 弹出动画
        UIView.animate(withDuration: 0.25, animations: {
            self.digitLabel.alpha = 1.0
            self.frame.origin.x = 0
        }) { (finished) in
            // 执行 label 的跳动动画
            // 将频道视图显示出来后,要显示数字 Label 并添加动画
            self.performDigitAnimation()
        }
        
        
    }
    // 执行文字弹跳效果
    func performDigitAnimation() {
        currentNumber += 1
        digitLabel.text = "X【\(currentNumber)】"
        // 在执行完 label 的弹跳动画以后,判断缓存中有没有任务,如果有缓存,执行缓存任务:将缓存-1,然后递归执行动画,至到缓存池中没有任务为止
        digitLabel.showDigitAnimation {
            // 用户连击
            if self.cacheNumber > 0 { //说明缓存池中有等待的任务
                self.performDigitAnimation()
                self.cacheNumber -= 1
            }else { // 执行完动画后,下一个操作是等待消失状态(3.0s 等待),这时候的状态是willEnd
                self.state = .willEnd
                self.perform(#selector(self.performEndAnimation), with: nil, afterDelay: 3.0)
            }
        }
        
        
        
        
    }
    // 执行消失动画,这时候的状态为endAnimating状态
    @objc func performEndAnimation() {
        state = .endAnimating
        UIView.animate(withDuration: 0.25, animations: {
            self.frame.origin.x = UIScreen.main.bounds.size.width
           // self.alpha = 0
        }) { (finished) in // 在动画消失后,这时候的状态为闲置状态即 : idle
            // 清空模型数据,如果不设置,在外面判断是不是同一个模型的时候会出问题: 如果是同一个模型,需要执行同一个视图,如果不是同一个模型,需要将模型添加到缓存池当中,等待执行
            self.currentNumber = 0
            self.cacheNumber = 0
            self.giftModel = nil
            // 将视图的位置重新回到屏幕的最左端
            self.frame.origin.x = -self.frame.width
            self.state = .idle
            self.alpha = 0
            
            // 动画执行完以后,将消息传递给上一个控件,告诉控制器
            self.delegate?.giftAnimationDidCompletion(giftChannelView: self)
            
        }
        
    }
    
    
    
}
