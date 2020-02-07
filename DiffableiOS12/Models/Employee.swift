//
//  Employee.swift
//  DiffableiOS12
//
//  Created by Daniel Yount on 2/7/20.
//  Copyright © 2020 Daniel Yount. All rights reserved.
//

import Foundation


struct Employee: Hashable, Codable {
    let id: String
    let name: String
    let salary: String

    enum CodingKeys: String, CodingKey {
        case id
        case name = "employee_name"
        case salary = "employee_salary"
    }

}
