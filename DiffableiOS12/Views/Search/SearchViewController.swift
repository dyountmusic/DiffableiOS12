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

    @IBOutlet weak var searchPromptLabel: UILabel!

    private var quickResultsTableViewDelegate = QuickSearchTableViewDelegate()
    private var quickResultsTableViewDatasource = QuickSearchTableViewDatasource()

    private var recentSearchTableViewDelegate = RecentSearchTableViewDelegate()
    private var recentSearchTableViewDatasource = RecentSearchTableViewDatasource()

    private lazy var recentSearchDiffableDatasource: Any? = {
        if #available(iOS 13, *) {
            return makeRecentSearchDatasource()
        } else {
            return nil
        }
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        registerComponents()
        setupTableViews()
        searchBar.delegate = self
        setupInitialLayout()
        loadRecents()
    }

    func updateUI() {
        if #available(iOS 13, *) {
            quickResultsTableView.reloadData()
            updateRecentSearchData()
        } else {
            recentSearchTableViewDatasource.recentSearchItems = Coordinators.search.cachedRecentResults
            quickResultsTableView.reloadData()
            recentResultsTableView.reloadData()
        }
    }

    @IBAction func doneButtonPressed(_ sender: Any) {
        dismiss(animated: true)
    }
}

// MARK: - Diffable Datasource
extension SearchViewController {

    enum RecentSearchSection {
        case main, sub
    }

    @available(iOS 13, *)
    private func makeRecentSearchDatasource() -> UITableViewDiffableDataSource<RecentSearchSection, Employee> {
        return UITableViewDiffableDataSource(tableView: recentResultsTableView) { tableView, indexPath, result in
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "searchResultCell") as? SearchResultTableViewCell else { return UITableViewCell() }
            cell.categoryLabel.text = result.salary
            cell.titleLabel.text = result.name
            cell.model = result
            return cell
        }
    }

    @available(iOS 13, *)
    private func updateRecentSearchData() {
        guard !Coordinators.search.cachedRecentResults.isEmpty else { return }
        var snapshot = NSDiffableDataSourceSnapshot<RecentSearchSection, Employee>()
        snapshot.appendSections([.main])
        snapshot.appendItems(Coordinators.search.cachedRecentResults, toSection: .main)
        if let diffable = recentSearchDiffableDatasource as? UITableViewDiffableDataSource<RecentSearchSection, Employee> {
            diffable.apply(snapshot, animatingDifferences: true)
        }
    }

    @available(iOS 13, *)
    private func clearRecentSearchData() {
        var snapshot = NSDiffableDataSourceSnapshot<RecentSearchSection, Employee>()
        snapshot.deleteAllItems()
        snapshot.deleteSections([.main])
        if let diffable = recentSearchDiffableDatasource as? UITableViewDiffableDataSource<RecentSearchSection, Employee> {
            diffable.apply(snapshot, animatingDifferences: true)
        }
        recentResultsTableView.isHidden = true
    }

}

// MARK: - SearchBar
extension SearchViewController: UISearchBarDelegate {
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        quickResultsTableViewDatasource.quickSearchItems = mockData
        updateUI()
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
            quickResultsTableViewDatasource.quickSearchItems = mockData
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
        quickResultsTableViewDatasource.quickSearchItems = results
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

        quickResultsTableView.delegate = quickResultsTableViewDelegate
        recentResultsTableView.delegate = recentSearchTableViewDelegate
        recentSearchTableViewDelegate.searchViewController = self
        quickResultsTableViewDelegate.searchViewController = self

        if #available(iOS 13, *) {
            if let recentDiffable = recentSearchDiffableDatasource as? UITableViewDiffableDataSource<RecentSearchSection, Employee> {
                quickResultsTableView.dataSource = quickResultsTableViewDatasource
                recentResultsTableView.dataSource = recentDiffable
            } else {
                quickResultsTableView.dataSource = quickResultsTableViewDatasource
                recentResultsTableView.dataSource = recentSearchTableViewDatasource
            }
        } else {
            quickResultsTableView.dataSource = quickResultsTableViewDatasource
            recentResultsTableView.dataSource = recentSearchTableViewDatasource
        }

    }

    private func setupInitialLayout() {
        searchPromptLabel.isHidden = !Coordinators.search.cachedRecentResults.isEmpty
        quickResultsTableView.isHidden = true
        recentResultsTableView.isHidden = Coordinators.search.cachedRecentResults.isEmpty
    }

    private func loadRecents() {
        guard !Coordinators.search.cachedRecentResults.isEmpty else { return }
        if #available(iOS 13.0, *) {
            if let diffable = recentSearchDiffableDatasource as? UITableViewDiffableDataSource<RecentSearchSection, Employee> {
                var snapshot = NSDiffableDataSourceSnapshot<RecentSearchSection, Employee>()
                snapshot.appendSections([.main])
                snapshot.appendItems(Coordinators.search.cachedRecentResults, toSection: .main)
                diffable.apply(snapshot, animatingDifferences: true)
            }
        } else {
            recentSearchTableViewDatasource.recentSearchItems = Coordinators.search.cachedRecentResults
        }
    }
}

// MARK: - Footer Delegate
extension SearchViewController: RecentSearchFooterDelegate {
    func footerButtonPressed() {
        Coordinators.search.cachedRecentResults.removeAll()
        if #available(iOS 13, *) {
            clearRecentSearchData()
        } else {
            updateUI()
        }
        searchPromptLabel.isHidden = false
    }
}
