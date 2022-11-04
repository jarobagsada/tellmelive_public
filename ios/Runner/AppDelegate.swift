import UIKit
import Flutter
import GoogleMaps
import Firebase
import UserNotifications

@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
   /*if #available(iOS 10.0, *) {
    UNUserNotificationCenter.current().delegate = self as? UNUserNotificationCenterDelegate
    }*/
    FirebaseApp.configure()
    UNUserNotificationCenter.current().delegate = self
           UIApplication.shared.registerForRemoteNotifications()
           /*UNUserNotificationCenter.current().requestAuthorization(
               options: [.alert, .badge, .sound],
               completionHandler: { (granted, error) in
                   print("access granted!")
                   guard granted else { return }
                   DispatchQueue.main.async {
                       UIApplication.shared.registerForRemoteNotifications()
                       print("Registered: \(UIApplication.shared.isRegisteredForRemoteNotifications)")
                   }
               })*/
    GMSServices.provideAPIKey("AIzaSyAGtFtbnppF8eAPadjGU_ZcQAL0C8RrYvg")
    GeneratedPluginRegistrant.register(with: self)
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
    

   override func application(_ application: UIApplication,
                didRegisterForRemoteNotificationsWithDeviceToken
                    deviceToken: Data) {
       debugPrint("deviceToken")
       let token = deviceToken.map { String(format: "%02.2hhx", $0) }.joined()
       debugPrint(token)
       debugPrint("got token")
       let path = FileManager.default.urls(for: .documentDirectory,
                                    in: .userDomainMask)[0].appendingPathComponent("data.txt")

        print(path)
        if let stringData = token.data(using: .utf8) {
            try? stringData.write(to: path)
        }
    }

    override func application(_ application: UIApplication,
                didFailToRegisterForRemoteNotificationsWithError
                    error: Error) {
        debugPrint("failed to register token")
    }
    
    
    override func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        debugPrint(response)
        completionHandler();
     }
}



