//
//  StudentCell.swift
//  On The Map
//
//  Created by James Dyer on 6/6/16.
//  Copyright © 2016 James Dyer. All rights reserved.
//

import UIKit

class StudentCell: UITableViewCell {
    
    @IBOutlet weak private var locationImageView: UIImageView!
    @IBOutlet weak private var studentNameLabel: UILabel!
    @IBOutlet weak private var studentLocationLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
    }
    
    func configureCell(student: StudentInformation) {
        locationImageView.image = UIImage(named: "post.png")
        studentNameLabel.text = "\(student.firstName) \(student.lastName)"
        studentLocationLabel.text = student.mapString
    }

}
