//
//  ContentView.swift
//  assignment
//
//  Created by 欧高远 on 10/5/2022.
//

import UIKit

class ContentView: UIView {

    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.endEditing(true)

    }
}
