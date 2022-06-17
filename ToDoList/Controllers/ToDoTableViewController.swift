//
//  ToDoTableViewController.swift
//  ToDoList
//
//  Created by Aries Lam on 5/25/22.
//






import UIKit
import RealmSwift
import SwiftUI
import ChameleonFramework

class ToDoTableViewController: SwipeTableViewController{
    
    @IBOutlet weak var searchBar: UISearchBar!
    var todoItems : Results<Item>?
    let realm = try! Realm()
    
    var selectedCategory : Category? {
        didSet{
            loadItems()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        searchBar.delegate = self
        title = selectedCategory?.name
    }
    
    override func viewWillAppear(_ animated: Bool) {
        if let colorHex = selectedCategory?.color{
            guard let navBar = navigationController?.navigationBar, let navBarColor = UIColor(hexString: colorHex) else{fatalError("nav con doesn't exist")}
            navBar.backgroundColor = navBarColor
            navBar.tintColor = ContrastColorOf(navBarColor, returnFlat: true)
            navBar.largeTitleTextAttributes = [NSAttributedString.Key.foregroundColor: ContrastColorOf(navBarColor, returnFlat: true)]
            searchBar.barTintColor  = navBarColor
        }
    }

    // MARK: - Table view data source

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return todoItems?.count ?? 1
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ToDoCell", for: indexPath)
        if let item = todoItems?[indexPath.row]{
            cell.textLabel?.text = item.title
            
            if let color = UIColor(hexString: selectedCategory!.color)?.darken(byPercentage:CGFloat(indexPath.row) / CGFloat(todoItems!.count)){
                cell.backgroundColor = color
                cell.textLabel?.textColor = ContrastColorOf(color, returnFlat: true)
            }
         
            //value = condition ? valueIfTrue : valueIfFalse
            cell.accessoryType = item.checkMark ? .checkmark : .none
        }else{
            cell.textLabel?.text = "No item added"
        }

        return cell
    }
    
    //MARK: - TableViewDelegate
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if let selectedItem = todoItems?[indexPath.row]{
            do{
                try realm.write({
                    selectedItem.checkMark = !selectedItem.checkMark
                })
            }catch{
                print("Error saving done status, \(error)")
            }
           
        }
        tableView.reloadData()
        
        tableView.deselectRow(at: indexPath, animated: true)
    }
//    MARK: - delete selected row method
    override  func deleteRow(at indexPath: IndexPath) {
        if let itemToDel = todoItems?[indexPath.row]{
            do{
                try realm.write{
                    realm.delete(itemToDel)
                }
            }catch{
                print(" Error to delele Category \(error)")
            }
        }
    }

    //MARK: - Add new items
    
    @IBAction func addBtn(_ sender: UIBarButtonItem) {
        var textField = UITextField()
        
        let alert = UIAlertController(title: "Add New ToDo Item", message: "", preferredStyle: .alert)
        
        alert.addTextField { newItem in
            newItem.placeholder = "Create new item"
            textField = newItem
        }
            
        let action = UIAlertAction(title: "Add Item", style: .default) { [self]action in
            if let currentCategory = selectedCategory{
                do{
                    try realm.write {
                        let newItem = Item()
                        newItem.title = textField.text!
                        newItem.dateCreated = Date()
                        currentCategory.items.append(newItem)
                    }
                } catch{
                    print("Error saving new items,\(error)")
                }
            }
            tableView.reloadData()

        }
        alert.addAction(action)
        self.present(alert, animated: true, completion: nil)
 
    }
    
    // give a default value for parameter so that it can be called without passing a parameter => it is passed a default parameter
    func loadItems(){
        todoItems = selectedCategory?.items.sorted(byKeyPath: "title", ascending: true)
        
        tableView.reloadData()
    }
}

extension ToDoTableViewController: UISearchBarDelegate{
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        
        todoItems = todoItems?.filter("title CONTAINS[cd] %@", searchBar.text!).sorted(byKeyPath: "dateCreated", ascending: true)
        tableView.reloadData()

    }
    
    // go back to the origin list after done searching
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchBar.text?.count == 0{
            loadItems()
        //hide the keyboard when search bar is empty
            DispatchQueue.main.async {
                searchBar.resignFirstResponder()
            }
        }
    }
    
    
}


