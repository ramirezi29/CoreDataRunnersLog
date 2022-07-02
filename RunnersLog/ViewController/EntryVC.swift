//
//  EntryVC.swift
//  RunnersLog
//
//  Created by Ivan Ramirez on 1/26/22.
//

import UIKit


class EntryVC: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var randomButton: UIButton!
    @IBOutlet weak var addButton: UIButton!
    @IBOutlet weak var sortButton: UIButton!
    @IBOutlet weak var myTableView: UITableView!
    
    var isAscending: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        myTableView.delegate = self
        myTableView.dataSource = self
        
        // Notification Center
        NotificationCenter.default.addObserver( self, selector: #selector(self.refreshData(notification:)), name: Notification.Name("RefreshNotificationIdentifier"), object: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    @objc func refreshData(notification: Notification) {
        myTableView.reloadData()
    }
    
    
    //MARK: - Table View Data Source
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return EntryController.shared.fetchedEntries.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = myTableView.dequeueReusableCell(withIdentifier: "entryCell", for: indexPath) as? EntryCell else {
            return UITableViewCell()
        }
        
        let entry = EntryController.shared.fetchedEntries[indexPath.row]
        cell.entry = entry
        
        return cell
    }
    
    // MARK: - Navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let destinationVC = segue.destination as? DetailVC, let cell = sender as? EntryCell, let indexPath = self.myTableView.indexPath(for: cell) else {
            return
        }
        
        let entry = EntryController.shared.fetchedEntries[indexPath.row]
        
        destinationVC.entry = entry
    }
    
    
    @IBAction func sortButtonTapped(_ sender: Any) {
        if isAscending == false {
            EntryController.shared.sortEntries(ascending: isAscending)
            isAscending = true
        } else {
            EntryController.shared.sortEntries(ascending: isAscending)
            isAscending = false
        }
        myTableView.reloadData()
    }
    
    
    @IBAction func randomButtonTapped(_ sender: Any) {
        EntryController.shared.deleteEverything()
        myTableView.reloadData()
    }
    
}
