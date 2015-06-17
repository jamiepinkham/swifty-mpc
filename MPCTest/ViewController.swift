//
//  ViewController.swift
//  MPCTest
//
//  Created by Jamie Pinkham on 6/16/15.
//  Copyright (c) 2015 Ubersense. All rights reserved.
//

import UIKit
import MultipeerConnectivity


class ViewController: UIViewController, MCBrowserViewControllerDelegate {
    
    // Watch our here is there is *any* chance that the session might end up being nil
    let session = MCSession(peer: MCPeerID(displayName: NSUUID().UUIDString))

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func beginListening(sender: UIButton) {
        let browserViewController = MCBrowserViewController(serviceType: "mpc-demo", session: self.session)
        browserViewController.delegate = self
        browserViewController.maximumNumberOfPeers = 1
        self.presentViewController(browserViewController, animated: true) { () -> Void in
        }
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "showReceiver" {
            let destinationViewController = segue.destinationViewController as! ReceiverViewController
            destinationViewController.session = self.session
        }
    }
    
    func browserViewControllerDidFinish(browserViewController: MCBrowserViewController!) {
        self.dismissViewControllerAnimated(true, completion: { () -> Void in
            self.performSegueWithIdentifier("showReceiver", sender: nil)
        })
    }
    
    // Notifies delegate that the user taps the cancel button.
    func browserViewControllerWasCancelled(browserViewController: MCBrowserViewController!) {
        self.dismissViewControllerAnimated(true, completion: { () -> Void in
            
        })
    }
    
    
}

