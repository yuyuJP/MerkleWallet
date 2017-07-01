//
//  BIScrollView.swift
//  SwiftBitcoin
//
//  Created by Yusuke Asai on 2017/07/01.
//  Copyright © 2017年 Yusuke Asai. All rights reserved.
//

import UIKit

class BIScrollView: UIScrollView {
    
    override func touchesShouldCancel(in view: UIView) -> Bool {
        if view is UIButton {
            return  true
        }
        return  super.touchesShouldCancel(in: view)
    }
    
}
