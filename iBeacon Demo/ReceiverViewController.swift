//
//  ReceiverViewController.swift
//  iBeacon Demo
//
//  Created by Darktt on 15/01/31.
//  Copyright (c) 2015年 Darktt. All rights reserved.
//

import UIKit
import CoreLocation
import CoreBluetooth
import Firebase
import FirebaseDatabase



class ReceiverViewController: UIViewController

{
    var boolean = true
    var initial = true
    
    @IBOutlet fileprivate weak var tableView: UITableView!
    fileprivate weak var refreshControl: UIRefreshControl?
    
    fileprivate var beacons: [CLBeacon] = []
    fileprivate var location: CLLocationManager?
    
    override func viewWillAppear(_ animated: Bool)
    {
        super.viewWillAppear(animated)
        
        self.refreshControl!.beginRefreshing()
        self.refreshBeacons(sender: self.refreshControl!)
    }
    
    override func viewDidAppear(_ animated: Bool)
    {
        super.viewDidAppear(animated)
        
        self.setNeedsStatusBarAppearanceUpdate()
    }
    
    override func viewWillDisappear(_ animated: Bool)
    {
        super.viewDidDisappear(animated)
        
        self.refreshControl!.endRefreshing()
    }
    
    func getData() {
        let ref = FIRDatabase.database().reference(fromURL: "https://beacon-5cac4.firebaseio.com/")
        ref.child("beacons").observeSingleEvent(of: .value, with: { (snapshot) in
            // Get user value
            let value = snapshot.value as? NSDictionary
//            print(value)
            
            // ...
        }) { (error) in
            print(error.localizedDescription)
        }

       
    }
    
    func writeData(x: Int) {
        let input = x
        
        if (input == 1) {
        
            if (initial == true || boolean == true) {
                let ref = FIRDatabase.database().reference(fromURL: "https://beacon-5cac4.firebaseio.com/")

        ref.child("beacons").observeSingleEvent(of: .value, with: { (snapshot) in
            // Get user value
            let value = snapshot.value as? NSDictionary
            let b = (value?.value(forKey: "F4:5E:AB:27:4E:D2"))
            var j: Int = b as! Int
            j = j+1
            
            ref.child("beacons").updateChildValues(["F4:5E:AB:27:4E:D2": j])

    
            // ...
        }) { (error) in
            print(error.localizedDescription)
        }
                
                boolean = false
                initial = false
        }
    }
        else if (input == -1) {
            
            if (initial == true || boolean == false) {
                let ref = FIRDatabase.database().reference(fromURL: "https://beacon-5cac4.firebaseio.com/")

            
            ref.child("beacons").observeSingleEvent(of: .value, with: { (snapshot) in
                // Get user value
                let value = snapshot.value as? NSDictionary
                var b = (value?.value(forKey: "F4:5E:AB:27:4E:D2"))
                var j: Int = b as! Int
                if (j>=1) {
                j = j-1
                }
                
                ref.child("beacons").updateChildValues(["F4:5E:AB:27:4E:D2": j])
                
                
                // ...
            }) { (error) in
                print(error.localizedDescription)
            }
                initial = false
                boolean = true
        }
        }

        

    }
    override func viewDidLoad()
    {
        super.viewDidLoad()
        self.navigationController?.navigationBar.barTintColor = UIColor.iOS7BlueColor()
        self.navigationController?.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: UIColor.white]
        
        self.location = CLLocationManager()
        self.location!.delegate = self
        self.location!.requestAlwaysAuthorization()
        
        let attributes: [String: AnyObject] = [NSForegroundColorAttributeName: UIColor.iOS7BlueColor()]
        let attributedTitle: NSAttributedString = NSAttributedString(string: "Receiving Beacon", attributes: attributes)
        
        let refreshControl: UIRefreshControl = UIRefreshControl()
        refreshControl.attributedTitle = attributedTitle
        refreshControl.addTarget(self, action: #selector(ReceiverViewController.refreshBeacons), for: UIControlEvents.valueChanged)
        
        self.refreshControl = refreshControl
        self.tableView.addSubview(refreshControl)
    }
    
    deinit
    {
        self.location = nil
    }
    
