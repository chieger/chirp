//
//  DetailViewController.swift
//  TwitterClient
//
//  Created by Charlie Hieger on 3/16/16.
//  Copyright © 2016 Charles Hieger. All rights reserved.
//

import UIKit

protocol DetailViewControllerDelegate {
  func updateCellWithIndexPathAnimated(indexPath: NSIndexPath, animation: UITableViewRowAnimation)
}

class DetailViewController: UIViewController {
  
  @IBOutlet weak var profileImageView: UIImageView!
  @IBOutlet weak var usernameLabel: UILabel!
  @IBOutlet weak var screennameLabel: UILabel!
  @IBOutlet weak var textLabel: UILabel!
  @IBOutlet weak var dateLabel: UILabel!
  @IBOutlet weak var retweetCountLabel: UILabel!
  @IBOutlet weak var favoriteCountLabel: UILabel!
  @IBOutlet weak var favoriteButton: UIButton!
  @IBOutlet weak var retweetButton: UIButton!
  
  var delegate: DetailViewControllerDelegate?
  var changes: Bool = false
  var tweet: Tweet!
  var indexPath: NSIndexPath?
  
  override func viewDidLoad() {
    super.viewDidLoad()
    screennameLabel.text = tweet.screenname
    usernameLabel.text = tweet.username
    textLabel.text = tweet.text
    profileImageView.setImageWithURL(tweet.profileImageUrl)
    styleProfileImage()
    updateLabelsAndButtons()
  }
  
  override func viewWillDisappear(animated: Bool) {
    super.viewWillDisappear(animated)
    if changes {
      if let indexPath = indexPath {
        delegate?.updateCellWithIndexPathAnimated(indexPath, animation: .Bottom)
      }
    }
  }
  
  @IBAction func didPressFavoriteButton(sender: UIButton) {
    changes = true
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
    changes = true
    if !sender.selected {
      TwitterClient.sharedTwitterClient().retweet(tweet.tweetId, success: { (retweet: Tweet) -> () in
        }, failure: { (error: NSError) -> () in
          print(error.localizedDescription)
      })
      tweet.retweetCount += 1
      tweet.retweeted = true
      updateLabelsAndButtons()
    } else {
      TwitterClient.sharedTwitterClient().unretweet(tweet.tweetId, success: { (unretweet: Tweet) -> () in
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
  
  func styleProfileImage() {
    profileImageView.layer.cornerRadius = 4
    profileImageView.clipsToBounds = true
  }
}
