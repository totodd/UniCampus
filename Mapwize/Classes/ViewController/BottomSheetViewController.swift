import Foundation
import WebKit
import ionicons

class BottomSheetViewController : UIViewController {
    
    let placeView:PlaceView
    let webView:WKWebView
    let defaultBottomMargin:CGFloat!
    let defaultTopMargin:CGFloat!
    let placeViewHeight:CGFloat!
    var htmlContent:String?
    var isDeployed = false
    
    init(bottomMargin:CGFloat, topMargin:CGFloat) {
        self.placeView = PlaceView()
        self.webView = WKWebView()
        self.defaultBottomMargin = bottomMargin
        self.defaultTopMargin = topMargin
        self.placeViewHeight = 60
        super.init(nibName:nil, bundle:nil)
        self.setupViews()
        self.placeView.delegate = self
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupViews() {
        self.view.addSubview(self.placeView)
        self.view.addSubview(self.webView)
        self.placeView.frame = CGRect.init(x: 0, y: 0, width: self.view.frame.size.width, height: self.placeViewHeight)
        self.webView.frame = CGRect.init(x: 0, y: self.placeViewHeight+defaultBottomMargin, width: self.view.frame.size.width, height: self.view.frame.size.height - self.placeViewHeight - defaultBottomMargin)
    }
    
    func show() {
        UIView.animate(withDuration: 0.3) { [weak self] in
            let frame = self?.view.frame
            var yComponent:CGFloat;
            if #available(iOS 11.0, *) {
                yComponent = (self?.view.superview?.safeAreaLayoutGuide.layoutFrame.height)! + (self?.view.superview?.safeAreaInsets.top)! + (self?.view.superview?.safeAreaInsets.bottom)! -  self!.placeViewHeight - self!.defaultBottomMargin
            } else {
                yComponent = UIScreen.main.bounds.height -  self!.placeViewHeight - self!.defaultBottomMargin
            }
            self?.view.frame = CGRect.init(x:0, y:yComponent, width:frame!.width, height:frame!.height)
        }
    }
    
    func hide() {
        UIView.animate(withDuration: 0.3) { [weak self] in
            let frame = self?.view.frame
            let yComponent = UIScreen.main.bounds.height
            self?.view.frame = CGRect.init(x:0, y:yComponent, width:frame!.width, height:frame!.height)
        }
    }
    
    func setHtmlContent(content:String?) {
        htmlContent = content
        if content != nil {
            self.webView.loadHTMLString(content!, baseURL: nil)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let gesture = UIPanGestureRecognizer.init(target: self, action: #selector(BottomSheetViewController.panGesture))
        view.addGestureRecognizer(gesture)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        prepareBackgroundView()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    
    func prepareBackgroundView(){
        self.view.backgroundColor = .white
    }
    
    var lastTranslationY:CGFloat = 0.0
    @objc func panGesture(recognizer: UIPanGestureRecognizer) {
        if htmlContent != nil && htmlContent!.count > 0 {
            let translation = recognizer.translation(in: self.view)
            let y = self.view.frame.minY
            var nextY = y + translation.y
            if  nextY < 20 + defaultTopMargin {
                nextY = 20 + defaultTopMargin
            }
            self.view.frame = CGRect.init(x:0, y:nextY, width:view.frame.width, height:view.frame.height)
            recognizer.setTranslation(CGPoint.zero, in: self.view)
            if recognizer.state == .ended {
                if  lastTranslationY < 0 {
                    nextY = 20 + defaultTopMargin
                    self.isDeployed = true
                }
                else {
                    nextY = UIScreen.main.bounds.height - self.placeViewHeight - defaultBottomMargin
                    self.isDeployed = false
                }
                UIView.animate(withDuration: 0.3) { [weak self] in
                    let frame = self?.view.frame
                    self?.view.frame = CGRect.init(x:0, y:nextY, width:frame!.width, height:frame!.height)
                }
            }
            lastTranslationY = translation.y
        }
    }
}

extension BottomSheetViewController : PlaceViewDelegate {
    
    func didTapMoreDetails() {
        var nextY:CGFloat
        if self.isDeployed {
            nextY = UIScreen.main.bounds.height - self.placeViewHeight - defaultBottomMargin
            self.isDeployed = false
            self.placeView.moreDetailsImageView?.setImage(IonIcons.image(withIcon: ion_ios_more, iconColor: .black, iconSize: 30, imageSize: CGSize(width: 30, height: 30)), for: .normal)
        }
        else {
            nextY = 20 + defaultTopMargin
            self.isDeployed = true
            self.placeView.moreDetailsImageView?.setImage(IonIcons.image(withIcon: ion_android_close, iconColor: .black, iconSize: 30, imageSize: CGSize(width: 30, height: 30)), for: .normal)
        }
        UIView.animate(withDuration: 0.3) { [weak self] in
            let frame = self?.view.frame
            self?.view.frame = CGRect.init(x:0, y:nextY, width:frame!.width, height:frame!.height)
        }
    }
    
}
