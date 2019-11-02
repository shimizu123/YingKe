//
//  DiscoverViewController.swift
//  YingKe
//
//  Created by 邓康大 on 2017/7/19.
//  Copyright © 2017年 邓康大. All rights reserved.
//

import UIKit

class DiscoverViewController: UIViewController, LiveGiftShowCustomDelegate {
    let screen = UIScreen.main.bounds.size
    let kTag: CGFloat = 200
    
    /*
     礼物视图支持很多配置属性，开发者按需选择。
     */
    lazy var customGiftShow: LiveGiftShowCustom = {
      let customShow = LiveGiftShowCustom.addToView(superView: self.view)
        customShow.addMode = .LiveGiftAddModeAdd
        customShow.setMaxGiftCount(maxGiftCount: 3)
        customShow.setShowMode(mode: .LiveGiftShowModeFromTopToBottom)
        customShow.setAppearMode(mode: .LiveGiftAppearModeLeft)
        customShow.setHiddenMode(mode: .LiveGiftHiddenModeNone)
        
        customShow.delegate = self
        
        return customShow
    }()
    
    var giftArr: [LiveGiftListModel] = []
    var giftDataSource: [NSDictionary] = {
        let giftData = [
        [
            "name": "松果",
            "rewardMsg": "扔出一颗松果",
            "personSort": 0,
            "goldCount": 3,
            "type": 0,
            "picUrl": "http://ww3.sinaimg.cn/large/c6a1cfeagw1fbks9dl7ryj205k05kweo.jpg"
        ],
        [
            "name": "花束",
            "rewardMsg": "献上一束花",
            "personSort": 6,
            "goldCount": 66,
            "type": 1,
            "picUrl": "http://ww1.sinaimg.cn/large/c6a1cfeagw1fbksa4vf7uj205k05kaa0.jpg"
        ],
        [
            "name": "果汁",
            "rewardMsg": "递上果汁",
            "personSort": 3,
            "goldCount": 18,
            "type": 2,
            "picUrl": "http://ww2.sinaimg.cn/large/c6a1cfeagw1fbksajipb8j205k05kjri.jpg"
        ],
        [
            "name": "棒棒糖",
            "rewardMsg": "递上棒棒糖",
            "personSort": 2,
            "goldCount": 8,
            "type": 3,
            "picUrl": "http://ww2.sinaimg.cn/large/c6a1cfeagw1fbksasl9qwj205k05kt8k.jpg"
        ],
        [
            "name": "泡泡糖",
            "rewardMsg": "一起吃泡泡糖吧",
            "personSort": 2,
            "goldCount": 8,
            "type": 4,
            "picUrl": "http://a3.qpic.cn/psb?/V12A6SP10iIW9i/AL.CfLAFH*W.Ge1n*.LwpXSImK.Hm1eCMtt4rm5WvCA!/b/dFOyjUpCBwAA&bo=yADIAAAAAAABACc!&rf=viewer_4"
        ]
        ]
        return giftData as [NSDictionary]
    }()
    
    lazy var firstUser: LiveUserModel = {
        let first = LiveUserModel()
        first.name = "first"
        first.iconUrl = "http://ww1.sinaimg.cn/large/c6a1cfeagy1ffbg8tb6wqj20gl0qogni.jpg"
        return first
        
    }()
    
    lazy var secondUser: LiveUserModel = {
        let second = LiveUserModel()
        second.name = "second"
        second.iconUrl = "http://ww1.sinaimg.cn/large/c6a1cfeagy1ffbgd5cr5nj209s0akgly.jpg"
        return second
        
    }()
    
    lazy var thirdUser: LiveUserModel = {
        let third = LiveUserModel()
        third.name = "third"
        third.iconUrl = "http://ww1.sinaimg.cn/large/c6a1cfeagy1ffbgeuwk21j205k05kq2w.jpg"
        
        return third
        
    }()
    
    lazy var fourthUser: LiveUserModel = {
        let fourth = LiveUserModel()
        fourth.name = "fourth"
        fourth.iconUrl = "http://ww1.sinaimg.cn/large/c6a1cfeagy1ffbgfpf5bgj205k07v3yk.jpg"
        return fourth
    }()
    
    lazy var fifthUser: LiveUserModel = {
        let fifth = LiveUserModel()
        fifth.name = "fifth"
        fifth.iconUrl = "http://ww1.sinaimg.cn/large/c6a1cfeagy1ffbgg5427qj205k05k748.jpg"
        return fifth
    }()
    
   // lazy var giftContainerView: GiftContainerView = GiftContainerView(frame: CGRect(x: 0, y: 100, width: 250, height: 100))
    
    
//    var categoryArray: [String] = ["关注","热门","附近","小视频","游戏"]
//    var categoryLabelArray: [UILabel] = []
    
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "弹幕"
        self.view.backgroundColor = RGB(r: 0, g: 237, b: 237)
        

