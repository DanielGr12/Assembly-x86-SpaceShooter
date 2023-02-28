IDEAL
MODEL small
	BACKGROUND1_WIDTH = 320
	BACKGROUND1_HEIGHT = 170
	BACKGROUND1_FILE  equ 'back.bmp'
	
	BACKGROUND2_WIDTH = 320
	BACKGROUND2_HEIGHT = 30
	BACKGROUND2_FILE  equ 'back2.bmp'
	
	PLAYER_WIDTH = 45
	PLAYER_HEIGHT = 27
	PLAYER_FILE  equ 'player.bmp'
	
	ENEMY_WIDTH = 30
	ENEMY_HEIGHT = 22
	ENEMY_FILE  equ 'enemy.bmp'
	
	BULLET_WIDTH = 11
	BULLET_HEIGHT = 11
	BULLET_FILE  equ 'bullet.bmp'
	
	HEART_WIDTH = 10
	HEART_HEIGHT = 9
	HEART_FILE  equ 'heart.bmp'
	
	EASY_WIDTH = 42
	EASY_HEIGHT = 23
	EASY_FILE  equ 'easy.bmp'
	
	MED_WIDTH = 42
	MED_HEIGHT = 23
	MED_FILE  equ 'med.bmp'
	
	HARD_WIDTH = 42
	HARD_HEIGHT = 23
	HARD_FILE  equ 'hard.bmp'
	
	AGAIN_WIDTH = 100
	AGAIN_HEIGHT = 50
	AGAIN_FILE  equ 'again.bmp'
	
	START_WIDTH = 94
	START_HEIGHT = 46
	START_FILE  equ 'start.bmp'
	
	INFO_WIDTH = 45
	INFO_HEIGHT = 46
	INFO_FILE  equ 'info.bmp'
	
	HEADER_WIDTH = 320
	HEADER_HEIGHT = 43
	HEADER_FILE  equ 'header.bmp'
	
STACK 100h
DATASEG
	; --------------------------
	; 	  Variables Start
	; --------------------------
	
	escFlag db 0
	
	; BMP Variables
	ScrLine 	db 320 dup (0)  ; One picture line read buffer
	FileHandle	dw ?
	Header 	    db 54 dup(0)
	Palette 	db 400h dup (0)
			  
	BmpLeft dw ?
	BmpTop dw ?
	BmpColSize dw ?
	BmpRowSize dw ?
	
	;BMP File data
	Background1FileName 	db BACKGROUND1_FILE ,0
	Background2FileName 	db BACKGROUND2_FILE ,0
	
	PlayerFileName 	db PLAYER_FILE ,0
	EnemyFileName 	db ENEMY_FILE ,0
	BulletFileName 	db BULLET_FILE ,0
	HeartFileName 	db HEART_FILE ,0
	
	EasyFileName 	db EASY_FILE ,0
	MedFileName 	db MED_FILE ,0
	HardFileName 	db HARD_FILE ,0
	
	AgainFileName 	db AGAIN_FILE ,0
	
	HeaderFileName 	db HEADER_FILE ,0
	StartFileName 	db START_FILE ,0
	InfoFileName 	db INFO_FILE ,0
	
	
	
	
	;Random variable
	RndCurrentPos dw start
	
	playerXpos dw 100
	

	bulletYpos dw ?
	bulletXpos dw ?
	bulletExist dw 0
	bulletDelays db 0
	bulletCollision db 0
	
	enemy1Ypos dw ?
	enemy1Xpos dw ?
	enemy2Ypos dw ?
	enemy2Xpos dw ?
	
	enemyExists db 1
	
	newEnemy1 db 1
	newEnemy2 db 1
	
	showEnemy2 db 0
	enemyDelays db 0
	enemyToDelete db 0
	
	points dw 0
	lastPoints dw 0
	lastPointsStr db 5 dup(0)
	
	lives db 3
	heartX dw ?
	
	endGame db 0
	printOver db "Game Over!!$"
	playAgain db "Play Again?$"
	printInfo db "You are the spaceship at the bottom and there is an enemy that is coming to yourdirection.$"
	printSpeed db "After some time the difficulty will     increase and the enemy will be faster.$"
	printControls db "You have 3 hearts and the game ends if  you lose all of your hearts.$"
	printPurpose db "You need to destroy the enemy using yourbullet.$"
	printSpaceBar db "SpaceBar = shoot bullet$"
	printRight db "Right arrow = move right$"
	printLeft db "Left arrow = move left$"
	printPress db "     Press any key to start the game$"
	printHighScore db "High score:$"
	printHighMessage db "You broke the high score!!!$"
	brokeScore db 0
	
	enemySpeed db 15
	changeDifficulty db 0
	difficultyTimer db 0
	level db 0
	
	startAgain db 0
	againX dw ?
	againY dw ?
	exitLoop db 0
	
	playX dw ?
	playY dw ?
	
	infoX dw ?
	infoY dw ?
	
	exitStartLoop db 0
	playGame db 0
	
	
	;High score file
	highScoreFileName db "high.txt",0
	highScoreFileHandle dw ?
	fileLenParam dw ?
	errorFile dw 0
	tempChar db ?
	clearChar db '_'
	byte_buff db 0
	; --------------------------
	; 	   Variables End
	; --------------------------
	CODESEG
