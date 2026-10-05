
//
// Written by John Baylor (john.baylor@gmail.com) ~2007
//
// Versions:
// 1.6	- Added the word 'PASS' next to the name of anyone that has passed a turn.
// 1.5	- Minor improvements to mail link - forced comment so it always mails.
// 1.4	- Added test mail link; fixed up some addrs
// 1.3	- Spammed myself by always adding me to the CC list
// 1.2	- Sped up redraw of the "stash" of to-be-played pieces
// 1.1	- Changed CC delimeter to comma when Tony sends a move
// 1.0	- Shrunk board, replaced gray/white background with dashed lines
// 0.9	- Added Paul, clarified cut and paste section
// 0.8	- Changed CC to include *all* player's emails
// 0.7	- Fixed initial off-board corners, changed scores to non-negative numbers, validated moves
// 0.6	- Added Jim, MikeJulie, AmyJason; improved email text; instructions; link to blokus.com
// 0.5	- Added scoring (starting out negative)
// 0.4	- Fixed the 'pass' option; forced pieces to stay on board
// 0.3	- Added Dan, Marsha, Jon, Tony and Rob; showed available pieces; improved mailto link
// 0.2	- Piece flipping; move passing
// 0.1	- First version that can actually allow pieces to be played
//

/*
THEORY OF OPERATION
The visible game board is backed by a slightly larger grid that extends one square in each
direction. The off-board squares are all marked as out-of-bounds to simplify tests against
going off the side of the board. Visible board cells have a "cell-xyz" ID that matches the
underlying grid. Thus, for a 5x3 grid (7x5 internally) the upper-left visible corner is at
index 8 and the lower-right is at 26.
 */

    var doc = Document;
    doc.onkeydown = KeyDown;

    var playerList = new Array();
    playerList[0] = "John,John Baylor,john.baylor@gmail.com";
    playerList[1] = "John,John Baylor,john.baylor@gmail.com";
    playerList[2] = "Dan,Dan Goss,dgoss5262@gmail.com";
    playerList[3] = "Marsha,Marsha Hiller,MHiller4@earthlink.net";
    playerList[4] = "Jon,John Baumgartner,jbaumgartner649@worldsavings.com";
    playerList[5] = "Tony,Tony Maynard,tony@maynard.com";
    playerList[6] = "Rob,Rob Kayen,louis.kayen@mac.com;rkayen@usgs.gov";
    playerList[7] = "Jim,Jim Gilsenan,jfGilsenan@yahoo.com;jgilsenan@ggu.edu";
    playerList[8] = "MikeJulie,Mike and Julie,mjbweitz@earthlink.net";
    playerList[9] = "Amy,OnlyAmy,lustishiro@gmail.com";
    playerList['a'] = "Paul,Paul LaVigne,paul.lavigne@gmail.com";
    playerList['b'] = "Jack,Jack Gardner,jakgardner@aol.com";
    playerList['c'] = "ErikP,Erik Pearson,eapearson@gmail.com";
    playerList['d'] = "Jeff Turner,Jeff Turner,flight_square@hotmail.com";
    playerList['e'] = "Meg, Meg Sedlak,mdsblueskies@yahoo.com";
    playerList['f'] = "Mark,Mark,mbatchelder@netscape.net";
    playerList['g'] = "Ian,Ian,Ian@songbirdnest.com";
    playerList['h'] = "Matt,Matt,Matt@songbirdnest.com";

// Blokus-by-mail data
    var OFFBOARD = -1;
    var EMPTYSQUARE = 0;
    var FIRSTCOLOR = 1;
    var BLUESQUARE = 1;
    var YELLOWSQUARE = 2;
    var REDSQUARE = 3;
    var GREENSQUARE = 4;
    var LASTCOLOR = 4;

    var colorChars = new Array();
    colorChars[BLUESQUARE] = "B";
    colorChars[YELLOWSQUARE] = "Y";
    colorChars[REDSQUARE] = "R";
    colorChars[GREENSQUARE] = "G";

    var colorNames = new Array();
    colorNames[EMPTYSQUARE] = "#f0f0f0";
    colorNames[BLUESQUARE] = "LightBlue";
    colorNames[YELLOWSQUARE] = "Yellow";
    colorNames[REDSQUARE] = "Red";
    colorNames[GREENSQUARE] = "Green";

    var hasPassed = new Array();
    hasPassed[BLUESQUARE] = "";
    hasPassed[YELLOWSQUARE] = "";
    hasPassed[REDSQUARE] = "";
    hasPassed[GREENSQUARE] = "";


    var availablePieces = new Array();

// "pos" contains our internal position, larger than the real board.
    var pos = new Array(22 * 22);
    var curPieceIdx = -1;
    var curColor = FIRSTCOLOR;
    var curPiece = "";		// from pieceTypes[]
    var pieceInHand = "";	// "Bg" for the 7th Blue piece
    var boardIdx = 189;		// Where current piece is on the board (start at center-right)
    var pieceWasPlaced = 0;

// delay between each move when in auto-move mode
    var delay = 1400;

// image index to the board and each of the sets of pieces
    var imgIdxBoard = 0;
    var imgIdxColors = new Array();

    function preloadImages() {
        var myImage;
        for (var i = 0; i < preloadImages.arguments.length; i++) {
            myImage = new Image();
            myImage.src = preloadImages.arguments[i];
        }
    }

    function beginPreLoad() {
        if (document.images) {
            preloadImages(
                "images/i25.jpg", "images/B25.jpg", // "images/Y25.jpg", "images/R25.jpg", "images/G25.jpg",
                // "images/i25_H.jpg", "images/B25_H.jpg", "images/Y25_H.jpg", "images/R25_H.jpg", "images/G25_H.jpg",
//						"images/i35.gif","images/B.jpg","images/Y.jpg","images/R.jpg","images/G.jpg",
//						"images/i35_H.gif","images/B_H.jpg","images/Y_H.jpg","images/R_H.jpg","images/G_H.jpg",
                "images/Ba.jpg", "images/Bb.jpg", "images/Bc.jpg", "images/Bd.jpg", "images/Be.jpg", "images/Bf.jpg", "images/Bg.jpg",
                "images/Bh.jpg", "images/Bi.jpg", "images/Bj.jpg", "images/Bk.jpg", "images/Bl.jpg", "images/Bm.jpg", "images/Bn.jpg",
                "images/Bo.jpg", "images/Bp.jpg", "images/Bq.jpg", "images/Br.jpg", "images/Bs.jpg", "images/Bt.jpg", "images/Bu.jpg",
                "images/Ba_H.jpg", "images/Bb_H.jpg", "images/Bc_H.jpg", "images/Bd_H.jpg", "images/Be_H.jpg", "images/Bf_H.jpg", "images/Bg_H.jpg",
                "images/Bh_H.jpg", "images/Bi_H.jpg", "images/Bj_H.jpg", "images/Bk_H.jpg", "images/Bl_H.jpg", "images/Bm_H.jpg", "images/Bn_H.jpg",
                "images/Bo_H.jpg", "images/Bp_H.jpg", "images/Bq_H.jpg", "images/Br_H.jpg", "images/Bs_H.jpg", "images/Bt_H.jpg", "images/Bu_H.jpg",
                "images/flipdiagonal.gif", "images/flipHorizontal.jpg", "images/flipvertical.gif");
        }
    }

    function InitSys() {
        beginPreLoad();
    }


