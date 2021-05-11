//
//  SectionModel.swift
//  DiffableTableViewDataSource
//
//  Created by Hosamane, Vinay K N on 11/05/21.
//

import Foundation

struct SectionModel: Hashable, Equatable {

    var title: String
    var rows: [RowModel]
    
    let uniqueId = UUID()
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(uniqueId)
    }
    
    static func == (lhs: Self, rhs: Self) -> Bool {
        return lhs.uniqueId == rhs.uniqueId
    }

}
