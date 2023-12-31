//
//  RootViewController.swift
//  Fuel
//
//  Created by Brad Leege on 8/11/21.
//  Copyright © 2021 Brad Leege. All rights reserved.
//

import UIKit
import Combine

class RootViewController: UIViewController {

    let navDrawer = NavDrawerViewController()
    
    private lazy var backgroundMaskView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.black.withAlphaComponent(0.0)
        view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(hideNavDrawer)))
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private lazy var navController: UINavigationController = {
        let navController = UINavigationController()
        navController.delegate = self
        navController.navigationBar.isTranslucent = true
        navController.navigationBar.setBackgroundImage(UIImage(), for: .default)
        navController.navigationBar.shadowImage = UIImage()
        navController.view.translatesAutoresizingMaskIntoConstraints = false
        return navController
    }()
    
    private let hamburgerButton: UIButton = {
        let menuBtn = UIButton(type: .custom)
        menuBtn.frame = CGRect(x: 0.0, y: 0.0, width: 20, height: 20)
        menuBtn.setImage(UIImage(named:"hamburger-menu"), for: .normal)
        return menuBtn
    }()
    
    private lazy var hamburgerButtonItem: UIBarButtonItem = {
        let menuBarItem = UIBarButtonItem(customView: hamburgerButton)
        menuBarItem.customView?.widthAnchor.constraint(equalToConstant: 24).isActive = true
        menuBarItem.customView?.heightAnchor.constraint(equalToConstant: 24).isActive = true
        return menuBarItem
    }()
    
    private var cancellables = Set<AnyCancellable>()
    
    private var leadingNavDrawerAnchor: NSLayoutConstraint?
        
    override func viewDidLoad() {
        super.viewDidLoad()
        bindPublishers()

        // Do any additional setup after loading the view.

        addChild(navController)
        navController.didMove(toParent: self)
        view.addSubview(navController.view)

        view.addSubview(backgroundMaskView)

        addChild(navDrawer)
        navDrawer.didMove(toParent: self)
        view.addSubview(navDrawer.view)
        
        leadingNavDrawerAnchor = navDrawer.view.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: -200.0)
        
        NSLayoutConstraint.activate([
            navDrawer.view.topAnchor.constraint(equalTo: view.topAnchor),
            navDrawer.view.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            navDrawer.view.widthAnchor.constraint(equalToConstant: 200.0),
            leadingNavDrawerAnchor!,
            navController.view.topAnchor.constraint(equalTo: view.topAnchor),
            navController.view.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            navController.view.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            navController.view.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            backgroundMaskView.topAnchor.constraint(equalTo: view.topAnchor),
            backgroundMaskView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            backgroundMaskView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            backgroundMaskView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
        
    }
        
    private func bindPublishers() {
        hamburgerButton.tapPublisher
            .sink(receiveValue: { [weak self] _ in
                self?.showNavDrawer()
            }).store(in: &cancellables)
        
        navDrawer.navDrawerItemSelectedPublisher
            .sink(receiveValue: { [weak self] menuIndex in
                self?.hideNavDrawer()
            }).store(in: &cancellables)
    }
    
    func startNewFlow(with viewController: UIViewController) {
        navController.viewControllers.removeAll()
        navController.viewControllers.append(viewController)
    }

    @objc
    func showNavDrawer() {
        self.view.insertSubview(backgroundMaskView, belowSubview: navDrawer.view)
        NSLayoutConstraint.activate([
            backgroundMaskView.topAnchor.constraint(equalTo: view.topAnchor),
            backgroundMaskView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            backgroundMaskView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            backgroundMaskView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
        
        UIView.animate(withDuration: 0.5, animations: {
            self.leadingNavDrawerAnchor?.constant = 0.0
            self.backgroundMaskView.backgroundColor = UIColor.black.withAlphaComponent(0.85)
            self.view.layoutIfNeeded()
        })
    }
    
    @objc
    func hideNavDrawer() {
        UIView.animate(withDuration: 0.5, animations: {
            self.leadingNavDrawerAnchor?.constant = -200.0
            self.backgroundMaskView.backgroundColor = UIColor.black.withAlphaComponent(0.0)
            self.view.layoutIfNeeded()
        }, completion: {_ in
            self.backgroundMaskView.removeFromSuperview()
        })
    }

}

extension RootViewController: UINavigationControllerDelegate {
    
    func navigationController(_ navigationController: UINavigationController, willShow viewController: UIViewController, animated: Bool) {
        if viewController.navigationItem.leftBarButtonItem == nil {
            viewController.navigationItem.leftBarButtonItem = hamburgerButtonItem
        }
    }
    
}
