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
    
    private static let sharedInstance = TwitterClient(baseURL: NSURL(string: "https://api.twitter.com")!, consumerKey: "uFTmFW66AAMEUwx3rZlZDMSCf", consumerSecret: "LtlxIoQpBvHcqjpSMIA9Gs2E9wCJbr7xkx9EpSdBYoNedaZUgh")
    
    static func sharedTwitterClient() -> TwitterClient {
        return sharedInstance
    }
    
    var loginSuccess: (() -> ())?
    var loginFailure: ((NSError) -> ())?
    
    func login(success: () -> (), failure: (NSError) -> ()) {
        loginSuccess = success
        loginFailure = failure
        TwitterClient.sharedTwitterClient().deauthorize()
        TwitterClient.sharedTwitterClient().fetchRequestTokenWithPath("oauth/request_token", method: "POST", callbackURL: NSURL(string: "twitterClient://oauth"), scope: nil, success: { (requestToken: BDBOAuth1Credential!) -> Void in
            let url = NSURL(string: "https://api.twitter.com/oauth/authenticate?oauth_token=\(requestToken.token)")!
            print("We have the initial request token and we're adding it as a query parameter to the authenticate end point url and sending it off to get authorization.")
            print(url.description)
            print("if the user agrees to authorize, we will get an authorized request token which we can cash in later for an access token!")
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
    
    func homeTimeline(success: ([Tweet]) -> (), failure: (NSError) -> ()) {
        GET("1.1/statuses/home_timeline.json", parameters: nil, progress: nil, success: { (task: NSURLSessionDataTask, response: AnyObject?) -> Void in
            let dictionaries = response as! [NSDictionary]
            let lastTweetDictionary = dictionaries[dictionaries.count - 1]
            let tweets = Tweet.tweetsWithArray(dictionaries)
            success(tweets)
            }, failure: { (task: NSURLSessionDataTask?, error: NSError) -> Void in
                failure(error)
        })
    }
    
    func oldHomeTimeline(parameters: NSDictionary, success: ([Tweet]) -> (), failure: (NSError) -> ()) {
        GET("1.1/statuses/home_timeline.json", parameters: parameters, progress: nil, success: { (task: NSURLSessionDataTask, response: AnyObject?) -> Void in
            let dictionaries = response as! [NSDictionary]
            let oldTweets = Tweet.tweetsWithArray(dictionaries)
            success(oldTweets)
        }) { (task: NSURLSessionDataTask?, error: NSError) -> Void in
            failure(error)
        }
    }
    
    func newTimeline(parameters: NSDictionary, success: ([Tweet]) -> (), failure: (NSError) -> ()) {
        GET("1.1/statuses/home_timeline.json", parameters: parameters, progress: nil, success: { (task: NSURLSessionDataTask, response: AnyObject?) -> Void in
            let dictionaries = response as! [NSDictionary]
            let newTweets = Tweet.tweetsWithArray(dictionaries)
            success(newTweets)
        }) { (task: NSURLSessionDataTask?, error: NSError) -> Void in
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
    
    func retweet(tweetId: Int, success: (Tweet) -> (), failure: (NSError) -> ()) {
        POST("1.1/statuses/retweet/\(tweetId).json", parameters: nil, progress: nil, success: { (task: NSURLSessionDataTask, response: AnyObject?) -> Void in
            let dictionary = response as! NSDictionary
            // print(response?.valueForKeyPath("user.name") as! String)
            // print(dictionary)
            let retweet = Tweet(dictionary: dictionary)
            success(retweet)
        }) { (task: NSURLSessionDataTask?, error: NSError) -> Void in
            failure(error)
        }
    }
    
    func unretweet (tweetId: Int, success: (Tweet) -> (), failure: (NSError) -> ()) {
        POST("1.1/statuses/unretweet/\(tweetId).json", parameters: nil, progress: nil, success: { (task: NSURLSessionDataTask, response: AnyObject?) -> Void in
            let dictionary = response as! NSDictionary
            let unretweet = Tweet(dictionary: dictionary)
            success(unretweet)
        }) { (task: NSURLSessionDataTask?, error: NSError) -> Void in
            failure(error)
        }
    }
    
    func favorite(tweetId: NSDictionary, success: (Tweet) -> (), failure: (NSError) -> ()) {
        POST("1.1/favorites/create.json", parameters: tweetId, progress: nil, success: { (task: NSURLSessionDataTask, response: AnyObject?) -> Void in
            //print(response)
            //print("favorited")
            let dictionary = response as! NSDictionary
            let favoritedTweet = Tweet(dictionary: dictionary)
            success(favoritedTweet)
        }) { (task: NSURLSessionDataTask?, error: NSError) -> Void in
            failure(error)
        }
    }
    
    func unfavorite(tweetId: NSDictionary, success: (Tweet) -> (), failure: (NSError) -> ()) {
        POST("1.1/favorites/destroy.json", parameters: tweetId, progress: nil, success: { (task: NSURLSessionDataTask, response: AnyObject?) -> Void in
            //print(response)
            //print("un-favorited")
            let dictionary = response as! NSDictionary
            let unfavoritedTweet = Tweet(dictionary: dictionary)
            success(unfavoritedTweet)
        }) { (task: NSURLSessionDataTask?, error: NSError) -> Void in
            print(error.localizedDescription)
        }
    }
    
    func composeTweet(parameters: NSDictionary, success: (Tweet) -> (), failure: (NSError) -> ()) {
        POST("https://api.twitter.com/1.1/statuses/update.json", parameters: parameters, success: { (task: NSURLSessionDataTask, response: AnyObject?) in
            let dictionary = response as! NSDictionary
            let newTweet = Tweet(dictionary: dictionary)
            success(newTweet)
        }) { (task: NSURLSessionDataTask?, error: NSError) in
            failure(error)
        }
    }
}
