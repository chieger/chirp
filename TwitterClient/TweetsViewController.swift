//
//  TweetsViewController.swift
//  TwitterClient
//
//  Created by Charles Hieger on 2/23/16.
//  Copyright © 2016 Charles Hieger. All rights reserved.
//

import UIKit
import AFNetworking

class TweetsViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UIScrollViewDelegate {
    
    @IBOutlet var tableView: UITableView!
    
    var tweets: [Tweet] = []
    var olderTweetsParameters: NSDictionary!
    var newerTweetsParameters: NSDictionary!
    
    var refreshControl: UIRefreshControl!
    var dataLoading: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let twitterTitleLogo = UIImage(named: "Twitter_logo_blue_32")
        // navigationItem.titleView?.sizeToFit()
        navigationItem.titleView = UIImageView(image: twitterTitleLogo)
        
        refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: "refreshControlAction:", forControlEvents: UIControlEvents.ValueChanged)
        tableView.insertSubview(refreshControl, atIndex: 0)
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 120
        getHomeTimeline()
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func getHomeTimeline() {
        TwitterClient.sharedInstance.homeTimeline({ (tweets: [Tweet]) -> () in
            self.tweets = tweets
            let oldestTweet = tweets[tweets.count - 1]
            var maxId = oldestTweet.tweetId
            maxId! -= 1
            print(maxId)
            self.olderTweetsParameters = ["max_id": maxId!]
            let newestTweet = tweets[0]
            let sinceId = newestTweet.tweetId
            self.newerTweetsParameters = ["since_id": sinceId!]
            self.tableView.reloadData()
            self.refreshControl.endRefreshing()
            
            }) { (error: NSError) -> () in
                print(error.localizedDescription)
                self.refreshControl.endRefreshing()
        }
    }
    
    func getOldTimeline() {
        TwitterClient.sharedInstance.oldHomeTimeline(olderTweetsParameters, success: { (oldTweets: [Tweet]) -> () in
            let oldestTweet = oldTweets[oldTweets.count - 1]
            if var maxId = oldestTweet.tweetId {
                maxId -= 1
                print(maxId)
                self.olderTweetsParameters = ["max_id": maxId]
                self.tweets += oldTweets
                self.tableView.reloadData()
                print("Here are some classic tweets you may remember")
            }
            self.dataLoading = false
            }) { (error: NSError) -> () in
                print(error.localizedDescription)
        }
    }
    
    func getNewTimeline() {
        TwitterClient.sharedInstance.newTimeline(newerTweetsParameters, success: { (newTweets: [Tweet]) -> () in
            
            if newTweets.isEmpty {
                print("No new tweets I guess 😭")
                
            } else {
                
                let newestTweet = newTweets[0]
                let sinceId = newestTweet.tweetId
                print(sinceId)
                self.newerTweetsParameters = ["since_id": sinceId!]
                self.tweets = newTweets + self.tweets
                self.tableView.reloadData()
                print("ummm ummm...these fresh tweets is good!")
                
            }
            self.refreshControl.endRefreshing()
            }) { (error: NSError) -> () in
                self.refreshControl.endRefreshing()
        }
    }
    
    func refreshControlAction(refreshControl: UIRefreshControl) {
        print("lets get some new tweets fresh out the kitchen!")
        getNewTimeline()
    }
    
    @IBAction func didPressLogoutButton(sender: AnyObject) {
        TwitterClient.sharedInstance.logout()
    }
    
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        // return tweets?.count ?? 0
        return tweets.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("TweetCell", forIndexPath: indexPath) as! TweetCell
        
        cell.tweet = tweets[indexPath.row]
        
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }
    
    // Infinite scrolling
    func scrollViewDidScroll(scrollView: UIScrollView) {
        
        if !dataLoading {
            let scrollviewContentHeight = tableView.contentSize.height
            let scrollOffsetThreshold = scrollviewContentHeight - tableView.bounds.height
            if scrollView.contentOffset.y > scrollOffsetThreshold && tableView.dragging {
                dataLoading = true
                
                // load more results here
                print("Lets get some olddie but goodie tweets")
                getOldTimeline()
                
            }
        }
    }
    
    
    
    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
    // Get the new view controller using segue.destinationViewController.
        let cell = sender as! UITableViewCell
        let indexPath = tableView.indexPathForCell(cell)
        let tweet = tweets[indexPath!.row]
        
        let detailViewController = segue.destinationViewController as! DetailViewController
        
        detailViewController.tweet = tweet
        
    // Pass the selected object to the new view controller.
    }
    
    
}
