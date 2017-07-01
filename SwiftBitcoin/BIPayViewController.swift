//
//  BIPayViewController.swift
//  SwiftBitcoin
//
//  Created by Yusuke Asai on 2017/07/01.
//  Copyright © 2017年 Yusuke Asai. All rights reserved.
//

import UIKit

public protocol BIPayViewControllerDelegate {
    func paymentCanceled()
}

class BIPayViewController: UIViewController {
    
    public var addressStr: String? = nil
    public var amountStr: String? = nil
    
    //public var doubleDismiss = false
    
    public var qrCodeReadViewController: BIQRCodeReadViewController? = nil
    
    @IBOutlet weak var addressTextField: UITextField!
    @IBOutlet weak var amountTextField: UITextField!
    
    public var delegate: BIPayViewControllerDelegate? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        amountTextField.adjustsFontSizeToFitWidth = true
        
        addressTextField.text = addressStr
        amountTextField.text = amountStr
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    @IBAction func cancelButtonTapped(_ sender: Any) {
        delegate?.paymentCanceled()
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func send(_ sender: Any) {
        //Do send action here!!
        
        if qrCodeReadViewController != nil {
            let presentingViewController: UIViewController! = self.presentingViewController
            
            qrCodeReadViewController!.dismiss(animated: false, completion: {
                presentingViewController.dismiss(animated: true, completion: nil)
            })
            
        } else {
            self.dismiss(animated: true, completion: nil)
        }
    }
    
}

