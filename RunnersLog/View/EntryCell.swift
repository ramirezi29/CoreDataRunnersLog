//
//  EntryCell.swift
//  RunnersLog
//
//  Created by Ivan Ramirez on 1/26/22.
//

import UIKit

class EntryCell: UITableViewCell {

    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var distanceLabel: UILabel!

    var entry: Entry? {
        didSet {
            updateViews()
        }
    }

    func updateViews() {
        guard let entry = entry else { return }
        dateLabel.text = entry.date?.asString
        distanceLabel.text = entry.distance
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
