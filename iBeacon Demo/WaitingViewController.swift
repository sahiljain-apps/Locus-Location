//
//  WaitingViewController.swift
//  iBeacon Demo
//
//  Created by Sahil Jain on 4/8/17.
//  Copyright © 2017 Darktt. All rights reserved.
//

import UIKit
import Firebase
import FirebaseDatabase
import Dispatch

class WaitingViewController: UIViewController {

    var carljr = ""
    @IBOutlet weak var Carls: UILabel!
    @IBOutlet weak var movieLabel: UILabel!
    @IBOutlet weak var refreshButton: UIButton!
    var hello = ""
    var bye = ""
    override func viewDidLoad() {
        super.viewDidLoad()
        
//        if hello != "" {
//            self.DMVLabel.text = "\(hello)" + " Minutes"
//        }
        

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBOutlet weak var DMVLabel: UILabel!
    
    @IBAction func refreshButtonTapped(_ sender: Any) {
        let url = URL(string: "https://beacon-5cac4.firebaseio.com/.json")

        
        
        URLSession.shared.dataTask(with:url!) { (data, response, error) in
            if error != nil {
                print("error")
            } else {
                do {
                    
                    let parsedData = try JSONSerialization.jsonObject(with: data!, options: []) as! [String:Any]
                    let waitTimeArray = parsedData["waittimes"] as! [String:Any]
                    
                    var movieTimes = waitTimeArray["F4:5E:AB:70:43:9F"] as! Double
                    
                    var carlTimes = waitTimeArray["F4:5E:AB:27:53:2C"] as! Double
                    
                    var waitTimes = waitTimeArray["F4:5E:AB:27:4E:D2"] as! Double
                    let beaconArray = parsedData["beacons"] as! [String:Any]
                    
                    let beacon = beaconArray["F4:5E:AB:27:4E:D2"] as! Double!
                    
                    let beacon1 = beaconArray["F4:5E:AB:70:43:9F"] as! Double
                    
                    let beacon2 = beaconArray["F4:5E:AB:27:53:2C"] as! Double
                    
                    self.carljr = "\(carlTimes * beacon2)"

                    
                    waitTimes = waitTimes * beacon!
                    movieTimes = movieTimes * beacon1
                    
                    self.hello = "\(waitTimes)"
                    self.bye = "\(movieTimes)"
                    
                    DispatchQueue.main.async {
                        self.updateLabel(x: self.hello)
                        self.updateL(x: self.bye)
                        self.Carls.text = self.carljr + " Minutes"
                    }


                    
                    
                } catch let error as NSError {
                    print(error)
                }
            }
            
            }.resume()
        


    }
    
    func updateLabel(x: String) {
        self.DMVLabel.text = x + " Minutes"
    }
    
    func updateL(x: String) {
        self.movieLabel.text = x + "Minutes"
        
    }
    func convertToDictionary(text: String) -> [String: Any]? {
        if let data = text.data(using: .utf8) {
            do {
                return try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
            } catch {
                print(error.localizedDescription)
            }
        }
        return nil
    }



}
