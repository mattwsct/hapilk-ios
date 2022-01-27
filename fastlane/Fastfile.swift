// This file contains the fastlane.tools configuration
// You can find the documentation at https://docs.fastlane.tools
//
// For a list of all available actions, check out
//
//     https://docs.fastlane.tools/actions
//

import Foundation

class Fastfile: LaneFile {
    
    func beforeAll() {
        setupCircleCi()
        cocoapods()
    }
    
	func betaLane() {
        desc("Push a new beta build to TestFlight")
        buildIosApp(
            workspace: "Kenko.xcworkspace",
            scheme: "Hapilk Dev",
            configuration: "Development",
            exportMethod: "development"
        )
        uploadToTestflight(
            username: appleID,
            appIdentifier: appIdentifier,
            teamId: teamID
        )
	}
    
    func afterAll(currentLane: String) {
        
    }
}
