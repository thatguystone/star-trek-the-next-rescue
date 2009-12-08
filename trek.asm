;Andrew Stone
;Computer Systems Organization -- Nathan Hull
;Spring 2009
;
;Star Trek, The Next Rescue
;
;This is the file used for generating and playing the game.
;
;In this folder, you can find a description of the game in deep, technical 
;detail in the file Report.pdf, so I will not discuss much of the technical 
;implimentation here, though above each procedure you will find descriptions 
;of what they do and how they function.
;
;
;
;=============================================================================
;======   Here, we will define the variables used througout the game    ======
;=============================================================================
;
;Skip executing the variables as code...
;
          jmp       start
;
;Let's set the image locations -- now, not to lecture, but I am not checking
;if these are valid files (no use...only those who know what they are doing
;should ever modify these files), so don't mess things up!
;
IMGSPLASH       db 'Splash.bmp',0       ;The main screen the user sees on load
IMGFAILURE      db 'Failure.bmp',0      ;The screen to show when user dies
IMGSUCCESS      db 'Success.bmp',0      ;The image to show when we win
IMGINSTRUCT     db 'Instrct.bmp',0      ;The instruction screen
IMGSETTINGS     db 'Sett.bmp',0         ;The settings screen
IMGBOPREY       db 'BOPrey.bmp',0       ;The enemy ship
IMGWRBIRD       db 'Warbird.bmp',0      ;Our ship
IMGSHUTTLE      db 'Shuttle.bmp',0      ;Wesley's shuttle
IMGEXPLOSION    db 'Explode.bmp',0      ;A cool graphic for when ships explode
IMGWORMHOLE     db 'Wormhole.bmp',0     ;A pretty little wormhole
IMGJUNK         db 'Junk.bmp',0         ;Space junk
IMGASTEROID     db 'Ast.bmp',0          ;An asteroid
IMGSTATION      db 'Station.bmp',0      ;Our space station
SETTINGS        db 'set.txt',0          ;The file containing difficulty level
;
;These equates hold information about where the squares on the difficulty page
;are location
;
DIFFX1          equ 42                 ;box 1
DIFFY1          equ 100
DIFFX2          equ 42                 ;box 2
DIFFY2          equ 142
DIFFX3          equ 183                ;box 3
DIFFY3          equ 100
DIFFX4          equ 183                ;box 4
DIFFY4          equ 142
DIFF1Ships      equ 5                  ;5 ships to kill at level 1 (easy)
DIFF2Ships      equ 10                 ;10 ships at level 2 (medium)
DIFF3Ships      equ 15                 ;15 ships at level 3 (hard)
DIFF4Ships      equ 30                 ;30 ships at level 4 (impossible)
;
;These variables hold information about the current state of the game
;
shipsLeft       db 0                    ;the number of ships left to kill
dead            db 0                    ;contains whether or not we are dead
;
;Used to hold caches of the objects for the game
;
BOPREYH         equ 30
BOPREYW         equ 48
BOPREY          db BOPREYH*BOPREYW dup(0)
WRBIRDH         equ 13
WRBIRDW         equ 52
WRBIRD          db WRBIRDH*WRBIRDW dup(0)
SHUTTLEH        equ 9
SHUTTLEW        equ 20
SHUTTLE         db SHUTTLEH*SHUTTLEW dup(0)
EXPLOSIONH      equ 31
EXPLOSIONW      equ 52
EXPLOSION       db EXPLOSIONH*EXPLOSIONW dup(0)
WORMHOLEH       equ 40
WORMHOLEW       equ 40
WORMHOLE        db WORMHOLEH*WORMHOLEW dup(0)
JUNKH           equ 26
JUNKW           equ 40
JUNK            db JUNKH*JUNKW dup(0)
ASTEROIDH       equ 28
ASTEROIDW       equ 40
ASTEROID        db ASTEROIDH*ASTEROIDW dup(0)
STATIONH        equ 89
STATIONW        equ 60
STATION         db STATIONH*STATIONW dup(0)
STARCOUNT       equ 100*2-2             ;# of stars on the screen(*2=word val)
STARFIELD       dw 100 dup(0)           ;locations of stars on the screen
;
;Because I don't feel like memorizing where all the items are located, the 
;following equates make for easy access to these items
;
PNT             equ 0                   ;pointer to image location
DIR             equ 2                   ;direction (POS=right, NEG=left)
PAD             equ 4                   ;min dist. from top of screen
X               equ 6                   ;X location of object
Y               equ 8                   ;Y location of object
VERT            equ 10                  ;vertical movement of ship
HORZ            equ 12                  ;horizontal movement of ship
H               equ 14                  ;height of object
W               equ 16                  ;width of object
HULL            equ 18                  ;hull / armor amount remaining
PHSR            equ 20                  ;phaser charge
SHLDS           equ 22                  ;shields remaining
SPRW            equ 24                  ;super weapon...oh yeah!
SHIPLEN         equ 26                  ;length of the above data in total
;
;Used to hold all the information we need about the ships
;Their information is defined in the comments next to each subscript
;
MYSHIP          dw SHIPLEN/2 dup(0)     ;object for our ship
ENEMY           dw SHIPLEN/2 dup(0)     ;object for the enemy ship
ANOMALY         dw 20 dup(0)            ;object for anomalies
SPACEST         dw 20 dup(0)            ;object for the space station
WESLEY          dw 20 dup(0)            ;object for wesley's shuttle
;
;These hold the default values for all of the gaming variables
;NOTE: these are only used for resetting the game after winning or dying
;
;NOTE2: For phaser/hull/shields, these are percents out of 100.
;
shipsLeftDef    db 5
deadDef         db 0
MYSHIPDEF       dw 0                    ;0-pointer to image buffer
                dw 1                    ;2-direction of ship
                dw 15                   ;4-top padding (ie. cant go past this)
                dw 0                    ;6-position of X (max 320)
                dw 25                   ;8-position of Y (max 200)
                dw 0                    ;10-vertical movement
                dw 0                    ;12-horizontal movement
                dw WRBIRDH              ;14-height of object
                dw WRBIRDW              ;16-width of object
                dw 100                  ;18-hull
                dw 100                  ;20-phaser charge
                dw 100                  ;22-shields
                dw 100                  ;24-super weapon
ENEMYDEF        dw 0                    ;0-pointer to image buffer
                dw -1                   ;2-direction of ship
                dw 0                    ;4-top padding (none for this ship)
                dw 320-BOPREYW          ;6-position of X (max 320)
                dw 200-BOPREYH          ;8-position of Y (max 200)=bttm of scr
                dw 0                    ;10-vertical movement
                dw 0                    ;12-horizontal movement
                dw BOPREYH              ;14-height of object
                dw BOPREYW              ;16-width of object
                dw 100                  ;18-hull
                dw 100                  ;20-phaser charge
                dw 0                    ;22-shields (dont have any by default)
                dw 0                    ;24-super weapon -- none by default
