//
//  BitBoard.swift
//  Chess
//
//  Created by arsh-zstch1313 on 23/02/24.
//

import Foundation

struct Bitboard {
    var whitePawns: UInt64 = 0
    var whiteKnights: UInt64 = 0
    var whiteBishops: UInt64 = 0
    var whiteRooks: UInt64 = 0
    var whiteQueens: UInt64 = 0
    var whiteKing: UInt64 = 0
    
    var blackPawns: UInt64 = 0
    var blackKnights: UInt64 = 0
    var blackBishops: UInt64 = 0
    var blackRooks: UInt64 = 0
    var blackQueens: UInt64 = 0
    var blackKing: UInt64 = 0
    
    var occupied: UInt64 = 0
    var empty: UInt64 = 0xFFFFFFFFFFFFFFFF
    var fog:Bool = false
    
    var whiteOccupied: UInt64 = 0xFFFFFFFFFFFFFFFF
    var blackOccupied: UInt64 = 0xFFFFFFFFFFFFFFFF
    
    var whiteAttacking: UInt64 = 0xFFFFFFFFFFFFFFFF{
        didSet{
            print("White Attacking: \(findPiecePositions(boardValue: whiteAttacking))")
        }
    }
    var blackAttacking: UInt64 = 0xFFFFFFFFFFFFFFFF{
        didSet{
            print("Black Attacking: \(findPiecePositions(boardValue: blackAttacking))")
        }
    }
    
    var whitePossibleMoves: UInt64 = 4294901760
    var blackPossibleMoves: UInt64 = 281470681743360
    
    var canBeTakenByEnPassant:UInt64 = 0
    var canTakeByEnPassant:UInt64 = 0
    var squareThatCanBeTakenByEnPassant:UInt64 = 0
    
    var blackUnderCheck: Bool = false{
        didSet{
            if blackUnderCheck{
                updatePossibleMovesWhenUnderCheck(side: false)
            }else{
                print("Black No longer under check")
            }
        }
    }
    var whiteUnderCheck: Bool = false{
        didSet{
            if whiteUnderCheck{
                updatePossibleMovesWhenUnderCheck(side: true)
            }else{
                print("white No longer under check")
            }
        }
    }
    
    var noOfCheckingPieces:Int? = nil
    var squaresThatCanBlockTheCheck: [Int]? = nil
    var pinnedPieces:UInt64 = 0{
        didSet{
            print("The pinned squares are: \(findPiecePositions(boardValue: pinnedPieces))")
        }
    }
    
    var blackCanCastleQueenSide:Bool? = false{
        didSet{
            guard let a = blackCanCastleQueenSide else{
//                print("Black queenside castling is nil")
                return
            }
//            print("Black can castle queenside: \(a)")
            
        }
    }
    var blackCanCastleKingSide:Bool? = false{
        didSet{
            guard let a = blackCanCastleKingSide else{
//                print("Black kingside castling is nil")
                return
            }
//            print("Black can castle kingside: \(a)")
        }
    }
    var whiteCanCastleQueenSide:Bool? = false{
        didSet{
            guard let a = whiteCanCastleQueenSide else{
//                print("White queenside castling is nil")
                return
            }
//            print("White can castle queenside: \(a)")
        }
    }
    var whiteCanCastleKingSide:Bool? = false{
        didSet{
            guard let a = whiteCanCastleKingSide else{
//                print("White kingside castling is nil")
                return
            }
//            print("White can castle kingside: \(a)")
        }
    }
}


extension Bitboard{
    func showPawnMoves(startingSquare: Int, pov: Bool, attacking: Bool = true, fog:Bool = false) -> [Int] {
        
        if (1 << startingSquare & pinnedPieces) != 0{
            return []
        }
        let row = startingSquare / 8
        var moves = [Int]()
        let friendlyPieces: UInt64
        let enemyPieces: UInt64
        let oneStepForward: Int
        let twoStepsForward: Int
        let diagonallyRight: Int
        let diagonallyLeft: Int
        let originalRow: Int
        let board = self
        
        if pov {
            friendlyPieces = board.whiteOccupied
            enemyPieces = board.blackOccupied
            oneStepForward = startingSquare + 8
            twoStepsForward = startingSquare + 16
            diagonallyRight = startingSquare + 9
            diagonallyLeft = startingSquare + 7
            originalRow = 1
        } else {
            friendlyPieces = board.blackOccupied
            enemyPieces = board.whiteOccupied
            oneStepForward = startingSquare - 8
            twoStepsForward = startingSquare - 16
            diagonallyRight = startingSquare - 7
            diagonallyLeft = startingSquare - 9
            originalRow = 6
        }
        
        if !(attacking || fog){ //Case where you're not attacking and not in fog. AKA, normal chess these squares are guarded by the pawns, aka kings cannot enter
            moves.append(diagonallyLeft)
            moves.append(diagonallyRight)
        }else {
            if ((1 << diagonallyLeft) & enemyPieces != 0) || (canEnPassant(originSquare: startingSquare, destinationSquare: diagonallyLeft)) { 
                //If there's an enemy piece to the left or if you can en passant, then add that move
                // This is true for both fog and normal
                moves.append(diagonallyLeft)
            }
            
            
            if ((1 << diagonallyRight) & enemyPieces != 0) || (canEnPassant(originSquare: startingSquare, destinationSquare: diagonallyRight)) {
                moves.append(diagonallyRight)
            }
            
            if ((1 << oneStepForward) & (friendlyPieces ^ enemyPieces) == 0){
                //If there's nothing in front of you, then it's a viable move
                
                moves.append(oneStepForward)
                if (row == originalRow) && !((1 << twoStepsForward) & (friendlyPieces ^ enemyPieces) != 0) {
                    moves.append(twoStepsForward)
                }
            }
        }
        return moves
    }
    
