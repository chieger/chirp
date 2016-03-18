//
//  DetailViewController.swift
//  TwitterClient
//
//  Created by Charlie Hieger on 3/16/16.
//  Copyright © 2016 Charles Hieger. All rights reserved.
//

import UIKit

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
    
    var tweetId: Int!
    var tweetIdDictionary: NSDictionary!
    var retweetCount: Int!
    var favoriteCount: Int!
    
    var tweet: Tweet!
            // update all the cell properties here...
        
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        screennameLabel.text = tweet.screenName
        usernameLabel.text = tweet.userName
        textLabel.text = tweet.text
        profileImageView.setImageWithURL(tweet.profileImageUrl)
        profileImageView.layer.cornerRadius = 4
        profileImageView.clipsToBounds = true
        tweetId = tweet.tweetId
        favoriteCount = tweet.favoritesCount
        retweetCount = tweet.retweetCount
        //let tweetDictionary = tweet.dic
        
        // Setup favorite button
        let favorited = tweet.favorited
        likeButton.selected = favorited! ? true : false
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
        updateCountLabel(likesCountLabel, count: favoriteCount)
        updateCountLabel(retweetCountLabel, count: retweetCount)
        


        // Do any additional setup after loading the view.
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
        sender.selected = !sender.selected
        
        if sender.selected {
            TwitterClient.sharedInstance.favorite(tweetIdDictionary, success: { (favoritedTweet: Tweet) -> () in
                
                }, failure: { (error: NSError) -> () in
                    print(error.localizedDescription)
            })
            favoriteCount!++
            updateCountLabel(likesCountLabel, count: favoriteCount)
            
            
            
        } else {
            TwitterClient.sharedInstance.unfavorite(tweetIdDictionary, success: { (favoritedTweet: Tweet) -> () in
                
                }, failure: { (error: NSError) -> () in
                    print(error.localizedDescription)
            })
            
            favoriteCount!--
            updateCountLabel(self.likesCountLabel, count: self.favoriteCount)
            
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
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