ANOMALYDEF      dw 0                    ;0-pointer to image buffer
                dw -1                   ;2-direction
                dw 0                    ;4-top padding
                dw 0                    ;6-position of X (max 320)
                dw 0                    ;8-position of Y (max 200)
                dw 0                    ;10-vertical movement
                dw 0                    ;12-horizontal movement
                dw 0                    ;14-height of object
                dw 0                    ;16-width of object
                dw -1                   ;18-hull (doesn't appear by def)
SPACESTDEF      dw 0                    ;0-pointer to image buffer
                dw -1                   ;2-direction
                dw 0                    ;4-top padding
                dw 320                  ;6-position of X (max 320)
                dw 40                   ;8-position of Y (max 200)
                dw 0                    ;10-vertical movement
                dw 0                    ;12-horizontal movement
                dw STATIONH             ;14-height of object
                dw STATIONW             ;16-width of object
                dw -1                   ;18-hull (set to appear)
WESLEYDEF       dw 0                    ;0-pointer to image buffer
                dw -1                   ;2-direction
                dw 0                    ;4-top padding
                dw 272                  ;6-position of X (max 320)
                dw 120                  ;8-position of Y (max 200)
                dw 0                    ;10-vertical movement
                dw 0                    ;12-horizontal movement
                dw SHUTTLEH             ;14-height of object
                dw SHUTTLEW             ;16-width of object
                dw -1                   ;18-hull (set to appear)
;
;Here, let's set some error messages for if we have problems...
;
msgFileErr      db 'Error opening file.',7,0Dh,0Ah,24h
;
;Now, let's get some space for reading our BMP files and storing temp info
;about them
;
HEADER          dw 0
HEADBUFF        db 54 dup('H')          ;the size of the bmp header
PALBUFF         db 1024 dup('P')        ;set MAX possible size of VGA palette
SCRLINE         db 320 dup(0)           ;the MAX width of the screen (320x200)
PALSIZE         dw ?
BMPWIDTH        dw ?
BMPHEIGHT       dw ?
;
;The following are keyboard scan codes that we will need throughout
;
UPARROW         equ 48h
DOWNARROW       equ 50h
RIGHTARROW      equ 4dh
LEFTARROW       equ 4bh
ESCKEY          equ 01h
ENTERKEY        equ 1ch
SPACEBAR        equ 39h
BACKSPACE       equ 0eh
F2              equ 3ch
;
;For animations, let's define some scrolling constants and the like
;
SCROLL          equ 20                  ;scroll 20px at each update
MYMOVE          equ 20                  ;move 20px per each move
ENEMYMOVE       equ 15                  ;move 15px per move (BOPrey is slow)
AIDISTANCE      equ 125                 ;distance for AI to try to stay away
AISHOOTMARGIN   equ 15                  ;AI will fire when within 15px of us
;
;For weapons, shields, etc, let's define the constants for firing, recharging,
;damage, and everything else.
;
PHASERENERGY    equ 10
PHASERDAMAGE    equ 10
PHASERREGEN     equ 3
SUPERWEPREGEN   equ 3
SHIELDREGEN     equ 1
ANOMALYGENFACTOR equ 95                 ;100-factor=chance of an anomaly
AIGENFACTOR     equ 95                  ;100-factor=chance of new enemy
;
;The following is the background music that is played throughout the game...
; As a side note, this is actually part of the full orchestral score used for
; some of the battles in the original Star Trek.
;
BGMUSIC         dw 50,65,5,0
                dw 25,98,5,0
                dw 15,98,5,0
                dw 35,65,5,0
                dw 20,98,5,0
                dw 15,130,5,0
                dw 20,65,5,0
                dw 15,98,5,0
                dw 20,65,5,0
                dw 15,98,5,0
                dw 35,130,5,0
                dw 35,196,5,0
                dw 35,349,5,0
                dw 15,261,5,0
                dw 15,293,5,0
                dw 15,261,5,0
                dw 20,246,5,0
                dw 35,233,5,0
                dw 40,233,5,0
                dw 55,233,5,0
                dw 25,392,5,0
                dw 15,349,5,0
                dw 15,329,5,0
                dw 15,294,5,0
                dw 20,261,5,0
                dw 30,247,5,0
                dw 20,247,5,0
                dw 0
;
;Default the following values to the first note or things break....
;
BGMUSPOS        dw 2                    ;holds the current note being played
BGMUSCNT        dw 50                   ;# of intervals left to play
BGMUSPOSDEF     dw 2                    ;default for above
BGMUSCNTDEF     dw 50                   ;default for above
;
;
;
;=============================================================================
;======     Here is where the actual game code begins...oh the joy!     ======
;=============================================================================
;
;At this point, we are just going to handle the intro screens and the like
;apart from the rest of the game -- it is helpful to think of this just as a 
;static introduction and the "game" as being the playable part that is defined
;by all of the following procedures.
;
start:
;
;         before we begin anything, let's set the graphics pointers for our
;         objects so that we don't have to worry about it later
;
          call      reset               ;reset all the in-game variables
          call      initGraphics        ;setup the graphics (mode 13h)
;
;         Let's load+display the splash image
;         this could be written as a function...but it's 3 lines...no point
;
showSplash:
          lea       dx, IMGSPLASH
          call      bmpToScreen
waitMain: call      getKey              ;wait for the user to hit something
          cmp       ah, ENTERKEY        ;does the user want to start?
          je        playGame
          cmp       ah, ESCKEY          ;does the user want to exit?
          je        exitGame
          cmp       ah, SPACEBAR        ;does the user want instructions?
          je        showInstructions
          cmp       ah, F2              ;are we changing settings?
          je        changeSettings
          jmp       waitMain            ;the user just hit a random key
;
;These are the functions processed on the main screen via different keys
;
playGame:
          call      loadLevel
;
;         Now that everything is all setup, we can play the level
;
          call      play
waitPlayGame:
          call      getKey
          cmp       ah, ENTERKEY        ;does the user want to start?
          jne       waitPlayGame
          jmp       showSplash
;
;Shows the user the instruction screen and waits for a key press to return
;
showInstructions:
          lea       dx, IMGINSTRUCT     ;get location of image
          call      bmpToScreen         ;show it
showInstructionsWait:
          call      getKey              ;get an input
          cmp       ah, ENTERKEY        ;enter hit?
          jne       showInstructionsWait
          jmp       showSplash          ;retun to main
;
;Change the difficulty settings of the level
;
changeSettings:
          lea       dx, IMGSETTINGS
          call      bmpToScreen
          call      getDifficulty       ;get the difficulty level
          mov       ax, bx
          add       al, '0'             ;fake user input for drawing...
          call      setDifficulty       ;paint it to the screen
changeSettingsWait:
          call      getKey
          cmp       al, '1'             ;determine which level
          je        changeSettingsSet   ;set the level
          cmp       al, '2'
          je        changeSettingsSet   ;set the level
          cmp       al, '3'
          je        changeSettingsSet   ;set the level
          cmp       al, '4'
          je        changeSettingsSet   ;set the level
          cmp       ah, ENTERKEY        ;return to menu?
          je        showSplash
          jmp       changeSettingsWait  ;wait for a real key
changeSettingsSet:
          call      setDifficulty
          jmp       changeSettingsWait
;
;This exits the game upon user request
;
exitGame:
          call      deinitGraphics      ;return to basic dos mode
          call      exit                ;and we're done!
;
;=============================================================================
;======       Below this are all of the procedures for the game         ======
;======   Note: the procedures are grouped by functionality and are in  ======
;======          alphabetical order according to their function.        ======
;=============================================================================
;
;
;
;=============================================================================
;======    Procedures for graphics modes and other misc. functions      ======
;=============================================================================
;
;
;PROCEDURE deinitGraphics
;
; This guy returns to the normal dos text mode.
;
;  INPUT=(void)
; OUTPUT=(void)``
deinitGraphics      proc
          push      ax
;
          mov       ax, 3
          int       10h
;
          pop       ax
          ret
deinitGraphics      endp
;
;
;PROCEDURE exit
;
; Does what the name suggests...
exit                proc
          int       20h
exit                endp
;
;
;PROCEDURE initGraphics
;
; This guy sets the graphics mode to 13h so that the game can be played
; correctly.
;
;  INPUT=(void)
; OUTPUT=(void)
initGraphics        proc
          push      ax
;
          mov       ax, 13h             ;video mode
          int       10h                 ;set video mode
;
          pop       ax
          ret
initGraphics        endp
;
;
;PROCDURE getKey
;
; Waits for the user to hit a key and returns only the scancode
; of that key.
;
;  INPUT=(void)
; OUTPUT=al=the scan code from the keyboard
;        ah=the key
getKey              proc
;
          mov       ax, 0
          int       16h
;
;         the scan code is now contained in AH, so we can simply return it
;
          ret
getKey              endp
;
;
;PROCEDURE raiseError
;
; Displays and error message and exits program execution.
;
;  INPUT=dx - pointer to error message
; OUTPUT=(void) (displays a message and exits the game)
raiseError          proc
          call      deinitGraphics
          mov       ah,9
          int       21h
          call      exit
raiseError          endp
;
;=============================================================================
;======      Procedures for gameplay (user controls, sound, etc).       ======
;======  Nothing here actually pertains to producing sound or reading   ======
;======  images...that is all done in the sections following this one.  ======
;=============================================================================
;
;
;PROCEDURE AI
;
; In all fairness, the computer could match the player move-for-move,
; so I am going to limit the enemy ships to moving at 15pixels per update
; rather than 20, as with the user, so that it will be limited; interestingly
; enough, this does hold true in star trek: the Bird of Preys are far less
; manuverable than the Warbirds...useless trivia for you.
;
; This function also tests if there is indeed a ship present for it to
; control; if there is not, it will randomly generate one if the chances
; are right; otherwise, it just exits
;
; In order for the AI to know where to move the ship, we are just going to
; track the user movements and follow his ship around.
;
;  INPUT=(void)
; OUTPUT=(void)
AI                  proc
          push      ax
          push      bx
          push      cx
          push      di
          push      si
;
;         Make sure that the AI ship is still alive before we start moving...
;
          cmp       ENEMY[HULL], 0
          jl        AIGenerate
;
          mov       ax, ENEMY[Y]        ;get Y position of enemy ship
;
;         we can only fire from the bottom of our ship, so let's try to get
;         aligned with the enemy ship that way
;
          add       ax, ENEMY[H]
          mov       bx, MYSHIP[Y]       ;get Y position of our ship
          cmp       ax, bx              ;which direction should we move?
          jb        AIUp                ;we're below him -- move up
          ja        AIDown              ;we're above him -- move down
          je        AIHorz              ;we're there! -- don't move
AIUp:     add       word ptr ENEMY[VERT], ENEMYMOVE
          jmp       AIHorz
AIDown:   sub       word ptr ENEMY[VERT], ENEMYMOVE
          jmp       AIHorz
;
;         We want the enemy ship to stay around 70px away from out ship, so
;         we're going to calculate its position and then move our ship
;         accordingly...I figure it's fair to allow AI to move diagnolly
;         because it only moves once per cycle and we can move ~3 a cycle
;
;         MYSHIP[DIR] = -1 when going left (ie. enemy on the left side of scr)
;         MYSHIP[DIR] =  1 when going right (ie. enemy on right side of scr)
;
AIHorz:
          cmp       MYSHIP[DIR], 1      ;which way are we facing?
          je        AIHorzLeft          ;update left AI positions
;
;AIHorzRight: calculate AI when ENEMY ship is on the left
;
          mov       bx, ENEMY[X]
          add       bx, ENEMY[W]        ;get location of OUR ship
          add       bx, AIDISTANCE
          mov       ax, MYSHIP[X]
          cmp       ax, bx              ;which direction should we move?!
          ja        AIHorzMoveRight
          jna       AIHorzMoveLeft
AIHorzLeft:
          mov       bx, MYSHIP[X]
          add       bx, MYSHIP[W]       ;get location of OUR ship
          mov       ax, ENEMY[X]
          sub       ax, AIDISTANCE      ;stay around 100px away
          cmp       bx, ax              ;which direction should we move?!
          ja        AIHorzMoveRight
          jna       AIHorzMoveLeft
AIHorzMoveRight:
          add       word ptr ENEMY[HORZ], ENEMYMOVE
          jmp       AIMove
AIHorzMoveLeft:
          sub       word ptr ENEMY[HORZ], ENEMYMOVE
          jmp       AIMove
;
;Now, let's generate a new AI ship and place it randomly on the screen(rand Y)
;
AIGenerate:
          mov       ax, 100             ;0-100
          int       62h                 ;get a random number
          cmp       ax, AIGENFACTOR     ;generate a new ship?
          jb        AIDone
          lea       si, ENEMYDEF        ;enemy definition
          lea       di, ENEMY           ;the live enemy
          mov       cx, SHIPLEN
          rep       movsb               ;copy ENEMYDEF to ENEMY
;
;         and generate the Y position randomly
;
          mov       ax, 200-7           ;don't overlap the status bar on top
          int       62h
          add       ax, 7               ;move away from top bar
          mov       ENEMY[Y], ax        ;set the position 
          add       ax, BOPREYH         ;and test if position is off the scr
          cmp       ax, 200             ;does the new position go off screen?
          jb        AIMove              ;nope...still on the screen!
          mov       ax, 200             ;set bottom of screen
          sub       ax, BOPREYH         ;get the lowest position it can be
          mov       ENEMY[Y], ax        ;set the position 
AIMove:
          lea       bx, ENEMY           ;get enemy address
          call      updateObject        ;update its movement
;
AIDone:
          pop       si
          pop       di
          pop       cx
          pop       bx
          pop       ax
          ret
AI                  endp
;
;
;PROCEDRUE AIShoot
;
; This procedure is responsible for calculating when the AI should shoot
; its weapons.
;
; So as to make it more fair to the user, there is a rather large margin in
; which AI will choose to fire weapons (ie. it will miss a lot), otherwise, it
; would be impossible for the user to win.
;
; AISHOOTMARGIN defines the margin described above.
;
;  INPUT=(void)
; OUTPUT=(void) (shoots the weapons if deemed "good")
AIShoot             proc
          push      ax
          push      bx
          push      si
;
;         Make sure that the AI ship is still alive before we start moving...
;
          cmp       ENEMY[HULL], 0
          jl        AIShootDone
;
;         First, compare the X positions only
;
          mov       ax, ENEMY[Y]        ;get enemy's Y position
          sub       ax, MYSHIP[Y]       ;distance between the ships
          cmp       ax, AISHOOTMARGIN
          jbe       AIShootGood
          mov       ax, MYSHIP[Y]       ;get our Y position
          sub       ax, ENEMY[Y]        ;distance between the ships
          cmp       ax, AISHOOTMARGIN
          jbe       AIShootGood
;
;         Now, see if the bottom of the ship is in range
;
          mov       ax, ENEMY[Y]        ;get enemy's Y position
          add       ax, ENEMY[H]        ;enemy's height (bottom of ship)
          sub       ax, MYSHIP[Y]       ;distance between the ships
          cmp       ax, AISHOOTMARGIN
          jbe       AIShootGood
          mov       ax, MYSHIP[Y]       ;get our Y position
          sub       ax, ENEMY[Y]        ;distance between the ships
          sub       ax, ENEMY[H]
          cmp       ax, AISHOOTMARGIN
          jbe       AIShootGood
          jmp       AIShootDone
AIShootGood:          
          lea       bx, ENEMY
          lea       si, MYSHIP
          call      fire
AIShootDone:
;
          pop       si
          pop       bx
          pop       ax
          ret
AIShoot             endp
;
;
;PROCEDURE anomalies
;
; This procedure is responsible for handling everything with anomalies
; from generating them to removing them when they leave the screen to 
; moving them across the screen.
;
; ANOMALYGENFACTOR = the chances of an anomaly appearing in this round
;  if one is not already on the screen (100-ANOMALYGENFACTOR = chance)
;
;  INPUT=(void)
; OUTPUT=(void) (update anomalies)
anomalies           proc
          push      ax
          push      cx
;
          cmp       ANOMALY[HULL], 0    ;is there currently an anomaly on scr?
          jg        anomaliesMove       ;move it left if there is one
          jmp       anomaliesGenerate
anomaliesMove:
          mov       cx, ANOMALY[X]      ;get current position of anomaly
          mov       ax, cx
          cmp       ANOMALY[DIR], 0     ;which way are we moving?
          jg        anomaliesMoveRight
          sub       cx, MYMOVE          ;can we still move it left?
          jc        anomaliesRemove     ;it would move off the screen...
          sub       ANOMALY[HORZ], MYMOVE ;else, just move it (LEFT)
          jmp       anomaliesDone
anomaliesMoveRight:
          add       ax, MYMOVE          ;make sure it's not leaving the screen
          add       ax, ANOMALY[W]
          cmp       ax, 320
          ja        anomaliesRemove
          add       ANOMALY[HORZ], MYMOVE ;move it RIGHT
          jmp       anomaliesDone
anomaliesRemove:
          mov       ANOMALY[HULL], -1
          jmp       anomaliesDone
anomaliesGenerate:
;
;         here, let's see if we want to generate an anomaly for this round
;
          mov       ax, 100
          int       62h
          cmp       ax, ANOMALYGENFACTOR
          ja        anomaliesGenerateGo ;if we are generating one...start!
          jmp       anomaliesDone
;
;         otherwise...let's init this anomaly
;         I'm not proud of the following code...but it gets the job done... :(
;
anomaliesGenerateGo:
          mov       ANOMALY[HULL], 1    ;activate the anomaly
          mov       ax, 3               ;randomize selection
          int       62h
          cmp       ax, 1
          je        anomalyJunk
          cmp       ax, 2
          je        anomalyAsteroid
;
;anomalyWormhole: not actually used, just what this amounts to if ax=0
;
          mov       ANOMALY[X], 320-WORMHOLEW     ;set X position
          mov       ANOMALY[W], WORMHOLEW         ;set height
          mov       ANOMALY[H], WORMHOLEH         ;set width
          lea       ax, WORMHOLE
          mov       ANOMALY[PNT], ax              ;set image data
          jmp       anomaliesCheckDir
anomalyJunk:
          mov       ANOMALY[X], 320-JUNKW         ;set X pos
          mov       ANOMALY[W], JUNKW             ;set height
          mov       ANOMALY[H], JUNKH             ;set width
          lea       ax, JUNK
          mov       ANOMALY[PNT], ax              ;set image data
          jmp       anomaliesCheckDir
anomalyAsteroid:
          mov       ANOMALY[X], 320-ASTEROIDW     ;set X pos
          mov       ANOMALY[W], ASTEROIDW         ;set width
          mov       ANOMALY[H], ASTEROIDH         ;set height
          lea       ax, ASTEROID
          mov       ANOMALY[PNT], ax              ;set image data
          jmp       anomaliesCheckDir
;
;         Let's make sure that the anomaly isn't starting on the left side and
;         moving right
;
anomaliesCheckDir:
          cmp       ANOMALY[DIR], 0     ;which side is it on?
          jl        anomaliesSetVert
          mov       ANOMALY[X], 0
;
;         Set the vertical position of the anomaly
;
anomaliesSetVert:
          mov       ax, 200-7           ;don't overlap the status bar on top
          int       62h
          add       ax, 7
          mov       ANOMALY[Y], ax      ;set the position 
          add       ax, ANOMALY[H]      ;and test if position is off the scr
          cmp       ax, 200             ;does the new position go off screen?
          jb        anomaliesDone       ;nope...still on the screen!
          mov       ax, 200             ;set bottom of screen
          sub       ax, ANOMALY[H]      ;get the lowest position it can be
          mov       ANOMALY[Y], ax      ;set the position 
;
;...and we're done!
;
anomaliesDone:
          pop       cx
          pop       ax
          ret
anomalies           endp
;
;
;PROCEDURE collide
;
; This tests if any of the ships have colliden (new word, thank you)
; with any of the other objects, thus killing them.
;
;  INPUT=(void)
; OUTPUT=(void)
collide             proc
          push      bx
          push      di
;
;         Let's begin this by testing if our ship has hit anything
;
          lea       di, MYSHIP          ;get our ship's data
          lea       bx, ENEMY           ;get enemy ship data
          call      collideTest         ;see if they collided
          jnc       collideMyAnam       ;they didn't...test anamoly + our ship
          call      killMYSHIP
          call      killENEMY
collideMYAnam:
          lea       bx, ANOMALY
          call      collideTest         ;did we collide with an anamoly?
          jnc       collideEnAnam       ;see if the enemy hit an anamoly
          call      killMYSHIP
collideEnAnam:
          lea       di, ENEMY
          call      collideTest         ;did enemy collide with an anamoly?
          jnc       collideDone
          call      killENEMY
;
collideDone:
          pop       di
          pop       bx
          ret
collide             endp
;
;
;PROCEDURE collideTest
;
; This guy tests if two objects have collided with each other
; when given the two objects.
;
; It works by taking the x position of the first object and comparing
; it to the x position of the second object; if it is greater, then it
; compares to the x+w of the second object; if it is less, then we check
; if it in vertical range by the same method. If the first x was less, then
; we add its width to it and repeat the above test.
;
; This is written all out rather than using loops because a loop would be far
; too complicated -- having to figure out when to update which X and which Y
; would require far too many calculations, and linearly is far simpler.
;
;  INPUT=di-object 1
;        bx-object 2
; OUTPUT=CARRY FLAG = set if collide, not set otherwise
collideTest         proc
          push      ax
          push      cx
          push      dx
          push      si
;
;         first, make sure we have something to collide with...
;
          cmp       word ptr [bx+HULL], 0
          jl        collideTestFail     ;can't collide with a dead object
          cmp       word ptr [di+HULL], 0
          jl        collideTestFail     ;a dead object can't collide
;
;         some variables for quicker access as we move on
;
          mov       ax, [di+X]          ;x position of obj1
          mov       si, [bx+X]          ;x position of obj2
;
;         start the calculations / comparisons
;
          mov       cx, ax              ;x pos of object 1
          mov       dx, si              ;x pos of object 2
          cmp       cx, dx              ;is obj1 too far left of obj2?
          jl        collideTestX2
          add       dx, [bx+W]          ;see if obj1 still in range of obj2
          cmp       cx, dx              ;still in range?
          jg        collideTestX2       ;it's not in range of the right X
;
;         if we get here, then it must be in range of the second object
;
          jmp       collideTestY
;
;Here is where we test the X+W of the first object with colliding with the
;second one
;
collideTestX2:
          mov       cx, ax              ;x pos of object 1
          add       cx, [di+W]
          mov       dx, si              ;x pos of object 2
          cmp       cx, dx              ;is obj1 too far left of obj2?
          jl        collideTestFail
          add       dx, [bx+W]          ;see if obj1 still in range of obj2
          cmp       cx, dx              ;still in range?
          jg        collideTestFail     ;it's not in range of the right X
;
;         if we get here, then it must be in range of the second object
;
          jmp       collideTestY
;
;Let's test the Y positions to see if there is a collision
;
collideTestY:
;
;         again, some variables for quicker access
;
          mov       ax, [di+Y]          ;y position of obj1
          mov       si, [bx+Y]          ;y position of obj2
;
          mov       cx, ax              ;y pos of object 1
          mov       dx, si              ;y pos of object 2
          cmp       cx, dx              ;is obj1 too far above obj2?
          jl        collideTestY2
          add       dx, [bx+H]          ;see if obj1 still in range of obj2
          cmp       cx, dx              ;still in range?
          jg        collideTestY2       ;it's not in range of the bottom Y
;
;         if we get here, then it must be in range of the second object
;
          stc
          jmp       collideTestDone
;
;Let's test the Y+H position of the first object
;
collideTestY2:
          mov       cx, ax              ;y pos of object 1
          add       cx, [di+H]          ;Y2 position of obj1
          mov       dx, si              ;y pos of object 2
          cmp       cx, dx              ;is obj1 too far above obj2?
          jl        collideTestFail
          add       dx, [bx+H]          ;see if obj1 still in range of obj2
          cmp       cx, dx              ;still in range?
          jg        collideTestFail     ;it's not in range of the bottom Y
;
;         if we get here, then it must be in range of the second object
;
          stc
          jmp       collideTestDone
collideTestFail:
          clc                           ;set the carry to fail
collideTestDone:
          pop       si
          pop       dx
          pop       cx
          pop       ax
          ret
collideTest         endp
;
;
;PROCEDURE damage
;
; This procedure deals out damage to the specified ship and takes care
; of clearing the ship if it is dead.
;
;  INPUT=si-pointer to ship
; OUTPUT=void (updated damage to ship)
damage              proc
          push      ax
          push      bx
;
;         first, let's find out if the ship has shields
;
          cmp       word ptr [si+SHLDS], 0 ;does it have any shields?
          jng       damageHull
;
;         we don't care if it carries -- if the shields die, the damage
;         should not chain to the hull
;
          sub       word ptr [si+SHLDS], PHASERDAMAGE
          jmp       damageDone
damageHull:                             ;do some damage to the opponent
          sub       word ptr [si+HULL], PHASERDAMAGE
          jnc       damageDone
;
;         the enemy ship died...do something!
;
          lea       ax, MYSHIP          ;find where our ship lives
          cmp       ax, si              ;did our ship die?
          jne       damageEnemyDead
          call      killMYSHIP
          jmp       damageDone
damageEnemyDead:
          call      killENEMY
damageDone:
          pop       bx
          pop       ax
          ret
damage              endp
;
;
;PROCEDURE fire
;
; This guy fires the user's weapon exactly where it is at the moment.
;
;  INPUT=bx-pointer to ship firing
;        si-pointer to other ship
; OUTPUT=(void)
fire                proc
          push      ax
          push      bx
          push      cx
          push      dx
          push      di
          push      si
          push      es
;
;         To begin this, let's make sure that the user has enough power to
;         fire weapons, if not, then just exit this function.
;
          cmp       word ptr [bx+PHSR], PHASERENERGY
          jae       fireStart
          jmp       fireDone
;
;         if there is enough power to fire, start shooting!
;
fireStart:
          mov       di, 0a000h          ;set video memory
          mov       es, di
;
;         Find the location of the ship (all weapons are fired from the bottom
;         of the ship directly across the screen).
;
;         The location of the ship is used when firing both left and right, so
;         we place it here for ease of use
;
          mov       di, [bx+Y]          ;start of area through which to fire
          add       di, [bx+H]          ;fire from bottom of ship
          sub       di, 4               ;don't fire below ship, just bottom!
          mov       ax, di              ;save pos for later use
          call      getLocation
;
          mov       dx, 0               ;offset as described above
          mov       cx, [si+Y]          ;enemy position
;
;         now, let's see which direction we should be firing the beam
;         for some reason, a JG doesn't work when comparing with a 0
;         here...who knows why...but a compare with 1 works just fine
;
          cmp       word ptr [bx+DIR], 1;which way are we facing?
          je        fireRight           ;facing right
          jmp       fireLeft            ;facing left
;
;         This series of instructions determines where the beam should be
;         placed when the ship is facing right
;
fireRight:
;
;         set the offset X of the ship on the right
;
          add       di, [bx+X]
          add       di, [bx+W]          ;don't fire through the ship
;
;         Let's see if we hit the enemy ship -- if we did, then let's take
;         some of his armor away
;
;         -we're going to use AX to compare -- set from position above
;         -use DX to hold the offset of the enemy ship so that if we do hit it
;          we don't keep the phaser going after the ship ends (ie. so that it
;          stops at the ship) -- for this, let's set the offset = 0 (ie.
;          first assume we haven't hit the ship, if we do, then change offset)
;
          cmp       word ptr [si+HULL], 0 ;see if the ship exists
          jnge      fireRightNoHit      ;the ship is dead...
          cmp       ax, cx              ;see if shot over top
          jb        fireRightNoHit
          add       cx, [si+H]          ;see if we are in the range
          cmp       ax, cx              ;did we shoot below the enemy?
          ja        fireRightNoHit
