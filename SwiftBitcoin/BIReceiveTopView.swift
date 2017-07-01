//
//  BIReceiveTopView.swift
//  SwiftBitcoin
//
//  Created by Yusuke Asai on 2017/07/01.
//  Copyright © 2017年 Yusuke Asai. All rights reserved.
//

import UIKit

class BIReceiveTopView: UIView {
    
    public var myAddress: String = "mrAsyQH7fpShVb7MRKxAddXMbPatX8Ldjr"
    
    private let offsetY: CGFloat = 54.0
    
    //private var imageSize: CGFloat = 0
    
    override func draw(_ rect: CGRect) {
        
        let imageSize = self.frame.width / 1.5
        
        if let qrCodeImage = BIQRCodeGenerator(code: myAddress, imageSize: imageSize).qrCodeImage {
            let viewSize = self.frame.size
            let imageView = UIImageView(image: qrCodeImage)
            imageView.frame = CGRect(x: (viewSize.width - imageSize) / 2.0, y: (viewSize.height - offsetY) / 2.0 - 10.0, width: imageSize, height: imageSize)
            self.addSubview(imageView)
        }
        
    }
    
    public func setupReceiveLabel(_ y: CGFloat) {
        let viewHeight = self.frame.size.height
        let bottom = viewHeight / 2.0 - offsetY / 2.0
        
        let sendLabel = UILabel(frame: CGRect(x: 0.0, y: y, width: self.frame.size.width, height: bottom - y))
        sendLabel.text = "Receive:"
        sendLabel.textAlignment = .center
        sendLabel.textColor = .lightGray
        sendLabel.font = UIFont.systemFont(ofSize: 30.0)
        sendLabel.backgroundColor = .clear
        self.addSubview(sendLabel)
        
    }
    
    public func setupAddresLabel() {
        let viewSize = self.frame.size
        let imageSize = self.frame.width / 1.5
        let yOffset: CGFloat = 25.0
        
        let yAxis: CGFloat = (viewSize.height - offsetY) / 2.0 - 10.0 + imageSize + yOffset
        
        let addressLabel = UILabel(frame: CGRect(x: 0.0, y: yAxis, width: self.frame.size.width, height: 18.0))
        addressLabel.text = "my3TE7S7ou4UxYLj5HXcLVsiTt32th4qeN"
        addressLabel.textAlignment = .center
        addressLabel.textColor = .gray
        addressLabel.font = UIFont.systemFont(ofSize: 18.0)
        addressLabel.backgroundColor = .clear
        self.addSubview(addressLabel)
    }
    
}
