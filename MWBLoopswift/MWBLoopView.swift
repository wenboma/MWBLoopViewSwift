//
//  MWBLoopView.swift
//  MWBLoopViewSwift
//
//  Created by 马文铂 on 15/12/24.
//  Copyright © 2015年 UK. All rights reserved.
//

import UIKit
import SDWebImage
enum  MWBImageType{
    case LocalImage//加载本地图片
    case WebImage //加载网络图片
}

@objc protocol MWBLoopViewDelegate :NSObjectProtocol {
    
    @objc optional func loopView(loopView:MWBLoopView , didScrollToPage index:NSInteger)
    @objc optional func loopView(loopView:MWBLoopView , didSelected index:NSInteger)
}

class MWBLoopView: UICollectionView,UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout,MWBLoopViewDelegate {
    
    
    let MIN_MOVING_TIMEINTERVAL = 0.1 //最小滚动时间间隔
    let DEFAULT_MOVING_TIMEINTERVAL = 3.0 //默认滚动时间间隔
    
    var timer :NSTimer?
    var needRefresh :Bool = false
    
    
    var pageControl:UIPageControl?
    var pageLabel:UILabel?
    
    var loopViewDelegate:MWBLoopViewDelegate?
    
    var picAry : NSArray?
    
    var imageURLs:NSArray? = []{                            /******** @brife 网络图片数组 ******/
        
        didSet{
            
            let arr = NSMutableArray()
            if(imageURLs != nil){
                arr.addObject((imageURLs!.lastObject)!)
                arr.addObjectsFromArray(imageURLs as! [AnyObject])
                arr.addObject((imageURLs!.firstObject)!)
                imageURLs = NSArray(array: arr);
            }
            let ary:NSArray? = self.getPicAry()
            if(ary != nil){
                self.picAry =  ary
            }
            
            
            self.reloadData()
            self.loadPageControl()
            self.loadPageLabel()
            
            if(self.pageControl != nil && self.showPageControl && imageURLs != nil){
                self.pageControl!.numberOfPages = imageURLs!.count-2;
            }
            self.needRefresh = true
            
            self.judgeMoving()
        }
    }
    var localImages:NSArray? = []{                             /******* @brief 本地图片数组****/
        didSet{
            
            let arr = NSMutableArray()
            if(localImages != nil){
                arr.addObject((localImages!.lastObject)!)
                arr.addObjectsFromArray(localImages as! [AnyObject])
                arr.addObject((localImages!.firstObject)!)
                localImages = NSArray(array: arr);
            }
            let ary:NSArray? = self.getPicAry()
            if(ary != nil){
                self.picAry =  ary
            }
            
            self.reloadData()
            self.loadPageControl()
            self.loadPageLabel()
            
            if(self.pageControl != nil && self.showPageControl && localImages != nil){
                self.pageControl!.numberOfPages = localImages!.count-2;
            }
            self.needRefresh = true
            
            self.judgeMoving()
        }
    }
    var placeholder:UIImage?                                    /******* @brief 没有图片轮播的占位图****/
    var autoMoving:Bool         = true                          /******* @brief 是否自动播放 默认YES****/
    var movingTimeInterval:NSTimeInterval = 3                   /******* @brief 时间间隔 默认 3秒****/
    var currentPageIndex:NSInteger  = 0                         /******* @brief 进入滚动到多少页 默认0 如果大于array count ，显示第一张****/
    
