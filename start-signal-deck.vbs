Dim fso, shell, folder, chromePath, bravePath, url

Set fso = CreateObject("Scripting.FileSystemObject")
Set shell = CreateObject("WScript.Shell")
folder = fso.GetParentFolderName(WScript.ScriptFullName)
url = "http://localhost:8000/dashboard.html"

' Start the local server hidden (no console window).
' If it's already running from a previous launch, this second attempt
' will just fail quietly to bind the port - the first instance keeps serving.
shell.Run "powershell -WindowStyle Hidden -ExecutionPolicy Bypass -File """ & folder & "\serve.ps1""", 0, False
WScript.Sleep 900

chromePath = "C:\Program Files\Google\Chrome\Application\chrome.exe"
bravePath  = "C:\Program Files\BraveSoftware\Brave-Browser\Application\brave.exe"

If fso.FileExists(bravePath) Then
  shell.Run """" & bravePath & """ --app=" & url, 1, False
ElseIf fso.FileExists(chromePath) Then
  shell.Run """" & chromePath & """ --app=" & url, 1, False
Else
  shell.Run url, 1, False
End If
