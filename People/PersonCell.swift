//
//  PersonCell.swift
//  People
//
//  Created by Taras Kalapun on 07/08/14.
//  Copyright (c) 2014 Kalapun. All rights reserved.
//

import UIKit

class PersonCell: UITableViewCell {

    let imageSize:CGFloat = 48.0
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        self.imageView.layer.masksToBounds = true
        self.imageView.layer.borderWidth = 0
        self.imageView.layer.cornerRadius = imageSize/2
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    override func layoutSubviews() {
        //var imFrame = self.imageView.frame
        //imFrame.origin.x = 2
        //self.imageView.frame = imFrame
        super.layoutSubviews()
        
        let offset:CGFloat = 4
        let w:CGFloat = imageSize
        var imFrame = self.imageView.frame
        self.imageView.frame = CGRectMake(offset, offset, w, w)
        
        var diff:CGFloat = (imFrame.origin.x + imFrame.size.width) - (offset + w)
        
        var tFrame = self.textLabel.frame
        tFrame.origin.x -= diff
        tFrame.size.width += diff
        self.textLabel.frame = tFrame
        
        var dFrame = self.detailTextLabel.frame
        dFrame.origin.x -= diff
        dFrame.size.width += diff
        self.detailTextLabel.frame = dFrame
    }
    
    func setPerson(person: Person) {
        self.textLabel.text = person.title
        self.detailTextLabel.text = person.subtitle
        self.imageView.image = person.image
    }
    
    func setABPerson(person: ABPerson) {
        self.textLabel.text = person.title
        self.detailTextLabel.text = person.subtitle
        self.imageView.image = person.image
    }
    
}
