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
    
    static let sharedInstance = TwitterClient(baseURL: NSURL(string: "https://api.twitter.com")!, consumerKey: "uFTmFW66AAMEUwx3rZlZDMSCf", consumerSecret: "LtlxIoQpBvHcqjpSMIA9Gs2E9wCJbr7xkx9EpSdBYoNedaZUgh")
    
    var loginSuccess: (() -> ())?
    var loginFailure: ((NSError) -> ())?
    
  
    
    func login(success: () -> (), failure: (NSError) -> ()) {
        
        // We will store our closures that have instructions for what to do in the cases of login success or failure. Remember, we set the contents of these closures when we called the login method. The contents of success cointain login navigation instructions and the failure contains instructions to print any errors we encounter along the way
        // The reason we store them into instance variables that we created is because we want to beable to access the login success closure (in order to initiate the login navigation) elsewhere when we are finally done with all the OAuth stuff. Similarly, there are lots of chances for errors or failures along the way, so we want to easily be able to print the errors to console each time without having to re-write the printing instructions each time, but this is really for conveinience more than necesity.
        loginSuccess = success
        loginFailure = failure
        
        // This deauthorize method just clears out any previous access tokens that could be laying around for whatever reason
        TwitterClient.sharedInstance.deauthorize()
        // The endpoints of the twitter API where you will need to go are in your app on the details page https://apps.twitter.com/app/12004121/show
        // The steps for OAuth1 are:
        // 1) Get initial Request Token: oauth/request_token NOTE: You only need the last part of the url after the base url: api.twitter.com/
        // 2) Get request token Authorized: oauth/authorize
        // 3) Get the access token: oauth/access_token  NOTE: we will do this in a subsequent method
        // The fetchRequestTokenWithPath method gets the initial request token to present to Twitter and then if successful, the success closue is called. This is where we will assemble the url with the newly fetched request token. we will use that url to get the access token later.
        // The first parameter, access path is just the endpoint from the Twitter API that we need to go to to get the request_token.
        //
        TwitterClient.sharedInstance.fetchRequestTokenWithPath("oauth/request_token", method: "POST", callbackURL: NSURL(string: "twitterClient://oauth"), scope: nil, success: { (requestToken: BDBOAuth1Credential!) -> Void in
            let url = NSURL(string: "https://api.twitter.com/oauth/authenticate?oauth_token=\(requestToken.token)")!
            print("We have the initial request token and we're adding it as a query parameter to the authenticate end point url and sending it off to get authorization.")
            print(url.description)
            print("if the user agrees to authorize, we will get an authorized request token which we can cash in later for an access token!")
            UIApplication.sharedApplication().openURL(url)
            // Why do we 
            
            }) { (error: NSError!) -> Void in
                
                // What is going on here?
                // Does this just capture the code snippet, print("error \(error.localizedDescription)") for later use?
                // Did we instantiate the closure at this point?
                self.loginFailure?(error)
                
        }
    }
    
    func logout() {
        User.currentUser = nil
        deauthorize()
        
        NSNotificationCenter.defaultCenter().postNotificationName(User.userDidLogoutNotification, object: nil)
    }
    
    func handleOpenUrl(url: NSURL) {
        // We will create an authorized version of a request token using the query parameters from the url Twitter sent us when it called us back and cash that in for an access token
        let requestToken = BDBOAuth1Credential(queryString: url.query)
        fetchAccessTokenWithPath("/oauth/access_token", method: "POST", requestToken: requestToken, success: { (acessToken: BDBOAuth1Credential!) -> Void in
            print("I got the access token")
            
            
            self.currentAccount({ (user: User) -> () in
               //Thi method will go get the signed in users credentials from the
                User.currentUser = user
                // Finally we are done with the OAuth biz and can call the login closure to navigate us to the signe in view controller
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
            
            // create and instantiate a new user using the dictionary obtained from from the verify credentials end point
            let user = User(dictionary: responseDictionary)
            // pass the user we just created as a parameter in the success closure
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