;
;         let's check to make sure we're on the right side of the enemy
;
          mov       ax, [bx+X]
          cmp       ax, [si+X]          ;is the enemy to our right?
          ja        fireRightNoHit
;
;         if we get here, we must have hit the enemy, so take away some armor!
;
          mov       dx, 320             ;enemy X is from the right of screen
          sub       dx, [si+X]          ;update our offset holder
          call      damage
fireRightNoHit:
          mov       cx, 320
          sub       cx, [bx+W]          ;the length of the beam
          sub       cx, [bx+X]
          sub       cx, dx              ;offset of enemy ship
          jnc       fireDraw            ;if ships aren't on top of eachother
          mov       cx, 2               ;draw at least a tiny beam for user
          jmp       fireDraw
;
fireLeft:
;
;         we do not set an offset here as we are firing left, so we should
;         start at 0 rather than the offset of the ship
;
          mov       dx, 0
          cmp       word ptr [si+HULL], 0 ;see if the ship exists
          jnge      fireLeftNoHit       ;the ship is dead...
          cmp       ax, cx              ;see if shot over top
          jb        fireLeftNoHit
          add       cx, [si+H]          ;see if we are in the range
          cmp       ax, cx              ;did we shoot below the enemy?
          ja        fireLeftNoHit
;
;         let's check to make sure we're on the left side of the enemy
;
          mov       ax, [bx+X]
          cmp       ax, [si+X]          ;is the enemy to our right?
          jb        fireLeftNoHit
