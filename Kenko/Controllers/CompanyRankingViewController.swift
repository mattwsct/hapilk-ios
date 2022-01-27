//
//  GenericRankingViewController.swift
//  Kenko
//
//  Created by David Garcia Tort on 8/6/19.
//  Copyright © 2019 Innovatech Studio Co., LTD. All rights reserved.
//

import UIKit

class CompanyRankingViewController: UIViewController {
    
    @IBOutlet weak var periodLabel: UILabel!
    private let refreshControl = UIRefreshControl()
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    @IBOutlet weak var rankingTableView: UITableView! {
        didSet {
            rankingTableView.dataSource = self
            rankingTableView.delegate = self
            rankingTableView.refreshControl = refreshControl
        }
    }
    @IBOutlet weak var rankingTableNoDataLabel: UILabel!
    
    private var rankingList: [[CompanyRankingInformation]] = [] {
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
    
    @objc private func refreshData() {
        reloadRankingData()
        refreshControl.endRefreshing()
    }
    
    private func reloadRankingData() {
        activityIndicator.startAnimating()
        Network.getCompanyRanking(success: { companyRankingList in
            if companyRankingList.count > 0 {
                let sortedPersonalRankingInformation = companyRankingList.sorted {
                    $0.position < $1.position
                }
                self.rankingList = sortedPersonalRankingInformation.compactMap({ [$0] })
                self.updatePeriodLabel(from: companyRankingList[0].fromDate, to: companyRankingList[0].toDate)
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
}

extension CompanyRankingViewController: UITableViewDataSource, UITableViewDelegate {
    
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
        let cell = tableView.dequeueReusableCell(withIdentifier: "companyRankingCell", for: indexPath)
        if let companyRankingCell = cell as? CompanyRankingTableViewCell {
            companyRankingCell.positionLabel.text = rankingList[indexPath.section][indexPath.row].position.formattedWithSeparator
            companyRankingCell.amountPeopleLabel.text = rankingList[indexPath.section][indexPath.row].people.formattedWithSeparator + "人"
            companyRankingCell.companyLabel.text = rankingList[indexPath.section][indexPath.row].companyName
            if let branchName = rankingList[indexPath.section][indexPath.row].branchName {
                companyRankingCell.branchLabel.isHidden = false
                companyRankingCell.branchLabel.text = branchName
            } else {
                companyRankingCell.branchLabel.isHidden = true
            }
            if let departmentName = rankingList[indexPath.section][indexPath.row].departmentName {
                companyRankingCell.departmentLabel.isHidden = false
                companyRankingCell.departmentLabel.text = departmentName
            } else {
                companyRankingCell.departmentLabel.isHidden = true
            }
            companyRankingCell.stepsLabel.text = rankingList[indexPath.section][indexPath.row].steps.formattedWithSeparator + " 歩"
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
        if let companyRankingCell = cell as? CompanyRankingTableViewCell {
            switch rankingList[indexPath.section][indexPath.row].position {
            case 1:
                companyRankingCell.positionBackgroundColorView.backgroundColor = Colors.rankingFirst.uiColor
                companyRankingCell.positionLabel.textColor = UIColor.white
                companyRankingCell.stepsLabel.textColor = Colors.rankingFirst.uiColor
            case 2:
                companyRankingCell.positionBackgroundColorView.backgroundColor = Colors.rankingSecond.uiColor
                companyRankingCell.positionLabel.textColor = UIColor.white
                companyRankingCell.stepsLabel.textColor = Colors.rankingFirst.uiColor
            case 3:
                companyRankingCell.positionBackgroundColorView.backgroundColor = Colors.rankingThird.uiColor
                companyRankingCell.positionLabel.textColor = UIColor.white
                companyRankingCell.stepsLabel.textColor = Colors.rankingFirst.uiColor
            default:
                companyRankingCell.positionBackgroundColorView.backgroundColor = UIColor.clear
                companyRankingCell.positionLabel.textColor = UIColor.black
                companyRankingCell.stepsLabel.textColor = UIColor.black
            }
        }
    }
}
