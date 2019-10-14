//
//  CategoryTVC.swift
//  Ambassadoor Business
//
//  Created by K Saravana Kumar on 07/08/19.
//  Copyright © 2019 Tesseract Freelance, LLC. All rights reserved.
//

import UIKit

protocol selectedCategoryDelegate {
    func selectedArray(array: [String])
}

class catCell: UITableViewCell {
    @IBOutlet weak var titleLabel: UILabel!
}

class CategoryTVC: UITableViewController,ExpandableHeaderViewDelegate {
    
    
    var categoryList = [Section]()
    var selectedValues = [String]()
    var delegateCategory: selectedCategoryDelegate!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        categoryListArray = [Section]()
        categoryList.append(contentsOf: categoryListArray)
        self.customizeNavigationBar()
        self.addRightButton()
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
    }
    
    func addRightButton() {
        
        let rightButton: UIBarButtonItem = UIBarButtonItem.init(title: "Done", style: UIBarButtonItem.Style.plain, target: self, action: #selector(self.addRightAction(sender:)))
        self.navigationItem.rightBarButtonItem = rightButton
    }
    
    @IBAction func addRightAction(sender: UIBarButtonItem){
        self.navigationController?.popViewController(animated: true)
        self.delegateCategory.selectedArray(array: self.selectedValues)
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return categoryList.count
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return categoryList[section].categoryData.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "catCell", for: indexPath) as! catCell
        cell.titleLabel.text = categoryList[indexPath.section].categoryData[indexPath.row].rawValue
        // Configure the cell...
        
        if self.selectedValues.contains(cell.titleLabel.text!){
            cell.accessoryType = .checkmark
        }else{
            cell.accessoryType = .none
        }

        return cell
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat{
        
        if (categoryList[indexPath.section].expanded){
            return 52.0
        }
        else {
            return 0.0
        }
        
    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        let header = ExpandableHeaderView()
        // header.backgroundColor = UIColor.clear
        header.expandBool = categoryList[section].expanded
        header.customInit(title: categoryList[section].categoryTitle!.rawValue, section: section, delegate: self)
        // header.backgroundColor = UIColor.clear
        
        return header
        
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat{
        
        return 60.0
        
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let cell = self.tableView.cellForRow(at: indexPath)
        cell?.accessoryType = .checkmark
        let category = categoryList[indexPath.section].categoryData[indexPath.row].rawValue
        self.selectedValues.append(category)
    }
    override func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath){
        let cell = self.tableView.cellForRow(at: indexPath)
        cell?.accessoryType = .none
        let category = categoryList[indexPath.section].categoryData[indexPath.row].rawValue
        let index = self.selectedValues.index(of: category)
        self.selectedValues.remove(at: index!)
    }
    
    func toggleSection(header: ExpandableHeaderView, section: Int) {
        categoryList[section].expanded = !categoryList[section].expanded
        
        
        self.tableView.beginUpdates()
        self.tableView.reloadData()
        for i in 0 ..< categoryList[section].categoryData.count {
            self.tableView.reloadRows(at: [IndexPath(row: i, section: section)], with: .automatic)
        }
       self.tableView.endUpdates()
    }
    
    func customizeNavigationBar() {
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        self.navigationController?.navigationBar.shadowImage = UIImage()
        self.navigationController?.navigationBar.isTranslucent = true
        self.navigationController?.navigationBar.tintColor = UIColor.blue
        self.navigationController?.navigationBar.barTintColor = UIColor.white
        self.navigationController?.navigationBar.titleTextAttributes =
            [NSAttributedString.Key.foregroundColor:UIColor.black, NSAttributedString.Key.font:UIFont.systemFont(ofSize: 14.0)]
        self.navigationController?.view.backgroundColor = UIColor.clear
    }
    
    
    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
