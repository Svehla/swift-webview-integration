import UIKit

func asyncAlert(title: String, body: String) async -> Void {
    await withCheckedContinuation({ (continuation: CheckedContinuation<Void, Never>) -> Void in
        // should there by async or sync?
        DispatchQueue.main.async {
            let content = "\(body)"
            let alertController = UIAlertController(title: title, message: content, preferredStyle: .alert)
            alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: { alertAction in
                continuation.resume(returning: ())
            }))
            let window = UIApplication.shared.windows.first
            window?.rootViewController?.present(alertController, animated: true)
        }
    })
}

func justAlert(title: String, body: String) -> Void {
    let content = "\(body)"
    let alertController = UIAlertController(title: title, message: content, preferredStyle: .alert)
    alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
    let window = UIApplication.shared.windows.first
    window?.rootViewController?.present(alertController, animated: true)
}
