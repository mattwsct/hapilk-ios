//
//  AnnouncementsSwipeMenuController.swift
//  Kenko
//
//  Created by David Garcia Tort on 11/18/19.
//  Copyright © 2019 Innovatech Studio Co., LTD. All rights reserved.
//

import Foundation
import SwipeMenuViewController

class AnnouncementsViewController: UIViewController {
    
    var announcements: [Announcement] = []
    lazy var filteredAnnouncements: [Announcement] = []
    
    @IBOutlet weak var popupView: UIView! {
        didSet {
            popupView.layer.masksToBounds = true
            popupView.layer.cornerRadius = 8
        }
    }
    
    private var swipeMenuViewOptions = SwipeMenuViewOptions()
    @IBOutlet weak var swipeMenuView: SwipeMenuView!
    @IBOutlet weak var announcementsPageControl: UIPageControl!
    @IBOutlet weak var doNotShowCheckBox: CheckBox! {
        didSet {
            doNotShowCheckBox.style = .tick
            doNotShowCheckBox.borderStyle = .roundedSquare(radius: 4)
        }
    }
    var doNotShowAnnouncementsIds: [Int] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        if #available(iOS 13.0, *) {
            isModalInPresentation = true
        }
        presentationController?.delegate = self
        
        filteredAnnouncements = announcements.filter({ $0.enabled }).sorted(by: { $0.order < $1.order })
        
        announcementsPageControl.numberOfPages = filteredAnnouncements.count
        
        let storyboard = UIStoryboard(name: "Announcements", bundle: nil)
        for announcement in filteredAnnouncements {
            let identifier = "announcement"
            if let announcementViewController = storyboard.instantiateViewController(withIdentifier: identifier) as? AnnouncementViewController {
                announcementViewController.announcement = announcement
                addChild(announcementViewController)
            }
        }
        
        swipeMenuView.dataSource = self
        swipeMenuView.delegate = self
        
        swipeMenuViewOptions = .init()
        swipeMenuViewOptions.tabView.height = 0
        swipeMenuViewOptions.tabView.itemView.textColor = Colors.darkOrange.uiColor
        swipeMenuViewOptions.tabView.itemView.selectedTextColor = Colors.darkOrange.uiColor
        swipeMenuViewOptions.tabView.additionView.backgroundColor = Colors.darkOrange.uiColor
        
        swipeMenuView.reloadData(options: swipeMenuViewOptions)
    }
    
    @IBAction func closePopupView(_ sender: Any) {
        checkDoNotShowCheckBoxes()
        dismiss(animated: true, completion: nil)
    }
    
    func checkDoNotShowCheckBoxes() {
        if !doNotShowAnnouncementsIds.isEmpty {
            let filteredAnnouncementsIds = announcements.filter({ $0.enabled == false }).map({ $0.id })
            doNotShowAnnouncementsIds.append(contentsOf: filteredAnnouncementsIds)
            UserDefaults.standard.set(doNotShowAnnouncementsIds, forKey: "announcements")
        }
    }
    
    @IBAction func clickDoNotShowCheckBox(_ sender: CheckBox) {
        if sender.isChecked {
            doNotShowAnnouncementsIds.append(filteredAnnouncements[swipeMenuView.currentIndex].id)
        } else {
            doNotShowAnnouncementsIds = doNotShowAnnouncementsIds.filter { $0 != self.filteredAnnouncements[swipeMenuView.currentIndex].id }
        }
    }
    
    @IBAction func changeAnnouncement(_ sender: UIPageControl) {
        let page = sender.currentPage
        swipeMenuView.jump(to: page, animated: true)
    }
    
}

extension AnnouncementsViewController: SwipeMenuViewDataSource, SwipeMenuViewDelegate {
    
    // MARK: - SwipeMenuViewDataSource
    func numberOfPages(in swipeMenuView: SwipeMenuView) -> Int {
        return filteredAnnouncements.count
    }
    
    func swipeMenuView(_ swipeMenuView: SwipeMenuView, titleForPageAt index: Int) -> String {
        return filteredAnnouncements[index].title
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
        doNotShowCheckBox.isChecked = doNotShowAnnouncementsIds.contains(filteredAnnouncements[toIndex].id)
    }
    
    func swipeMenuView(_ swipeMenuView: SwipeMenuView, didChangeIndexFrom fromIndex: Int, to toIndex: Int) {
        // Codes
        announcementsPageControl.currentPage = toIndex
    }
    
}

extension AnnouncementsViewController: UIAdaptivePresentationControllerDelegate {
    func presentationControllerDidDismiss(_ presentationController: UIPresentationController) {
        self.checkDoNotShowCheckBoxes()
    }
}