start:
	mov ax, @data
	mov ds, ax
	
	;Graphics Mode
	mov ax,13h
	int 10h
	
	;Draw the first frame (without it there will be no player because it renders it after the player has pressed something)
	call StartScreen
	
	;Show Mouse
	mov ax,1
	int 33h
	
	;Asyncronic mouse
	push ds
	pop  es	 
	mov ax, seg CheckStart 
	mov es, ax
	mov dx, offset CheckStart   ; ES:DX ->Far routine
	mov ax,0Ch             ; interrupt number
    mov cx,0Ah              ; 2 + 8   Left Down and Right down
    int 33h
	
@@StartLoop:
	cmp [exitStartLoop],1
	jne @@StartLoop
	cmp [playGame],1
	
	;Hide Mouse
	mov ax,2
	int 33h
	
	je Game
	
Info:
	call InfoBackScreen
	;Set the cursor to the middle of the screen
	mov ah,2
	mov bh,0
	mov dh, 6 ; line number
	mov dl, 0; column number
	int 10h
	
	mov dx, offset printInfo  
	mov ah, 9
	int 21h
	
	call NewLine
	call NewLine
	
	mov dx, offset printSpeed  
	mov ah, 9
	int 21h
	
	call NewLine
	call NewLine
	
	mov dx, offset printControls
	mov ah, 9
	int 21h
	
	call NewLine
	call NewLine
	
	mov dx, offset printPurpose  
	mov ah, 9
	int 21h
	
	call NewLine
	call NewLine
	
	mov dx, offset printSpaceBar  
	mov ah, 9
	int 21h
	
	call NewLine
	
	mov dx, offset printRight
	mov ah, 9
	int 21h
	
	call NewLine
	
	mov dx, offset printLeft  
	mov ah, 9
	int 21h
	
	call NewLine
	call NewLine
	
	mov dx, offset printPress  
	mov ah, 9
	int 21h
    
	mov ah,7 ;silent input
	int 21h
	
Game:
	;delete Asyncronic mouse
	push ds
	pop  es	 
	mov ax, seg CheckStart 
	mov es, ax
	mov dx, offset CheckStart   ; ES:DX ->Far routine
	mov ax,0Ch             ; interrupt number
    mov cx,0Ah              ; 2 + 8   Left Down and Right down
    int 33h
	
	
	call DrawScreen
; --------------------------
; 	   	  MAIN LOOP
; --------------------------
MainLoop:
	;Check if the player has pressed on esc
	cmp [escFlag],1
	je exit
	
	;move the bullet and the enemy
	call IncBullet
	call IncEnemy
	
	call DoDelay50
	
	;Check in the player has pressed a key
	call KeyPressed
	
	call ChangeLevel

	;Check if Game Over
	cmp [endGame],0
	je MainLoop
; --------------------------
;       END MAIN LOOP
; --------------------------

exit:
	mov dx,offset highScoreFileName
	call OpenFile
	call WriteToFile
	call CloseFile
	mov [enemyExists],0
	call Render
	
	cmp [brokeScore],1
	jne @@ContinuePrinting
	;Set the cursor to the middle up of the screen
	mov ah,2
	mov bh,0
	mov dh, 6 ; line number
	mov dl, 8; column number
	int 10h
	
	mov dx, offset printHighMessage  
	mov ah, 9
	int 21h
	
@@ContinuePrinting:
	;Set the cursor to the middle of the screen
	mov ah,2
	mov bh,0
	mov dh, 8 ; line number
	mov dl, 15; column number
	int 10h
	
	;Print "Game Over!!"
	mov dx,offset printOver
	mov ah,9
	int 21h
	
	;Set the cursor to two lines under the "Game Over"
	mov ah,2
	mov bh,0
	mov dh, 10 ; line number
	mov dl, 15; column number
	int 10h
	
	;Print "Play Again?"
	mov dx,offset playAgain
	mov ah,9
	int 21h
	
	mov [BmpLeft],113
	mov [BmpTop],105
	
	mov ax,[BmpLeft]
	mov [againX],ax
	
	mov ax,[BmpTop]
	mov [againY],ax
	
	mov dx, offset AgainFileName
	mov [BmpColSize], AGAIN_WIDTH
	mov [BmpRowSize], AGAIN_HEIGHT
	call OpenShowBmp

	;Asyncronic mouse
	push ds
	pop  es	 
	mov ax, seg CheckClick 
	mov es, ax
	mov dx, offset CheckClick   ; ES:DX ->Far routine
	mov ax,0Ch             ; interrupt number
    mov cx,0Ah              ; 2 + 8   Left Down and Right down
    int 33h
	
	;Show Mouse
	mov ax,1
	int 33h
	
@@WaitForRespond:
	cmp [exitLoop],1
	jne @@WaitForRespond
	
	cmp [startAgain],1
	jne @@stop
	
@@Again:
	;If the player wants to play again
	call InitVars
	jmp MainLoop
	
@@stop:
	
	;Text Mode
	mov ax,2
	int 10h

	mov ax, 4c00h
	int 21h
	
	
