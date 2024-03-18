//
//  BoardView.swift
//  Chess
//
//  Created by arsh-zstch1313 on 27/02/24.
//

import Foundation
import UIKit

//I want it to select the n'th of a set of colours. So, I will create a list lists of 4 things[[lightSquare, darkSquare, lightFog, darkFog]]
class BoardView:UIView{
    var board:Bitboard!
    var winner:Bool? = nil
    var theme:ThemeStruct = ThemeStruct(lightSquare: .brownThemeLightSquare,
                                        darkSquare: .brownThemeDarkSquare,
                                        lightFog: UIImage.brownThemeLightFog,
                                        darkFog: UIImage.brownThemeDarkFog)
    var currentTurn = true{
        didSet{
            let currentPossibleMoves:[Int]
            if fog{
                setFogForCurrentPlayer()
            }
            if currentTurn{
                currentPossibleMoves = board.findPiecePositions(boardValue: board.blackPossibleMoves)
                
            }else{
                currentPossibleMoves = board.findPiecePositions(boardValue: board.whitePossibleMoves)
            }
            if board.squaresThatCanBlockTheCheck != nil{
                print("Squares that can block the check are not nil")
                let possibleMoves = Set(board.squaresThatCanBlockTheCheck!).intersection(currentPossibleMoves)
                print(possibleMoves)
                if possibleMoves.isEmpty{
                    winner = !currentTurn
                    print()
                    print()
                    print("CheckMate")
                    print()
                    print()
                    print()
                }else{
                    print("Squares that can block the check: \(board.squaresThatCanBlockTheCheck!)")
                }
            }
        }
    }
    var pov:Bool = true
    var initialSquare:SquareView? = nil
    var finalSquare:SquareView? = nil
    var pieceDetails:PieceDetails? = nil
    var possibleMoves:[Int]? = nil
    var fog:Bool = false
    
