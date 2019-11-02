//
//  LiveGiftShowNumberView.swift
//  YingKe
//
//  Created by 邓康大 on 2018/3/3.
//  Copyright © 2018年 邓康大. All rights reserved.
//  弹幕效果数字变化的视图

import UIKit

class LiveGiftShowNumberView: UIView {

    /**< 初始化数字 */
    var _num: Int!
    
    var num: Int {
        get {
            _num = lastNumber
            lastNumber += 1
            return _num
        }
        set {
            lastNumber = newValue
        }
    }
    /**< 最后显示的数字 */
    var lastNumber: Int = 1
    
    var digitIV = UIImageView()
    var ten_digitIV = UIImageView()
    var hundredIV = UIImageView()
    var thousandIV = UIImageView()
    
    var xIV = UIImageView()
    
    
    /**
     改变数字显示
     
     @param number 显示的数字
     */
    func changeNumber(number: Int)  {
        if (number <= 0) {
            return
        }
        
        var qian = number / 1000
        let qianYu = number % 1000
        var bai = qianYu / 100
        let baiYu = qianYu % 100
        var shi = baiYu / 10
        let shiYu = baiYu % 10
        var ge = shiYu
        
        if (number > 9999) {
            qian = 9
            bai = 9
            shi = 9
            ge = 9
        }
        
        self.addSubview(digitIV)
        
        digitIV.image = UIImage(named: String(format: "w_%d", ge))
        
        digitIV.snp.makeConstraints { (make) in
            make.right.equalToSuperview()
            make.centerY.equalToSuperview()
        }
        
        var length = 1
        
        if (qian > 0) {
            length = 4
            self.addSubview(thousandIV)
            self.addSubview(hundredIV)
            self.addSubview(ten_digitIV)
            
            thousandIV.image = UIImage(named: String(format: "w_%d", qian))
            hundredIV.image = UIImage(named: String(format: "w_%d", bai))
            ten_digitIV.image = UIImage(named: String(format: "w_%d", shi))
            
            thousandIV.snp.makeConstraints({ (make) in
                make.right.equalTo(hundredIV.snp.left)
                make.centerY.equalToSuperview()
            })
            hundredIV.snp.makeConstraints({ (make) in
                make.right.equalTo(ten_digitIV.snp.left)
                make.centerY.equalToSuperview()
            })
            ten_digitIV.snp.makeConstraints({ (make) in
                make.right.equalTo(digitIV.snp.left)
                make.centerY.equalTo(digitIV)
            })
            
        }else if (bai > 0){
            length = 3
            thousandIV.removeFromSuperview()
            self.addSubview(hundredIV)
            self.addSubview(ten_digitIV)
            
            hundredIV.image = UIImage(named: String(format: "w_%d", bai))
            ten_digitIV.image = UIImage(named: String(format: "w_%d", shi))
            
            hundredIV.snp.makeConstraints({ (make) in
                make.right.equalTo(ten_digitIV.snp.left)
                make.centerY.equalTo(self)
            })
            ten_digitIV.snp.makeConstraints({ (make) in
                make.right.equalTo(digitIV.snp.left)
                make.centerY.equalTo(digitIV)
            })
            
            
        }else if (shi > 0){
            length = 2
            thousandIV.removeFromSuperview()
            hundredIV.removeFromSuperview()
            self.addSubview(ten_digitIV)
            
            ten_digitIV.image = UIImage(named: String(format: "w_%d", shi))
            
            ten_digitIV.snp.makeConstraints({ (make) in
                make.right.equalTo(digitIV.snp.left)
                make.centerY.equalTo(digitIV)
            })
            
            
        }else {
            length = 1
            thousandIV.removeFromSuperview()
            hundredIV.removeFromSuperview()
            ten_digitIV.removeFromSuperview()
            
        }
        self.addSubview(xIV)
        
        xIV.image = UIImage(named: "w_x")
        
        xIV.snp.makeConstraints { (make) in
            make.right.equalToSuperview().offset(-15 * length)
            make.centerY.equalToSuperview().offset(2)
            make.width.equalTo(15)
        }
        
        self.layoutIfNeeded()
    }
    
    /**
     获取显示的数字
     
     @return 显示的数字
     */
    func getLastNumber() -> Int {
        return lastNumber - 1
    }

}
