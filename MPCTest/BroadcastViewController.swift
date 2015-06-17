//
//  BroadcastViewController.swift
//  MPCTest
//
//  Created by Jamie Pinkham on 6/16/15.
//  Copyright (c) 2015 Ubersense. All rights reserved.
//

import UIKit
import AVFoundation

class BroadcastViewController: UIViewController, FrameProcessorDelegate {
    
    @IBOutlet var previewView: UIView?
    
    let captureSession = AVCaptureSession()
    let advertisingController = MultipeerController(displayName: NSUUID().UUIDString)
    let frameProcessor = FrameProcessor()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        var captureVideoPreviewLayer: AVCaptureVideoPreviewLayer = AVCaptureVideoPreviewLayer.layerWithSession(self.captureSession) as! AVCaptureVideoPreviewLayer
        captureVideoPreviewLayer.videoGravity = AVLayerVideoGravityResizeAspectFill
        captureVideoPreviewLayer.frame = self.view.frame
        self.previewView?.layer.addSublayer(captureVideoPreviewLayer)
        
        let videoDevice = AVCaptureDevice.defaultDeviceWithMediaType(AVMediaTypeVideo)
        if let videoDeviceInput = AVCaptureDeviceInput.deviceInputWithDevice(videoDevice, error: nil) as? AVCaptureDeviceInput {
            
            self.captureSession.addInput(videoDeviceInput)
            
            let videoDataCaptureOutput = AVCaptureVideoDataOutput()
            videoDataCaptureOutput.alwaysDiscardsLateVideoFrames = true
            
            let canAddOutput = self.captureSession.canAddOutput(videoDataCaptureOutput)
            
            if canAddOutput {
                videoDataCaptureOutput.setSampleBufferDelegate(self.frameProcessor, queue: self.frameProcessor.sampleQueue)
                frameProcessor.delegate = self
                self.captureSession.addOutput(videoDataCaptureOutput)
            }

        }

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        self.captureSession.startRunning()
        self.frameProcessor.beginProcessingFrames()
        self.advertisingController.beginAdvertising()
    }

    
    override func viewDidDisappear(animated: Bool) {
        super.viewDidDisappear(animated)
        self.captureSession.stopRunning();
        self.frameProcessor.endProcessingFrames()
        self.advertisingController.endAdvertising()
    }
    
    func processorDidProcessImage(_:FrameProcessor, image:UIImage?, timestamp: Float64) -> Void {
        if let theImage = image {
            self.advertisingController.distributeImage(theImage, timestamp: timestamp)
        }
    }
    

}
