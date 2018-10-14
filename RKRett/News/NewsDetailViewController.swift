//
//  NewsDetailViewController.swift
//  RKRett
//
//  Created by Julien Fieschi on 09/10/2018.
//  Copyright © 2018 AFSR. All rights reserved.
//

import UIKit
import CloudKit

class NewsDetailViewController: UIViewController {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var newsTextField: UITextView!
    
    var news : CKRecord?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = news?.value(forKey: "title") as! String
        
        titleLabel.text = news?.value(forKey: "title") as! String
        newsTextField.text = news?.value(forKey: "news") as! String
        if let asset = news!.value(forKey: "newsImage") as? CKAsset,
            let data = NSData(contentsOf: asset.fileURL),
            let image = UIImage(data: data as Data)
        {
            imageView.image = image
        }

        // Do any additional setup after loading the view.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
