//
//  AVCaptureMultipeerVideoDataOutput.swift
//  MPCTest
//
//  Created by Jamie Pinkham on 6/16/15.
//  Copyright (c) 2015 Ubersense. All rights reserved.
//

import UIKit
import AVFoundation
import MultipeerConnectivity
import CoreMedia

class AVCaptureMultipeerVideoDataOutput: AVCaptureVideoDataOutput, AVCaptureVideoDataOutputSampleBufferDelegate, MCAdvertiserAssistantDelegate, MCSessionDelegate,MCNearbyServiceAdvertiserDelegate {
    
    var session: MCSession
    var nearbyAdvertiser: MCNearbyServiceAdvertiser
    
    let sampleQueue = dispatch_queue_create("sampleQueue", DISPATCH_QUEUE_SERIAL);
    
    init(displayName: String) {
        let peerID = MCPeerID(displayName: displayName);
        session = MCSession(peer: peerID, securityIdentity: nil, encryptionPreference: .None)
        nearbyAdvertiser = MCNearbyServiceAdvertiser(peer: peerID, discoveryInfo: nil, serviceType: "mpc-demo")
        nearbyAdvertiser.startAdvertisingPeer()
        super.init()
        self.setSampleBufferDelegate(self, queue: self.sampleQueue)
        self.alwaysDiscardsLateVideoFrames = true
    }
    
    func cgBackedImageWithCIImage(#ciImage:CIImage) -> UIImage? {
        let ciContect = CIContext(options: nil)
        let imageRef = ciContect.createCGImage(ciImage, fromRect: ciImage.extent())
        let uiImage = UIImage(CGImage: imageRef, scale: UIScreen.mainScreen().scale, orientation: .Left)
        return uiImage;
    }
    
    func captureOutput(captureOutput: AVCaptureOutput!, didDropSampleBuffer sampleBuffer: CMSampleBuffer!, fromConnection connection: AVCaptureConnection!) {
        if self.session.connectedPeers.count > 0 {
            let timestamp: Float64 = CMTimeGetSeconds(CMSampleBufferGetPresentationTimeStamp(sampleBuffer))
            
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
            
            let uiImage = self.cgBackedImageWithCIImage(ciImage: finalImage)
            
            let imageData: NSData = UIImageJPEGRepresentation(uiImage, 0.2)
            
            let inputPort = connection.inputPorts[0] as! AVCaptureInputPort
            let deviceInput = inputPort.input as! AVCaptureDeviceInput
            
            let frameDuration: CMTime = deviceInput.device.activeVideoMaxFrameDuration
            let timescale: Int32 = frameDuration.timescale
            
            let packet = [ "image" : imageData, "timestamp" : timestamp ]
            
            let packetData = NSKeyedArchiver.archivedDataWithRootObject(packet)
            
            self.session.sendData(packetData, toPeers: self.session.connectedPeers, withMode: .Unreliable, error: nil)
        }
    }
    
    func advertiser(advertiser: MCNearbyServiceAdvertiser!, didReceiveInvitationFromPeer peerID: MCPeerID!, withContext context: NSData!, invitationHandler: ((Bool, MCSession!) -> Void)!) {
        if invitationHandler != nil {
            invitationHandler(true, self.session)
        }
    }
    
    func session(session: MCSession!, peer peerID: MCPeerID!, didChangeState state: MCSessionState) {
        switch (state)
        {
        case .Connected:
                NSLog("peer connected = %@", peerID.displayName)
        case .NotConnected:
                NSLog("peer not connected = %@", peerID.displayName)
        case .Connecting:
                NSLog("peer connected = %@", peerID.displayName)
        }
    }
    
    
    // Received data from remote peer
    func session(session: MCSession!, didReceiveData data: NSData!, fromPeer peerID: MCPeerID!) {
        
    }
    
    // Received a byte stream from remote peer
    func session(session: MCSession!, didReceiveStream stream: NSInputStream!, withName streamName: String!, fromPeer peerID: MCPeerID!) {
        
    }
    
    // Start receiving a resource from remote peer
    func session(session: MCSession!, didStartReceivingResourceWithName resourceName: String!, fromPeer peerID: MCPeerID!, withProgress progress: NSProgress!) {
        
    }
    
    // Finished receiving a resource from remote peer and saved the content in a temporary location - the app is responsible for moving the file to a permanent location within its sandbox
    func session(session: MCSession!, didFinishReceivingResourceWithName resourceName: String!, fromPeer peerID: MCPeerID!, atURL localURL: NSURL!, withError error: NSError!) {

    }
    
}
