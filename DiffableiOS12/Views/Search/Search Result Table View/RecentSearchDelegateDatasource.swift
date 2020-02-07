//
//  RecentSearchDelegateDatasource.swift
//  DiffableiOS12
//
//  Created by Daniel Yount on 2/7/20.
//  Copyright © 2020 Daniel Yount. All rights reserved.
//

import Foundation
import UIKit

class RecentSearchTableViewDelegate: NSObject, UITableViewDelegate {
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        UIView()
    }
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
