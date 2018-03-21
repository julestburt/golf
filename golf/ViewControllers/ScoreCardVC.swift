//
//  ScoreCardVC.swift
//  golf
//
//  Created by Jules Burt on 2018-03-12.
//  Copyright © 2018 bethegame Inc. All rights reserved.
//

import Foundation
import UIKit

class ScoreCardVC: UIViewController {

    let golf = Golf.data

    @IBOutlet weak var scrollView: UIScrollView!
    
    override func viewDidLoad() {
        let back = UIBarButtonItem.init(title: NSLocalizedString("Back", comment: ""), style: .plain, target: nil, action: nil)
        navigationController?.navigationBar.topItem?.backBarButtonItem = back
        
    }
}

