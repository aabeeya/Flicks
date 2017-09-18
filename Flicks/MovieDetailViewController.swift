//
//  MovieDetailViewController.swift
//  Flicks
//
//  Created by Aabeeya on 9/16/17.
//  Copyright © 2017 Aabeeya. All rights reserved.
//

import UIKit

class MovieDetailViewController: UIViewController {
    @IBOutlet weak var posterDetailImage: UIImageView!

    @IBOutlet weak var detailsView: UIView!
    @IBOutlet weak var scrollView: UIScrollView!

    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var overviewLabel: UILabel!
    @IBOutlet weak var popularityLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var titleLabel: UILabel!

    var movie: [String: Any]!

    override func viewDidLoad() {
        super.viewDidLoad()

        if let path = movie["poster_path"] as? String {
            let baseUrl = "http://image.tmdb.org/t/p/w500"
            let posterUrl = URL(string:  baseUrl + path)!
            posterDetailImage.setImageWith(posterUrl)
        }

        // Get and format date
        let rawDate = movie["release_date"] as! String


        let dateFormatterGet = DateFormatter()
        dateFormatterGet.dateFormat = "yyyy-MM-dd"
        let date: Date! = dateFormatterGet.date(from: rawDate)

        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM dd, yyyy"
        dateLabel.text = formatter.string(from: date)


        // Set text fields
        overviewLabel.text = movie["overview"] as? String
        titleLabel.text = movie["title"] as? String

        // Convert average into a percentage
        let voteAverage = movie["vote_average"] as! Double
        popularityLabel.text = String(format:"%.0f%%", voteAverage * 10)


        // Make a network call for additional movie info, like runtime
        let movieId = movie["id"] as! UInt32;
        getMovieDetails(movieId);


        let contentWidth = scrollView.bounds.width
        overviewLabel.sizeToFit()
        let contentHeight = overviewLabel.frame.size.height + 230;
        scrollView.contentSize = CGSize(width: contentWidth, height: contentHeight)

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


    /*
     // MARK: - Navigation

     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
         // Get the new view controller using segue.destinationViewController.
         // Pass the selected object to the new view controller.
     }
     */

    func getMovieDetails(_ movieId: UInt32) {
        let url = URL(string:String(format:"https://api.themoviedb.org/3/movie/%d?api_key=a07e22bc18f5cb106bfe4cc1f83ad8ed", movieId))
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

                // Get and format runtime
                let runtime = dictionary["runtime"] as! UInt32;
                let formatter = DateComponentsFormatter()
                formatter.unitsStyle = .short
                formatter.allowedUnits = [.hour, .minute]

                self.timeLabel.text = formatter.string(from:TimeInterval(runtime*60))
            }
        });
        task.resume()
    }

}