    func showKnightMoves(startingSquare: Int, pov: Bool, attacking: Bool = true, fog:Bool = false) -> [Int] {
        if (1 << startingSquare & pinnedPieces) != 0 && attacking{
            return []
        }
        print("Knight's starting square: \(startingSquare)")
        print("Pinned Pieces = \(findPiecePositions(boardValue: pinnedPieces))")
        let row = startingSquare / 8
        let column = startingSquare % 8
        var knightMoves = [Int]()
        let friendlyPieces: UInt64
        let board = self
        
        if pov {
            friendlyPieces = board.whiteOccupied
        } else {
            friendlyPieces = board.blackOccupied
        }
        
        if row >= 2 {
            if column <= 6 {
                let currentSquare = 8 * (row - 2) + (column + 1)
                if ( ((1 << currentSquare) & friendlyPieces) == 0) || !attacking { //If there isn't a friendly piece or if you're defending, add it to moves
                    knightMoves.append(currentSquare)
                }
            }
            if column >= 1 {
                let currentSquare = 8 * (row - 2) + (column - 1)
                if ((1 << currentSquare) & friendlyPieces == 0) || !attacking {
                    knightMoves.append(currentSquare)
                }
            }
        }
        if row >= 1 {
            if column <= 5 {
                let currentSquare = 8 * (row - 1) + (column + 2)
                if ((1 << currentSquare) & friendlyPieces == 0) || !attacking {
                    knightMoves.append(currentSquare)
                }
            }
            if column >= 2 {
                let currentSquare = 8 * (row - 1) + (column - 2)
                if ((1 << currentSquare) & friendlyPieces == 0) || !attacking {
                    knightMoves.append(currentSquare)
                }
            }
        }
        if row <= 6 {
            if column >= 2 {
                let currentSquare = 8 * (row + 1) + (column - 2)
                if ((1 << currentSquare) & friendlyPieces == 0) || !attacking {
                    knightMoves.append(currentSquare)
                }
            }
            if column <= 5 {
                let currentSquare = 8 * (row + 1) + (column + 2)
                if ((1 << currentSquare) & friendlyPieces == 0) || !attacking {
                    knightMoves.append(currentSquare)
                }
            }
        }
        if row <= 5 {
            if column <= 6 {
                let currentSquare = 8 * (row + 2) + (column + 1)
                if ((1 << currentSquare) & friendlyPieces == 0) || !attacking {
                    knightMoves.append(currentSquare)
                }
            }
            if column >= 1 {
                let currentSquare = 8 * (row + 2) + (column - 1)
                if ((1 << currentSquare) & friendlyPieces == 0) || !attacking {
                    knightMoves.append(currentSquare)
                }
            }
        }
        
        return knightMoves
    }
    
    func showRookMoves(startingSquare: Int, pov: Bool, attacking: Bool = true, fog:Bool = false) -> [Int] {
        
        if ((1 << startingSquare & pinnedPieces) != 0) && attacking{
            return []
        }
        var moves = [Int]()
        let friendlyPieces: UInt64
        let enemyPieces: UInt64
        let board = self
        
        if pov {
            friendlyPieces = board.whiteOccupied
            enemyPieces = board.blackOccupied
        } else {
            friendlyPieces = board.blackOccupied
            enemyPieces = board.whiteOccupied
        }
        
        // For up
        var currentSquare = startingSquare// 29
        let rowsAbove = (63 - startingSquare) / 8 //3
        for _ in 0..<rowsAbove {
            currentSquare += 8 //29+8
            if (1 << currentSquare) & friendlyPieces != 0 { //If friendly piece, don't add it unless you're not attacking
                if !attacking {
                    moves.append(currentSquare) //29+8
                }
                break
            } else if (1 << currentSquare) & enemyPieces != 0 { //If enemy piece, add it and break
                moves.append(currentSquare)
                break
            }
            moves.append(currentSquare)
        }
        
        // For down
        currentSquare = startingSquare
        let rowsBelow = startingSquare / 8
        for _ in 0..<rowsBelow {
            currentSquare -= 8
            if (1 << currentSquare) & friendlyPieces != 0 {
                if !attacking {
                    moves.append(currentSquare)
                }
                break
            } else if (1 << currentSquare) & enemyPieces != 0 {
                moves.append(currentSquare)
                break
            }
            moves.append(currentSquare)
        }
        
        // For left
        currentSquare = startingSquare
        while currentSquare % 8 > 0 {
            currentSquare -= 1
            if (1 << currentSquare) & friendlyPieces != 0 {
                if !attacking {
                    moves.append(currentSquare)
                }
                break
            } else if (1 << currentSquare) & enemyPieces != 0 {
                moves.append(currentSquare)
                break
            }
            moves.append(currentSquare)
        }
        
        // For right
        currentSquare = startingSquare
        while currentSquare % 8 < 7 {
            currentSquare += 1
            if (1 << currentSquare) & friendlyPieces != 0 {
                if !attacking {
                    moves.append(currentSquare)
                }
                break
            } else if (1 << currentSquare) & enemyPieces != 0 {
                moves.append(currentSquare)
                break
            }
            moves.append(currentSquare)
        }
        
        return moves
    }
    
    func showBishopMoves(startingSquare: Int, pov: Bool, attacking: Bool = true, fog:Bool = false) -> [Int] {
        
        if ((1 << startingSquare & pinnedPieces) != 0) && attacking{
            return []
        }
        var moves = [Int]()
        
        let friendlyPieces: UInt64
        let enemyPieces: UInt64
        let board = self
        
        if pov {
            friendlyPieces = board.whiteOccupied
            enemyPieces = board.blackOccupied
        } else {
            friendlyPieces = board.blackOccupied
            enemyPieces = board.whiteOccupied
        }
        
        let row = startingSquare / 8
        let column = startingSquare % 8
        
        let rowsAbove = 7 - row
        let columnsToTheRight = 7 - column
        let columnsToTheLeft = column
        let rowsBelow = row
        
        // Checking top right:
        var currentSquare = startingSquare
        let squaresInTopRight = min(rowsAbove, columnsToTheRight)
        for _ in 0..<squaresInTopRight {
            currentSquare += 9
            if (1 << currentSquare) & friendlyPieces != 0 {
                if !attacking {
                    moves.append(currentSquare)
                }
                break
            } else if (1 << currentSquare) & enemyPieces != 0 {
                moves.append(currentSquare)
                break
            }
            moves.append(currentSquare)
        }
        
        // Checking top left:
        currentSquare = startingSquare
        let squaresInTopLeft = min(rowsAbove, columnsToTheLeft)
        for _ in 0..<squaresInTopLeft {
            currentSquare += 7
            if (1 << currentSquare) & friendlyPieces != 0 {
                if !attacking {
                    moves.append(currentSquare)
                }
                break
            } else if (1 << currentSquare) & enemyPieces != 0 {
                moves.append(currentSquare)
                break
            }
            moves.append(currentSquare)
        }
        
        // Checking bottom right:
        currentSquare = startingSquare
        let squaresInBottomRight = min(rowsBelow, columnsToTheRight)
        for _ in 0..<squaresInBottomRight {
            currentSquare -= 7
            if (1 << currentSquare) & friendlyPieces != 0 {
                if !attacking {
                    moves.append(currentSquare)
                }
                break
            } else if (1 << currentSquare) & enemyPieces != 0 {
                moves.append(currentSquare)
                break
            }
            moves.append(currentSquare)
        }
        
        // Checking bottom left:
        currentSquare = startingSquare
        let squaresInBottomLeft = min(rowsBelow, columnsToTheLeft)
        for _ in 0..<squaresInBottomLeft {
            currentSquare -= 9
            if (1 << currentSquare) & friendlyPieces != 0 {
                if !attacking {
                    moves.append(currentSquare)
                }
                break
            } else if (1 << currentSquare) & enemyPieces != 0 {
                moves.append(currentSquare)
                break
            }
            moves.append(currentSquare)
        }
        
        return moves
    }
    
