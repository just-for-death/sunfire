import Flutter
import UIKit
import Intents
#if canImport(ActivityKit)
import ActivityKit

// I8.3: Live Activity attributes for ongoing reading sessions.
// (ActivityKit auto-links; no Xcode project changes needed beyond this file
// and the NSSupportsLiveActivities Info.plist key.)
@available(iOS 16.2, *)
struct ReadingActivityAttributes: ActivityAttributes {
  public struct ContentState: Codable, Hashable {
    var mangaTitle: String
    var chapterName: String
    var progress: Double
  }
  var sessionId: String
}

@available(iOS 16.2, *)
@MainActor
private final class LiveActivityManager {
  static let shared = LiveActivityManager()
  private var currentActivity: Activity<ReadingActivityAttributes>?

  func start(mangaTitle: String, chapterName: String) {
    guard ActivityAuthorizationInfo().areActivitiesEnabled else { return }
    end()
    let attributes = ReadingActivityAttributes(sessionId: UUID().uuidString)
    let state = ReadingActivityAttributes.ContentState(
      mangaTitle: mangaTitle, chapterName: chapterName, progress: 0)
    do {
      currentActivity = try Activity.request(
        attributes: attributes,
        content: .init(state: state, staleDate: nil))
    } catch {
      print("[Sunfire] Live Activity start failed: \(error)")
    }
  }

  func update(mangaTitle: String, chapterName: String, progress: Double) {
    let activity = currentActivity
    Task {
      await activity?.update(
        .init(
          state: .init(
            mangaTitle: mangaTitle,
            chapterName: chapterName,
            progress: progress),
          staleDate: nil))
    }
  }

  func end() {
    let activity = currentActivity
    currentActivity = nil
    Task {
      await activity?.end(nil, dismissalPolicy: .immediate)
    }
  }
}
#endif

@main
@objc class AppDelegate: FlutterAppDelegate {
  private var siriChannel: FlutterMethodChannel?
  private var liveChannel: FlutterMethodChannel?

  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    GeneratedPluginRegistrant.register(with: self)

    guard let controller = window?.rootViewController as? FlutterViewController else {
      return super.application(application, didFinishLaunchingWithOptions: launchOptions)
    }

    // I8.4: Siri Shortcuts / NSUserActivity bridge.
    siriChannel = FlutterMethodChannel(
      name: "sunfire/siri_shortcuts",
      binaryMessenger: controller.binaryMessenger)
    siriChannel?.setMethodCallHandler { [weak self] call, result in
      switch call.method {
      case "donateContinueReading":
        let args = call.arguments as? [String: Any]
        self?.donateContinueReading(
          mangaTitle: args?["mangaTitle"] as? String ?? "",
          chapterName: args?["chapterName"] as? String ?? "",
          mangaId: args?["mangaId"] as? Int ?? 0)
        result(nil)
      default:
        result(FlutterMethodNotImplemented)
      }
    }

    // I8.3: Live Activities bridge.
    liveChannel = FlutterMethodChannel(
      name: "sunfire/live_activities",
      binaryMessenger: controller.binaryMessenger)
    liveChannel?.setMethodCallHandler { [weak self] call, result in
      switch call.method {
      case "startReading":
        let args = call.arguments as? [String: Any]
        self?.startReadingActivity(
          mangaTitle: args?["mangaTitle"] as? String ?? "",
          chapterName: args?["chapterName"] as? String ?? "")
        result(nil)
      case "updateReading":
        let args = call.arguments as? [String: Any]
        self?.updateReadingActivity(
          mangaTitle: args?["mangaTitle"] as? String ?? "",
          chapterName: args?["chapterName"] as? String ?? "",
          progress: args?["progress"] as? Double ?? 0)
        result(nil)
      case "endReading":
        self?.endReadingActivity()
        result(nil)
      default:
        result(FlutterMethodNotImplemented)
      }
    }

    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }

  // MARK: - I8.4 Siri Shortcuts

  /// Donates a "Continue Reading" user activity so Siri can suggest it and
  /// the Shortcuts app can run it. Taps route back through
  /// continueUserActivity -> Dart (sunfire/deep_link channel via app_links).
  func donateContinueReading(mangaTitle: String, chapterName: String, mangaId: Int) {
    let activity = NSUserActivity(activityType: "com.sunfire.app.continue-reading")
    activity.title = "Continue reading \(mangaTitle)"
    activity.suggestedInvocationPhrase = "Continue reading manga"
    activity.isEligibleForSearch = true
    activity.isEligibleForPrediction = true
    activity.persistentIdentifier = "com.sunfire.app.continue-reading"
    activity.userInfo = [
      "mangaId": mangaId,
      "mangaTitle": mangaTitle,
      "chapterName": chapterName,
    ]
    activity.becomeCurrent()
  }

  override func application(
    _ application: UIApplication,
    continue userActivity: NSUserActivity,
    restorationHandler: @escaping ([UIUserActivityRestoring]?) -> Void
  ) -> Bool {
    if userActivity.activityType == "com.sunfire.app.continue-reading",
       let mangaId = userActivity.userInfo?["mangaId"] as? Int {
      // Route via the existing deep-link pipeline (app_links listens on the
      // sunfire/deep_link channel; openURL round-trips through the OS).
      if let url = URL(string: "sunfire://manga/\(mangaId)") {
        application.open(url, options: [:], completionHandler: nil)
        return true
      }
    }
    return super.application(application, continue: userActivity, restorationHandler: restorationHandler)
  }

  // MARK: - I8.3 Live Activities

  private func startReadingActivity(mangaTitle: String, chapterName: String) {
    #if canImport(ActivityKit)
    if #available(iOS 16.2, *) {
      LiveActivityManager.shared.start(mangaTitle: mangaTitle, chapterName: chapterName)
    }
    #endif
  }

  private func updateReadingActivity(mangaTitle: String, chapterName: String, progress: Double) {
    #if canImport(ActivityKit)
    if #available(iOS 16.2, *) {
      LiveActivityManager.shared.update(
        mangaTitle: mangaTitle,
        chapterName: chapterName,
        progress: progress)
    }
    #endif
  }

  private func endReadingActivity() {
    #if canImport(ActivityKit)
    if #available(iOS 16.2, *) {
      LiveActivityManager.shared.end()
    }
    #endif
  }
}
