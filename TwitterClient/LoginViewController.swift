//
//  LoginViewController.swift
//  TwitterClient
//
//  Created by Charles Hieger on 2/23/16.
//  Copyright © 2016 Charles Hieger. All rights reserved.
//

import UIKit
import BDBOAuth1Manager

class LoginViewController: UIViewController {
  
  override func viewDidLoad() {
    super.viewDidLoad()
  }
  
  @IBAction func didPressLoginButton(sender: AnyObject) {
    TwitterClient.sharedTwitterClient().login({ () -> () in
      print("I've logged in")
      self.performSegueWithIdentifier("loginSegue", sender: nil)
    }) { (error: NSError) -> () in
      print("Error: \(error.localizedDescription)")
    }
  }
}
