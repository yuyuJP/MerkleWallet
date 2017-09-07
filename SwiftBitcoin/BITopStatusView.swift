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
    private var progressBar: UIView!
    
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
    
    public func setupProgressBar() {
        let boarderLineThickness: CGFloat = 1.0
        let thickness: CGFloat = 3.0
        let yAxis = self.frame.size.height - boarderLineThickness - thickness
        progressBar = UIView(frame: CGRect(x: 0.0, y: yAxis, width: 0.0, height: thickness))
        progressBar.backgroundColor = UIColor.themeColor()
        
        self.addSubview(progressBar)
    }
    
    public func changeProgressBar(_ length: CGFloat) {
        if length > 1.0 {
            print("Invalid value(\(length)). ChangeProgressBar function in BITopStatusView.swift only accepts value between 0.0 - 1.0.")
            return
        }
        let prevFrame = progressBar.frame
        let barFrame = CGRect(x: prevFrame.origin.x, y: prevFrame.origin.y, width: self.frame.size.width * length, height: prevFrame.height)
        progressBar.frame = barFrame
    }
    
    public func disposeProgressBar() {
        progressBar.removeFromSuperview()
    }
    
    public func setupStatusLabel(text: String) {
        let height: CGFloat = 50.0
        
        statusLabel = UILabel()
        statusLabel.frame = CGRect(x: 0.0, y: (self.frame.size.height - height) / 2, width: self.frame.size.width, height: height)
        statusLabel.font = UIFont.systemFont(ofSize: 30.0)
        statusLabel.textColor = UIColor.themeColor()
        statusLabel.text = text
        statusLabel.textAlignment = .center
        self.addSubview(statusLabel)
        
    }
    
    public func changeStatusLabel(text: String) {
        statusLabel.text = text
    }
}
