//
//  BIAddressInputView.swift
//  SwiftBitcoin
//
//  Created by Yusuke Asai on 2017/07/01.
//  Copyright © 2017年 Yusuke Asai. All rights reserved.
//

import UIKit

class BIAddressInputView: UIView {
    
    
    override func draw(_ rect: CGRect) {
        let thickness: CGFloat = 0.5
        let boarder = UIBezierPath()
        let yAxis = self.frame.size.height - thickness
        boarder.move(to: CGPoint(x: 0.0, y: yAxis))
        boarder.addLine(to: CGPoint(x: self.frame.size.width, y: yAxis))
        boarder.close()
        
        UIColor.boarderGray().setStroke()
        
        boarder.lineWidth = thickness
        boarder.stroke()
    }
    
    
}
