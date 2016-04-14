//
//  TweetsViewController.swift
//  TwitterClient
//
//  Created by Charles Hieger on 2/23/16.
//  Copyright © 2016 Charles Hieger. All rights reserved.
//

import UIKit
import AFNetworking

class TweetsViewController: UIViewController {
  
  @IBOutlet var tableView: UITableView!
  
  var tweets: [Tweet] = []
  var refreshControl: UIRefreshControl!
  var dataLoading: Bool = false
  var url: NSURL?
  
  var newlyCreatedTweet: Tweet? {
    didSet {
      tweets = [newlyCreatedTweet!] + tweets
      tableView.reloadData()
    }
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    setupNavigationBar()
    setupRefreshControl()
    tableView.delegate = self
    tableView.dataSource = self
    tableView.rowHeight = UITableViewAutomaticDimension
    tableView.estimatedRowHeight = 120
    getHomeTimeline()
  }
  
  func getHomeTimeline() {
    TwitterClient.sharedTwitterClient().getHomeTimeline({ (tweets: [Tweet]) in
      self.tweets = tweets
      self.tableView.reloadData()
      self.refreshControl.endRefreshing()
    }) { (error: NSError) in
      print(error.localizedDescription)
      self.refreshControl.endRefreshing()
    }
  }
  
  func refreshControlAction(refreshControl: UIRefreshControl) {
    getHomeTimeline()
  }
  
  @IBAction func didPressLogoutButton(sender: AnyObject) {
    TwitterClient.sharedTwitterClient().logout()
  }
  
  override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
    if segue.identifier == "WebViewSegue" {
      let webNavigationController = segue.destinationViewController as! UINavigationController
      let webViewController = webNavigationController.topViewController as! WebViewController
      webViewController.url = self.url
    } else if segue.identifier == "DetailSegue" {
      let cell = sender as! UITableViewCell
      let indexPath = tableView.indexPathForCell(cell)
      let tweet = tweets[indexPath!.row]
      let detailViewController = segue.destinationViewController as! DetailViewController
      detailViewController.delegate = self
      detailViewController.indexPath = indexPath
      detailViewController.tweet = tweet
    } else if segue.identifier == "ComposeSegue" {
      let composeNavigationController = segue.destinationViewController as! UINavigationController
      let composeViewController = composeNavigationController.topViewController as! ComposeViewController
      composeViewController.delegate = self
    }
  }
  
  func setupNavigationBar() {
    navigationController?.navigationBar.translucent = false
    navigationController?.navigationBar.barTintColor = UIColor.whiteColor()
    let twitterTitleLogo = UIImage(named: "Twitter_logo_blue_32")
    navigationItem.titleView = UIImageView(image: twitterTitleLogo)
    navigationItem.leftBarButtonItem?.tintColor = UIColor.twitterBlueColor()
    navigationItem.rightBarButtonItem?.tintColor = UIColor.twitterBlueColor()
  }
  
  func setupRefreshControl() {
    refreshControl = UIRefreshControl()
    refreshControl.addTarget(self, action: #selector(TweetsViewController.refreshControlAction(_:)), forControlEvents: UIControlEvents.ValueChanged)
    tableView.insertSubview(refreshControl, atIndex: 0)
  }
  
  func reloadTableViewWithAnimation(animation: UITableViewRowAnimation) {
    let range = NSMakeRange(0, tableView.numberOfSections)
    let sections = NSIndexSet(indexesInRange: range)
    tableView.reloadSections(sections, withRowAnimation: animation)
  }
}

extension TweetsViewController: UITableViewDataSource {
  func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return tweets.count
  }
  
  func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCellWithIdentifier("TweetCell", forIndexPath: indexPath) as! TweetCell
    cell.delegate = self
    cell.tweet = tweets[indexPath.row]
    return cell
  }
}

extension TweetsViewController: UITableViewDelegate {
  func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
    tableView.deselectRowAtIndexPath(indexPath, animated: true)
  }
}

extension TweetsViewController: UIScrollViewDelegate {
  // Infinite scrolling
  func scrollViewDidScroll(scrollView: UIScrollView) {
    if !dataLoading {
      let scrollviewContentHeight = tableView.contentSize.height
      let scrollOffsetThreshold = scrollviewContentHeight - tableView.bounds.height
      if scrollView.contentOffset.y > scrollOffsetThreshold && tableView.dragging {
        dataLoading = true
        
        TwitterClient.sharedTwitterClient().getHomeTimeline(tweets.last,
                                                            sinceTweet: nil,
                                                            success: { (tweets:[Tweet]) in
                                                              self.tweets += tweets
                                                              self.tableView.reloadData()
                                                              self.dataLoading = false
          }, failure: { (error: NSError) in
            print(error.localizedDescription)
        })
      }
    }
  }
}

extension TweetsViewController: TweetCellDelegate {
  func didTapUrlLink(url: NSURL) {
    self.url = url
    performSegueWithIdentifier("WebViewSegue", sender: nil)
  }
}

extension TweetsViewController: DetailViewControllerDelegate {
  func updateCellWithIndexPathAnimated(indexPath: NSIndexPath, animation: UITableViewRowAnimation) {
    let indexPathArray: [NSIndexPath] = [indexPath]
    tableView.reloadRowsAtIndexPaths(indexPathArray, withRowAnimation: animation)
  }
}

extension TweetsViewController: ComposeViewControllerDelegate {
}
