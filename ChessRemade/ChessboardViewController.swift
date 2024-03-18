//
//  BoardViewController.swift
//  Chess
//
//  Created by arsh-zstch1313 on 23/02/24.
//
import UIKit
import Foundation
import SnapKit

class ChessboardViewController: UIViewController {
    
    var boardView: BoardView!
    var board:Bitboard! = createBoard(fog:true)
    var theme: ThemeStruct = ThemeStruct(lightSquare: .brownThemeLightSquare,
                                         darkSquare: .brownThemeDarkSquare,
                                         lightFog: UIImage.brownThemeLightFog,
                                         darkFog: UIImage.brownThemeDarkFog){
        didSet{
            viewDidLoad()
        }
    }
    var fog: Bool = false
    var themeChangeButton = UIButton()
    var showCheckmateButton = UIButton()
    
    init(fog:Bool){
        super.init(nibName: nil, bundle: nil)
        self.fog = fog
        self.board = createBoard(fog:true)
        self.theme = ThemeStruct(lightSquare: .brownThemeLightSquare,
                                   darkSquare: .brownThemeDarkSquare,
                                   lightFog: UIImage.brownThemeLightFog,
                                   darkFog: UIImage.brownThemeDarkFog)
        self.themeChangeButton = UIButton()
        self.showCheckmateButton = UIButton()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Create the boardView
        let squareSize = view.frame.width / 8.0
        boardView = BoardView(
            frame: CGRect(x: 0, y: 0, width: squareSize * 8.0, height: squareSize * 8.0),
            board: board,
            squareSize: squareSize,
            pov:true,
            fog: fog,
            theme: theme)
        boardView.center = view.center
        view.addSubview(boardView)
        
        view.addSubview(themeChangeButton)
        view.addSubview(showCheckmateButton)
        themeChangeButton.backgroundColor = .clear
        themeChangeButton.layer.borderColor = UIColor.white.cgColor
        themeChangeButton.layer.borderWidth = 2
        
        themeChangeButton.snp.makeConstraints({(make) in
            make.width.equalToSuperview().multipliedBy(0.3)
            make.height.equalTo(45.0)
            make.trailing.equalToSuperview().offset(-20.0)
            make.bottom.equalTo(boardView.snp.top).offset(-16.0)
        })
        themeChangeButton.layer.cornerRadius = 8.0
        themeChangeButton.setTitle("Change Theme", for: .normal)
        themeChangeButton.addTarget(self, action: #selector(changeTheme), for: .touchUpInside)
        
        showCheckmateButton.backgroundColor = .themeButtonColour
        
        showCheckmateButton.snp.makeConstraints({(make) in
            make.width.equalToSuperview().multipliedBy(0.3)
            make.height.equalTo(45.0)
            make.trailing.equalTo(themeChangeButton.snp.leading).offset(-20.0)
            make.bottom.equalTo(boardView.snp.top).offset(-16.0)
        })
        showCheckmateButton.layer.cornerRadius = 8.0
        showCheckmateButton.setTitle("Show Checkmate Screen", for: .normal)
        showCheckmateButton.addTarget(self, action: #selector(loadCheckmateScreen), for: .touchUpInside)
        
        
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(viewDragged(_:)))
        boardView.addGestureRecognizer(panGesture)
        view.backgroundColor = .shadowChessRed
        
        // Add squares to the board
    }
    
    //MARK: - OBJECTIVE C FUNCTIONS
    
    
    @objc func viewDragged(_ sender: UIPanGestureRecognizer) {
            switch sender.state {
            case .began:
                // Find the initial view based on the touch location
                let initialLocation = sender.location(in: view)
                let draggedView = findSubview(at: initialLocation)
                print("Drag started from: \(draggedView?.number ?? 404)")
            case .ended:
                // Find the final view based on the touch location
                let finalLocation = sender.location(in: view)
                let finalView = findSubview(at: finalLocation)
                print("Drag ended at: \(finalView?.number ?? 404)")
            default:
                break
            }
        }
    
    @objc func loadCheckmateScreen() {
            // Create the view controller you want to navigate to
        let winner = Int.random(in: 0...100)%2 == 0 ? true : false
        let newViewController = CheckMateViewController(winner: winner)
            
            // Push the new view controller onto the navigation stack
            navigationController?.pushViewController(newViewController, animated: true)
    }
    
    @objc func changeTheme(){
        let themes = [
            ThemeStruct(lightSquare: .blueThemeLightSquare,
                        darkSquare: .blueThemeDarkSquare,
                        lightFog: UIImage.blueThemeLightFog,
                        darkFog: UIImage.blueThemeLightFog),
            
                ThemeStruct(lightSquare: .lavenderThemeLightSquare,
                            darkSquare: .lavenderThemeDarkSquare,
                            lightFog: UIImage.lavenderThemeLightFog,
                            darkFog: UIImage.lavenderThemeLightFog),
            
                ThemeStruct(lightSquare: .brownThemeLightSquare,
                            darkSquare: .brownThemeDarkSquare,
                            lightFog: UIImage.brownThemeLightFog,
                            darkFog: UIImage.brownThemeLightFog)] 
        let currentTheme = self.theme
        
        var newTheme = self.theme
        
        while newTheme.darkFog  == currentTheme.darkFog{
            let randomIndex = Int.random(in: 0..<themes.count)
            newTheme = themes[randomIndex]
        }
        self.theme = newTheme
    }
        
    func findSubview(at location: CGPoint) -> SquareView? { //Helper function
        return view.hitTest(location, with: nil) as? SquareView
    }
    
    
    
    func declareWinner(){
        if boardView.winner != nil{
            if boardView.winner!{
                let winAlertController = UIAlertController(title: "Victory!", message: "White Has Won!!", preferredStyle: .alert)
                present(winAlertController, animated: true)
            }else{
                let winAlertController = UIAlertController(title: "Victory!", message: "Black Has Won!!", preferredStyle: .alert)
                present(winAlertController, animated: true)
            }
        }
    }
}


struct PieceDetails {
    var pieceImage: UIImage
    var occupiedFriendlyPieces: UInt64
    var moveGenerator: (Int, Bool, Bool, Bool) -> [Int]
    var pieceType:String
}
