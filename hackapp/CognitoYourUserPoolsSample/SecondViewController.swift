//
//  SecondViewController.swift
//  CognitoYourUserPoolsSample
//
//  Created by 吉川 寛樹 on 2017/10/22.
//  Copyright © 2017年 Dubal, Rohan. All rights reserved.
//

import UIKit

class SecondViewController: UIViewController {

    var parameters: String = ""
    
    @IBOutlet weak var jsonLabel: UILabel!
    @IBOutlet weak var companylabel: UILabel!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let split = self.parameters.components(separatedBy: "department")
        let split2 = split[1].components(separatedBy: "\"")
        let split3 = split2[2].components(separatedBy: "\\")
        print(split3[0])
        
        let split4 = self.parameters.components(separatedBy: "company")
        let split5 = split[1].components(separatedBy: "\"")
        let split6 = split2[2].components(separatedBy: "\\")
        print(split6[0])
        
        jsonLabel.text =  "department : " + split3[0]
        
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
