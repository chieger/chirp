//
//  TweetCell.swift
//  TwitterClient
//
//  Created by Charles Hieger on 3/1/16.
//  Copyright © 2016 Charles Hieger. All rights reserved.
//

import UIKit
import TTTAttributedLabel

protocol TweetCellDelegate {
    var url: NSURL? {get set}
    func didTapUrlLink (url: NSURL)
}

class TweetCell: UITableViewCell, UITextViewDelegate, TTTAttributedLabelDelegate {
    
    @IBOutlet weak var favoriteButton: UIButton!
    @IBOutlet weak var retweetButton: UIButton!
    @IBOutlet weak var screenNameLabel: UILabel!
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var tweetAtTextLabel: TTTAttributedLabel!
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var retweetCountLabel: UILabel!
    @IBOutlet weak var favoriteCountLabel: UILabel!
    
    var delegate: TweetCellDelegate?
    var tweetId: Int!
    var tweetIdDictionary: NSDictionary!
    var blueColorTwitter: UIColor = UIColor(red: 64/255, green: 153/255, blue: 255/255, alpha: 1.0)
    
    var tweet: Tweet! {
        didSet {
            tweetAtTextLabel.delegate = self
            tweetAtTextLabel.enabledTextCheckingTypes = NSTextCheckingType.Link.rawValue
            tweetAtTextLabel.activeLinkAttributes = [kCTForegroundColorAttributeName: UIColor.greenColor()]
            tweetAtTextLabel.linkAttributes = [kCTForegroundColorAttributeName: blueColorTwitter, NSUnderlineColorAttributeName: blueColorTwitter , NSUnderlineStyleAttributeName: NSNumber(bool: false)]
            
            screenNameLabel.text = tweet.screenName
            usernameLabel.text = tweet.userName
            tweetAtTextLabel.setText(tweet.text)
            profileImageView.setImageWithURL(tweet.profileImageUrl)
            profileImageView.layer.cornerRadius = 4
            profileImageView.clipsToBounds = true
            tweetId = tweet.tweetId
            tweetIdDictionary = ["id": tweetId]
            
            Tweet.updateButtonAndLabel(favoriteButton, label: favoriteCountLabel, selected: tweet.favorited, count: tweet.favoritesCount)
            Tweet.updateButtonAndLabel(retweetButton, label: retweetCountLabel, selected: tweet.retweeted, count: tweet.retweetCount)
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    @IBAction func didPressLikeButton(sender: UIButton) {
        if !sender.selected {
            TwitterClient.sharedTwitterClient().favorite(tweetIdDictionary, success: { (favoritedTweet: Tweet) -> () in
                
                }, failure: { (error: NSError) -> () in
                    print(error.localizedDescription)
            })
            tweet.favoritesCount += 1
            tweet.favorited = true
            Tweet.updateButtonAndLabel(favoriteButton, label: favoriteCountLabel, selected: tweet.favorited, count: tweet.favoritesCount)
        } else {
            TwitterClient.sharedTwitterClient().unfavorite(tweetIdDictionary, success: { (favoritedTweet: Tweet) -> () in
                
                }, failure: { (error: NSError) -> () in
                    print(error.localizedDescription)
            })
            tweet.favoritesCount -= 1
            tweet.favorited = false
            Tweet.updateButtonAndLabel(favoriteButton, label: favoriteCountLabel, selected: tweet.favorited, count: tweet.favoritesCount)
        }
    }
    
    @IBAction func didPressRetweetButton(sender: UIButton) {
        if !sender.selected {
            TwitterClient.sharedTwitterClient().retweet(tweetId, success: { (retweet: Tweet) -> () in
                print("Nice Retweet Breh!")
                }, failure: { (error: NSError) -> () in
                    print(error.localizedDescription)
            })
            tweet.retweetCount += 1
            tweet.retweeted = true
            Tweet.updateButtonAndLabel(retweetButton, label: retweetCountLabel, selected: tweet.retweeted, count: tweet.retweetCount)
        } else {
            TwitterClient.sharedTwitterClient().unretweet(tweetId, success: { (unretweet: Tweet) -> () in
                
                print("Unretweet that jam!")
                }, failure: { (error: NSError) -> () in
                    print(error.localizedDescription)
            })
            tweet.retweetCount -= 1
            tweet.retweeted = false
            Tweet.updateButtonAndLabel(retweetButton, label: retweetCountLabel, selected: tweet.retweeted, count: tweet.retweetCount)
        }
    }
    
    func attributedLabel(label: TTTAttributedLabel!, didSelectLinkWithURL url: NSURL!) {
        delegate?.didTapUrlLink(url)
    }
    
    func textView(textView: UITextView, shouldInteractWithURL URL: NSURL, inRange characterRange: NSRange) -> Bool {
        delegate?.didTapUrlLink(URL)
        return false
    }
}
