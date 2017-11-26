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
    func broadcastTransaction(tx: Transaction)
}

class BIPayViewController: UIViewController {
    
    public var addressStr: String? = nil
    public var amountStr: String? = nil
    
    //public var doubleDismiss = false
    
    public var qrCodeReadViewController: BIQRCodeReadViewController? = nil
    
    @IBOutlet weak var addressTextField: UITextField!
    @IBOutlet weak var amountTextField: UITextField!
    
    private var txSentTimer: Timer? = nil
    
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
        self.view.endEditing(true)
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func send(_ sender: Any) {
        
        if addressTextField.text == "" || amountTextField.text == "" {
            self.displayAlert(title: NSLocalizedString("invalidInput", comment: ""), message: NSLocalizedString("empty", comment: ""))
            //print("Address or amount is empty.")
            return
        }
        
        guard let addressStr = addressTextField.text else {
            self.displayAlert(title: nil, message: NSLocalizedString("invalidInput", comment: ""))
            //print("Address is nil")
            return
        }
        
        guard let amountStr = amountTextField.text else {
            self.displayAlert(title: nil, message: NSLocalizedString("invalidInput", comment: ""))
            //print("Amount is nil")
            return
        }
        
        guard let type = addressStr.determinOutputScriptTypeWithAddress() else {
            self.displayAlert(title: nil, message: NSLocalizedString("noDetermine", comment: ""))
            //print("Could not determin address type")
            return
        }
        
        let privatePrefix = BitcoinPrefixes.privatePrefix
        let pubkeyPrefix = BitcoinPrefixes.pubKeyPrefix
        let minimumAmount: Int64 = 547
        
        var prefix = pubkeyPrefix
        
        if type == .P2SH {
            prefix = BitcoinPrefixes.scriptHashPrefix
        }
        
        if let pubkeyHash = addressStr.publicAddressToPubKeyHash(prefix) {
            
            if let amount = Double(amountStr) {
                
                let convertedInBtc = Int64(amount * 100000000)
                
                if convertedInBtc > minimumAmount {
                    let txConstructor = TransactionDBConstructor(privateKeyPrefix: privatePrefix, publicKeyPrefix: pubkeyPrefix, sendAmount: convertedInBtc, to: RIPEMD160HASH(pubkeyHash.hexStringToNSData().reversedData), type: type, fee: 90000)
                    
                    self.propagateTx(txConstructor: txConstructor)

                } else {
                    self.displayAlert(title: NSLocalizedString("invalidAmount", comment: ""), message: NSLocalizedString("belowMin", comment: "") + " \(minimumAmount) " + NSLocalizedString("belowMin_", comment: ""))

                    //print("Entered amount is insufficient. Miminum amount is \(minimumAmount) satoshi.")
                }
                
            } else {
                self.displayAlert(title: nil, message: NSLocalizedString("invalidInputAmount", comment: ""))
                //print("Failed to convert amount properly")
                return
            }
            
        } else {
            self.displayAlert(title: nil, message: NSLocalizedString("invalidAddress", comment: ""))
            //print("Invalid address")
            return
        }
        
    }
    
    private func dismissViewControllers() {
        
        self.view.endEditing(true)
        
        if qrCodeReadViewController != nil {
            let presentingViewController: UIViewController! = self.presentingViewController
            
            qrCodeReadViewController!.dismiss(animated: false, completion: {
                presentingViewController.dismiss(animated: true, completion: nil)
            })
            
        } else {
            self.dismiss(animated: true, completion: nil)
        }
    }
    
    private func propagateTx(txConstructor: TransactionDBConstructor) {
        if let tx = txConstructor.transaction {
            delegate?.broadcastTransaction(tx: tx)
            dismissViewControllers()
            
        } else {
            self.displayAlert(title: NSLocalizedString("Error", comment: ""), message: NSLocalizedString("txBuildFail", comment: ""))
        }
    }
    
    private func displayAlert(title: String?, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: {
            (result : UIAlertAction) -> Void in
            //Called, when AlertController is dismissed.
        }))
        self.present(alert, animated: true, completion: nil)
    }
    

}