    override func didReceiveMemoryWarning()
    {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

// MARK: - Status Bar -

extension ReceiverViewController
{
    override var preferredStatusBarStyle: UIStatusBarStyle
    {
        return .lightContent
    }
    
    override var preferredStatusBarUpdateAnimation: UIStatusBarAnimation
    {
        return .none
    }
    
    override var prefersStatusBarHidden: Bool
    {
        return false
    }
}
    
// MARK: - Actions -

extension ReceiverViewController
{
    @objc 
    fileprivate func refreshBeacons(sender: UIRefreshControl) -> Void
    {
        // This uuid must same as broadcaster.
        let UUID: UUID = iBeaconConfiguration.uuid
        
        let beaconRegion: CLBeaconRegion = CLBeaconRegion(proximityUUID: UUID, identifier: "tw.darktt.beaconDemo")
        
        self.location!.startMonitoring(for: beaconRegion)
    }
    
    //MARK: - Other Method
    
    private func notifiBluetoothOff()
    {
        let OKAction: UIAlertAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
        
        let alert: UIAlertController = UIAlertController(title: "Bluetooth OFF", message: "Please power on your Bluetooth!", preferredStyle: .alert)
        alert.addAction(OKAction)
        
        self.present(alert, animated: true, completion: nil)
    }
}
// MARK: - UITableView DataSource Methods

extension ReceiverViewController: UITableViewDataSource, UITableViewDelegate
{
    func numberOfSections(in tableView: UITableView) -> Int
    {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return self.beacons.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        let CellIdentifier: String = "CellIdentifier"
        
        var cell: UITableViewCell? = tableView.dequeueReusableCell(withIdentifier: CellIdentifier)
        if cell == nil {
            cell = UITableViewCell(style: UITableViewCellStyle.subtitle, reuseIdentifier: CellIdentifier)
        }
        
        let row: Int = indexPath.row
        let beacon: CLBeacon = self.beacons[row]
//        let detailText: String = "Major: " + "\(beacon.major)" + "\tMinor: " + "\(beacon.minor)"
        let beaconUUID: String = "DMV Beacon"
        
        cell?.detailTextLabel?.text = beaconUUID
        
        return cell!
    }
    
    //MARK: - UITableView Delegate Methods
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    {
        tableView.deselectRow(at: indexPath, animated: true)
    }    
}
 
//MARK: - CLocationManager Delegate Methods
    
extension ReceiverViewController: CLLocationManagerDelegate
{
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) 
    {
        guard status == .authorizedAlways else {
//            print("******** User not authorized !!!!")
            return
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didStartMonitoringFor region: CLRegion)
    {
        manager.requestState(for: region)
    }
    
    func locationManager(_ manager: CLLocationManager, didDetermineState state: CLRegionState, for region: CLRegion)
    {
        if state == .inside {
            manager.startRangingBeacons(in: region as! CLBeaconRegion)
            return
        }
        
        manager.stopRangingBeacons(in: region as! CLBeaconRegion)
    }
    
    func locationManager(_ manager: CLLocationManager, didRangeBeacons beacons: [CLBeacon], in region: CLBeaconRegion)
    {
        self.beacons = beacons 
        
        if beacons.count > 0 {
        var x = "(\(self.beacons))"
        let index = x.index(x.startIndex, offsetBy: 85)
        x = x.substring(from: index)  // playground
        
        var z = ""
        var bool = false
        var salt = false
        for character in x.characters {
            
            if (character != "m") {
                if (bool == false && salt == true) {
                    z += "\(character)"
                }
                
            }
            if (character == "m") {
                bool = true
            }
            
            if (character == ":") {
                salt = true
            }
            
            
            
        }

        if (z == "0 +/- -1.00") {
            manager.startRangingBeacons(in: region)
        }
        else {
            var x = "\(z)"
            let index = x.index(x.startIndex, offsetBy: 1)
            x = x.substring(to: index)  // playground
            
            var ind = 0
            var finally = 0
            
            for character in z.characters {
                if (character == "-") {
                    finally = ind + 2
                }
                ind = ind + 1
            }
            // Done rn
//            manager.stopRangingBeacons(in: region)
            
            var bb = "\(z)"

            let index1 = bb.index(bb.startIndex, offsetBy: finally)
            bb = bb.substring(from: index1)
//            print(bb)
//            print(x)
//            
            var val = Double(bb)! + Double(x)!
            print(val)
            
            if val > 1.6 {
                writeData(x: -1)
            }
            else {
                writeData(x: 1)
            }
        
        }

            
        }
        //Done rn
//        manager.stopRangingBeacons(in: region)
        //Lol
        self.refreshControl?.endRefreshing()
        
        
        self.tableView.reloadData()
    }
}
