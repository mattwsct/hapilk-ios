//
//  DashboardViewController.swift
//  Kenko
//
//  Created by David Garcia Tort on 6/24/19.
//  Copyright © 2019 Innovatech Studio Co., LTD. All rights reserved.
//

import UIKit
import Charts

class DashboardViewController: UIViewController {

    // MARK: - Properties
    private lazy var activityIndicator = UIActivityIndicatorView()
    private lazy var refreshControl = UIRefreshControl()
    private let calendar = Calendar.current
    private lazy var dayOfWeek: Int = 0
    private lazy var weekOfYear: Int = 0
    private lazy var healthData: [HealthData] = []
    private lazy var totalSteps: Int = 0
    private var goal: Int = 0
    private let healthService = HealthService()
    private var stepsDayDataEntries = [PieChartDataEntry]()
    private var stepsWeekDataEntries = [BarChartDataEntry]()
    private let days = ["月", "火", "水", "木", "金", "土", "日"]
    private lazy var announcements: [Announcement] = []
    private lazy var lastSynchronizedDate: Date = Date()
    
    public var date = Date() {
        didSet {
            let isTodayOrBefore = date.isBehindOf(date: Date())
            changeDayAfterView.isHidden = !isTodayOrBefore
            swipeLeftGesture.isEnabled = isTodayOrBefore
            
            fetchHealthData()
        }
    }

    @IBOutlet weak var dashboardView: UIScrollView!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var stepsDayChartView: PieChartView!
    @IBOutlet weak var goalAchievedImageView: UIImageView!
    @IBOutlet weak var stepsLabel: UILabel!
    @IBOutlet weak var stepsGoalLabel: UILabel!
    @IBOutlet weak var caloriesLabel: UILabel!
    @IBOutlet weak var stepsWeekChartView: BarChartView!
    @IBOutlet weak var totalStepsWeekView: UIView!
    @IBOutlet weak var totalStepsWeekLabel: UILabel!
    @IBOutlet weak var changeDayBeforeView: UIView!
    @IBOutlet weak var changeDayAfterView: UIView!
    @IBOutlet var swipeLeftGesture: UISwipeGestureRecognizer!
    @IBOutlet var swipeRightGesture: UISwipeGestureRecognizer!
    