// Parse URL - from http://www.eggheadcafe.com/articles/20020107.asp
    function PageQuery(q) {
        if (q.length > 1) this.q = q.substring(1, q.length);
        else this.q = null;

        this.keyValuePairs = new Array();
        if (q) {
            for (var i = 0; i < this.q.split("&").length; i++) {
                this.keyValuePairs[i] = this.q.split("&")[i];
            }
        }
        this.getKeyValuePairs = function () {
            return this.keyValuePairs;
        }
        this.getValue = function (s) {
            for (var j = 0; j < this.keyValuePairs.length; j++) {
                if (this.keyValuePairs[j].split("=")[0] == s)
                    return this.keyValuePairs[j].split("=")[1];
            }
            return false;
        }

        this.getParameters = function () {
            var a = new Array(this.getLength());
            for (var j = 0; j < this.keyValuePairs.length; j++) {
                a[j] = this.keyValuePairs[j].split("=")[0];
            }
            return a;
        }

        this.getLength = function () {
            return this.keyValuePairs.length;
        }
    }

    function queryString(key) {
        var page = new PageQuery(window.location.search);
        return unescape(page.getValue(key));
    }

    function displayItem(key) {
        if (queryString(key) == 0) {
            document.write("you didn't enter a ?name=value querystring item.");
        } else {
            document.write(queryString(key));
        }
    }

// ---end of http://www.eggheadcafe.com/articles/20020107.asp

    var VERT_FLIP = 1;
    var HORZ_FLIP = 2;
    var DIAG_FLIP = 4;
    var vertReplace = "uvwxypqrstklmnofghijabcde";
    var horzReplace = "edcbajihgfonmlktsrqpyxwvu";
    var diagReplace = "afkpubglqvchmrwdinsxejoty";
//var diagReplace="ytojexsnidwrmhcvqlgbupkfa";	//this was wrong

// piece format: <orientation><listOfSquares>
// orientation:
//		0=original orientation
//		1bit = vertical flip
//		2bit = horizontal flip
//		4bit = diagonal flip
// listOfSquares: corresponds to the array of chars below.  It may appear
//	 that this could be as small as 5x3 but it needs to be 5x5 so as to be
//	 flippable vertically, horizontally or diagonally.  (M is the center
//	 and is forced to be in every piece - it is the "handle" for the piece)
//		abcde
//		fghij
//		klmno
//		pqrst
//		uvwxy
//
    var pieceTypes = new Array(21);
    pieceTypes[0] = "0m";	// a
    pieceTypes[1] = "0mn";	// b
    pieceTypes[2] = "0lmn";	// c
    pieceTypes[3] = "0mns";	// d
    pieceTypes[4] = "0lmno";	// e
    pieceTypes[5] = "0lmns";	// f
    pieceTypes[6] = "0lmnr";	// g

    pieceTypes[7] = "0lmrs";	// h
    pieceTypes[8] = "0lmqr";	// i
    pieceTypes[9] = "0klmno";	// j
    pieceTypes[10] = "0klmnr";	// k
    pieceTypes[11] = "0klmns";	// l
    pieceTypes[12] = "0ghmns";	// m
    pieceTypes[13] = "0klmrw";	// n

    pieceTypes[14] = "0hlmnr";	// o
    pieceTypes[15] = "0lmnqr";	// p
    pieceTypes[16] = "0ghmnr";	// q
    pieceTypes[17] = "0klmrs";	// r
    pieceTypes[18] = "0ghmrs";	// s
    pieceTypes[19] = "0ghimr";	// t
    pieceTypes[20] = "0lmnqs";	// u

// file:///C:/JBaylorPersonal/HomeBackups/blokus/blokus.htm?P=123X&M=4mBb1mSb0nTr4uEe0oPb5pQp0aDb2hMa4bOq6tGb4bNc5lSm6hBf4fQe1rRj4jCi6pPh0jMn4lBn5lNk0oJl4bDm4jMg0iJo6gFl0eJd4uGl0oGo0iGe0kFi2sDq3rEh6tJi0rHg0aHi4mIf0iBs2dIj6sHc3pEs6gLk1qEn0qJb4kPm6hFq0dLc2sNp2dDs4jLg1qSp5fBq0fOe6uQs4jAn4cOh0cNs4cCm1nSg2nJr6gBj6kTj0tHr0aAh
// file:///C:/JBaylorPersonal/HomeBackups/blokus/blokus.htm?P=123X&M=4mBb1mSb0nTr5uEe0oPb5pQp0aDb2hMa4bOq6tGb4bNc5lSm2hBe4fQe1rRj4jCi5pPh0jMn4lBn5lOl0oJl4bDm4jMg0iJo5gFl0eJd4uGl0oGo0iGe0kFi2sDq3rEh6tJi0rHg0aHi4mIf0iBs2dIj6sHc3pEs6gLk1qEn0qJb4kPm6hFq0dLc2sNp4jLg4jLg1qSp5fBq0fOe6uQs4jAn4cOh0cNs4cCm1nSg2nJr6gBj6kTj0tHr0aAh
//28 good moves:
// file:///C:/JBaylorPersonal/HomeBackups/blokus/blokus.htm?P=123X&M=4mBb1mSb0nTr5uEe0oPb5pQp0aDb2hMa4bOq6tGb4bNc5lSm2hBe4fQe1rRj4jCi5pPh0jMn4lBn5lOl0oJl4bDm4jMg0iJo5gFl0eJd4uGl0oGo
//nearly an entire game
// file:///C:/JBaylorPersonal/HomeBackups/blokus/blokus.htm?P=1234&M=4mBb1mSb0mSs6qBs2pEd0oPd1pPq1tDp4jDh6qNf4eNm4jEl4lCm4sKh7lOi7lFg0eHf4jPi0gLk1nIe0sFp4nGi0jHj3rGs0qIq4eOm1kLp3kKr5uKn0uPa4uHn1pOt0kLs4rLc6rRn0mQs0oLe4fJc0nTj0oCe7rNb2lGa4tRh0iBg2hIk0dMj6fFm5uEb0tDs0tSf4bTf5gBo0iBi0iRl4cEh4bNp0aOe4bTh0aTq1sSp1gQf0aSk0aTl4cQo1fSd5kMn0aTl2dHb4cAe0aTh0aSm0aHq3dGt0aSf0aRh5hBlXXXX

