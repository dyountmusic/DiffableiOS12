//
//  SearchViewController.swift
//  DiffableiOS12
//
//  Created by Daniel Yount on 2/7/20.
//  Copyright © 2020 Daniel Yount. All rights reserved.
//

import UIKit

class SearchViewController: UIViewController {

    @IBOutlet weak var quickResultsTableView: UITableView!

    @IBOutlet weak var recentResultsTableView: UITableView!

    @IBOutlet weak var searchBar: UISearchBar!

    override func viewDidLoad() {
        super.viewDidLoad()
        print(mockData)
    }

    @IBAction func doneButtonPressed(_ sender: Any) {
        dismiss(animated: true)
    }
}
