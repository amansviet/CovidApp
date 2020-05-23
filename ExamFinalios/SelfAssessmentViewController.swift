//
//  SelfAssessmentViewController.swift
//  ExamFinalios
//
//  Created by Amandeep Bhatia on 2020-04-18.
//  Copyright © 2020 Amandeep Bhatia. All rights reserved.
//

import UIKit

class SelfAssessmentViewController: UIViewController {

    @IBOutlet weak var feverSwitchButton: UISwitch!
    @IBOutlet weak var coughSwitchButton: UISwitch!
    @IBOutlet weak var swallowingSwitchButton: UISwitch!
    @IBOutlet weak var noneOftheseSwitchButton: UISwitch!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.white

        feverSwitchButton.isOn = false
        coughSwitchButton.isOn = false
        swallowingSwitchButton.isOn = false
        noneOftheseSwitchButton.isOn = false
    }

    @IBAction func sourceFooterLink(_ sender: Any) {
        if let url = URL(string: "https://covid-19.ontario.ca/self-assessment/q2") {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        }
    }

    @IBAction func feverSwitchAction(_ sender: Any) {
        if (feverSwitchButton.isOn){
             noneOftheseSwitchButton.isOn = false
        }
    }

    @IBAction func coughSwitchAction(_ sender: Any) {
        if (coughSwitchButton.isOn){
             noneOftheseSwitchButton.isOn = false
        }
    }

    @IBAction func swallowingSwitchAction(_ sender: Any) {
        if (swallowingSwitchButton.isOn){
             noneOftheseSwitchButton.isOn = false
        }
    }

    @IBAction func noneOfTheseSwitchAction(_ sender: Any) {
        if (noneOftheseSwitchButton.isOn){
             feverSwitchButton.isOn = false
             coughSwitchButton.isOn = false
             swallowingSwitchButton.isOn = false
        }
    }

    @IBAction func checkResults(_ sender: Any) {

        if  (feverSwitchButton.isOn ||  coughSwitchButton.isOn || swallowingSwitchButton.isOn)
        {
            let alert = UIAlertController(title: "Result", message: " You have one or more symptoms of Covid-19. Please see a medical doctor urgently", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Close", style: .default, handler: nil))
            self.present(alert, animated: true)
        }
        else if (noneOftheseSwitchButton.isOn){
            let alert = UIAlertController(title: "Result", message: "You do not have Covid-19 symptoms", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Close", style: .default, handler: nil))
            self.present(alert, animated: true)
        }
        else {
            let alert = UIAlertController(title: "Result", message: "You have not selected any question. Please select one or more options from the symptoms list", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Close", style: .default, handler: nil))
            self.present(alert, animated: true)
        }
    }
}
