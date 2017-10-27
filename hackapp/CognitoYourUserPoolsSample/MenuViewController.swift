//
//  MenuViewController.swift
//  CognitoYourUserPoolsSample
//
//  Created by 吉川 寛樹 on 2017/10/22.
//  Copyright © 2017年 Dubal, Rohan. All rights reserved.
//

import UIKit
import Foundation
import AWSCognitoIdentityProvider

class MenuViewController: UIViewController {

    var response: AWSCognitoIdentityUserGetDetailsResponse?
    var user: AWSCognitoIdentityUser?
    var pool: AWSCognitoIdentityUserPool?
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //editbtn.imageView?.contentMode = UIViewContentMode.scaleAspectFill;
        //camerabtn.imageView?.contentMode = UIViewContentMode.scaleAspectFill;
        //allbtn.imageView?.contentMode = UIViewContentMode.scaleAspectFill;
        self.pool = AWSCognitoIdentityUserPool(forKey: AWSCognitoUserPoolsSignInProviderKey)
        if (self.user == nil) {
            self.user = self.pool?.currentUser()
        }
        self.refresh()

        // Do any additional setup after loading the view.
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        //self.navigationController?.setToolbarHidden(true, animated: true)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        //self.navigationController?.setToolbarHidden(false, animated: true)
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
    
    @IBAction func returnToMe(segue : UIStoryboardSegue){
        
    }
    
    @IBAction func signOut(_ sender: AnyObject) {
        self.user?.signOut()
        self.title = nil
        self.response = nil
        //self.tableView.reloadData()
        self.refresh()
    }
    
    func refresh() {
        self.user?.getDetails().continueOnSuccessWith { (task) -> AnyObject? in
            DispatchQueue.main.async(execute: {
                //self.response = task.result
                self.title = self.user?.username
                //self.menutable.reloadData()
                //self.tableView.reloadData()
            })
            return nil
        }
    }

}
