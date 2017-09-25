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
    var expandedSections: [Int:Bool] = [SectionIdentifier.deals.rawValue: true, SectionIdentifier.distance.rawValue: false, SectionIdentifier.sort.rawValue: false, SectionIdentifier.category.rawValue: false]
    var collapsedCategoryCellsSize = 4
    
    let sections: [String] = ["", "Distance", "Sort By", "Category"]
    let dealsRowLabels: [String] = ["Offering a deal"]
    let distanceRowLabels: [String] = ["Auto", "0.3 miles", "1 mile", "5 miles", "20 miles"]
    let distanceRowData: [Double] = [0.0, 482.803, 1609.34, 8046.72, 32186.9]
    let sortRowLabels: [String] = ["Best Match", "Distance", "Highest Rated"]
    var categoriesRowLabels = [String]()
    var sectionsData = [Int:[String]]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        
        categories = Utils.yelpCategories()
        categoriesRowLabels = categories.map({return $0["title"]!})

        sectionsData = [0: dealsRowLabels, 1: distanceRowLabels, 2: sortRowLabels, 3: categoriesRowLabels]
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
        
        let deals = switchStates[SectionIdentifier.deals.rawValue]?[0] ?? false
        let distanceRowId = selectStates[SectionIdentifier.distance.rawValue] ?? 0
        let sortId = selectStates[SectionIdentifier.sort.rawValue] ?? 0
        
        filters["isDealSelected"] = deals as AnyObject
        filters["selectedSortId"] = sortId as AnyObject
        filters["radiusInMeters"] = distanceRowData[distanceRowId] as AnyObject
        delegate?.filtersViewController!(filtersViewController: self, didUpdateFilters: filters)
    }
    
    func sectionTapped(section: Int) {
        let updatedSection = !expandedSections[section]!
        expandedSections[section] = updatedSection
        self.tableView.reloadSections([section], with: UITableViewRowAnimation.automatic)
    }
}
    
extension FiltersViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == SectionIdentifier.distance.rawValue || indexPath.section == SectionIdentifier.sort.rawValue {
            
            if expandedSections[indexPath.section]! {
                let cell = tableView.cellForRow(at: indexPath) as! SelectCell
                cell.newOptionSelected()
            } else {
                sectionTapped(section:indexPath.section)
            }
            
        } else if indexPath.section == SectionIdentifier.category.rawValue {
            if (!expandedSections[indexPath.section]!) && (indexPath.row == collapsedCategoryCellsSize - 1) {
                sectionTapped(section:indexPath.section)
            }
        }
    }
    func numberOfSections(in tableView: UITableView) -> Int {
        return sectionsData.count
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return sections[section]
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if expandedSections[section]! {
            return (sectionsData[section]?.count)!
        } else {
            if section == SectionIdentifier.category.rawValue{
               return collapsedCategoryCellsSize
            } else {
                return 1
            }
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch (indexPath.section){
        case SectionIdentifier.distance.rawValue, SectionIdentifier.sort.rawValue:
            if expandedSections[indexPath.section]! {
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
            } else {
                let cell = tableView.dequeueReusableCell(withIdentifier: "CollapsedCell", for: indexPath) as! CollapsedCell
                let selectedRowIndex = selectStates[indexPath.section] ?? 0
                cell.titleLabel.text = sectionsData[indexPath.section]?[selectedRowIndex]
                return cell
            }
        case SectionIdentifier.deals.rawValue:
            let cell = tableView.dequeueReusableCell(withIdentifier: "SwitchCell", for: indexPath) as! SwitchCell
            cell.switchLabel.text = sectionsData[indexPath.section]?[indexPath.row]
            cell.onSwitch.isOn = switchStates[indexPath.section]?[indexPath.row] ?? false
            cell.delegate = self
            return cell
        case SectionIdentifier.category.rawValue:
            if !expandedSections[indexPath.section]! {
                if (indexPath.row < collapsedCategoryCellsSize - 1) {
                    let cell =  tableView.dequeueReusableCell(withIdentifier: "SwitchCell", for: indexPath) as! SwitchCell
                    cell.switchLabel.text = sectionsData[indexPath.section]?[indexPath.row]
                    cell.onSwitch.isOn = switchStates[indexPath.section]?[indexPath.row] ?? false
                    cell.delegate = self
                    
                    return cell
                } else {
                    let cell =  tableView.dequeueReusableCell(withIdentifier: "CollapsedCategoryCell", for: indexPath) as! CollapsedCategoryCell
                    return cell
                }
            } else {
                let cell =  tableView.dequeueReusableCell(withIdentifier: "SwitchCell", for: indexPath) as! SwitchCell
                cell.switchLabel.text = sectionsData[indexPath.section]?[indexPath.row]
                cell.onSwitch.isOn = switchStates[indexPath.section]?[indexPath.row] ?? false
                cell.delegate = self
                return cell
            }
            
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
        sectionTapped(section: indexPath.section)
    }
}
