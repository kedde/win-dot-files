class LogLevel
{
    Debug()
    {
        return 1
    }

    Information()
    {
        return 2
    }

    Warning()
    {
        return 3
    }

    Error()
    {
        return 4
    }

    Critical()
    {
        return 5
    }

    GetLogName(logLevel)
    {
        switch logLevel
        {
            case 1: return "Debug"
            case 2: return "Information"
            case 3: return "Warning"
            case 4: return "Error"
            case 5: return "Critical"
        }
        return "Unknow"
    }
}

class Logger
{
    __new(){
        this.logLevel := new LogLevel
    }

    ; TODO move log to a seperate file - including the loglevel
    WriteLog(text, logLevel) {
        ; Get-Content C:\Users\[username]\AppData\Local\Temp\Autohotkey\logFile.txt -Wait
        tempFolder = %A_Temp%\Autohotkey

        IfNotExist, %tempFolder%
            FileCreateDir, %tempFolder%

        logFile = %tempFolder%\logFile.txt

        ; MsgBox, % CurrentLogLevel
        isInitialized := IsInitialized(CurrenLogLevel)
        if (isInitialized)
        {
            MsgBox, % "Please initialize CurrentLogLevel variable CurrentLogLevel := LogLevel.Information()"
            return
        }

        if (CurrentLogLevel <= logLevel)
        {
            logName := this.logLevel.GetLogName(CurrentLogLevel)

            text := "[" . logName . "] " . text
            logText = % A_NowUTC ": " text  "`n"

            ; NOTE: 
            ; using the FileAppend method gives the following error 
            ; Get-Content: The process cannot access the file
            ; when watching for changes using the powershell 
            ; cmd Get-Content with the -wait option
            file := FileOpen(logFile, "a")
            file.write(logText)
            file.close()
        }
    }
}
