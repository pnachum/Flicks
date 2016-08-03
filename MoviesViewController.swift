//
//  MoviesViewController.swift
//  Flicks
//
//  Created by phil_nachum on 8/1/16.
//  Copyright © 2016 phil_nachum. All rights reserved.
//

import UIKit
import AFNetworking
import MBProgressHUD

class MoviesViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var networkErrorView: UIView!

    var movies: [NSDictionary]!
    var endpoint: String!
    var searchBar: UISearchBar!
    var searchText: String!

    var filtered: [NSDictionary] {
        if let movies = movies {
            return movies.filter { (movie) -> Bool in
                let title = (movie["title"] as? String)?.lowercaseString ?? ""
                let search = searchText.lowercaseString
                return (search.characters.count == 0) || title.rangeOfString(search) != nil
            }
        } else {
            return []
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        // QUESTION: This happens every time the view loads. That can't be right
        searchBar = UISearchBar()
        navigationItem.titleView = searchBar
        searchBar.delegate = self

        tableView.delegate = self
        tableView.dataSource = self
        let refreshControl = UIRefreshControl()
        // QUESTION: What is going on here? Why does it require @objc in front of fetchData?
        refreshControl.addTarget(self, action: #selector(fetchData(_:)), forControlEvents: UIControlEvents.ValueChanged)
        tableView.insertSubview(refreshControl, atIndex: 0)

        fetchData(refreshControl)

        // Do any additional setup after loading the view.
    }

    func searchBar(searchBar: UISearchBar, textDidChange searchText: String) {
        updateMoviesData(movies, searchText: searchText)
    }

    private func updateMoviesData(movies: [NSDictionary], searchText: String) {
        self.movies = movies
        self.searchText = searchText
        tableView.reloadData()
    }

    @objc private func fetchData(refreshControl: UIRefreshControl) {
        MBProgressHUD.showHUDAddedTo(self.view, animated: true)
        let apiKey = "a07e22bc18f5cb106bfe4cc1f83ad8ed"
        let url = NSURL(string: "https://api.themoviedb.org/3/movie/\(endpoint)?api_key=\(apiKey)")
        let request = NSURLRequest(
            URL: url!,
            cachePolicy: NSURLRequestCachePolicy.ReloadIgnoringLocalCacheData,
            timeoutInterval: 10)

        let session = NSURLSession(
            configuration: NSURLSessionConfiguration.defaultSessionConfiguration(),
            delegate: nil,
            delegateQueue: NSOperationQueue.mainQueue()
        )

        let task: NSURLSessionDataTask = session.dataTaskWithRequest(request,
             completionHandler: { (dataOrNil, response, error) in
                MBProgressHUD.hideHUDForView(self.view, animated: true)
                refreshControl.endRefreshing()
                if error != nil {
                    self.networkErrorView.hidden = false
                }
                if let data = dataOrNil {
                    if let responseDictionary = try! NSJSONSerialization.JSONObjectWithData(
                        data, options:[]) as? NSDictionary {
                        self.updateMoviesData(responseDictionary["results"] as! [NSDictionary], searchText: self.searchBar.text ?? "")
                        self.networkErrorView.hidden = true
                    }
                }
        })
        task.resume()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filtered.count
    }

    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("MovieCell", forIndexPath: indexPath) as! MovieCell

        let movie = filtered[indexPath.row]
        let baseImageUrl = "http://image.tmdb.org/t/p/w500"
        if let posterPath = movie["poster_path"] as? String {
            let imageUrl = NSURL(string: baseImageUrl + posterPath)
            cell.posterView.setImageWithURL(imageUrl!)
        }

        cell.titleLabel.text = movie["title"] as? String
        cell.overviewLabel.text = movie["overview"] as? String
        return cell
    }


    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        let cell = sender as! UITableViewCell
        let indexPath = tableView.indexPathForCell(cell)
        let movie = filtered[indexPath!.row]
        let detailViewController = segue.destinationViewController as! DetailViewController
        detailViewController.movie = movie
    }
}