;
;         If we get here, we must have hit the enemy, so take away some armor!
;         Also, set our offset to the position / width of the ship so that the
;         beam does not go right through him.
;
          mov       dx, [si+W]          ;the length of the beam
          add       dx, [si+X]
          call      damage
fireLeftNoHit:
          add       di, dx              ;move the drawing pos past the ship
          mov       cx, [bx+X]
          sub       cx, dx              ;make the beam not go through the ship
          jnc       fireDraw            ;if ships aren't on top of eachother
          mov       cx, 2               ;draw at least a tiny beam for user
fireDraw:
          mov       al, 46              ;yellow for phasers! weee!
          rep       stosb               ;write to screen
;
;         Each phaser shot takes 10 away from the phaser power, so let's
;         update the stats to reflect that
;
          sub       word ptr [bx+PHSR], PHASERENERGY
fireDone:
;
          pop       es
          pop       si
          pop       di
          pop       dx
          pop       cx
          pop       bx
          pop       ax
          ret
fire                endp
;
;
;PROCEDURE fireSuperWeapon
;
; This will see if the user's super weapon (read: Photonic Cannon) is
; charged and ready to fire, and if it is, then it fires it...
;
; This super weapon simply destroys everything on the screen with a fast burst
; of light...why light destroys, I don't know...it was just funny.
;
; This does not, however, destroy the user.
;
;  INPUT=(void)
; OUTPUT=(void)
fireSuperWeapon     proc
          push      ax
          push      cx
          push      di
          push      es
;
          cmp       MYSHIP[SPRW], 100   ;is the weapon ready to fire?
          jne       fireSuperWeaponDone
;
;         Since we can fire the weapon, we need to reset it
;
          mov       MYSHIP[SPRW], 0     ;no more fire power...
;
          mov       di, 0a000h          ;video memory
          mov       es, di
;
;         Let's do the actual firing and destroying...
;
          mov       di, 0               ;start of screen
          mov       al, 255             ;white...for the photonic flash
          mov       cx, 320*200         ;for the entire screen
          rep       stosb               ;white it out
;
;         Now that the screen is white, remove any enemies and anomalies
;         -Note -- not calling killENEMY here as that creates an explosion
;          that makes the effect look really bad
;
          mov       ANOMALY[HULL], -1
          cmp       ENEMY[HULL], 0
          jnge      fireSuperWeaponDone
          mov       ENEMY[HULL], -1     ;don't show an explosion...
          dec       shipsLeft           ;dec number of ships left to kill
;
fireSuperWeaponDone:
          pop       es
          pop       di
          pop       cx
          pop       ax
          ret
fireSuperWeapon     endp
;
;
;PROCEDURE getDifficulty
;
; Reads the difficulty level from file and returns it back to the
; caller.
;
;  INPUT=(void)
; OUTPUT=bx - the difficulty level
getDifficulty       proc
          push      dx
;
          lea       dx, SETTINGS        ;get the file location
          call      loadFile            ;load the file
;
          mov       cx, 1               ;read the first character -- the level
          mov       ah, 3fh             ;set the function call
          lea       dx, palBuff         ;piggy-back on some free memory...
          int       21h                 ;read the level into the buffer
;
          call      closeFile           ;we're done reading
;
          mov       bh, 0
          mov       bl, palBuff[0]      ;first byte of buffer...our level
          sub       bl, '0'             ;deasciify our ouput
;
          pop       dx
          ret
