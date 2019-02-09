import Foundation

class SideViewController : UIViewController {
    
    @IBOutlet weak var accessKeyLabel:UILabel!
    @IBOutlet weak var creditsLabel:UILabel!
    @IBOutlet weak var versionLabel:UILabel!
    @IBOutlet weak var aboutLabel:UILabel!
    @IBOutlet weak var contactLabel:UILabel!
    
    var mapController:MapwizeViewController!
    
    override func viewDidLoad() {
        let tapAccess = UITapGestureRecognizer(target: self, action: #selector(SideViewController.accessFunction))
        accessKeyLabel.isUserInteractionEnabled = true
        accessKeyLabel.addGestureRecognizer(tapAccess)
        
        let tapCredits = UITapGestureRecognizer(target: self, action: #selector(SideViewController.creditsFunction))
        creditsLabel.isUserInteractionEnabled = true
        creditsLabel.addGestureRecognizer(tapCredits)
        
        let tapAbout = UITapGestureRecognizer(target: self, action: #selector(SideViewController.aboutFunction))
        aboutLabel.isUserInteractionEnabled = true
        aboutLabel.addGestureRecognizer(tapAbout)
        
        let tapContact = UITapGestureRecognizer(target: self, action: #selector(SideViewController.contactFunction))
        contactLabel.isUserInteractionEnabled = true
        contactLabel.addGestureRecognizer(tapContact)
        
        let navControlller = self.revealViewController().frontViewController as! UINavigationController
        mapController = navControlller.childViewControllers.first as! MapwizeViewController
        
        versionLabel.text = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String
        
        accessKeyLabel.text = NSLocalizedString("Enter an acccess key", comment: "")
        aboutLabel.text = NSLocalizedString("About Mapwize", comment: "")
        contactLabel.text = NSLocalizedString("Contact us", comment: "")
        
        self.view.addGestureRecognizer(revealViewController().panGestureRecognizer())
        
    }
    
    @objc func accessFunction(sender:UITapGestureRecognizer) {
        mapController.revealLeftMenu()
        mapController.openAccessKeyAlert()
    }
    @objc func creditsFunction(sender:UITapGestureRecognizer) {
        mapController.revealLeftMenu()
        mapController.showCredits()
    }
    @objc func aboutFunction(sender:UITapGestureRecognizer) {
        mapController.revealLeftMenu()
        let application = UIApplication.shared
        let url = URL(string:"https://www.mapwize.io")
        application.openURL(url!)
    }
    @objc func contactFunction(sender:UITapGestureRecognizer) {
        mapController.revealLeftMenu()
        UIApplication.shared.openURL(URL(string: "mailto:support@mapwize.io")!)
    }
}