    func showQueenMoves(startingSquare: Int, pov: Bool, attacking: Bool = true, fog:Bool = false) -> [Int] {
        
        if ((1 << startingSquare & pinnedPieces) != 0) && attacking{
            return []
        }
        var moves = [Int]()
        moves += showBishopMoves(startingSquare: startingSquare, pov: pov, attacking: attacking)
        moves += showRookMoves(startingSquare: startingSquare, pov: pov, attacking: attacking)
        return moves
    }
    
    func showKingMoves(startingSquare: Int, pov: Bool, attacking: Bool = true, fog:Bool = false) -> [Int] {
        var moves = [Int]()
        let surroundingSquares = giveSurroundingSquares(sourceSquare: startingSquare)
        
        if !attacking{
            return surroundingSquares
        }else{
            for i in surroundingSquares{
                if i == 51 && !pov{
                    print("On square 51: \(isClear(square: i, king:true, pov: pov))")
                }
                if isClear(square: i, king:true, pov: pov){
                    moves.append(i)
                }
            }
            if blackCanCastleKingSide == true{
                if isClear(square: 62, king:true, pov: pov){
                    moves.append(62)
                }
            }
            if blackCanCastleQueenSide ?? false{
                if isClear(square: 58, king:true, pov: pov){
                    moves.append(58)
                }
            }
            if whiteCanCastleKingSide ?? false{
                if isClear(square: 6, king:true, pov: pov){
                    moves.append(6)
                }
            }
            if whiteCanCastleQueenSide ?? false{
                if isClear(square: 2, king:true, pov: pov){
                    moves.append(2)
                }
            }
            return moves
        }
    }
    
    func isClear(square:Int, king:Bool = false, pov:Bool) -> Bool{
        
        let board = self
        var opponentAttacking:UInt64 = 0
        var friendlyPieces:UInt64 = 0
        if king{
            if pov{
                opponentAttacking = board.blackAttacking
                friendlyPieces = board.whiteOccupied
            }else{
                opponentAttacking = board.whiteAttacking
                friendlyPieces = board.blackOccupied
            }
        } //If king, it's clear if Opponent isn't attacking that square and my piece isn't on that square
        if king{
            return ((opponentAttacking & 1 << square) + (friendlyPieces & 1 << square) == 0)
        }
        else{
            return ((friendlyPieces & 1 << square) != 0)
        }
        //For all other pieces, if it's not occupied by my pieces, it's clears
    }
    
    func giveSurroundingSquares(sourceSquare: Int) -> [Int]{
        var surroundingSquares = [Int]()
        let row = sourceSquare / 8
        let column = sourceSquare % 8
        
        if (row<7){
            let StraightUp = (8 * (row + 1)) + column
            surroundingSquares.append(StraightUp)
            if column<7{
                let TopRight = (8 * (row + 1)) + (column + 1)
                surroundingSquares.append(TopRight)
            }
            if column>0{
                let TopLeft = (8 * (row + 1)) + (column - 1)
                surroundingSquares.append(TopLeft)
            }
        }
        if column>0{
            let StraightLeft = sourceSquare - 1
            surroundingSquares.append(StraightLeft)
        }
        if column<7{
            let StraightRight = sourceSquare + 1
            surroundingSquares.append(StraightRight)
        }
        if row>0{
            let StraightDown = (8 * (row - 1)) + column
            surroundingSquares.append(StraightDown)
            if column<7{
                let BottomRight = (8 * (row - 1)) + (column + 1)
                surroundingSquares.append(BottomRight)
            }
            if column>0{
                let BottomLeft = (8 * (row - 1)) + (column - 1)
                surroundingSquares.append(BottomLeft)
            }
        }
        return surroundingSquares
    }
    
    func findPiecePositions(boardValue: UInt64) -> [Int] {
        var setBits = [Int]()
        for i in 0..<64 {
            if boardValue & (1 << i) != 0 {
                setBits.append(i)
            }
        }
        return setBits
    }
    
    func canEnPassant(originSquare:Int, destinationSquare:Int) ->Bool{
        return ((1 << destinationSquare) & (self.squareThatCanBeTakenByEnPassant) != 0) && (1 << originSquare & self.canTakeByEnPassant != 0)
    }
    
    func bitReturner(lowerLimit: Int, upperLimit: Int, number: UInt64) -> UInt64 {
        // Calculate the number of bits between the lower and upper limits
        let numBits = upperLimit - lowerLimit - 1
        
        // Extract the desired bits between the lower and upper limits
        let result = (number >> (lowerLimit + 1)) & ((1 << numBits) - 1)
        
        return result
    }
    
    func findVerticalSquaresBetween(pointA: Int, pointB: Int)->[Int]{ //Always have pointA = king
        let colA = pointA % 8
        let colB = pointB % 8
        var traversibleSquares:[Int] = []
        if colA != colB{
            return traversibleSquares
        }
        
        let startingPoint = min(pointA, pointB)+8
        let endingPoint = max(pointA, pointB)
        
        
        for square in stride(from: startingPoint, to: endingPoint, by: 8){
            traversibleSquares.append(square)
        }
        return traversibleSquares
    }
    
    func findHorizontalSquaresBetween(pointA: Int, pointB: Int)->[Int]{ //Always have pointA = king
        let rowA = pointA / 8
        let rowB = pointB / 8
        var traversibleSquares:[Int] = []
        if rowA != rowB{
            return traversibleSquares
        }
        
        let startingPoint = min(pointA, pointB)+1
        let endingPoint = max(pointA, pointB)
        
        
        for square in startingPoint..<endingPoint{
            traversibleSquares.append(square)
        }
        return traversibleSquares
    }
    
