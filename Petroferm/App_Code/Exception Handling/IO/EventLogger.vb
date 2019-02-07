Imports System
Imports System.IO

Public Class EventLogger

    Public Shared Sub Log(ByVal message As String)
        Dim sw As StreamWriter = File.AppendText("c:\eventlogger.txt")
        With sw
            .Write(ControlChars.CrLf & "Log Entry : ")
            .WriteLine("{0} {1}", DateTime.Now.ToLongTimeString(), DateTime.Now.ToLongDateString())
            .WriteLine(":")
            .WriteLine("{0}", message)
            .WriteLine("-------------------------------")
            .Flush()
            .Close()
        End With
    End Sub

    'Public Shared Sub DumpLog()
    'Dim r As StreamReader = File.OpenText("c:\eventlogger.txt")
    '    ' While not at the end of the file, read and write lines.
    '    Dim line As String
    '    line = r.ReadLine()
    '    While Not line Is Nothing
    '        line = r.ReadLine()
    '    End While
    '    r.Close()
    'End Sub
End Class

