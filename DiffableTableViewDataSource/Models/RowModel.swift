//
//  RowModel.swift
//  DiffableTableViewDataSource
//
//  Created by Hosamane, Vinay K N on 11/05/21.
//

import Foundation

enum RowType {
    case A
    case B
}

struct RowModel: Hashable {

    var name: String
    var detail: String
    var type: RowType

}
