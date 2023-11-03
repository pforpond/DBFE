REM dosbox frontend
REM dp 2020
 
$CONSOLE:ONLY
_DEST _CONSOLE
IF INSTR(_OS$, "[WINDOWS]") THEN LET ros$ = "win"
IF INSTR(_OS$, "[LINUX]") THEN LET ros$ = "lnx"
IF INSTR(_OS$, "[MACOSX]") THEN LET ros$ = "mac"
setup:
REM loads games folder location AND checks IF it exists
10 IF _FILEEXISTS("dbfe.ddf") THEN
    OPEN "dbfe.ddf" FOR INPUT AS #1
    INPUT #1, rootdir$, confdir$, confname$, dosboxexe$, ifwindows$
    CLOSE #1
    IF _DIREXISTS(rootdir$) THEN
        REM nothing
    ELSE
        PRINT: PRINT "Cannot find games folder!"
        IF ros$ = "lnx" OR ros$ = "mac" THEN SHELL _HIDE "rm dbfe.ddf"
        IF ros$ = "win" THEN SHELL _HIDE "del dbfe.ddf"
        GOTO 10
    END IF
ELSE
    PRINT "Please type in the location of your games folder..."
    INPUT rootdir$
    IF _DIREXISTS(rootdir$) THEN
        OPEN "dbfe.ddf" FOR OUTPUT AS #1
        PRINT #1, rootdir$
        CLOSE #1
    ELSE
        PRINT: PRINT "Cannot find games folder!"
        IF _FILEEXISTS("dbfe.ddf") THEN
            IF ros$ = "lnx" OR ros$ = "mac" THEN SHELL _HIDE "rm dbfe.ddf"
            IF ros$ = "win" THEN SHELL _HIDE "del dbfe.ddf"
        END IF
        GOTO 10
    END IF
    IF ros$ = "win" OR ros$ = "lnx" THEN PRINT "Please type in the location of your dosbox conf folder (must ONLY contain unedited conf file)..."
    IF ros$ = "mac" THEN PRINT "Please type in the location of your dosbox preferences folder..."
    INPUT confdir$
    IF _DIREXISTS(confdir$) THEN
        OPEN "dbfe.ddf" FOR APPEND AS #1
        PRINT #1, confdir$
        CLOSE #1
        IF ros$ = "lnx" OR ros$ = "mac" THEN SHELL _HIDE "ls '" + confdir$ + "' > temp.ddf"
        IF ros$ = "win" THEN SHELL _HIDE "dir /b " + CHR$(34) + confdir$ + CHR$(34) + " > temp.ddf"
        IF ros$ = "lnx" OR ros$ = "win" THEN
        	REM conf finder (linux and windows)
			OPEN "temp.ddf" FOR INPUT AS #1
			INPUT #1, confname$
			CLOSE #1
            LET findconf% = INSTR(findconf% + 1, confname$, ".conf")
            IF findconf% THEN
                IF ros$ = "lnx" THEN SHELL _HIDE "rm temp.ddf"
                IF ros$ = "win" THEN SHELL _HIDE "del temp.ddf"
                OPEN "dbfe.ddf" FOR APPEND AS #1
                PRINT #1, confname$
                CLOSE #1
                LET findconf% = 0
            ELSE
                PRINT: PRINT "Cannot find conf file in folder!"
                IF _FILEEXISTS("dbfe.ddf") THEN
                    IF ros$ = "lnx" THEN SHELL _HIDE "rm dbfe.ddf"
                    IF ros$ = "win" THEN SHELL _HIDE "del dbfe.ddf"
                END IF
                GOTO 10
            END IF
        END IF
        IF ros$ = "mac" THEN
			REM conf finder (macos)
			OPEN "temp.ddf" FOR INPUT AS #1
			DO
				INPUT #1, confname$
				LET findconf% = INSTR(findconf% + 1, confname$, "DOSBox")
			LOOP UNTIL findconf% OR EOF(1)
			CLOSE #1
			IF findconf% THEN
				SHELL _HIDE "rm temp.ddf"
				OPEN "dbfe.ddf" FOR APPEND AS #1
				PRINT #1, confname$
				CLOSE #1
				LET findconf% = 0
			ELSE
				PRINT: PRINT "Cannot find preference file in folder!"
				SHELL _HIDE "rm dbfe.ddf"
				GOTO 10
			END IF
        END IF
    ELSE
        PRINT: PRINT "Cannot find preference folder!"
        IF _FILEEXISTS("dbfe.ddf") THEN
            IF ros$ = "lnx" OR ros$ = "mac" THEN SHELL _HIDE "rm dbfe.ddf"
            IF ros$ = "win" THEN SHELL _HIDE "del dbfe.ddf"
        END IF
        GOTO 10
    END IF
