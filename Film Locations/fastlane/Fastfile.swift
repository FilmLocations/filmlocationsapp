// This file contains the fastlane.tools configuration
// You can find the documentation at https://docs.fastlane.tools
//
// For a list of all available actions, check out
//
//     https://docs.fastlane.tools/actions
//

import Foundation

class Fastfile: LaneFile {
	func screenshotsLane() {
	desc("Generate new localized screenshots")
		captureScreenshots(workspace: "Film Locations.xcworkspace", scheme: "Film Locations")
		uploadToAppStore(username: "ithadtobeyou79@yahoo.com", app: "com.filmlocations.Film-Locations", skipBinaryUpload: true, skipMetadata: true)
	}
}
