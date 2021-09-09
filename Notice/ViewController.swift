//
//  ViewController.swift
//  Notice
//
//  Created by sunny h on 2021/09/10.
//

import UIKit
import FirebaseRemoteConfig
import FirebaseAnalytics

class ViewController: UIViewController {
    
    var remoteConfig: RemoteConfig?
    
    override func viewDidLoad() {
        super.viewDidLoad()
         
        remoteConfig = RemoteConfig.remoteConfig()
        
        let setting = RemoteConfigSettings()
        // 최대한 자주 데이터를 가져오기
        setting.minimumFetchInterval = 0
        
        remoteConfig?.configSettings = setting
        
        // 각 키에대한 기본값 설정
        remoteConfig?.setDefaults(fromPlist: "RemoteConfigDefault")
        
        
        
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        getNotice()
    }
    
    


}


extension ViewController {
    func getNotice() {
        guard let remoteConfig = remoteConfig else { return }
        
        remoteConfig.fetch {[weak self] status, _ in
            if status == .success {
                remoteConfig.activate(completion: nil)
            } else {
                print("Config not fetched")
            }
            
            guard let self = self else { return }
            
            if !self.isNoticeHidden(remoteConfig) {
                let noticeVC = NoticeViewController(nibName: "NoticeViewController", bundle: nil)
                
                noticeVC.modalPresentationStyle = .custom
                noticeVC.modalTransitionStyle = .crossDissolve
                
                let title = (remoteConfig["title"].stringValue ?? "").replacingOccurrences(of: "\\n", with: "\n")
                let detail = (remoteConfig["detail"].stringValue ?? "").replacingOccurrences(of: "\\n", with: "\n")
                let date = (remoteConfig["date"].stringValue ?? "").replacingOccurrences(of: "\\n", with: "\n")
                
                noticeVC.noticeContents = (title: title, detail: detail, date: date)
                self.present(noticeVC, animated: true, completion: nil)
         
            }else{
                self.showEventAlert()
            }
        }
    }
    
    func isNoticeHidden(_ remoteConfig: RemoteConfig) -> Bool {
        return remoteConfig["isHidden"].boolValue
    }
}
//A/b Test
//AB Test
extension ViewController {
    func showEventAlert() {
        guard let remoteConfig = remoteConfig else { return }
        
        remoteConfig.fetch {[weak self] status, _ in
            if status == .success {
                remoteConfig.activate(completion: nil)
            } else {
                print("Config not fetched")
            }
            
            let message = remoteConfig["message"].stringValue ?? ""
            let confirmAction = UIAlertAction(title: "확인하기", style: .default) { action in
                Analytics.logEvent("promo tion_alert", parameters: nil)
            }
            let cancelAction = UIAlertAction(title: "취소", style: .cancel, handler: nil)
            
            let alertController = UIAlertController(title: "깜짝 이벤트", message: message, preferredStyle: .alert)
            
            alertController.addAction(confirmAction)
            alertController.addAction(cancelAction)
            
            self?.present(alertController, animated: true, completion: nil)
        }
    }
}