getDifficulty       endp
;
;
;PROCEDURE getDiffInfo
;
; Given the difficulty level, it returns the location of the box that
; will need to be blacked out / filled in.
;
; It will also return the number of ships that are to be displayed at this
; level before the user wins.
;
; Note that we don't have to do any error checking as an invalid input
; in the difficulty selection screen would not allow it to continue
; any further, so we can be sure that our input is valid.
;
;  INPUT=bx - level (a # 1-4)
; OUTPUT=bx=X pos
;        dx=Y pos
;        al=# of ships to kill
getDiffInfo         proc
;
          cmp       bx, 1               ;difficulty of 1 set?
          jne       getDiffTest2
          mov       bx, DIFFX1
          mov       dx, DIFFY1
          mov       al, DIFF1Ships
          jmp       getDiffTestDone
getDiffTest2:
          cmp       bx, 2               ;difficulty of 1 set?
          jne       getDiffTest3
          mov       bx, DIFFX2
          mov       dx, DIFFY2
          mov       al, DIFF2Ships
          jmp       getDiffTestDone
getDiffTest3:
          cmp       bx, 3               ;difficulty of 1 set?
          jne       getDiffTest4
          mov       bx, DIFFX3
          mov       dx, DIFFY3
          mov       al, DIFF3Ships
          jmp       getDiffTestDone
getDiffTest4:                           ;last choice...must be this one
          mov       bx, DIFFX4
          mov       dx, DIFFY4
          mov       al, DIFF4Ships
getDiffTestDone:
;
          ret
getDiffInfo         endp
;
;
;PROCEDURE getLocation
;
; This returns the location of an object on the screen when
; given the Y coordinate of the object (basically, it multiplies
; it by 320).
;
;  INPUT=di-location
; OUTPUT=di-location in video memory
getLocation         proc
          push      ax
          push      cx
;
          mov       ax, di
          mov       cl, 6
          shl       di, cl
          mov       cl, 8
          shl       ax, cl              ;DI*320 (the two shl's above)
          add       di, ax
;
          pop       cx
          pop       ax
          ret
getLocation         endp
;
;
;PROCEDURE honorTheDead
;
; I couldn't think of a better name... This function makes the ship explode
; (really, it only draws an explosion at the last known position of the ship)
;
;  INPUT=bx-pointer to object
; OUTPUT=(void) (explosion at location)
honorTheDead        proc
          push      ax
          push      cx
          push      di
          push      si
          push      es
;
          mov       di, 0a000h          ;set video memory
          mov       es, di
;
          mov       di, [bx+Y]          ;get Y position of ship
          call      getLocation         ;get the location on the screen
          add       di, [bx+X]          ;offset its X position
          mov       si, di              ;save the position for later
;
;         Let's black out the ship that is currently there and replace it with
;         an explosion :)
;
          mov       cx, [bx+H]          ;get height of ship
          mov       al, 0               ;black for the color
htdBlank:
          push      cx
          mov       cx, [bx+W]          ;width of current object
          rep       stosb               ;blank it all...fast!
          pop       cx
          add       di, 320             ;go to the next line (320-width)
          sub       di, [bx+W]          ;the width of the image
          loop      htdBlank
;
          mov       cx, EXPLOSIONH
          mov       di, si
          lea       si, EXPLOSION
htdExplode:
          push      cx
          mov       cx, EXPLOSIONW      ;width of object
          rep       movsb 
          pop       cx
          add       di, 320-EXPLOSIONW  ;go to the next line (320-width)
          loop      htdExplode
;
          pop       es
          pop       si
          pop       di
          pop       cx
          pop       ax
          ret
honorTheDead        endp
;
;
;PROCEDURE killENEMY
;
; Simply, this one kills the enemy ship;
;
; To Kill:
;   -ENEMY[HULL] < 0
;   -shipsLeft--
;
;  INPUT=(void)
; OUTPUT=(void)
killENEMY           proc
          push      bx
;
          mov       ENEMY[HULL], -1     ;kill the enemy ship
          dec       shipsLeft           ;remove a ship from the count
          lea       bx, ENEMY
          call      honorTheDead        ;make a pretty explosion
;
          pop       bx
          ret
killENEMY           endp
;
;
;PROCEDURE killMYSHIP
;
; This simply contains a set of actions needed in order to kill
; our ship.
;
; To Kill:
;   -shipsLeft = 0
;   -dead > 0
;   -MYSHIP[HULL] < 0
;
;  INPUT=(void)
; OUTPUT=(void)
killMYSHIP          proc
          push      bx
;         
          mov       dead, 1             ;kill our ship
          mov       shipsLeft, 0        ;set to exit loop  
          mov       MYSHIP[HULL], -1    ;destroy the hull
          lea       bx, MYSHIP
          call      honorTheDead
;
          pop       bx
          ret
killMYSHIP          endp
;
;
;PROCEDURE loadLevel
;
; This function loads the necessary ships and etc from an image file
; and sets up the level for the user to begin playing.
loadLevel           proc
          push      di
          push      dx
          push      ax
          push      es
;
;         let's cache our necessary files
;         Bird of Prey -- the Enemy
;
          lea       dx, IMGBOPREY
          lea       di, BOPREY
          add       di, BOPREYW*BOPREYH-BOPREYW
          call      cacheImage
;
;         Wardbird -- US
;
          lea       dx, IMGWRBIRD
          lea       di, WRBIRD
          add       di, WRBIRDW*WRBIRDH-WRBIRDW
          call      cacheImage
;
;         Shuttle -- Wesley
;
          lea       dx, IMGSHUTTLE
          lea       di, SHUTTLE
          add       di, SHUTTLEW*SHUTTLEH-SHUTTLEW
          call      cacheImage
;
;         Explosion -- for fun!
;
          lea       dx, IMGEXPLOSION
          lea       di, EXPLOSION
          add       di, EXPLOSIONW*EXPLOSIONH-EXPLOSIONW
          call      cacheImage
;
;         An asteroid...for space junk!
;
          lea       dx, IMGASTEROID
          lea       di, ASTEROID
          add       di, ASTEROIDW*ASTEROIDH-ASTEROIDW
          call      cacheImage
;
;         A wormhole...for more space junk!
;
          lea       dx, IMGWORMHOLE
          lea       di, WORMHOLE
          add       di, WORMHOLEW*WORMHOLEH-WORMHOLEW
          call      cacheImage
;
;         Space junk...for space junk?...
;
          lea       dx, IMGJUNK
          lea       di, JUNK
          add       di, JUNKW*JUNKH-JUNKW
          call      cacheImage
;
;         The space station...for rescuing Wesley
;
          lea       dx, IMGSTATION
          lea       di, STATION
          add       di, STATIONW*STATIONH-STATIONW
          call      cacheImage
;
;         Let's get us some random numbers for a random star field
;
          mov       di, STARCOUNT
loadLevelStars:
          mov       ax, 320*200         ;=64000, the # of pixels on the screen
          int       62h
          mov       STARFIELD[di], ax
          sub       di, 2
          jnc       loadLevelStars
;
          pop       es
          pop       ax
          pop       dx
          pop       di
          ret
loadLevel           endp
;
;
;PROCEDURE nextNote
;
; Given the background music defined above, this will determine which note in
; the sequence it should be playing at a give time. It updates itself nicely 
; and uses what it sets to determine which note in the bg sequence it should
; be playing. 
;
;  INPUT=(void)
; OUTPUT=ax=frequency
;        dx=duration
nextNote            proc
          push      si
;
          lea       si, BGMUSIC         ;get the background music
          add       si, BGMUSPOS        ;get the note that is being played
;
          cmp       BGMUSCNT, 0         ;is the interval for this note done?
          ja        nextNoteSameNote
          add       si, 2               ;next note
          add       BGMUSPOS, 4         ;update our holder, too
          lodsw                         ;load the next duration
          cmp       ax, 0               ;duration of 0?
          ja        nextNoteNoRestart
          mov       BGMUSPOS, 2
          lea       si, BGMUSIC         ;reset our music position
          lodsw
nextNoteNoRestart:
          mov       BGMUSCNT, ax        ;save the duration
nextNoteSameNote:
          sub       BGMUSCNT, 5         ;take away 1 duration
          lodsw                         ;get the frequency
          mov       dx, 5               ;delay of 0.1 sec is reasonable
;
          pop       si
          ret
nextNote            endp
;
;
;
;PROCEDURE play
;
; This is where the fun happens...this loop just goes on until the player
; dies, wins, or whatever...
;
; This procedure listens for the keyboard, moves around the alien ships,
; deteremines whether or not an anomaly should come, controls the direction
; of the stars, and the like (don't worry, these are done through function
; calls and are not coded directly into this function).
;
;  INPUT=(void)
; OUTPUT=(void)
play                proc
          push      ax
          push      bx
          push      dx
          push      di
;
          call      reset               ;get ready for this round
playLp:
          cmp       bx, 2
          jna       playLpNoUpdate
          sub       bx, bx
          call      AI                  ;move the enemy ship around
          call      anomalies
          call      updateAIStats
          call      wipeScreen          ;make the screen all black
          call      updateStarField
          call      updateStats         ;update the ship info
;
;         we update positions here as we need a new position after the AI
;         moves the ship in order to determine if shoot would be advisable
;         and to make sure the beam is placed with the ship
;
          call      updateObjects       ;update positions of ALL objects
          call      collide             ;check if things hit each other
          call      AIShoot
playLpNoUpdate:
          call      nextNote
          call      prepNote            ;get a delay ready 
playLpWait: 
          call      rctr                ;read initial count
playLpWaitLp: 
          call      userAction          ;see if the user wants to do something
          mov       dx, ax              ;save previous count
          call      rctr                ;read count again
          cmp       ax, dx              ;compare new count with old count
          jb        playLpWaitLp        ;loop if new count is lower
          loop      playLpWait          ;else reset + count down cycles
          call      noteDone
          inc       bx
          cmp       shipsLeft, 0
          jg        playLp
;
;         See if the user is dead
;
          cmp       dead, 0             ;see if set...uh-oh!
          je        playNext
          lea       dx, IMGFAILURE
          call      bmpToScreen
          jmp       playDone
;
;If we get here, the user has successfully destroyed the number of ships 
;required to get to the space station, so let's play the animation for
;retrieving the shuttle, but before we do that, we are going to need to
;reverse all of our images that we use, and we are going to need to set the
;direction that the ship is going.
;
;Here, too, we also see if the user has already rescued the shuttle (ie. he
;should be facing away from the space station now), so if he is, we assume
;that he has won, and we call the appropriate procedures.
;
playNext:
          cmp       MYSHIP[DIR], 1                ;see if has already won
          jne       playSuccess                   ;he has!
          call      reverseEverything             ;reverse the images in place
          call      shuttleToShip                 ;play the animation
          mov       al, shipsLeftDef              ;reset # of ships to kill
          mov       shipsLeft, al                 ;and reset...
          jmp       playLp                        ;finish playing
playSuccess:
          lea       dx, IMGSUCCESS                ;get the success image
          call      bmpToScreen                   ;display it
;
playDone:
          pop       di
          pop       dx
          pop       bx
          pop       ax
          ret
play                endp
;
;
;PROCEDURE reset
;
; This guy resets all of the values for the game so that it can be played
; without having to be restarted.  It's just a bunch of assignments...
;
;  INPUT=(void)
; OUTPUT=(void) (reset gaming values)
reset               proc
          push      bx
          push      dx
          push      si
          push      di
;
;         reset key scaffold values
;
          mov       ENEMYDEF[DIR], -1   ;reset the default direction for these
          mov       ENEMYDEF[X], 320-BOPREYW ;reset the X position
          mov       ANOMALYDEF[DIR], -1 ;reset def dir, again
;
;         Now copy the scaffolds into the working-versions
;
          lea       si, MYSHIPDEF       ;copy definition of our ship
          lea       di, MYSHIP
          mov       cx, SHIPLEN
          rep       movsb
          lea       si, ENEMYDEF        ;copy definition for enemy ship
          lea       di, ENEMY
          mov       cx, SHIPLEN
          rep       movsb
          lea       si, ANOMALYDEF      ;copy definition for anamolies
          lea       di, ANOMALY
          mov       cx, 20
          rep       movsb
          lea       si, SPACESTDEF      ;copy definition for the space station
          lea       di, SPACEST
          mov       cx, 20
          rep       movsb
          lea       si, WESLEYDEF       ;copy definition for Wesley's Shuttle
          lea       di, WESLEY
          mov       cx, 20
          rep       movsb
;
;         Set the image pointers for the scaffolds
;
          lea       bx, WRBIRD
          mov       MYSHIPDEF[PNT], bx  ;set pointer for my ship
          lea       bx, BOPREY          
          mov       ENEMYDEF[PNT], bx   ;set pointer for enemy ships
          lea       bx, STATION          
          mov       SPACESTDEF[PNT], bx ;set pointer for the space station
          lea       bx, SHUTTLE          
          mov       WESLEY[PNT], bx     ;set pointer for the shuttle
;
;         Grab values from the difficulty settings
;
          call      getDifficulty       ;get the level
          call      getDiffInfo         ;get the info for that level
          mov       shipsLeftDef, al    ;set the default # of ships
;
;         Now update the playing variables (ships left, etc)
;
          mov       bl, shipsLeftDef
          mov       shipsLeft, bl       ;reset # of ships to kill
          mov       bl, deadDef
          mov       dead, bl            ;reset dead tester
;
;         Reset the music variables
;
          mov       dx, BGMUSPOSDEF
          mov       BGMUSPOS, dx        ;reset the position
          mov       dx, BGMUSCNTDEF
          mov       BGMUSCNT, bx        ;reset the intervals
;
          pop       di
          pop       si
          pop       dx
          pop       bx
          ret
reset               endp
;
;
;PROCEDURE reverse
;
; Given an image data segment and the length/width of the image,
; it reverses the image for us...isn't that nice of it?!
;
;  INPUT=di-data pointer
;        cx-height
;        bx-width
; OUTPUT=(void) (reversed image)
reverse             proc
          push      ax
          push      bx
          push      cx
          push      dx
          push      di
          push      si
;
          mov       si, di              ;get our end pointer ready
          sub       cx, 1               ;don't go past image boundary
          mov       dx, bx              ;save actual width
          shr       bx, 1               ;divide it by 2
          sub       di, bx
reverseHLp:
          add       di, bx              ;move to next line
          mov       si, di              ;mov si up, too
          add       si, dx              ;go to end of line
reverseWLp:
          mov       al, [di]            ;save DI for reversing
          mov       ah, [si]            ;save SI for reversing
          mov       [di], ah            ;reverse!
          mov       [si], al            ;reverse!
          dec       si
          inc       di
          cmp       si, di              ;have the counters passed each other?
          jg        reverseWLp
;
          sub       cx, 1               ;dec height of object
          jnz       reverseHLp          ;still anything to reverse?
;
          pop       si
          pop       di
          pop       dx
          pop       cx
          pop       bx
          pop       ax
          ret
reverse             endp
;
;
;PROCEDURE reverseEverything
;
; This guy takes the important elements and reverses them
;
;  Namely, it reverses the graphic image for the ships and changes
;  the default direction for anamolies.
;
;  INPUT=(void)
; OUTPUT=(void)
reverseEverything   proc
          push      bx
          push      cx
          push      di
;
          lea       di, WRBIRD          ;get our ship
          mov       cx, WRBIRDH
          mov       bx, WRBIRDW
          call      reverse             ;reverse it!
          lea       di, BOPREY          ;get the enemy ship
          mov       cx, BOPREYH
          mov       bx, BOPREYW
          call      reverse             ;reverse it!
;
;         Now change the direction of the objects on the screen
;
          mov       MYSHIP[DIR], -1     ;we're going the other way now
          mov       ENEMY[DIR], 1       ;it's going the other way now
          mov       ENEMYDEF[DIR], 1    ;come at us from the other side now
          mov       ENEMYDEF[X], 0      ;come at us from the other side now
          mov       ANOMALYDEF[DIR], 1  ;they should come from the other side
          mov       ANOMALY[DIR], 1
;
          pop       di
          pop       cx
          pop       bx
          ret
reverseEverything   endp
;
;
;PROCEDURE setDifficulty
;
; This will take the user input, highlight the appropriate place 
; on the screen for the selection, and then write the info to a
; file for saving for when the user next loads the game.
;
;  INPUT=ax - the return of getKey
; OUTPUT=(void) (screen updated and preferences updated)
setDifficulty       proc
          push      ax
          push      bx
          push      cx
          push      dx
          push      di
          push      si
          push      es
;
;         Save the user input for drawing
;
          push      ax
;
          call      getDifficulty
          call      getDiffInfo         ;bx = X and dx = Y; al=# of ships
;
;         Let's go ahead and reset the # of ships required to win
;
          mov       shipsLeftDef, al
;
          mov       di, 0a000h          ;video memory
          mov       es, di
;
;         Let's start by blacking out all the old settings areas
;
          mov       al, 0               ;the color black
          mov       ah, 7               ;the number of pixels to draw vert.
          mov       di, dx              ;set Y position
          call      getLocation         ;get position on screen
          add       di, bx              ;offset with X position
setDiffClear:
          mov       cx, 7               ;number of pixels to draw horz.
          rep       stosb
          add       di, 320-7           ;offset next line
          sub       ah, 1               ;decrement counter
          jnz       setDiffClear
;
;         Get the user input and draw
;
          pop       ax                  
          push      ax                  ;restore the user input (AX)
          sub       al, '0'             ;deasciify the input
          mov       ah, 0               ;clear out the register
          mov       bx, ax              ;get input for locaton
          call      getDiffInfo
          mov       al, 250             ;the color green
          mov       ah, 7               ;the number of pixels to draw vert.
          mov       di, dx              ;set Y position
          call      getLocation         ;get position on screen
          add       di, bx              ;offset with X position
setDiffDraw:
          mov       cx, 7               ;number of pixels to draw horz.
          rep       stosb
          add       di, 320-7           ;offset next line
          sub       ah, 1               ;decrement counter
          jnz       setDiffDraw
;
;         And now, let's write the new difficulty level to the file
;         Since we need to write the file, we can't simply call
;         loadFile...we must just write it out here.
;
          pop       ax                  ;restore the user input
          mov       palBuff[0], al      ;piggyback free memory
;
;         my version of an inline function...meh, w/e
;
          lea       dx, SETTINGS        ;get the file location
          mov       ah, 3dh             ;file reading command
          mov       al, 1               ;open file for writing
          int       21h
          mov       bx, ax              ;save file handle
;
;         now write the data
;
          mov       ah, 40h             ;set write function
          lea       dx, palBuff         ;set position for info
          mov       cx, 1               ;set number of bytes to read
          int       21h
;
;         now close the file and be done with it!
;
          call      closeFile
;
          pop       es
          pop       si
          pop       di
          pop       dx
          pop       cx
          pop       bx
          pop       ax
          ret
setDifficulty       endp
;
;
;PROCEDURE shuttleToShip
;
; Basically, this will take the ship, place it in a good location, fade
; in the space station, fly the shuttle from it, and return you to the game.
;
;  INPUT=(void)
; OUTPUT=(void)
shuttleToShip       proc
          push      ax
          push      bx
          push      cx
          push      dx
          push      si
;
;         Reverse the direction of the star field just for this function --
;         still included in reverseAll because that is the logical place for
;         it, rather than here, but we need it changed for this function only
;
          mov       MYSHIP[DIR], 1
;
;         Hide extraneous objects
;
          mov       ANOMALY[HULL], -1
          mov       ENEMY[HULL], -1
;
;         Make the Space Station and Shuttle Appear
;
          mov       SPACEST[HULL], 1
          mov       WESLEY[HULL], 1
;
;         To start off, let's move our ship into the proper position on screen
;
          mov       MYSHIP[X], 20                 ;set to screen
          mov       MYSHIP[Y], 200/2+WRBIRDH/2    ;align vertically
          mov       cx, 60
;
;         Let's animate the space station so it floats in
;         Let's move the shuttle to our ship
;
shtlToSpStation:
          push      cx
;
          cmp       si, 2
          jna       shtlToSpStationNoUpdate
          sub       si, si
          mov       SPACEST[HORZ], -2
          mov       WESLEY[HORZ], -11
          mov       WESLEY[VERT], -2
          call      wipeScreen          ;make the screen all black
          call      updateStarField
          call      updateObjects       ;update positions of ALL objects
          lea       bx, SPACEST
          call      updateObject        ;update the space station pos
          lea       bx, WESLEY
          call      updateObject        ;update Wesley's Shuttle
          call      updateStats         ;update the ship info
shtlToSpStationNoUpdate:
          call      nextNote
          call      prepNote            ;get a delay ready 
shtlToSpStationLpIn:
          call      rctr
shtlToSpStationLpInIn:
          mov       dx, ax              ;save previous count in dx
          call      rctr                ;read count again
          cmp       ax, dx              ;compare new count : old count
          jb        shtlToSpStationLpInIn ;loop if new count is lower
          loop      shtlToSpStationLpIn ;else reset, count down cycles
;
          call      noteDone
          inc       si
          pop       cx
          loop      shtlToSpStation
;
;         Now that our shuttle is in place, let's move the space station out
;         and dock the shuttle with our ship
;
;         Note that we are now moving in the opposite direction, so we need
;         to reverse our ship direction (as changed from above)
;
          mov       MYSHIP[DIR], -1
;
          mov       cx, 60
shtlToSpDock:
          push      cx
;
          cmp       si, 2
          jna       shtlToSpDockNoUpdate
          sub       si, si
          mov       SPACEST[HORZ], 2
          mov       WESLEY[HORZ], 8
          mov       WESLEY[VERT], -1
          mov       MYSHIP[HORZ], 8
          call      wipeScreen          ;make the screen all black
          call      updateStarField
          lea       bx, SPACEST
          call      updateObject        ;update the space station pos
          lea       bx, WESLEY
          call      updateObject        ;update Wesley's Shuttle
          call      updateObjects       ;update positions of ALL objects
          call      updateStats         ;update the ship info
shtlToSpDockNoUpdate:
          call      nextNote
          call      prepNote            ;get a delay ready
shtlToSpDockLpIn:
          call      rctr
shtlToSpDockLpInIn:
          mov       dx, ax              ;save previous count in dx
          call      rctr                ;read count again
          cmp       ax, dx              ;compare new count : old count
          jb        shtlToSpDockLpInIn  ;loop if new count is lower
          loop      shtlToSpDockLpIn    ;else reset, count down cycles
;
          call      noteDone
          inc       si
          pop       cx
          loop      shtlToSpDock
;
;         Once the above animations are complete, we know that Wesley is
;         docked to the ship, so let's resume the game and get them out of
;         there
;
;         Make the Space Station and Shuttle VANISH!
;
          mov       SPACEST[HULL], -1
          mov       WESLEY[HULL], -1
;
;         Because this game is already really hard...I'm giving the gift
;         of recharged shields and phasers just to help out
;
          mov       MYSHIP[SHLDS], 100
          mov       MYSHIP[PHSR], 100
;
;         Let's not just throw the user into the action...hold off for a while
;
          mov       ax, 0               ;zero frequency for rest
          mov       dx, 10              ;delay of 0.3 sec is reasonable
          call      prepNote            ;get a delay ready
shtlToSpWait:
          call      rctr
shtlToSpWaitLp:
          mov       dx, ax              ;save previous count in dx
          call      rctr                ;read count again
          cmp       ax, dx              ;compare new count : old count
          jb        shtlToSpWaitLp      ;loop if new count is lower
          loop      shtlToSpWait        ;else reset, count down cycles
;
          pop       si
          pop       dx
          pop       cx
          pop       bx
          pop       ax
          ret
shuttleToShip       endp
;
;
;PROCEDURE updateAIStats
;
; The AI, just like our ship, is going to need its phasers to be
; recharged at the same rate as ours, so let's do that here.
;
;  INPUT=(void)
; OUTPUT=(void) (updated phasers)
updateAIStats       proc
          push      ax
;
          mov       ax, ENEMY[PHSR]     ;update his phasers
          add       ax, PHASERREGEN
          cmp       ax, 100             ;is his charge > 100?
          jbe       upAIStatsDone
          mov       ax, 100             ;reset to 100
upAIStatsDone:
          mov       ENEMY[PHSR], ax     ;set the phaser charge
;
          pop       ax
          ret
updateAIStats       endp
;
;
;PROCEDURE updateObjects
;
; Updates all of the ships and such on the screen as necessary
;
; NOTE: This function is extremely inefficient and should only be
; called during an update round to update evertyhing -- if called
; after user action every time, the game become unplayable... (ie.
; it uses so many resources that it takes forever to count down the 
; number of clock cycles for the beat...)
;
;  INPUT=(void)
; OUTPUT=(void) (updated screen)
updateObjects       proc
          push      bx
;
          lea       bx, MYSHIP
          call      updateObject
          lea       bx, ENEMY
          call      updateObject
          lea       bx, ANOMALY
          call      updateObject
;
          pop       bx
          ret
updateObjects       endp
;
;
;PROCEDURE updateObject
;
; This is a generic routine to update the position of objects on the screen.
; The driver method, updateObjects, supplies it with what it needs to run...
; there was no point to redo this routine for every object as it can be
; written so generically as follows.
;
; BIG NOTE: the top of the screen is defined as at 7px so that the stats bar
; can be displayed without any problems.
;
;  INPUT=bx-pointer to object values
; OUTPUT=updated screen (void)
updateObject        proc
          push      ax
          push      bx
          push      cx
          push      dx
          push      es
          push      si
          push      di
;
;         Make sure that the obj exists before we start drawing it willy-nilly
;
          cmp       word ptr [bx+HULL], 0
          jge       upObjStart          ;if exists, then draw it out
          jmp       updateObjectsDone   ;else, just quit
;
;         set the video memory location
;
upObjStart:
          mov       cx, 0a000h          ;video memory location
          mov       es, cx
;
;To start off this beauty, let's update the position of our ship
;
; After we validate the movement, we will save the new X and Y so as not to 
; cause the screen to flicker as we black out and redraw the obj (doing the
; calcs after we black out would cause a flicker problem).
;  Save locations are as follows:
;   ax-used for coloring; bx-ship pointer; cx-counter; dx-unused; di-counter;
;   si-unused
;
;   si - X Pos
;   dx - Y Pos
;   
          mov       cx, [bx+VERT]
          add       cx, [bx+HORZ]
          jc        updateObjectsVert   ;something changed...move the obj!
          cmp       cx, 0               ;did the ship move?
          jne       updateObjectsVert   ;then calculate the moves
          jmp       updateObjectsNoMove ;the ship didn't move
updateObjectsVert:
          mov       dx, [bx+VERT]       ;get movement of ship
          mov       cx, [bx+H]          ;save height of ship for use
          cmp       dx, 0               ;did they move vertically?
          je        updateObjectsVertNoMove ;no move
          add       dx, [bx+Y]          ;add our Y location
          add       dx, cx              ;add our HEIGHT
          cmp       dx, 200             ;past the bottom of the screen?
          jng       updateObjectsTop
          mov       dx, 200             ;the absolute bottom of the screen
          sub       dx, cx              ;height of the ship
          mov       cx, 0               ;remove any padding (for the "de-pad")
          jmp       updateObjectsVertDone
updateObjectsTop:
          sub       dx, cx              ;height of ship
          mov       cx, [bx+PAD]        ;padding for object
          sub       dx, cx              ;sub padding
          cmp       dx, 7               ;past top of screen? (in stats bar?)
          jnl       updateObjectsVertDone
          mov       dx, 7
updateObjectsVertDone:
          add       dx, cx              ;de-pad position from addition above
          jmp       updateObjectsHorz
updateObjectsVertNoMove:
          mov       dx, [bx+Y]          ;save Y position for drawing and etc
updateObjectsHorz:                      ;for checking for horizontal movement
          mov       si, [bx+HORZ]       ;get vertical movement
          mov       cx, [bx+W]          ;save width for quick access
          cmp       si, 0               ;did they move horizontally?
          je        updateObjectsHorzNoMove
          add       si, cx              ;add width to calcs
          add       si, [bx+X]          ;add X pos
          cmp       si, 320             ;past right of the screen?
          jng       updateObjectsHorzLeft
          mov       si, 320
          sub       si, cx              ;get farthest pos left ship can go
          jmp       updateObjectsUpdatePos
updateObjectsHorzLeft:
          sub       si, cx              ;left is from the X pos, not with WDTH
          cmp       si, 0               ;past the left of the screen?
          jnl       updateObjectsUpdatePos
          mov       si, 0               ;at the left of the screen
          jmp       updateObjectsUpdatePos
updateObjectsHorzNoMove:
          mov       si, [bx+X]
updateObjectsUpdatePos:
          mov       word ptr [bx+VERT], 0 ;reset our movement holders
          mov       word ptr [bx+HORZ], 0
;
;         calculate the current location of the ship for blacking out
;         regardless of where it moved
;
          mov       di, [bx+Y]          ;Y location of curr obj (for vid mem)
          call      getLocation         ;get the REAL y position of obj
          add       di, [bx+X]          ;set old X position
          mov       cx, [bx+H]          ;counter for drawing (height of obj)
;
;         black out the current ship
;         we need to do this even though we blank the full screen as the user
;         can move multiple times in each step
;
          mov       al, 0               ;set the color for blanking the object
updateObjectsBlack:
          push      cx
          mov       cx, [bx+W]          ;width of current object
          rep       stosb               ;blank it all...fast!
          pop       cx
          add       di, 320             ;go to the next line (320-width)
          sub       di, [bx+W]          ;the width of the image
          loop      updateObjectsBlack
;
;         update the ship's position NEW position from saved values
;
          mov       [bx+X], si          ;update x position of obj
          mov       [bx+Y], dx          ;update y position of obj
;
;         Don't used saved values below as this can be called directly from
;         the top where the values are are not saved in registers
;
updateObjectsNoMove:
          mov       di, [bx+Y]
          call      getLocation
          add       di, [bx+X]          ;x offset / position of ship
          mov       cx, [bx+H]          ;counter for drawing (height of obj)
          mov       si, [bx+PNT]        ;pointer to image data
          mov       dx, [bx+W]          ;width of object
updateObjectsShip:
          push      cx
          mov       cx, dx              ;width of object
          rep       movsb
          pop       cx
          add       di, 320             ;go to the next line (320-width)
          sub       di, dx              ;width of object
          loop      updateObjectsShip
;
updateObjectsDone:
          pop       di
          pop       si
          pop       es
          pop       dx
          pop       cx
          pop       bx
          pop       ax
          ret
updateObject        endp
;
;
;PROCEDURE updateStarField
;
; Makes the star field pass by.
;
; NOTE: this does *NOT* generate the star field, that must be done
; elsewhere.
;
;  INPUT=(void)
; OUTPUT=(void)
updateStarField     proc
          push      ax
          push      bx
          push      cx
          push      di
          push      si
          push      es
;
          mov       di, 0a000h
          mov       es, di              ;set the video memory location
;
;         Let's find out which way the stars should be moving
;
          cmp       MYSHIP[DIR], 0
          jl        upStarFieldRight
          mov       bx, SCROLL          ;scroll left, as normal
          jmp       upStarFieldStart
upStarFieldRight:
          mov       bx, -1*SCROLL       ;scroll right
;
;Move all the stars left/right and turn them white
;They are already blacked out before drawing by PLAY (from wipeScreen)
;
upStarFieldStart:
          mov       si, STARCOUNT
          mov       al, 255             ;white up the star
updateStarFieldLp:
          mov       di, STARFIELD[si]
          sub       di, bx
          stosb
          sub       di, 1               ;remove the 1 added by stosb
          mov       STARFIELD[si], di
          sub       si, 2
          jnc       updateStarFieldLp
;

          pop       es
          pop       si
          pop       di
          pop       cx
          pop       bx
          pop       ax
          ret
updateStarField     endp
;
;
;PROCEDURE updateStats
;
; This guy updates the user display of shields, weapons, and etc
; as well as does the recharging of weapons.
;
; I repeat the loops in here statically because I feel no need to write
; it iteratively (ie. way too complicated)
;
; If the user does die (ie. hull goes below 0), this is the function
; that kills the program and throws everything away.
;
;  INPUT=(void)
; OUTPUT=(void)
updateStats         proc
          push      ax
          push      cx
          push      es
          push      di
;
;         Before we do anything, we need to update the actual stats of our
;         ship.  Let's go ahead and do that here.
;
;         update the shields...don't go over 100%
;
          mov       ax, MYSHIP[SHLDS]
          add       ax, SHIELDREGEN
          cmp       ax, 100
          jle       upStatsPhsr
          mov       ax, 100
upStatsPhsr:        ;update the phasers...don't go over 100%
          mov       MYSHIP[SHLDS], ax   ;save shields
          mov       ax, MYSHIP[PHSR]
          add       ax, PHASERREGEN
          cmp       ax, 100
          jle       upStatsSuper
          mov       ax, 100
upStatsSuper:       ;update the super weapon...don't go over 100%
          mov       MYSHIP[PHSR], ax    ;save phasers
          mov       ax, MYSHIP[SPRW]
          add       ax, SUPERWEPREGEN
          cmp       ax, 100
          jle       upStatsGo
          mov       ax, 100
upStatsGo:
          mov       MYSHIP[SPRW], ax    ;save super weapon
;
          mov       di, 0a000h          ;set video memory
          mov       es, di
;
;         Borders:
;
          mov       al, 10              ;border with some nice, dark red
;
;         top
;
          mov       di, 3               ;start at left
          mov       cx, 314             ;to end of padding for stats
          rep       stosb               ;write to screen
;
;         bottom
;
          mov       di, 320*5+3         ;start at left, after the stats bars
          mov       cx, 314             ;to end of padding for stats
          rep       stosb               ;write to screen
;
;         Sides:
;         left
;
          mov       di, 322
          mov       cx, 4
upStatsLeft:
          stosb
          add       di, 319
          loop      upStatsLeft
;
;         between hull and shields
;
          mov       di, 425
          mov       cx, 4
upStatsHullSh:
          stosb
          add       di, 319
          loop      upStatsHullSh
;
;         between shields and phasers
;
          mov       di, 528
          mov       cx, 4
upStatsShPh:
          stosb
          add       di, 319
          loop      upStatsShPh
;
;         between phasers and super weapon indicator
;
          mov       di, 631
          mov       cx, 4
upStatsPhSup:
          stosb
          add       di, 319
          loop      upStatsPhSup
;
;         right
;
          mov       di, 637
          mov       cx, 4
upStatsRight:
          stosb
          add       di, 319
          loop      upStatsRight
;
;         HULL status
;
          mov       ah, 2               ;number of lines to paint
          mov       di, 644             ;padding from left (2 lines from top)
          mov       al, 14              ;red
upStatsHull:
          mov       cx, MYSHIP[HULL]    ;current status of HULL
          cmp       cx, 0
          jnl       upStatsHullDraw     ;hull below 0? don't red-out the scrn!
          mov       cx, 0
upStatsHullDraw:
          rep       stosb               ;set current line
          add       di, 320             ;next line
          sub       di, MYSHIP[HULL]    ;less where it should begin
          sub       ah, 1               ;end of painting?
          jnz       upStatsHull         
;
;         SHIELD status
;
          mov       ah, 2               ;number of lines to paint
          mov       di, 747             ;padding from left (1 line from top)
          mov       al, 200             ;blue
upStatsShields:
          mov       cx, MYSHIP[SHLDS]   ;current status of the SHIELDS
          cmp       cx, 0
          jnl       upStatsShieldsDraw
          mov       cx, 0
upStatsShieldsDraw:
          rep       stosb               ;set current line
          add       di, 320             ;next line
          sub       di, MYSHIP[SHLDS]   ;less where it should begin
          sub       ah, 1               ;end of painting?
          jnz       upStatsShields
;
;         PHASERS status
;
          mov       ah, 2               ;number of lines to paint
          mov       di, 850             ;padding from left (1 line from top)
          mov       al, 50              ;green
upStatsPhasers:
          mov       cx, MYSHIP[PHSR]    ;current status of the PHASERS
          cmp       cx, 0
          jnl       upStatsPhasersDraw
          mov       cx, 0
upStatsPhasersDraw:
          rep       stosb               ;set current line
          add       di, 320             ;next line
          sub       di, MYSHIP[PHSR]    ;less where it should begin
          sub       ah, 1               ;end of painting?
          jnz       upStatsPhasers
;
;         SUPER WEAPON stats
;
          mov       ah, 2               ;number of lines to paint
          mov       di, 953             ;padding from left (1 line from top)
          cmp       MYSHIP[SPRW], 100   ;is the weapon charged?
          je        upStatsSuperGood
          mov       al, 0               ;the weapon is not charged
          jmp       upStatsSuperDraw
upStatsSuperGood:
          mov       al, 55              ;yellow to indicate it's ready
upStatsSuperDraw:
          mov       cx, 3               ;number of pixels to draw
          rep       stosb               ;draw current line
          add       di, 320-3           ;next line
          sub       ah, 1               ;end of painting?
          jnz       upStatsSuperDraw
;
updateStatsDone:
          pop       di
          pop       es
          pop       cx
          pop       ax
          ret
updateStats         endp
;
;
;PROCEDURE userAction
;
; Sees if any keys have been hit and moves the user's ship accordingly
;
;  INPUT=(void)
; OUTPUT=(void)
userAction          proc
          push      ax
          push      bx
          push      si
;
          mov       ah, 1               ;check for key in queue
          int       16h                 ;try to grab key
          jz        userActionDone      ;no key was pressed
          mov       ah, 0
          int       16h
;
;         below here, we know a key was pressed, see what to do.
;
          cmp       ah, UPARROW         ;up arrow?
          je        userActionUp
          cmp       ah, DOWNARROW       ;down arrow?
          je        userActionDown
          cmp       ah, RIGHTARROW      ;right arrow?
          je        userActionRight
          cmp       ah, LEFTARROW       ;left arrow?
          je        userActionLeft
          cmp       ah, SPACEBAR        ;space bar?
          je        userActionFire
          cmp       ah, ENTERKEY        ;super weapon fire?
          je        userActionSuperWeapon
          cmp       ah, BACKSPACE       ;backspace key?
          je        userActionExit
          jmp       userActionDone      ;we don't recognize what the user hit
userActionUp:
          sub       MYSHIP[VERT], MYMOVE;move the ship down (movement holder)
          jmp       userActionMove
userActionDown:
          add       MYSHIP[VERT], MYMOVE;move the ship up (movement holder)
          jmp       userActionMove
userActionRight:
          add       MYSHIP[HORZ], MYMOVE;move the ship right
          jmp       userActionMove
userActionLeft:
          sub       MYSHIP[HORZ], MYMOVE;move the ship left
          jmp       userActionMove
userActionMove:
          lea       bx, MYSHIP          ;get pointer to ship
          call      updateObject        ;update the position of the ship
          jmp       userActionDone
userActionFire:
          lea       bx, MYSHIP
          lea       si, ENEMY
          call      fire                ;fire the weapon!
          jmp       userActionDone
userActionSuperWeapon:
          call      fireSuperWeapon
          jmp       userActionDone
userActionExit:
          call      noteDone            ;turn off the speaker
          call      deinitGraphics
          call      exit
          jmp       userActionDone
userActionDone:
          pop       si
          pop       bx
          pop       ax
          ret
userAction          endp
;
;
;PROCEDURE wipeScreen
;
; Once every round it becomes necessary to clean the screen:
;   1) traditional recoloring the pixels does not work because
;      some things are drawn to the screen and not linked to any
;      object, so we lose track of their place
;   2) we redraw everything every round anyway...so why not?
;
;  INPUT=(void)
; OUTPUT=(void)
wipeScreen          proc
          push      ax
          push      cx
          push      es
          push      di
