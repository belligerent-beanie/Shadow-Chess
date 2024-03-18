//
//  ViewController.swift
//  ChessRemade
//
//  Created by arsh-zstch1313 on 06/03/24.
//

import UIKit
import SnapKit

class ViewController: UIViewController {
    //This will be the first screen
    
    let contentHolder = UIView()
    
    let titleImage = UIImageView()
    let singlePlayerButton = UIButton()
    let multiPlayerButton = UIButton()
    let horseView = UIImageView()
    let queenView = UIImageView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.addSubview(contentHolder)
        view.addSubview(horseView)
        view.addSubview(queenView)
        
        horseView.image = .chessHorse
        queenView.image = .chessQueen1
        
        horseView.snp.makeConstraints({(make) in
            make.bottom.equalToSuperview()
            make.leading.equalToSuperview()
            make.width.equalTo(281.33).multipliedBy(1.3)
            make.height.equalTo(462.19).multipliedBy(1.3)
        })
        
        queenView.snp.makeConstraints({(make) in
            make.top.equalToSuperview()
            make.trailing.equalToSuperview()
            make.width.equalTo(289.3)
            make.height.equalTo(422.59)
        })
        
        view.backgroundColor = .shadowChessRed
        
        contentHolder.snp.makeConstraints({(make) in
            make.center.equalToSuperview() // Center
            make.width.equalToSuperview().multipliedBy(12.0 / 27.0) // Width equals half of superview's width
            make.height.equalToSuperview().multipliedBy(5.0 / 18.0) // Height equals half of superview's height
        })
        
        titleImage.image = .splashEC5554
        
        
        
        contentHolder.addSubview(titleImage)
        
        titleImage.snp.makeConstraints({(make) in
            make.width.equalToSuperview().offset(-20)
            make.centerX.equalToSuperview()
            make.height.equalTo(titleImage.snp.width).multipliedBy(79.7/330.0)
        })
        

        contentHolder.addSubview(singlePlayerButton)
        contentHolder.addSubview(multiPlayerButton)
        
        singlePlayerButton.setTitle("Classic Chess", for: .normal)
        
        multiPlayerButton.setTitle("Shadow Chess", for: .normal)

        singlePlayerButton.layer.borderWidth = 1.0
        
        singlePlayerButton.titleLabel?.font = .systemFont(ofSize: 26.0)
        singlePlayerButton.layer.cornerRadius = 8.0
        singlePlayerButton.addTarget(self, action: #selector(loadClassicChess), for: .touchUpInside)
        singlePlayerButton.backgroundColor = .singlePlayerButtonColour
        singlePlayerButton.layer.borderColor = CGColor(red: 175.0, green: 137.0, blue:0.0 , alpha: 1.0)

        multiPlayerButton.layer.borderWidth = 1.0
        multiPlayerButton.titleLabel?.font = .systemFont(ofSize: 26.0)
        multiPlayerButton.layer.cornerRadius = 8.0
        multiPlayerButton.addTarget(self, action: #selector(loadShadowChess), for: .touchUpInside)
        multiPlayerButton.backgroundColor = .multiPlayerButtonColour
        
        multiPlayerButton.layer.borderColor = CGColor(red: 55.0, green: 183.0, blue:255.0 , alpha: 1.0)
        
        singlePlayerButton.snp.makeConstraints({(make) in
            make.width.equalToSuperview().offset(-4.0)
            make.height.equalTo(66.0)
            make.center.equalToSuperview()
        })
        
        multiPlayerButton.snp.makeConstraints({(make) in
            make.width.equalToSuperview().offset(-4.0)
            make.height.equalTo(66.0)
            make.topMargin.equalTo(singlePlayerButton.snp_bottomMargin).offset(27.0)
        })
        
        
        
        
    }
}

extension ViewController{
    @objc func loadClassicChess() {
            // Create the view controller you want to navigate to
        let boardViewController = ChessboardViewController(fog:false)
            
            // Push the new view controller onto the navigation stack
            navigationController?.pushViewController(boardViewController, animated: true)
    }
    @objc func loadShadowChess() {
            // Create the view controller you want to navigate to
        let boardViewController = ChessboardViewController(fog:true)
            navigationController?.pushViewController(boardViewController, animated: true)
    }

}
