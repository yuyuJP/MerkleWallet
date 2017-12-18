//
//  BIReceiveTopView.swift
//  SwiftBitcoin
//
//  Created by Yusuke Asai on 2017/07/01.
//  Copyright © 2017年 Yusuke Asai. All rights reserved.
//

import UIKit

public protocol BIReceiveTopViewDelegate {
    func addressLabelTapped()
}

class BIReceiveTopView: UIView {
    
    private let offsetY: CGFloat = 54.0
    
    public var delegate: BIReceiveTopViewDelegate? = nil
    
    override func draw(_ rect: CGRect) {
        
    }
    
    public func setupReceiveLabel(_ y: CGFloat) {
        let viewHeight = self.frame.size.height
        let bottom = viewHeight / 2.0 - offsetY / 2.0
        
        let sendLabel = UILabel(frame: CGRect(x: 0.0, y: y, width: self.frame.size.width, height: bottom - y))
        sendLabel.text = NSLocalizedString("Receive", comment: "")
        sendLabel.textAlignment = .center
        sendLabel.textColor = .lightGray
        sendLabel.font = UIFont.systemFont(ofSize: 30.0)
        sendLabel.backgroundColor = .clear
        self.addSubview(sendLabel)
        
    }
    
    public func setupAddresLabel(_ address: String) {
        let viewSize = self.frame.size
        let imageSize = self.frame.width / 1.5
        let yOffset: CGFloat = 25.0
        
        let yAxis: CGFloat = (viewSize.height - offsetY) / 2.0 - 10.0 + imageSize + yOffset
        
        let gap: CGFloat = 20
        
        let addressLabel = UILabel(frame: CGRect(x: gap / 2, y: yAxis, width: self.frame.size.width - 20, height: 25.0))
        addressLabel.text = address
        addressLabel.textAlignment = .center
        addressLabel.textColor = .gray
        addressLabel.font = UIFont.systemFont(ofSize: 18.0)
        addressLabel.backgroundColor = .clear
        addressLabel.adjustsFontSizeToFitWidth = true
        
        let gesture = UITapGestureRecognizer(target: self, action: #selector(self.addressLabelTapped(_:)))
        addressLabel.isUserInteractionEnabled = true
        addressLabel.addGestureRecognizer(gesture)
        
        self.addSubview(addressLabel)
    }
    
    public func setupAddressQRCode(_ address: String) {
        let imageSize = self.frame.width / 1.5
        
        if let qrCodeImage = BIQRCodeGenerator(code: address, imageSize: imageSize).qrCodeImage {
            let viewSize = self.frame.size
            let imageView = UIImageView(image: qrCodeImage)
            imageView.frame = CGRect(x: (viewSize.width - imageSize) / 2.0, y: (viewSize.height - offsetY) / 2.0 - 20.0, width: imageSize, height: imageSize)
            self.addSubview(imageView)
        }

    }
    
    @objc func addressLabelTapped(_ gestureRecognizer: UITapGestureRecognizer) {
        delegate?.addressLabelTapped()
    }
    
}