END IF
IF ros$ = "win" THEN
    IF dosboxexe$ = "" THEN
        PRINT "Please type in the location of your dosbox program folder..."
        INPUT dosboxwin$
        SHELL _HIDE "dir /b " + CHR$(34) + dosboxwin$ + CHR$(34) + " > temp.ddf"
        OPEN "temp.ddf" FOR INPUT AS #1
        DO
            INPUT #1, temp$
            LET finddosbox% = INSTR(finddosbox% + 1, UCASE$(temp$), "DOSBOX.EXE")
            IF finddosbox% THEN
                LET dosboxexe$ = dosboxwin$ + "\" + "dosbox.exe"
                LET finddosbox% = 0
            END IF
        LOOP UNTIL EOF(1) OR dosboxexe$ <> ""
        CLOSE #1
        IF dosboxexe$ = "" THEN
            PRINT: PRINT "Cannot find dosbox exe in folder!"
            IF _FILEEXISTS("dbfe.ddf") THEN
                SHELL _HIDE "del dbfe.ddf"
            END IF
            SHELL _HIDE "del temp.ddf"
            GOTO 10
        ELSE
            OPEN "dbfe.ddf" FOR APPEND AS #1
            PRINT #1, dosboxexe$
            CLOSE #1
            SHELL _HIDE "del temp.ddf"
        END IF
    END IF
ELSE
	IF ifwindows$ = "notwindows" THEN
		REM nothing
	ELSE
		OPEN "dbfe.ddf" FOR APPEND AS #1
		PRINT #1, "notwindows"
		CLOSE #1
	END IF
END IF
PRINT
IF ros$ = "win" THEN PRINT "Dosbox found at: " + dosboxexe$
PRINT "Games folder found at: " + rootdir$
PRINT "Conf file found at: " + confdir$
PRINT "Conf file name is: " + confname$
PRINT "Building database..."
IF ros$ = "lnx" OR ros$ = "mac" THEN SHELL _HIDE "ls '" + rootdir$ + "' > dosgamedb.ddf"
IF ros$ = "win" THEN SHELL _HIDE "dir /b " + CHR$(34) + rootdir$ + CHR$(34) + " > dosgamedb.ddf"
OPEN "dosgamedb.ddf" FOR INPUT AS #1
DO
    LET numberofgames = numberofgames + 1
    INPUT #1, templine$
LOOP UNTIL EOF(1)
CLOSE #1
GOTO menu
 
menu:
REM menu
PRINT
PRINT "DOSBOX FRONTEND"
PRINT
PRINT "1) Quick Launch"
PRINT "2) List Games"
PRINT "3) Search for Games"
PRINT "4) Change Folders"
PRINT "5) Quit"
PRINT
INPUT a
IF a = 1 THEN GOTO quicklaunch
IF a = 2 THEN GOTO listgames
IF a = 3 THEN GOTO searchgames
IF a = 4 THEN GOTO changedir
IF a = 5 THEN
    IF ros$ = "lnx" OR ros$ = "mac" THEN SHELL _HIDE "rm dosgamedb.ddf": SHELL _HIDE "rm dosexedb.ddf"
    IF ros$ = "win" THEN SHELL _HIDE "del dosgamedb.ddf": SHELL _HIDE "del dosexedb.ddf"
    SYSTEM
END IF
GOTO menu
 
