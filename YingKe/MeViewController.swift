//
//  MeViewController.swift
//  YingKe
//
//  Created by 邓康大 on 2017/7/6.
//  Copyright © 2017年 邓康大. All rights reserved.
//

import UIKit
import LFLiveKit

class MeViewController: UIViewController, LFLiveSessionDelegate {
    var session: LFLiveSession!
    
    
    
    
    @IBOutlet weak var linkStatusLb: UILabel!
    
    @IBOutlet weak var beautyBtn: UIButton!
    
    @IBOutlet weak var changeCameraBtn: UIButton!

    @IBAction func changeCameraTap(_ sender: UIButton) {
        sender.isSelected = !sender.isSelected
        let position = session.captureDevicePosition
        session.captureDevicePosition = (position == AVCaptureDevice.Position.back) ? AVCaptureDevice.Position.front : AVCaptureDevice.Position.back
        
        
    }
    
    @IBAction func backBtn(_ sender: UIButton) {
        self.tabBarController?.selectedIndex = 0
        
    }
    
    @IBAction func beautyTap(_ sender: UIButton) {
        sender.isSelected = !sender.isSelected
        session.beautyFace = !session.beautyFace

    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.clear
        
        setup()

//        //MARK: - Getters and Setters
//            var session: LFLiveSession = {
//            let audioConfiguration = LFLiveAudioConfiguration.defaultConfiguration()
//            let videoConfiguration = LFLiveVideoConfiguration.defaultConfigurationForQuality(LFLiveVideoQuality.Low3, landscape: false)
//            let session = LFLiveSession(audioConfiguration: audioConfiguration, videoConfiguration: videoConfiguration)
//            
//            session?.delegate = self
//            session?.preView = self.view
//            return session!
//        }()
    }
    func setup()  {
        let audioConfiguration = LFLiveAudioConfiguration.default()
        let videoConfiguration = LFLiveVideoConfiguration.defaultConfiguration(for: LFLiveVideoQuality.low3)
        
        session = LFLiveSession(audioConfiguration: audioConfiguration, videoConfiguration: videoConfiguration)
        session.delegate = self
        session.preView = self.view

    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.tabBarController?.tabBar.isHidden = true
        
        self.requestAccessForAudio()
        self.requestAccessForVideo()
        
        self.startLive()
        
        
        
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.stopLive()
        
    }
    //MARK: - 请求方法
    func requestAccessForVideo()  {
        let status = AVCaptureDevice.authorizationStatus(for: AVMediaType.video)
        switch status {
        case .notDetermined:
            AVCaptureDevice.requestAccess(for: AVMediaType.video, completionHandler: { (granted) in
                if (granted){
                    DispatchQueue.main.async {
                        self.session.running = true
                    }
                }
            })
            break
            
        case .authorized:
            DispatchQueue.main.async {
                self.session.running = true
            }
            break
            
        case .denied:
            break
            
        case .restricted:
            break
            
        
        }
        
        
    }
    func requestAccessForAudio()  {
        let status = AVCaptureDevice.authorizationStatus(for: AVMediaType.audio)
        switch status {
        case .notDetermined:
            AVCaptureDevice.requestAccess(for: AVMediaType.audio, completionHandler: { (granted) in
                
            })
        case .authorized:
            break
            
        case .denied:
            break
            
        case .restricted:
            break

        
        }
        
    }
    //MARK : - LFStreamingSessionDelegate
    func liveSession(_ session: LFLiveSession?, liveStateDidChange state: LFLiveState) {
        switch state {
        case .ready:
            linkStatusLb.text = "未连接"
            break

        case .pending:
            linkStatusLb.text = "连接中..."
            break

        case .start:
            linkStatusLb.text = "开始连接"
            break

        case .stop:
            linkStatusLb.text = "断开连接"
            break

        case .refresh:
            linkStatusLb.text = "连接错误"
            break

            
        default:
            break
        }
    }
    func startLive()  {
        let stream = LFLiveStreamInfo()
        stream.url = "rtmp://192.168.0.103:1935/rtmplive/room"
        session.startLive(stream)
    }
    func stopLive()  {
        session.stopLive()
    }
    func liveSession(_ session: LFLiveSession?, errorCode: LFLiveSocketErrorCode) {
        print(errorCode)
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