        //初始化按钮
        let titles = ["first", "second", "third", "fourth", "fifth"]
        for i in 0..<titles.count {
            createBtnWithTag(tag: CGFloat(i) + kTag, title: titles[i], maxCount: CGFloat(titles.count))
        }
        //初始化数据源
        for gift in giftDataSource {
            let listModel = LiveGiftListModel(dict: gift as! [String : Any])
            giftArr.append(listModel)
        }
   
        //初始化弹幕视图
        _ = customGiftShow
        
        animateBtn()
        
//        for index in 0..<categoryArray.count {
//            var categoryLabel = UILabel()
//            categoryLabelArray.append(categoryLabel)
//            categoryLabel.font = UIFont.boldSystemFont(ofSize: 32)
//            categoryLabel.textAlignment = NSTextAlignment.center
//            if (index == 0) {
//                categoryLabel.textColor = UIColor.green
//            } else {
//                categoryLabel.textColor = UIColor.blue
//            }
//            categoryLabel.tag = index
//        }

    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        let model = LiveGiftShowModel.initModel(giftModel: giftArr[3], userModel: firstUser)
        customGiftShow.addLiveGiftShowModel(model: model)
    }
    
    
    func animateBtn()  {
        let animateBtn = createBtnWithTag(tag: 205, title: "sixth", maxCount: 3)
        animateBtn.center = CGPoint(x: screen.width / 2, y: screen.height - 150)
        
    }
    
    func RGB(r: CGFloat, g: CGFloat, b: CGFloat) -> UIColor {
        let color = UIColor(red: r/255.0, green: g/255.0, blue: b/255.0, alpha: 1.0)
        return color
    }
    func randomColor() -> UIColor {
        //0.0 to 1.0
        let hue = (arc4random() % 256) / UInt32(255.0)
        // 0.5 to 1.0,away from white
        let saturation = ((arc4random() % 128) / UInt32(255.0)) + UInt32(0.5)
        //0.5 to 1.0,away from black
        let brightness = ((arc4random() % 128) / UInt32(255.0)) + UInt32(0.5)
        
        return UIColor(hue: CGFloat(hue), saturation: CGFloat(saturation), brightness: CGFloat(brightness), alpha: 1)
    }
    
    /*
     以下是测试方法：
     分别是三种添加视图的方法
     animatedWithGiftModel:   从1开始动画展示到 model.toNumber 的效果，会累加；
     addLiveGiftShowModel:   普通的从1显示礼物视图，会+=1；
     addLiveGiftShowModel: showNumber: 普通的礼物显示视图，指定显示特定数字。
     */
    @objc func btnClicked(clickedBtn: UIButton)  {
        switch clickedBtn.tag {
        case 200:
           
            var model = LiveGiftShowModel.initModel(giftModel: giftArr[0], userModel: firstUser)
            model.toNumber = 8
            model.interval = .seconds(Int(0.15))
            customGiftShow.animatedWithGiftModel(showModel: model)

        case 201:
            let model = LiveGiftShowModel.initModel(giftModel: giftArr[1], userModel: secondUser)
            customGiftShow.addLiveGiftShowModel(model: model)

        case 202:
            let model = LiveGiftShowModel.initModel(giftModel: giftArr[2], userModel: thirdUser)
            customGiftShow.addLiveGiftShowModel(model: model, showNumber: 99)

        case 203:
            var model = LiveGiftShowModel.initModel(giftModel: giftArr[3], userModel: fourthUser)
            model.toNumber = 3
            customGiftShow.animatedWithGiftModel(showModel: model)

        case 204:
            var model = LiveGiftShowModel.initModel(giftModel: giftArr[4], userModel: fifthUser)
            model.toNumber = 2
            customGiftShow.animatedWithGiftModel(showModel: model)

        case 205:
            let model = LiveGiftShowModel.initModel(giftModel: giftArr[4], userModel: fifthUser)
            customGiftShow.animatedWithGiftModel(showModel: model)
            
        default:
            break
        }
    }
    
    /**
     弹幕移除回调代理
     
     @param showModel 数据模型
     */
    func giftDidRemove(showModel: LiveGiftShowModel) {
        NSLog("用户：%@ 送出了 %li 个 %@", showModel.user.name, showModel.currentNumber, showModel.giftModel.name)
    }
    
    
   
    
    
    
    func createBtnWithTag(tag: CGFloat, title: String, maxCount: CGFloat) -> UIButton {
        let btnWidth = (screen.width - 40) / maxCount
        let number = tag - kTag
        
        let btn = UIButton(frame: CGRect(x: 20 + number * btnWidth, y: 400, width: btnWidth, height: 40))
        btn.backgroundColor = randomColor()
        btn.tag = Int(tag)
        
        
        btn.setTitle(title, for: .normal)
        btn.setTitle(title, for: .highlighted)
        
        btn.addTarget(self, action: #selector(btnClicked), for: .touchUpInside)
        
        self.view.addSubview(btn)
        
        return btn
    }
    
    
    
    
    


    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
