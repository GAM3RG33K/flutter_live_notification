import ActivityKit
import Flutter
import UIKit
import UserNotifications

public class FlutterLiveNotificationPlugin: NSObject, FlutterPlugin {
    public static func register(with registrar: FlutterPluginRegistrar) {
        let channel = FlutterMethodChannel(
            name: "flutter_live_notification", binaryMessenger: registrar.messenger())
        let instance = FlutterLiveNotificationPlugin()
        registrar.addMethodCallDelegate(instance, channel: channel)
        NSLog("[FlutterLiveNotificationPlugin] Plugin registered.")
    }

    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        NSLog(
            "[handle] Received method call: \(call.method) with arguments: \(String(describing: call.arguments))"
        )

        // Ensure iOS version compatibility
        guard #available(iOS 16.1, *) else {
            NSLog("[handle] Unsupported iOS version. Live Activities require iOS 16.1 or newer.")
            result(
                FlutterError(
                    code: "UNSUPPORTED_VERSION",
                    message: "Live Activities are only supported on iOS 16.1+",
                    details: nil))
            return
        }

        // Handle the methods
        switch call.method {
        case "getPlatformVersion":
            NSLog("[handle] Returning platform version.")
            result("iOS " + UIDevice.current.systemVersion)

        case "initialize":
            NSLog("[handle] Initializing.")
            setup(result: result)

        case "dispose":
            NSLog("[handle] Disposing resources.")
            dispose(result: result)

        case "createLiveNotification":
            guard let args = call.arguments as? [String: Any] else {
                result(
                    FlutterError(
                        code: "INVALID_ARGUMENTS",
                        message: "Invalid arguments structure for live notification",
                        details: nil))
                return
            }

            // Extracting values from args dictionary
            let title = args["title"] as? String ?? ""
            let message = args["message"] as? String ?? ""
            NSLog("[handle] Creating live notification.")
            if title.isEmpty || message.isEmpty {
                NSLog("[handle] Invalid arguments for createLiveNotification. \(call.arguments)")
                result(
                    FlutterError(
                        code: "INVALID_ARGUMENTS",
                        message: "Invalid arguments for createLiveNotification",
                        details: call.arguments))
                return
            }

            if #available(iOS 16.2, *) {
                createLiveNotification(title: title, message: message, result: result)
            } else {
                NSLog(
                    "[handle] Unsupported iOS version. Live Activities require iOS 16.2 or newer.")
                result(
                    FlutterError(
                        code: "UNSUPPORTED_VERSION",
                        message: "Live Activities are only supported on iOS 16.2+",
                        details: nil))
            }

        case "updateLiveNotification":
            guard let args = call.arguments as? [String: Any] else {
                result(
                    FlutterError(
                        code: "INVALID_ARGUMENTS",
                        message: "Invalid arguments structure for live notification",
                        details: nil))
                return
            }

            // Extracting values from args dictionary
            let id = args["id"] as? String ?? ""
            let title = args["title"] as? String ?? ""
            let message = args["message"] as? String ?? ""
            if id.isEmpty || title.isEmpty || message.isEmpty {

                NSLog("[handle] Invalid arguments for updateLiveNotification. \(call.arguments)")
                result(
                    FlutterError(
                        code: "INVALID_ARGUMENTS",
                        message: "Invalid arguments for updateLiveNotification",
                        details: call.arguments))
                return
            }

            if #available(iOS 16.2, *) {
                updateLiveNotification(
                    id: id, title: title, message: message, result: result)
            } else {
                NSLog(
                    "[handle] Unsupported iOS version. Live Activities require iOS 16.2 or newer."
                )
                result(
                    FlutterError(
                        code: "UNSUPPORTED_VERSION",
                        message: "Live Activities are only supported on iOS 16.2+",
                        details: nil))
            }

        case "dismiss":
            if #available(iOS 16.2, *) {
                dismiss(result: result)
            } else {
                NSLog(
                    "[handle] Unsupported iOS version. Live Activities require iOS 16.2 or newer."
                )
                result(
                    FlutterError(
                        code: "UNSUPPORTED_VERSION",
                        message: "Live Activities are only supported on iOS 16.2+",
                        details: nil))
            }

        default:
            NSLog("[handle] Method not implemented.")
            result(FlutterMethodNotImplemented)
        }

    }

    private func requestNotificationAuthorization() {
        NSLog("[requestNotificationAuthorization] requesting user permission to show notification")
        let center = UNUserNotificationCenter.current()
        center.requestAuthorization(options: [.alert, .badge, .sound]) { granted, error in
            if granted {
                NSLog("Notification permissions granted.")
            } else {
                NSLog("Notification permissions denied.")
            }
            if let error = error {
                NSLog("Error requesting notification authorization: \(error.localizedDescription)")
            }
        }
    }

    // MARK: - live notification Methods
    private func setup(result: @escaping FlutterResult) {
        NSLog("[initialize] Initializing resources.")
        requestNotificationAuthorization()
        result(true)
    }

    private func dispose(result: @escaping FlutterResult) {
        NSLog("[dispose] Disposing resources.")
        result(true)
    }

    @available(iOS 16.2, *)
    private func createLiveNotification(
        title: String, message: String, result: @escaping FlutterResult
    ) {
        NSLog(
            "[createLiveNotification] Creating live notification with title: \(title), message: \(message)."
        )

        // Creating an instance of LiveNotificationState with the provided title and message
        let initialContentState = LiveNotificationAttributes.LiveNotificationState(
            title: title, message: message)

        // Creating the content for the live notification using LiveNotificationAttributes
        let attributes = LiveNotificationAttributes()  // Instantiate the attributes if required
        let liveNotificationContent = ActivityContent(state: initialContentState, staleDate: nil)

        Task {
            do {
                // Requesting a new live notification asynchronously
                let liveNotification = try await Activity<LiveNotificationAttributes>.request(
                    attributes: attributes, content: liveNotificationContent, pushType: nil)
                NSLog(
                    "[createLiveNotification] Successfully created live notification with ID: \(liveNotification.id)"
                )
                result(liveNotification.id)
            } catch {
                NSLog(
                    "[createLiveNotification] Failed to create live notification: \(error.localizedDescription)"
                )
                result(
                    FlutterError(
                        code: "CREATE_ACTIVITY_FAILED",
                        message: "Failed to create live notification",
                        details: error.localizedDescription))
            }
        }
    }

    @available(iOS 16.2, *)
    private func updateLiveNotification(
        id: String, title: String, message: String, result: @escaping FlutterResult
    ) {
        NSLog(
            "[updateLiveNotification] Updating live notification with ID: \(id), title: \(title), message: \(message)."
        )

        guard
            let liveNotification = Activity<LiveNotificationAttributes>.activities.first(where: {
                $0.id == id
            })
        else {
            NSLog("[updateLiveNotification] Could not find live notification with ID: \(id)")
            result(
                FlutterError(
                    code: "ACTIVITY_NOT_FOUND",
                    message: "Could not find live notification with ID: \(id)", details: nil))
            return
        }

        let updatedState = LiveNotificationAttributes.LiveNotificationState(
            title: title, message: message)

        Task {
            do {
                try await liveNotification.update(using: updatedState)
                NSLog(
                    "[updateLiveNotification] Successfully updated live notification with ID: \(id)"
                )
                result(id)
            } catch {
                NSLog(
                    "[updateLiveNotification] Failed to update live notification: \(error.localizedDescription)"
                )
                result(
                    FlutterError(
                        code: "UPDATE_ACTIVITY_FAILED",
                        message: "Failed to update live notification",
                        details: error.localizedDescription))
            }
        }
    }

    @available(iOS 16.2, *)
    private func dismiss(result: @escaping FlutterResult) {
        NSLog("[dismiss] Dismissing all running live activities.")

        // Fetch all active live activities for the app
        let allActivities = Activity<LiveNotificationAttributes>.activities

        if allActivities.isEmpty {
            NSLog("[dismiss] No live activities found to dismiss.")
            result(nil)
            return
        }

        Task {
            do {
                for activity in allActivities {
                    try await activity.end(dismissalPolicy: .immediate)
                    NSLog(
                        "[dismiss] Successfully dismissed live activity with ID: \(activity.id).")
                }
                result(nil)
            } catch {
                NSLog(
                    "[dismiss] Failed to dismiss live activities: \(error.localizedDescription)"
                )
                result(
                    FlutterError(
                        code: "DISMISS_ACTIVITY_FAILED",
                        message: "Failed to dismiss live activities",
                        details: error.localizedDescription
                    )
                )
            }
        }
    }

}

// MARK: - live notification Attributes
struct LiveNotificationAttributes: ActivityAttributes, Codable, Hashable {
    public struct LiveNotificationState: Codable, Hashable {
        var title: String
        var message: String
    }

    typealias ContentState = LiveNotificationState
}
