//
//  AddTreatmentViewController.swift
//  RKRett
//
//  Created by Julien Fieschi on 22/10/2018.
//  Copyright © 2018 AFSR. All rights reserved.
//

import UIKit
import CoreData

class AddTreatmentViewController: UIViewController,UIPickerViewDelegate,UIPickerViewDataSource,UITextFieldDelegate{
    
    var pickerData: [[String]] = [[String]]()
    
    @IBOutlet weak var titleView: UILabel!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var nameTextField: UITextField!
    
    @IBOutlet weak var posologyLabel: UILabel!
    
    @IBOutlet weak var unitLabel: UILabel!
    @IBOutlet weak var unitTextField: UITextField!
    
    @IBOutlet weak var frequencyLabel: UILabel!
    @IBOutlet weak var frequencyPickerView: UIPickerView!
    
    @IBOutlet weak var addButton: UIButton!
    
    @IBAction func addTreatment(_ sender: Any) {
        //Add the treatment to the CoreData
        let appDelegate  = UIApplication.shared.delegate as! AppDelegate
        
        let data = NSManagedObject(entity: NSEntityDescription.entity(forEntityName: "Treatment", in: appDelegate.persistentContainer.viewContext)!, insertInto: appDelegate.persistentContainer.viewContext)
        
        data.setValue(nameTextField.text, forKey: "name")
        data.setValue(unitTextField.text, forKey: "unit")
        
        let posology = Double(pickerData[0][frequencyPickerView.selectedRow(inComponent: 0)])
        let frequency = pickerData[1][frequencyPickerView.selectedRow(inComponent: 1)]
        
        data.setValue(posology, forKey: "posology")
        data.setValue(frequency, forKey: "frequency")
        
        do {
            try data.validateForInsert()
        } catch {
            print(error)
        }
        appDelegate.saveContext()
        
        performSegue(withIdentifier: "unwindToListTreatment", sender: self)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        titleView.text = NSLocalizedString("Add Treatment", comment: "")
        nameLabel.text = NSLocalizedString("Name", comment: "")
        posologyLabel.text = NSLocalizedString("Posology", comment: "")
        unitLabel.text = NSLocalizedString("Unit", comment: "")
        frequencyLabel.text = NSLocalizedString("Frequency", comment: "")
        addButton.setTitle(NSLocalizedString("Add", comment: ""), for: UIControl.State.normal)
        
        pickerData = [["1", "2", "3", "4", "5", "6", "7", "8", "9", "10"],
                      ["x/jour", "x/semaine", "x/mois", "x/an"]]
        
        self.frequencyPickerView.delegate = self
        self.frequencyPickerView.dataSource = self
        
        self.nameTextField.delegate = self
        self.unitTextField.delegate = self
        
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.endEditing(true)
        return false
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return pickerData.count
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return pickerData[component].count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return pickerData[component][row]
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
