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
    
    var currentDeal: Bool!
    var currentDistance: Float!
    var currentSort: YelpSortMode!
    var currentCategories: [String]!
    var currentOffset: Int!
    
    var tempTableFooter: UIView!
    var loadingState: UIActivityIndicatorView!
    var noMoreResultLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.searchBar.placeholder = "Restaurant"
        self.navigationItem.titleView = searchBar
        self.searchBar.delegate = self
        
        
        let fadedViewtapGestureRecognizer = UITapGestureRecognizer(target: self, action: "onFadedViewTap")
        self.fadedView.addGestureRecognizer(fadedViewtapGestureRecognizer)
        let fadedViewpanGestureRecognizer = UIPanGestureRecognizer(target: self, action: "onFadedViewTap")
        self.fadedView.addGestureRecognizer(fadedViewpanGestureRecognizer)
        
        
        tableView.dataSource = self
        tableView.delegate = self
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 120
        tableFooterViewConfig()
        
        Business.searchWithTerm("Restaurants", sort: currentSort, categories: currentCategories, deals: currentDeal, distance: currentDistance, offset: currentOffset) { (businesses: [Business]!, error: NSError!) -> Void in
            
            self.businesses = businesses
            self.tableView.reloadData()
        }
    }
    
    override func viewDidLayoutSubviews() {
        tableFooterViewConfig()
    }
    
    
    // MARK: - Table View
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let businesses = businesses {
            if searchActive {
                return searchBarFilters!.count
            }
            return businesses.count
        } else {
            return 0
        }
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("BusinessCell", forIndexPath: indexPath) as! BusinessCell
        var business = searchActive ? searchBarFilters : businesses!
        cell.business = business[indexPath.row]
        
        if indexPath.row == businesses.count - 1 {
            noMoreResultLabel.hidden ? self.loadingState.startAnimating() : loadingState.stopAnimating()
            searchMoreBusinesses()
        } else {
            loadingState.stopAnimating()
        }
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
            self.searchBar.text = ""
            self.searchActive = false
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
        
        // Deals
        currentDeal = filters["deals"] as? Bool
        
        // Distance
        currentDistance = filters["distance"] as? Float
        
        // Sort
        var sortRawValue = filters["sortRawValue"] as? Int
        currentSort = (sortRawValue != nil) ? YelpSortMode(rawValue: sortRawValue!) : nil
        
        // Categories
        currentCategories = filters["categories"] as? [String]
        
        // Reset offset
        currentOffset = 0
        
        Business.searchWithTerm("Restaurants", sort: currentSort, categories: currentCategories, deals: currentDeal, distance: currentDistance, offset: currentOffset) { (businesses: [Business]!, error: NSError!) -> Void in
            self.businesses = businesses
            if self.businesses.count == 0 {
                self.noMoreResultLabel.text = "No Result Found"
                self.noMoreResultLabel.hidden = false
            } else {
                self.noMoreResultLabel.text = "No More Result"
            }
            self.tableView.reloadData()
        }
    }
    
    
    // MARK: - Search more Businesses
    
    func searchMoreBusinesses() {
        var moreBusinesses: [Business]!
        currentOffset = businesses.count
        Business.searchWithTerm("Restaurants", sort: currentSort, categories: currentCategories, deals: currentDeal, distance: currentDistance, offset: currentOffset) { (businesses: [Business]!, error: NSError!) -> Void in
            moreBusinesses = businesses
            if moreBusinesses.count == 0 {
                self.noMoreResultLabel.hidden = false
            } else {
                self.noMoreResultLabel.hidden = true
                for business in moreBusinesses {
                    self.businesses.append(business)
                }
            }
            self.tableView.reloadData()
        }
    }
    
    
    func tableFooterViewConfig() {
        tempTableFooter = UIView(frame: CGRect(x: 0, y: 0, width: CGRectGetWidth(view.frame), height: 40))
        loadingState = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.Gray)
        loadingState.center = tempTableFooter.center
        loadingState.hidden = true
        
        noMoreResultLabel = UILabel(frame: CGRect(x: 0, y: 0, width: CGRectGetWidth(view.frame), height: 40))
        noMoreResultLabel.text = "No More Result"
        noMoreResultLabel.textAlignment = .Center
        noMoreResultLabel.center = tempTableFooter.center
        noMoreResultLabel.hidden = true
        
        tempTableFooter.addSubview(loadingState)
        tempTableFooter.addSubview(noMoreResultLabel)
        
        tableView.tableFooterView = tempTableFooter
    }
}
