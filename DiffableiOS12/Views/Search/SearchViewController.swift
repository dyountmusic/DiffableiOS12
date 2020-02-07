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

    private var quickResultsTableViewDelegate = QuickSearchTableViewDelegate()
    private var quickResultsTableViewDatasource = QuickSearchTableViewDatasource()

    private var recentSearchTableViewDelegate = RecentSearchTableViewDelegate()
    private var recentSearchTableViewDatasource = RecentSearchTableViewDatasource()

    var cachedResults = Coordinators.search.cachedRecentResults

    override func viewDidLoad() {
        super.viewDidLoad()
        registerComponents()
        setupTableViews()
        searchBar.delegate = self
        setupInitialLayout()
    }

    func updateUI() {
        quickResultsTableView.reloadData()
        recentResultsTableView.reloadData()
    }

    @IBAction func doneButtonPressed(_ sender: Any) {
        dismiss(animated: true)
    }
}

extension SearchViewController: UISearchBarDelegate {
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        quickResultsTableViewDatasource.quickSearchItems = mockData
        updateUI()
        quickResultsTableView.isHidden = false
        recentResultsTableView.isHidden = true
    }

    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        quickResultsTableView.isHidden = true
        recentResultsTableView.isHidden = false
    }

    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        guard !searchText.isEmpty else {
            quickResultsTableViewDatasource.quickSearchItems = mockData
            updateUI()
            return
        }
        let results = mockData.filter { $0.name.lowercased().contains(searchText.lowercased()) }
        quickResultsTableViewDatasource.quickSearchItems = results
        updateUI()
    }
}

extension SearchViewController {
    private func registerComponents() {
        let nib = UINib(nibName: "SearchResultTableViewCell", bundle: nil)
        quickResultsTableView.register(nib, forCellReuseIdentifier: "searchResultCell")
        recentResultsTableView.register(nib, forCellReuseIdentifier: "searchResultCell")
    }

    private func setupTableViews() {
        quickResultsTableView.delegate = quickResultsTableViewDelegate
        recentResultsTableView.delegate = recentSearchTableViewDelegate

        quickResultsTableViewDatasource.quickSearchItems = cachedResults

        quickResultsTableView.dataSource = quickResultsTableViewDatasource
        recentResultsTableView.dataSource = recentSearchTableViewDatasource
    }

    private func setupInitialLayout() {
        searchBar.becomeFirstResponder()
        quickResultsTableView.isHidden = true
        recentResultsTableView.isHidden = false
    }
}
