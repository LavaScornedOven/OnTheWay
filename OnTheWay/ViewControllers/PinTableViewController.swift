//
//  PinTableTableViewController.swift
//  OnTheWay
//
//  Created by Vedran Novoselac on 03/03/2020.
//  Copyright © 2020 Vedran Novoselac. All rights reserved.
//

import UIKit

class PinTableViewController: UITableViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        tableView.reloadData()
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return SessionModel.students.count
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath)
        
        if let url = URL(string: cell?.detailTextLabel?.text ?? "") {
            openUrlInBrowser(request: url, completion: nil)
        }
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "studentInfoCell", for: indexPath)

        let info = SessionModel.students[indexPath.row]
        
        cell.textLabel?.text = "\(info.firstName) \(info.lastName)"
        cell.detailTextLabel?.text = info.mediaURL

        return cell
    }
}
