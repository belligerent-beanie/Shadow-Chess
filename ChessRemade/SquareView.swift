//
//  SquareView.swift
//  Chess
//
//  Created by arsh-zstch1313 on 23/02/24.
//

import Foundation
import UIKit
import SnapKit

class SquareView: UIView {
    var number:Int = 404
    var theme:ThemeStruct = ThemeStruct(lightSquare: .brownThemeLightSquare,
                                        darkSquare: .brownThemeDarkSquare,
                                        lightFog: UIImage.brownThemeLightFog,
                                        darkFog: UIImage.brownThemeDarkFog)
    var pieceImageView: UIImageView? = nil{
        didSet{
            if let newPieceImageView = pieceImageView {
                addSubview(newPieceImageView)
                isOccupied = true
            }
        }
    }
    var movementIndicatorImageView: UIImageView? = nil{
        
        didSet{
            if let newMovementIndicatorImageView = movementIndicatorImageView {
                addSubview(newMovementIndicatorImageView) // Add it as a subview when it is not nil
                newMovementIndicatorImageView.snp.makeConstraints({ make in
                    make.edges.equalToSuperview()
                })
                if(isOccupied){
                    newMovementIndicatorImageView.image = .hoop
                }else{
                    newMovementIndicatorImageView.image = .dot
                }
            }
        }
    }
    var fogImageView:UIImageView? = nil{
        didSet{
            if let newFogImageView = fogImageView {
                addSubview(newFogImageView) // Add it as a subview when it is not nil
                newFogImageView.snp.makeConstraints({ make in
                    make.edges.equalToSuperview()
                })
                if [theme.darkSquare].contains(self.backgroundColor){
                    newFogImageView.image = theme.darkFog
                }else{
                    newFogImageView.image = theme.lightFog
                }
            }
        }
    }
            
    //States
    
    var isOccupied:Bool = false{
        didSet{
            if !(isOccupied){
                pieceImageView?.removeFromSuperview()
                pieceImageView = nil
            }else{
                pieceImageView?.snp.makeConstraints({ make in
                    make.edges.equalToSuperview()
                })
            }
        }
    }
    var isSelected:Bool = false
    var canBeReached:Bool = false{
        didSet{
            if canBeReached{ //If it can be reached
                self.movementIndicatorImageView = UIImageView()
                
            }else{ //If it cannot be reached
                self.movementIndicatorImageView?.removeFromSuperview()
                self.movementIndicatorImageView = nil
            }
        }
    }
    
    var underFog:Bool = false{
        didSet{
            if underFog{
                self.fogImageView = UIImageView()
            }else{ //If it cannot be reached
                self.fogImageView?.removeFromSuperview()
                self.fogImageView = nil
            }
        }
    }
    
    
    
//    if(I touch the view and isOccupied == false): nothing happens, and if something wasSelected, it stops being selected and if anything was being shown, it stops being shown
//    else if(I touch the square and it is occupied): I calculate all moves that can be seen then I call a function that says load movementIndicators and then if the squares are occupied, we set movementIndicatorImageView of a dot or a circle
//    else if(I touch the square and it is not in the can be occupied): everything disappears agains
    
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setPieceImage(pieceImage:UIImage){
        self.pieceImageView = UIImageView()
        self.pieceImageView?.image = pieceImage
    }
    
    func setFog(board:Bitboard, currentTurn:Bool){
        //Referring to whitePossibleMoves because this is called once when setting up the board for the first time
        var notFoggy:Set<Int> = []
        if currentTurn{
            notFoggy = Set(board.findPiecePositions(boardValue: board.whitePossibleMoves)).union(Set(board.findPiecePositions(boardValue: board.whiteOccupied)))
        }else{
            notFoggy = Set(board.findPiecePositions(boardValue: board.blackPossibleMoves)).union(Set(board.findPiecePositions(boardValue: board.blackOccupied)))
        }
        if notFoggy.contains(number){
            self.underFog = false
        }else{
            self.underFog = true
        }
        
    }
    
    func createSquare(squareNumber:UInt64, board:Bitboard){
        if squareNumber & board.whitePawns != 0 {
            self.setPieceImage(pieceImage: .pawnWhite)
        } else if squareNumber & board.whiteKnights != 0 {
            self.setPieceImage(pieceImage: .horseWhite)
        } else if squareNumber & board.whiteBishops != 0 {
            self.setPieceImage(pieceImage: .bishopWhite)
        } else if squareNumber & board.whiteRooks != 0 {
            self.setPieceImage(pieceImage: .rookWhite)
        } else if squareNumber & board.whiteQueens != 0 {
            self.setPieceImage(pieceImage: .queenWhite)
        } else if squareNumber & board.whiteKing != 0 {
            self.setPieceImage(pieceImage: .kingWhite)
        } else if squareNumber & board.blackPawns != 0 {
            self.setPieceImage(pieceImage: .pawnBlack)
        } else if squareNumber & board.blackKnights != 0 {
            self.setPieceImage(pieceImage: .horseBlack)
        } else if squareNumber & board.blackBishops != 0 {
            self.setPieceImage(pieceImage: .bishopBlack)
        } else if squareNumber & board.blackRooks != 0 {
            self.setPieceImage(pieceImage: .rookBlack)
        } else if squareNumber & board.blackQueens != 0 {
            self.setPieceImage(pieceImage: .queenBlack)
        } else if squareNumber & board.blackKing != 0 {
            self.setPieceImage(pieceImage: .kingBlack)
        }
    }
    
}
