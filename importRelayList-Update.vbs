Option Explicit
Dim objSMTP,objRelayIpList,objCurrentList,objIP,objFSO,objTextFile,count,newIpList(),inputOption,outputFile,ipFilePath
outputFile = "IPrelayAddOrRemove.txt"
ipFilePath = "E:\IPUpdateKit\ip.txt"

Function WriteOutput(text)
    Dim fso, file
    Set fso = CreateObject("Scripting.FileSystemObject")
    Set file = fso.OpenTextFile(outputFile, 8, True)
    file.WriteLine text
    file.Close
End Function
Set objSMTP = GetObject("IIS://localhost/smtpsvc/1")
Set objRelayIpList = objSMTP.Get("RelayIpList") 
'objRelayIpList is of type IIsIPSecuritySetting http://msdn.microsoft.com/en-us/library/ms525725.aspx
WriteOutput "============================================" 
WriteOutput "CURRENT SETTINGS"
WriteOutput "================"
WriteOutput " " 
WriteOutput "Computer(s) that may relay through this virtual server."
WriteOutput " " 
' GrantByDefault returns 0 when "only the list below" is set (false) and -1 when all except the list below is set(true)
If objRelayIpList.GrantByDefault = true Then
    WriteOutput "All except the list below :"
    objCurrentList = objRelayIpList.IPDeny
Else 
    WriteOutput "Only the list below :"
    objCurrentList = objRelayIpList.IPGrant
End If
count = 0
For Each objIP in objCurrentList
        WriteOutput objIP 
        count = count + 1
Next
If count = 0 Then
    WriteOutput "*NIL*"
End If
WriteOutput "============================================" 
WriteOutput " " 
WriteOutput "Replacing ReplayIpList with the IP address(es) from the ip.txt file."
WriteOutput " "
Do While Not((inputOption = "a") Or (inputOption = "d") Or (inputOption = "x") ) 
WriteOutput " " 
WriteOutput "making changes"
WriteOutput " "
inputOption = "a" 'lcase(trim(Wscript.StdIn.ReadLine))
Loop
Set objFSO = CreateObject("Scripting.FileSystemObject")
If objFSO.FileExists(ipFilePath) Then
    Set objTextFile = objFSO.OpenTextFile(ipFilePath, 1)

    count = 0
    Do Until objTextFile.AtEndOfStream
        Redim Preserve newIpList(count)
       newIpList(count) = objTextFile.Readline
        count = count + 1
    Loop
    objTextFile.Close

    For each objIP in newIpList
       WriteOutput objIP
    Next
    WriteOutput " "
    Select Case inputOption
        Case "a"
            objRelayIpList.GrantByDefault = false
            objRelayIpList.IpGrant = newIpList
            WriteOutput "SET " & count &" address(es) to Allow List"        
        Case "d"
            objRelayIpList.GrantByDefault = true
            objRelayIpList.IpDeny = newIpList
            WriteOutput "SET " & count &" address(es) to Deny List"
        Case "x"
            WriteOutput "Exiting without making changes"
            WriteOutput "============================================" 
            Wscript.Quit
    End Select
    
    objSMTP.Put "RelayIpList",objRelayIpList
    objSMTP.SetInfo
    WriteOutput " "
    
    WriteOutput "============================================" 
Else
    WriteOutput "Please create a file ip.txt that contains the list of IP address(es)"
    WriteOutput "FORMAT : Each Line should be IP,MASK "
    WriteOutput "EX     : 127.0.0.1,255.255.255.255"
End If