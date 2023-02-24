//
//  ViewController.swift
//  RT-Lab-Mobile-Le_Anh_Dinh
//
//  Created by Anh Dinh Le on 2023-02-23.
//

import UIKit
import Foundation
import SQLite



class ViewController: UIViewController, ObservableObject {

    @IBOutlet weak var tableView: UITableView!
    
    private var items: [ItemToDo] = []
    private var selectFile: [FileName] = []
    private var valueParse: [ValueParse] = []
    
    
    let Path =  "/Users/anhdinhle/Development/Fanshawe_Development/RT-Lab-Mobile-Le_Anh_Dinh/RT-Lab-Mobile-Le_Anh_Dinh/Data"
    let DesPath =  "/Users/anhdinhle/Development/Fanshawe_Development/RT-Lab-Mobile-Le_Anh_Dinh/RT-Lab-Mobile-Le_Anh_Dinh/Official-Data"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        createDB()
        loadDefaultItems()
        tableView.dataSource = self
        tableView.delegate = self

    }

    
    @IBAction func ImportButton(_ sender: Any) {
        copyItem()
        ParseXML()
        WriteDB()
        self.performSegue(withIdentifier: "goToNextPage", sender: self)
    }
  

    
     func copyItem(){
        
        for file in selectFile{
            
            let SourcePath = "\(Path)/\(file.Name)"
            let DesPath2 = "\(DesPath)/\(file.Name)"
            

            do {
               if FileManager.default.fileExists(atPath: "\(DesPath2)") {
                try FileManager.default.removeItem(atPath: "\(DesPath2)")
                }
                try FileManager.default.copyItem(atPath: "\(SourcePath)", toPath: "\(DesPath2)")
                
            }
            catch {
                print(error)
            }
        }
    }
    
    
     func loadDefaultItems() {
        
        do {
            let itemsInDirectory = try FileManager.default.contentsOfDirectory(atPath: "\(Path)")

            for file in itemsInDirectory {
                items.append(ItemToDo(FileName: "\(file)"))
            }
        } catch {
             print("failed to read directory")
        }
    }
    private func createDB(){
        let path = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true ).first!
        do {
            
            let db = try Connection("\(path)/db.sqlite7")
            print(db)
            
            let xml = Table("XML")
            let ID = Expression<String?>("ID")
            let Path = Expression<String>("Path")

               try db.run(xml.create { t in
                   t.column(ID,unique: true)
                   t.column(Path)
               })
        }
        catch
        {
            print(error)
        }
    }
    
    private func UpdateDB(uid: String, pathName: String){
        
        let path = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true ).first!
        do {
            
            let db = try Connection("\(path)/db.sqlite7")
            print(db)
            
            let xml = Table("XML")
            let ID = Expression<String?>("ID")
            let Path = Expression<String>("Path")
            let rowid = try db.run(xml.insert(ID <- "\(uid)", Path <- "\(pathName)"))
            
            let rowIterator = try db.prepareRowIterator(xml)
            for user in try Array(rowIterator) {
                print("id: \(user[ID]), email: \(user[Path])")
            }
        }
        catch
        {
            print(error)
        }
    }
    
    private func WriteDB(){
        
        for item in valueParse {
            UpdateDB(uid: item.Value, pathName: DesPath)
        }
    }
    private func ParseXML(){
        
        for item in selectFile {
            loadJson(filename: "\(item.Name)")
        }
    }

    
    func loadJson(filename fileName: String) {
        if let url = Bundle.main.url(forResource: fileName, withExtension: nil,subdirectory: "Official-Data") {
            do {
                let data = try Data(contentsOf: url)
                let decoder = JSONDecoder()
                let jsonData: ValueStruct? = try decoder.decode(ValueStruct.self, from: data)
                valueParse.append(ValueParse(Value: jsonData!.All_in_One_GEN007.meta.instanceID))
            } catch {
                print("error:\(error)")
            }
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

struct ValueParse {
    let Value : String
}
struct ValueStruct: Decodable {
    let All_in_One_GEN007: Content
}

struct Content: Decodable {
    let meta: SubContent
}

struct SubContent: Decodable{
    let instanceID: String
}

