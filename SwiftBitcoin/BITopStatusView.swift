//
//  BITopStatusView.swift
//  SwiftBitcoin
//
//  Created by Yusuke Asai on 2017/07/01.
//  Copyright © 2017年 Yusuke Asai. All rights reserved.
//

import UIKit

import UIKit

class BITopStatusView: UIView {
    
    private var statusLabel: UILabel!
    
    override func draw(_ rect: CGRect) {
        
        let thickness: CGFloat = 1.0
        let boarder = UIBezierPath()
        let yAxis = self.frame.size.height - thickness
        boarder.move(to: CGPoint(x: 0.0, y: yAxis))
        boarder.addLine(to: CGPoint(x: self.frame.size.width, y: yAxis))
        boarder.close()
        
        UIColor.boarderGray().setStroke()
        
        boarder.lineWidth = thickness
        boarder.stroke()
    }
    
    public func setupStatusLabel(text: String) {
        statusLabel = UILabel()
        statusLabel.font = UIFont.systemFont(ofSize: 30.0)
        statusLabel.textColor = UIColor.themeColor()
        statusLabel.text = text
        statusLabel.textAlignment = .center
        statusLabel.sizeToFit()
        statusLabel.center = CGPoint(x: self.frame.size.width / 2.0, y: self.frame.size.height / 2.0)
        
        self.addSubview(statusLabel)
        
    }
    
    public func changeStatusLabel(text: String) {
        statusLabel.text = text
    }
}
