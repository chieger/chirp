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
    if let url = url {
      let request = NSURLRequest(URL: url)
      webView.loadRequest(request)
      setupNavigationBar()
    }
  }
  
  @IBAction func didTapBackButton(sender: AnyObject) {
    dismissViewControllerAnimated(true, completion: nil)
  }
  
  func setupNavigationBar() {
    navigationController?.navigationBar.setBackgroundImage(UIImage(), forBarPosition: .Any, barMetrics: .Default)
    navigationController?.navigationBar.translucent = false
    navigationController?.navigationBar.barTintColor = UIColor.whiteColor()
    navigationItem.rightBarButtonItem?.tintColor = UIColor.twitterBlueColor()
  }
}
