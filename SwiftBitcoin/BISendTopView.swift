//
//  BISendTopView.swift
//  SwiftBitcoin
//
//  Created by Yusuke Asai on 2017/07/01.
//  Copyright © 2017年 Yusuke Asai. All rights reserved.
//

import UIKit

public protocol BISendTopViewDelegate {
    func qrScanButtonTapped()
    func enterAddressButtonTapped()
}

class BISendTopView: UIView {
    
    let btnHeight: CGFloat = 54.0
    
    public var delegate: BISendTopViewDelegate? = nil
    
    override func draw(_ rect: CGRect) {
        placeScanQRButton(self.frame.size)
        placePayFromAddresssButton(self.frame.size)
        
    }
    
    func placeScanQRButton(_ viewSize: CGSize) {
        let btnWidth = viewSize.width / 1.5
        
        let scanQRBtn = UIButton(frame: CGRect(x: viewSize.width / 2.0 - btnWidth / 2.0, y: viewSize.height / 2.0 - btnHeight / 2.0, width: btnWidth, height: btnHeight))
        scanQRBtn.layer.masksToBounds = true
        scanQRBtn.setTitle(NSLocalizedString("scanQR", comment: ""), for: .normal)
        scanQRBtn.setBackgroundColorForBothState(UIColor.themeColor())
        scanQRBtn.layer.cornerRadius = 5.0
        
        scanQRBtn.addTarget(self, action: #selector(scanButtonTapped), for: .touchUpInside)
        
        self.addSubview(scanQRBtn)
    }
    
    //When there is a valid address in clipboard, pay to the address from clipboard
    func placePayFromAddresssButton(_ viewSize: CGSize) {
        let btnWidth = viewSize.width / 1.5
        
        let payFromAdrBtn = UIButton(frame: CGRect(x: viewSize.width / 2.0 - btnWidth / 2.0, y: viewSize.height / 2.0 - btnHeight / 2.0 + btnHeight * 2.0, width: btnWidth, height: btnHeight))
        payFromAdrBtn.layer.masksToBounds = true
        payFromAdrBtn.setTitle(NSLocalizedString("enterAddr", comment: ""), for: .normal)
        payFromAdrBtn.setBackgroundColorForBothState(UIColor.themeColor())
        payFromAdrBtn.layer.cornerRadius = 5.0
        
        payFromAdrBtn.addTarget(self, action: #selector(enterButtonTapped), for: .touchUpInside)
        
        self.addSubview(payFromAdrBtn)
    }
    
    @objc func scanButtonTapped() {
        delegate?.qrScanButtonTapped()
    }
    
    @objc func enterButtonTapped() {
        delegate?.enterAddressButtonTapped()
    }
    
    public func setupSendLabel(_ y: CGFloat) {
        let viewHeight = self.frame.size.height
        let bottom = viewHeight / 2.0 - btnHeight / 2.0
        
        let sendLabel = UILabel(frame: CGRect(x: 0.0, y: y, width: self.frame.size.width, height: bottom - y))
        sendLabel.text = NSLocalizedString("Send", comment: "")
        sendLabel.textAlignment = .center
        sendLabel.textColor = .lightGray
        sendLabel.font = UIFont.systemFont(ofSize: 30.0)
        sendLabel.backgroundColor = .clear
        self.addSubview(sendLabel)
        
    }
}
