//
//  MWBLoopViewCollectionViewCell.swift
//  MWBLoopViewSwift
//
//  Created by 马文铂 on 15/12/24.
//  Copyright © 2015年 UK. All rights reserved.
//

import UIKit

class MWBLoopViewCollectionViewCell: UICollectionViewCell {
    var LoopImageView :UIImageView!
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.makeSubViews()
        fatalError("init(coder:) has not been implemented")
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        self.makeSubViews()
    }
    func set(){
        self.LoopImageView.frame = self.bounds;
    }
    func makeSubViews(){
        self.LoopImageView = UIImageView(frame: self.bounds)
        self.LoopImageView.userInteractionEnabled = true
        self.addSubview(self.LoopImageView)
    }
    
}
