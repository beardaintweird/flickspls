//
//  CollectionViewController.swift
//  babyFlicks
//
//  Created by Samee Khan on 1/31/16.
//  Copyright © 2016 Samee Khan. All rights reserved.
//

import UIKit

private let reuseIdentifier = "Cell"

class CollectionViewController: UIViewController, UICollectionViewDataSource, UISearchBarDelegate, UICollectionViewDelegate {


    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var networkError: UILabel!
    @IBOutlet weak var search: UISearchBar!
    @IBOutlet weak var navButton: UIButton!
    
    var movies: [NSDictionary]?
    var filteredData: [NSDictionary]?
    var movieTitle: [String] = []
    var endpoint: String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navButton.setTitle("Old School", forState: UIControlState.Normal)
        self.networkError.hidden = true
        collectionView.dataSource = self
        collectionView.delegate = self
        search.delegate = self
        
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
                            
                            self.movies = responseDictionary["results"] as! [NSDictionary]
                            print(self.movies)
                            
                            self.filteredData = self.movies
                            print(self.filteredData)
                            
                            self.collectionView.reloadData()
                    }
                }
                else {
                    self.networkError.hidden = false
                    self.search.hidden = true
                }
        })
        task.resume()
        
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: "refreshControlAction:", forControlEvents: UIControlEvents.ValueChanged)
        collectionView.addSubview(refreshControl)
        
        networkRequest()
        print("got to the network request")
//        task.resume()        // Do any additional setup after loading the view.
    }
    
    override func viewDidAppear(animated: Bool) {
        EZLoadingActivity.showWithDelay("Loading...", disableUI: true, seconds: 0.5)
    }
    
    


    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of items
        if let movies = movies {
            return movies.count
        } else {
            return 20
        }
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("MovieCollCell", forIndexPath: indexPath) as! MovieCollCell
        networkRequest()
        print("network request reached.")
        
        let movie = self.movies![indexPath.row]
        let flowPosterPath = movie["poster_path"] as! String
        let baseUrl = "http://image.tmdb.org/t/p/w500"
        let imageUrl = NSURL(string: baseUrl + flowPosterPath)
        
        let imageRequest = NSURLRequest(URL: imageUrl!)
        cell.flowPosterView.setImageWithURLRequest(
            imageRequest,
            placeholderImage: nil,
            success: { (imageRequest, imageResponse, image) -> Void in
                
                // imageResponse will be nil if the image is cached
                if imageResponse != nil {
                    print("Image was NOT cached, fade in image")
                    cell.flowPosterView.alpha = 0.0
                    cell.flowPosterView.image = image
                    UIView.animateWithDuration(1.2, animations: { () -> Void in
                        cell.flowPosterView.alpha = 1.0
                    })
                } else {
                    print("Image was cached so just update the image")
                    cell.flowPosterView.image = image
                }
            },
            failure: { (imageRequest, imageResponse, error) -> Void in
                // do something for the failure condition
        })
        cell.flowPosterView.setImageWithURL(imageUrl!)
        
        print("row \(indexPath.row)")
        return cell
    }
    
    func networkRequest() {
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
                            
                            self.movies = (responseDictionary["results"] as? [NSDictionary])
                            self.filteredData = self.movies
                            print(self.filteredData)
                            
                            self.collectionView.reloadData()
                    }
                }
                else {
                    self.networkError.hidden = false
                    self.search.hidden = true
                }
        })
        task.resume()
    }


    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        print("prepare for segue called.")
        
        if segue.identifier == "showDetailedViewController" {
            let cell = sender as! UICollectionViewCell
            if let indexPath = collectionView.indexPathForCell(cell) {
                let detailedController = segue.destinationViewController as! DetailViewController
                detailedController.movie = movies![indexPath.row]
                collectionView.deselectItemAtIndexPath(indexPath, animated: true)
            }
        }

        
        //        guard
//            let destinationVC = segue.destinationViewController as? UINavigationController,
//            let cvc = destinationVC.topViewController as? CollectionViewController,
//            let selectedCell = sender as? UICollectionViewCell,
//            let selectedIndexPath = collectionView.indexPathForCell(selectedCell),
//            let movie = movies?[selectedIndexPath.row]
//        else {
//            return
//        }
//        
//        cvc.movies = movie
        
        // Get the new view controller using [segue destinationViewController].
        // Pass the selected object to the new view controller.
    }


    // MARK: UICollectionViewDataSource

     func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 20

    }


    
    func searchBar(searchBar: UISearchBar, textDidChange searchText: String) {
        
        filteredData = searchText.isEmpty ? movies : movies!.filter({(movie: NSDictionary) -> Bool in
            
            let title = movie["title"] as! String
            let overview = movie["overview"] as! String
            
            return title.rangeOfString(searchText, options: .CaseInsensitiveSearch) != nil || overview.rangeOfString(searchText, options: .CaseInsensitiveSearch) != nil
        })
        collectionView.reloadData()
    }
    
    
    
//    @IBAction func onTap(sender: AnyObject) {
//        view.endEditing(true)
//    }
//    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        print("Tap is being recognized.")
    }
    
    // creating the refresh control actions
    let refreshControlAction = UIRefreshControl()
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
                self.collectionView.reloadData()
                
                // Tell the refreshControl to stop spinning
                refreshControl.endRefreshing()
        });
        refreshControl.addTarget(self, action: "refreshControlAction", forControlEvents: UIControlEvents.ValueChanged)
        collectionView.addSubview(refreshControl)
        task.resume()
        
        
        
        // Uncomment the following line to preserve selection between presentations
//        self.clearsSelectionOnViewWillAppear = true
        
//         Register cell classes
        self.collectionView!.registerClass(UICollectionViewCell.self, forCellWithReuseIdentifier: reuseIdentifier)
        
        // Do any additional setup after loading the view.
    }

    // MARK: UICollectionViewDelegate

    /*
    // Uncomment this method to specify if the specified item should be highlighted during tracking
    override func collectionView(collectionView: UICollectionView, shouldHighlightItemAtIndexPath indexPath: NSIndexPath) -> Bool {
        return true
    }
    */

    /*
    // Uncomment this method to specify if the specified item should be selected
    override func collectionView(collectionView: UICollectionView, shouldSelectItemAtIndexPath indexPath: NSIndexPath) -> Bool {
        return true
    }
    */

    /*
    // Uncomment these methods to specify if an action menu should be displayed for the specified item, and react to actions performed on the item
    override func collectionView(collectionView: UICollectionView, shouldShowMenuForItemAtIndexPath indexPath: NSIndexPath) -> Bool {
        return false
    }

    override func collectionView(collectionView: UICollectionView, canPerformAction action: Selector, forItemAtIndexPath indexPath: NSIndexPath, withSender sender: AnyObject?) -> Bool {
        return false
    }

    override func collectionView(collectionView: UICollectionView, performAction action: Selector, forItemAtIndexPath indexPath: NSIndexPath, withSender sender: AnyObject?) {
    
    }
    */


}