    func findTopRightBottomLeftDiagonalSquaresBetween(pointA:Int, pointB:Int) -> [Int]{
        var traversibleSquares:[Int] = []
        if (pointA - pointB) % 9 != 0{
            return traversibleSquares
        }
        
        let startingPoint = min(pointA, pointB)+9
        let endingPoint = max(pointA, pointB)
        
        
        for square in stride(from:startingPoint, to: endingPoint, by: 9){
            traversibleSquares.append(square)
        }
        return traversibleSquares
    }
    
    func findTopLeftBottomRightDiagonalSquaresBetween(pointA:Int, pointB:Int) -> [Int]{
        var traversibleSquares:[Int] = []
        if (pointA - pointB) % 7 != 0{
            return traversibleSquares
        }
        
        let startingPoint = min(pointA, pointB)+7
        let endingPoint = max(pointA, pointB)
        
        for square in stride(from: startingPoint, to: endingPoint, by: 7){
            traversibleSquares.append(square)
        }
        return traversibleSquares
    }
    
    
    
    
    func showBoard(){
        print("Black Occupied: \(findPiecePositions(boardValue: blackOccupied))")
        print("White Occupied: \(findPiecePositions(boardValue: whiteOccupied))")
        
        print("White king Pos: \(findPiecePositions(boardValue: whiteKing))")
        print("Black King pos: \(findPiecePositions(boardValue: blackKing))")
        
        print("White rooks: \(findPiecePositions(boardValue: whiteRooks))")
        print("Black rooks: \(findPiecePositions(boardValue: blackRooks))")
        
    }
    
    
    
    
}


extension Bitboard{
    //Only to be used after a move has been checked
    mutating func makeMove(startingSquare:Int, endingSquare:Int, pieceType:String, capturing:Bool, capturedPieceType:String) throws{
        let initialPosition:UInt64 = 1 << startingSquare
        let finalPosition:UInt64 = 1 << endingSquare
        lazy var enemyPawns:UInt64 = 69
        var pawnToTheSide:UInt64
        let kingPos:Int
        print("The piece that is moving is of type \(testPieces[pieceType]!)")
        
        
        //This is the part where I declare that this move blunders this pawn by allowing it to be taken by en passant
        if pieceType.lowercased() == "p" && abs(startingSquare - endingSquare) == 16{
            let directionalMultiplier = ((startingSquare - endingSquare) / abs(startingSquare - endingSquare))
            if pieceType == "p"{
                enemyPawns = self.whitePawns
            }else{
                enemyPawns = self.blackPawns
            }
            
            if endingSquare%8>0{ //Not in an edge column
                pawnToTheSide = 1 << (endingSquare - 1)
                if enemyPawns & pawnToTheSide != 0{
                    self.canTakeByEnPassant |= pawnToTheSide
                    self.canBeTakenByEnPassant = UInt64(1 << endingSquare)
                    self.squareThatCanBeTakenByEnPassant = UInt64(1 << (endingSquare + (directionalMultiplier * 8)))
                }
            }
            if endingSquare%8<7{// Not in an edge column
                pawnToTheSide = 1 << (endingSquare + 1)
                if enemyPawns & pawnToTheSide != 0{
                    self.canTakeByEnPassant |= pawnToTheSide
                    self.canBeTakenByEnPassant = UInt64(1 << endingSquare)
                    self.squareThatCanBeTakenByEnPassant = UInt64(1 << (endingSquare + (directionalMultiplier * 8)))
                }
            }
        }
        
        
        
        if pieceType == pieceType.uppercased() {
            self.whiteOccupied = self.whiteOccupied - initialPosition + finalPosition
            kingPos = findPiecePositions(boardValue: blackKing)[0]
            
        } else {
            self.blackOccupied = self.blackOccupied - initialPosition + finalPosition
            kingPos = findPiecePositions(boardValue: whiteKing)[0]
        }
        
        
        switch pieceType {
            case "R":
                self.whiteRooks   = self.whiteRooks - initialPosition + finalPosition
            case "N":
                self.whiteKnights = self.whiteKnights - initialPosition + finalPosition
            case "B":
                self.whiteBishops = self.whiteBishops - initialPosition + finalPosition
            case "Q":
                self.whiteQueens  = self.whiteQueens - initialPosition + finalPosition
            case "K":
                self.whiteKing    = self.whiteKing - initialPosition + finalPosition
                self.whiteCanCastleKingSide = nil
                self.whiteCanCastleQueenSide = nil
            case "P":
                self.whitePawns   = self.whitePawns - initialPosition + finalPosition
            case "r":
                self.blackRooks   = self.blackRooks - initialPosition + finalPosition
                
            case "n":
                self.blackKnights = self.blackKnights - initialPosition + finalPosition
            case "b":
                self.blackBishops = self.blackBishops - initialPosition + finalPosition
            case "q":
                self.blackQueens  = self.blackQueens - initialPosition + finalPosition
            case "k":
                self.blackKing    = self.blackKing - initialPosition + finalPosition
                self.blackCanCastleKingSide = nil
                self.blackCanCastleQueenSide = nil
            case "p":
                self.blackPawns   = self.blackPawns - initialPosition + finalPosition
            default:
                throw MyError("You're trying to move a pieceType that doesn't exist")
        }
        
        // This is the part where someone takes by enPassant and I manage it
        
        if(initialPosition & (self.canTakeByEnPassant) != 0) && (finalPosition & self.squareThatCanBeTakenByEnPassant != 0){
            if pieceType == "p"{
                self.whitePawns -= self.canBeTakenByEnPassant
                self.whiteOccupied -= self.canBeTakenByEnPassant
                self.blackPawns = (self.blackPawns - initialPosition) + finalPosition
            }else{
                self.blackPawns -= self.canBeTakenByEnPassant
                self.blackOccupied -= self.canBeTakenByEnPassant
                self.whitePawns = (self.whitePawns - initialPosition) + finalPosition
            }
        }
        
        if(capturing){
            print("The piece that is being captured is of type \(testPieces[capturedPieceType]!)")
            
            if capturedPieceType == capturedPieceType.uppercased() {
                self.whiteOccupied -= finalPosition
            } else {
                self.blackOccupied -= finalPosition
            }
            
            switch capturedPieceType {
            case "R":
                self.whiteRooks   = self.whiteRooks - finalPosition
            case "N":
                self.whiteKnights = self.whiteKnights - finalPosition
            case "B":
                self.whiteBishops = self.whiteBishops - finalPosition
            case "Q":
                self.whiteQueens  = self.whiteQueens -  finalPosition
            case "K":
                self.whiteKing    = self.whiteKing -  finalPosition
            case "P":
                self.whitePawns   = self.whitePawns -  finalPosition
            case "r":
                self.blackRooks   = self.blackRooks - finalPosition
            case "n":
                self.blackKnights = self.blackKnights -  finalPosition
            case "b":
                self.blackBishops = self.blackBishops - finalPosition
            case "q":
                self.blackQueens  = self.blackQueens -  finalPosition
            case "k":
                self.blackKing    = self.blackKing -  finalPosition
            case "p":
                self.blackPawns   = self.blackPawns - finalPosition
            default:
                throw MyError("You're trying to capture a pieceType that doesn't exist")
            }
        }
//        self.showBoard()
        self.occupied = self.blackOccupied | self.whiteOccupied
        self.updateAttacking()
        self.updateCastlingPrivileges()
        self.updateCheckStatus()
        if !fog{
            self.updatePinnedSquares(kingPos: kingPos)
        }
        self.updatePossibleMoves()
//        let pov = pieceType == pieceType.lowercased()
//        self.updateCheckStatus(pov: pov)
        
        
    }
    