    var imageType:MWBImageType  = MWBImageType.WebImage {       /******* @brief 加载图片类型 默认 网络图片****/
        didSet{
            
            let ary:NSArray? = self.getPicAry()
            if(ary != nil ){
                self.picAry =  ary
            }
        }
    }
    var showDefaultImage:Bool   = false                         /******* @brief 没有数据的时候是否显示 默认图 默认 NO****/
    var showPageControl:Bool    = true                          /******* @brief 是否显示pagecontrol 默认YES****/
    var showpageLabel:Bool      = true                          /******* @brief 是否显示 滑动到哪儿的label 默认YES****/
    var hidePageControlWhenNoData:Bool   = true                 /******* @brief 是否隐藏pageControl 在只有一条或者没有数据的时候 默认隐藏YES****/
    var hidePageLabelWhenNoData:Bool     = true                 /******* @brief 是否隐藏pageLabel 在只有一条或者没有数据的时候 默认隐藏 YES****/
    var notAutoMovingWhenNoData:Bool     = true                 /******* @brief 是否自动滚动 在只有一条或者没有数据的时候 默认不滚动 YES****/
    var notScrollWhenNoData:Bool         = true                 /******* @brief 是否可以滚动 再只有一条数据时 默认不可以 YES****/
    var couldTouchNoData : Bool          = false                /******* @brief 没有数据时是否可点击 默认不可以 NO****/
    override init(frame: CGRect, collectionViewLayout layout: UICollectionViewLayout) {
        
        super.init(frame:frame ,collectionViewLayout:layout)
        self.makeSubViews()
    }
    required init?(coder aDecoder: NSCoder) {
        super.init(coder:aDecoder)
        fatalError("init(coder:) has not been implemented")
    }
    override func awakeFromNib() {
        self.makeSubViews()
    }
    
    func getPicAry() -> NSArray?{
        if(self.imageType == MWBImageType.WebImage){
            return self.imageURLs
        }else{
            return self.localImages
        }
    }
    
    
    
    func makeSubViews() {
        self.delegate = self;
        self.dataSource = self;
        self.pagingEnabled = true
        self.showsHorizontalScrollIndicator = false
        self.backgroundColor = UIColor.whiteColor()
        if(self.collectionViewLayout.isKindOfClass(UICollectionViewFlowLayout)){
            let layout:UICollectionViewFlowLayout = self.collectionViewLayout as! UICollectionViewFlowLayout;
            layout.scrollDirection = UICollectionViewScrollDirection.Horizontal;
            layout.minimumInteritemSpacing = 0;
            layout.minimumLineSpacing = 0;
            self.collectionViewLayout = layout;
        }else{
            self.collectionViewLayout = UICollectionViewLayout();
            let layout:UICollectionViewFlowLayout = self.collectionViewLayout as! UICollectionViewFlowLayout;
            layout.scrollDirection = UICollectionViewScrollDirection.Horizontal;
            layout.minimumInteritemSpacing = 0;
            layout.minimumLineSpacing = 0;
            self.collectionViewLayout = layout;
        }
        self.registerClass(MWBLoopViewCollectionViewCell.self, forCellWithReuseIdentifier: NSStringFromClass(MWBLoopViewCollectionViewCell))
        self.registerNofitication()
        
        
        self.imageType = MWBImageType.WebImage;
        self.autoMoving = true;
        self.currentPageIndex = 0;
        self.showDefaultImage = false;
        self.showPageControl = true
        self.showpageLabel = true
        self.hidePageControlWhenNoData = true
        self.hidePageLabelWhenNoData = true
        self.notAutoMovingWhenNoData = true
        self.notScrollWhenNoData = true;
        self.couldTouchNoData = false
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        if (self.needRefresh && self.picAry?.count > 0){
            
            //最左边一张图其实是最后一张图，因此移动到第二张图，也就是imageURL的第一个URL的图。
            self.scrollToItemAtIndexPath(NSIndexPath(forRow: ((self.currentPageIndex+1)>(picAry!.count-1) ? 1 : self.currentPageIndex+1) , inSection:0), atScrollPosition:UICollectionViewScrollPosition.None, animated: false)
            self.needRefresh = false;
        }
        self.loadPageControl();
        self.loadPageLabel();
    }
    func loadPageControl() {
        if(self.pageControl == nil&&self.showPageControl){
            self.pageControl = UIPageControl(frame: CGRectMake(0, self.frame.size.height-37, self.frame.size.width, 37));
            self.pageControl!.numberOfPages = 0;
        }
        if(self.pageControl != nil && self.showPageControl){
            if(self.superview != nil && !self.superview!.subviews.contains(self.pageControl!)){
                self.superview!.addSubview(self.pageControl!)
                self.superview!.bringSubviewToFront(self.pageControl!)
            }
        }
    }
    func loadPageLabel(){
        if(self.pageLabel == nil && self.showpageLabel){
            
            self.pageLabel = UILabel(frame: CGRectMake(self.frame.size.width-90, self.frame.size.height-37,60, 37))
            self.pageLabel!.font = UIFont.systemFontOfSize(15);
            self.pageLabel!.textColor = UIColor.whiteColor();
            self.pageLabel!.textAlignment = NSTextAlignment.Center
        }
        if(self.pageControl != nil && self.showPageControl){
            if(self.superview != nil && !self.superview!.subviews.contains(self.pageLabel!)){
                self.superview!.addSubview(self.pageLabel!)
                self.superview!.bringSubviewToFront(self.pageLabel!)
            }
        }
    }
    func registerNofitication() {
        NSNotificationCenter.defaultCenter().addObserver(self, selector:"applicationWillResignActive",name:UIApplicationWillResignActiveNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "applicationDidBecomeActive", name: UIApplicationDidBecomeActiveNotification, object: nil)
    }
    
