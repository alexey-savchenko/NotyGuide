//
//  b.swift
//  notyguide
//
//  Created by Alexey Savchenko on 03.02.17.
//  Copyright © 2017 SuddenlyPancakes. All rights reserved.
//

import UIKit

class RoundButton: UIButton {
  


  required init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
    
    self.clipsToBounds = true
    self.layer.cornerRadius = CGFloat(self.frame.size.width / 2)
    
  }
  
  
}