searchgames:
REM searches FOR a game
PRINT
INPUT "Insert Search Term: "; gamesearch$
IF gamesearch$ = "" THEN GOTO menu
LET dbline = 0
LET dbloop = 0
OPEN "dosgamedb.ddf" FOR INPUT AS #1
DO
    DO
        LET dbline = dbline + 1
        INPUT #1, gamedir$
        LET findsearch% = INSTR(findsearch% + 1, UCASE$(gamedir$), UCASE$(gamesearch$))
        IF findsearch% THEN
            LET dbloop = dbloop + 1
            PRINT dbline; " - " + gamedir$
            LET findsearch% = 0
        END IF
    LOOP UNTIL dbloop = 20 OR EOF(1)
    LET dbloop = 0
    IF EOF(1) THEN PRINT "End of Search Results!"
    PRINT "Type in a game number. ENTER) Next Page. 0) Menu."
    50 INPUT a$
    IF UCASE$(a$) = "0" THEN GOTO menu
    IF a$ <> "" THEN
        LET gameno = VAL(a$)
        IF gameno > 0 THEN GOSUB launchgame: GOTO menu
        GOTO 50
    END IF
LOOP UNTIL EOF(1)
CLOSE #1
GOTO menu
 
quicklaunch:
REM quick launches a game
PRINT
INPUT "Insert Game Number: "; gameno
IF gameno = 0 THEN GOTO menu
GOSUB launchgame
GOTO menu
 
changedir:
REM changes game directory
LET rootdir$ = ""
IF ros$ = "lnx" OR ros$ = "mac" THEN SHELL _HIDE "rm dbfe.ddf"
IF ros$ = "win" THEN SHELL _HIDE "del dbfe.ddf"
GOTO setup
 
listgames:
REM lists games
LET dbline = 0
LET dbloop = 0
OPEN "dosgamedb.ddf" FOR INPUT AS #1
DO
    DO
        LET dbline = dbline + 1
        LET dbloop = dbloop + 1
        INPUT #1, gamedir$
        PRINT dbline; " - " + gamedir$
    LOOP UNTIL dbloop = 20 OR EOF(1)
    IF EOF(1) THEN PRINT "End of Game List!"
    PRINT "Type in a game number. ENTER) Next Page. 0) Menu."
    20 INPUT a$
    IF UCASE$(a$) = "0" THEN CLOSE #1: GOTO menu
    IF UCASE$(a$) <> "" THEN
        REM launch game
        LET gameno = VAL(a$)
        IF gameno > 0 THEN GOSUB launchgame: GOTO menu
        GOTO 20
    END IF
    LET dbloop = 0
LOOP UNTIL EOF(1)
CLOSE #1
GOTO menu
 
launchgame:
REM launches games?
CLOSE #1
IF gameno > numberofgames THEN PRINT: PRINT "The total number of games available is "; numberofgames: RETURN
LET dbloop2 = 0
OPEN "dosgamedb.ddf" FOR INPUT AS #1
DO
    LET dbloop2 = dbloop2 + 1
    INPUT #1, gamedir$
LOOP UNTIL dbloop2 = gameno
CLOSE #1
IF ros$ = "lnx" OR ros$ = "mac" THEN SHELL _HIDE "ls '" + rootdir$ + "/" + gamedir$ + "' > dosexedb.ddf"
IF ros$ = "win" THEN SHELL _HIDE "dir /b " + CHR$(34) + rootdir$ + "\" + gamedir$ + CHR$(34) + " > dosexedb.ddf"
PRINT
PRINT gamedir$ + " - Available Executables"
PRINT
LET dbloop2 = 0
OPEN "dosexedb.ddf" FOR INPUT AS #1
DO
    INPUT #1, gameexe$
    LET findexe% = INSTR(findexe% + 1, gameexe$, ".exe")
    LET findcom% = INSTR(findcom% + 1, gameexe$, ".com")
    LET findbat% = INSTR(findbat% + 1, gameexe$, ".bat")
    LET findcapexe% = INSTR(findcapexe% + 1, gameexe$, ".EXE")
    LET findcapcom% = INSTR(findcapcom% + 1, gameexe$, ".COM")
    LET findcapbat% = INSTR(findcapbat% + 1, gameexe$, ".BAT")
    IF findexe% OR findcom% OR findbat% OR findcapexe% OR findcapcom% OR findcapbat% THEN
        LET dbloop2 = dbloop2 + 1
        PRINT dbloop2; " - " + gameexe$
        LET findexe% = 0
        LET findcom% = 0
        LET findbat% = 0
        LET findcapexe% = 0
        LET findcapcom% = 0
        LET findcapbat% = 0
    END IF
