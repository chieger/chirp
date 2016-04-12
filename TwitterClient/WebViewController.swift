//
//  WebViewController.swift
//  TwitterClient
//
//  Created by Charlie Hieger on 3/18/16.
//  Copyright © 2016 Charles Hieger. All rights reserved.
//

import UIKit
import TTTAttributedLabel

class WebViewController: UIViewController, TTTAttributedLabelDelegate  {

    @IBOutlet weak var webView: UIWebView!
    
    var url: NSURL?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let url = url {
        let request = NSURLRequest(URL: url)
        webView.loadRequest(request)
        }
    }
    
    @IBAction func didTapBackButton(sender: AnyObject) {
        dismissViewControllerAnimated(true, completion: nil)
    }
}
