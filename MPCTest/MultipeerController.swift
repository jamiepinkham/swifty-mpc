//
//  MultipeerController.swift
//  MPCTest
//
//  Created by Jamie Pinkham on 6/17/15.
//  Copyright (c) 2015 Ubersense. All rights reserved.
//

import UIKit
import MultipeerConnectivity

class MultipeerController: NSObject, MCSessionDelegate, MCNearbyServiceAdvertiserDelegate {
    
    var session: MCSession
    var nearbyAdvertiser: MCNearbyServiceAdvertiser
    
    init(displayName: String)
    {
        let peerID = MCPeerID(displayName: displayName);
        session = MCSession(peer: peerID, securityIdentity: nil, encryptionPreference: .None)
        nearbyAdvertiser = MCNearbyServiceAdvertiser(peer: peerID, discoveryInfo: nil, serviceType: "mpc-demo")
        super.init()
        nearbyAdvertiser.delegate = self
    }
    
    func beginAdvertising()
    {
        self.nearbyAdvertiser.startAdvertisingPeer()
    }
    
    func endAdvertising()
    {
        self.nearbyAdvertiser.stopAdvertisingPeer()
    }
    
    func distributeImage(image: UIImage, timestamp: Float64)
    {
        let imageData = UIImageJPEGRepresentation(image, 0.4)
        let packet = [ "image" : imageData, "timestamp" : timestamp ]
        
        let packetData = NSKeyedArchiver.archivedDataWithRootObject(packet)
        
        self.session.sendData(packetData, toPeers: self.session.connectedPeers, withMode: .Unreliable, error: nil)
    }
    
    func advertiser(advertiser: MCNearbyServiceAdvertiser!, didReceiveInvitationFromPeer peerID: MCPeerID!, withContext context: NSData!, invitationHandler: ((Bool, MCSession!) -> Void)!)
    {
        if((invitationHandler) != nil)
        {
            invitationHandler(true, self.session)
        }
    }
    
    func session(session: MCSession!, peer peerID: MCPeerID!, didChangeState state: MCSessionState) {
        switch (state)
        {
        case .Connected:
            NSLog("peer connected = %@", peerID.displayName)
            break
        case .NotConnected:
            NSLog("peer not connected = %@", peerID.displayName)
            break
        case .Connecting:
            NSLog("peer connected = %@", peerID.displayName)
            break
        }
    }
    
    
    // Received data from remote peer
    func session(session: MCSession!, didReceiveData data: NSData!, fromPeer peerID: MCPeerID!)
    {
        
    }
    
    // Received a byte stream from remote peer
    func session(session: MCSession!, didReceiveStream stream: NSInputStream!, withName streamName: String!, fromPeer peerID: MCPeerID!)
    {
        
    }
    
    // Start receiving a resource from remote peer
    func session(session: MCSession!, didStartReceivingResourceWithName resourceName: String!, fromPeer peerID: MCPeerID!, withProgress progress: NSProgress!)
    {
        
    }
    
    // Finished receiving a resource from remote peer and saved the content in a temporary location - the app is responsible for moving the file to a permanent location within its sandbox
    func session(session: MCSession!, didFinishReceivingResourceWithName resourceName: String!, fromPeer peerID: MCPeerID!, atURL localURL: NSURL!, withError error: NSError!)
    {
        
    }
   
}