LOOP UNTIL EOF(1)
CLOSE #1
LET numberofexe = dbloop2
IF numberofexe = 0 THEN PRINT "No executable files found!": RETURN
PRINT "Type in a launch number. 0) Menu."
30 INPUT b$
IF UCASE$(b$) = "0" THEN RETURN
IF UCASE$(b$) <> "" THEN
    REM launch game
    LET exeno = VAL(b$)
    IF exeno > 0 THEN GOSUB launchexe: GOTO menu
END IF
GOTO 30
 
launchexe:
REM launches a game exe
IF exeno > numberofexe THEN PRINT: PRINT "The total number of executable files available is "; numberofexe: RETURN
LET dbloop3 = 0
OPEN "dosexedb.ddf" FOR INPUT AS #1
DO
    INPUT #1, gameexe$
    LET findexe% = INSTR(findexe% + 1, gameexe$, ".exe")
    LET findcom% = INSTR(findcom% + 1, gameexe$, ".com")
    LET findbat% = INSTR(findbat% + 1, gameexe$, ".bat")
    LET findcapexe% = INSTR(findcapexe% + 1, gameexe$, ".EXE")
    LET findcapcom% = INSTR(findcapcom% + 1, gameexe$, ".COM")
    LET findcapbat% = INSTR(findcapbat% + 1, gameexe$, ".BAT")
    IF findexe% OR findcom% OR findbat% OR findcapexe% OR findcapcom% OR findcapbat% THEN
        LET dbloop3 = dbloop3 + 1
        LET findexe% = 0
        LET findcom% = 0
        LET findbat% = 0
        LET findcapexe% = 0
        LET findcapcom% = 0
        LET findcapbat% = 0
    END IF
LOOP UNTIL dbloop3 = exeno
CLOSE #1
PRINT: PRINT "Launching " + gamedir$ + " [" + gameexe$ + "]...": PRINT
IF ros$ = "lnx" OR ros$ = "mac" THEN SHELL _HIDE "cp '" + confdir$ + "/" + confname$ + "' ."
IF ros$ = "win" THEN SHELL _HIDE "copy " + CHR$(34) + confdir$ + "\" + confname$ + CHR$(34) + " " + confname$
IF ros$ = "win" OR ros$ = "lnx" THEN OPEN confname$ FOR APPEND AS #1
IF ros$ = "mac" THEN OPEN confdir$ + confname$ FOR APPEND AS #1
PRINT #1, ""
IF ros$ = "lnx" OR ros$ = "mac" THEN PRINT #1, "mount c " + CHR$(34) + rootdir$ + "/" + gamedir$ + CHR$(34)
IF ros$ = "win" THEN PRINT #1, "mount c " + CHR$(34) + rootdir$ + "\" + gamedir$ + CHR$(34)
PRINT #1, "c:"
PRINT #1, gameexe$
PRINT #1, "exit"
CLOSE #1
REM launch dosbox
IF ros$ = "lnx" THEN SHELL "dosbox -conf " + confname$
IF ros$ = "win" THEN SHELL CHR$(34) + dosboxexe$ + CHR$(34) + " -conf " + confname$
IF ros$ = "mac" THEN SHELL "open -a dosbox"
IF ros$ = "mac" THEN 
	PRINT: PRINT "Press ENTER to finish playing..."
	INPUT temp$
END IF
REM post game commands
IF ros$ = "lnx" THEN SHELL _HIDE "rm " + confname$
IF ros$ = "win" THEN SHELL _HIDE "del " + confname$
IF ros$ = "mac" THEN 
	SHELL _HIDE "rm '" + confdir$ + "/" + confname$ + "'"
	SHELL _HIDE "cp '" + confname$ + "' '" + confdir$ + "/" + confname$ + "'"
	SHELL _HIDE "rm '" + confname$ + "'"
END IF
RETURN