    init(frame:CGRect, board: Bitboard, squareSize:CGFloat, pov:Bool, fog:Bool = false, theme:ThemeStruct) {
        super.init(frame: frame)
        self.pov = pov
        self.board = board
        self.fog = fog
        self.theme = theme

        if pov{
            for row in (0..<8).reversed() {
                for col in (0..<8) {
                    let squareNumber = (8 * row + col)
                    let square = UInt64(1) << squareNumber
                    let squareView = SquareView(
                        frame: CGRect(x: CGFloat(col) * squareSize, y: CGFloat((7 - row)) * squareSize, width: squareSize, height: squareSize))
                    squareView.backgroundColor = (row + col) % 2 == 0 ? theme.darkSquare: theme.lightSquare
                    squareView.theme = theme
                    squareView.number = squareNumber
                    let tapGesture = UITapGestureRecognizer(target: self, action: #selector(squareTapped))
                    squareView.addGestureRecognizer(tapGesture)
                    addSubview(squareView)
                    if fog{
                        squareView.setFog(board: board, currentTurn: currentTurn)
                    }
                    squareView.createSquare(squareNumber: square, board: board)
                }
            }
        }else{
            for row in (0..<8) {
                for col in (0..<8).reversed() {
                    let squareNumber = (8 * row + col)
                    let square = UInt64(1) << squareNumber
                    let squareView = SquareView(
                        frame: CGRect(x: CGFloat((7 - col)) * squareSize, y: CGFloat(row) * squareSize, width: squareSize, height: squareSize))
                    squareView.backgroundColor = (row + col) % 2 == 0 ? theme.darkSquare : theme.lightSquare
                    squareView.number = squareNumber
                    let tapGesture = UITapGestureRecognizer(target: self, action: #selector(squareTapped))
                    squareView.addGestureRecognizer(tapGesture)
                    addSubview(squareView)
                    if fog{
                        squareView.setFog(board: board, currentTurn: currentTurn)
                    }
                    squareView.createSquare(squareNumber: square, board: board)
                }
            }
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    //MARK: - OBJ C Functions


@objc func squareTapped(_ sender: UITapGestureRecognizer) {
    
    
    
    //How to check for pinned pieces?
    // From king, start going down. If my piece encountered, take note, continue. If opp queen/rook encountered, add that square to pinned square
    // Do this for all directions. In piece generators, if the square is pinned, skip it
    
    if let tappedView = sender.view as? SquareView { //Checking if we tapped on a square
        let friendlyPiecePositions:[Int]
        let enemyPiecePositions:[Int]
        var myPieces:[UInt64:(UIImage, UInt64, (Int, Bool, Bool, Bool) -> [Int],String)] = [:]
        var opposingPieces:[UInt64:String] = [:]
        let currentSideInCheck:Bool
        
        if currentTurn{  //Checking who the friendly and enemy pieces are
            friendlyPiecePositions = findPiecePositions(boardValue:board!.whiteOccupied)
            enemyPiecePositions    = findPiecePositions(boardValue:board!.blackOccupied)
            currentSideInCheck = board.whiteUnderCheck
            
            for (key, value) in [
                (board.whiteKing,    (UIImage.kingWhite,  board.whiteOccupied, board.showKingMoves,   "K")),
                (board.whitePawns,   (UIImage.pawnWhite,  board.whiteOccupied, board.showPawnMoves,   "P")),
                (board.whiteQueens,  (UIImage.queenWhite, board.whiteOccupied, board.showQueenMoves,  "Q")),
                (board.whiteRooks,   (UIImage.rookWhite,  board.whiteOccupied, board.showRookMoves,   "R")),
                (board.whiteBishops, (UIImage.bishopWhite,board.whiteOccupied, board.showBishopMoves, "B")),
                (board.whiteKnights, (UIImage.horseWhite,board.whiteOccupied, board.showKnightMoves, "N"))
            ]{
                if key > 0 {
                    myPieces[key] = value
                }
            }
            let enemyPieces = [
                (board.blackKing,    "k"),
                (board.blackPawns,   "p"),
                (board.blackQueens,  "q"),
                (board.blackRooks,   "r"),
                (board.blackBishops, "b"),
                (board.blackKnights, "n")
            ]
            for (key, value) in enemyPieces{
                if key > 0 {
                    opposingPieces[key] = value
                }
            }
        }
        else{ //Checking who the friendly and enemy pieces are
            friendlyPiecePositions = findPiecePositions(boardValue:board.blackOccupied)
            enemyPiecePositions    = findPiecePositions(boardValue:board.whiteOccupied)
            currentSideInCheck = board.blackUnderCheck
            for (key, value) in [
                (board.blackKing,    (UIImage.kingBlack,  board.blackOccupied, board.showKingMoves,   "k")),
                (board.blackPawns,   (UIImage.pawnBlack,  board.blackOccupied, board.showPawnMoves,   "p")),
                (board.blackQueens,  (UIImage.queenBlack, board.blackOccupied, board.showQueenMoves,  "q")),
                (board.blackRooks,   (UIImage.rookBlack,  board.blackOccupied, board.showRookMoves,   "r")),
                (board.blackBishops, (UIImage.bishopBlack,board.blackOccupied, board.showBishopMoves, "b")),
                (board.blackKnights, (UIImage.horseBlack, board.blackOccupied, board.showKnightMoves, "n"))
            ] {
                if key > 0 {
                    myPieces[key] = value
                }
            }

            let enemyPieces = [
                (board.whiteKing,    "K"),
                (board.whitePawns,   "P"),
                (board.whiteQueens,  "Q"),
                (board.whiteRooks,   "R"),
                (board.whiteBishops, "B"),
                (board.whiteKnights, "N")
            ]
            for (key, value) in enemyPieces{
                if key > 0 {
                    opposingPieces[key] = value
                }
            }
        }
        if ((pieceDetails != nil) && (initialSquare != nil) && (possibleMoves != nil)){ //Checking if this is the second click
            
            print("Second Click")
            finalSquare = tappedView
            if(possibleMoves!.contains(finalSquare!.number)){
                
                var capturing = false
                var capturedPieceType:String = " "
                if(enemyPiecePositions.contains(finalSquare!.number)){
                    print("About to capture a piece")
                    capturing = true
                    for piecePosition in opposingPieces.keys{
                        if(piecePosition & (1 << finalSquare!.number) != 0){
                            capturedPieceType = opposingPieces[piecePosition]!
                            break
                        }
                    }
                }
                
                do{
                    if capturing{
                        print("Moving piece \(testPieces[pieceDetails!.pieceType]!) from \(initialSquare!.number) to \(finalSquare!.number) while capturing is \(capturing) and the piece being captured is \(capturedPieceType)")
                    }else{
                        print("Moving piece \(pieceDetails!.pieceType) from \(initialSquare!.number) to \(finalSquare!.number)")
                    }
                    
                    if (1 << initialSquare!.number & board.whiteKing != 0) || (1 << initialSquare!.number & board.blackKing != 0){
                        if castlingisHappening(){
                            movePiece(initialSquare: initialSquare!, finalSquare: finalSquare!.number, castling: true)
                        }else{
                            movePiece(initialSquare: initialSquare!, finalSquare: finalSquare!.number)
                        }
                        
                    }else{
                        if enPassantIsHappening(){
                            movePiece(initialSquare: initialSquare!, finalSquare: finalSquare!.number, enPassant: true)
                        }
                        else{
                            movePiece(initialSquare: initialSquare!, finalSquare: finalSquare!.number)
                        }
                    }
                    try board.makeMove(startingSquare: initialSquare!.number, endingSquare: finalSquare!.number, pieceType: pieceDetails!.pieceType, capturing: capturing, capturedPieceType: capturedPieceType)
                    
                    currentTurn.toggle()
                }catch let error as MyError{
                    print(error.message)
                }catch {
                    print("Something went wrong")
                }
                if let possibleMoves = possibleMoves, !possibleMoves.isEmpty {
                    toggleTraversibility(squares: possibleMoves)
                }
                removeClickedPieceDetails()
            }
            else{
                if let possibleMoves = possibleMoves, !possibleMoves.isEmpty {
                    toggleTraversibility(squares: possibleMoves)
                }
                removeClickedPieceDetails()
            }
        }else{ //Checking if this is the first click
            print("First Click")
            let selectedSquare = tappedView
            if (friendlyPiecePositions.contains((selectedSquare.number))){
                for pieceType in myPieces.keys{
                    if((1 << selectedSquare.number & pieceType) != 0){ //Checking which piece it is
                        
                        pieceDetails = PieceDetails(pieceImage: myPieces[pieceType]!.0, occupiedFriendlyPieces: myPieces[pieceType]!.1, moveGenerator: myPieces[pieceType]!.2,pieceType:myPieces[pieceType]!.3)
                        initialSquare = selectedSquare
                        possibleMoves = pieceDetails!.moveGenerator(initialSquare!.number, currentTurn, true, fog) //This is generating moves to go to, hence attacking = true, fog = true, should act as normal
                        if currentSideInCheck && myPieces[pieceType]!.3.lowercased() != "k"{
                            possibleMoves = Array(Set(possibleMoves!).intersection(Set(board.squaresThatCanBlockTheCheck!)))
                        }
                        break
                    }
                }
                
                if let possibleMoves = possibleMoves, !possibleMoves.isEmpty {
                    toggleTraversibility(squares: possibleMoves)
                }
            }else if (enemyPiecePositions.contains(Int(tappedView.number))){
                
                if let possibleMoves = possibleMoves, !possibleMoves.isEmpty {
                    toggleTraversibility(squares: possibleMoves)
                }
                removeClickedPieceDetails()
                print("Enemy piece for white")
            }else{
                if let possibleMoves = possibleMoves, !possibleMoves.isEmpty {
                    toggleTraversibility(squares: possibleMoves)
                }
                print("Empty square")
                removeClickedPieceDetails()
            }
        }
    }else{
        print("jgvgvff")
    }
}
    
//MARK: - Helper Functions
    
    func findPiecePositions(boardValue: UInt64) -> [Int] {
        var setBits = [Int]()
        for i in 0..<64 {
            if boardValue & (1 << i) != 0 {
                setBits.append(i)
            }
        }
        return setBits
    }

    func movePiece(initialSquare:SquareView, finalSquare:Int, enPassant:Bool = false, castling:Bool = false){
        
        let targetIndex = ((8 * (7 - (finalSquare/8))) + finalSquare%8)
        let originIndex = ((8 * (7 - (initialSquare.number/8))) + initialSquare.number%8)
        
        var targetSquare = subviews[targetIndex] as! SquareView
        var originSquare = subviews[originIndex] as! SquareView
        
        if enPassant{
            let pieceToBeTakenByEnPassant:Int = findPiecePositions(boardValue: board.canBeTakenByEnPassant)[0]
            let enPassantTargetIndex:Int = ((8 * (7 - (pieceToBeTakenByEnPassant/8))) + pieceToBeTakenByEnPassant%8)
            
            var squareToBeKilled = subviews[enPassantTargetIndex] as! SquareView
            
            if(squareToBeKilled.number != pieceToBeTakenByEnPassant){
                squareToBeKilled = subviews[63-enPassantTargetIndex] as! SquareView
            }
            squareToBeKilled.isOccupied = false
        }
        
        if castling{
            let rookToMove:Int
            let rookFinalPos:Int
            let pieceType:String
            switch finalSquare {
            case 2:
                rookToMove = 0
                rookFinalPos = 3
                pieceType = "R"
            case 6:
                rookToMove = 7
                rookFinalPos = 5
                pieceType = "R"
            case 62:
                rookToMove = 63
                rookFinalPos = 61
                pieceType = "r"
            case 58:
                rookToMove = 56
                rookFinalPos = 59
                pieceType = "r"
            default:
                rookToMove = -1
                rookFinalPos = -1
                pieceType = "Z"
            }
            if rookToMove != -1{
                let rookIndex:Int = ((8 * (7 - (rookToMove/8))) + rookToMove%8)
                var rookSquare = subviews[rookIndex] as! SquareView
                if rookSquare.number != rookToMove{
                    rookSquare = subviews[63-rookIndex] as! SquareView
                }
                movePiece(initialSquare: rookSquare, finalSquare: rookFinalPos)
                
                do {
                    try board.makeMove(startingSquare: rookSquare.number, endingSquare: rookFinalPos, pieceType: pieceType, capturing: false, capturedPieceType: " ")
                }
                catch let error as MyError{
                    print(error.message)
                }catch {
                    print("Something went wrong")
                }
            }else{
                print("YOU FUCKED UP THE FINAL SQUARES IN CASTLING")
            }
        }
        
        if targetSquare.number != finalSquare{
            targetSquare = subviews[63-targetIndex] as! SquareView
        }
        if(originSquare.number != initialSquare.number){
            originSquare = subviews[63-originIndex] as! SquareView
        }
        
        print("Moved to \(targetSquare.number), from \(originSquare.number)")
        
        targetSquare.isOccupied = false
        targetSquare.setPieceImage(pieceImage: originSquare.pieceImageView!.image!)
        originSquare.isOccupied = false
    }
    
    func toggleTraversibility(squares:[Int]){
        for squareNumber in squares{
            let targetIndex = ((8 * (7 - (squareNumber/8))) + squareNumber%8)
            var targetSquare = subviews[targetIndex] as! SquareView
            if targetSquare.number == squareNumber{
                targetSquare.canBeReached.toggle()
            }else{
                targetSquare = subviews[63-targetIndex] as! SquareView
                targetSquare.canBeReached.toggle()
            }
        }
    }
    
    func removeClickedPieceDetails(){
        self.initialSquare = nil
        self.possibleMoves = nil
        self.pieceDetails = nil
    }
    
    func enPassantIsHappening()->Bool{
        return (findPiecePositions(boardValue: board.canTakeByEnPassant).contains(initialSquare!.number)) && (findPiecePositions(boardValue:board.squareThatCanBeTakenByEnPassant).contains(finalSquare!.number))
    }
    
    func castlingisHappening()->Bool{
        return abs(initialSquare!.number - finalSquare!.number) == 2
    }
    
    func setFogForCurrentPlayer(){
        var notFoggy:Set<Int> = []
        if currentTurn{
            notFoggy = Set(board.findPiecePositions(boardValue: board.whitePossibleMoves)).union(Set(board.findPiecePositions(boardValue: board.whiteOccupied)))
        }else{
            notFoggy = Set(board.findPiecePositions(boardValue: board.blackPossibleMoves)).union(Set(board.findPiecePositions(boardValue: board.blackOccupied)))
        }
        //Traverse through the list of subviews via index
        for i in 0..<subviews.count{
            let currentSquare = subviews[i] as! SquareView
            if notFoggy.contains(currentSquare.number){
                currentSquare.underFog = false
            }else{
                currentSquare.underFog = true
            }
        }
    }
}



func bitReturner(lowerLimit: Int, upperLimit: Int, number: UInt64) -> UInt64 {
    // Calculate the number of bits between the lower and upper limits
    let numBits = upperLimit - lowerLimit - 1
    
    // Extract the desired bits between the lower and upper limits
    let result = (number >> (lowerLimit + 1)) & ((1 << numBits) - 1)
    
    return result
}

