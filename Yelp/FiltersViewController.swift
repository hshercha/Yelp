    //
//  FiltersViewController.swift
//  Yelp
//
//  Created by hsherchan on 9/19/17.
//  Copyright © 2017 Timothy Lee. All rights reserved.
//

import UIKit

enum SectionIdentifier : Int {
    case deals = 0
    case distance = 1
    case sort = 2
    case category = 3
}
    
@objc protocol FiltersViewControllerDelegate {
    @objc optional func filtersViewController(filtersViewController: FiltersViewController, didUpdateFilters filters: [String: AnyObject])
}
    
class FiltersViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    weak var delegate: FiltersViewControllerDelegate?
    
    var categories: [[String:String]]!
    var switchStates = [Int:[Int:Bool]] ()
    var selectStates = [Int:Int]()
    
    let sections: [String] = ["", "Distance", "Sort By", "Category"]
    let dealSectionData: [String] = ["Offering a deal"]
    let distanceSectionData: [String] = ["Auto", "0.3 miles", "1 mile", "5 miles", "20 miles"]
    let sortSectionData: [String] = ["Best Match", "Distance", "Highest Rated"]
    var categoriesSectionData = [String]()
    var sectionsData = [Int:[String]]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        
        categories = Utils.yelpCategories()
        categoriesSectionData = categories.map({return $0["title"]!})

        sectionsData = [0: dealSectionData, 1: distanceSectionData, 2: sortSectionData, 3: categoriesSectionData]
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func onCancelButton(_ sender: Any) {
        dismiss(animated: true, completion:nil)
    }

    @IBAction func onSearchButton(_ sender: Any) {
        dismiss(animated: true, completion:nil)
        var filters = [String:AnyObject] ()
        var selectedCategories = [String] ()
        
        for (row,isSelected) in switchStates[SectionIdentifier.category.rawValue] ?? [:] {
            if isSelected {
                selectedCategories.append(categories[row]["value"]!)
            }
        }
        
        if selectedCategories.count > 0 {
            filters["categories"] = selectedCategories as AnyObject
        }
        delegate?.filtersViewController!(filtersViewController: self, didUpdateFilters: filters)
    }
}
    
extension FiltersViewController: UITableViewDataSource, UITableViewDelegate {
    func numberOfSections(in tableView: UITableView) -> Int {
        return sectionsData.count
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return sections[section]
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return (sectionsData[section]?.count)!
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch (indexPath.section){
        case SectionIdentifier.distance.rawValue, SectionIdentifier.sort.rawValue:
            let cell = tableView.dequeueReusableCell(withIdentifier: "SelectCell", for: indexPath) as! SelectCell
            cell.selectLabel.text = sectionsData[indexPath.section]?[indexPath.row]
            
            if selectStates[indexPath.section] == nil {
                selectStates[indexPath.section] = 0
            }
            
            if selectStates[indexPath.section] == indexPath.row {
                let image = UIImage(named: "check") as UIImage!
                cell.selectBtn.setBackgroundImage(image, for: UIControlState.normal)
            } else {
                cell.selectBtn.setBackgroundImage(nil, for: UIControlState.normal)
                cell.selectBtn.backgroundColor = .gray
            }
            cell.delegate = self
            return cell
        case SectionIdentifier.deals.rawValue, SectionIdentifier.category.rawValue:
            let cell = tableView.dequeueReusableCell(withIdentifier: "SwitchCell", for: indexPath) as! SwitchCell
            cell.switchLabel.text = sectionsData[indexPath.section]?[indexPath.row]
            cell.onSwitch.isOn = switchStates[indexPath.section]?[indexPath.row] ?? false
            cell.delegate = self
            return cell
        default:
            break
        }
        
        return UITableViewCell()
    }
    
}
    
extension FiltersViewController: SwitchCellDelegate, SelectCellDelegate {
    func switchCell(switchCell: SwitchCell, didChangeValue value: Bool) {
        let indexPath = tableView.indexPath(for: switchCell)!
        if switchStates[indexPath.section] == nil {
            switchStates[indexPath.section] = [indexPath.row: value]
        } else {
            switchStates[indexPath.section]?[indexPath.row] = value
        }
    }
    
    func selectCell(selectCell: SelectCell, isSelected value: Bool) {
        let indexPath = tableView.indexPath(for: selectCell)!
        selectStates[indexPath.section] = indexPath.row
        self.tableView.reloadData()
    }
}
