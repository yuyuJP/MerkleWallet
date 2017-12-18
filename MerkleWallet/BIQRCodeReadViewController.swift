//
//  BIQRCodeReadViewController.swift
//  SwiftBitcoin
//
//  Created by Yusuke Asai on 2017/07/01.
//  Copyright © 2017年 Yusuke Asai. All rights reserved.
//

import UIKit
import AVFoundation

public protocol BIQRCodeReadViewControllerDelegate {
    func propagateTransaction(tx: Transaction)
}

class BIQRCodeReadViewController: UIViewController, AVCaptureMetadataOutputObjectsDelegate, BIPayViewControllerDelegate {
    
    private let videoCaptureDevice: AVCaptureDevice = AVCaptureDevice.default(for: AVMediaType.video)!
    private let output = AVCaptureMetadataOutput()
    
    private var previewLayer: AVCaptureVideoPreviewLayer?
    private var captureSession: AVCaptureSession? = AVCaptureSession()
    
    @IBOutlet weak var cameraView: UIView!
    
    private var previousCode = ""
    
    private var isCameraLoaded = false
    
    private var addressStr: String? = nil
    private var amountStr: String? = nil
    
    public var delegate: BIQRCodeReadViewControllerDelegate? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if AVCaptureDevice.authorizationStatus(for: AVMediaType.video) == AVAuthorizationStatus.notDetermined {
            AVCaptureDevice.requestAccess(for: AVMediaType.video, completionHandler: { (videoGranted: Bool) -> Void in
                
                if (videoGranted) {
                    DispatchQueue.main.async {
                        self.setupCamera()
                    }
                } else {
                    print("Camera Use Denied.")
                }
            })
        }
    }
    
    private func setupCamera() {
        
        let input: AVCaptureInput
        
        do {
            input = try AVCaptureDeviceInput(device: videoCaptureDevice)
        } catch {
            
            return
        }
        
        let status = AVCaptureDevice.authorizationStatus(for: AVMediaType.video)
        
        if status == .authorized {
            
            if self.captureSession!.canAddInput(input) {
                self.captureSession!.addInput(input)
            }
            self.previewLayer = AVCaptureVideoPreviewLayer(session: captureSession!)
            
            if let videoPreviewLayer = self.previewLayer {
                videoPreviewLayer.videoGravity = AVLayerVideoGravity.resizeAspectFill
                videoPreviewLayer.frame = self.cameraView.bounds
                
                self.cameraView.layer.addSublayer(videoPreviewLayer)
            }
            
            let metaDataOutput = AVCaptureMetadataOutput()
            
            if self.captureSession!.canAddOutput(metaDataOutput) {
                self.captureSession!.addOutput(metaDataOutput)
                
                metaDataOutput.setMetadataObjectsDelegate(self, queue: .main)
                metaDataOutput.metadataObjectTypes = [.qr]
                
            } else {
                print("Could not add metadata output")
            }
            
        } else {
            print("Camera Use Unauthorized. Show alert here.")
        }
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        if let session = captureSession {
            
            if session.isRunning == true {
                session.stopRunning()
                captureSession = nil
                
                previewLayer?.removeFromSuperlayer()
                previewLayer = nil
            }
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        if !isCameraLoaded {
            isCameraLoaded = true
            setupCamera()
            if let session = captureSession {
                if session.isRunning == false {
                    session.startRunning()
                }
            }
        }
    }
    
    //MARK:- AVCaptureMetadataOutputObjectsDelegate
    func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
        
        for metaData in metadataObjects {
            let readableObject = metaData as! AVMetadataMachineReadableCodeObject
            let code = readableObject.stringValue
            
            if let code = code {
                if previousCode == code {
                    return
                }
                previousCode = code
                
                let qrCodeParser = BIQRCodeParser(string: code)
                if qrCodeParser.isValid {
                    //print("QR Code read : address: \(qrCodeParser.address!), amount: \(qrCodeParser.amount ?? "nil"), label: \(qrCodeParser.label ?? "nil"), message: \(qrCodeParser.message ?? "nil")")
                    addressStr = qrCodeParser.address
                    amountStr = qrCodeParser.amount
                    
                    self.performSegue(withIdentifier: "qrCodeParsed", sender: nil)
                    
                } else {
                    //print(qrCodeParser.amount)
                    print("Read QR Code is invalid")
                }
            }
        }
    }
    
    @IBAction func dismissView(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    

    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "qrCodeParsed" {
            let payViewController = segue.destination as! BIPayViewController
            payViewController.delegate = self
            payViewController.addressStr = addressStr
            payViewController.amountStr = amountStr
            payViewController.qrCodeReadViewController = self
        }
    }
    
    //MARK:- BIPayViewControllerDelegate
    func paymentCanceled() {
        previousCode = ""
    }
    
    func broadcastTransaction(tx: Transaction) {
        //broadcast tx
        delegate?.propagateTransaction(tx: tx)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}

