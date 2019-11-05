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
        self.addLeftButton()
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        for (index,categoryData) in categoryList.enumerated() {
			
			var selectTag = true
			
			
			for category in categoryData.categoryData {
				
				if self.selectedValues.contains(category){
					
				}else{
					
					selectTag = false
					
				}
				
			}
			if selectTag {
				categoryList[index].selectedAll = true
			}else{
				categoryList[index].selectedAll = false
			}
			
        }
    }
    
    func addLeftButton() {
        let rightButton: UIBarButtonItem = UIBarButtonItem.init(title: "Done", style: UIBarButtonItem.Style.plain, target: self, action: #selector(self.addLeftAction(sender:)))
        self.navigationItem.leftBarButtonItem = rightButton
    }
    
    func addRightButton() {
        
        let rightButton: UIBarButtonItem = UIBarButtonItem.init(title: "Clear", style: UIBarButtonItem.Style.plain, target: self, action: #selector(self.clearAction(sender:)))
        self.navigationItem.rightBarButtonItem = rightButton
    }
    
    @IBAction func addLeftAction(sender: UIBarButtonItem){
        self.delegateCategory.selectedArray(array: self.selectedValues)
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func clearAction(sender: UIBarButtonItem){
        self.selectedValues.removeAll()
        let categoryPartialList = categoryList.map { (category) -> Section in
            var categoryPartial = category
            categoryPartial.selectedAll = false
            return categoryPartial
        }
        categoryList.removeAll()
        categoryList.append(contentsOf: categoryPartialList)
        self.tableView.reloadData()
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
        cell.titleLabel.text = categoryList[indexPath.section].categoryData[indexPath.row]
        // Configure the cell...
        
        if self.selectedValues.contains(cell.titleLabel.text!){
            cell.accessoryType = .checkmark
            cell.titleLabel.textColor = UIColor.systemBlue
			cell.titleLabel.font = UIFont.systemFont(ofSize: 17, weight: .bold)
        }else{
            cell.accessoryType = .none
            cell.titleLabel.textColor = GetForeColor()
			cell.titleLabel.font = UIFont.systemFont(ofSize: 17, weight: .regular)
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
        header.selectedAll = categoryList[section].selectedAll
//        if categoryList[section].categoryData.contains(where: { (category) -> Bool in
//
//            category.
//
//        }) {
//
//        }
        
        header.customInit(title: categoryList[section].categoryTitle!.rawValue, section: section, delegate: self)
        // header.backgroundColor = UIColor.clear
        
        return header
        
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat{
        
        return 60.0
        
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let cell = self.tableView.cellForRow(at: indexPath) as! catCell
        cell.accessoryType = .checkmark
        cell.titleLabel.textColor = UIColor.systemBlue
		cell.titleLabel.font = UIFont.systemFont(ofSize: 17, weight: .bold)
        let category = categoryList[indexPath.section].categoryData[indexPath.row]
        self.selectedValues.append(category)
    }
    override func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath){
        let cell = self.tableView.cellForRow(at: indexPath) as! catCell
        cell.accessoryType = .none
        cell.titleLabel.textColor =	GetForeColor()
		cell.titleLabel.font = UIFont.systemFont(ofSize: 17, weight: .regular)
        let category = categoryList[indexPath.section].categoryData[indexPath.row]
        let index = self.selectedValues.index(of: category)
        self.selectedValues.remove(at: index!)
    }
    
    func toggleSection(header: ExpandableHeaderView, section: Int) {
        categoryList[section].expanded = !categoryList[section].expanded
            self.tableView.beginUpdates()
            self.tableView .reloadSections(IndexSet.init(integer: section), with: .fade)
            self.tableView.endUpdates()
    }
    
    func selectAllSection(header: ExpandableHeaderView, section: Int, selected: Bool) {
        
        categoryList[section].selectedAll = !categoryList[section].selectedAll
        
        if categoryList[section].selectedAll {
            
            for category in categoryList[section].categoryData {
                
                
                if self.selectedValues.contains(category){
                    
                }else{
                   self.selectedValues.append(category)
                }
                
            }
            
            
            
        }else{
            
            for category in categoryList[section].categoryData {
                
                
                if self.selectedValues.contains(category){
                    let index = selectedValues.index(of: category)
                    self.selectedValues.remove(at: index!)
                    
                }else{
                   
                }
                
            }
            
        }
        
        
        
        self.tableView.reloadData()
         
    }
    
    func customizeNavigationBar() {
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        self.navigationController?.navigationBar.shadowImage = UIImage()
        self.navigationController?.navigationBar.isTranslucent = false
        self.navigationController?.navigationBar.tintColor = UIColor.systemBlue
        
		if #available(iOS 13.0, *) {
			self.navigationController?.navigationBar.barTintColor = UIColor.secondarySystemBackground
		} else {
			self.navigationController?.navigationBar.barTintColor = UIColor(red: 239.0/255.0, green: 239.0/255.0, blue: 244.0/255.0, alpha: 1.0)
		}
        //
        self.navigationController?.view.backgroundColor = UIColor.black
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
