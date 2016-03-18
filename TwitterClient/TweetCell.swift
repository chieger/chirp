//
//  TweetCell.swift
//  TwitterClient
//
//  Created by Charles Hieger on 3/1/16.
//  Copyright © 2016 Charles Hieger. All rights reserved.
//

import UIKit

class TweetCell: UITableViewCell {
    
    
    @IBOutlet weak var favoriteButton: UIButton!
    @IBOutlet weak var retweetButton: UIButton!
    
    
    @IBOutlet weak var screenNameLabel: UILabel!
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var tweetTextLabel: UILabel!
    @IBOutlet weak var profileImageView: UIImageView!
    
    @IBOutlet weak var retweetCountLabel: UILabel!
    
    @IBOutlet weak var favoriteCountLabel: UILabel!
    
    var tweetId: Int!
    var tweetIdDictionary: NSDictionary!
    var retweetCount: Int!
    var favoriteCount: Int!
    
    //@IBOutlet weak var timeStampLabel: UILabel!
    var tweet: Tweet! {
        didSet {
            // update all the cell properties here...
            
            screenNameLabel.text = tweet.screenName
            usernameLabel.text = tweet.userName
            tweetTextLabel.text = tweet.text
            profileImageView.setImageWithURL(tweet.profileImageUrl)
            profileImageView.layer.cornerRadius = 4
            profileImageView.clipsToBounds = true
            tweetId = tweet.tweetId
            favoriteCount = tweet.favoritesCount
            retweetCount = tweet.retweetCount
            //let tweetDictionary = tweet.dic
            
            // Setup favorite button
            let favorited = tweet.favorited
            favoriteButton.selected = favorited! ? true : false
            if favorited! && favoriteCount == 0 {
                favoriteCount = 1
            }
            
            let retweeted = tweet.retweeted
            retweetButton.selected = retweeted! ? true : false
            if retweeted! && retweetCount == 0 {
                retweetCount = 1
            }
            
            
            // timeStampLabel.text = tweet.timestamp
            tweetIdDictionary = ["id": tweetId]
            
            // Setup favorite label
            updateCountLabel(favoriteCountLabel, count: favoriteCount)
            updateCountLabel(retweetCountLabel, count: retweetCount)
            
        }
        
    }
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        
    }
    
    func updateCountLabel(label: UILabel, count: Int) {
        label.hidden = (count == 0) ? true : false
        label.text = String(count)
    }
    
    @IBAction func didPressLikeButton(sender: UIButton) {
        sender.selected = !sender.selected
        
        if sender.selected {
            TwitterClient.sharedInstance.favorite(tweetIdDictionary, success: { (favoritedTweet: Tweet) -> () in
                
                }, failure: { (error: NSError) -> () in
                    print(error.localizedDescription)
            })
            favoriteCount!++
            updateCountLabel(favoriteCountLabel, count: favoriteCount)
            
            
            
        } else {
            TwitterClient.sharedInstance.unfavorite(tweetIdDictionary, success: { (favoritedTweet: Tweet) -> () in
                
                }, failure: { (error: NSError) -> () in
                    print(error.localizedDescription)
            })
            
            favoriteCount!--
            updateCountLabel(self.favoriteCountLabel, count: self.favoriteCount)
            
        }
        
    }
    @IBAction func didPressRetweetButton(sender: UIButton) {
        sender.selected = !sender.selected
        
        if sender.selected {
            TwitterClient.sharedInstance.retweet(tweetId, success: { (retweet: Tweet) -> () in
                print("You retweeted \(retweet.userName)'s tweet. The retweet count is now \(retweet.retweetCount)")
                }, failure: { (error: NSError) -> () in
                    print(error.localizedDescription)
            })
            retweetCount!++
            updateCountLabel(retweetCountLabel, count: retweetCount)
        } else {
            TwitterClient.sharedInstance.unretweet(tweetId, success: { (unretweet: Tweet) -> () in
                
                print("You un-retweeted \(unretweet.userName)'s tweet. The retweet count is now \(unretweet.retweetCount)")
                }, failure: { (error: NSError) -> () in
                    print(error.localizedDescription)
            })
            retweetCount!--
            updateCountLabel(retweetCountLabel, count: retweetCount)
        }
        
        
    }
    
    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
}
