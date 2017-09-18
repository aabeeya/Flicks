//
//  ViewController.swift
//  Flicks
//
//  Created by Aabeeya on 9/15/17.
//  Copyright © 2017 Aabeeya. All rights reserved.
//

import UIKit
import AFNetworking
import MBProgressHUD

class ViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var networkErrorView: UIView!

    var movies: [[String: Any]] = [[String: Any]]()

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        tableView.dataSource = self
        tableView.delegate = self

        // Initialize a UIRefreshControl
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(refreshControlAction(_:)), for: UIControlEvents.valueChanged)
        // add refresh control to table view
        tableView.insertSubview(refreshControl, at: 0)

        reloadMovieData(nil);
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return movies.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "MovieCell") as! MovieCell

        let movie = movies[indexPath.row]
        let title = movie["title"] as? String
        let synopsis = movie["overview"] as? String
        var posterUrl: URL!
        if let path = movie["poster_path"] as? String {
            let baseUrl = "http://image.tmdb.org/t/p/w500"
            posterUrl = URL(string:  baseUrl + path)!
        }

        cell.titleLabel.text = title
        cell.synopsisLabel.text = synopsis
        cell.posterView.setImageWith(posterUrl)

        return cell

    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // get reference to the details view Controller
        let destinationViewController = segue.destination as! MovieDetailViewController
        // index path of the selected photo
        let indexpath = tableView.indexPath(for: sender as! UITableViewCell)!

        let movie = movies[indexpath.row]
        destinationViewController.movie = movie;
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated:true)
    }

    // Makes a network request to get updated data
    // Updates the tableView with the new data
    // Hides the RefreshControl
    func refreshControlAction(_ refreshControl: UIRefreshControl) {
        reloadMovieData(refreshControl)
    }

    func reloadMovieData(_ refreshControl: UIRefreshControl?) {
        MBProgressHUD.showAdded(to: self.view, animated: true)

        let url = URL(string:"https://api.themoviedb.org/3/movie/now_playing?api_key=a07e22bc18f5cb106bfe4cc1f83ad8ed")
        var request = URLRequest(url: url!)
        request.cachePolicy = .reloadIgnoringLocalAndRemoteCacheData
        let session = URLSession(
            configuration: URLSessionConfiguration.default,
            delegate:nil,
            delegateQueue:OperationQueue.main
        )
        let task : URLSessionDataTask = session.dataTask(with: request, completionHandler:
        { (dataOrNil, response, error) in
            if let data = dataOrNil {

                let dictionary = try! JSONSerialization.jsonObject(with: data, options: []) as! [String: Any]

                // Hide HUD once the network request comes back (must be done on main UI thread)
                MBProgressHUD.hide(for: self.view, animated: true)
                self.networkErrorView.isHidden = true;
                self.networkErrorView.frame.size.height = 0;

                self.movies = dictionary["results"] as! [[String:Any]]
                self.tableView.reloadData()

                if (refreshControl != nil) {
                    // Tell the refreshControl to stop spinning
                    refreshControl!.endRefreshing()
                }

            }

            if (error != nil) {
                self.networkErrorView.isHidden = false;
                self.networkErrorView.frame.size.height = 40;
            }
        });
        task.resume()
    }

}

