//
//  DetailViewController.swift
//  Flicks
//
//  Created by phil_nachum on 8/1/16.
//  Copyright © 2016 phil_nachum. All rights reserved.
//

import UIKit
import YouTubePlayer

class DetailViewController: UIViewController {

    @IBOutlet weak var posterImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var overviewLabel: UILabel!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var infoView: UIView!
    @IBOutlet weak var videoView: YouTubePlayerView!

    var movie: NSDictionary!
    var trailerYoutubeId: String?

    var movieTrailerUrl: String {
        let id = movie["id"] as! Int
        return "http://api.themoviedb.org/3/movie/\(id)/videos?api_key=a07e22bc18f5cb106bfe4cc1f83ad8ed"
    }

    private func fetchTrailer() {
        fetchDataHelper(movieTrailerUrl,
            completionHandler: { (dataOrNil, response, error) in
                if let data = dataOrNil {
                    if let responseDictionary = try! NSJSONSerialization.JSONObjectWithData(
                        data, options:[]) as? NSDictionary {
                        let results = responseDictionary["results"] as! [NSDictionary]
                        if results.count > 0 {
                            let youtubeId = results[0]["key"] as? String
                            self.trailerYoutubeId = youtubeId
                            if let youtubeId = youtubeId {
                                self.videoView.loadVideoID(youtubeId)
                            } else {
                                // Hide the video view if there's no video
                                self.videoView.hidden = true
                            }
                            self.setScrollViewSize()
                            
                        }
                    }
                }
            }
        )
    }
    
    private func setScrollViewSize() {
        var scrollViewHeight = infoView.frame.origin.y + infoView.frame.size.height
        if trailerYoutubeId != nil {
            scrollViewHeight += videoView.frame.size.height
        }
        scrollView.contentSize = CGSize(width: scrollView.frame.size.width, height: scrollViewHeight)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setScrollViewSize()
        videoView.frame.origin.y = infoView.frame.origin.y + infoView.frame.size.height
        titleLabel.text = movie["title"] as? String
        overviewLabel.text = movie["overview"] as? String
        overviewLabel.sizeToFit()
        if let posterPath = movie["poster_path"] as? String {
            setImage(posterPath, posterView: posterImageView)
        }
        fetchTrailer()
    

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
