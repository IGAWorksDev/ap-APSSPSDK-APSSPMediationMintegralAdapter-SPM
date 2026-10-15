//
//  MintegralMediationRewardVideoAd.swift
//  MediationMintegral
//
//  Created by Odin.송황호 on 7/8/24.
//

import UIKit

import APSSPSDK
import MTGSDKReward


final class MintegralMediationRewardVideoAd: NSObject {
    
    weak var delegate: APSSPRewardVideoAdapterDelegate?
    
    private let placementId: String
    
    private let unitID: String
    
    private let rewardID: String
    
    private weak var rootViewController: UIViewController?
    
    private var rewardVideoAd = MTGRewardAdManager.sharedInstance()
    
    
    init(placementId: String, unitID: String, rewardID: String, rootViewController: UIViewController?) {
        self.placementId = placementId
        self.unitID = unitID
        self.rewardID = rewardID
        self.rootViewController = rootViewController
    }
    
    public func present(from: UIViewController, completion: @escaping () -> Void) {
        if rewardVideoAd.isVideoReadyToPlay(withPlacementId: placementId, unitId: unitID) {
            rewardVideoAd.showVideo(withPlacementId: placementId,
                                    unitId: unitID,
                                    withRewardId: rewardID,
                                    userId: "",
                                    delegate: self,
                                    viewController: from)
        }
        else {
            delegate?.rewardVideoShowFail(message: "")
        }
    }
    
    func load() {
        guard !unitID.isEmpty else {
            APLogger.error("Mintegral RewardVideo unitID is empty")
            delegate?.rewardVideoLoadFail(error: .nextMediation, errorMessage: "unitID is empty")
            return
        }
        
        APLogger.debug("Start Mintegral RewardVideo load,  placementId: \(placementId), unitId: \(unitID), rewardID: \(rewardID)")
        rewardVideoAd.loadVideo(withPlacementId: placementId, unitId: unitID, delegate: self)
    }
        
}


extension MintegralMediationRewardVideoAd: MTGRewardAdLoadDelegate, MTGRewardAdShowDelegate {
    func onAdLoadSuccess(_ placementId: String?, unitId: String?) {
        delegate?.rewardVideoLoadSuccess()
    }
    
    func onVideoAdLoadFailed(_ placementId: String?, unitId: String?, error: any Error) {
        APLogger.error("Mintegra RewardVideo Error: \(error.localizedDescription)")
        delegate?.rewardVideoLoadFail(error: .nextMediation, errorMessage: error.localizedDescription)
    }
    
    func onVideoAdShowSuccess(_ placementId: String?, unitId: String?) {
        delegate?.rewardVideoShowSuccess(message: "Mintegral RewardVideo ShowSuccess")
    }
    
    func onVideoAdShowFailed(_ placementId: String?, unitId: String?, withError error: any Error) {
        APLogger.error("Mintegra RewardVideo Error: \(error.localizedDescription)")
        delegate?.rewardVideoLoadFail(error: .nextMediation, errorMessage: error.localizedDescription)
    }
    
    func onVideoAdClicked(_ placementId: String?, unitId: String?) {
        delegate?.rewardVideoClicked(message: "Mintegral RewardVideo Click")
    }
    
    func onVideoAdDidClosed(_ placementId: String?, unitId: String?) {
        delegate?.rewardVideoClosed(message: "Mintegral RewardVideo Closed")
    }
    
    /// 광고 종료. `converted` 가 리워드 인정 여부다. **완료 통보는 이 콜백을 기준으로 한다.**
    ///
    /// 이전에는 `onVideoPlayCompleted`(영상 재생 완료)에서 무조건 완료를 통보해
    /// 리워드 미인정 건도 완료로 계상됐다 — 과다 정산 소지.
    /// ObjC(`MintegralAdapter.m:567`) / AOS(`MintegralAdapter.java:625 rewardInfo.isCompleteView()`)
    /// 와 동일하게 `converted` 를 반영한다.
    ///
    /// - Note: `converted == false`(미완주)는 현재 전달 수단이 없다.
    ///   `rewardVideoCompleted()` 에 완료 여부 파라미터가 없어 ObjC
    ///   `onCompleteTrackingEvent:isCompleted:` 처럼 false 를 보낼 수 없다.
    ///   프로토콜 시그니처 확장은 별도 과제.
    func onVideoAdDismissed(_ placementId: String?, unitId: String?,
                            withConverted converted: Bool, withRewardInfo rewardInfo: MTGRewardAdInfo?) {
        APLogger.debug("Mintegral RewardVideo dismissed, converted: \(converted)")
        if converted {
            delegate?.rewardVideoCompleted()
        }
    }

    /// 영상 재생 완료. 리워드 인정과는 별개다. 완료 통보는 `onVideoAdDismissed` 에서 한다.
    func onVideoPlayCompleted(_ placementId: String?, unitId: String?) {
        APLogger.debug("Mintegral RewardVideo videoPlayCompleted")
    }

}