    //makeMove will update the piece that moved and all of our occupied positions
    //This needs to update which squares anything is attacking
    //This has to include a change for pawns cuz they'll only attack left and right
    //It also has to include only unique values. If a square is covered once, a king can't go there. That's what we're trying to find
    
    mutating func updateAttacking(){
        //At this point, BlackOccupied and whiteOccupied have just been updated, a move has been made.
        var blackMoves = Set<Int>()
        var whiteMoves = Set<Int>()
        
        
        //Pawns
        let whitePawnPositions = findPiecePositions(boardValue: whitePawns)
        for pawn in whitePawnPositions{
            whiteMoves.formUnion(showPawnMoves(startingSquare: pawn, pov: true, attacking: false, fog:fog))
            print("Pawn in \(pawn) is attacking \(showPawnMoves(startingSquare: pawn, pov: true, attacking: false, fog:fog))")
        }
        
        
        //Knights
        let whiteKnightPositions = findPiecePositions(boardValue: whiteKnights)
        for knight in whiteKnightPositions{
            whiteMoves.formUnion(showKnightMoves(startingSquare: knight, pov: true, attacking: false))
            print("Knight in \(knight) is attacking \(showKnightMoves(startingSquare: knight, pov: true, attacking: false, fog:fog))")
        }
        //Bishops
        let whiteBishopPositions = findPiecePositions(boardValue: whiteBishops)
        for bishop in whiteBishopPositions{
            whiteMoves.formUnion(showBishopMoves(startingSquare: bishop, pov: true, attacking: false, fog: fog))
            print("bishop in \(bishop) is attacking \(showBishopMoves(startingSquare: bishop, pov: true, attacking: false, fog:fog))")
        }
        //Rooks
        let whiteRookPositions = findPiecePositions(boardValue: whiteRooks)
        for rook in whiteRookPositions{
            whiteMoves.formUnion(showRookMoves(startingSquare: rook, pov: true, attacking: false, fog: fog))
            print("rook in \(rook) is attacking \(showRookMoves(startingSquare: rook, pov: true, attacking: false, fog:fog))")
        }
        //Queens
        let whiteQueenPositions = findPiecePositions(boardValue: whiteQueens)
        for queen in whiteQueenPositions{
            whiteMoves.formUnion(showQueenMoves(startingSquare: queen, pov: true, attacking: false, fog: fog))
            print("queen in \(queen) is attacking \(showQueenMoves(startingSquare: queen, pov: true, attacking: false, fog:fog))")
        }
        //King  //PROBLEM PIECE
        let whiteKingPositions = findPiecePositions(boardValue: whiteKing)
        for king in whiteKingPositions{
            whiteMoves.formUnion(showKingMoves(startingSquare: king, pov: true, attacking: false, fog: fog))
            print("king in \(king) is attacking \(showKingMoves(startingSquare: king, pov: true, attacking: false, fog:fog))")
        }
    
        
        //Black
        
        
        //Pawns
        let blackPawnPositions = findPiecePositions(boardValue: blackPawns)
        for pawn in blackPawnPositions{
            blackMoves.formUnion(showPawnMoves(startingSquare: pawn, pov: false, attacking: false))
        }
        //Knights
        let blackKnightPositions = findPiecePositions(boardValue: blackKnights)
        for knight in blackKnightPositions{
            blackMoves.formUnion(showKnightMoves(startingSquare: knight, pov: false, attacking: false))
        }
        //Bishops
        let blackBishopPositions = findPiecePositions(boardValue: blackBishops)
        for bishop in blackBishopPositions{
            blackMoves.formUnion(showBishopMoves(startingSquare: bishop, pov: false, attacking: false))
        }
        //Rooks
        let rookPositions = findPiecePositions(boardValue: blackRooks)
        for rook in rookPositions{
            blackMoves.formUnion(showRookMoves(startingSquare: rook, pov: false, attacking: false))
        }
        //Queens
        let blackQueenPositions = findPiecePositions(boardValue: blackQueens)
        for queen in blackQueenPositions{
            blackMoves.formUnion(showQueenMoves(startingSquare: queen, pov: false, attacking: false))
        }
        //King
        let blackKingPositions = findPiecePositions(boardValue: blackKing)
        for king in blackKingPositions{
            blackMoves.formUnion(showKingMoves(startingSquare: king, pov: false, attacking: false))
        }
        
        var blackMovesBitBoard:UInt64 = 0
        var whiteMovesBitBoard:UInt64 = 0
        for i in whiteMoves{
            whiteMovesBitBoard |= 1 << i
        }
        for i in blackMoves{
            blackMovesBitBoard |= 1 << i
        }
        self.whiteAttacking = whiteMovesBitBoard
        self.blackAttacking = blackMovesBitBoard
        
    }
    