// in:  piece char ('a' - 'u')
// out: pieceTypes index (0 - 20)
    function char2piece(ch) {
        return ch.charCodeAt(0) - "a".charCodeAt(0);
    }

// in:  piece char ('a' - 'u')
// out: pieceTypes string
    function getPieceString(piece) {
        piece = char2piece(piece);
        if (piece < 0 || piece >= 21) return "";
        return pieceTypes[piece];
    }

// in:  piece char ('A' - 'T')
// out: X position (0 - 19)
    function char2boardX(ch) {
        return ch.charCodeAt(0) - "A".charCodeAt(0);
    }

// in:  piece char ('a' - 't')
// out: Y position (0 - 19)
    function char2boardY(ch) {
        return ch.charCodeAt(0) - "a".charCodeAt(0);
    }

// in:  piece position in 5x5 array ('a' - 'y')
// out: X position (0 - 4)
    function char2pieceX(ch) {
        ch = ch.charCodeAt(0) - "a".charCodeAt(0);
        return ch % 5;
    }

// in:  piece position in 5x5 array ('a' - 'y')
// out: Y position (0 - 4)
    function char2pieceY(ch) {
        ch = ch.charCodeAt(0) - "a".charCodeAt(0);
        ch = Math.floor(ch / 5);	//or "((ch - (ch % 5)) / 5)"
        return ch;
    }

// in:  XY position in 5x5 array
// out: character corresponding with that position ('a' - 'y')
    function pieceXY2char(x, y) {
        var num = "a".charCodeAt(0);
        num += x + 5 * y;
        var ch = String.fromCharCode(num);
        console.log(" ["+x+","+y+"]="+ch);
        return ch;
    }

// in:  X position (0-19)
// out: character corresponding with that position ('A' - 'Y')
    function boardX2char(x) {
        var num = "A".charCodeAt(0);
        num += x;
        var ch = String.fromCharCode(num);
        console.log(" X"+x+":"+ch);
        return ch;
    }

// in:  Y position (0-19)
// out: character corresponding with that position ('a' - 'y')
    function boardY2char(y) {
        var num = "a".charCodeAt(0);
        num += y;
        var ch = String.fromCharCode(num);
        console.log(" Y"+y+":"+ch);
        return ch;
    }

//boardX2char(5);
//boardY2char(20);

// Translate 20x20 board position (0-19 in each direction) to
// a 22x22 internal index (0-483)
    function board2posIndex(x, y) {
        var idx = 23 + x + (22 * y);
        // console.log(" "+x+"."+y+"=="+idx + " " );
        return idx;
    }

//board2posIndex(0,0);
//board2posIndex(1,1);
//board2posIndex(5,19);
//board2posIndex(19,19);


//
    function isSquareEmpty(x, y) {
        var idx = board2posIndex(x, y);
        console.log(" isSquareEmpty("+x+","+y+")="+pos[idx] + " " );
        if (pos[idx] == EMPTYSQUARE) return 1;
        return 0;
    }

//isSquareEmpty(0,0);
//isSquareEmpty(5,7);
//isSquareEmpty(19,19);

//
    function hasMatchingDiagNeighbor(x, y, color) {
        if (color == pos[board2posIndex(x - 1, y - 1)]) return 1;
        if (color == pos[board2posIndex(x - 1, y + 1)]) return 1;
        if (color == pos[board2posIndex(x + 1, y - 1)]) return 1;
        if (color == pos[board2posIndex(x + 1, y + 1)]) return 1;
        console.log(" hasMatchingDiagNeighbor("+x+","+y+","+color+")=NO " );
        return 0;
    }

//
    function hasMatchingSideNeighbor(x, y, color) {
        if (color == pos[board2posIndex(x - 1, y)]) return 1;
        if (color == pos[board2posIndex(x + 1, y)]) return 1;
        if (color == pos[board2posIndex(x, y - 1)]) return 1;
        if (color == pos[board2posIndex(x, y + 1)]) return 1;
        return 0;
    }

//hasMatchingDiagNeighbor(0,0,BLUESQUARE);
//hasMatchingDiagNeighbor(6,9,BLUESQUARE);