;---------------------------------------------
; 				  Functions
;---------------------------------------------
proc NewLine
	mov dl, 0Ah
	mov ah, 2
	int 21h
	ret
endp NewLine


proc InfoBackScreen
	;Draw Background1 (upper part)
	mov [BmpLeft],0
	mov [BmpTop],0
	mov dx, offset Background1FileName
	mov [BmpColSize], BACKGROUND1_WIDTH
	mov [BmpRowSize], BACKGROUND1_HEIGHT
	call OpenShowBmp

	;Draw Background2 (lower part)
	mov [BmpLeft],0
	mov [BmpTop],170
	mov dx, offset Background2FileName
	mov [BmpColSize], BACKGROUND2_WIDTH
	mov [BmpRowSize], BACKGROUND2_HEIGHT
	call OpenShowBmp

	; Draw Header
	mov [BmpLeft],0
	mov [BmpTop],7
	mov dx, offset HeaderFileName
	mov [BmpColSize], HEADER_WIDTH
	mov [BmpRowSize], HEADER_HEIGHT
	call OpenShowBmp
	ret
endp InfoBackScreen

proc ChangeLevel
	cmp [difficultyTimer],255
	jae @@CheckIfToChange

	jmp @@finish
@@CheckIfToChange:
	inc [changeDifficulty]
	cmp [changeDifficulty],10
	jne @@CheckEnemy2
@@IncreaseDifficulty:
	mov [changeDifficulty],0
	mov [difficultyTimer],0
	
	cmp [enemySpeed],15
	je @@MidChange
	
	cmp [enemySpeed],8
	je @@LastChange
	
	jmp @@CheckEnemy2
@@MidChange:
	mov [enemySpeed],8
	mov [enemyDelays],8
	mov [level],1
	jmp @@CheckEnemy2
@@LastChange:
	mov [enemySpeed],4	
	mov [enemyDelays],4
	mov [level],2
@@CheckEnemy2:
	cmp [newEnemy2],1
	jne @@finish
	cmp [changeDifficulty],4
	jne @@finish
	mov [showEnemy2],1
@@finish:
	ret
endp ChangeLevel



;When a key is pressed
proc KeyPressed
	;async keyboard read
	mov ah,1
	int 16h
	jz @@stop
	
	;Read the key if a key was pressed
	mov ah,0
	int 16h
	
	;Check if right
	cmp ah,04Dh
	je @@right
	
	;Check if left
	cmp ah,04Bh
	je @@left
	
	;Check if spaceBar
	cmp ah,39h
	je @@space
	
	;Check if Esc
	cmp ah,1
	je changeFlag
	jmp @@stop
changeFlag:
	mov [escFlag],1
	jmp @@drawScreen
@@right:
	cmp [playerXpos],275
	jne @@IncPos
	mov [playerXpos],0
	jmp @@drawScreen
@@IncPos:
	inc [playerXpos]
	jmp @@drawScreen
	
@@left:
	cmp [playerXpos],0
	jne @@DecPos
	mov [playerXpos],275
	jmp @@drawScreen
@@DecPos:
	dec [playerXpos]
	jmp @@drawScreen

@@space:
	mov [bulletExist],1
	mov ax,[playerXpos]
	add ax,17
	mov [bulletXpos],ax
	mov [bulletYpos],150
	mov [bulletDelays],4
	call IncBullet
@@drawScreen:
	call RenderPlayerMovement
@@stop:
	ret
endp KeyPressed



proc IncBullet
	;check if the bullet exists
	cmp [bulletExist],0
	je @@MidJump
	
	;check if the delay is over
	cmp [bulletDelays],4
	jne @@MidJump
	mov [bulletDelays],0
	
	;Draw Bullet if exists
	call Render
	cmp [bulletYpos],0
	je @@deleteBullet
	
	mov ax,[bulletXpos]
	mov [BmpLeft],ax
	
	mov ax,[bulletYpos]
	mov [BmpTop],ax
	
	mov dx, offset BulletFileName
	mov [BmpColSize], BULLET_WIDTH
	mov [BmpRowSize], BULLET_HEIGHT
	call OpenShowBmp
	dec [bulletYpos]
	
	jmp @@continue
@@MidJump:
	jmp @@end
	
@@continue:
	;Check if there is a collision between the enemy and the bullet
	call CheckEnemy1Collision
	call CheckEnemy2Collision
	jmp @@end
@@deleteBullet:
	mov [bulletExist],0
	mov [bulletDelays],0
	call Render
@@end:
	ret
endp IncBullet

proc CheckEnemy1Collision
	mov ax,[enemy1Xpos]
	cmp [bulletXpos],ax
	jb @@end
@@CheckXBelow:
	add ax,ENEMY_WIDTH
	cmp [bulletXpos],ax
	ja @@end
@@CheckY:
	mov ax,[enemy1Ypos]
	add ax,ENEMY_HEIGHT
	cmp [bulletYpos],ax
	jbe @@Collision
	jmp @@end
@@Collision:
	mov [bulletExist],0
	inc [points]
	mov [newEnemy1],1
	call Render
	jmp @@end
@@deleteBullet:
	mov [bulletExist],0
	mov [bulletDelays],0
	call Render
@@end:
	ret
