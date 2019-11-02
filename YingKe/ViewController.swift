//
//  ViewController.swift
//  YingKe
//
//  Created by 邓康大 on 2017/6/12.
//  Copyright © 2017年 邓康大. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    var live : YKCell!
    var playerView : UIView!
    var ijkPlayer : IJKMediaPlayback!
    
    

    @IBOutlet weak var imgBack: UIImageView!
    @IBOutlet weak var btnLike: UIButton!
    @IBOutlet weak var btnGift: UIButton!
    @IBOutlet weak var btnBack: UIButton!
    
    @IBAction func tapLike(_ sender: UIButton) {
        
        let heart = DMHeartFlyView(frame: CGRect(x: 0, y: 0, width: 40, height: 40))
        
        heart.center = CGPoint(x: btnLike.frame.origin.x, y: btnLike.frame.origin.y)
        view.addSubview(heart)
        heart.animate(in: view)
        
        //爱心按钮 大小的关键帧动画
        let btnAnima = CAKeyframeAnimation(keyPath: "transform.scale")
        btnAnima.values = [1.0,0.7,0.5,0.3,0.5,0.7,1.0,1.2,1.4,1.2,1.0]
        btnAnima.keyTimes = [0.0,0.1,0.2,0.3,0.4,0.5,0.6,0.7,0.8,0.9,1.0]
        btnAnima.duration = 0.2
        sender.layer.add(btnAnima, forKey: "SHOW")
        
    }
    
    
    @IBAction func tapGift(_ sender: UIButton) {
        let duration = 3.0
        let car = UIImageView(image: #imageLiteral(resourceName: "porsche"))
        
        car.frame = CGRect(x: 0, y: 0, width: 0, height: 0)
        view.addSubview(car)
        
        let widthCar: CGFloat = 250
        let heightCar: CGFloat = 125
        
        UIView.animate(withDuration: duration) { 
            car.frame = CGRect(x: self.view.center.x-widthCar/2, y: self.view.center.y-heightCar/2, width: widthCar, height: heightCar)
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + duration) { 
            UIView.animate(withDuration: duration, animations: { 
                car.alpha = 0
            }, completion: { (completed) in
                car.removeFromSuperview()
            })
        }
        
        let layerFw = CAEmitterLayer()
        view.layer.addSublayer(layerFw)
        emmitParticles(from: sender.center, emitter: layerFw, in: view)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + duration * 2) {
            layerFw.removeFromSuperlayer()
        }
        
        
        
        
    }
    
    
    @IBAction func tapBack(_ sender: UIButton) {
        ijkPlayer.shutdown()
        
        navigationController?.popViewController(animated: true)
        navigationController?.setNavigationBarHidden(false, animated: true)
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        setBg()
        
        setPlayerView()
        
        bringBtnToFront()
    }
    
    func setPlayerView()  {
        self.playerView = UIView(frame: view.bounds)
        view.addSubview(self.playerView)
        
        ijkPlayer = IJKFFMoviePlayerController(contentURLString: live.url, with: nil)
        let pv = ijkPlayer.view!
        
        pv.frame = playerView.bounds
        pv.autoresizingMask = [.flexibleWidth,.flexibleHeight]
        playerView.insertSubview(pv, at: 1)
        ijkPlayer.scalingMode = .aspectFill
        
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if !self.ijkPlayer.isPlaying() {
            ijkPlayer.prepareToPlay()
        }
    }
    
    
    func setBg()  {
        let imgUrl = URL(string: live.portrait)
        imgBack.kf.setImage(with: imgUrl)
        
        let blurEffect = UIBlurEffect(style: .light)
        let effectView = UIVisualEffectView(effect: blurEffect)
        effectView.frame = imgBack.bounds
        effectView.autoresizingMask = [.flexibleWidth,.flexibleHeight]
        imgBack.addSubview(effectView)

        
    }
    
    func bringBtnToFront()  {
        view.bringSubview(toFront: btnLike)
        view.bringSubview(toFront: btnBack)
        view.bringSubview(toFront: btnGift)

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