    // MARK: - Functions
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Check date
        NotificationCenter.default.addObserver(self, selector: #selector(enterForeground), name: UIApplication.willEnterForegroundNotification, object: nil)
        
        // Activity Indicator
        activityIndicator.center = self.view.center
        activityIndicator.hidesWhenStopped = true
        activityIndicator.style = .gray
        self.view.addSubview(activityIndicator)
        
        // Change forward controls
        changeDayAfterView.isHidden = true
        swipeRightGesture.isEnabled = false
        
        // Refresh Control
        refreshControl.addTarget(self, action: #selector(getHealthKitDataAndFetchAPI), for: .valueChanged)
        dashboardView.addSubview(refreshControl)
        
        // Notifications
        NotificationsService.requestNotifications()
        
        // Health
        HealthService.checkHealthDataAvailability()
        
        // Fetch data
        Network.getGoal(success: { goal in
            self.goal = goal.goal
        }, error: { error in }, failure: { error in })
        
        fetchHealthData()
        
        // Daily Chart
        setupStepsDayPieChart()
        
        // Weekly Chart
        stepsWeekChartView.delegate = self
        setupStepsWeekBarChart()
        
        fetchAnnouncements()
    }
    
    @objc private func enterForeground() {
        checkDate()
        getHealthKitDataAndFetchAPI()
    }
    
    private func checkDate() {
        let todayDateKey = "todayDate"
        let today = Date()
        if let todayDate = UserDefaults.standard.object(forKey: todayDateKey) as? Date {
            if today.isAheadOf(date: todayDate), todayDate.isSameOf(date: date) {
                date = today
            }
        }
        UserDefaults.standard.set(today, forKey: todayDateKey)
    }
    
    private func synchronizeHealthKitData(for days: [Date], completion: @escaping () -> Void, completionWithoutPermissions: @escaping () -> Void) {
        HealthService.getHealthData(of: [.steps, .calories], for: days, withCompletion: { healthData in
            if !healthData.isEmpty {
                Network.request(
                    target: .updateUserHealthData(healthData: healthData),
                    success: { response in
                        completion()
                    }, error: { error in
                        self.validationAlert(title: "", message: error.localizedDescription)
                    }, failure: { error in
                        self.validationAlert(title: "", message: error.localizedDescription)
                    })
            } else {
                completionWithoutPermissions()
            }
        })
    }
    
    @objc private func getHealthKitDataAndFetchAPI() {
        // Sync data from API
        activityIndicator.startAnimating()
        startLoadingDashboard()
        
        // Check last synchronization date, and synchronize the missing days
        let lastSynchronizationDateKey = "syncDate"
        
        if let lastSynchronizedDate = UserDefaults.standard.object(forKey: lastSynchronizationDateKey) as? Date {
            self.lastSynchronizedDate = lastSynchronizedDate
        }
        let daysToSync = lastSynchronizedDate.datesBetween(date: Date().endOfDay)
        
        // Sync today's health data
        self.synchronizeHealthKitData(for: daysToSync, completion: {
            // Set last synchronized date
            UserDefaults.standard.set(Date(), forKey: lastSynchronizationDateKey)
            self.fetchAPIData()
        }, completionWithoutPermissions: {
            self.fetchAPIData()
        })
    }
    
    private func fetchAPIData() {
        Network.getUserHealthData(start: self.date.firstDayOfWeek, end: self.date.lastDayOfWeekOrToday, success: { healthData in
            // Reset healthData and assigned synchronized data
            self.healthData = Array(repeating: HealthData(steps: 0, calories: 0, date: Date().encodedUTCDateString), count: 7)
            for index in healthData.indices {
                let dayOfWeek = healthData[index].date.decodedUTCDatetimeDate.dayOfWeekForArray
                self.healthData[dayOfWeek] = healthData[index]
            }
            self.activityIndicator.stopAnimating()
            self.refreshControl.endRefreshing()
            self.stopLoadingDashboard()
            self.updateCharts()
        }, error: { error in }, failure: { error in })
    }
    
    private func fetchAnnouncements() {
        Network.getAnnouncements(success: { announcements in
            if announcements.count > 0 {
                self.announcements = announcements
                if let announcementsIds = UserDefaults.standard.object(forKey: "announcements") as? [Int] {
                    self.announcements = announcements.map { announcement in
                        if announcementsIds.contains(announcement.id) {
                            var mutatedAnnouncement = announcement
                            mutatedAnnouncement.enabled = false
                            return mutatedAnnouncement
                        }
                        return announcement
                    }
                }
                if self.announcements.filter({ $0.enabled }).count > 0 {
                    self.performSegue(withIdentifier: "showAnnouncements", sender: nil)
                }
            }
        }, error: { error in }, failure: { error in })
    }
    
    private func fetchHealthData() {
        // Data is fetched by week, if day is within the week no need to fetch again
        dayOfWeek = date.dayOfWeekForArray
        if date.weekOfYear != self.weekOfYear {
            self.weekOfYear = date.weekOfYear
            getHealthKitDataAndFetchAPI()
        } else {
            self.updateCharts()
        }
    }
    
    private func startLoadingDashboard() {
        stepsDayChartView.isHidden = true
        caloriesLabel.isHidden = true
        stepsWeekChartView.isHidden = true
        totalStepsWeekView.isHidden = true
        changeDayBeforeView.isHidden = true
        changeDayAfterView.isHidden = true
        swipeLeftGesture.isEnabled = false
        swipeRightGesture.isEnabled = false
    }
    
    private func stopLoadingDashboard() {
        stepsDayChartView.isHidden = false
        caloriesLabel.isHidden = false
        stepsWeekChartView.isHidden = false
        totalStepsWeekView.isHidden = false
        changeDayBeforeView.isHidden = false
        if date.isBehindOf(date: Date()) {
            changeDayAfterView.isHidden = false
            swipeLeftGesture.isEnabled = true
        }
        swipeRightGesture.isEnabled = true
    }
    
    private func updateCharts() {
        updateDailyChart()
        updateWeeklyChart()
    }
    
    private func updateDailyChart() {
        updateGoalAchievedView()
        updateDateLabel()
        updateStepsDayChartView()
        updateStepsLabel()
        updateStepsGoalLabel()
        updateCaloriesLabel()
    }
    
    private func updateWeeklyChart() {
        updateStepsWeekChartView()
        updateTotalStepsLabel()
    }
    
    @IBAction func changeDayBefore(_ sender: Any) {
        date = Calendar.current.date(byAdding: .day, value: -1, to: date)!
    }
    
    @IBAction func changeDayAfter(_ sender: Any) {
        date = Calendar.current.date(byAdding: .day, value: 1, to: date)!
    }
    
    @IBAction func refreshDashboard(_ sender: Any) {
        getHealthKitDataAndFetchAPI()
    }
    
    @IBAction func changeGoal(_ sender: Any) {
        let cancelButton = UIAlertAction(title: "キャンセル", style: .cancel, handler: nil)
        let goalButton = UIAlertAction(title: "ゴール", style: .default, handler: { action in
            self.validationAlert(title: "", message: "目標は本日以降変更されます", completion: {
                self.performSegue(withIdentifier: "showEditGoal", sender: nil)
            })
        })
        let stepsButton = UIAlertAction(title: "歩数", style: .default, handler: { action in
            self.performSegue(withIdentifier: "showEditSteps", sender: nil)
        })
        let alertController = UIAlertController.init(title: nil, message: nil, preferredStyle: .actionSheet)
        
        alertController.addAction(cancelButton)
        alertController.addAction(goalButton)
        alertController.addAction(stepsButton)
        
        self.present(alertController, animated: true)
    }
    
    // MARK: - Date
    private func updateGoalAchievedView() {
        goalAchievedImageView.isHidden = healthData[dayOfWeek].steps < healthData[dayOfWeek].goal ?? Double(goal)
    }
    
    private func updateDateLabel() {
        dateLabel.text = date.encodedUTCDay
    }
    
    // MARK: - Daily Chart
    private func updateStepsLabel() {
        if !healthData.isEmpty {
            stepsLabel.isHidden = false
            stepsLabel.text = healthData[dayOfWeek].steps.formattedWithSeparator
        } else {
            stepsLabel.isHidden = true
        }
    }
    
    private func updateStepsGoalLabel() {
        if !healthData.isEmpty {
            stepsGoalLabel.isHidden = false
            stepsGoalLabel.text = healthData[dayOfWeek].goal?.formattedWithSeparator ?? goal.formattedWithSeparator
        } else {
            stepsGoalLabel.isHidden = true
        }
    }
    
    private func updateCaloriesLabel() {
        if !healthData.isEmpty {
            caloriesLabel.isHidden = false
            caloriesLabel.text = healthData[dayOfWeek].calories.formattedWithSeparator + "kcal"
        } else {
            caloriesLabel.isHidden = true
        }
    }
    
    private func updateStepsDayChartView() {
        let steps = healthData[dayOfWeek].steps
        //let calories = healthData[dayOfWeek].calories
        
        let stepsDataEntry = PieChartDataEntry(value: steps)
        let stepsGoal = ((healthData[dayOfWeek].goal ?? Double(goal)) - steps) > 0 ? (healthData[dayOfWeek].goal ?? Double(goal)) - steps : 0
        let stepsGoalDataEntry = PieChartDataEntry(value: stepsGoal)
        
        stepsDayDataEntries = [stepsDataEntry, stepsGoalDataEntry]
        let chartDataSet = PieChartDataSet(entries: stepsDayDataEntries, label: nil)
        let chartData = PieChartData(dataSet: chartDataSet)
        let colors = [#colorLiteral(red: 0.2392156869, green: 0.6745098233, blue: 0.9686274529, alpha: 1), #colorLiteral(red: 0.8039215803, green: 0.8039215803, blue: 0.8039215803, alpha: 1)]
        chartDataSet.colors = colors
        chartDataSet.drawValuesEnabled = false
        stepsDayChartView.data = chartData
        stepsDayChartView.animate(xAxisDuration: 0, yAxisDuration: 1, easingOption: .easeOutCirc)
    }
    
    private func setupStepsDayPieChart() {
        stepsDayChartView.drawHoleEnabled = true
        stepsDayChartView.holeRadiusPercent = 0.9
        stepsDayChartView.rotationEnabled = false
        stepsDayChartView.drawEntryLabelsEnabled = false
        stepsDayChartView.legend.enabled = false
        stepsDayChartView.rotationAngle = 90
    }
    
    // MARK: - Weekly Chart
    private func setupStepsWeekBarChart() {
        stepsWeekChartView.xAxis.labelPosition = .bottom
        stepsWeekChartView.xAxis.valueFormatter = IndexAxisValueFormatter(values: days)
        stepsWeekChartView.xAxis.drawAxisLineEnabled = false
        stepsWeekChartView.xAxis.drawGridLinesEnabled = false
        stepsWeekChartView.leftAxis.drawAxisLineEnabled = false
        stepsWeekChartView.leftAxis.axisMinimum = 0
        stepsWeekChartView.rightAxis.drawAxisLineEnabled = false
        stepsWeekChartView.rightAxis.axisMinimum = 0
        stepsWeekChartView.rightAxis.enabled = false
        stepsWeekChartView.legend.enabled = false
        stepsWeekChartView.doubleTapToZoomEnabled = false
        stepsWeekChartView.dragEnabled = false
        stepsWeekChartView.pinchZoomEnabled = false
        stepsWeekChartView.fitBars = true
        stepsWeekChartView.drawValueAboveBarEnabled = false
    }
    
    private func updateStepsWeekChartView() {
        stepsWeekDataEntries = []
        totalSteps = 0
        
        for index in healthData.indices {
            var steps: Double = 0
            steps = healthData[index].steps
            totalSteps += Int(steps)
            let stepsDayDataEntry = BarChartDataEntry(x: Double(index), y: steps)
            stepsWeekDataEntries.append(stepsDayDataEntry)
        }
        
        let chartDataSet = BarChartDataSet(entries: stepsWeekDataEntries, label: nil)
        let chartData = BarChartData(dataSet: chartDataSet)
        let colors = [#colorLiteral(red: 0.8039215803, green: 0.8039215803, blue: 0.8039215803, alpha: 0.9)]
        chartDataSet.colors = colors
        chartDataSet.highlightColor = #colorLiteral(red: 0.2588235438, green: 0.7568627596, blue: 0.9686274529, alpha: 1)
        chartData.highlightEnabled = true
        chartDataSet.drawValuesEnabled = false
        stepsWeekChartView.data = chartData
        stepsWeekChartView.highlightValue(x: Double(dayOfWeek), dataSetIndex: 0)
        stepsWeekChartView.notifyDataSetChanged()
        stepsWeekChartView.animate(xAxisDuration: 0, yAxisDuration: 1, easingOption: .easeOutCirc)
    }
    
    private func updateTotalStepsLabel() {
        totalStepsWeekLabel.text = totalSteps.formattedWithSeparator + " 歩"
    }
    
    // MARK: - Segue
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let destination = segue.destination as? UINavigationController, let vc = destination.viewControllers.first as? EditDashboardViewController {
            vc.goal = Double(goal)
            vc.date = date
            vc.healthData = healthData[dayOfWeek]
        }
        if let destination = segue.destination as? AnnouncementsViewController {
            destination.announcements = announcements
        }
    }
    
    @IBAction func unwindToDashboard(_ unwindSegue: UIStoryboardSegue) {
        if let sourceViewController = unwindSegue.source as? EditDashboardViewController {
            if let stepsInputField = sourceViewController.stepsInputField {
                healthData[dayOfWeek].steps = Double(stepsInputField.text!)!
                updateCharts()
            }
            if let goalInputField = sourceViewController.goalInputField {
                goal = Int(goalInputField.text!)!
                updateCharts()
            }
        }
    }
}

extension DashboardViewController: ChartViewDelegate {
    
    func chartValueSelected(_ chartView: ChartViewBase, entry: ChartDataEntry, highlight: Highlight) {
        if Int(entry.x) != dayOfWeek {
            let differenceOfDays = Int(entry.x) - dayOfWeek
            if let date = Calendar.current.date(byAdding: .day, value: differenceOfDays, to: date), !date.isAheadOf(date: Date()) {
                self.date = date
            }
        }
    }
}
