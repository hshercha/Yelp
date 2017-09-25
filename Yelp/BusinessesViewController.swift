//
//  BusinessesViewController.swift
//  Yelp
//
//  Created by Timothy Lee on 4/23/15.
//  Copyright (c) 2015 Timothy Lee. All rights reserved.
//

import UIKit

class BusinessesViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, FiltersViewControllerDelegate {
    
    var businesses: [Business]!
    var isMoreDataLoading = false
    
    var categories: [String]?
    var deals: Bool?
    var radius: Double?
    var sort: YelpSortMode?
    var searchBar: UISearchBar!
    @IBOutlet weak var tableView: UITableView!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(UIInputViewController.dismissKeyboard))
        
        tap.cancelsTouchesInView = false
        
        view.addGestureRecognizer(tap)
        createSearchBar()
        tableView.dataSource = self
        tableView.delegate = self
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 120
        searchBar.delegate = self
        Business.searchWithTerm(term: "Thai", completion: { (businesses: [Business]?, error: Error?) -> Void in
            
            self.businesses = businesses
            if let businesses = businesses {
                for business in businesses {
                    print(business.name!)
                    print(business.address!)
                }
            }
            
            self.tableView.reloadData()
            
            }
        )
        
    }
    
    func createSearchBar() {
        searchBar = UISearchBar()
        searchBar.sizeToFit()
        searchBar.delegate = self
        searchBar.placeholder = "Restaurants"
        searchBar.sizeToFit()
        if #available(iOS 11.0, *) {
            searchBar.heightAnchor.constraint(equalToConstant: 42).isActive = true
        }
        navigationItem.titleView = searchBar
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        createSearchBar()
        navigationItem.titleView?.sizeToFit()
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        view.endEditing(true)
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if businesses != nil {
            return businesses!.count
        } else {
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "BusinessCell", for: indexPath) as! BusinessCell
        cell.business = businesses[indexPath.row]
        return cell
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "filter" {
            let navigationController = segue.destination as! UINavigationController
            let filtersViewController = navigationController.topViewController as! FiltersViewController
            filtersViewController.delegate = self
        } else if segue.identifier == "map" {
            let navigationController = segue.destination as! UINavigationController
            let mapViewController = navigationController.topViewController as! MapViewController
            mapViewController.businesses = businesses
        }
    }
    
    func filtersViewController(filtersViewController: FiltersViewController, didUpdateFilters filters: [String : AnyObject]) {
        categories = filters["categories"] as?  [String]
        deals = filters["isDealSelected"] as? Bool
        let selectedSortId = filters["selectedSortId"] as? Int
        radius = filters["radiusInMeters"] as? Double
        sort = YelpSortMode(rawValue: selectedSortId!)
        
        Business.searchWithTerm(term: "Restaurants", sort: sort, categories: categories, deals: deals, radius:radius, offset: 0) { (businesses, error) in
            self.businesses = businesses
            self.tableView.reloadData()
        }
    }
    
    func dismissKeyboard() {
        view.endEditing(true)
    }
}

extension BusinessesViewController: UIScrollViewDelegate {

    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if (!isMoreDataLoading) {
            // Calculate the position of one screen length before the bottom of the results
            let scrollViewContentHeight = tableView.contentSize.height
            let scrollOffsetThreshold = scrollViewContentHeight - tableView.bounds.size.height
            
            // When the user has scrolled past the threshold, start requesting
            if(scrollView.contentOffset.y > scrollOffsetThreshold && tableView.isDragging) {
                isMoreDataLoading = true
                
                let tableFooterView: UIView = UIView(frame: CGRect(x:0, y:0, width:self.tableView.frame.width, height:50))
                let loadingView: UIActivityIndicatorView = UIActivityIndicatorView(activityIndicatorStyle: .gray)
                loadingView.startAnimating()
                loadingView.center = tableFooterView.center
                tableFooterView.addSubview(loadingView)
                self.tableView.tableFooterView = tableFooterView
                Business.searchWithTerm(term: "Restaurants", sort: sort, categories: categories, deals: deals, radius:radius, offset: self.businesses.count) { (businesses, error) in
                    for business in businesses! {
                        self.businesses.append(business)
                    }
                    loadingView.stopAnimating()
                    self.tableView.reloadData()
                }
            }
        }
    }
}

extension BusinessesViewController: UISearchBarDelegate {

    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.showsCancelButton = false
        searchBar.text = ""
        searchBar.resignFirstResponder()
        tableView.reloadData()
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        let modifiedSearchText = searchText + " restaurants"
        Business.searchWithTerm(term: modifiedSearchText, sort: sort, categories: categories, deals: deals, radius:radius, offset: 0) { (businesses, error) in
            self.businesses = businesses
            self.tableView.reloadData()
        }
    }
}