endp CheckEnemy1Collision
proc CheckEnemy2Collision
	mov ax,[enemy2Xpos]
	cmp [bulletXpos],ax
	jb @@end
@@CheckXBelow:
	add ax,ENEMY_WIDTH
	cmp [bulletXpos],ax
	ja @@end
@@CheckY:
	mov ax,[enemy2Ypos]
	add ax,ENEMY_HEIGHT
	cmp [bulletYpos],ax
	jbe @@Collision
	jmp @@end
@@Collision:
	mov [bulletExist],0
	inc [points]
	mov [newEnemy2],1
	call Render
	jmp @@end
@@deleteBullet:
	mov [bulletExist],0
	mov [bulletDelays],0
	call Render
@@end:
	ret
endp CheckEnemy2Collision

proc IncEnemy
	;check if the enemy exists
	cmp [enemyExists],0
	je @@mid
	
	;check if the delay is over
	mov al,[enemySpeed]
	cmp [enemyDelays],al
	jne @@mid
	mov [enemyDelays],0

	;call ShowAxDecimal
	
	;Draw Enemys if exists
	
	call Render
	;Enemy 1
	cmp [enemy1Ypos],148
	mov [enemyToDelete],1
	je @@deleteEnemy
	
	mov ax,[enemy1Xpos]
	mov [BmpLeft],ax
	
	mov ax,[enemy1Ypos]
	mov [BmpTop],ax
	
	mov dx, offset EnemyFileName
	mov [BmpColSize], ENEMY_WIDTH
	mov [BmpRowSize], ENEMY_HEIGHT
	call OpenShowBmp
	
	jmp @@continueRender
@@mid:
	jmp @@end
	
@@continueRender:
	;Enemy 2
	cmp [showEnemy2],1
	jne @@incYpos
	cmp [enemy2Ypos],148
	mov [enemyToDelete],2
	je @@deleteEnemy
	
	mov ax,[enemy2Xpos]
	mov [BmpLeft],ax
	
	mov ax,[enemy2Ypos]
	mov [BmpTop],ax
	
	mov dx, offset EnemyFileName
	mov [BmpColSize], ENEMY_WIDTH
	mov [BmpRowSize], ENEMY_HEIGHT
	call OpenShowBmp
	inc [enemy2Ypos]
@@incYpos:
	inc [enemy1Ypos]
	jmp @@end
@@deleteEnemy:
	mov [enemyExists],1
	cmp [enemyToDelete],1
	je @@New1
	cmp [enemyToDelete],2
	je @@New2
@@New1:
	mov [newEnemy1],1
	jmp @@cont
@@New2:
	mov [newEnemy2],1
@@cont:
	mov [enemyDelays],0
	dec [lives]
	call Render
	cmp [lives],0
	jne @@end
@@StopGame:
	mov [endGame],1
	
@@end:
	ret
endp IncEnemy

;in: heartX
proc DrawHeart
	;Draw Heart
	mov ax,[heartX]
	mov [BmpLeft],ax
	mov [BmpTop],0
	mov dx, offset HeartFileName
	mov [BmpColSize], HEART_WIDTH
	mov [BmpRowSize], HEART_HEIGHT
	call OpenShowBmp
	ret
endp DrawHeart

proc DrawScreen
	call Render
	call RenderPlayerMovement
	ret
endp DrawScreen

proc RenderPlayerMovement
	;Draw Background2 (lower part)
	mov [BmpLeft],0
	mov [BmpTop],170
	mov dx, offset Background2FileName
	mov [BmpColSize], BACKGROUND2_WIDTH
	mov [BmpRowSize], BACKGROUND2_HEIGHT
	call OpenShowBmp
	
	;Draw Player
	mov ax,[playerXpos]
	mov [BmpLeft],ax
	mov [BmpTop],170
	mov dx, offset PlayerFileName
	mov [BmpColSize], PLAYER_WIDTH
	mov [BmpRowSize], PLAYER_HEIGHT
	call OpenShowBmp
	
	ret
endp RenderPlayerMovement

proc Render
;Draw Background1 (upper part)
	mov [BmpLeft],0
	mov [BmpTop],0
	mov dx, offset Background1FileName
	mov [BmpColSize], BACKGROUND1_WIDTH
	mov [BmpRowSize], BACKGROUND1_HEIGHT
	call OpenShowBmp
	
;Draw Difficulty level
	mov [BmpLeft],278
	mov [BmpTop],0
	cmp [level],0
	je @@Easy
	cmp [level],1
	je @@Med
	cmp [level],2
	je @@Hard
@@Easy:
	mov dx, offset EasyFileName
	mov [BmpColSize], EASY_WIDTH
	mov [BmpRowSize], EASY_HEIGHT
	jmp @@ShowBmp
@@Med:
	mov dx, offset MedFileName
	mov [BmpColSize], MED_WIDTH
	mov [BmpRowSize], MED_HEIGHT
	jmp @@ShowBmp
@@Hard:
	mov dx, offset HardFileName
	mov [BmpColSize], HARD_WIDTH
	mov [BmpRowSize], HARD_HEIGHT
	
@@ShowBmp:
	call OpenShowBmp
	
