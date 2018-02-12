//
//  SecondViewController.swift
//  Fuel
//
//  Created by Brad Leege on 11/21/17.
//  Copyright © 2017 Brad Leege. All rights reserved.
//

import CoreLocation
import UIKit

class AddStopViewController: UIViewController, AddStopContractView {

    var presenter: AddStopContractPresenter?
    
    @IBOutlet weak var date: UITextField!
    @IBOutlet weak var location: UITextField!
    @IBOutlet weak var pricePerGalloon: UITextField!
    @IBOutlet weak var gallons: UITextField!
    @IBOutlet weak var cost: UITextField!
    @IBOutlet weak var octane: UITextField!
    @IBOutlet weak var tripOdometer: UITextField!
    @IBOutlet weak var odometer: UITextField!
    
    let dateFormatter = DateFormatter()
    let datePicker = UIDatePicker()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        presenter = AddStopPresenter()
        
        dateFormatter.dateStyle = .medium
        datePicker.datePickerMode = .date
        datePicker.addTarget(self, action: #selector(datePickerValueChanged(_:)), for: UIControlEvents.valueChanged)
        date.inputView = datePicker

        // Dismiss Keyboard Input
        self.view.addGestureRecognizer(UITapGestureRecognizer(target: self.view, action: #selector(UIView.endEditing(_:))))
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        presenter?.onAttach(view: self)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        presenter?.onDetach()
        super.viewWillDisappear(animated)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @objc func datePickerValueChanged(_ sender: UIDatePicker) {
        dateFormatter.dateStyle = .medium
        date.text = dateFormatter.string(from: sender.date)
    }
    
    @IBAction func handleCancelTap(_ sender: Any) {
        presenter?.handleCancelTap()
    }
    
    // MARK: AddStopContractView
    
    func initialDataPopulation(stopDate: Date, location: CLLocation?) {
        datePicker.date = stopDate
        date.text = dateFormatter.string(from: datePicker.date)
        
        var locationText:String? = nil
        if let lat = location?.coordinate.latitude {
            if let lon = location?.coordinate.longitude {
                locationText = "\(lat), \(lon)"
            }
        }
        self.location.text = locationText
        
        self.pricePerGalloon.text = ""
        self.gallons.text = ""
        self.cost.text = ""
        self.octane.text = ""
        self.tripOdometer.text = ""
        self.odometer.text = ""
    }
    
    func dismiss() {
        dismiss(animated: true)
    }
}
