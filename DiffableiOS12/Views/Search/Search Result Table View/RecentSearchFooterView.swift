//
//  RecentSearchFooterView.swift
//  DiffableiOS12
//
//  Created by Daniel Yount on 2/7/20.
//  Copyright © 2020 Daniel Yount. All rights reserved.
//

import UIKit

protocol RecentSearchFooterDelegate: NSObjectProtocol {
    func footerButtonPressed()
}

class RecentSearchFooterView: UITableViewHeaderFooterView {

    weak var delegate: RecentSearchFooterDelegate?
    
    @IBAction func buttonPressed(_ sender: Any) {
        delegate?.footerButtonPressed()
    }
}
