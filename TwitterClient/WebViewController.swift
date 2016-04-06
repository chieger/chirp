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
        
        //tttLabel.
        
        if let url = url {
            print("the url was passed is \(url)")
        let request = NSURLRequest(URL: url)
        webView.loadRequest(request)
        } else {
            print("no url 😬")
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func didTapBackButton(sender: AnyObject) {
        dismissViewControllerAnimated(true, completion: nil)
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