/*
class ToDoTableViewController: UITableViewController{
    
    @IBOutlet weak var searchBar: UISearchBar!
    var itemArr = [Item]()
    
    var selectedCategory : Category? {
        didSet{
            loadItems()
        }
    }
    
    /* save a small data in p.list, this should not be used as a database
        let defaults = UserDefaults.standard */
    
    // creating a custom plist file where to save custom data to the app
    /* let dataFilePath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first?.appendingPathComponent("Item.plist")*/
    
    //get the variable from appDelagate by a singleton
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    override func viewDidLoad() {
        super.viewDidLoad()
        searchBar.delegate = self
        loadItems()

    }

    // MARK: - Table view data source

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        
        return itemArr.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ToDoCell", for: indexPath)
        let item = itemArr[indexPath.row]
        
        cell.textLabel?.text = item.title
        
        //checkmark based on array.title
            //option1: Ternary operator
        cell.accessoryType = item.checkMark ? .checkmark : .none
        
           /* option2: if statement
        if item.checkMark == true{
            cell.accessoryType = .checkmark
        }else{
            cell.accessoryType = .none
        } */
        
        return cell
    }
    
    //MARK: - TableViewDelegate
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        
        //change checkMark from false to true and reverse
        itemArr[indexPath.row].checkMark = !itemArr[indexPath.row].checkMark
        
        //delete data from the array and coredata
//        context.delete(itemArr[indexPath.row])
//        itemArr.remove(at: indexPath.row)
        
        saveDatas()
        
        /* or using if statement to change
        if itemArr[indexPath.row].checkMark == false{
            itemArr[indexPath.row].checkMark = true
        }else{
            itemArr[indexPath.row].checkMark = false
        } */
        
        
        /* set the cell with a checkmark when click on it
        if tableView.cellForRow(at: indexPath)?.accessoryType == .checkmark{
            tableView.cellForRow(at: indexPath)?.accessoryType = .none
        }else{
            tableView.cellForRow(at: indexPath)?.accessoryType = .checkmark
        } */
        
        // reload the data on the tableView
        
        
        tableView.deselectRow(at: indexPath, animated: true)
        
    }
    

    //MARK - Add new items
    
    @IBAction func addBtn(_ sender: UIBarButtonItem) {
        var textField = UITextField()
        
        let alert = UIAlertController(title: "Add New ToDo Item", message: "", preferredStyle: .alert)
        
        alert.addTextField { newItem in
            newItem.placeholder = "Create new item"
            textField = newItem
        }
            
        let action = UIAlertAction(title: "Add Item", style: .default) {action in

                let newItem = Item(context: self.context)
                newItem.title = textField.text
                newItem.checkMark = false
                newItem.parentCategory = self.selectedCategory
            
                self.itemArr.append(newItem)
                
                self.saveDatas()

        }
        alert.addAction(action)
        self.present(alert, animated: true, completion: nil)
 
    }
    
    func saveDatas(){
        // encode the itemArr into PropertyList
        do{
            //save data in context to CoreData
           try context.save()
        }catch{
           print("error saving context \(error)")
        }
        
        // reload the data on the tableView
        tableView.reloadData()
    }
    
    // give a default value for parameter so that it can be called without passing a parameter => it is passed a default parameter
    func loadItems(with request: NSFetchRequest<Item> = Item.fetchRequest(), with predicate: NSPredicate? = nil){
        //request data from CoreData
        let categoryPredicate = NSPredicate(format: "parentCategory.name MATCHES %@", selectedCategory!.name!)
        
        if let additionPredicate = predicate{
            request.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [categoryPredicate, additionPredicate])
        }else{
            request.predicate = categoryPredicate
        }
        do{
            itemArr = try context.fetch(request)
        }catch{
            print("Error fetching data from context \(error)")
        }
        
        tableView.reloadData()
    }
}

extension ToDoTableViewController: UISearchBarDelegate{
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        //request data from CoreData
        let request : NSFetchRequest<Item> = Item.fetchRequest()
        
        //search for the title that contains the word we typed in searchbar
        let wordPredicate = NSPredicate(format: "title CONTAINS[cd] %@", searchBar.text!)
        //get the request with the word that wants to search
        request.predicate = wordPredicate
        
        //sort the results in order
        let sortDescriptor = NSSortDescriptor(key: "title", ascending: true)
        request.sortDescriptors = [sortDescriptor]
        
        //load data to context with a request after passing word to search and sorted
        loadItems(with: request, with: wordPredicate)

    }
    
    // go back to the origin list after done searching
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchBar.text?.count == 0{
            loadItems()
        
            DispatchQueue.main.async {
                searchBar.resignFirstResponder()
            }
        }
    }
    
    
}
*/
