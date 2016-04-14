//
//  Tweet.swift
//  TwitterClient
//
//  Created by Charles Hieger on 2/23/16.
//  Copyright © 2016 Charles Hieger. All rights reserved.
//

import UIKit

class Tweet: NSObject {
  
  var tweetId: Int?
  var text: String?
  var username: String?
  var screenname: String?
  var timestamp: NSDate?
  var timeStampString: String?
  var retweetCount: Int = 0
  var favoritesCount: Int = 0
  var retweeted: Bool?
  var favorited: Bool?
  var profileImageUrl: NSURL!
  
  init(dictionary: NSDictionary) {
    
    tweetId = dictionary["id"] as? Int
    text = dictionary["text"] as? String
    username = dictionary.valueForKeyPath("user.name") as? String
    screenname = dictionary.valueForKeyPath("user.screen_name") as? String
    retweetCount = (dictionary["retweet_count"] as? Int) ?? 0
    favoritesCount = (dictionary["favorite_count"] as? Int) ?? 0
    retweeted = dictionary["retweeted"] as? Bool
    favorited = dictionary["favorited"] as? Bool
    if let profileImageUrlString = dictionary.valueForKeyPath("user.profile_image_url") as? String {
      profileImageUrl = NSURL(string: profileImageUrlString)
    }
    let timestampString = dictionary["created_at"] as? String
    // Date format: Tue Aug 28 21:16:23 +0000 2012
    if let timestampString = timestampString {
      let formatter = NSDateFormatter()
      formatter.dateFormat = "EEE MMM d HH:mm:ss Z y"
      timestamp = formatter.dateFromString(timestampString)
    }
  }
  
  static func tweetsWithArray(dictionaries: [NSDictionary]) -> [Tweet] {
    
    var tweets = [Tweet]()
    for dictionary in dictionaries {
      let tweet = Tweet(dictionary: dictionary)
      tweets.append(tweet)
    }
    return tweets
  }
}
