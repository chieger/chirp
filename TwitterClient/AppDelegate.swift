//
//  AppDelegate.swift
//  TwitterClient
//
//  Created by Charles Hieger on 2/23/16.
//  Copyright © 2016 Charles Hieger. All rights reserved.
//

import UIKit
import BDBOAuth1Manager

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
  
  var window: UIWindow?
  
  
  func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
    // Override point for customization after application launch.
    if User.currentUser != nil {
      print("There is a current user")
      let storyboard = UIStoryboard(name: "Main", bundle: nil)
      let vc = storyboard.instantiateViewControllerWithIdentifier("MainTabBarController") as! UITabBarController
      window?.rootViewController = vc
    }
    
    NSNotificationCenter.defaultCenter().addObserverForName(User.userDidLogoutNotification, object: nil, queue: NSOperationQueue.mainQueue()) { (NSNotification) -> Void in
      let storyboard = UIStoryboard(name: "Main", bundle: nil)
      let vc = storyboard.instantiateInitialViewController()
      self.window?.rootViewController = vc
    }
    return true
  }
  
  func applicationWillResignActive(application: UIApplication) {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
  }
  
  func applicationDidEnterBackground(application: UIApplication) {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
  }
  
  func applicationWillEnterForeground(application: UIApplication) {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
  }
  
  func applicationDidBecomeActive(application: UIApplication) {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
  }
  
  func applicationWillTerminate(application: UIApplication) {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
  }
  
  func application(app: UIApplication, openURL url: NSURL, options: [String : AnyObject]) -> Bool {
    // This function is called anytime are app is opened by means of a url. In this case we created a url scheme that will open our app when that url is opened. We then supplied that url to twitter as a callback url and they will use that to call us back and open our app.
    print("my app just got opened using the callback that we supplied in the login method.")
    print("Notice that the authorized request token was passed back as a query parameter in the url, where the base url was the callback used to open our app")
    print(url.description)
    print("We can access just the query parameter part of the url by calling .query on the url")
    print(url.query)
    print("next we will pass the url over to a custom method which can parse the url to get an access token. It is convention to call this method, handleOpenUrl")
    TwitterClient.sharedTwitterClient().handleOpenUrl(url)
    
    return true
  }
}



