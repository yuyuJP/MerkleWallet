//
//  BIWifDisplayViewController.swift
//  SwiftBitcoin
//
//  Created by Yusuke Asai on 2017/09/15.
//  Copyright © 2017年 Yusuke Asai. All rights reserved.
//


import UIKit

class BIWifDisplayViewController: UIViewController {

    
    public var WIF: String? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let wif = WIF {
            setupWifLabel(wif)
            setupWifQRCode(wif)
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    func setupWifQRCode(_ wif: String) {
        let imageSize = self.view.frame.width / 1.5
        
        if let qrCodeImage = BIQRCodeGenerator(code: wif, imageSize: imageSize).qrCodeImage {
            let viewSize = self.view.frame.size
            let imageView = UIImageView(image: qrCodeImage)
            imageView.frame = CGRect(x: (viewSize.width - imageSize) / 2.0, y: (viewSize.height - imageSize) / 2.0, width: imageSize, height: imageSize)
            self.view.addSubview(imageView)
        }
        
    }

    
    public func setupWifLabel(_ wif: String) {
        let viewSize = self.view.frame.size
        let imageSize = self.view.frame.width / 1.5
        
        let yAxis: CGFloat = (viewSize.height) / 2.0  + imageSize / 1.5
        
        let blank: CGFloat = 50.0
        
        let wifLabel = UILabel(frame: CGRect(x: blank / 2, y: yAxis, width: self.view.frame.size.width - blank, height: 25.0))
        wifLabel.text = wif
        wifLabel.textAlignment = .center
        wifLabel.textColor = .gray
        wifLabel.backgroundColor = .clear
        wifLabel.adjustsFontSizeToFitWidth = true
        wifLabel.minimumScaleFactor = 0.2
        wifLabel.numberOfLines = 1
        
        self.view.addSubview(wifLabel)
    }
    
    @IBAction func dismissView(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
}