;
          mov       di, 0a000h          ;video memory
          mov       es, di
          mov       di, 0               ;memory counter
          mov       al, 0               ;black (color)
          mov       cx, 320*200         ;dimensions
          rep       stosb
;
          pop       di
          pop       es
          pop       cx
          pop       ax
          ret
wipeScreen          endp
;
;=============================================================================
;====== The following are some modified procedures from Dewar used for  ======
;======                  delays and sound and the like.                 ======
;=============================================================================
;
;
;=============================================================================
;======  Note: I did not write the following code, I stole it from the  ======
;======  Dewar game, but I did modify it some so that I have control    ======
;======  over the delay loop that happens for checking for user input   ======
;======  and the like.                                                  ======
;=============================================================================
;=============================================================================

CTRL      EQU   61H          ; timer gate control port
TIMR      EQU   00000001B     ; bit to turn timer on
SPKR      EQU   00000010B     ; bit to turn speaker on
;
;  Definitions of input/output ports to access timer chip
;
TCTL      EQU   043H          ; port for timer control
TCTR      EQU   042H          ; port for timer count values
;
;  Definitions of timer control values (to send to control port)
;
TSQW      EQU   10110110B     ; timer 2, 2 bytes, sq wave, binary
LATCH     EQU   10000000B     ; latch timer 2
;
;  Define 32 bit value used to set timer frequency
;
FRHI      EQU   0012H          ; timer frequency high (1193180 / 256)
FRLO      EQU   34DCH          ; timer low (1193180 mod 256)
prepnote            proc
          push      ax
          push      bx
          push      dx
          push      si
