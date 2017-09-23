//
//  SelectCell.swift
//  Yelp
//
//  Created by hsherchan on 9/22/17.
//  Copyright © 2017 Timothy Lee. All rights reserved.
//

import UIKit

@objc protocol SelectCellDelegate {
    @objc optional func selectCell(selectCell: SelectCell, isSelected value:Bool)
}
class SelectCell: UITableViewCell {

    @IBOutlet weak var selectLabel: UILabel!
    @IBOutlet weak var selectBtn: UIButton!
    
    weak var delegate: SelectCellDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        selectBtn.layer.cornerRadius = 15
        selectBtn.clipsToBounds = true
        
        selectBtn.addTarget(self, action: #selector(SelectCell.newOptionSelected), for: UIControlEvents.touchDown)
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func newOptionSelected() {
        delegate?.selectCell?(selectCell: self, isSelected: true)
    }

}
