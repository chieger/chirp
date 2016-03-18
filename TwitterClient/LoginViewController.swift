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
        
        // Do any additional setup after loading the view.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // This is wher it all begins
    @IBAction func didPressLoginButton(sender: AnyObject) {
        
        // Access the singleton, sharedInstance which is of type TwitterClient which is a subclass BDOAuth1Manager
        // Pass in a closure which gives commands for navigating to the Tweets view controller. Note, we won't call this closure until we are truly ready to login
        // The reason we give this instruction here, even through it will be called elsewhere is because it makes the most sence logically to give the navigation instructions for login in the didPressLoginMethod. This keeps the specific navigation out of the login method so the login method is not tied to any specific navigation.
        // TwitterClient.sharedInstance is a reference to the singleton instance of TwitterClient that we have stored in the TwitterClient class.
        // .login references the login method available to all instances of TwitterClient
        // We also send some instructions for printing the errors when an error is passed into the input of the closure
        TwitterClient.sharedInstance.login({ () -> () in
            print("I've logged in")
            self.performSegueWithIdentifier("loginSegue", sender: nil)
            
            // Note, the last closure looks weird because it is using last parameter trailing closure syntax to look cute.
            }) { (error: NSError) -> () in
                print("Error: \(error.localizedDescription)")
                // Why are we passing this to the login method? Doen't it already do the error handling?
        }
        
        
        
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
