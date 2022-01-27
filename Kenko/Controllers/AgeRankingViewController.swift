//
//  AgeRankingViewController.swift
//  Kenko
//
//  Created by David Garcia Tort on 8/26/19.
//  Copyright © 2019 Innovatech Studio Co., LTD. All rights reserved.
//

import UIKit

class AgeRankingViewController: UIViewController {
    
    private var rankingAgeGroup: RankingAgeGroup = .forties
    private let refreshControl = UIRefreshControl()
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    @IBOutlet weak var periodLabel: UILabel!
    @IBOutlet weak var userPositionLabel: UILabel!
    @IBOutlet weak var userProfilePictureImageView: ProfilePictureUIView!
    @IBOutlet weak var userNameLabel: UILabel!
    @IBOutlet weak var userStepsLabel: UILabel!
    @IBOutlet weak var userStepsAgeSeparatorView: UIView!
    @IBOutlet weak var userAgeRangeLabel: UILabel!
    @IBOutlet weak var userNoDataLabel: UILabel!
    
    @IBOutlet weak var rankingTableView: UITableView! {
        didSet {
            rankingTableView.dataSource = self
            rankingTableView.delegate = self
            rankingTableView.refreshControl = refreshControl
        }
    }
    @IBOutlet weak var rankingTableNoDataLabel: UILabel!
    
    @IBOutlet weak var periodSegmentedControl: UISegmentedControl! {
        didSet {
            periodSegmentedControl.layer.cornerRadius = 5
            periodSegmentedControl.layer.borderColor = Colors.darkOrange.cgColor
            periodSegmentedControl.layer.borderWidth = 1.0
            periodSegmentedControl.layer.masksToBounds = true
            periodSegmentedControl.tintColor = Colors.darkOrange.uiColor
        }
    }
    
