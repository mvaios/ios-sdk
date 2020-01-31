//
//  APEMultipleStripsViewController.swift
//  ApisterKitDemo
//
//  Created by Hasan Sa on 24/02/2019.
//  Copyright © 2019 Apester. All rights reserved.
//

import UIKit
import WebKit
import ApesterKit

class APEMultipleStripsViewController: UIViewController {

    @IBOutlet private weak var collectionView: UICollectionView! {
        didSet {
            collectionView.showsHorizontalScrollIndicator = false
            collectionView.showsVerticalScrollIndicator = false
        }
    }

    private lazy var channelTokens: [String] = StripConfigurationsFactory.configurations.map { $0.channelToken }

    override func viewDidLoad() {
        super.viewDidLoad()
        // update stripView delegates
        channelTokens.forEach {
            APEStripViewService.shared.stripView(for: $0)?.delegate = self
        }
    }
}

extension APEMultipleStripsViewController: UICollectionViewDataSource {

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.channelTokens.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ReuseCellIdentifier", for: indexPath) as! APEStripCollectionViewCell
        guard indexPath.row < self.channelTokens.count else {
            return cell
        }
        let token = self.channelTokens[indexPath.row]
        let stripView = APEStripViewService.shared.stripView(for: token)
        cell.show(stripView: stripView, containerViewConroller: self)
        return cell
    }
}

extension APEMultipleStripsViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        guard indexPath.row < self.channelTokens.count else { return .zero }
        let token = self.channelTokens[indexPath.row]
        let stripView = APEStripViewService.shared.stripView(for: token)
        return CGSize(width: collectionView.bounds.width, height: stripView?.height ?? 0)
    }
}

extension APEMultipleStripsViewController: APEStripViewDelegate {

    func stripView(_ stripView: APEStripView, didUpdateHeight height: CGFloat) {
        self.collectionView.reloadData()
    }

    func stripView(_ stripView: APEStripView, didFinishLoadingChannelToken token: String) {}

    func stripView(_ stripView: APEStripView, didFailLoadingChannelToken token: String) {
        DispatchQueue.main.async {
            APEStripViewService.shared.unloadStripViews(with: [stripView.configuration.channelToken])
            self.collectionView.reloadData()
        }
    }
}
