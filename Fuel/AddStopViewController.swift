//
//  SecondViewController.swift
//  Fuel
//
//  Created by Brad Leege on 11/21/17.
//  Copyright © 2017 Brad Leege. All rights reserved.
//

import CoreLocation
import UIKit
import Combine
import CombineCocoa
import os.log

class AddStopViewController: UIViewController, AddStopContractView {

    var presenter: AddStopContractPresenter?
    private let appDelegate = UIApplication.shared.delegate as! AppDelegate
        
    // MARK: - Data Entry Text Fields
    
    private let pricePerGallonTextField: UITextField = {
        let label = UITextField()
        label.font = UIFont.systemFont(ofSize: 30.0)
        label.textColor = UIColor.label
        label.textAlignment = .center
        label.placeholder = "$0.00"
        label.keyboardType = .decimalPad
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let gallonsTextField: UITextField = {
        let label = UITextField()
        label.font = UIFont.systemFont(ofSize: 30.0)
        label.textColor = UIColor.label
        label.textAlignment = .center
        label.placeholder = "0.0000"
        label.keyboardType = .decimalPad
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let costTextField: UITextField = {
        let label = UITextField()
        label.font = UIFont.systemFont(ofSize: 30.0)
        label.textColor = UIColor.label
        label.textAlignment = .center
        label.placeholder = "$0.00"
        label.keyboardType = .decimalPad
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let tripOdometerTextField: UITextField = {
        let label = UITextField()
        label.font = UIFont.systemFont(ofSize: 30.0)
        label.textColor = UIColor.label
        label.textAlignment = .center
        label.placeholder = "0000"
        label.keyboardType = .decimalPad
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let tripMPGTextField: UITextField = {
        let label = UITextField()
        label.font = UIFont.systemFont(ofSize: 30.0)
        label.textColor = UIColor.label
        label.textAlignment = .center
        label.placeholder = "00.000"
        label.keyboardType = .decimalPad
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let odometerTextField: UITextField = {
        let label = UITextField()
        label.font = UIFont.systemFont(ofSize: 30.0)
        label.textColor = UIColor.label
        label.textAlignment = .center
        label.placeholder = "00000"
        label.keyboardType = .numberPad
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let octaneTextField: UITextField = {
        let label = UITextField()
        label.font = UIFont.systemFont(ofSize: 30.0)
        label.textColor = UIColor.label
        label.textAlignment = .center
        label.placeholder = "00"
        label.keyboardType = .numberPad
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private var pricePerGallon: Double = 0
    private var gallons: Double = 0
    private var cost: Double = 0
    private var octane: Int = 0
    private var tripOdometer: Double = 0
    private var odometer: Double = 0
    
    private var cancellables = Set<AnyCancellable>()
    let dismissPublisher = PassthroughSubject<Bool, Never>()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        setupViewHierarchy()

        presenter = (UIApplication.shared.delegate as? AppDelegate)?.container?.resolve(AddStopContractPresenter.self)
        
        // Dismiss Keyboard Input
        self.view.addGestureRecognizer(UITapGestureRecognizer(target: self.view, action: #selector(UIView.endEditing(_:))))
      
        pricePerGallonTextField.textPublisher
            .subscribe(on: DispatchQueue.main)
            .receive(on: DispatchQueue.main)
            .filter { string in !(string ?? "").isEmpty }
            .sink(receiveCompletion: { completion in },
                  receiveValue: { value in
                    self.pricePerGallon = Double(self.stripDollarSign(string: value!))!
                    self.updatePriceTextField()
                  }).store(in: &cancellables)

        gallonsTextField.textPublisher
            .subscribe(on: DispatchQueue.main)
            .receive(on: DispatchQueue.main)
            .filter { string in !(string ?? "").isEmpty }
            .sink(receiveValue: { value in
                self.gallons = Double(value!)!
                self.updatePriceTextField()
                self.updateTripMPGTextField()
            }).store(in: &cancellables)

        tripOdometerTextField.textPublisher
            .subscribe(on: DispatchQueue.main)
            .receive(on: DispatchQueue.main)
            .filter { string in !(string ?? "").isEmpty }
            .sink(receiveValue: { value in
                self.tripOdometer = Double(value!)!
                self.updateTripMPGTextField()
            }).store(in: &cancellables)
    }
        
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        presenter?.onAttach(view: self)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        presenter?.onDetach()
        super.viewWillDisappear(animated)
    }
    
    // MARK: - View Hierarchy Setup
    private func setupViewHierarchy() {
        view.backgroundColor = UIColor.systemGray6
                
        let topStack = UIStackView()
        topStack.axis = .horizontal
        topStack.alignment = .fill
        topStack.distribution = .fillProportionally
        topStack.spacing = 0
        topStack.translatesAutoresizingMaskIntoConstraints = false
        topStack.addArrangedSubview(createPairingStack(dataTextField: pricePerGallonTextField, descriptionText: "$ / Gallon"))
        topStack.addArrangedSubview(createPairingStack(dataTextField: gallonsTextField, descriptionText: "Gallons"))
        topStack.addArrangedSubview(createPairingStack(dataTextField: costTextField, descriptionText: "Price"))

        view.addSubview(topStack)
        let bottomLeftStack = UIStackView()
        bottomLeftStack.axis = .vertical
        bottomLeftStack.alignment = .fill
        bottomLeftStack.distribution = .equalCentering
        bottomLeftStack.spacing = 28
        bottomLeftStack.addArrangedSubview(createPairingStack(dataTextField: tripOdometerTextField, descriptionText: "Trip Odometer"))
        bottomLeftStack.addArrangedSubview(createPairingStack(dataTextField: odometerTextField, descriptionText: "Odometer"))

        let bottomRightStack = UIStackView()
        bottomRightStack.axis = .vertical
        bottomRightStack.alignment = .fill
        bottomRightStack.distribution = .equalCentering
        bottomRightStack.spacing = 28
        bottomRightStack.addArrangedSubview(createPairingStack(dataTextField: tripMPGTextField, descriptionText: "Trip MPG"))
        bottomRightStack.addArrangedSubview(createPairingStack(dataTextField: octaneTextField, descriptionText: "Octane"))

        let bottomStack = UIStackView()
        bottomStack.axis = .horizontal
        bottomStack.alignment = .fill
        bottomStack.distribution = .fillEqually
        bottomStack.spacing = 0
        bottomStack.translatesAutoresizingMaskIntoConstraints = false
        bottomStack.addArrangedSubview(bottomLeftStack)
        bottomStack.addArrangedSubview(bottomRightStack)
        
        view.addSubview(bottomStack)

        let saveButton = UIButton()
        saveButton.setTitle("Save", for: .normal)
        saveButton.setTitleColor(UIColor.systemBlue, for: .normal)
        saveButton.titleLabel?.font = UIFont.systemFont(ofSize: 17.0, weight: .bold)
        saveButton.addTarget(self, action: #selector(handleSaveTap(_:)), for: .touchUpInside)
        
        let cancelButton = UIButton()
        cancelButton.setTitle("Cancel", for: .normal)
        cancelButton.setTitleColor(UIColor.systemBlue, for: .normal)
        cancelButton.titleLabel?.font = UIFont.systemFont(ofSize: 17.0, weight: .bold)
        cancelButton.addTarget(self, action: #selector(handleCancelTap(_:)), for: .touchUpInside)
        
        let buttonStack = UIStackView()
        buttonStack.axis = .horizontal
        buttonStack.alignment = .fill
        buttonStack.distribution = .fillEqually
        buttonStack.spacing = 0
        buttonStack.translatesAutoresizingMaskIntoConstraints = false
        buttonStack.addArrangedSubview(saveButton)
        buttonStack.addArrangedSubview(cancelButton)
        
        view.addSubview(buttonStack)

        NSLayoutConstraint.activate([
            topStack.topAnchor.constraint(equalTo: view.topAnchor, constant: 16.0),
            topStack.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16.0),
            topStack.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16.0),
            bottomStack.topAnchor.constraint(equalTo: topStack.bottomAnchor, constant: 28.0),
            bottomStack.leadingAnchor.constraint(equalTo: topStack.leadingAnchor),
            bottomStack.trailingAnchor.constraint(equalTo: topStack.trailingAnchor),
            buttonStack.topAnchor.constraint(equalTo: bottomStack.bottomAnchor, constant: 10.0),
            buttonStack.leadingAnchor.constraint(equalTo: bottomStack.leadingAnchor),
            buttonStack.trailingAnchor.constraint(equalTo: bottomStack.trailingAnchor)
        ])
    }
    
    private func createPairingStack(dataTextField: UITextField, descriptionText: String) -> UIStackView {
        
        let stack = UIStackView()
        stack.axis = .vertical
        stack.alignment = .fill
        stack.distribution = .fill
        stack.spacing = 0.0
        stack.addArrangedSubview(dataTextField)
        stack.addArrangedSubview(createDescriptionLabel(text: descriptionText))
        
        return stack
    }

    private func createDescriptionLabel(text: String) -> UILabel {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 17.0)
        label.textColor = UIColor.label
        label.text = text
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }
    
    
    @IBAction func handleSaveTap(_ sender: Any) {
        presenter?.handleSaveTap()
    }
    @IBAction func handleCancelTap(_ sender: Any) {
        presenter?.handleCancelTap()
    }
    
    // MARK: - AddStopContractView
    
    func dismiss() {
        dismiss(animated: true)
        dismissPublisher.send(true)
    }
    
    func dismissAfterSave(record: FuelStop) {
        if (self.presentingViewController != nil) {
            os_log(.info, log: Log.general, "presentingViewController is not null")
            
            let navVC = self.presentingViewController?.children.first(where: {
                if let _ = $0 as? UINavigationController {
                    return true
                }
                return false
            })
            
            if let navVC = navVC as? UINavigationController,
               let ovc = navVC.topViewController as? OverviewViewController {
                ovc.addFuelStopToTable(fuelStop: record)
                dismiss()
            } else {
                os_log(.error, log: Log.general, "Unable to dismiss form after save.")
                displayError(message: "Unable to dismiss form after save completed.")
            }
        }
    }
    
    func displayError(message: String) {
        let alertController = UIAlertController(title: "Whoops", message: message, preferredStyle: .alert)
        let defaultAction = UIAlertAction(title: "Ok", style: .default, handler: nil)
        alertController.addAction(defaultAction)
        self.present(alertController, animated: true, completion: nil)
    }
    
    func validateForm() -> Bool {
        
        var isValid = true
        
        if (pricePerGallonTextField.text?.isEmpty)! {
            isValid = false
            paintError(textField: pricePerGallonTextField)
        } else {
            paintClean(textField: pricePerGallonTextField)
        }

        if (gallonsTextField.text?.isEmpty)! {
            isValid = false
            paintError(textField: gallonsTextField)
        } else {
            paintClean(textField: gallonsTextField)
        }

        if (costTextField.text?.isEmpty)! {
            isValid = false
            paintError(textField: costTextField)
        } else {
            paintClean(textField: costTextField)
        }

        if (octaneTextField.text?.isEmpty)! {
            isValid = false
            paintError(textField: octaneTextField)
        } else {
            paintClean(textField: octaneTextField)
        }

        if (tripOdometerTextField.text?.isEmpty)! {
            isValid = false
            paintError(textField: tripOdometerTextField)
        } else {
            paintClean(textField: tripOdometerTextField)
        }

        if (odometerTextField.text?.isEmpty)! {
            isValid = false
            paintError(textField: odometerTextField)
        } else {
            paintClean(textField: odometerTextField)
        }
        
        return isValid
    }
    
    func locationData() -> CLLocation? {
        return appDelegate.currentLocation
    }
    
    func gallonsData() -> Double {
        return Double(gallonsTextField.text!)!
    }
    
    func octaneData() -> Int{
        return Int(octaneTextField.text!)!
    }
    
    func odometerData() -> Int{
        return Int(odometerTextField.text!)!
    }
    
    func priceData() -> Double{
        return Double(stripDollarSign(string: costTextField.text!))!
    }
    
    func ppgData() -> Double{
        return Double(stripDollarSign(string: pricePerGallonTextField.text!))!
    }
    
    func stopDateData() -> Date{
        return Date()
    }
    
    func tripOdometerData() -> Double{
        return Double(tripOdometerTextField.text!)!
    }
    
    func stripDollarSign(string: String) -> String {
        return string.replacingOccurrences(of: "$", with: "")
    }
    
    private func updatePricePerGallonTextField() {
        pricePerGallonTextField.text = pricePerGallon.currencyFormat()
    }
    
    private func updatePriceTextField() {
        cost = pricePerGallon * gallons
        costTextField.text = cost.currencyFormat()
    }
    
    private func updateTripMPGTextField() {
        if (gallons == 0) {
            tripMPGTextField.text = 0.mpgFormat()
        } else {
            tripMPGTextField.text = (tripOdometer / gallons).mpgFormat()
        }
    }
    
    private func paintError(textField: UITextField) {
        textField.layer.masksToBounds = true
        textField.layer.borderColor = UIColor.red.cgColor
        textField.layer.borderWidth = 2
    }
    
    private func paintClean(textField: UITextField) {
        textField.layer.masksToBounds = false
        textField.layer.borderColor = UIColor.clear.cgColor
        textField.layer.borderWidth = 0
    }
}
