//
//  ViewController.swift
//  RT-Lab-Mobile-Le_Anh_Dinh
//
//  Created by Anh Dinh Le on 2023-02-23.
//

import UIKit
import Foundation

class ViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    
    private var items: [ItemToDo] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        loadDefaultItems()
        tableView.dataSource = self
        tableView.delegate = self
        
    }

    @IBAction func ImportButton(_ sender: UIBarButtonItem) {
        
        
        
        
        self.performSegue(withIdentifier: "goToNextPage", sender: self)
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
        }
    }
}


struct ItemToDo {
    let FileName: String
}
