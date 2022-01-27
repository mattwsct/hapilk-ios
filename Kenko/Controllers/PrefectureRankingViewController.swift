//
//  PrefectureRankingViewController.swift
//  Kenko
//
//  Created by David Garcia Tort on 8/26/19.
//  Copyright © 2019 Innovatech Studio Co., LTD. All rights reserved.
//

import UIKit

class PrefectureRankingViewController: UIViewController {
    
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
    
    private var rankingList: [[PrefectureRankingInformation]] = [] {
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
        Network.getPrefectureRanking(success: { prefectureRankingList in
            if prefectureRankingList.count > 0 {
                let sortedPersonalRankingInformation = prefectureRankingList.sorted {
                    $0.position < $1.position
                }
                self.rankingList = sortedPersonalRankingInformation.compactMap({ [$0] })
                self.updatePeriodLabel(from: prefectureRankingList[0].fromDate, to: prefectureRankingList[0].toDate)
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

extension PrefectureRankingViewController: UITableViewDataSource, UITableViewDelegate {
    
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
        let cell = tableView.dequeueReusableCell(withIdentifier: "generalRankingCell", for: indexPath)
        if let generalRankingCell = cell as? GeneralRankingTableViewCell {
            generalRankingCell.positionLabel.text = rankingList[indexPath.section][indexPath.row].position.formattedWithSeparator
            generalRankingCell.amountPeopleLabel.text = rankingList[indexPath.section][indexPath.row].people.formattedWithSeparator + "人"
            generalRankingCell.nameLabel.text = rankingList[indexPath.section][indexPath.row].prefectureName
            generalRankingCell.stepsLabel.text = rankingList[indexPath.section][indexPath.row].steps.formattedWithSeparator + " 歩"
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
        if let generalRankingCell = cell as? GeneralRankingTableViewCell {
            switch rankingList[indexPath.section][indexPath.row].position {
            case 1:
                generalRankingCell.positionBackgroundColorView.backgroundColor = Colors.rankingFirst.uiColor
                generalRankingCell.positionLabel.textColor = UIColor.white
                generalRankingCell.stepsLabel.textColor = Colors.rankingFirst.uiColor
            case 2:
                generalRankingCell.positionBackgroundColorView.backgroundColor = Colors.rankingSecond.uiColor
                generalRankingCell.positionLabel.textColor = UIColor.white
                generalRankingCell.stepsLabel.textColor = Colors.rankingFirst.uiColor
            case 3:
                generalRankingCell.positionBackgroundColorView.backgroundColor = Colors.rankingThird.uiColor
                generalRankingCell.positionLabel.textColor = UIColor.white
                generalRankingCell.stepsLabel.textColor = Colors.rankingFirst.uiColor
            default:
                generalRankingCell.positionBackgroundColorView.backgroundColor = UIColor.clear
                generalRankingCell.positionLabel.textColor = UIColor.black
                generalRankingCell.stepsLabel.textColor = UIColor.black
            }
        }
    }
}
