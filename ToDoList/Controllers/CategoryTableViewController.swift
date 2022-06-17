//
//  CategoryTableViewController.swift
//  ToDoList
//
//  Created by Aries Lam on 6/2/22.
//

import UIKit
import RealmSwift
import ChameleonFramework

// Realm

class CategoryTableViewController: SwipeTableViewController {

    
    let realm = try! Realm()
    var categoryArr: Results<Category>?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadCategories()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        guard let navbarColor = navigationController?.navigationBar.barTintColor else{fatalError("navigation con doesn't exist")}

        navigationController?.navigationBar.largeTitleTextAttributes = [NSAttributedString.Key.foregroundColor :ContrastColorOf(navbarColor, returnFlat: true)]

    }
    
    
    @IBAction func addBtnPressed(_ sender: UIBarButtonItem) {
        var textfield = UITextField()
        
        let alert = UIAlertController(title: "Add new category", message: "", preferredStyle: .alert)
          
        alert.addTextField { field in
            textfield = field
            textfield.placeholder = "Add a new Category"
        }
        
        let action = UIAlertAction(title: "Add", style: .default) { (action) in
            let newCate = Category()
            newCate.name = textfield.text!
            newCate.color = UIColor.randomFlat().hexValue()
            self.saveCategories(category: newCate)
        }

        alert.addAction(action)
        
        present(alert, animated: true, completion: nil)
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return categoryArr?.count ?? 1
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "categoryCell", for: indexPath)
        let category = categoryArr?[indexPath.row]
        cell.textLabel?.text = category?.name ?? "No Category added"
        
        if let categoryColor = category?.color{
            guard let textColor = UIColor(hexString: categoryColor) else { fatalError("text has no color")}
            cell.textLabel?.textColor = ContrastColorOf(textColor, returnFlat: true)
        }
        
        cell.backgroundColor = UIColor(hexString: category?.color ?? "007AFF")
        
        return cell
    }
    //MARK: - Delete methods
    override func deleteRow(at indexPath: IndexPath) {
        if let cateToDel = categoryArr?[indexPath.row]{
            do{
                try realm.write{
                    realm.delete(cateToDel)
                }
            }catch{
                print(" Error to delele Category \(error)")
            }
        }
    }

    
    //MARK: - TableView Delegate Methods
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let destinationVC = segue.destination as! ToDoTableViewController
        if let indexPath = tableView.indexPathForSelectedRow{
            destinationVC.selectedCategory = categoryArr?[indexPath.row]
        }
    }
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "GoToItem", sender: self)
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            if let cateToDel = categoryArr?[indexPath.row]{
                do{
                    try realm.write{
                        realm.delete(cateToDel)
                    }
                }catch{
                    print(" Error to delele Category \(error)")
                }
            }

            tableView.deleteRows(at: [indexPath], with: .fade)
        }
        tableView.reloadData()
    }
    
    
    //MARK: - Data Manipulation Methods
    func saveCategories(category: Category){
        do{
            try realm.write{
                realm.add(category)
            }
        }catch{
            print("Error saving context \(error)")
        }
        
        tableView.reloadData()
    }
    
    func  loadCategories(){
        categoryArr = realm.objects(Category.self)
        tableView.reloadData()
    }

    
    
}



/* Core Data
class CategoryTableViewController: UITableViewController {
    
    var categoryArr = [Category]()

    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext

    override func viewDidLoad() {
        super.viewDidLoad()
        loadCategories()
    }

    //MARK: - TableView DataSource Methods
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return categoryArr.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "categoryCell", for: indexPath)
        let category = categoryArr[indexPath.row]
        cell.textLabel?.text = category.name
        return cell
    }
    
    
    //MARK: - TableView Delegate Methods
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let destinationVC = segue.destination as! ToDoTableViewController
        if let indexPath = tableView.indexPathForSelectedRow{
            destinationVC.selectedCategory = categoryArr[indexPath.row]
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "GoToItem", sender: self)
    }
    
    
    
    //MARK: - Add new Categories
    
    @IBAction func addButtonPressed(_ sender: UIBarButtonItem) {
        var textField = UITextField()
        
        let alert = UIAlertController(title: "Add Categories", message: "", preferredStyle: .alert)
        
        alert.addTextField { newCategory in
            newCategory.placeholder = "Create new category"
            textField = newCategory
        }
        
        let action = UIAlertAction(title: "Add Category", style: .default, handler: { action in
            
            let newCate = Category(context: self.context)
            newCate.name = textField.text
            self.categoryArr.append(newCate)
            self.saveCategories()
        })
        alert.addAction(action)
        present(alert, animated: true, completion: nil)
        
    }
    
    //MARK: - Data Manipulation Methods
    
    func saveCategories(){
        do{
            try context.save()
        }catch{
            print("Error saving context \(error)")
        }
        
        tableView.reloadData()
    }
    
    func  loadCategories(with request: NSFetchRequest<Category> = Category.fetchRequest()){
        do{
            categoryArr = try context.fetch(request)
        }catch{
            print("Error loading data from context \(error)")
        }
        tableView.reloadData()
    }
   

}
 */
 
