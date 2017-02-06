//
//  SavedLocationCell.swift
//  notyguide
//
//  Created by Alexey Savchenko on 06.02.17.
//  Copyright © 2017 SuddenlyPancakes. All rights reserved.
//

import UIKit

class SavedLocationCell: UITableViewCell {
  
  @IBOutlet weak var nameOfLocation: UILabel!
  @IBOutlet weak var dateAdded: UILabel!
  @IBOutlet weak var latitude: UILabel!
  @IBOutlet weak var longtitude: UILabel!
  
  
  func configureCell(with location: Location) {
    
    nameOfLocation.text = location.name
    dateAdded.text = "\(location.dateAdded!)"
    latitude.text = "\(location.latitude)"
    longtitude.text = "\(location.longtitude)"
    
  }
  
  override func awakeFromNib() {
    super.awakeFromNib()
    // Initialization code
  }
  
  override func setSelected(_ selected: Bool, animated: Bool) {
    super.setSelected(selected, animated: animated)
    
    // Configure the view for the selected state
  }
  
}
