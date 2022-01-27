//
//  RankingSwipeMenuViewController.swift
//  Kenko
//
//  Created by David Garcia Tort on 8/5/19.
//  Copyright © 2019 Innovatech Studio Co., LTD. All rights reserved.
//

import Foundation
import SwipeMenuViewController

class RankingSwipeMenuViewController: UIViewController {
    
    @IBOutlet weak var swipeMenuView: RankingSwipeMenuView!
    private var swipeMenuViewOptions = SwipeMenuViewOptions()
    
    private let pageNames = ["会社別ランキング", "個人別ランキング", "年代別ランキング", "都道府県ランキング"]
    
    override func viewDidLoad() {
        
        let storyboard = UIStoryboard(name: "Ranking", bundle: nil)
        
        for index in pageNames.indices {
            var storyboardIdentifier: String?
            
            switch index {
            case 0: storyboardIdentifier = "companyRanking"
            case 1: storyboardIdentifier = "individualRanking"
            case 2: storyboardIdentifier = "ageRanking"
            case 3: storyboardIdentifier = "prefectureRanking"
            default: break
            }
            if let identifier = storyboardIdentifier {
                let rankingViewController = storyboard.instantiateViewController(withIdentifier: identifier)
                addChild(rankingViewController)
            }
        }
        
        super.viewDidLoad()
        
        swipeMenuView.dataSource = self
        swipeMenuView.delegate = self
        
        swipeMenuViewOptions = .init()
        swipeMenuViewOptions.tabView.itemView.textColor = Colors.darkOrange.uiColor
        swipeMenuViewOptions.tabView.itemView.selectedTextColor = Colors.darkOrange.uiColor
        swipeMenuViewOptions.tabView.additionView.backgroundColor = Colors.darkOrange.uiColor
        
        swipeMenuView.reloadData(options: swipeMenuViewOptions)
    }
    
}

extension RankingSwipeMenuViewController: SwipeMenuViewDataSource, SwipeMenuViewDelegate {
    
    // MARK: - SwipeMenuViewDataSource
    func numberOfPages(in swipeMenuView: SwipeMenuView) -> Int {
        return pageNames.count
    }
    
    func swipeMenuView(_ swipeMenuView: SwipeMenuView, titleForPageAt index: Int) -> String {
        return pageNames[index]
    }
    
    func swipeMenuView(_ swipeMenuView: SwipeMenuView, viewControllerForPageAt index: Int) -> UIViewController {
        let viewController = children[index]
        viewController.didMove(toParent: self)
        return viewController
    }
    
    // MARK: - SwipeMenuViewDelegate
    func swipeMenuView(_ swipeMenuView: SwipeMenuView, viewWillSetupAt currentIndex: Int) {
        // Codes
    }
    
    func swipeMenuView(_ swipeMenuView: SwipeMenuView, viewDidSetupAt currentIndex: Int) {
        // Codes
    }
    
    func swipeMenuView(_ swipeMenuView: SwipeMenuView, willChangeIndexFrom fromIndex: Int, to toIndex: Int) {
        // Codes
    }
    
    func swipeMenuView(_ swipeMenuView: SwipeMenuView, didChangeIndexFrom fromIndex: Int, to toIndex: Int) {
        // Codes
    }
    
}