// Always remember: when drawing the piece, the flip order will be vert->horz->diag
// so if the user applied it in a different order then we need to compensate.
    function applyOrientationToOrientChar(ch, orient) {
        // force ch to be an integer with the *1 operation
        ch = ch * 1;
        // If diag was already done on this piece, invert the H and V swaps as well
        // (this will convert it to seemingly have the diag swap last)
        if (ch & DIAG_FLIP) ch ^= (VERT_FLIP + HORZ_FLIP);
        ch ^= orient;
        return ch;
    }

    function passYourTurn() {
        // todo: verify that there really are no moves - give hints if there are?
        alert("You are passing your move to the next player.  Reload the page if this was not your intent.");

        var showAlerts = 0;
        // TODO: Enable play-next-move and email-next-move links...
        var ourMove = "X";
        if (showAlerts) alert("ourMove2=" + ourMove + ", rest=" + restOfMoves);
        restOfMoves += ourMove;
        if (showAlerts) alert("ourMove=" + ourMove + ", rest=" + restOfMoves);
        moves += ourMove;
        pieceInHand = "";	//now not holding a piece
        pieceWasPlaced = 1;
        GoEnd();
    }

    function pieceFlipVert() {
        console.log("curPiece: " + curPiece)
        if ("" == curPiece) return;
        var newOrientation = applyOrientationToOrientChar(curPiece.charAt(0), VERT_FLIP);
        curPiece = orientPieceList(curPiece.substring(1, 6), VERT_FLIP);
        // restore to "(orientChar)(listOfSquares)"
        curPiece = newOrientation + curPiece;
        boardIdx = findAllowableBoardPosition(boardIdx, curPiece);
        hilightPieceOnBoard(boardIdx, curPiece);
    }

    function pieceFlipHorz() {
        if ("" == curPiece) return;
        var newOrientation = applyOrientationToOrientChar(curPiece.charAt(0), HORZ_FLIP);
        curPiece = orientPieceList(curPiece.substring(1, 6), HORZ_FLIP);
        curPiece = newOrientation + curPiece;
        boardIdx = findAllowableBoardPosition(boardIdx, curPiece);
        hilightPieceOnBoard(boardIdx, curPiece);
    }

    function pieceFlipDiag() {
        if ("" == curPiece) return;
        var newOrientation = applyOrientationToOrientChar(curPiece.charAt(0), DIAG_FLIP);
        curPiece = orientPieceList(curPiece.substring(1, 6), DIAG_FLIP);
        curPiece = newOrientation + curPiece;
        boardIdx = findAllowableBoardPosition(boardIdx, curPiece);
        hilightPieceOnBoard(boardIdx, curPiece);
    }

    function getScore(color) {
        // if (BLUESQUARE == color) return doc.form0.Bluescore.value;
        // if (YELLOWSQUARE == color) return doc.form0.Yellowscore.value;
        // if (REDSQUARE == color) return doc.form0.Redscore.value;
        // if (GREENSQUARE == color) return doc.form0.Greenscore.value;
        return -99;
    }

    function setScore(color, val) {
        // if (BLUESQUARE == color) doc.form0.Bluescore.value = val;
        // if (YELLOWSQUARE == color) doc.form0.Yellowscore.value = val;
        // if (REDSQUARE == color) doc.form0.Redscore.value = val;
        // if (GREENSQUARE == color) doc.form0.Greenscore.value = val;
    }

    function setPass(color, val) {
        // if (BLUESQUARE == color) doc.form0.Bluepassed.value = val;
        // if (YELLOWSQUARE == color) doc.form0.Yellowpassed.value = val;
        // if (REDSQUARE == color) doc.form0.Redpassed.value = val;
        // if (GREENSQUARE == color) doc.form0.Greenpassed.value = val;
    }

//
    function initPosition() {
        var loop = 0;
        for (loop = 0; loop < 22 * 22; loop++) {
            pos[loop] = EMPTYSQUARE;
        }
        for (loop = 0; loop < 22; loop++) {
            pos[loop] = OFFBOARD;
            pos[22 * loop] = OFFBOARD;
            pos[22 * loop + 21] = OFFBOARD;
            pos[22 * 21 + loop] = OFFBOARD;
        }
        // Treat the off-board corners as already being the color that will start
        // from that corner.  The same-diagonal-color check will always work.
        pos[0] = BLUESQUARE;
        pos[21] = YELLOWSQUARE;
        pos[21 * 22] = GREENSQUARE;
        pos[22 * 22 - 1] = REDSQUARE;

        restOfMoves = moves;
        curMove = 0;
        curColor = FIRSTCOLOR;
        var pieceIdx;
        var pieceLoop;
        // Why did we even need to set visibility at all?
        // for (loop = FIRSTCOLOR; loop <= LASTCOLOR; loop++) {
        //     pieceIdx = imgIdxColors[loop];
        //     for (pieceLoop = 0; pieceLoop < 21; pieceLoop++) {
        //         doc.images[pieceIdx + pieceLoop].visibility = 'visible';
        //     }
        // }
        initAvailablePieces();
        setScore(BLUESQUARE, 0);
        // Restore when all of them exist
        // setScore(YELLOWSQUARE, 0);
        // setScore(REDSQUARE, 0);
        // setScore(GREENSQUARE, 0);
    }

//
    function getNextColor() {
        curColor++;
        if (curColor > LASTCOLOR) {
            curColor = FIRSTCOLOR;
        }
    }

//
    function isOnBoard(x, y) {
    }

//
    function isValidSquare(x, y, color) {
    }

//
    function isValidPlacement(orientation, piece, x, y) {
    }

    /*
    */

//
    function isPassChar(ch) {
        console.log(" isPassChar("+ch+") ");

        if (ch == 'X') return 1;
        return 0;
    }

//
    function countMoves(moves) {
        var loop;
        var soFar = 0;
        if (!moves) return 0;
        if (moves == 'false') return 0;
        console.log(" moves="+moves);
        for (loop = 0; loop < moves.length; loop++) {
            soFar++;
            if (isPassChar(moves.charAt(loop)) == 1) {
                console.log(" PASS ");
            } else {
                var orientation = moves.charAt(loop);
                var piece = moves.charAt(loop + 1);

                var pieceIdx = char2piece(piece);
                console.log(" pieceIdx="+pieceIdx +pieceTypes[pieceIdx].substring(1,6)+" ");
                //if( pieceIdx < 0 || pieceIdx >= 21 )
                console.log("pieceIdx="+pieceIdx+"!!!!");

                //TODO: apply orientation to the selected piece string
                var xPos = moves.charAt(loop + 2);
                var yPos = moves.charAt(loop + 3);
                xPos = char2boardX(xPos);
                yPos = char2boardY(yPos);
                loop += 3;
                console.log("O="+orientation+",P="+piece+",x="+xPos+",y="+yPos+" ");
                var posIdx = board2posIndex(xPos, yPos);
                console.log("posIdx="+posIdx+" ");
            }
        }
        return soFar;
    }

//DWIT: what should this do?  One routine probably can't do both:
//	- place a piece in the POS array
//	- draw directly to board, bypassing POS
    function placePiece(g) {
    }

//
    function board2imgIndex(x, y) {
        return x + 22 * y + imgIdxBoard;
    }

    function coloredImage(color) {
        if (BLUESQUARE == color) return "images/B25.jpg";
        if (REDSQUARE == color) return "images/R25.jpg";
        if (YELLOWSQUARE == color) return "images/Y25.jpg";
        if (GREENSQUARE == color) return "images/G25.jpg";
        return "images/i25.jpg";
    }

console.log( "Blue="+coloredImage(BLUESQUARE)+"...");

