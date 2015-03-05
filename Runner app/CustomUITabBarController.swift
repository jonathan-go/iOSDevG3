//
//  CustomUITabBarController.swift
//  Runner app
//
//  Created by Elias Nilsson on 05/03/15.
//  Copyright (c) 2015 iOSGroup3. All rights reserved.
//

import UIKit

class CustomUITabBarController: UITabBarController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tabBar.selectedImageTintColor = UIColor(red: 62/255.0, green: 228/255.0, blue: 157/255.0, alpha: 1.0)

    }
   
    
}