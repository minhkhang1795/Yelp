//
//  BusinessesViewController.swift
//  Yelp
//
//  Created by Timothy Lee on 4/23/15.
//  Copyright (c) 2015 Timothy Lee. All rights reserved.
//

import UIKit

class BusinessesViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate, FiltersViewControllerDelegate {

    @IBOutlet weak var fadedView: UIView!
    @IBOutlet weak var tableView: UITableView!
    lazy var searchBar: UISearchBar = UISearchBar(frame: CGRectMake(0, 0, 200, 20))
    var searchActive: Bool = false
    var businesses: [Business]!
    var searchBarFilters: [Business]!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.searchBar.placeholder = "Restaurant"
        
        self.navigationItem.titleView = searchBar
        self.searchBar.delegate = self
        
        
        let fadedViewtapGestureRecognizer = UITapGestureRecognizer(target: self, action: "onFadedViewTap")
        self.fadedView.addGestureRecognizer(fadedViewtapGestureRecognizer)
        let fadedViewpanGestureRecognizer = UIPanGestureRecognizer(target: self, action: "onFadedViewTap")
        self.fadedView.addGestureRecognizer(fadedViewpanGestureRecognizer)

//        Business.searchWithTerm("Thai", completion: { (businesses: [Business]!, error: NSError!) -> Void in
//            self.businesses = businesses
//            
//            for business in businesses {
//                println(business.name!)
//                println(business.address!)
//            }
//        })
        
        tableView.dataSource = self
        tableView.delegate = self
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 120
        
        Business.searchWithTerm("Restaurants", sort: .Distance, categories: nil, deals: nil, distance: 10, offset: 0) { (businesses: [Business]!, error: NSError!) -> Void in
            
            self.businesses = businesses
            self.tableView.reloadData()
        
        }
    }
    
    // - Table View
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if searchBarFilters != nil {
            return searchBarFilters!.count
        } else if businesses != nil {
            return businesses!.count
        } else {
            return 0
        }
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("BusinessCell", forIndexPath: indexPath) as! BusinessCell
        var business = searchActive ? searchBarFilters : businesses!
        cell.business = business[indexPath.row]
        
        return cell
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }

    
    // MARK: - Search Bar
    
    func searchBarTextDidBeginEditing(searchBar: UISearchBar) {
        self.fadedView.userInteractionEnabled = true
        self.fadedView.alpha = 0.35
    }
    
    func searchBarTextDidEndEditing(searchBar: UISearchBar) {
        self.searchBar.endEditing(true)
        self.fadedView.userInteractionEnabled = false
        self.fadedView.alpha = 0
    }
    
    func searchBarSearchButtonClicked(searchBar: UISearchBar) {
        self.searchBar.endEditing(true)
        self.fadedView.userInteractionEnabled = false
        self.fadedView.alpha = 0
    }
    
    func searchBar(searchBar: UISearchBar, textDidChange searchText: String) {
        if businesses != nil {
            searchBarFilters = businesses!.filter({ (business) -> Bool in
                let tmpTitle = business.name
                let range = tmpTitle!.rangeOfString(searchText, options: NSStringCompareOptions.CaseInsensitiveSearch)
                return range != nil
            })
        }
        
        if (searchText == "" && searchBarFilters.count == 0) {
            searchActive = false
        } else {
            searchActive = true
        }
        self.tableView.reloadData()
    }
    
    func onFadedViewTap() {
        self.searchBar.endEditing(true)
        self.fadedView.userInteractionEnabled = false
        self.fadedView.alpha = 0
    }

    
    // MARK: - Navigation

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "Filters" {
            let navigationController = segue.destinationViewController as! UINavigationController
            let filtersViewController = navigationController.topViewController as! FiltersViewController
            
            filtersViewController.delegate = self
        }
        
        else if segue.identifier == "BusinessDetails" {
            let cell = sender as! UITableViewCell
            let indexPath = tableView.indexPathForCell(cell)!
            
            let business = searchActive ? searchBarFilters[indexPath.row] : businesses![indexPath.row]
            
            let businessDetailsViewController = segue.destinationViewController as! BusinessDetailsViewController
            businessDetailsViewController.business = business
        }
    }
    
    func filtersViewController(filltersViewController: FiltersViewController, didUpdateFilters filters: [String : AnyObject]) {
        //Deals
        var deals = filters["deals"] as? Bool
        
        //Distance
        var distance = filters["distance"] as? Double
        
        //Sort
        var sortRawValue = filters["sortRawValue"] as? Int
        var sort = (sortRawValue != nil) ? YelpSortMode(rawValue: sortRawValue!) : nil
        
        //Categories
        var categories = filters["categories"] as? [String]
        
        Business.searchWithTerm("Restaurants", sort: sort, categories: categories, deals: deals, distance: distance, offset: 20) { (businesses: [Business]!, error: NSError!) -> Void in
            self.businesses = businesses
            self.tableView.reloadData()
        }
    }
}