// Given a board position, draw the expected color for each square
    function drawSquare(x, y) {
        var posIdx = board2posIndex(x, y);
        var cellColorIndex = pos[posIdx];
        var cellColor = colorNames[cellColorIndex] || "orange"
        // console.log("Setting "+posIdx+" ("+x+","+y+") to "+cellColor)
        setCellColor(posIdx, cellColor);
        // setCellBorder(posIdx, "1px solid #ccc");
    }

    function setCellColor(cell_id, color) {
        var el= document.getElementById("cell-" + cell_id)
        if (el) {
            // console.log("Setting color '"+color+"' for " + cell_id + ".")
            el.style.backgroundColor = color;
        } else {
            console.log("Unable to find ??? cell-" + cell_id + ".")
        }
    }
    function setCellBorder(cell_id, border) {
        var el= document.getElementById("cell-" + cell_id)
        if (el) {
            console.log("Setting color '"+border+"' for " + cell_id + ".")
            el.style.border = border;
        } else {
            console.log("Unable to find ??? cell-" + cell_id + ".")
        }
    }

    function drawPosition() {
        var x;
        var y;
        for (x = 0; x < 20; x++) {
            for (y = 0; y < 20; y++) {
                drawSquare(x, y);
            }
        }
        // Mark the corners for the player that starts there
        // TODO: lighten them somehow, to show they aren't real pieces
        // TODO: don't show color if no player of that color
        if (numMoves < 5) {
            if (isSquareEmpty(0, 0)) setCellColor(board2posIndex(0, 0), colorNames[BLUESQUARE]);
            if (isSquareEmpty(19, 0)) setCellColor(board2posIndex(19, 0), colorNames[YELLOWSQUARE]);
            if (isSquareEmpty(19, 19)) setCellColor(board2posIndex(19, 19), colorNames[REDSQUARE]);
            if (isSquareEmpty(0, 19)) setCellColor(board2posIndex(0, 19), colorNames[GREENSQUARE]);
        }
        var loop = "a";
        var color = FIRSTCOLOR;
        var idx = 0;
        // Unclear what this is actually intending to do. Copy a shadow color over the cell?
        // for (idx = 0; idx < 21; idx++) {
        //     for (color = FIRSTCOLOR; color <= LASTCOLOR; color++) {
        //         loop = String.fromCharCode(idx + "a".charCodeAt(0));
        //         var pieceName = colorChars[color] + loop;
        //         if (doc.images[imgIdxColors[color] + idx].src != doc.images[imgIdxColors[color] + idx].s) {
        //             doc.images[imgIdxColors[color] + idx].src = doc.images[imgIdxColors[color] + idx].s;
        //         }
        //     }
        // }
    }

// From the players and moves, we should be able to
// generate the current position.
    var players = queryString("P");
    if ('false' == players) players = "1212";
console.log(" players="+players );
    var moves = queryString("M");
    if ('false' == moves) moves = "";
    var numMoves = countMoves(moves);

console.log(" numMoves="+numMoves);


    function playerFirstname(color) {
        var pIdx = players.charAt(color - 1);
        if (pIdx == "X") return "";
        var n = playerList[pIdx].split(",")[0];
        //alert(n);
        return n;
    }

    function playerFullname(color) {
        var pIdx = players.charAt(color - 1);
        if (pIdx == "X") return "";
        var n = playerList[pIdx].split(",")[1];
        //alert(n);
        return n;
    }

    function playerEmail(color) {
        var pIdx = players.charAt((color + 2) % 4);
        if (pIdx == "X") return "";
        var n = playerList[pIdx].split(",")[2];
        //alert("player="+n);
        return n;
    }

// it looks like the current player's email, but we've already incremented
// curColor so the "next" player is really the current player
    function nextPlayersEmail(color) {
        var pIdx = players.charAt(color - 1);
        if (pIdx == "X") return "";
        var n = playerList[pIdx].split(",")[2];
        //alert("player="+n);
        return n;
    }


    var nowAutoMoving = 0;
    var tmid;	//timer ID for replay speed
    var restOfMoves = moves;	// when moving back and forth in a game, this is yet to be played
    var curMove = 0;

//
    function Astop() {
        nowAutoMoving = 0;
        clearInterval(tmid);
    }

    var showOrientation = 0;
// in: piece - list of position squares ('a' to 'y')
// in: orientation - 0 to 7
// out: list of squares used after orientation ('a'-'y')
    function orientPieceList(squares, orientation) {
        if (!squares) return "";
        if (squares == 'false') return "";
        var msg;

        var oriented = "";
        var loop;
        var pos;
        var nextChar;
        for (loop = 0; loop < squares.length; loop++) {
            nextChar = squares.charAt(loop);
            // apply orientation to the selected piece string
            if (orientation & VERT_FLIP) {
                pos = char2piece(nextChar);
                nextChar = vertReplace.charAt(pos);
            }
            if (orientation & HORZ_FLIP) {
                pos = char2piece(nextChar);
                nextChar = horzReplace.charAt(pos);
            }
            if (orientation & DIAG_FLIP) {
                pos = char2piece(nextChar);
                nextChar = diagReplace.charAt(pos);
            }
            oriented += nextChar;
        }
        return oriented;
        /*
        */
    }

// in: piece - character designating piece ('a'-'u')
// in: piece - character designating piece ('a'-'u')
// out: list of squares used after orientation ('a'-'y')
// TODO: change to use orientPieceList()
    function orientPiece(piece, orientation) {
        if (!piece) return "";
        if (piece == 'false') return "";
        var msg;
        var pieceIdx = char2piece(piece);
        //if( pieceIdx < 0 || pieceIdx >= 21 )
        console.log("pieceIdx="+pieceIdx+"!! ");
        //return "m";
        var squares = pieceTypes[pieceIdx].substring(1, 6);
        console.log("{"+squares+"}");
        //return squares;
        var oriented = "";
        var loop;
        var pos;
        var nextChar;
        for (loop = 0; loop < squares.length; loop++) {
            nextChar = squares.charAt(loop);
            msg = "[" + piece + "." + orientation + ":" + nextChar + "->";
            // apply orientation to the selected piece string
            if (orientation & VERT_FLIP) {
                pos = char2piece(nextChar);
                nextChar = vertReplace.charAt(pos);
                msg += pos + nextChar + "->";
            }
            if (orientation & HORZ_FLIP) {
                pos = char2piece(nextChar);
                nextChar = horzReplace.charAt(pos);
                msg += pos + nextChar + "->";
            }
            if (orientation & DIAG_FLIP) {
                pos = char2piece(nextChar);
                nextChar = diagReplace.charAt(pos);
                msg += pos + nextChar + "->";
            }
            msg += nextChar + "]";
            oriented += nextChar;
        }
        if (showOrientation) {
            doc.write(msg + oriented + " ");
        } else {
            //alert(msg+oriented+" ");
        }
        return oriented;
        /*
        */
    }

    showOrientation = 0;
    // orientPiece("b", 0);
    // orientPiece("b", 1);
    // orientPiece("b", 2);
    // orientPiece("b", 3);
    // orientPiece("b", 4);
    // orientPiece("b", 5);
    // orientPiece("b", 6);
    // orientPiece("b", 7);
    showOrientation = 0;

    function initAvailablePieces() {
        var loop = "a";
        var color = FIRSTCOLOR;
        var idx = 0;
        for (idx = 0; idx < 21; idx++) {
            for (color = FIRSTCOLOR; color <= LASTCOLOR; color++) {
                loop = String.fromCharCode(idx + "a".charCodeAt(0));
                var pieceName = colorChars[color] + loop;
                availablePieces[pieceName] = 1;	// yes, available to play
                // doc.images[imgIdxColors[color] + idx].s = "images/B" + loop + ".jpg";
            }
        }
    }