    //程序被暂停的时候，应该停止计时器
    func applicationWillResignActive(){
        self.stopMoving()
    }
    
    //程序从暂停状态回归的时候，重新启动计时器
    func applicationDidBecomeActive(){
        self.judgeMoving();
    }
    
    func judgeMoving(){
        self.moving();
        if(self.picAry?.count <= 3 && self.picAry?.count > 0){
            if(self.pageControl != nil && self.showPageControl){
                self.pageControl!.hidden = false;
            }
            if(self.hidePageControlWhenNoData && self.pageControl != nil){
                self.pageControl!.hidden = true;
            }
            
            if(self.pageLabel != nil && self.showpageLabel){
                self.pageLabel!.hidden = false;
            }
            if(self.hidePageLabelWhenNoData && self.pageLabel != nil){
                self.pageLabel!.hidden = true;
            }
            
            if(self.notAutoMovingWhenNoData){
                self.applicationWillResignActive()
            }
            
            if(self.notScrollWhenNoData){
                self.scrollEnabled = false
            }
        }
    }
    
    func moving(){
        if (self.autoMoving)
        {
            self.startMoving();
        }else{
            self.stopMoving()
        }
    }
    
    func startMoving(){
        
        if(self.picAry?.count > 0){
            self.addTimer()
        }
    }
    
    func stopMoving(){
        self.removeTimer()
    }
    
    func addTimer() {
        self.removeTimer();
        let speed:NSTimeInterval? = self.movingTimeInterval < MIN_MOVING_TIMEINTERVAL ? DEFAULT_MOVING_TIMEINTERVAL : self.movingTimeInterval;
        self.timer = NSTimer.scheduledTimerWithTimeInterval(speed!, target: self, selector: "moveToNextPage", userInfo: nil, repeats: true)
        
    }
    
    func removeTimer(){
        if(self.timer != nil){
            self.timer!.invalidate()
        }
        self.timer = nil;
    }
    
    func moveToNextPage(){
        let newContentOffset:CGPoint = CGPoint(x: self.contentOffset.x + self.frame.size.width,y: 0);
        self.setContentOffset(newContentOffset, animated: true)
    }
    
    func adjustCurrentPage(scrollView:UIScrollView) -> NSInteger{
        var page:NSInteger = NSInteger(scrollView.contentOffset.x / self.frame.size.width) - 1;
        
        if (scrollView.contentOffset.x < self.frame.size.width){
            page = (self.picAry?.count)! - 3;
        }
        else if (scrollView.contentOffset.x >= self.frame.size.width * CGFloat((self.picAry?.count)!-1))
        {
            page = 0;
        }
        
        if(self.loopViewDelegate != nil && self.loopViewDelegate!.respondsToSelector("loopView:didScrollToPage:")){
            self.loopViewDelegate!.loopView!(self, didScrollToPage: page+1)
        }
        return page
    }
    