;Draw Enemys
	;Enemy 1
	cmp [enemyExists],1
	jne @@midJump
	cmp [newEnemy1],1
	jne @@DrawEnemy1
	mov bx,0
	mov dx,320
	sub dx,ENEMY_WIDTH
	call RandomByCsWord
	mov [enemy1Xpos],ax
	mov [enemy1Ypos],0
	mov [newEnemy1],0
	
	jmp @@DrawEnemy1
@@midJump:
	jmp @@end
	
	
@@DrawEnemy1:
	mov ax,[enemy1Xpos]
	mov [BmpLeft],ax
	mov ax,[enemy1Ypos]
	mov [BmpTop],ax
	mov dx, offset EnemyFileName
	mov [BmpColSize], ENEMY_WIDTH
	mov [BmpRowSize], ENEMY_HEIGHT
	call OpenShowBmp
	
	;Enemy 2
	cmp [showEnemy2],1
	jne @@end
	cmp [newEnemy2],1
	jne @@DrawEnemy2
	mov bx,0
	mov dx,320
	sub dx,ENEMY_WIDTH
	call RandomByCsWord
	mov [enemy2Xpos],ax
	mov [enemy2Ypos],0
	mov [newEnemy2],0
@@DrawEnemy2:
	mov ax,[enemy2Xpos]
	mov [BmpLeft],ax
	mov ax,[enemy2Ypos]
	mov [BmpTop],ax
	mov dx, offset EnemyFileName
	mov [BmpColSize], ENEMY_WIDTH
	mov [BmpRowSize], ENEMY_HEIGHT
	call OpenShowBmp

@@end:
	;3 hearts
	cmp [lives],3
	je @@Print3Hearts
	
	;2 hearts
	cmp [lives],2
	je @@Print2Hearts
	
	;1 heart
	cmp [lives],1
	je @@Print1Heart
	jmp @@PrintPoints
@@Print3Hearts:
	mov [heartX],18
	call DrawHeart
	mov [heartX],30
	call DrawHeart
	mov [heartX],42
	call DrawHeart
	jmp @@PrintPoints
@@Print2Hearts:
	mov [heartX],18
	call DrawHeart
	mov [heartX],30
	call DrawHeart
	jmp @@PrintPoints
@@Print1Heart:
	mov [heartX],18
	call DrawHeart
	
@@PrintPoints:
	mov ah,2
	mov bh,0
	mov dh, 0 ; line number
	mov dl, 0; column number
	int 10h
	
	mov ax,[points]
	call ShowAxDecimal
	ret
endp Render

proc StartScreen
	;Draw Background1 (upper part)
	mov [BmpLeft],0
	mov [BmpTop],0
	mov dx, offset Background1FileName
	mov [BmpColSize], BACKGROUND1_WIDTH
	mov [BmpRowSize], BACKGROUND1_HEIGHT
	call OpenShowBmp

	;Draw Background2 (lower part)
	mov [BmpLeft],0
	mov [BmpTop],170
	mov dx, offset Background2FileName
	mov [BmpColSize], BACKGROUND2_WIDTH
	mov [BmpRowSize], BACKGROUND2_HEIGHT
	call OpenShowBmp

	; Draw Header
	mov [BmpLeft],0
	mov [BmpTop],7
	mov dx, offset HeaderFileName
	mov [BmpColSize], HEADER_WIDTH
	mov [BmpRowSize], HEADER_HEIGHT
	call OpenShowBmp
	
	; Draw Play
	mov [playX],80
	mov [playY],85
	
	mov [BmpLeft],80
	mov [BmpTop],85
	mov dx, offset StartFileName
	mov [BmpColSize], START_WIDTH
	mov [BmpRowSize], START_HEIGHT
	call OpenShowBmp
	
	; Draw Info
	mov [infoX],190
	mov [infoY],85
	
	mov [BmpLeft],190
	mov [BmpTop],85
	mov dx, offset InfoFileName
	mov [BmpColSize], INFO_WIDTH
	mov [BmpRowSize], INFO_HEIGHT
	call OpenShowBmp
	
	
	mov dx,offset highScoreFileName
	call OpenFile
	; Set the cursor to the middle of the screen
	mov ah,2
	mov bh,0
	mov dh, 8 ; line number
	mov dl, 13; column number
	int 10h
	mov dx, offset printHighScore  
	mov ah, 9
	int 21h
	
	call PrintFile
	call CloseFile
	
	
	
	ret
endp StartScreen
	

proc CheckClick far
	mov ax,3
	int 33h
	shr cx,1
	sub dx,1
	cmp bx,1
	jne @@finish
	
	;Check If yes
	cmp cx,[againX]
	ja @@checkXBelowYes
	jmp @@CheckNo
@@checkXBelowYes:
	mov ax,[againX]
	add ax,50
	cmp cx,ax
	jbe @@checkYAboveYes
	jmp @@CheckNo
@@checkYAboveYes:
	cmp dx,[againY]
	ja @@checkYBelowYes
	jmp @@CheckNo
@@checkYBelowYes:
	mov ax,[againY]
	add ax,50
	cmp dx,ax
	jbe @@Yes
	
@@CheckNo:
	;Check If no
	mov ax,[againX]
	add ax,50
	cmp cx,ax
	ja @@checkXBelowNo
	jmp @@finish
