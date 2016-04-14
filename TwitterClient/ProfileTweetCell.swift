//
//  TweetCell.swift
//  TwitterClient
//
//  Created by Charles Hieger on 3/1/16.
//  Copyright © 2016 Charles Hieger. All rights reserved.
//

import UIKit
import TTTAttributedLabel

//protocol TweetCellDelegate {
//  var url: NSURL? {get set}
//  func didTapUrlLink (url: NSURL)
//}

class ProfileTweetCell: UITableViewCell {
  
  @IBOutlet weak var favoriteButton: UIButton!
  @IBOutlet weak var retweetButton: UIButton!
  @IBOutlet weak var screenNameLabel: UILabel!
  @IBOutlet weak var usernameLabel: UILabel!
  @IBOutlet weak var tweetAtTextLabel: TTTAttributedLabel!
  @IBOutlet weak var profileImageView: UIImageView!
  @IBOutlet weak var retweetCountLabel: UILabel!
  @IBOutlet weak var favoriteCountLabel: UILabel!
  
  //var delegate: TweetCellDelegate?
  
  var tweet: Tweet! {
    didSet {
      tweetAtTextLabel.delegate = self
      tweetAtTextLabel.enabledTextCheckingTypes = NSTextCheckingType.Link.rawValue
      tweetAtTextLabel.activeLinkAttributes = [kCTForegroundColorAttributeName: UIColor.greenColor()]
      tweetAtTextLabel.linkAttributes = [kCTForegroundColorAttributeName: UIColor.twitterBlueColor(), NSUnderlineColorAttributeName: UIColor.twitterBlueColor() , NSUnderlineStyleAttributeName: NSNumber(bool: false)]
      
      screenNameLabel.text = User.currentUser?.username
      usernameLabel.text = User.currentUser?.username
      tweetAtTextLabel.setText(tweet.text)
      if let profileImageUrl = tweet.profileImageUrl {
        profileImageView.setImageWithURL(profileImageUrl)
      }
      styleProfileImageView()
      updateLabelsAndButtons()
    }
  }
  
  @IBAction func didPressLikeButton(sender: UIButton) {
    if !sender.selected {
      TwitterClient.sharedTwitterClient().favorite(tweet.tweetId, success: { (favoritedTweet: Tweet) -> () in
        
        }, failure: { (error: NSError) -> () in
          print(error.localizedDescription)
      })
      tweet.favoritesCount += 1
      tweet.favorited = true
      updateLabelsAndButtons()
    } else {
      TwitterClient.sharedTwitterClient().unfavorite(tweet.tweetId, success: { (favoritedTweet: Tweet) -> () in
        
        }, failure: { (error: NSError) -> () in
          print(error.localizedDescription)
      })
      tweet.favoritesCount -= 1
      tweet.favorited = false
      updateLabelsAndButtons()
    }
  }
  
  @IBAction func didPressRetweetButton(sender: UIButton) {
    if !sender.selected {
      TwitterClient.sharedTwitterClient().retweet(tweet.tweetId, success: { (retweet: Tweet) -> () in
        print("Nice Retweet Breh!")
        }, failure: { (error: NSError) -> () in
          print(error.localizedDescription)
      })
      tweet.retweetCount += 1
      tweet.retweeted = true
      updateLabelsAndButtons()
    } else {
      TwitterClient.sharedTwitterClient().unretweet(tweet.tweetId, success: { (unretweet: Tweet) -> () in
        
        print("Unretweet that jam!")
        }, failure: { (error: NSError) -> () in
          print(error.localizedDescription)
      })
      tweet.retweetCount -= 1
      tweet.retweeted = false
      updateLabelsAndButtons()
    }
  }
  
  func updateLabelsAndButtons() {
    updateCountLabel(favoriteCountLabel, count: tweet.favoritesCount)
    updateCountLabel(retweetCountLabel, count: tweet.retweetCount)
    updateButton(favoriteButton, selected: tweet.favorited)
    updateButton(retweetButton, selected: tweet.retweeted)
  }
  
  func updateCountLabel(label: UILabel, count: Int?) {
    label.hidden = (count == 0)
    if let count = count {
      label.text = String(count)
    }
  }
  
  func updateButton(button: UIButton, selected: Bool?) {
    if let selected = selected {
      button.selected = selected
    }
  }
  
  func styleProfileImageView() {
    profileImageView.layer.cornerRadius = 4
    profileImageView.clipsToBounds = true
  }
}

extension ProfileTweetCell: TTTAttributedLabelDelegate {
  func attributedLabel(label: TTTAttributedLabel!, didSelectLinkWithURL url: NSURL!) {
    //delegate?.didTapUrlLink(url)
  }
}
