//
//  MainViewController.swift
//  MWBLoopViewSwift
//
//  Created by 马文铂 on 15/12/24.
//  Copyright © 2015年 UK. All rights reserved.
//

import UIKit


class MainViewController: UIViewController,MWBLoopViewDelegate {

    override func viewDidLoad() {
        super.viewDidLoad()
        var loopView :MWBLoopView?
        
        loopView = MWBLoopView(frame: CGRectMake(0, 0, UIScreen.mainScreen().bounds.width, 144), collectionViewLayout: UICollectionViewFlowLayout());
        loopView?.loopViewDelegate = self
        loopView!.placeholder = UIImage(named:"share_weibo_default")
        self.view.addSubview(loopView!)
        
        
        loopView?.imageURLs = ["http://pic.58pic.com/58pic/13/18/14/87m58PICVvM_1024.jpg","http://pic.58pic.com/58pic/13/18/14/87m58PICVvM_1024.jpg","http://pic.58pic.com/58pic/13/18/14/87m58PICVvM_1024.jpg"];
//        loopView?.localImages = ["share_weibo_default","poi_image_default","share_weibo_default"]
    }
    func loopView(loopView: MWBLoopView, didSelected index: NSInteger) {
        print(index)
    }
    func loopView(loopView: MWBLoopView, didScrollToPage index: NSInteger) {
        print(index)
    }
}
