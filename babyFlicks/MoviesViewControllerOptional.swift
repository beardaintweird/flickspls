//
//  MoviesViewController.swift
//  babyFlicks
//
//  Created by Samee Khan on 1/25/16.
//  Copyright © 2016 Samee Khan. All rights reserved.
//

import UIKit
import AFNetworking

class MoviesViewControllerOptional: UIViewController, UITableViewDataSource, UITableViewDelegate {

    @IBOutlet weak var tableView: UITableView!
    
    var movies: [NSDictionary]?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: "refreshControlAction:", forControlEvents: UIControlEvents.ValueChanged)
        tableView.addSubview(refreshControl)

        
        
        tableView.dataSource = self
        tableView.delegate = self
        
        let apiKey = "a07e22bc18f5cb106bfe4cc1f83ad8ed"
        let url = NSURL(string: "https://api.themoviedb.org/3/movie/now_playing?api_key=\(apiKey)")
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
                if let data = dataOrNil {
                    if let responseDictionary = try! NSJSONSerialization.JSONObjectWithData(
                        data, options:[]) as? NSDictionary {
                            print("response: \(responseDictionary)")
                            
                            self.movies = (responseDictionary["results"] as! [NSDictionary])
                            self.tableView.reloadData()
                    }
                }
        })
        task.resume()        // Do any additional setup after loading the view.
    }
    
    let totalColors: Int = 100
    func colorForIndexPath(indexPath: NSIndexPath) -> UIColor {
        if indexPath.row >= totalColors {
            return UIColor.blackColor()	// return black if we get an unexpected row index
        }
        
        var hueValue: CGFloat = CGFloat(indexPath.row) / CGFloat(totalColors)
        return UIColor(hue: hueValue, saturation: 1.0, brightness: 1.0, alpha: 1.0)
    }
    
    override func viewDidAppear(animated: Bool) {
        EZLoadingActivity.showWithDelay("Loading...", disableUI: true, seconds: 2)
    }
    
    // creating the refresh control actions
    let refreshControl = UIRefreshControl()
    func refreshControlAction(refreshControl: UIRefreshControl)
    {
    // ... Create the NSURLRequest (myRequest) ...
    
    let myRequest = NSURLRequest()
    
    
    // Configure session so that completion handler is executed on main UI thread
    let session = NSURLSession(
        configuration: NSURLSessionConfiguration.defaultSessionConfiguration(),
        delegate:nil,
        delegateQueue:NSOperationQueue.mainQueue()
    )
    let task : NSURLSessionDataTask = session.dataTaskWithRequest(myRequest,
        completionHandler: { (data, response, error) in
            
            // ... Use the new data to update the data source ...
            
            // Reload the tableView now that there is new data
            self.tableView.reloadData()
            
            // Tell the refreshControl to stop spinning
            refreshControl.endRefreshing()
    });
    refreshControl.addTarget(self, action: "refreshControlAction", forControlEvents: UIControlEvents.ValueChanged)
    tableView.addSubview(refreshControl)
    task.resume()
}
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let movies = movies {
            return movies.count
        } else {
            return 0
        }
    }
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("MovieCell", forIndexPath: indexPath) as! MovieCell
        
        let movie = movies![indexPath.row]
        let title = movie["title"] as! String
        let overview = movie["overview"] as! String
        let posterPath = movie["poster_path"] as! String
        
        let baseUrl = "http://image.tmdb.org/t/p/w500"
        
        let imageUrl = NSURL(string: baseUrl + posterPath)
        
        
        cell.titleLabel.text = title
        cell.overviewLabel.text = overview
        cell.posterView.setImageWithURL(imageUrl!)
        
        print("row \(indexPath.row)")
        return cell
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
