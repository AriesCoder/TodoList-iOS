//
//  Category.swift
//  ToDoList
//
//  Created by Aries Lam on 6/6/22.
//

import Foundation
import RealmSwift

class Category: Object{
    @objc dynamic var name = ""
    @objc dynamic var color: String = ""
    var items = List<Item>()
}
