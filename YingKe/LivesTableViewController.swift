//
//  LivesTableViewController.swift
//  YingKe
//
//  Created by 邓康大 on 2017/6/12.
//  Copyright © 2017年 邓康大. All rights reserved.
//

import UIKit
import Just
import Kingfisher

class LivesTableViewController: UITableViewController {
    
    
    var previousOffsetY: CGFloat = 0.0
    let kViewHeight = UIScreen.main.bounds.size.height
    var deltaY: CGFloat = 0.0
    
    
    let livelisturl = "http://service.inke.com/api/live/simpleall?&gender=1&gps_info=116.346844%2C40.090467&loc_info=CN%2C%E5%8C%97%E4%BA%AC%E5%B8%82%2C%E5%8C%97%E4%BA%AC%E5%B8%82&is_new_user=1&lc=0000000000000053&cc=TG0001&cv=IK4.0.30_Iphone&proto=7&idfa=D7D0D5A2-3073-4A74-A726-98BE8B4E8F38&idfv=58A18E13-A21D-456D-B6D8-7499948B379D&devi=54b68af1895085419f7f8978d95d95257dd44f93&osversion=ios_10.300000&ua=iPhone6_2&imei=&imsi=&uid=450515766&sid=20XNNoa5VwMozGALfmi2xN1YCfLWvEq7aJuTHTQLu8bT88i1aNbi0&conn=wifi&mtid=391bb3520c38e0444ba0b3975f4bb1aa&mtxid=f0b42913a33c&logid=162,210&s_sg=3111b3a0092d652ab3bcb218099968de&s_sc=100&s_st=1492954889"
    
    
    
//    let livelisturl = "http://service.ingkee.com/api/live/gettop?imsi=&uid=17800399&proto=5&idfa=A1205EB8-0C9A-4131-A2A2-27B9A1E06622&lc=0000000000000026&cc=TG0001&imei=&sid=20i0a3GAvc8ykfClKMAen8WNeIBKrUwgdG9whVJ0ljXi1Af8hQci3&cv=IK3.1.00_Iphone&devi=bcb94097c7a3f3314be284c8a5be2aaeae66d6ab&conn=Wifi&ua=iPhone&idfv=DEBAD23B-7C6A-4251-B8AF-A95910B778B7&osversion=ios_9.300000&count=5&multiaddr=1"
    
    var list : [YKCell] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.navigationController?.hidesBarsOnSwipe = true
        
        loadlist()
        
        //下拉刷新
        self.refreshControl = UIRefreshControl()
        refreshControl?.addTarget(self, action: #selector(loadlist), for: .valueChanged)
    }
    
//    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
//        return 460.0
//    }
    
    @objc func loadlist()  {
        Just.post(livelisturl) { (r) in
            guard let json = r.json as? NSDictionary else {
                return
            }
            let lives = YKLiveStream(fromDictionary: json).lives!
            
            self.list = lives.map({ (live) -> YKCell in
                return YKCell(portrait: live.creator.portrait, nick: live.creator.nick, location: live.city, viewers: live.onlineUsers , url: live.streamAddr)
            })
            
            
            OperationQueue.main.addOperation {
                self.tableView.reloadData()
                self.refreshControl?.endRefreshing()
            }
           
        }
                   
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.tabBarController?.tabBar.isHidden = false
    }
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return list.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! LiveTableViewCell

        let live = list[indexPath.row]
        
        cell.labelAddr.text = live.location
        cell.labelNick.text = live.nick
        cell.labelViewers.text = "\(live.viewers)"
        
        //小头像 http://img.meelive.cn/
        let imgUrl = URL(string: live.portrait)
        
        cell.imgPor.kf.setImage(with: imgUrl)
        
        //大幅主播图
        cell.imgBigPor.kf.setImage(with: imgUrl)
        

        return cell
    }
    
    // MARK: - scrollView delegate
    override func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        //上次滑动距离
         previousOffsetY = scrollView.contentOffset.y
    }
    override func scrollViewDidScroll(_ scrollView: UIScrollView) {
        //相对移动距离
        deltaY = scrollView.contentOffset.y - previousOffsetY
        
        var frame = self.tabBarController?.tabBar.frame
        //展开坐标
        let openOffsetY = kViewHeight - (frame?.height)!
        //收起坐标
        let closeOffsetY = kViewHeight

        
        var newOffsetY = (frame?.minY)! + deltaY
        newOffsetY = min(closeOffsetY, max(openOffsetY, newOffsetY))
        
        frame?.origin.y = newOffsetY
        self.tabBarController?.tabBar.frame = frame!
        
        let tabBarMinY = self.tabBarController?.tabBar.frame.minY
        var scrollViewInset = self.tableView.contentInset
        scrollViewInset.bottom = max(0, kViewHeight - tabBarMinY!)
        
        UIView.animate(withDuration: 0.2) { 
            self.tableView.contentInset = scrollViewInset
            self.tableView.scrollIndicatorInsets = scrollViewInset
        }
        
        
        
    }
    override func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        
        var frame = self.tabBarController?.tabBar.frame
        //展开坐标
        let openOffsetY = kViewHeight - (frame?.height)!
        //收起坐标
        let closeOffsetY = kViewHeight
        
        
        func shouldOpen() -> Bool {
           
            var viewMinY = openOffsetY
            
            viewMinY = closeOffsetY + (openOffsetY - closeOffsetY) * 0.5
            
            if (viewMinY <= (frame?.minY)!) {
                return false
            }
            return true
        }
        
        var tabBarOffsetY: CGFloat = 0.0
        if (shouldOpen()) {
            //从当前位置到展开滑动的距离
            tabBarOffsetY = (frame?.minY)! - openOffsetY
        } else {
            //从当前位置到收起滑动的距离
            tabBarOffsetY = closeOffsetY - (frame?.minY)!
        }
        //更新contentInset
        var scrollViewInset = self.tableView.contentInset
        scrollViewInset.bottom = max(0, self.kViewHeight - (frame?.minY)!)
        
        //根据tabBar的偏移量来滑动tableView
        var contentOffset = self.tableView.contentOffset
        contentOffset.y += tabBarOffsetY
        
        UIView.animate(withDuration: 0.2) {
            
            
            self.tableView.contentInset = scrollViewInset
            self.tableView.scrollIndicatorInsets = scrollViewInset
            
            self.tableView.contentOffset = contentOffset
        }

    }
        
        
        
        
        
  

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        navigationController?.setNavigationBarHidden(true, animated: true)
        self.tabBarController?.tabBar.isHidden = true
        
        let dest = segue.destination as! ViewController
        dest.live = list[(tableView.indexPathForSelectedRow?.row)!]
        
    }
    

}