// given a move list, apply the first N moves
// out: rest of list (or "" if no more moves)
    function applyNMoves(n, moves) {
        var loop;
        for (loop = 0; moves != "" && loop < n; loop++, curMove++, getNextColor()) {
            var orientation = moves.charAt(0);
            if (isPassChar(orientation) == 1) {
                moves = moves.substring(1, moves.length);
                hasPassed[curColor] = "PASSED";
                setPass(curColor, hasPassed[curColor]);
                //alert( "hasPassed[" + curColor + "]=" + hasPassed[curColor] );
            } else {
                var piece = moves.charAt(1);

                console.log("orientPiece("+piece+","+orientation+")["+moves+"] ");
                var orientedSquares = orientPiece(piece, orientation);
                //TODO: draw the entire piece not just one square
                var xPos = moves.charAt(2);
                var yPos = moves.charAt(3);
                xPos = char2boardX(xPos);
                yPos = char2boardY(yPos);

                for (i = 0; i < orientedSquares.length; i++) {
                    // get 0-24
                    var curChar = orientedSquares.charAt(i);
                    posIdx = board2posIndex(xPos + char2pieceX(curChar) - 2, yPos + char2pieceY(curChar) - 2);
                    pos[posIdx] = curColor;
                }

                // SCORING:
                //	+1 point for each square covered
                //	+15 points for completing
                //	+5 points if the last piece played is the one square
                var score = getScore(curColor) * 1 + orientedSquares.length;
                if (89 == score) {
                    score += 15;
                    if (1 == orientedSquares.length) score += 5;
                }
                setScore(curColor, score);

                //??? placePiece(orientation,piece,
                moves = moves.substring(4, moves.length);

                // Hide the piece they used
                // mark piece as used (and hide it)
                availablePieces[colorChars[curColor] + piece] = 0;	// piece is used
                piece = char2piece(piece);
                // doc.images[imgIdxColors[curColor] + piece].s = "images/i.jpg";
            }
        }
        if (moves == "") {
            // nothing left of list, stop any auto-play
            Astop();
        }
        //return anything left of list
        return moves;
    }

// given a move list, apply the first N moves
// out: rest of list (or "" if no more moves)
    function applyNAndShow(n) {

        restOfMoves = applyNMoves(n, restOfMoves);
        drawPosition();
    }

//
    function goMoveN(n) {
        initPosition();
        applyNAndShow(n);
    }

//
    function AutoMv() {
        applyNAndShow(1);
    }

    function Astart(g) {
        nowAutoMoving = 1;
        tmid = setInterval('AutoMv()', delay);
        AutoMv();
    }

    function stopAnyPlayback(g) {
        Astop();
        // can I find another use for this control?
    }

    function Forward3(g) {
        Astop();
        applyNAndShow(3);
    }

    function Back3(g) {
        Astop();
        curMove -= 3;
        if (curMove <= 0) {
            curMove = 0;
            curColor = FIRSTCOLOR;
        } else {
            getNextColor();
        }
        restOfMoves = moves;
        goMoveN(curMove);
    }

    function GoStart(g) {
        Astop();
        goMoveN(0);
    }

    function GoEnd(g) {
        Astop();
        goMoveN(85);	//there are only 84 pieces so this is guaranteed to go to the end
    }

    function Forward(g) {
        Astop();
        applyNAndShow(1);
    }

    function Back(g) {
        Astop();
        curMove -= 1;
        if (curMove < 0) curMove = 0;
        restOfMoves = moves;
        goMoveN(curMove);
    }

    function Step(g) {
        // what was this supposed to do?  pass a turn?
        // st[g]^=1;
        // doc.images[jb[g]+64].src='pw/conpanel/p3condb.gif';
    }

    function KeyDown() {
        var key = 0;
        //if( event.type != 'keydown' ) return;
        key = event.keyCode;
        if (key != 0)
            ActOnKey(key);
    }

    function ActOnKey(key) {
        if (key == 37 || key == 100)
            Back()
        if (key == 39 || key == 102)
            Forward()
        if (key == 103)
            GoStart()
        if (key == 97)
            GoEnd()
        if (key == 111)
            stopAnyPlayback()
        if (key == 106)
            Astart()
        if (key == 96)
            Step();
        //if(!posbrd)
        //MvStr();
    }

    function DropPc(g) {
    }

    var myPage;
    myPage = window.location.toString();
//alert( "myPage0="+myPage);
    var qqq = myPage.indexOf("?");
///alert( "qqq="+qqq);
    if (qqq > 0) myPage = myPage.substring(0, qqq);

