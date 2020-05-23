//
//  HowToAvoidInfectionViewController.swift
//  ExamFinalios
//
//  Created by Amandeep Bhatia on 2020-04-18.
//  Copyright © 2020 Amandeep Bhatia. All rights reserved.
//

import UIKit

class HowToAvoidInfectionViewController: UIViewController {

    @IBOutlet weak var moreInfo: UIButton!

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.white
    }

    @IBAction func moreInfo(_ sender: Any) {
        if let url = URL(string: "https://www.who.int/emergencies/diseases/novel-coronavirus-2019/advice-for-public") {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        }
    }
}