    mutating func updatePossibleMoves(){
        //At this point, BlackOccupied and whiteOccupied have just been updated, a move has been made.
        var blackMoves = Set<Int>()
        var whiteMoves = Set<Int>()
        
        
        //Pawns
        let whitePawnPositions = findPiecePositions(boardValue: whitePawns)
        for pawn in whitePawnPositions{
            if pawn == 28{
                print("Pawn at 28 can attack: \(showPawnMoves(startingSquare: pawn, pov: true))")
            }
            whiteMoves.formUnion(showPawnMoves(startingSquare: pawn, pov: true))
        }
        
        
        //Knights
        let whiteKnightPositions = findPiecePositions(boardValue: whiteKnights)
        for knight in whiteKnightPositions{
            whiteMoves.formUnion(showKnightMoves(startingSquare: knight, pov: true))
        }
        //Bishops
        let whiteBishopPositions = findPiecePositions(boardValue: whiteBishops)
        for bishop in whiteBishopPositions{
            whiteMoves.formUnion(showBishopMoves(startingSquare: bishop, pov: true))
        }
        //Rooks
        let whiteRookPositions = findPiecePositions(boardValue: whiteRooks)
        for rook in whiteRookPositions{
            whiteMoves.formUnion(showRookMoves(startingSquare: rook, pov: true))
        }
        //Queens
        let whiteQueenPositions = findPiecePositions(boardValue: whiteQueens)
        for queen in whiteQueenPositions{
            whiteMoves.formUnion(showQueenMoves(startingSquare: queen, pov: true))
        }
        //King  //PROBLEM PIECE
        let whiteKingPositions = findPiecePositions(boardValue: whiteKing)
        for king in whiteKingPositions{
            whiteMoves.formUnion(showKingMoves(startingSquare: king, pov: true))
        }
    
        
        //Black
        
        
        //Pawns
        let blackPawnPositions = findPiecePositions(boardValue: blackPawns)
        for pawn in blackPawnPositions{
            blackMoves.formUnion(showPawnMoves(startingSquare: pawn, pov: false))
        }
        //Knights
        let blackKnightPositions = findPiecePositions(boardValue: blackKnights)
        for knight in blackKnightPositions{
            blackMoves.formUnion(showKnightMoves(startingSquare: knight, pov: false))
        }
        //Bishops
        let blackBishopPositions = findPiecePositions(boardValue: blackBishops)
        for bishop in blackBishopPositions{
            blackMoves.formUnion(showBishopMoves(startingSquare: bishop, pov: false))
        }
        //Rooks
        let rookPositions = findPiecePositions(boardValue: blackRooks)
        for rook in rookPositions{
            blackMoves.formUnion(showRookMoves(startingSquare: rook, pov: false))
        }
        //Queens
        let blackQueenPositions = findPiecePositions(boardValue: blackQueens)
        for queen in blackQueenPositions{
            blackMoves.formUnion(showQueenMoves(startingSquare: queen, pov: false))
        }
        //King
        let blackKingPositions = findPiecePositions(boardValue: blackKing)
        for king in blackKingPositions{
            blackMoves.formUnion(showKingMoves(startingSquare: king, pov: false))
        }
        
        var blackMovesBitBoard:UInt64 = 0
        var whiteMovesBitBoard:UInt64 = 0
        for i in whiteMoves{
            whiteMovesBitBoard |= 1 << i
        }
        for i in blackMoves{
            blackMovesBitBoard |= 1 << i
        }
        self.whitePossibleMoves = whiteMovesBitBoard
        self.blackPossibleMoves = blackMovesBitBoard
        
    }
    
    mutating func updateCastlingPrivileges(){
        
        //Check if a rook has moved. If yes, kill that side
        if whiteCanCastleQueenSide != nil{
            if (bitReturner(lowerLimit:0, upperLimit:4, number:occupied) == 0){
                whiteCanCastleQueenSide = true
            }else if !(findPiecePositions(boardValue: whiteRooks).contains(0)){
                whiteCanCastleQueenSide = nil
            }
        }
        if whiteCanCastleKingSide != nil{
            if bitReturner(lowerLimit:4, upperLimit:7, number:occupied) == 0{
                whiteCanCastleKingSide = true
            }else if !(findPiecePositions(boardValue: whiteRooks).contains(7)){
                whiteCanCastleKingSide = nil
            }
        }
        if blackCanCastleQueenSide != nil{
            if bitReturner(lowerLimit:56, upperLimit:60, number:occupied) == 0{
                blackCanCastleQueenSide = true
            }else if !(findPiecePositions(boardValue: blackRooks).contains(56)){
                blackCanCastleQueenSide = nil
            }
        }
        if blackCanCastleKingSide != nil{
            if bitReturner(lowerLimit:60, upperLimit:63, number:occupied) == 0{
                blackCanCastleKingSide = true
            }else if !(findPiecePositions(boardValue: blackRooks).contains(63)){
                blackCanCastleKingSide = nil
            }
        }
    }
    
    mutating func updateCheckStatus(){
            blackUnderCheck = (whiteAttacking & blackKing != 0)
            whiteUnderCheck = (blackAttacking & whiteKing != 0)
    }
    
