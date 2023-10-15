//
//  TaskTableViewCell.swift
//  To-Do-List
//
//  Created by Vlad Kugan on 15.10.23.
//

import UIKit

protocol TaskTableViewCellDelegate: AnyObject {
    func didTapButtonInCell(_ cell: TaskTableViewCell)
}


class TaskTableViewCell: UITableViewCell {

    @IBOutlet weak var textCell: UILabel!
    @IBOutlet weak var buttonCell: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    weak var delegate: TaskTableViewCellDelegate?
    
    @IBAction func buttonTapped(_ sender: UIButton) {
        delegate?.didTapButtonInCell(self)
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
}