@@checkXBelowNo:
	mov ax,[againX]
	add ax,100
	cmp cx,ax
	jbe @@checkYAboveNo
	jmp @@finish
@@checkYAboveNo:
	cmp dx,[againY]
	ja @@checkYBelowNo
	jmp @@finish
@@checkYBelowNo:
	mov ax,[againY]
	add ax,50
	cmp dx,ax
	jbe @@No
	jmp @@finish
	
@@Yes:
	mov [startAgain],1
	mov [exitLoop],1
	jmp @@finish
@@No:
	mov [startAgain],0
	mov [exitLoop],1

@@finish:
	retf
endp CheckClick
	

proc CheckStart far
	mov ax,3
	int 33h
	shr cx,1
	sub dx,1
	cmp bx,1
	jne @@finish
	
	;Check Play
	cmp cx,[playX]
	ja @@checkXBelowPlay
	jmp @@CheckInfo
@@checkXBelowPlay:
	mov ax,[playX]
	add ax,94
	cmp cx,ax
	jbe @@checkXAbovePlay
	jmp @@CheckInfo
@@checkXAbovePlay:
	cmp dx,[playY]
	ja @@checkYBelowPlay
	jmp @@CheckInfo
@@checkYBelowPlay:
	mov ax,[playY]
	add ax,46
	cmp dx,ax
	jbe @@Play
	
@@CheckInfo:
	;Check Info
	mov ax,[infoX]
	cmp cx,ax
	ja @@checkXBelowInfo
	jmp @@finish
@@checkXBelowInfo:
	mov ax,[infoX]
	add ax,45
	cmp cx,ax
	jbe @@checkYAboveInfo
	jmp @@finish
@@checkYAboveInfo:
	cmp dx,[infoY]
	ja @@checkYBelowInfo
	jmp @@finish
@@checkYBelowInfo:
	mov ax,[infoY]
	add ax,46
	cmp dx,ax
	jbe @@Info
	jmp @@finish
	
@@Play:
	mov [playGame],1
	mov [exitStartLoop],1
	jmp @@finish
@@Info:
	mov [playGame],0
	mov [exitStartLoop],1

@@finish:
	retf
endp CheckStart
	

;Init Variables
proc InitVars
	;set every vairable that needs to change
	mov [escFlag],0
	mov [level],0
	mov [enemySpeed],15
	mov [enemyDelays],15
	mov [endGame],0
	mov [enemyExists],1
	mov [lives],3
	mov [points],0
	mov [exitLoop],0
	mov [startAgain],0
	mov [newEnemy1],1
	mov [newEnemy2],1
	mov [changeDifficulty],0
	mov [difficultyTimer],0
	mov [showEnemy2],0
	mov [brokeScore],0
	;Hide Mouse
	mov ax,2
	int 33h
	
	
	
	;Draw the first frame
	call DrawScreen
	
	ret
endp InitVars


; delay of 50 mSec
proc DoDelay50
	push cx
	mov cx, 50
	Delay1:
		push cx
		mov cx, 6000
		Delay2:
			loop Delay2
		pop cx
	loop Delay1
	inc [bulletDelays]
	inc [enemyDelays]
	inc [difficultyTimer]
	pop cx
	ret
endp DoDelay50


;-----------------------
;    File Functions
;-----------------------
proc FileLen
	mov ah,42h
	mov bx,[highScoreFileHandle]
	mov al,2
	mov cx,0
	mov dx,0
	int 21h
	mov [fileLenParam],ax
	mov al,0
	mov ah,42h
	int 21h
	ret
endp FileLen
proc PrintFile
	call FileLen
	mov cx,[fileLenParam]
	mov bx,[highScoreFileHandle]
@@LoopFile:
	push cx
	mov dx,offset tempChar
	mov cx,1
	mov ah,3Fh
	int 21h
	mov dl, [tempChar]
	mov ah, 2
	int 21h
	pop cx
	loop @@LoopFile
	ret
endp PrintFile


proc FileScore
	call FileLen
	
	; change file pointer to start for write
    mov ah, 42h
    mov al, 0
    mov bx, [highScoreFileHandle]
    xor cx, cx
    xor dx, dx
    int 21h
	
	
	
	
	mov cx,[fileLenParam]
	mov dx,offset lastPointsStr
	mov ah,3Fh
	int 21h
	push offset lastPointsStr
	push [fileLenParam]
	call toInt
	mov [lastPoints],ax
	
	
	ret
endp FileScore

; Parses string to int
; P1: offset of string to parse
; P2: number of bytes to parse into int
; RETURNS AX = answer
proc toInt
    push bp
    mov bp, sp
	
    off equ [bp+6]
    amt equ [bp+4]

    mov si, off
    mov cx, amt

	;from last digit to the first
    add si, cx
    dec si

    xor ax, ax ; holder for the number
	
	;multiply offset
    mov bx, 1

@@AddDigit: 
    push ax ;push for saving ax
    xor ah, ah
    mov al, [si] ; the digit in the memory
    sub al, '0'
    xor dx, dx; for the multiply
    mul bx
    mov dx, ax; move dx the digit
    pop ax
	
	;at first add the units -> tens -> hundreds -> thousands...
	add ax, dx; add the digit to the number
    push ax
    mov ax, 10
    xor dx, dx
    mul bx ;bx has first 1 -> 10 -> 100 -> 1000
    mov bx, ax
    pop ax
    dec si
    loop @@AddDigit
    pop bp
    ret 4
