//
//  SecondPage.swift
//  RT-Lab-Mobile-Le_Anh_Dinh
//
//  Created by Anh Dinh Le on 2023-02-23.
//

import UIKit
import Foundation
import SQLite

class SecondPage: UIViewController {

    @IBOutlet weak var TableView: UITableView!
    
    private var items: [Items] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()

        TableView.dataSource = self
        TableView.delegate = self
        UpdateDB()
    }
    
    private func UpdateDB(){
        
        let path = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true ).first!
        do {
            
            let db = try Connection("\(path)/db.sqlite7")
            print(db)
            
            let xml = Table("XML")
            let ID = Expression<String?>("ID")
            let Path = Expression<String>("Path")

            
            let rowIterator = try db.prepareRowIterator(xml)
            for user in try Array(rowIterator) {
                items.append(Items(ID: "\(user[ID])", Path: "\(user[Path])"))
            }
        }
        catch
        {
            print(error)
        }
    }

}
extension SecondPage: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // items is an array of ItemToDo
        return items.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // identifier is defined in that Attribute inspector on the Storyboard
        let cell = tableView.dequeueReusableCell(withIdentifier: "toDoCell", for: indexPath)
        let item = items[indexPath.row]
        
        var content = cell.defaultContentConfiguration()
        content.text = item.ID
        content.secondaryText = item.Path

        
        
        cell.contentConfiguration = content
        
        return cell
    }
}

extension SecondPage: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        tableView.deselectRow(at: indexPath, animated: true)

        let isChecked = tableView.cellForRow(at: indexPath)?.accessoryType == .checkmark
        if (isChecked) {
            tableView.cellForRow(at: indexPath)?.accessoryType = .none
                    
        } else {
            tableView.cellForRow(at: indexPath)?.accessoryType = .checkmark
        }
    }
}
struct Items {
    let ID: String
    let Path: String
}
