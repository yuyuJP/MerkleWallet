//
//  BISettingsTopView.swift
//  SwiftBitcoin
//
//  Created by Yusuke Asai on 2017/07/01.
//  Copyright © 2017年 Yusuke Asai. All rights reserved.
//

import UIKit

public protocol BISettingsTopViewDelegate {
    func showPrivateKeyButtonTapped()
}

class BISettingsTopView: UIView {
    
    public var delegate: BISettingsTopViewDelegate? = nil
    
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
        
        placeSettingsButton(self.frame.size)
    }
    
    func placeSettingsButton(_ viewSize: CGSize) {
        let topMargin: CGFloat = 5.0
        
        let statusBarSize: CGFloat = 20.0
        
        let btnHeight = 64.0 - statusBarSize - topMargin
        let btnWidth = btnHeight * 2
        
        let settingsBtn = UIButton(frame: CGRect(x: 10.0, y: statusBarSize / 2 + viewSize.height / 2 - btnHeight / 2, width: btnWidth, height: btnHeight))
        let settingImg = UIImage(named: "key.png")
        settingsBtn.setImage(settingImg!, for: .normal)
        settingsBtn.addTarget(self, action: #selector(settingsButtonTapped), for: .touchUpInside)
        //settingsBtn.backgroundColor = .red
        self.addSubview(settingsBtn)
    }
    
    @objc func settingsButtonTapped() {
        delegate?.showPrivateKeyButtonTapped()
    }
}
