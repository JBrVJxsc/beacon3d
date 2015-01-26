//
//  SettingViewController.swift
//  Beacon3D
//
//  Created by Yu on 1/26/15.
//  Copyright (c) 2015 Xu ZHANG. All rights reserved.
//

import Foundation
import UIKit

class SettingViewController: UITableViewController {
// MARK: - Table view init
	
	override func viewDidLoad() {
		
	}
	
	
	
	
	
	
	
	
	
	@IBAction func doneButtonDidTouch(sender: UIBarButtonItem) {
		self.dismissViewControllerAnimated(true, completion: { () -> Void in
			
		})
	}
	
// MARK: - Table view data source

//	override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
//		return 3
//	}
//	
//	override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//		return 2
//	}
//	
//	override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
//		let cellIdentifier:String = "Cell"
//		var cell:UITableViewCell = tableView.dequeueReusableCellWithIdentifier(cellIdentifier, forIndexPath: indexPath)
//		 as UITableViewCell
//		cell.textLabel?.text = "Test"
//		return cell;
//	}
	
	
//	override func sectionIndexTitlesForTableView(tableView: UITableView) -> [AnyObject]! {
//		return ["Section 1", "Section 2", "Section 3"]
//	}
	
// MARK: - Table view delegate

}