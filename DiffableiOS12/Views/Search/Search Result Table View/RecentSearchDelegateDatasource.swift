//
//  RecentSearchDelegateDatasource.swift
//  DiffableiOS12
//
//  Created by Daniel Yount on 2/7/20.
//  Copyright © 2020 Daniel Yount. All rights reserved.
//

import Foundation
import UIKit

class RecentSearchDataSourceAdapter {
    weak var delegate: SearchViewController?
    
    var dataSource = RecentSearchTableViewDatasource()
    
    var recentSearchResults = [Employee]()
    
    @available(iOS 13.0, *)
    lazy var recentSearchDiffableDataSource: UITableViewDiffableDataSource<SearchSection, Employee> = makeRecentSearchDatasource()
    
    @available(iOS 13, *)
    private func makeRecentSearchDatasource() -> UITableViewDiffableDataSource<SearchSection, Employee> {
        guard let tableView = delegate?.recentResultsTableView else {
            fatalError("Missing delegate for RecentSearchDataSourceAdapter.")
        }
        return UITableViewDiffableDataSource(tableView: tableView) { tableView, indexPath, result in
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "searchResultCell") as? SearchResultTableViewCell else { return UITableViewCell() }
            cell.categoryLabel.text = result.salary
            cell.titleLabel.text = result.name
            cell.model = result
            return cell
        }
    }
    
    func loadRecents() {
        guard !Coordinators.search.cachedRecentResults.isEmpty else { return }
        if #available(iOS 13.0, *) {
            var snapshot = NSDiffableDataSourceSnapshot<SearchSection, Employee>()
            snapshot.appendSections([.main])
            snapshot.appendItems(Coordinators.search.cachedRecentResults, toSection: .main)
            recentSearchDiffableDataSource.apply(snapshot, animatingDifferences: true)
        } else {
            dataSource.recentSearchItems = Coordinators.search.cachedRecentResults
        }
    }
    
    @available(iOS 13, *)
    func updateRecentSearchData() {
        guard !Coordinators.search.cachedRecentResults.isEmpty else { return }
        var snapshot = NSDiffableDataSourceSnapshot<SearchSection, Employee>()
        snapshot.appendSections([.main])
        snapshot.appendItems(Coordinators.search.cachedRecentResults, toSection: .main)
        recentSearchDiffableDataSource.apply(snapshot, animatingDifferences: true)
    }
    
    
    @available(iOS 13, *)
    func clearRecentSearchData() {
        var snapshot = NSDiffableDataSourceSnapshot<SearchSection, Employee>()
        snapshot.deleteAllItems()
        snapshot.deleteSections([.main])
        delegate?.recentResultsTableView.tableFooterView = UIView()
        recentSearchDiffableDataSource.apply(snapshot, animatingDifferences: true) {
            self.delegate?.recentResultsTableView.isHidden = true
            self.delegate?.searchPromptLabel.isHidden = false
        }
    }
}

class RecentSearchTableViewDelegate: NSObject, UITableViewDelegate {

    weak var searchViewController: SearchViewController?

    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        guard let footerView = tableView.dequeueReusableHeaderFooterView(withIdentifier: "recentSearchFooterView") as? RecentSearchFooterView, !Coordinators.search.cachedRecentResults.isEmpty else { return UIView() }
        footerView.delegate = searchViewController
        return footerView
    }

    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat { 70 }
}

class RecentSearchTableViewDatasource: NSObject, UITableViewDataSource {

    var recentSearchItems: [Employee]?

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let results = recentSearchItems else { return 0 }
        return results.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let results = recentSearchItems, let cell = tableView.dequeueReusableCell(withIdentifier: "searchResultCell") as? SearchResultTableViewCell else {
            return UITableViewCell()
        }
        cell.model = results[indexPath.row]
        cell.titleLabel.text = results[indexPath.row].name
        cell.categoryLabel.text = results[indexPath.row].salary
        return cell
    }


}
