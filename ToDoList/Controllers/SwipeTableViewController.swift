//
//  SwipeTableViewController.swift
//  ToDoList
//
//  Created by Aries Lam on 6/10/22.
//

import UIKit

class SwipeTableViewController: UITableViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.rowHeight = 50.0
    }
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            deleteRow(at: indexPath)
            tableView.deleteRows(at: [indexPath], with: .fade)
        }
        tableView.reloadData()
    }
    
    func deleteRow(at indexPath: IndexPath){
        //delete a row that get swiped
    }

}
