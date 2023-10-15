//
//  ToDoTableViewController.swift
//  To-Do-List
//
//  Created by Vlad Kugan on 15.10.23.
//

import UIKit
import CoreData
    
class ToDoTableViewController: UITableViewController, TaskTableViewCellDelegate {
   
    func didTapButtonInCell(_ cell: TaskTableViewCell) {
        guard let indexPath = tableView.indexPath(for: cell) else {
            return
        }

        let task = tasks[indexPath.row]
        let managedContext = task.managedObjectContext
        
        if cell.buttonCell.currentImage == UIImage(named: "redCheck") {
            cell.buttonCell.setImage(UIImage(named: "greenCheck"), for: .normal)
            task.setValue(true, forKey: "status_task")

            let attributeString = NSMutableAttributedString(string: cell.textCell.text ?? "")
            attributeString.addAttribute(NSAttributedString.Key.strikethroughStyle,
                                         value: NSUnderlineStyle.single.rawValue,
                                         range: NSMakeRange(0, attributeString.length))
            cell.textCell.attributedText = attributeString
        } else {
            cell.buttonCell.setImage(UIImage(named: "redCheck"), for: .normal)
            task.setValue(false, forKey: "status_task")

            let attributeString = NSMutableAttributedString(string: cell.textCell.text ?? "")
            attributeString.addAttribute(NSAttributedString.Key.strikethroughStyle,
                                         value: 0,
                                         range: NSMakeRange(0, attributeString.length))
            cell.textCell.attributedText = attributeString
        }

        do {
            try managedContext?.save()
        } catch let error as NSError {
            print("Could not save. \(error), \(error.userInfo)")
        }
    }

    var tasks = [NSManagedObject]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tableView.register(UINib(nibName: String(describing: TaskTableViewCell.self), bundle: nil), forCellReuseIdentifier: String(describing: TaskTableViewCell.self))
        
        let addButton = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addButtonTapped))
        self.navigationItem.rightBarButtonItem = addButton

    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            return
        }
        
        let managedContext = appDelegate.persistentContainer.viewContext
        
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "Tasks")
        
        do {
            let fetchedResults = try managedContext.fetch(fetchRequest)
            tasks = fetchedResults
        } catch let error as NSError {
            print("Could not fetch. \(error), \(error.userInfo)")
        }
    }
    
    
    // MARK: - Table view data source
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tasks.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: TaskTableViewCell.self), for: indexPath) as! TaskTableViewCell

        cell.delegate = self
        let task = tasks[indexPath.row]
        cell.textCell!.text = task.value(forKey: "text_task") as? String
        if let taskStatus = task.value(forKey: "status_task") as? Bool, taskStatus {
            cell.buttonCell.setImage(UIImage(named: "greenCheck"), for: .normal)
            let attributeString = NSMutableAttributedString(string: cell.textCell.text ?? "")
            attributeString.addAttribute(NSAttributedString.Key.strikethroughStyle,
                                         value: NSUnderlineStyle.single.rawValue,
                                         range: NSMakeRange(0, attributeString.length))
            cell.textCell.attributedText = attributeString

        }

        cell.buttonCell.addTarget(cell, action: #selector(cell.buttonTapped(_:)), for: .touchUpInside)
        
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let taskToDelete = tasks[indexPath.row]
            if let managedContext = taskToDelete.managedObjectContext {
                managedContext.delete(taskToDelete)
                
                do {
                    try managedContext.save()
                } catch let error as NSError {
                    print("Could not delete. \(error), \(error.userInfo)")
                }
            }
            tasks.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .fade)
        }
    }

    
    // MARK: - Function
    
    @objc func addButtonTapped(){
        let alert = UIAlertController(title: "New task",
              message: "Add a new task",
                                      preferredStyle: .alert)
         
          let saveAction = UIAlertAction(title: "Save",
                                         style: .default) { (action: UIAlertAction!) -> Void in
         
            let textField = alert.textFields![0]
            self.saveTask(textTask: textField.text ?? "")
            self.tableView.reloadData()
          }
          let cancelAction = UIAlertAction(title: "Cancel",
                                           style: .default) { (action: UIAlertAction!) -> Void in
          }
        alert.addTextField {
            (textField: UITextField!) -> Void in
          }
          alert.addAction(saveAction)
          alert.addAction(cancelAction)
        present(alert,
              animated: true,
              completion: nil)
    }
    
   
    func saveTask(textTask: String) {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            return
        }
        let managedContext = appDelegate.persistentContainer.viewContext
        guard let entity = NSEntityDescription.entity(forEntityName: "Tasks", in: managedContext) else {
            return
        }
        let task = NSManagedObject(entity: entity, insertInto: managedContext)
        task.setValue(textTask, forKey: "text_task")
        task.setValue(false, forKey: "status_task")
        task.setValue(Date(), forKey: "date_created")
        
        do {
            try managedContext.save()
        } catch let error as NSError {
            print("Could not save. \(error), \(error.userInfo)")
        }
        
        tasks.append(task)
    }
    


}