;
          mov       bx, ax    ;save frequency in bx
          mov       cx, dx    ;save duration in cx
;
;  we handle the rest (silence) case by using an arbitrary frequency to
;  program the clock so that the normal approach for getting the right
;  delay functions, but we will leave the speaker off in this case.
;
          mov       si, bx    ; copy frequency to bx
          or        bx, bx    ; test zero frequency (rest)
          jnz       not1      ; jump if not
          mov       bx, 256   ; else reset to arbitrary non-zero
;
;  initialize timer and set desired frequency
;
not1:     mov       al, tsqw  ; set timer 2 in square wave mode
          out       tctl, al
          mov       dx, frhi  ; set dx:ax = 1193180 decimal
          mov       ax, frlo  ;      = clock frequency
          div       bx        ; divide by desired frequency
          out       tctr, al  ; output low order of divisor
          mov       al, ah    ; output high order of divisor
          out       tctr, al
;
;  turn the timer on, and also the speaker (unless frequency 0 = rest)
;
          in        al, ctrl  ; read current contents of control port
          or        al, timr  ; turn timer on
          or        si, si    ; test zero frequency
          jz        not2      ; skip if so (leave speaker off)
          or        al, spkr  ; else turn speaker on as well
;
;  compute number of clock cycles required at this frequency
;
not2:     out       ctrl, al  ; rewrite control port
          xchg      ax, bx    ; frequency to ax
          mul       cx        ; frequency times secs/100 to dx:ax
          mov       cx, 100   ; divide by 100 to get number of beats
          div       cx
          shl       ax, 1     ; times 2 because two clocks/beat
          xchg      ax, cx    ; count of clock cycles to cx
