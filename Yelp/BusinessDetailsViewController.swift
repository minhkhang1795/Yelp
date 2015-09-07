//
//  BusinessDetailsViewController.swift
//  Yelp
//
//  Created by Clover on 9/7/15.
//  Copyright (c) 2015 Timothy Lee. All rights reserved.
//

import UIKit
import MapKit

class BusinessDetailsViewController: UIViewController {
    
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var thumbImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var distanceLabel: UILabel!
    @IBOutlet weak var ratingImageView: UIImageView!
    @IBOutlet weak var reviewsCountLabel: UILabel!
    @IBOutlet weak var addressLabel: UILabel!
    @IBOutlet weak var categoriesLabel: UILabel!
    
    var latitude: Double!
    var longitude: Double!
    var business: Business!
    var point = MKPointAnnotation()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        nameLabel.text = business.name
        thumbImageView.setImageWithURL(business.imageURL)
        categoriesLabel.text = business.categories
        addressLabel.text = business.address
        reviewsCountLabel.text = "\(business.reviewCount!) Reviews"
        ratingImageView.setImageWithURL(business.ratingImageURL)
        distanceLabel.text = business.distance
        
        latitude = business.latitude
        longitude = business.longitude
        
        // set initial location
        let initialLocation = CLLocation(latitude: latitude, longitude: longitude)
        let regionRadius: CLLocationDistance = 300
        func centerMapOnLocation(location: CLLocation) {
            let coordinateRegion = MKCoordinateRegionMakeWithDistance(location.coordinate,
                regionRadius * 2.0, regionRadius * 2.0)
            mapView.setRegion(coordinateRegion, animated: true)
        }
        
        point.title = business.name
        point.subtitle = business.address
        point.coordinate = initialLocation.coordinate
        
        mapView.addAnnotation(point)
        centerMapOnLocation(initialLocation)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Navigation
   
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        let mapViewController = segue.destinationViewController as! MapViewController
        mapViewController.point = self.point
        mapViewController.latitude = self.latitude
        mapViewController.longitude = self.longitude
    }
    
    
}