    func getCurrentScrolltoIndex(scrollView:UIScrollView ) -> NSInteger{
        var page:NSInteger! = Int(scrollView.contentOffset.x / self.frame.size.width - 1);
        
        if (scrollView.contentOffset.x < self.frame.size.width)
        {
            page = (self.picAry?.count)! - 3;
        }
        else if (scrollView.contentOffset.x >= self.frame.size.width * CGFloat((self.picAry?.count)! - 1))
        {
            page = 0;
        }
        return page;
    }
    func setPageControlIndexWithPage(page :NSInteger){
        if(self.showPageControl && self.pageControl != nil){
            if(page<self.pageControl!.numberOfPages){
                self.pageControl!.currentPage = page;
            }
        }
        if(self.showpageLabel && self.pageLabel != nil){
            
            self.pageLabel?.text = String(page+1) + "/" + String((self.picAry?.count)!-2)
        }
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return max((self.picAry?.count)! , Int(self.showDefaultImage))
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell:MWBLoopViewCollectionViewCell! = self.dequeueReusableCellWithReuseIdentifier(NSStringFromClass(MWBLoopViewCollectionViewCell), forIndexPath: indexPath) as! MWBLoopViewCollectionViewCell
        if (self.picAry?.count==0)
        {
            cell.LoopImageView.image = self.placeholder;
            return cell;
        }
        if(self.imageType == MWBImageType.WebImage){
            cell.LoopImageView.sd_setImageWithURL(NSURL(string: (self.picAry?[indexPath.row])! as! String), placeholderImage: self.placeholder)
            
        }else{
            cell.LoopImageView.image = UIImage(named:(self.picAry?[indexPath.row]) as! String)
        }
        return cell
    }
    
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        return CGSizeMake(self.frame.size.width, self.frame.size.height);
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAtIndex section: Int) -> UIEdgeInsets {
        return UIEdgeInsetsMake(0, 0, 0, 0);
    }
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        var  page:NSInteger! = 0;
        let lastIndex:NSInteger = self.picAry!.count - 3;
        
        if (indexPath.row == 0)
        {
            page = lastIndex;
        }
        else if (indexPath.row == self.picAry!.count-1)
        {
            page = 0;
        }
        else
        {
            page = indexPath.row - 1;
        }
        if(self.picAry?.count > 0){
            if (self.loopViewDelegate != nil && self.loopViewDelegate?.respondsToSelector("loopView:didSelected:") == true )
            {
                self.loopViewDelegate?.loopView!(self, didSelected: page+1)
            }
        }else {
            if(self.couldTouchNoData == true){
                if (self.loopViewDelegate != nil && self.loopViewDelegate?.respondsToSelector("loopView:didSelected:") == true )
                {
                    self.loopViewDelegate?.loopView!(self, didSelected: page+1)
                }
            }
        }
    }
    
    func scrollViewDidEndScrollingAnimation(scrollView: UIScrollView) {
        if(Int(scrollView.contentOffset.x) % Int(self.frame.size.width) != 0 ){
            scrollView.contentOffset = CGPointMake( CGFloat( (Int(scrollView.contentOffset.x) / Int(self.frame.size.width))*Int(self.frame.size.width) ),0)
        }
        //轮播滚动的时候 移动到了哪一页
        self.adjustCurrentPage(scrollView);
    }
    
    func scrollViewWillBeginDragging(scrollView: UIScrollView) {
        self.removeTimer()
    }
    
    func scrollViewDidEndDecelerating(scrollView: UIScrollView) {
        if (self.autoMoving){
            self.addTimer()
        }
        //用户手动拖拽的时候 移动到了哪一页
        self.adjustCurrentPage(scrollView)
    }
    
    func scrollViewDidScroll(scrollView: UIScrollView) {
        //向左滑动时切换imageView
        if (scrollView.contentOffset.x < self.frame.size.width )
        {
            self.contentOffset = CGPointMake(self.frame.size.width*CGFloat(self.picAry!.count-1)-(self.frame.size.width-scrollView.contentOffset.x), 0)
            self.setPageControlIndexWithPage(self.getCurrentScrolltoIndex(scrollView))
            return;
        }
        //向右滑动时切换imageView
        if (scrollView.contentOffset.x > CGFloat(self.picAry!.count - 1) * self.frame.size.width )
        {
            self.contentOffset = CGPointMake(self.frame.size.width+(scrollView.contentOffset.x-CGFloat(self.picAry!.count - 1) * self.frame.size.width), 0)
            self.setPageControlIndexWithPage(self.getCurrentScrolltoIndex(scrollView))
            return;
        }
        self.setPageControlIndexWithPage(self.getCurrentScrolltoIndex(scrollView))
    }
    
}