endp toInt
proc WriteToFile
	call FileScore
	mov ax,[lastPoints]
	cmp ax,[points]
	ja @@end
	mov dx,offset highScoreFileName
	call OpenFile
	call FileLen
	mov cx,[fileLenParam]

    
    ; change file pointer to start for write
    mov ah, 42h
    mov al, 0
    mov bx, [highScoreFileHandle]
    xor cx, cx
    xor dx, dx
    int 21h
    
    mov ax, [points]
    
    xor cx, cx ; points counter
    
    ; Write new highscore to file (overrides old highscore which must have less or equal num of digits of new so no corruption of data
@@PushDigsToStack:
    
    mov bx, 10
    xor dx, dx
    div bx
    
    ; dig in dx (%)
    
    add dx, '0' ; turn dx into number
    
    push dx
    
    inc cx ; inc points counter
    
    cmp ax, 0
    jnz @@PushDigsToStack
    
    ; num of digs in cx
    
@@WriteDigits:
    
    pop ax ; pop digit into ax
    mov [byte_buff], al ; mov digit into buffer
    
    push cx
    mov ah, 40h
    mov bx ,[highScoreFileHandle]
    mov cx, 1 ; write 1 byte
    mov dx, offset byte_buff
    int 21h
    pop cx
    
    loop @@WriteDigits
	mov [brokeScore],1
	

@@end:
	call CloseFile
	ret
endp WriteToFile

proc OpenFile
	mov ah,3Dh
	mov al,2
	int 21h
	jc @@ErrorAtOpening
	mov [highScoreFileHandle],ax
	jmp @@finish
@@ErrorAtOpening:
	mov [errorFile],1
@@finish:
	ret
endp OpenFile
proc CloseFile
	mov ah,3Eh
	mov bx,[highScoreFileHandle]
	int 21h
	jc @@ErrorAtClosing
	jmp @@finish
@@ErrorAtClosing:
	mov [errorFile],1
@@finish:
	ret
endp CloseFile
;-----------------------
;  End File Functions
;-----------------------


;-----------------------
;    BMP FUNCTIONS
;-----------------------
; input dx FileName
proc OpenShowBmp 
	
	call OpenBmpFile	
	
	call ReadBmpHeader
	
	call ReadBmpPalette
	
	call CopyBmpPalette
	
	call ShowBmp

	call CloseBmpFile
	ret
endp OpenShowBmp

; input dx filename to open
proc OpenBmpFile
	mov ah, 3Dh
	xor al, al
	int 21h
	mov [FileHandle], ax
	ret
endp OpenBmpFile

; input [FileHandle]
proc CloseBmpFile
	push bx
	
	mov ah,3Eh
	mov bx, [FileHandle]
	int 21h
	
	pop bx
	ret
endp CloseBmpFile


; Read and skip first 54 bytes the Header
proc ReadBmpHeader						
	push cx
	push dx
	
	mov ah,3fh
	mov bx, [FileHandle]
	mov cx,54
	mov dx,offset Header
	int 21h
	
	pop dx
	pop cx
	ret
endp ReadBmpHeader

; Read BMP file color palette, 256 colors * 4 bytes (400h)
; 4 bytes for each color BGR (3 bytes) + null(transparency byte not supported)	
proc ReadBmpPalette  		
	push cx
	push dx
	
	mov ah,3fh
	mov cx,400h
	mov dx,offset Palette
	int 21h
	
	pop dx
	pop cx
	
	ret
endp ReadBmpPalette


; Will move out to screen memory the pallete colors
; video ports are 3C8h for number of first color (usually Black, default)
; and 3C9h for all rest colors of the Pallete, one after the other
; in the bmp file pallete - each color is defined by BGR = Blue, Green and Red
proc CopyBmpPalette							
										
	push cx
	push dx
	
	mov si,offset Palette
	mov cx,256
	mov dx,3C8h
	mov al,0  ; black first							
	out dx,al ;3C8h
	inc dx	  ;3C9h
CopyNextColor:
	mov al,[si+2] 		; Red				
	shr al,2 			; divide by 4 Max (max is 63 and we have here max 255 ) (loosing color resolution).				
	out dx,al 						
	mov al,[si+1] 		; Green.				
	shr al,2            
	out dx,al 							
	mov al,[si] 		; Blue.				
	shr al,2            
	out dx,al 							
	add si,4 			; Point to next color.(4 bytes for each color BGR + null)				
								
	loop CopyNextColor
	
	pop dx
	pop cx
	
	ret
endp CopyBmpPalette

proc ShowBMP 

; BMP graphics are saved upside-down.
; Read the graphic line by line (BmpRowSize lines in VGA format),
; displaying the lines from bottom to top.
    push cx
    push bx

    mov bx, [FileHandle]

    mov ax, 0A000h
    mov es, ax

    mov cx,[BmpRowSize]

 
    mov ax,[BmpColSize] ; row size must dived by 4 so if it less we must calculate the extra padding bytes
    xor dx,dx
    mov si,4
    div si
    cmp dx,0
    mov bp,0
    jz @@row_ok
    mov bp,4
    sub bp,dx

@@row_ok:
    mov dx,[BmpLeft]

@@NextLine:
    push cx
    push dx

    mov di,cx  ; Current Row at the small bmp (each time -1)
    add di,[BmpTop] ; add the Y on entire screen

 
    ; next 5 lines  di will be  = cx*320 + dx , point to the correct screen line
    mov cx,di
    shl cx,6
    shl di,8
    add di,cx
    add di,dx

    ; small Read one line
    mov ah,3fh
    mov cx,[BmpColSize]
    add cx,bp  ; extra  bytes to each row must be divided by 4
    mov dx,offset ScrLine
    int 21h
    ; Copy one line into video memory
    cld ; Clear direction flag, for movsb
    mov cx,[BmpColSize]
    mov si,offset ScrLine
    ;Pink Screen Loop
@@LoopBMP:
    mov dl, [si]
    cmp dl, 0EFh ;Check for pink
    jne @@PrintByte ;If it isn't pink then print
    inc si
    inc di
    jmp @@EndOfLoopBmp
@@PrintByte:
    movsb
@@EndOfLoopBmp:
    loop @@LoopBMP

    pop dx
    pop cx

    loop @@NextLine

    pop bx
    pop cx
    ret
endp ShowBMP
;----------------End BMP Functions


;---------Random Number Functions

; Description  : get RND between any bl and bh includs (max 0 -255)
; Input        : 1. BX = min (from 0) , DX, Max (till 64k -1)
; 			     2. RndCurrentPos a  word variable,   help to get good rnd number
; 				 	Declre it at DATASEG :  RndCurrentPos dw ,0
;				 3. EndOfCsLbl: is label at the end of the program one line above END start		
; Output:        AX - rnd num from bx to dx  (example 50 - 1550)
; More Info:
; 	BX  must be less than DX 
; 	in order to get good random value again and again the Code segment size should be 
; 	at least the number of times the procedure called at the same second ... 
; 	for example - if you call to this proc 50 times at the same second  - 
; 	Make sure the cs size is 50 bytes or more 
; 	(if not, make it to be more) 
proc RandomByCsWord
    push es
	push si
	push di
 
	
	mov ax, 40h
	mov	es, ax
	
	sub dx,bx  ; we will make rnd number between 0 to the delta between bl and bh
			   ; Now bh holds only the delta
	cmp dx,0
	jz @@ExitP
	
	push bx
	
	mov di, [word RndCurrentPos]
	call MakeMaskWord ; will put in si the right mask according the delta (bh) (example for 28 will put 31)
	
@@RandLoop: ;  generate random number 
	mov bx, [es:06ch] ; read timer counter
	
	mov ax, [word cs:di] ; read one word from memory (from semi random bytes at cs)
	xor ax, bx ; xor memory and counter
	
	; Now inc di in order to get a different number next time
	inc di
	inc di
	cmp di,(EndOfCsLbl - start - 2)
	jb @@Continue
	mov di, offset start
@@Continue:
	mov [word RndCurrentPos], di
	
	and ax, si ; filter result between 0 and si (the nask)
	
	cmp ax,dx    ;do again if  above the delta
	ja @@RandLoop
	pop bx
	add ax,bx  ; add the lower limit to the rnd num
		 
@@ExitP:
	
	pop di
	pop si
	pop es
	ret
endp RandomByCsWord

Proc MakeMaskWord    
    push dx
	
	mov si,1
    
@@again:
	shr dx,1
	cmp dx,0
	jz @@EndProc
	
	shl si,1 ; add 1 to si at right
	inc si
	
	jmp @@again
	
@@EndProc:
    pop dx
	ret
endp  MakeMaskWord

;-------------End of Random Num functions

proc ShowAxDecimal
       push ax
	   push bx
	   push cx
	   push dx
	   
	   ; check if negative
	   test ax,08000h
	   jz PositiveAx
			
	   ;  put '-' on the screen
	   push ax
	   mov dl,'-'
	   mov ah,2
	   int 21h
	   pop ax

	   neg ax ; make it positive
PositiveAx:
       mov cx,0   ; will count how many time we did push 
       mov bx,10  ; the divider
   
put_mode_to_stack:
       xor dx,dx
       div bx
       add dl,30h
	   ; dl is the current LSB digit 
	   ; we cant push only dl so we push all dx
       push dx    
       inc cx
       cmp ax,9   ; check if it is the last time to div
       jg put_mode_to_stack

	   cmp ax,0
	   jz pop_next  ; jump if ax was totally 0
       add al,30h  
	   mov dl, al    
  	   mov ah, 2h
	   int 21h        ; show first digit MSB
	       
pop_next: 
       pop ax    ; remove all rest LIFO (reverse) (MSB to LSB)
	   mov dl, al
       mov ah, 2h
	   int 21h        ; show all rest digits
       loop pop_next
		
   
	   pop dx
	   pop cx
	   pop bx
	   pop ax
	   
	   ret
endp ShowAxDecimal

;-------END-------
EndOfCsLbl:
END start