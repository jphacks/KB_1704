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
    var faceimage : UIImage = #imageLiteral(resourceName: "logo.png")
    
    @IBOutlet weak var namelabel: UILabel!
    @IBOutlet weak var jsonLabel: UILabel!
    @IBOutlet weak var companylabel: UILabel!
    @IBOutlet weak var positionlabel: UILabel!
    @IBOutlet weak var tellabel: UILabel!
    @IBOutlet weak var maillabel: UILabel!
    @IBOutlet weak var faceview: UIImageView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let split = self.parameters.components(separatedBy: "department")
        let split2 = split[1].components(separatedBy: "\"")
        let split3 = split2[2].components(separatedBy: "\\")
        print(split3[0])
        
        let split4 = self.parameters.components(separatedBy: "company")
        let split5 = split4[1].components(separatedBy: "\"")
        let split6 = split5[2].components(separatedBy: "\\")
        print(split6[0])
        
        let split7 = self.parameters.components(separatedBy: "TEL")
        let split8 = split7[1].components(separatedBy: "\"")
        let split9 = split8[2].components(separatedBy: "\\")
        print(split9[0])
        
        let split10 = self.parameters.components(separatedBy: "Mail")
        let split11 = split10[1].components(separatedBy: "\"")
        let split12 = split11[2].components(separatedBy: "\\")
        print(split12[0])
        
        let split13 = self.parameters.components(separatedBy: "position")
        let split14 = split13[1].components(separatedBy: "\"")
        let split15 = split14[2].components(separatedBy: "\\")
        print(split15[0])
        
        let split16 = self.parameters.components(separatedBy: "Name")
        let split17 = split16[1].components(separatedBy: "\"")
        let split18 = split17[2].components(separatedBy: "\\")
        print(split18[0])
        
        jsonLabel.text =  "department : " + split3[0]
        companylabel.text = "company : " + split6[0]
        tellabel.text = "TEL : " + split9[0]
        maillabel.text = "Mail : " + split12[0]
        positionlabel.text = "position : " + split15[0]
        namelabel.text = "Name : " + split18[0]
        
        faceview.image = self.faceimage
        
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
