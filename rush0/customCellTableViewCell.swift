//
//  customCellTableViewCell.swift
//  rush0
//
//  Created by Jeremy SCHOTTE on 1/13/18.
//  Copyright © 2018 Jeremy SCHOTTE. All rights reserved.
//

import UIKit

class customCellTableViewCell: UITableViewCell {

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    @IBOutlet weak var deleteButton: UIButton!
    @IBOutlet weak var authorLbl: UILabel!
    @IBOutlet weak var dateLbl: UILabel!
    @IBOutlet weak var nameLbl: UILabel!
    var author_id : Int = 0
    var id: Int = 0
    var token : String = ""
    var titleTopic : String = ""
    
    override func setSelected(_ selected: Bool, animated: Bool)
    {
        super.setSelected(selected, animated: animated)
        // Configure the view for the selected state
    }

    @IBAction func deleteClick(_ sender: Any)
    {/*
       let url = NSURL(string: "https://api.intra.42.fr/v2/topics/\(id).json")
        let request = NSMutableURLRequest(url: url! as URL)
        request.httpMethod = "DELETE"
        request.addValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let task = URLSession.shared.dataTask(with: request as URLRequest)
        {
            (data, response, error) in
            print(response!)
            if error != nil{
                print(error!)
            }
        }
        task.resume()
 */
    }
}
