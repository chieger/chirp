//
//  User.swift
//  TwitterClient
//
//  Created by Charles Hieger on 2/23/16.
//  Copyright © 2016 Charles Hieger. All rights reserved.
//

import UIKit

class User: NSObject {
  
  static let userDidLogoutNotification = "UserDidLogOut"
  
  var username: String?
  var screenname: String?
  var tagline: String?
  var location: String?
  var followersCount: Int?
  var followingCount: Int?
  var profileImageUrl: NSURL?
  var profileBackgroundImageUrl: NSURL?
  var dictionary: NSDictionary?
  
  init(dictionary: NSDictionary) {
    self.dictionary = dictionary
    username = dictionary["name"] as? String
    screenname = dictionary["screen_name"] as? String
    tagline = dictionary["description"] as? String
    location = dictionary["location"] as? String
    followersCount = dictionary["followers_count"] as? Int
    followingCount = dictionary["following"] as? Int
    if let profileImageUrlString = dictionary["profile_image_url"] as? String {
      profileImageUrl = NSURL(string: profileImageUrlString)
    }
    if let profileBackgroundImageUrlString = dictionary["profile_background_image_url"] as? String {
      profileBackgroundImageUrl = NSURL(string: profileBackgroundImageUrlString)
    }
  }
  
  static var _currentUser: User?
  class var currentUser: User? {
    
    get {
      if _currentUser == nil {
        let defaults = NSUserDefaults.standardUserDefaults()
        let userData = defaults.objectForKey("currentUserData") as? NSData
        if let userData = userData {
          let dictionary = try! NSJSONSerialization.JSONObjectWithData(userData, options: []) as! NSDictionary
          _currentUser = User(dictionary: dictionary)
        }
      }
      return _currentUser
    }
    
    set(user) {
      _currentUser = user
      let defaults = NSUserDefaults.standardUserDefaults()
      if let user = user {
        let data = try! NSJSONSerialization.dataWithJSONObject(user.dictionary!, options: [])
        defaults.setObject(data, forKey: "currentUserData")
      } else {
        defaults.setObject(nil, forKey: "currentUserData")
      }
      defaults.synchronize()
    }
  }
}
