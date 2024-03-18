//
//  CheckmateScreen.swift
//  ChessRemade
//
//  Created by arsh-zstch1313 on 14/03/24.
//

import Foundation


import UIKit
import SnapKit

class CheckMateViewController: UIViewController {
    
    var checkmateImage:UIImage!
    var winImage:UIImage!
    //This will be the first screen
    
    let elementHolder = UIView()
    
    let titleImage = UIImageView()
    let secondTitleImage = UIImageView()
    let horseView = UIImageView()
    let queenView = UIImageView()
    
    init(winner:Bool) {
        super.init(nibName: nil, bundle: nil)
        if winner{
            self.checkmateImage = .checkmateBlack
            self.winImage = .whiteWins
        }else{
            self.checkmateImage = .checkmateWhite
            self.winImage = .blackWins
            
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.addSubview(elementHolder)
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
        
        view.backgroundColor = .checkmateBGColour
        
        elementHolder.snp.makeConstraints({(make) in
            make.center.equalToSuperview() // Center
            make.width.equalToSuperview().multipliedBy(47.0 / 81.0) // Width equals half of superview's width
            make.height.equalToSuperview().multipliedBy(18.0 / 108.0) // Height equals half of superview's height
        })
        
        titleImage.image = checkmateImage
        
        
        elementHolder.addSubview(titleImage)
        elementHolder.addSubview(secondTitleImage)
        
        titleImage.snp.makeConstraints({(make) in
            make.width.equalToSuperview().offset(-20)
            make.centerX.equalToSuperview()
            make.height.equalTo(titleImage.snp.width).multipliedBy(79.7/330.0).offset(-10)
        })
        
        secondTitleImage.snp.makeConstraints({(make) in
            make.width.equalTo(titleImage.snp.width).offset(-40)
            make.centerX.equalToSuperview()
            make.height.equalTo(secondTitleImage.snp.width).multipliedBy(7/47.0)
            make.top.equalTo(titleImage.snp.bottom).offset(16)
        })
        
        secondTitleImage.image = winImage
        
    }
    
    

}