;
;  wait is complete, so return
;
          pop       si 
          pop       dx
          pop       bx
          pop       ax
          ret
prepnote            endp
;
noteDone            proc
          push      ax
;
          in        al, ctrl            ;read current contents of port
          and       al, 0ffh-timr-spkr  ;reset timer/speaker control bits
          out       ctrl, al            ;rewrite control port
;
          pop       ax
          ret
noteDone            endp
;
;  routine to read count, returns current timer 2 count in ax
;
rctr                proc
          mov       al, latch           ;latch the counter
          out       tctl, al            ;latch counter
          in        al, tctr            ;read lsb of count
          mov       ah, al
          in        al, tctr            ;read msb of count
          xchg      ah, al              ;count is in ax
          ret
rctr                endp
;
;=============================================================================
;======     These procedures are used for reading BMP image files.      ======
;====== Note: I did not write part of these, but they have been moded   ======
;======     to fit the scheme of this game and provide additional       ======
;======                         functionality.                          ======
;=============================================================================
;
;
;PROCEDURE bmpToScreen
;
; This is one of a series of BMP functions that work with a set of back-end
; procedures for getting BMP images to display on the current screen.
;
;  INPUT=dx-pointer to filename to display
; OUTPUT=(void) (the screen is written to the image given)
bmpToScreen         proc
          push      ax
          push      bx
          push      cx
          push      di
          push      si
          push      es
;
;         first, we need to load the file - the file pointer is returned in BX
;
          call      loadFile
;
;         now, read the BMP header from the file (contained in BX)
;
          call      readBMPHeader
          call      writePalette
;
;         above, we used shared methods for getting bmp info, but this one is
;         unique to writing to the screen -- so we only have it here
;
          mov       cx, BMPHeight
;
          mov       ax, 0a000h          ;video memory
          mov       es, ax              ;set video memory pointer
bmpToScreenLoop:
          push      cx
          mov       di, cx
          call      getLocation         ;CX*320 - first pixel on current line
          mov       ah, 3fh
          lea       dx, ScrLine
          mov       cx, BMPWidth
          int       21h                 ;read one line into the buffer
;   
          cld                           ;clear direction flag, for movsb.
          mov       cx, BMPWidth
          lea       si, ScrLine
          rep       movsb               ;copy line in buffer to screen
;         
          pop       cx
          sub       cx, 1
          jnc       bmpToScreenLoop
;
          call      closeFile           ;close our image
;
          pop       es
          pop       si
          pop       di
          pop       cx
          pop       bx
          pop       ax
          ret
bmpToScreen         endp
;
;
;PROCEDURE readBMPHeader
;
; Reads the BMP header and sets some temp stats about the file
;
;  INPUT=bx-the file pointer of the bmp graphic
; OUTPUT=void (bx will now contain only image data waiting to be written)
;        PALSIZE - the size of the palette for this image
;        BMPWIDTH - the width of the just-read bmp image
;        BMPHEIGHT - the height of the just-read bmp image
readBMPHeader       proc
          push      ax
          push      cx
          push      dx
;
          mov       ah, 3fh
          mov       cx, 54              ;length of header
          lea       dx, Header
          int       21h                 ;read file header into buffer.
;
;Now, we shall get the info about this BMP image
;
          mov       cl, 2               ;for dividing by 4     
          mov       ax, header[0Ah]     ;ax=beginning of graphic data
;
;         header has a length of 54, so remove that
;
          sub       ax, 54              ;graphic data begins after the header
;
;         we now have a palette pointer in AX, but the palette size is only
;         1/4 of that because it takes 4 bytes to store 1 color in the palette
;
          shr       ax, cl              ;get rid of that extra 4 bytes
          mov       PALSIZE, ax         ;save the length of the palette
;
;         and this is where we save the info about the image dimensions
;
          mov       ax, header[12h]     ;ax=width of bmp image
          mov       BMPWIDTH, ax        ;store the width
          mov       ax, header[16h]     ;ax=height of the image
          mov       BMPHEIGHT, ax       ;store it.
;
          pop       dx
          pop       cx
          pop       ax
          ret
readBMPHeader       endp
;
;
;PROCEDURE cacheImage
;
; Loads the specified image file into its cache
;
; Note: BMP images are stored upside down (wtf?), so we have to work backwards
; with the cache in order to get the image right side up, hence the awkward
; value of di.
;
;  INPUT=dx-filename
;        di-cache location (points to end of cache - width)
; OUTPUT=(void) (the image in the cache location)
cacheImage          proc
          push      ax
          push      cx
          push      di
          push      si
          push      es
;
;         first, we need to load the file - the file pointer is returned in BX
;
          call      loadFile
;
;         now, read the BMP header from the file (contained in BX)
;
          call      readBMPHeader
;
;         We don't need to write the pallete again, just shave off the extra
;         palette info that is included in every BMP file
;
          mov       ax, PalSize         ;get number of colors in palette
          mov       cl, 2
          shl       ax, cl              ;there are 4 bytes per color
          mov       cx, ax              ;set number of bytes to read
          mov       ah, 3fh             ;set the function call
          lea       dx, palBuff
          int       21h                 ;put the palette into the buffer.
;
;         DONE shaving off palette info
;
          mov       cx, BMPHeight       ;counter for loop
cacheImageLoop:
          push      cx
          mov       ah, 3fh             ;read file command
          lea       dx, ScrLine         ;where to put contents
          mov       cx, BMPWidth        ;length to read
          int       21h                 ;read one line into the buffer
;
;         si - source for movsb
;         di - location for movsb
;         cx - counter until done
;
          cld                           ;clear direction flag, for movsb
          lea       si, ScrLine         ;where to copy from
          rep       movsb               ;copy line in buffer to screen
;         
          sub       di, BMPWIDTH
          sub       di, BMPWIDTH        ;-width*2 = previous line in graphic
          pop       cx
          loop      cacheImageLoop      ;cx=0? done caching the image?
;
          call      closeFile           ;close the image file
;
          pop       es
          pop       si
          pop       di
          pop       cx
          pop       ax
          ret
cacheImage          endp
;
;
;PROCEDURE writePalette
;
; Writes the palette in the temp holder directly to video memory
;
;  INPUT=bx-file pointer to current image
; OUTPUT=void (writes the palette to vga memory and points bx to front of
;              image data)
writePalette        proc
          push      ax
          push      cx
          push      dx
          push      si
          push      di
;
;         take the palette size, multiply it by 4 (4 bytes per color), and
;         then set the reading function to read that many bytes
;
          mov       ax, PalSize         ;get number of colors in palette
          mov       cl, 2
          shl       ax, cl              ;there are 4 bytes per color
;
          mov       cx, ax              ;set number of bytes to read
          mov       ah, 3fh             ;set the function call
          lea       dx, palBuff
          int       21h                 ;put the palette into the buffer.
;
          lea       si, palBuff         ;point to buffer containing palette.
          mov       di, PalSize         ;number of colors to send.
          mov       dx, 3c8h            ;initialize palette recieve for VGA
          mov       al, 0               ;we will start at 0.
          out       dx, al              ;tell palette we want to begin
          inc       dx                  ;dx=3C9h=where we send the colors
          mov       cl, 2
;
;BMP files are saved as BGR, not RGB.
;
;Also, the palette accepts colors of up RGB with values up to 63 for each
;slot, so 255/4 gives a reasonable value.
; Note: Colors in a BMP file are saved as BGR values rather than RGB.
;
writePaletteSend:
          mov       al, [si+2]          ;get red value.
          shr       al, cl              ;divide by 4
          out       dx, al              ;send it.
          mov       al, [si+1]          ;get green value.
          shr       al, cl
          out       dx, al
          mov       al, [si]            ;get blue value.
          shr       al, cl
          out       dx, al
          add       si, 4               ;get the next color
          sub       di, 1
          jnc       writePaletteSend
;
          pop       di
          pop       si
          pop       dx
          pop       cx
          pop       ax
          ret
writePalette         endp
;
;=============================================================================
;======       The following are for reading / manipulating files        ======
;=============================================================================
;
;
;
;PROCEDURE closeFile
;
; Closes down a file pointer when it is no longer in use.
;
;  INPUT=bx-file pointer
; OUTPUT=(void)
closeFile           proc
          push      ax
;
          mov       ah, 3eh   ;close the given file pointer
          int       21h
;
          pop       ax
          ret
closeFile           endp
;
;
;PROCEDURE loadFile
;
; This procedure loads a given file and returns the pointer to that file;
; if file reading was not succesful, it kills the program.
;
;  INPUT=dx-pointer to filename
; OUTPUT=bx=file pointer (if succesfully opened)
loadFile            proc
          push      ax
          push      dx
;
          mov       ah, 3dh             ;file reading command
          mov       al, 0               ;open file for reading
          int       21h
          jc        loadFileErr         ;error? display it and quit
          mov       bx, ax              ;set file handle
          jmp       loadFileDone
;
loadFileErr:
          lea       dx, msgFileErr
          call      raiseError
;
loadFileDone:
          pop       dx
          pop       ax
          ret
loadFile            endp
          end
