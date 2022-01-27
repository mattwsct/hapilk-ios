//
//  PointsViewController.swift
//  Kenko
//
//  Created by David Garcia Tort on 8/14/19.
//  Copyright © 2019 Innovatech Studio Co., LTD. All rights reserved.
//

import UIKit

class PointsViewController: UIViewController {
    
    private lazy var refreshControl = UIRefreshControl()
    
    @IBOutlet weak var rewardsView: UIScrollView!
    @IBOutlet weak var profilePictureView: ProfilePictureUIView!
    @IBOutlet weak var userNameLabel: UILabel!
    @IBOutlet var pointsViews: [PointView]!
    @IBOutlet weak var pointsToTicketLabel: UILabel!
    @IBOutlet weak var ticketsLabel: UILabel!
    
    private var points: Int = 0 {
        willSet {
            updatePointsView(points: newValue)
        }
    }
    
    private var tickets: Int = 0 {
        willSet {
            checkIfThereAreNewTickets(tickets: newValue)
            ticketsLabel.text = "チケット保有枚数 : \(newValue)枚"
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Refresh Control
        refreshControl.addTarget(self, action: #selector(refreshData), for: .valueChanged)
        rewardsView.addSubview(refreshControl)
        
        // Points Label
        pointsToTicketLabel.layer.borderWidth = 2
        pointsToTicketLabel.layer.borderColor = Colors.rankingFirst.cgColor
        
        Network.getUserProfile(success: { profile in
            self.userNameLabel.text = profile.displayName
        }, error: { error in }, failure: { error in })
        
        Network.getUserProfilePicture(success: { userProfilePicture in
            DispatchQueue.main.async {
                self.profilePictureView.image = UIImage(data: userProfilePicture)
            }
        }, error: { error in }, failure: { error in })
        
        // Rewards
        //fetchRewards()
    }
    
    @objc private func refreshData() {
        fetchRewards()
        refreshControl.endRefreshing()
    }
    
    private func fetchRewards() {
        Network.getRewards(success: { rewards in
            self.points = rewards.points
            self.tickets = rewards.tickets
        }, error: { error in }, failure: { error in })
    }
    
    private func updatePointsView(points: Int) {
        var delay: Double = 0
        pointsViews.forEach { point in
            if point.position <= points {
                point.win = true
                point.animate(withDelay: delay)
                delay += 0.07
            }
        }
    }
    
    private func checkIfThereAreNewTickets(tickets: Int) {
        let ticketsKey = "tickets"
        if UserDefaults.standard.object(forKey: ticketsKey) != nil {
            let currentTickets = UserDefaults.standard.integer(forKey: ticketsKey)
            if tickets > currentTickets {
                performSegue(withIdentifier: "showTicketView", sender: nil)
            }
        }
        UserDefaults.standard.set(tickets, forKey: ticketsKey)
    }
    
}
