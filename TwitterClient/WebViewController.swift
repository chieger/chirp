//
//  WebViewController.swift
//  TwitterClient
//
//  Created by Charlie Hieger on 3/18/16.
//  Copyright © 2016 Charles Hieger. All rights reserved.
//

import UIKit

class WebViewController: UIViewController {
  
  @IBOutlet weak var webView: UIWebView!
  
  var url: NSURL?
  
  override func viewDidLoad() {
    super.viewDidLoad()
    navigationController?.navigationBar.setBackgroundImage(UIImage(), forBarPosition: .Any, barMetrics: .Default)
    navigationController?.navigationBar.translucent = false
    navigationController?.navigationBar.barTintColor = UIColor.whiteColor()
    if let url = url {
      let request = NSURLRequest(URL: url)
      webView.loadRequest(request)
    }
  }
  
  @IBAction func didTapBackButton(sender: AnyObject) {
    dismissViewControllerAnimated(true, completion: nil)
  }
}
