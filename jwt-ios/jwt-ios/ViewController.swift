//
//  ViewController.swift
//  jwt-ios
//
//  Created by Andrew Chen Wang on 3/2/20.
//  Copyright © 2020 Andrew Chen Wang. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    let label = UILabel()
    var pingCount = 0
    
    // Necessary so we stop infinitely pinging when sign out. In production, please never do an infinite request like this...
    var inView: Bool = false
    
    var networkManager: AuthNetworkManager!
    init(networkManager: AuthNetworkManager) {
        super.init(nibName: nil, bundle: nil)
        self.networkManager = networkManager
    }
    required init?(coder aDecoder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white

        label.text = "Number of pings: \(pingCount)"
        label.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(label)
        NSLayoutConstraint.activate([
            label.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            label.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            label.heightAnchor.constraint(equalToConstant: 15)
        ])
        
        // Begining async calling to check if expired or not
        inView = true
        testLogin()
    }
    
    private func updatePingCount() {
        pingCount += 1
        label.text = "Number of pings: \(pingCount)"
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        inView = false
    }
    
    /// Test login against server every second
    func testLogin() {
        // Required
        let group = DispatchGroup()
        group.enter()
        var authError = false
        // The simulation may "lag" but it's really just this one second delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 1, execute: {
            // Perform ping test. Replace with whatever network thing you need to perform.
            self.networkManager.ping(id: 10) { response, error in
                if let error = error {
                    print(error)
                    // Required
                    if error == NetworkResponse.authenticationError.rawValue {
                        authError = true
                    }
                }
                group.leave()
            }
        })
        
        group.notify(queue: .main) {
            // Required if statement
            if authError {
            self.navigationController?.getNewAccessToken(self.networkManager)
            }
            // This is where you do your stuff. DO NOT do it in that DispatchQueue since all your UI actions need to happen on the main thread. So replace updatePingCount() with whatever you need to do.
            self.updatePingCount()
            // Re-run ping function to shoe how automatic Auth Works.
            if self.inView == true {
                self.testLogin()
            }
        }
    }
}

extension ViewController: UINavigationBarDelegate {
    // On sign out, we should revoke all tokens. It's up to you if you also want to delete shared web user credentials. For us, we delete all.
    func navigationBar(_ navigationBar: UINavigationBar, didPop item: UINavigationItem) {
        navigationController?.signout()
    }
}
