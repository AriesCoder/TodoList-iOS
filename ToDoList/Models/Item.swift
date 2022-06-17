//
//  Data.swift
//  ToDoList
//
//  Created by Aries Lam on 6/6/22.
//

import Foundation
import RealmSwift

class Item: Object{
    
    @objc dynamic var title: String = ""
    @objc dynamic var checkMark: Bool = false
    var parentCategory = LinkingObjects(fromType: Category.self, property: "items")
    @objc dynamic var dateCreated: Date?
    
}
