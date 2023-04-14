

import SwiftUI
import MessageUI

class SendMail: NSObject, MFMailComposeViewControllerDelegate{
    func sendMail(){
        if MFMailComposeViewController.canSendMail(){
            let mail = MFMailComposeViewController()
            mail.mailComposeDelegate = self
            mail.setToRecipients(["tranduy10062k@gmail.com"])
            mail.setSubject("")
            mail.setMessageBody("", isHTML: true)
            UIApplication.shared.windows.first?.rootViewController?.present(mail, animated: true, completion: nil)
        }else{
            print("Unable to send email")
        }
    }
    
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        controller.dismiss(animated: true)
    }
}
