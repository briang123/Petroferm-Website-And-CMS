#Region " IMPORTS "
Imports System.Configuration.ConfigurationManager
#End Region

#Region " CLASS COMMENTS "



#End Region

Public Class ErrorLogger
    Implements IErrorLogger

#Region " CLASS MEMBERS "



#End Region

#Region " PROPERTIES "



#End Region

#Region " CONSTRUCTORS "



#End Region

#Region " METHODS "



#End Region

#Region " EVENTS "



#End Region

End Class


' This class extends the base Exception class with a static method (callable 
' also without creating and throwing an instance of this exception class) to 
' log the contents of  the exception to a file.

' Notes:
' A custom key named ErrorLogFile must be added to the <appSettings> section,
'  within the <configuration> section, to specify the path of the log file,
'  as follows:
'    <appSettings>
'       <add key="ErrorLogFile" value="~/ErrorLog.txt" />
'    </appSettings>

' Usage: Throw New WebModules.AppException("This error message will be saved to 
' file")

'Imports System
'Imports System.Web
'Imports System.Diagnostics

'Namespace WebModules

'    ' Default exception to be thrown by the website, it will automatically
'    ' log the contents of  the exception to a file.
'    ' ---
'    Public Class AppException
'        Inherits System.Exception

'        ' Constructors
'        '- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

'        Public Sub New()
'            LogError("An unexpected error occurred.")
'        End Sub

'        Public Sub New(ByVal message As String)
'            LogError(message)
'        End Sub

'        Public Sub New(ByVal message As String, ByVal innerException As Exception)

'            LogError(message)

'            If Not (innerException Is Nothing) Then
'                LogError(innerException.Message.ToString)
'            End If

'        End Sub

'        ' Shared Methods
'        '- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

'        Public Shared Sub LogError(ByVal message As String)

'            ' Get the current HTTPContext
'            Dim context As HttpContext = HttpContext.Current

'            ' Get location of ErrorLogFile from Web.config file
'            Dim filePath As String = context.Server.MapPath(CStr _
'                (System.Configuration.ConfigurationSettings.AppSettings( _
'                "ErrorLogFile")))

'            ' Calculate GMT offset
'            Dim gmtOffset As Integer = DateTime.Compare(DateTime.Now, DateTime.UtcNow)

'            Dim gmtPrefix As String
'            If gmtOffset > 0 Then
'                gmtPrefix = "+"
'            Else
'                gmtPrefix = ""
'            End If

'            ' Create DateTime string
'            Dim errorDateTime As String = DateTime.Now.Year.ToString & "." & _
'                DateTime.Now.Month.ToString & "." & DateTime.Now.Day.ToString & " @ " _
'                & DateTime.Now.Hour.ToString & ":" & DateTime.Now.Minute.ToString & _
'                ":" & DateTime.Now.Second.ToString & " (GMT " & gmtPrefix & _
'                gmtOffset.ToString & ")"

'            ' Write message to error file
'            Try
'                Dim sw As New System.IO.StreamWriter(filePath, True)
'                sw.WriteLine("## " & errorDateTime & " ## " & message & " ##")
'                'sw.WriteLine(message)
'                'sw.WriteLine()
'                sw.Close()
'            Catch
'                ' If error writing to file, simply continue
'            End Try
'        End Sub
'    End Class
'End Namespace

' This code is taken from Marco Bellinaso's and Kevin Hoffman's "ASP.NET 
' Website Programming - VB.NET edition" (Wrox Press). You can read two entire 
' sample chapters of the C# edition from our Book Bank:
' Chapter 4: Mantaining the site: http://www.vb2themax.com/Htmldoc.asp?File=/
' Books/AspnetWebsite/AspNetWebSite_04.htm
' Chapter 11: Deploying the Site: http://www.vb2themax.com/HtmlDoc.asp?Table=
' Books&ID=7800