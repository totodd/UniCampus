import Foundation
import MTBBarcodeScanner

protocol QrCodeScannerDelegate {
    func backFromCamera(url:String?)
}

class QrCodeScannerViewController: UIViewController {
    
    @IBOutlet var previewView: UIView!
    @IBOutlet var targetView: UIView!
    @IBOutlet var closeButton: UIButton!
    var scanner: MTBBarcodeScanner?
    var delegate: QrCodeScannerDelegate?
    var resultFound = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        scanner = MTBBarcodeScanner(previewView: previewView)
        closeButton.setTitle(NSLocalizedString("Cancel", comment: ""), for: .normal)
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        MTBBarcodeScanner.requestCameraPermission(success: { success in
            if success {
                do {
                    
                    self.scanner?.didStartScanningBlock = {
                        self.scanner?.scanRect = self.targetView.frame
                    }
                    
                    try self.scanner?.startScanning(resultBlock: { codes in
                        if !self.resultFound {
                            if let codes = codes {
                                for code in codes {
                                    self.resultFound = true
                                    let stringValue = code.stringValue!
                                    self.delegate?.backFromCamera(url: stringValue)
                                    self.dismiss(animated: true, completion: nil)
                                }
                            }
                        }
                    })
                } catch {
                    NSLog("Unable to start scanning")
                }
            } else {
                let alertController = UIAlertController(title: "Scanning Unavailable", message: "This app does not have permission to access the camera", preferredStyle: .alert)
                alertController.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
                self.present(alertController, animated: true, completion: nil)
            }
        })
        
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        self.scanner?.stopScanning()
        
        super.viewDidDisappear(animated)
    }
    
    @IBAction func closeButtonPressed(_ sender: Any) {
        delegate?.backFromCamera(url: nil)
        dismiss(animated: true, completion: nil)
    }
}