//alert( "myPage="+myPage);


    function mailLink(huh) {
        if (0 == pieceWasPlaced) {
            alert("Please place a piece before clicking this link.");
            return;
        }
        var fullpage = myPage;
        myPage = "blokus.htm";
        myPage += "?P=" + players + "&M=" + moves;
        fullpage += "?P=" + players + "&M=" + moves;
        //alert( "myPage2=" + myPage);
        myPage = "<a href='" + myPage + "'>next position</a>";
        //alert( "myPage3="+myPage);

        var subj = playerFirstname(curColor) + " - ";
        var curPlayer = playerFullname(1 + (curColor + 2) % 4);
        var sep = ";";
        if (curPlayer.indexOf("Maynard") > 0) sep = ",";
        subj += curPlayer + " says it is your turn ";
        subj += "(move " + (numMoves + 2) + ") ";
        subj += "in Blokus";

        var allEmails = playerEmail(BLUESQUARE) + sep + playerEmail(YELLOWSQUARE) + sep;
        allEmails += playerEmail(REDSQUARE) + sep + playerEmail(GREENSQUARE);
        allEmails += sep + playerList[0].split(",")[2];	// spam myself!
        var msg = "<html><head></head><body>";
        msg += "<h1>You are not done yet...</h1><br>";
        msg += "If you can use a 'mailto' link, then ";
        msg += " <a href=mailto:" + nextPlayersEmail(curColor);
        //msg += "?to=" + nextPlayersEmail(curColor);
        //msg += "?from=" + playerEmail(curColor);
        msg += "?subject=" + escape(subj);
        msg += "&body=";
        msg += escape(doc.form0.comment.value);
        msg += escape("  ");
        msg += escape(fullpage);
        msg += "&cc=" + allEmails;
        msg += ">click here to email the move</a><br><p>";
        msg += "But if that link doesn't work then copy this info into a new email message:<p><b>StartCopyHere</b><p>";
        msg += "<dl>";
        msg += "<dt>TO<dd>" + nextPlayersEmail(curColor);
        msg += "<dt>CC<dd>" + allEmails;
        msg += "<dt>SUBJECT<dd>" + subj;
        msg += "<dt>BODY<dd>" + doc.form0.comment.value + "<p>" + fullpage + "<p>";
        msg += "</dl><p><b>EndCopyHere</b>";

        msg += String.fromCharCode(13);	//CR
        msg += String.fromCharCode(10);	//LF
        msg += "<hr>";
        msg += "<h2>And <i>after</i> you make your move...</h2>";
        msg += "<a href='" + fullpage;
        msg += "'>...you can return to contemplate the game</a>";

        msg += "<hr>";
        msg += "And if really feeling adventurous try ";
        sep = ",";
//	allEmails = "jtbaylor@idiom.com";
        allEmails = playerEmail(BLUESQUARE) + sep + playerEmail(YELLOWSQUARE) + sep;
        allEmails += playerEmail(REDSQUARE) + sep + playerEmail(GREENSQUARE);
        allEmails += sep + playerList[0].split(",")[2];	// spam myself!
        //allEmails.replace(/\;/g,",");	//fix any semicolons with commas
        splitStr = allEmails.split(";");
        if (splitStr.length > 1) allEmails = splitStr[0] + "," + splitStr[1];
        var commie = doc.form0.comment.value;
        if (commie == "") commie = "blah blah Ginger";
        var mmmm = "mmmm.php4?gub=" + allEmails;
        mmmm += "&fam=" + escape(subj);
        mmmm += "&merm=" + escape(commie + " === " + fullpage);
        mmmm += "&lum=jtbaylor@idiom.com";

        msg += "<a href='" + mmmm;
        msg += "'>a maybe-working way to email your move!</a> (be patient it takes about 10 seconds)";
        msg += "</body></html>";

        //alert( msg );
        doc.write(msg);
    }

    function nextMove(huh) {
        if (0 == pieceWasPlaced) {
            alert("Please place a piece before clicking this link.");
            return;
        }
        var fullpage = myPage;
        myPage = "blokus.htm";
        myPage += "?P=" + players + "&M=" + moves;
        fullpage += "?P=" + players + "&M=" + moves;
        window.location.replace(fullpage);
    }

    // This is only used for the highlight around the player's set of pieces.
    function toggleImgHilight(obj) {
        if (obj) {
            console.log("obj & objSrc");
            console.log(obj);
            console.log(obj.src);
            var src = "";
            var dot = obj.src.indexOf("_H.");
            if (dot >= 0) {
                // un highlight remove _H
                src = obj.src.substring(0, dot);
                src += obj.src.substring(dot + 2);
            } else {
                // highlight if we can find the dot
                dot = obj.src.length - 4;
                //dot = obj.src.indexOf(".gif");
                //if( dot < 0 ) dot = obj.src.indexOf(".jpg");
                if (dot >= 0) {
                    // add "_H"
                    src = obj.src.substring(0, dot);
                    src += "_H";
                    src += obj.src.substring(dot);
                }
            }
            //alert( obj.src + " ==> " + src );
            obj.src = src;
            //doc.images[40].src = "images/i25.jpg";
        } else {
            //doc.images[9].src = "images/Y.jpg";
        }
    }

    function mouseOverBoard(obj) {
        var msg = "";
        msg += "obj=" + obj + ". ";
        obj = event;
        msg += "src=" + obj.src + ", name=" + obj.name + ". ";
        msg += "x=" + obj.x + ", y=" + obj.y + ". ";
        msg += "xO=" + obj.xOffset + ", yO=" + obj.yOffset + ". ";
        msg += "width=" + obj.width + ", height=" + obj.height + ". ";
        //alert( msg );
    }


    function isCurrentColor(piece) {
        // console.log("piece: "+piece+".")
        piece = piece.charAt(0);
        if (BLUESQUARE == curColor && "B" == piece) return 1;
        if (YELLOWSQUARE == curColor && "Y" == piece) return 1;
        if (REDSQUARE == curColor && "R" == piece) return 1;
        if (GREENSQUARE == curColor && "G" == piece) return 1;
        return 0;
    }

    function holdingAPiece() {
        if ("" == pieceInHand) return 0;
        return 1;
    }

    function findAllowableBoardPosition(boardIdx, curPiece) {
        // todo: really check!
        var x = (boardIdx - 23) % 22;
        var y = Math.floor((boardIdx - 23) / 22);
        var xMin = 0;
        var yMin = 0;
        var xMax = 19;
        var yMax = 19;
        var xPos = 0;
        var yPos = 0;

        for (i = 1; i < curPiece.length; i++) {
            // get 'a'-'y'
            var curChar = curPiece.charAt(i);

            // get xPos,yPos in 0-4 range
            xPos = char2pieceX(curChar);
            yPos = char2pieceY(curChar);
            if (xPos < 2 && xMin < (2 - xPos)) xMin = (2 - xPos);
            if (xPos > 2 && xMax > (21 - xPos)) xMax = (21 - xPos);
            if (yPos < 2 && yMin < (2 - yPos)) yMin = (2 - yPos);
            if (yPos > 2 && yMax > (21 - yPos)) yMax = (21 - yPos);
            //alert( "xPos="+xPos+", "+yPos+", "+xMin+", "+xMax+", "+yMin+", "+yMax );
        }
        if (x < xMin) x = xMin;
        if (x > xMax) x = xMax;
        if (y < yMin) y = yMin;
        if (y > yMax) y = yMax;

        boardIdx = 22 * y + x + 23;
        console.log("Re-centering to "+boardIdx+" ("+x+", "+y+")")
        return boardIdx;
    }

    function hilightPieceOnBoard(boardIdx, curPiece) {
        var i;
        var xPos = (boardIdx - 1) % 22;
        var yPos = Math.floor((boardIdx - 1) / 22);
        console.log("boardIdx("+boardIdx+"), curPiece("+curPiece+")")

        drawPosition();
        for (i = 1; i < curPiece.length; i++) {
            // get 0-24
            var curChar = curPiece.charAt(i);
            posIdx = board2imgIndex(xPos + char2pieceX(curChar) - 2, yPos + char2pieceY(curChar) - 2);
            console.log("posIdx("+posIdx+"), curChar("+curChar+")")
            // setCellBorder(posIdx, "2px solid black")
            setCellColor(posIdx, "darkgray")
        }
    }