    mutating func updatePossibleMovesWhenUnderCheck(side:Bool) {
        if side{
                noOfCheckingPieces = 0
                squaresThatCanBlockTheCheck = []
                let kingPos = findPiecePositions(boardValue: whiteKing)[0]
                let possibleKnightChecks = showKnightMoves(startingSquare: kingPos, pov: true)
                
                for move in possibleKnightChecks{
                    if (1 << move) & blackKnights != 0{
                        noOfCheckingPieces!+=1
                        squaresThatCanBlockTheCheck!.append(move)
                    }
                }
            
            //OKAY SOOOOOOOOOOOOOOOOOOOOOOOOO
            //1. It doesn't know when the check state changes, I think. Let's check. Nvm it does
            //2. I need to add the promotion as a rule.
            //3. Create a promotion screen that acts as an overlay
            //4. Design a checkmate screen
            //5. Create a game stack
                if noOfCheckingPieces!>1{
                    squaresThatCanBlockTheCheck = showKingMoves(startingSquare: kingPos, pov: true)
                    return
                }
                
                let possibleStraightChecks = showRookMoves(startingSquare: kingPos, pov: true)
                for move in possibleStraightChecks{
                    if ((1 << move) & blackQueens != 0) || ((1 << move) & blackRooks != 0){
                        noOfCheckingPieces!+=1
                        squaresThatCanBlockTheCheck!.append(move)
                        squaresThatCanBlockTheCheck!.append(contentsOf: findVerticalSquaresBetween(pointA: kingPos, pointB: move))
                        squaresThatCanBlockTheCheck!.append(contentsOf: findHorizontalSquaresBetween(pointA: kingPos, pointB: move))
                    }
                }
                if noOfCheckingPieces!>1{
                    squaresThatCanBlockTheCheck = showKingMoves(startingSquare: kingPos, pov: true)
                    return
                }
                
                let possibleDiagonalChecks = showBishopMoves(startingSquare: kingPos, pov: true)
                for move in possibleDiagonalChecks{
                    if ((1 << move) & blackQueens != 0) || ((1 << move) & blackBishops != 0){
                        noOfCheckingPieces!+=1
                        squaresThatCanBlockTheCheck!.append(move)
                        squaresThatCanBlockTheCheck!.append(contentsOf: findTopLeftBottomRightDiagonalSquaresBetween(pointA: kingPos, pointB: move))
                        squaresThatCanBlockTheCheck!.append(contentsOf: findTopRightBottomLeftDiagonalSquaresBetween(pointA: kingPos, pointB: move))
                    }
                }
                if noOfCheckingPieces!>1{
                    squaresThatCanBlockTheCheck = showKingMoves(startingSquare: kingPos, pov: true)
                    return
                }
                
                let possiblePawnChecks = giveSurroundingSquares(sourceSquare: kingPos)
                for move in possiblePawnChecks{
                    if (1 << move) & blackPawns != 0{
                        if showPawnMoves(startingSquare: move, pov: false).contains(kingPos){
                            noOfCheckingPieces!+=1
                            squaresThatCanBlockTheCheck!.append(move)
                        }
                    }
                }
                //This will include taking the pawn or not
        }else{
                noOfCheckingPieces = 0
                squaresThatCanBlockTheCheck = []
                let kingPos = findPiecePositions(boardValue: blackKing)[0]
                let possibleKnightChecks = showKnightMoves(startingSquare: kingPos, pov: false)
                
                for move in possibleKnightChecks{
                    if (1 << move) & whiteKnights != 0{
                        noOfCheckingPieces!+=1
                        squaresThatCanBlockTheCheck!.append(move)
                    }
                }
                if noOfCheckingPieces!>1{
                    squaresThatCanBlockTheCheck = showKingMoves(startingSquare: kingPos, pov: false)
                    return
                }
                
                let possibleStraightChecks = showRookMoves(startingSquare: kingPos, pov: false)
                for move in possibleStraightChecks{
                    if ((1 << move) & whiteQueens != 0) || ((1 << move) & whiteRooks != 0){
                        noOfCheckingPieces!+=1
                        squaresThatCanBlockTheCheck!.append(move)
                        squaresThatCanBlockTheCheck!.append(contentsOf: findVerticalSquaresBetween(pointA: kingPos, pointB: move))
                        squaresThatCanBlockTheCheck!.append(contentsOf: findHorizontalSquaresBetween(pointA: kingPos, pointB: move))
                    }
                }
                if noOfCheckingPieces!>1{
                    squaresThatCanBlockTheCheck = showKingMoves(startingSquare: kingPos, pov: false)
                    return
                }
                
                let possibleDiagonalChecks = showBishopMoves(startingSquare: kingPos, pov: false)
                for move in possibleDiagonalChecks{
                    if ((1 << move) & whiteQueens != 0) || ((1 << move) & whiteBishops != 0){
                        noOfCheckingPieces!+=1
                        squaresThatCanBlockTheCheck!.append(move)
                        squaresThatCanBlockTheCheck!.append(contentsOf: findTopLeftBottomRightDiagonalSquaresBetween(pointA: kingPos, pointB: move))
                        squaresThatCanBlockTheCheck!.append(contentsOf: findTopRightBottomLeftDiagonalSquaresBetween(pointA: kingPos, pointB: move))
                    }
                }
                if noOfCheckingPieces!>1{
                    squaresThatCanBlockTheCheck = showKingMoves(startingSquare: kingPos, pov: false)
                    return
                }
                
                let possiblePawnChecks = giveSurroundingSquares(sourceSquare: kingPos)
                for move in possiblePawnChecks{
                    if (1 << move) & whitePawns != 0{
                        if showPawnMoves(startingSquare: move, pov: true).contains(kingPos){
                            noOfCheckingPieces!+=1
                            squaresThatCanBlockTheCheck!.append(move)
                        }
                    }
                }
                //This will include taking the pawn or not
        }
        print("Possible Squares: \(squaresThatCanBlockTheCheck!)")
    }
    
