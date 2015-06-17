//
//  RecieverViewController.swift
//  MPCTest
//
//  Created by Jamie Pinkham on 6/16/15.
//  Copyright (c) 2015 Ubersense. All rights reserved.
//

import UIKit
import MultipeerConnectivity

class ReceiverViewController: UIViewController, MCSessionDelegate {

    var session: MCSession?
    @IBOutlet var imageView: UIImageView?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.session?.delegate = self
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        self.session?.delegate = nil
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    
    func session(session: MCSession!, peer peerID: MCPeerID!, didChangeState state: MCSessionState)
    {
        
    }
    
    // Received data from remote peer
    func session(session: MCSession!, didReceiveData data: NSData!, fromPeer peerID: MCPeerID!)
    {
        if let dictionary = NSKeyedUnarchiver.unarchiveObjectWithData(data) as? NSDictionary {
            if let pictureData = dictionary["image"] as? NSData, image = UIImage(data: pictureData)
            {
                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                    self.imageView?.image = image
                })
            }
        }
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
