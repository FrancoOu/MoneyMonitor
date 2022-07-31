//
//  UIViewController-gouu0001.swift
//  FisrtProject
//
//  Created by 欧高远 on 2022/3/4.
//

import UIKit

extension UIViewController{
    func displayMessage(title: String, message: String, completion: ((UIAlertAction) -> Void)? = nil){
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "Dismiss", style: .default, handler: completion))
        self.present(alertController, animated: true, completion: nil)
    }
    
    @IBAction func jumpCommBank(_ sender: Any) {
        let commbank = "commbank://accounts"
        let commbankUrl = URL(string: commbank)!
        print("hello")
        if UIApplication.shared.canOpenURL(commbankUrl){
            print("sucess")
            UIApplication.shared.open(commbankUrl)
        }
        else{
            displayMessage(title: "CommBank Not Installed!", message: "Please make sure you install the App!")
        }
    }
}
