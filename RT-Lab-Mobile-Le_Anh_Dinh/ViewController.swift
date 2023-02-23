//
//  ViewController.swift
//  RT-Lab-Mobile-Le_Anh_Dinh
//
//  Created by Anh Dinh Le on 2023-02-23.
//

import UIKit
import Foundation
import SQLite


class ViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    
    private var items: [ItemToDo] = []
    private var selectFile: [FileName] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        connectDB()
        loadDefaultItems()
        tableView.dataSource = self
        tableView.delegate = self

    }

    
    @IBAction func ImportButton(_ sender: Any) {
      
        copyItem()
        self.performSegue(withIdentifier: "goToNextPage", sender: self)
    }
  

    
    private func copyItem(){
        
        for file in selectFile{
            
            let Path =  "/Users/anhdinhle/Development/Fanshawe_Development/RT-Lab-Mobile-Le_Anh_Dinh/RT-Lab-Mobile-Le_Anh_Dinh/Data"
            let SourcePath = "\(Path)/\(file.Name)"
            
            let Path2 =  "/Users/anhdinhle/Development/Fanshawe_Development/RT-Lab-Mobile-Le_Anh_Dinh/RT-Lab-Mobile-Le_Anh_Dinh/Official-data"
            let DesPath2 = "\(Path2)/\(file.Name)"
            

            do {
               if FileManager.default.fileExists(atPath: DesPath2) {
                try FileManager.default.removeItem(atPath: DesPath2)
                }
                try FileManager.default.copyItem(atPath: SourcePath, toPath: DesPath2)
                
            }
            catch {
                print(error)
            }
        }
    }
    
    
    private func loadDefaultItems() {
        let path = "/Users/anhdinhle/Development/Fanshawe_Development/RT-Lab-Mobile-Le_Anh_Dinh/RT-Lab-Mobile-Le_Anh_Dinh/Data"
        do {
            let itemsInDirectory = try FileManager.default.contentsOfDirectory(atPath: path)

            for file in itemsInDirectory {
                items.append(ItemToDo(FileName: "\(file)"))
            }
        } catch {
             print("failed to read directory")
        }
    }
    
    
    private func connectDB(){
        do {
            let db = try Connection("path/to/db.sqlite3")
            
            let xml = Table("XML")
            let id = Expression<Int64>("Id")
            let value = Expression<String?>("Value")
            let Path = Expression<String>("Path")
            
            try db.run(xml.create { t in
                t.column(id, primaryKey: true)
                t.column(value,unique: true)
                t.column(Path)
            })
        }
        catch
        {
            print(error)
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "goToNextPage"
        {
            let destination = segue.destination as! SecondPage
        }
    }
       
    
}

extension ViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // items is an array of ItemToDo
        return items.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // identifier is defined in that Attribute inspector on the Storyboard
        let cell = tableView.dequeueReusableCell(withIdentifier: "toDoCell", for: indexPath)
        let item = items[indexPath.row]
        
        var content = cell.defaultContentConfiguration()
        content.text = item.FileName
        
        cell.contentConfiguration = content
        
        return cell
    }
}

extension ViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        tableView.deselectRow(at: indexPath, animated: true)

        let isChecked = tableView.cellForRow(at: indexPath)?.accessoryType == .checkmark
        if (isChecked) {
            tableView.cellForRow(at: indexPath)?.accessoryType = .none
                    
        } else {
            tableView.cellForRow(at: indexPath)?.accessoryType = .checkmark
            selectFile.append(FileName(Name: "\(items[indexPath.row].FileName)"))
        }
    }
}



struct ItemToDo {
    let FileName: String
}

struct FileName {
    let Name: String
}
