//
//  SearchViewController.swift
//  DiffableiOS12
//
//  Created by Daniel Yount on 2/7/20.
//  Copyright © 2020 Daniel Yount. All rights reserved.
//

import UIKit

enum SearchSection {
    case main
}

class SearchViewController: UIViewController {

    @IBOutlet weak var quickResultsTableView: UITableView!
    @IBOutlet weak var recentResultsTableView: UITableView!
    @IBOutlet weak var searchBar: UISearchBar!

    @IBOutlet weak var searchPromptLabel: UILabel!

    private var quickResultsTableViewDelegate = QuickSearchTableViewDelegate()
    private var quickResultsDatasource = QuickSearchDataSourceAdapter()

    private var recentSearchTableViewDelegate = RecentSearchTableViewDelegate()
    private var recentSearchDatasource = RecentSearchDataSourceAdapter()

    override func viewDidLoad() {
        super.viewDidLoad()
        registerComponents()
        setupTableViews()
        searchBar.delegate = self
        setupInitialLayout()
        recentSearchDatasource.loadRecents()
    }

    func updateUI() {
        if #available(iOS 13, *) {
            recentSearchDatasource.updateRecentSearchData()
        } else {
            recentSearchDatasource.recentSearchResults = Coordinators.search.cachedRecentResults
            quickResultsTableView.reloadData()
            recentResultsTableView.reloadData()
        }
    }

    @IBAction func doneButtonPressed(_ sender: Any) {
        dismiss(animated: true)
    }
}

// MARK: - SearchBar
extension SearchViewController: UISearchBarDelegate {
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        updateUI()
        quickResultsDatasource.updateQuickSearchData(results: mockData)
        quickResultsTableView.isHidden = false
        recentResultsTableView.isHidden = true
        searchPromptLabel.isHidden = true
    }

    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        quickResultsTableView.isHidden = true
        recentResultsTableView.isHidden = false
        searchPromptLabel.text = "Search for something..."
        searchPromptLabel.isHidden = !Coordinators.search.cachedRecentResults.isEmpty
    }

    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        guard !searchText.isEmpty else {
            quickResultsDatasource.updateQuickSearchData(results: mockData)
            updateUI()
            recentResultsTableView.isHidden = true
            searchPromptLabel.isHidden = true
            return
        }
        searchPromptLabel.isHidden = true
        let results = mockData.filter { $0.name.lowercased().contains(searchText.lowercased()) }
        if results.isEmpty {
            searchPromptLabel.isHidden = false
            searchPromptLabel.text = "No results :("
        }
        quickResultsDatasource.updateQuickSearchData(results: results)
        updateUI()
    }
}

// MARK: - TableView
extension SearchViewController {
    private func registerComponents() {
        let nib = UINib(nibName: "SearchResultTableViewCell", bundle: nil)
        quickResultsTableView.register(nib, forCellReuseIdentifier: "searchResultCell")
        recentResultsTableView.register(nib, forCellReuseIdentifier: "searchResultCell")

        let footerNib = UINib(nibName: "RecentSearchFooterView", bundle: nil)
        recentResultsTableView.register(footerNib, forHeaderFooterViewReuseIdentifier: "recentSearchFooterView")
    }

    private func setupTableViews() {
        
        recentSearchDatasource.delegate = self
        quickResultsDatasource.delgate = self

        quickResultsTableView.delegate = quickResultsTableViewDelegate
        recentResultsTableView.delegate = recentSearchTableViewDelegate
        recentSearchTableViewDelegate.searchViewController = self
        quickResultsTableViewDelegate.searchViewController = self

        if #available(iOS 13, *) {
            recentResultsTableView.dataSource = recentSearchDatasource.recentSearchDiffableDataSource
            quickResultsTableView.dataSource = quickResultsDatasource.quickSearchDiffableDatasource
        } else {
            quickResultsTableView.dataSource = quickResultsDatasource.dataSource
            recentResultsTableView.dataSource = recentSearchDatasource.dataSource
        }
    }

    private func setupInitialLayout() {
        searchPromptLabel.isHidden = !Coordinators.search.cachedRecentResults.isEmpty
        quickResultsTableView.isHidden = true
        recentResultsTableView.isHidden = Coordinators.search.cachedRecentResults.isEmpty
    }

}

// MARK: - Footer Delegate
extension SearchViewController: RecentSearchFooterDelegate {
    func footerButtonPressed() {
        Coordinators.search.cachedRecentResults.removeAll()
        if #available(iOS 13, *) {
            recentSearchDatasource.clearRecentSearchData()
        } else {
            updateUI()
            searchPromptLabel.isHidden = false
        }
    }
}
