import Foundation
import MapwizeForMapbox
import GPSIndoorLocationProvider

class MapwizeLocationProvider: ILIndoorLocationProvider {
    
    let maxLockedTime:TimeInterval = 120
    
    var timer:Timer?
    var gpsProvider:ILGPSIndoorLocationProvider!
    var started = false
    var locationLocked = false;
    
    override init() {
        super.init()
        self.delegates = []
        
        gpsProvider = ILGPSIndoorLocationProvider()
        gpsProvider.addDelegate(self)
    }
    
    override func supportsFloor() -> Bool {
        return true
    }
    
    override func start() {
        if !started {
            gpsProvider.start()
            started = true
        }
    }
    
    override func stop() {
        if started {
            gpsProvider?.stop()
            started = false
        }
    }
    
    override func isStarted() -> Bool {
        return started
    }
    
    func defineLocation(location:ILIndoorLocation) {
        timer?.invalidate()
        timer = Timer.scheduledTimer(timeInterval: maxLockedTime, target: self, selector: #selector(tick), userInfo: nil, repeats: true)
        locationLocked = true
        
        self.dispatchDidUpdate(location)
        
    }
    
    @objc func tick() {
        locationLocked = false
    }
}

extension MapwizeLocationProvider: ILIndoorLocationProviderDelegate {
    func provider(_ provider: ILIndoorLocationProvider!, didFailWithError error: Error!) {
        
    }
    
    func providerDidStart(_ provider: ILIndoorLocationProvider!) {
        
    }
    
    func providerDidStop(_ provider: ILIndoorLocationProvider!) {
        
    }
    
    
    func provider(_ provider: ILIndoorLocationProvider!, didUpdate location: ILIndoorLocation!) {
        if !locationLocked {
            self.dispatchDidUpdate(location)
        }
    }
    
}

