//
//  NewsTableViewController.swift
//  RKRett
//
//  Created by Julien Fieschi on 08/10/2018.
//  Copyright © 2018 AFSR. All rights reserved.
//

import UIKit
import CloudKit

class NewsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    var news = [CKRecord]()
    let publicDB = CKContainer.default().publicCloudDatabase
    
    let sections = ["Learn More...","News"]
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet var newsView: UIView!
   
    
    
    @IBOutlet weak var activityLabel: UILabel!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    
    @IBAction func refreshAction(_ sender: Any) {
        fetchNews()
        updateView()
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        updateView()
    }
    
    private func setupView() {
        tableView.isHidden = true
        activityLabel.isHidden = false
        activityLabel.text = "Fetching news from server..."
        activityIndicator.startAnimating()
    }
    
    private func fetchNews(){
        let predicate = NSPredicate(value: true)
        let query = CKQuery(recordType: "News", predicate: predicate)
        
        self.publicDB.perform(query, inZoneWith: nil, completionHandler: {
            (records, error) -> Void in
            guard let records = records else {
                print("Error querying records: ", error)
                return
            }
            print("Found \(records.count) records")
            self.news = []
            self.news.append(contentsOf: records)
            OperationQueue.main.addOperation {
                self.updateView()
                self.tableView.reloadData()
            }
            print("Found \(self.news.count) records")
        })
    }
    
    private func updateView() {
        let hasRecords = news.count > 0
        activityLabel.isHidden = hasRecords
        tableView.isHidden = !hasRecords
        if hasRecords {
            activityIndicator.stopAnimating()
            activityIndicator.isHidden = hasRecords
        }
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
        
        self.title = "News"
        
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 140
        
        setupView()
        fetchNews()
        
        
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
    }


    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch indexPath.section {
        case 0:
            //Learn More Section
            tableView.deselectRow(at: indexPath, animated: true)
        default:
            //News Section
            tableView.deselectRow(at: indexPath, animated: true)
        }
    }
    

    
    // MARK: - Table view data source
    
    func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return sections.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        switch (section){
        case 0:
            return 1
        default:
            print(news.count)
            return news.count ?? 0
        }
    }
    
    //    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
    //        let headerView = UIView()
    //
    //        return headerView
    //    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "detailNewsSegue"{
            if let destinationVC = segue.destination as? NewsDetailViewController {
                destinationVC.news = self.news[(self.tableView.indexPathForSelectedRow?.row)!]
            }
        }
        
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        var sectionName = String()
        switch (section) {
        case 0 :
            //Learn More
            sectionName = "Learn More..."
        case 1 :
            //News
            sectionName = "News"
        default:
            break
        }
        return sectionName
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        //Core Data
        
        // Configure the cell...
        if indexPath.section == 0{
            let cell = tableView.dequeueReusableCell(withIdentifier: "learnMoreCell", for: indexPath) as! LearnMoreTableViewCell
            cell.frame.size.height = 140
            return cell
        }else{
            let cell = tableView.dequeueReusableCell(withIdentifier: "newsCell", for: indexPath) as! NewsTableViewCell
            let title = news[indexPath.row].value(forKey: "title") as! String
            let newsFeed = news[indexPath.row].value(forKey: "news") as! String
            
            let newsString = NSMutableAttributedString(string:newsFeed)
            
            let attrs = [NSAttributedString.Key.font : UIFont.boldSystemFont(ofSize: 15)]
            let boldTitle = NSMutableAttributedString(string:title, attributes:attrs)
            
            let attributedString = NSMutableAttributedString(attributedString: boldTitle)
            attributedString.append(NSMutableAttributedString(string:"\n"))
            attributedString.append(newsString)
            
            cell.newsTextView.attributedText = attributedString
            
            cell.newsTextView.textContainer.lineBreakMode = NSLineBreakMode.byTruncatingTail
            
            if let asset = news[indexPath.row].value(forKey: "newsImage") as? CKAsset,
                let data = NSData(contentsOf: asset.fileURL),
                let image = UIImage(data: data as Data)
            {
                cell.newsImage?.image = image
            }
            cell.frame.size.height = 125
            return cell
        }
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
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
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