// oc=onClick
// in: piece - "Gb" for the 2nd Green piece
    function oc(piece) {
        // console.log("as(" + piece + ")")
        if (!isCurrentColor(piece)) return;
        if (holdingAPiece()) {
            // drop the piece
            toggleHilight(pieceInHand);
        }
        if (piece == pieceInHand) {
            // they don't want that piece
            curPiece = "";
            pieceInHand = "";
            return;
        }

        // Choose this piece and place it on the board
        pieceInHand = piece;
        var idx = char2piece(piece.charAt(1));
        curPiece = pieceTypes[idx];
        boardIdx = 189;		//always start near center to avoid confusion
        boardIdx = findAllowableBoardPosition(boardIdx, curPiece);
        hilightPieceOnBoard(boardIdx, curPiece);
    }

    function color2imgs(colorChar) {
        console.log("color2imgs: "+colorChar)
        if ("B" == colorChar) return imgIdxColors[BLUESQUARE];
        if ("Y" == colorChar) return imgIdxColors[YELLOWSQUARE];
        if ("R" == colorChar) return imgIdxColors[REDSQUARE];
        if ("G" == colorChar) return imgIdxColors[GREENSQUARE];
        return 0;
    }

    function toggleHilight(piece) {
        //alert( "toggleHilight("+piece+")" );
        if (!piece || piece.length < 2) {
            return;
        }
        var img = document.getElementById("piece" + piece)
        toggleImgHilight(img);
    }

// omin=OnMouseIn (i.e OnMouseOver)
    function omin(piece) {
        if (!isCurrentColor(piece)) return;
        if (0 == availablePieces[piece]) return;	// piece is used
        toggleHilight(piece);
    }

// omout=OnMouseOut (i.e OnMouseOut)
    function omout(piece) {
        if (!isCurrentColor(piece)) return;
        if (0 == availablePieces[piece]) return;	// piece is used
        if (piece != pieceInHand) {
            toggleHilight(piece);
        }
    }

// obc=onBoardClick
// Place piece on board (if allowed)
    function obc(brdIdx) {
        console.log("obc("+brdIdx+")")
        if (!holdingAPiece()) return;
        // force it onto the board if the mouse position would push it off
        brdIdx = findAllowableBoardPosition(brdIdx, curPiece);

        // Do a lot of validation checking...
        var i;
        var xPos = (boardIdx - 23) % 22;
        var yPos = Math.floor((boardIdx - 23) / 22);
        var x;
        var y;
        var diagNeighbor = 0;
        for (i = 1; i < curPiece.length; i++) {
            // get 0-24
            var curChar = curPiece.charAt(i);
            x = xPos + char2pieceX(curChar) - 2;
            y = yPos + char2pieceY(curChar) - 2;
            if (!isSquareEmpty(x, y)) {
                alert("Cannot place a piece on top of another piece.");
                return;
            }
            if (hasMatchingSideNeighbor(x, y, curColor)) {
                alert("Piece cannot touch a piece of its own color along an edge (only at a corner).");
                return;
            }
            diagNeighbor += hasMatchingDiagNeighbor(x, y, curColor);
        }
        if (!diagNeighbor) {
            var msg = "Piece must touch a piece of its own color at a corner."
            if (numMoves < 4) msg = "First move must cover your corner square.";
            alert(msg);
            return;
        }

        var showAlerts = 0;
        if (showAlerts) alert("brdIdx=" + brdIdx + ", rest=" + restOfMoves + ", curPiece=" + curPiece);
        // TODO: Enable play-next-move and email-next-move links...
        var ourMove = curPiece.charAt(0) + pieceInHand.charAt(1)
        if (showAlerts) alert("ourMove1=" + ourMove + ", rest=" + restOfMoves);
        ourMove += boardX2char((boardIdx - 23) % 22) + boardY2char(Math.floor((boardIdx - 23) / 22));
        if (showAlerts) alert("ourMove2=" + ourMove + ", rest=" + restOfMoves);
        restOfMoves += ourMove;
        if (showAlerts) alert("ourMove=" + ourMove + ", rest=" + restOfMoves);
        moves += ourMove;
        pieceInHand = "";	//now not holding a piece
        pieceWasPlaced = 1;
        GoEnd();
    }

// ombin=OnMouseInBoard (i.e OnMouseOver)
// Highlight piece on board (regardless of whether it is allowed)
    function ombin(brdIdx) {
        console.log("ombin("+brdIdx+")")
        if (!holdingAPiece()) return;

        // Move the in-hand piece closer to the mouse
        boardIdx = findAllowableBoardPosition(brdIdx, curPiece);
        hilightPieceOnBoard(boardIdx, curPiece);
    }

// ombout=OnMouseOutOfBoard (i.e OnMouseOut)
    function ombout(brdIdx) {
        console.log("ombout("+brdIdx+")")
        // Nothing to do?  ombin will re-hilight the piece
    }

    function playerInfo(color) {
        //if( players.charAt( color - 1 ) == "X" ) return;

        doc.write('<INPUT type="text" size="3" readonly="1" value="0" name="' + colorNames[color] + 'score">');
        doc.write('<b><font style="BACKGROUND-COLOR: ' + colorNames[color] + '">');
        doc.write("&nbsp;&nbsp;" + colorNames[color] + ": ");
        doc.write(playerFullname(color) + "&nbsp;&nbsp;</font>");
        doc.write("&nbsp;" + hasPassed[color] + "</b>");
        doc.write('<INPUT type="text" size="6" readonly="1" value="" name="' + colorNames[color] + 'passed"></b>');
    }