    private var userRankingPosition: UserPersonalRankingInformation?
    private var rankingList: [[UserPersonalRankingInformation]] = [] {
        willSet {
            rankingTableNoDataLabel.isHidden = !newValue.isEmpty
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Refresh Control
        refreshControl.addTarget(self, action: #selector(refreshData), for: .valueChanged)
        
        reloadRankingData()
    }
    
    @IBAction func changeRankingPeriod(_ sender: UISegmentedControl) {
        switch sender.selectedSegmentIndex {
        case 0: rankingAgeGroup = .twenties
        case 1: rankingAgeGroup = .thirties
        case 2: rankingAgeGroup = .forties
        case 3: rankingAgeGroup = .fifties
        case 4: rankingAgeGroup = .sixties
        default: break
        }
        reloadRankingData()
    }
    
    @objc private func refreshData() {
        reloadRankingData()
        refreshControl.endRefreshing()
    }
    
    private func reloadRankingData() {
        activityIndicator.startAnimating()
        Network.getUserAgeRanking(group: rankingAgeGroup, success: { userPersonalRankingInformation in
            self.userRankingPosition = userPersonalRankingInformation
            self.updateUserRankingPosition(userRankingPosition: userPersonalRankingInformation)
        }, error: { error in
            self.updateUserRankingPosition(userRankingPosition: nil)
        }, failure: { error in
            self.updateUserRankingPosition(userRankingPosition: nil)
        })
        Network.getAgeRanking(group: rankingAgeGroup, success: { personalRankingInformation in
            self.rankingList = []
            if personalRankingInformation.count > 0 {
                let sortedPersonalRankingInformation = personalRankingInformation.sorted {
                    $0.position < $1.position
                }
                self.rankingList = sortedPersonalRankingInformation.compactMap({ [$0] })
                self.updatePeriodLabel(from: personalRankingInformation[0].fromDate, to: personalRankingInformation[0].toDate)
            } else {
                self.rankingList = []
            }
            self.activityIndicator.stopAnimating()
            self.rankingTableView.reloadData()
        }, error: { error in
            self.rankingList = []
        }, failure: { error in
            self.rankingList = []
        })
    }
    
    private func updatePeriodLabel(from: String, to: String) {
        periodLabel.text = "\(from.decodedUTCDateDate.encodedUTCIntervalDay) - \(to.decodedUTCDateDate.encodedUTCIntervalDay)"
    }
    
    private func updateUserRankingPosition(userRankingPosition: UserPersonalRankingInformation?) {
        if let userRankingPosition = userRankingPosition {
            userPositionLabel.text = userRankingPosition.position.formattedWithSeparator
            userPositionLabel.isHidden = false
            Network.getUserProfilePicture(success: { profilePicture in
                DispatchQueue.main.async {
                    self.userProfilePictureImageView.image = UIImage(data: profilePicture)
                }
            }, error: { error in }, failure: { error in })
            userProfilePictureImageView.isHidden = false
            userNameLabel.text = userRankingPosition.name
            userNameLabel.isHidden = false
            userStepsLabel.text = userRankingPosition.steps.formattedWithSeparator + " 歩"
            userStepsLabel.isHidden = false
            userStepsAgeSeparatorView.isHidden = false
            let userAgeRange = String(userRankingPosition.ageGroup!)
            userAgeRangeLabel.text = "〜\(userAgeRange)代"
            userAgeRangeLabel.isHidden = false
        } else {
            userPositionLabel.isHidden = true
            userProfilePictureImageView.isHidden = true
            userNameLabel.isHidden = true
            userStepsLabel.isHidden = true
            userStepsAgeSeparatorView.isHidden = true
            userAgeRangeLabel.isHidden = true
            userNoDataLabel.isHidden = false
        }
    }
}

extension AgeRankingViewController: UITableViewDataSource, UITableViewDelegate {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return rankingList.count
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 10
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = UIView()
        headerView.backgroundColor = UIColor.clear
        return headerView
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "userRankingCell", for: indexPath)
        if let userRankingCell = cell as? UserRankingTableViewCell {
            if rankingList.count > 0 {
                userRankingCell.positionLabel.text = rankingList[indexPath.section][indexPath.row].position.formattedWithSeparator
                
                if let profilePictureId = rankingList[indexPath.section][indexPath.row].profilePicture?.extractUserId {
                    Network.getUsersProfilePicture(userId: profilePictureId, success: { profilePicture in
                        DispatchQueue.main.async {
                            userRankingCell.profilePictureView.image = UIImage(data: profilePicture)
                        }
                    }, error: { error in }, failure: { error in })
                } else {
                    userRankingCell.profilePictureView.setDefaultImage()
                }
                userRankingCell.nameLabel.text = rankingList[indexPath.section][indexPath.row].name
                userRankingCell.stepsLabel.text = rankingList[indexPath.section][indexPath.row].steps.formattedWithSeparator + " 歩"
            }
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        // Customize generic cell
        cell.layer.borderWidth = 2
        cell.layer.cornerRadius = 5
        cell.layer.borderColor = #colorLiteral(red: 0.9198423028, green: 0.9198423028, blue: 0.9198423028, alpha: 1)
        cell.clipsToBounds = true
        
        // Customize PersonalRankingCell
        if let individualRankingCell = cell as? UserRankingTableViewCell {
            switch rankingList[indexPath.section][indexPath.row].position {
            case 1:
                individualRankingCell.positionBackgroundColorView.backgroundColor = Colors.rankingFirst.uiColor
                individualRankingCell.positionLabel.textColor = UIColor.white
                individualRankingCell.stepsLabel.textColor = Colors.rankingFirst.uiColor
            case 2:
                individualRankingCell.positionBackgroundColorView.backgroundColor = Colors.rankingSecond.uiColor
                individualRankingCell.positionLabel.textColor = UIColor.white
                individualRankingCell.stepsLabel.textColor = Colors.rankingFirst.uiColor
            case 3:
                individualRankingCell.positionBackgroundColorView.backgroundColor = Colors.rankingThird.uiColor
                individualRankingCell.positionLabel.textColor = UIColor.white
                individualRankingCell.stepsLabel.textColor = Colors.rankingFirst.uiColor
            default:
                individualRankingCell.positionBackgroundColorView.backgroundColor = UIColor.clear
                individualRankingCell.positionLabel.textColor = UIColor.black
                individualRankingCell.stepsLabel.textColor = UIColor.black
            }
        }
    }
}
