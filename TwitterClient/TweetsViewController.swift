//
//  TweetsViewController.swift
//  TwitterClient
//
//  Created by Charles Hieger on 2/23/16.
//  Copyright © 2016 Charles Hieger. All rights reserved.
//

import UIKit
import AFNetworking

class TweetsViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UIScrollViewDelegate, TweetCellDelegate, DetailViewControllerDelegate, ComposeViewControllerDelegate {
    
    
    @IBOutlet var tableView: UITableView!
    
    var tweets: [Tweet] = []
    var olderTweetsParameters: NSDictionary!
    var newerTweetsParameters: NSDictionary!
    var blueColorTwitter: UIColor = UIColor(red: 64/255, green: 153/255, blue: 255/255, alpha: 1.0)
    var refreshControl: UIRefreshControl!
    var dataLoading: Bool = false
    
    var url: NSURL?
    var currentFavoritesCount: Int?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let twitterTitleLogo = UIImage(named: "Twitter_logo_blue_32")
        // navigationItem.titleView?.sizeToFit()
        navigationItem.titleView = UIImageView(image: twitterTitleLogo)
        navigationItem.leftBarButtonItem?.tintColor = blueColorTwitter
        navigationItem.rightBarButtonItem?.tintColor = blueColorTwitter
        
        refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(TweetsViewController.refreshControlAction(_:)), forControlEvents: UIControlEvents.ValueChanged)
        tableView.insertSubview(refreshControl, atIndex: 0)
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 120
        getHomeTimeline()
        
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        //        tableView.reloadData()
        //        print("Your view did appear and we reloaded that data!")
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func getHomeTimeline() {
        TwitterClient.sharedTwitterClient().homeTimeline({ (tweets: [Tweet]) -> () in
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
        TwitterClient.sharedTwitterClient().oldHomeTimeline(olderTweetsParameters, success: { (oldTweets: [Tweet]) -> () in
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
        TwitterClient.sharedTwitterClient().newTimeline(newerTweetsParameters, success: { (newTweets: [Tweet]) -> () in
            
            if newTweets.isEmpty {
                print("No new tweets I guess 😭")
                
            } else {
                
                let newestTweet = newTweets[0]
                let sinceId = newestTweet.tweetId
                print(sinceId)
                self.newerTweetsParameters = ["since_id": sinceId!]
                self.tweets = newTweets + self.tweets
                
                // Reload table view data with animation
                let range = NSMakeRange(0, self.tableView.numberOfSections)
                let sections = NSIndexSet(indexesInRange: range)
                self.tableView.reloadSections(sections, withRowAnimation: .Automatic)
                
                // self.tableView.reloadData()
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
        TwitterClient.sharedTwitterClient().logout()
    }
    
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tweets.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("TweetCell", forIndexPath: indexPath) as! TweetCell
        
        cell.delegate = self
        cell.tweet = tweets[indexPath.row]
        
        return cell
    }
    
    func updateCellWithIndexPath(indexPath: NSIndexPath) {
        //let cell = tableView.cellForRowAtIndexPath(indexPath) as! TweetCell
        //let tweet = tweets[indexPath.row]
        //cell.tweet = tweet
        
        
        let indexPathArray: [NSIndexPath] = [indexPath]
        tableView.reloadRowsAtIndexPaths(indexPathArray, withRowAnimation: .Top)
        print("cell \(indexPath.row) was updated")
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
    
    func didTapUrlLink(url: NSURL) {
        print("didTapUrl Method has been called")
        self.url = url
        performSegueWithIdentifier("WebViewSegue", sender: nil)
        
    }
    
    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        
        if segue.identifier == "WebViewSegue" {
            let webViewController = segue.destinationViewController as! WebViewController
            webViewController.url = self.url
        } else if segue.identifier == "DetailSegue" {
            let cell = sender as! UITableViewCell
            let indexPath = tableView.indexPathForCell(cell)
            let tweet = tweets[indexPath!.row]
            if let currentFavoritesCount = currentFavoritesCount {
                tweet.favoritesCount = currentFavoritesCount
            }
            let detailViewController = segue.destinationViewController as! DetailViewController
            detailViewController.delegate = self
            detailViewController.indexPath = indexPath
            detailViewController.tweet = tweet
        } else if segue.identifier == "ComposeSegue" {
            let composeViewController = segue.destinationViewController as! ComposeViewController
            composeViewController.delegate = self
            
        }
        // Pass the selected object to the new view controller.
    }
    
    
}
