//
//  DetailViewController.swift
//  TwitterClient
//
//  Created by Charlie Hieger on 3/16/16.
//  Copyright © 2016 Charles Hieger. All rights reserved.
//

import UIKit

protocol DetailViewControllerDelegate {
    func updateCellWithIndexPath(indexPath: NSIndexPath)
}

class DetailViewController: UIViewController {
    
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var screennameLabel: UILabel!
    @IBOutlet weak var textLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var retweetCountLabel: UILabel!
    @IBOutlet weak var likesCountLabel: UILabel!
    @IBOutlet weak var likeButton: UIButton!
    @IBOutlet weak var retweetButton: UIButton!
    
    var delegate: DetailViewControllerDelegate?
    var tweetId: Int!
    var tweetIdDictionary: NSDictionary!
    var changes: Bool = false
    var tweet: Tweet!
    
    var indexPath: NSIndexPath?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        screennameLabel.text = tweet.screenName
        usernameLabel.text = tweet.userName
        textLabel.text = tweet.text
        profileImageView.setImageWithURL(tweet.profileImageUrl)
        profileImageView.layer.cornerRadius = 4
        profileImageView.clipsToBounds = true
        tweetId = tweet.tweetId
        // timeStampLabel.text = tweet.timestamp
        tweetIdDictionary = ["id": tweetId]
        Tweet.updateButtonAndLabel(likeButton, label: likesCountLabel, selected: tweet.favorited, count: tweet.favoritesCount)
        Tweet.updateButtonAndLabel(retweetButton, label: retweetCountLabel, selected: tweet.retweeted, count: tweet.retweetCount)
        
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        if changes {
            if let indexPath = indexPath {
                delegate?.updateCellWithIndexPath(indexPath)
            }
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func updateCountLabel(label: UILabel, count: Int) {
        label.hidden = (count == 0) ? true : false
        label.text = String(count)
    }
    
    @IBAction func didPressFavoriteButton(sender: UIButton) {
        changes = true
        
        if !sender.selected {
            TwitterClient.sharedInstance.favorite(tweetIdDictionary, success: { (favoritedTweet: Tweet) -> () in
                
                }, failure: { (error: NSError) -> () in
                    print(error.localizedDescription)
            })
            tweet.favoritesCount += 1
            tweet.favorited = true
            Tweet.updateButtonAndLabel(likeButton, label: likesCountLabel, selected: tweet.favorited, count: tweet.favoritesCount)
            
        } else {
            TwitterClient.sharedInstance.unfavorite(tweetIdDictionary, success: { (favoritedTweet: Tweet) -> () in
                
                }, failure: { (error: NSError) -> () in
                    print(error.localizedDescription)
            })
            
            tweet.favoritesCount -= 1
            tweet.favorited = false
            Tweet.updateButtonAndLabel(likeButton, label: likesCountLabel, selected: tweet.favorited, count: tweet.favoritesCount)
        }
        print(changes)
    }
    
    @IBAction func didPressRetweetButton(sender: UIButton) {
        changes = true
        if !sender.selected {
            TwitterClient.sharedInstance.retweet(tweetId, success: { (retweet: Tweet) -> () in
                print("You retweeted \(retweet.userName)'s tweet. The retweet count is now \(retweet.retweetCount)")
                }, failure: { (error: NSError) -> () in
                    print(error.localizedDescription)
            })
            tweet.retweetCount += 1
            tweet.retweeted = true
            Tweet.updateButtonAndLabel(retweetButton, label: retweetCountLabel, selected: tweet.retweeted, count: tweet.retweetCount)
            
        } else {
            TwitterClient.sharedInstance.unretweet(tweetId, success: { (unretweet: Tweet) -> () in
                
                print("You un-retweeted \(unretweet.userName)'s tweet. The retweet count is now \(unretweet.retweetCount)")
                }, failure: { (error: NSError) -> () in
                    print(error.localizedDescription)
            })
            
            tweet.retweetCount -= 1
            tweet.retweeted = false
            Tweet.updateButtonAndLabel(retweetButton, label: retweetCountLabel, selected: tweet.retweeted, count: tweet.retweetCount)
        }
        print(changes)
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