    mutating func updatePinnedSquares(kingPos: Int){
        let row = kingPos / 8
        let column = kingPos % 8
        var square:UInt64
        var currentPattern = "0"
        let friendlyPieces:UInt64
        let enemyStraightAttackingPieces:UInt64
        let enemyDiagonalAttackingPieces:UInt64
        var pinnedPieceSquare:UInt64 = 65
        
        
        let indexAt1 = currentPattern.index(currentPattern.startIndex, offsetBy: 1)
        pinnedPieces = 0
        
        if (1 << kingPos) & whiteKing != 0{
            
            friendlyPieces = whiteOccupied
            enemyStraightAttackingPieces = blackQueens | blackRooks
            enemyDiagonalAttackingPieces = blackQueens | blackBishops
        }else{
            
            friendlyPieces = blackOccupied
            enemyStraightAttackingPieces =  whiteQueens | whiteRooks
            enemyDiagonalAttackingPieces =  whiteQueens | whiteBishops
        }
        
        if (row<6){
            let upperLimit = (7-row)
            for i in 1...upperLimit{ //Increasing row, hence, add 8
                square = 1 << (kingPos + 8*i)
                if ((square & enemyStraightAttackingPieces) != 0){
                    currentPattern += "2"
                }else if ((square & friendlyPieces) != 0){
                    currentPattern += "1"
                    pinnedPieceSquare = square
                }
                if currentPattern.count == 3{
                    if (currentPattern.last == "2") && (currentPattern[indexAt1] == "1"){
                        pinnedPieces ^= pinnedPieceSquare
                    }
                    break
                }
            }
            currentPattern = "0"
            
            

            if column<6{//Increasing row and column (hence, add 9)
                let upperLimit = min(7-row, 7-column)
                
                for i in 1...upperLimit{
                    square = 1 << (kingPos + (9*i))
                    if ((square & enemyDiagonalAttackingPieces) != 0){
                        currentPattern += "2"
                    }else if ((square & friendlyPieces) != 0){
                        currentPattern += "1"
                        pinnedPieceSquare = square
                    }
                    if currentPattern.count == 3{
                        if (currentPattern.last == "2") && (currentPattern[indexAt1] == "1"){
                            pinnedPieces ^= pinnedPieceSquare
                        }
                        break
                    }
                }
                currentPattern = "0"
            }
            
            if column>0{ //Increasing Row, decreasing column, hence, add 7
                let upperLimit = min(7-row, 7-column)
                
                for i in 1...upperLimit{
                    square = 1 << (kingPos + (7*i))
                    if ((square & enemyDiagonalAttackingPieces) != 0){
                        currentPattern += "2"
                    }else if ((square & friendlyPieces) != 0){
                        currentPattern += "1"
                        pinnedPieceSquare = square
                    }
                    if currentPattern.count == 3{
                        if (currentPattern.last == "2") && (currentPattern[indexAt1] == "1"){
                            pinnedPieces ^= pinnedPieceSquare
                        }
                        break
                    }
                }
                currentPattern = "0"
            }
            
        }
        if column>0{ //Decreasing Column, hence subtract 1
            for i in (8*row...kingPos-1).reversed(){
                square = 1 << (i)
                if ((square & enemyStraightAttackingPieces) != 0){
                    currentPattern += "2"
                }else if ((square & friendlyPieces) != 0){
                    currentPattern += "1"
                    pinnedPieceSquare = square
                }
                if currentPattern.count == 3{
                    if (currentPattern.last == "2") && (currentPattern[indexAt1] == "1"){
                        pinnedPieces ^= pinnedPieceSquare
                        
                    }
                    break
                }
            }
            currentPattern = "0"
        }
        if column<7{//Increasing Column, hence add 1
            for i in (kingPos+1..<8*(row+1)){
                square = 1 << (i)
                if ((square & enemyStraightAttackingPieces) != 0){
                    currentPattern += "2"
                }else if ((square & friendlyPieces) != 0){
                    currentPattern += "1"
                    pinnedPieceSquare = square
                }
                if currentPattern.count == 3{
                    if (currentPattern.last == "2") && (currentPattern[indexAt1] == "1"){
                        pinnedPieces ^= pinnedPieceSquare
                    }
                    break
                }
            }
            currentPattern = "0"
        }
        if row>0{
            
            for i in 1...row{ //Decreasing row, hence subtract 8
                square = 1 << (kingPos - 8*i)
                if ((square & enemyStraightAttackingPieces) != 0){
                    currentPattern += "2"
                }else if ((square & friendlyPieces) != 0){
                    currentPattern += "1"
                    pinnedPieceSquare = square
                }
                if currentPattern.count == 3{
                    if (currentPattern.last == "2") && (currentPattern[indexAt1] == "1"){
                        pinnedPieces ^= pinnedPieceSquare
                    }
                    break
                }
            }
            currentPattern = "0"
            
            if column<7{//Decreasing row and increasing column, Hence, subtract 7
                
                for i in 1...row{
                    square = 1 << (kingPos - (7*i))
                    if ((square & enemyDiagonalAttackingPieces) != 0){
                        currentPattern += "2"
                    }else if ((square & friendlyPieces) != 0){
                        currentPattern += "1"
                        pinnedPieceSquare = square
                    }
                    if currentPattern.count == 3{
                        if (currentPattern.last == "2") && (currentPattern[indexAt1] == "1"){
                            pinnedPieces ^= pinnedPieceSquare
                        }
                        break
                    }
                }
                currentPattern = "0"
            }
            if column>0{//Decreasing row and column, Hence, subtract 9
                let upperLimit = min(row, column)
                
                for i in 1...upperLimit{
                    square = 1 << (kingPos - (9*i))
                    if ((square & enemyDiagonalAttackingPieces) != 0){
                        currentPattern += "2"
                    }else if ((square & friendlyPieces) != 0){
                        currentPattern += "1"
                        pinnedPieceSquare = square
                    }
                    if currentPattern.count == 3{
                        if (currentPattern.last == "2") && (currentPattern[indexAt1] == "1"){
                            pinnedPieces ^= pinnedPieceSquare
                        }
                        break
                    }
                }
            }
        }
    }

    
}


func createBoard(fog:Bool = false) -> Bitboard {
    var board = Bitboard()
    
    let whitePawnPos = Array(8..<16)
    let whiteRooksPos = [0, 7]
    let whiteKnightsPos = [1, 6]
    let whiteBishopsPos = [2, 5]
    let whiteQueensPos = [3]
    let whiteKingPos = [4]

    let blackPawnPos = Array(48..<56)
    let blackRooksPos = [56, 63]
    let blackKnightsPos = [57, 62]
    let blackBishopsPos = [58, 61]
    let blackQueensPos = [59]
    let blackKingPos = [60]
    
    board.fog = fog

    board.whitePawns = whitePawnPos.reduce(0) { result, i in result | (1 << i) }
    board.whiteRooks = whiteRooksPos.reduce(0) { result, i in result | (1 << i) }
    board.whiteKnights = whiteKnightsPos.reduce(0) { result, i in result | (1 << i) }
    board.whiteBishops = whiteBishopsPos.reduce(0) { result, i in result | (1 << i) }
    board.whiteQueens = whiteQueensPos.reduce(0) { result, i in result | (1 << i) }
    board.whiteKing = whiteKingPos.reduce(0) { result, i in result | (1 << i) }

    board.blackPawns = blackPawnPos.reduce(0) { result, i in result | (1 << i) }
    board.blackRooks = blackRooksPos.reduce(0) { result, i in result | (1 << i) }
    board.blackKnights = blackKnightsPos.reduce(0) { result, i in result | (1 << i) }
    board.blackBishops = blackBishopsPos.reduce(0) { result, i in result | (1 << i) }
    board.blackQueens = blackQueensPos.reduce(0) { result, i in result | (1 << i) }
    board.blackKing = blackKingPos.reduce(0) { result, i in result | (1 << i) }

    board.occupied = [
        board.whitePawns, board.whiteRooks, board.whiteKnights,
        board.whiteBishops, board.whiteQueens, board.whiteKing,
        board.blackPawns, board.blackRooks, board.blackKnights,
        board.blackBishops, board.blackQueens, board.blackKing
    ].reduce(0, |)
    
    board.whiteOccupied = [
        board.whitePawns, board.whiteRooks, board.whiteKnights,
        board.whiteBishops, board.whiteQueens, board.whiteKing
    ].reduce(0, |)
    
    board.blackOccupied = board.occupied ^ board.whiteOccupied
    
    return board
}



