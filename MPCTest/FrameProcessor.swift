//
//  FrameProcessor.swift
//  MPCTest
//
//  Created by Jamie Pinkham on 6/17/15.
//  Copyright (c) 2015 Ubersense. All rights reserved.
//

import UIKit
import AVFoundation

protocol FrameProcessorDelegate {
    func processorDidProcessImage(_:FrameProcessor, image:UIImage?, timestamp: Float64) -> Void
}

class FrameProcessor: NSObject, AVCaptureVideoDataOutputSampleBufferDelegate {
    var delegate: FrameProcessorDelegate?
    
    let sampleQueue = dispatch_queue_create("sampleQueue", DISPATCH_QUEUE_SERIAL);
    
    private var shouldProcessFrames: Bool = false
    
    override init() {
        super.init()
    }
    
    func beginProcessingFrames() {
        self.shouldProcessFrames = true
    }
    
    func endProcessingFrames() {
        self.shouldProcessFrames = false
    }
    
    func captureOutput(captureOutput: AVCaptureOutput!, didOutputSampleBuffer sampleBuffer: CMSampleBuffer!, fromConnection connection: AVCaptureConnection!) {
        if self.shouldProcessFrames {
            let timestamp = CMTimeGetSeconds(CMSampleBufferGetPresentationTimeStamp(sampleBuffer))
            
            let cvImage = CMSampleBufferGetImageBuffer(sampleBuffer)
            
            let sizeRatio = CGSize(width: 320, height: 320)
            let imageRect = CGRect(x: 0, y: 0, width: CVPixelBufferGetWidth(cvImage), height: CVPixelBufferGetHeight(cvImage))
            let cropRect = AVMakeRectWithAspectRatioInsideRect(sizeRatio, imageRect)
            let ciImage = CIImage(CVPixelBuffer: cvImage)
            
            let croppedImage = ciImage.imageByCroppingToRect(cropRect)
            
            let scaleFilter = CIFilter(name: "CILanczosScaleTransform")
            scaleFilter.setValue(croppedImage, forKey: "inputImage")
            scaleFilter.setValue(0.25, forKey: "inputScale")
            scaleFilter.setValue(1.0, forKey: "inputAspectRatio")
            
            let finalImage = scaleFilter.valueForKey("outputImage") as! CIImage
            
            let ciContext = CIContext(options: nil)
            let imageRef = ciContext.createCGImage(ciImage, fromRect: ciImage.extent())
            let uiImage = UIImage(CGImage: imageRef, scale: UIScreen.mainScreen().scale, orientation: .Left)
            
            self.delegate?.processorDidProcessImage(self, image: uiImage, timestamp: timestamp)
        }
        
    }
}
