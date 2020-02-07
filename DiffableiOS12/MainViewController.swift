//
//  ViewController.swift
//  DiffableiOS12
//
//  Created by Daniel Yount on 2/7/20.
//  Copyright © 2020 Daniel Yount. All rights reserved.
//

import UIKit

class MainViewController: UIViewController {

    @IBOutlet weak var searchButton: UIBarButtonItem!

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
    @IBAction func presentSearchViewController(_ sender: Any) {
        guard let viewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "searchViewController") as? SearchViewController else { return }
        viewController.modalPresentationStyle = .popover
        viewController.popoverPresentationController?.barButtonItem = searchButton
        present(viewController, animated: true)
    }


}

