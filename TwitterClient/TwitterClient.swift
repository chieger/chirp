//
//  TwitterClient.swift
//  TwitterClient
//
//  Created by Charles Hieger on 2/23/16.
//  Copyright © 2016 Charles Hieger. All rights reserved.
//

import UIKit
import BDBOAuth1Manager

class TwitterClient: BDBOAuth1SessionManager {
  
  private static let _sharedTwitterClient = TwitterClient(baseURL: NSURL(string: "https://api.twitter.com")!, consumerKey: "uFTmFW66AAMEUwx3rZlZDMSCf", consumerSecret: "LtlxIoQpBvHcqjpSMIA9Gs2E9wCJbr7xkx9EpSdBYoNedaZUgh")
  
  static func sharedTwitterClient() -> TwitterClient {
    return _sharedTwitterClient
  }
  
  var loginSuccess: (() -> ())?
  var loginFailure: ((NSError) -> ())?
  
  func login(success: () -> (), failure: (NSError) -> ()) {
    loginSuccess = success
    loginFailure = failure
    deauthorize()
    fetchRequestTokenWithPath("oauth/request_token", method: "POST", callbackURL: NSURL(string: "twitterClient://oauth"), scope: nil, success: { (requestToken: BDBOAuth1Credential!) -> Void in
      let url = NSURL(string: "https://api.twitter.com/oauth/authenticate?oauth_token=\(requestToken.token)")!
      UIApplication.sharedApplication().openURL(url)
    }) { (error: NSError!) -> Void in
      self.loginFailure?(error)
    }
  }
  
  func logout() {
    User.currentUser = nil
    deauthorize()
    
    NSNotificationCenter.defaultCenter().postNotificationName(User.userDidLogoutNotification, object: nil)
  }
  
  func handleOpenUrl(url: NSURL) {
    let requestToken = BDBOAuth1Credential(queryString: url.query)
    fetchAccessTokenWithPath("/oauth/access_token", method: "POST", requestToken: requestToken, success: { (acessToken: BDBOAuth1Credential!) -> Void in
      self.currentAccount({ (user: User) -> () in
        User.currentUser = user
        self.loginSuccess?()
        }, failure: { (error: NSError) -> () in
          self.loginFailure?(error)
      })
      }, failure: { (error: NSError!) -> Void in
        self.loginFailure?(error)
    })
  }
  
  func getHomeTimeline(success: ([Tweet]) -> (), failure: (NSError) -> ()) {
    getHomeTimeline(nil, sinceTweet: nil, success: success, failure: failure)
  }
  
  func getHomeTimeline(maxTweet: Tweet?, sinceTweet: Tweet?, success: ([Tweet]) -> (), failure: (NSError) -> ()) {
    var parameters = [String: Int]()
    parameters["max_id"] = maxTweet?.tweetId
    parameters["since_id"] = sinceTweet?.tweetId
    getHomeTimeLine(parameters, success: success, failure: failure)
  }
  
  func getHomeTimeLine(parameters: [String: Int]?, success: ([Tweet]) -> (), failure: (NSError) -> ()) {
    GET("1.1/statuses/home_timeline.json", parameters: parameters, progress: nil, success: { (task: NSURLSessionDataTask, response: AnyObject?) -> Void in
      let responseDictionaries = response as! [NSDictionary]
      let tweets = Tweet.tweetsWithArray(responseDictionaries)
      success(tweets)
      }, failure: { (task: NSURLSessionDataTask?, error: NSError) -> Void in
        failure(error)
    })
  }
  
  func getUserTimeline(success: ([Tweet]) -> (), failure: (NSError) -> ()) {
    GET("https://api.twitter.com/1.1/statuses/user_timeline.json", parameters: nil, progress: nil, success: { (task: NSURLSessionDataTask, response: AnyObject?) in
      let responseDictionaries = response as! [NSDictionary]
      let tweets = Tweet.tweetsWithArray(responseDictionaries)
      success(tweets)
    }) { (task: NSURLSessionDataTask?, error: NSError) in
        failure(error)
    }
  }
  
  func currentAccount(success: (User) -> (), failure: (NSError) -> ()) {
    GET("1.1/account/verify_credentials.json", parameters: nil, progress: nil, success: { (task: NSURLSessionDataTask, response: AnyObject?) -> Void in
      let responseDictionary = response as! NSDictionary
      let user = User(dictionary: responseDictionary)
      success(user)
    }) { (task: NSURLSessionDataTask?, error: NSError) -> Void in
      failure(error)
    }
  }
  
  func retweet(tweetId: Int?, success: (Tweet) -> (), failure: (NSError) -> ()) {
    POST("1.1/statuses/retweet/\(tweetId).json", parameters: nil, progress: nil, success: { (task: NSURLSessionDataTask, response: AnyObject?) -> Void in
      let dictionary = response as! NSDictionary
      let retweet = Tweet(dictionary: dictionary)
      success(retweet)
    }) { (task: NSURLSessionDataTask?, error: NSError) -> Void in
      failure(error)
    }
  }
  
  func unretweet (tweetId: Int?, success: (Tweet) -> (), failure: (NSError) -> ()) {
    POST("1.1/statuses/unretweet/\(tweetId).json", parameters: nil, progress: nil, success: { (task: NSURLSessionDataTask, response: AnyObject?) -> Void in
      let dictionary = response as! NSDictionary
      let unretweet = Tweet(dictionary: dictionary)
      success(unretweet)
    }) { (task: NSURLSessionDataTask?, error: NSError) -> Void in
      failure(error)
    }
  }
  
  func favorite(tweetId: Int?, success: (Tweet) -> (), failure: (NSError) -> ()) {
    var parameters = [String: Int]()
    parameters["id"] = tweetId
    POST("1.1/favorites/create.json", parameters: parameters, progress: nil, success: { (task: NSURLSessionDataTask, response: AnyObject?) -> Void in
      let responseDictionary = response as! NSDictionary
      let favoritedTweet = Tweet(dictionary: responseDictionary)
      success(favoritedTweet)
    }) { (task: NSURLSessionDataTask?, error: NSError) -> Void in
      failure(error)
    }
  }
  
  func unfavorite(tweetId: Int?, success: (Tweet) -> (), failure: (NSError) -> ()) {
    var parameters = [String: Int]()
    parameters["id"] = tweetId
    POST("1.1/favorites/destroy.json", parameters: parameters, progress: nil, success: { (task: NSURLSessionDataTask, response: AnyObject?) -> Void in
      let responseDictionary = response as! NSDictionary
      let unfavoritedTweet = Tweet(dictionary: responseDictionary)
      success(unfavoritedTweet)
    }) { (task: NSURLSessionDataTask?, error: NSError) -> Void in
      print(error.localizedDescription)
    }
  }
  
  func composeTweet(parameters: NSDictionary, success: (Tweet) -> (), failure: (NSError) -> ()) {
    POST("https://api.twitter.com/1.1/statuses/update.json", parameters: parameters, progress: nil, success: { (task: NSURLSessionDataTask, response: AnyObject?) in
      if let responseDictionary = response as? NSDictionary {
        let newTweet = Tweet(dictionary: responseDictionary)
        success(newTweet)
      }
    }) { (task: NSURLSessionDataTask?, error: NSError) in
      failure(error)
    }
  }
}

enum FavoriteOptions: String {
  case Create = "create"
  case Destroy = "destroy"
}
