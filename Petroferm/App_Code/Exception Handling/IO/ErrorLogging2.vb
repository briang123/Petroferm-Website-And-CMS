#Region " IMPORTS "
Imports System
Imports System.Data
'Imports System.Data.OracleClient
Imports System.Data.OleDb
Imports System.Configuration
Imports System.Collections
Imports System.IO
Imports System.Text
Imports System.ComponentModel
Imports System.Net
Imports System.Diagnostics
#End Region

#Region " CLASS COMMENTS "

' CLASS NAME:   ErrorLogging
' CREATED BY:   Brian Gaines
' UPDATE  BY:   Dave Metzger (July 2004) to C# and work with NFA.NET.Web
'               This class can now be used from multiple projects.  Also added some
'			    additional features within the database and application logging such
'			    as custom populating the additional text fields.  This allows each
'			    application to insert custom information.

'			    To use this class, set it up as such...

'			    Dim error As New ErrorLogging(<sourceException>)
'               error.AppName = "<your app name here>"
'				error.LogFileExt = "<log file extension...ex. LOG>"
'				error.LogFileInterval = <# of days between new log files - enter 0 for only 1 log file>
'				error.LogPath = "<path of log files... should be D:\LOGS"

'               Then use Try blocks to attempt to write the error to the
'			    database, and then the file system using...

'			    error.WriteToAppDbLog("<Oracle connection string>","<app-specific info>","<app-specific info type>")
'				error.WriteToAppFileLog("<app-specific info>","<app-specific info type>")

' PURPOSE:
'   Writes exceptions to a log file in a specified directory.

' CUSTOM FEATURES:

'   << LogFileInterval >>
'   User can set the interval for when a new log file should
'   be created, so for instance, if a log file should be 
'   created every week (starting today), then the LogFileInterval
'   property should be set to 7; for a month, we might set the 
'   property to 30; to create a log file each day, then the
'   setting will be 1. If we only want to have (1) one log file
'   then we set the property to 0.
'--------------------------------------------------------------

#End Region

Public Class ErrorLogging2

#Region " PRIVATE MEMBERS "
    Private _mLogErrorProcedure As String
    Private _mEx As Exception
    Private _mMessage As String = ""
    Private _mFileDuration As Integer
    Private _mAppName As String = ""
    Private _mLogPath As String = ""
    Private _mLogFileExt As String = ""
    Const NullExceptionMessage As String = "A NULL value is not an acceptable parameter for the ? property"
#End Region

#Region " ENUMS "
    Public Enum AdditionalErrorInfoTypes
        DbSave
        DbDelete
        DbSelect
        ObjCreate
        MiscError
        PageEvent
    End Enum

    Public Enum CompareByOptions
        FileName
        FileCreationTime
        LastAccessTime
        LastWriteTime
        Length
    End Enum
#End Region

#Region " CONSTRUCTORS "
    Private Sub New()
    End Sub

    Public Sub New(ByVal inner As Exception)
        _mEx = inner
    End Sub

    Public Sub New(ByVal message As String, ByVal inner As Exception)
        _mEx = inner
        _mMessage = message
    End Sub
#End Region

#Region " PROPERTIES "
    Public WriteOnly Property LogErrorPkgProc() As String
        Set(ByVal value As String)
            _mLogErrorProcedure = Value
        End Set
    End Property

    '/*--------------------------------------------
    ' Write-Only property to set the interval
    ' of time (in days), for when a new log
    ' file should be created. If 0, then only
    ' 1 file will be created for all exceptions
    '--------------------------------------------*/
    Public WriteOnly Property LogFileInterval() As Integer
        Set(ByVal value As Integer)
            Try
                If (Value < 0) Then
                    _mFileDuration = 0
                Else
                    _mFileDuration = Value
                End If
            Catch ane As ArgumentNullException
                Throw New Exception(NullExceptionMessage.Replace("?", "LogFileInterval"), ane)
            End Try
        End Set
    End Property

    '/*--------------------------------------------
    ' Write-Only property to set the application
    ' name, which will be used as part of the 
    ' log file name.
    '--------------------------------------------*/
    Public WriteOnly Property AppName() As String
        Set(ByVal value As String)
            Try
                _mAppName = Value.ToUpper()
            Catch ane As ArgumentNullException
                Throw New ArgumentNullException(NullExceptionMessage.Replace("?", ane.InnerException.TargetSite.ToString()))
            End Try
        End Set
    End Property

    '/*--------------------------------------------
    ' Write-Only property to set the location
    ' of the log file.
    '--------------------------------------------*/
    Public WriteOnly Property LogPath() As String
        Set(ByVal value As String)
            Try
                If (Value.EndsWith("\\")) Then
                    _mLogPath = Value.Substring(0, Value.Length - 1)
                Else
                    _mLogPath = Value
                End If
            Catch ane As ArgumentNullException
                Throw New ArgumentNullException(NullExceptionMessage.Replace("?", ane.InnerException.TargetSite.ToString()))
            End Try
        End Set
    End Property

    '/*--------------------------------------------
    ' Write-Only property to set the file
    ' extension used for log files.
    '--------------------------------------------*/
    Public WriteOnly Property LogFileExt() As String
        Set(ByVal value As String)
            Try
                If (Value.Trim().Length <= 4) Then
                    If (Value.Trim().EndsWith(".")) Then
                        _mLogFileExt = Value.Trim().ToLower()
                    Else
                        _mLogFileExt = "." & Value.Trim().ToLower()
                    End If
                Else
                    Throw New ArgumentException("You must specify a valid file extension. The file extension must be less than four characters.")
                End If
            Catch ane As ArgumentNullException
                Throw New ArgumentNullException(NullExceptionMessage.Replace("?", ane.InnerException.TargetSite.ToString()))
            End Try
        End Set
    End Property

#End Region

#Region " PRIVATE METHODS "

    '''-----------------------------------------------------------------------------
    ''' <summary>
    ''' 
    ''' </summary>
    ''' <param name="addlInfoType"></param>
    ''' <returns></returns>
    ''' <remarks></remarks>
    ''' <history>
    ''' 	[nfisbjg] 	9/17/2004	Created
    ''' </history>
    '''-----------------------------------------------------------------------------
    Private Function GetAddlInfoType(ByVal addlInfoType As AdditionalErrorInfoTypes) As String
        Select Case addlInfoType
            Case AdditionalErrorInfoTypes.DbDelete
                Return "DB_DELETE"
            Case AdditionalErrorInfoTypes.DbSave
                Return "DB_SAVE"
            Case AdditionalErrorInfoTypes.DbSelect
                Return "DB_SELECT"
            Case AdditionalErrorInfoTypes.MiscError
                Return "MISC_ERROR"
            Case AdditionalErrorInfoTypes.ObjCreate
                Return "OBJ_CREATE"
            Case AdditionalErrorInfoTypes.PageEvent
                Return "PAGE_EVENT"
            Case Else
                Return ""
        End Select
    End Function

    '/*-------------------------------------------------
    ' Method to get the search condition of a specific
    ' directory. 
    '-------------------------------------------------*/
    Private Function GetFileSearchCondition() As String
        Try
            Return _mAppName & "*" & _mLogFileExt
        Catch ex As Exception
            Throw New Exception("An invalid file search condition was specified.", ex)
        End Try
    End Function

    '/*------------------------------------------------
    '	Returns the directory specified by user input
    '	which will be the storage location of all log
    '	files
    '------------------------------------------------*/
    Private Function GetLogDirectory() As DirectoryInfo
        Try
            If (Directory.Exists(_mLogPath)) Then
                Return New DirectoryInfo(_mLogPath)
            Else
                Directory.CreateDirectory(_mLogPath)
                Return Nothing
            End If
        Catch de As DirectoryNotFoundException
            Throw New Exception("The directory does not exist.", de)
        Catch ex As Exception
            Throw New Exception(ex.Message)
        End Try
    End Function

    '/*----------------------------------------------------------
    ' Builds a new log file name concatenating the appName, 
    ' month, day, year and the file extension. This method
    ' takes an optional parameters for which to return the 
    ' full path to the new file.
    '----------------------------------------------------------*/
    Private Function BuildNewLogFileName() As String
        Return BuildNewLogFileName(True)
    End Function

    Private Function BuildNewLogFileName(ByVal getDir As Boolean) As String
        Try
            Dim nowTime As DateTime = DateTime.Now
            Dim datePart As String = nowTime.Month.ToString() & "_" & nowTime.Day.ToString() & "_" & nowTime.Year.ToString()
            If (getDir) Then
                Return _mLogPath & "\\" & _mAppName & "_" & datePart & _mLogFileExt
            Else
                Return _mAppName & "_" & datePart & _mLogFileExt
            End If
        Catch ex As Exception
            Throw New Exception(ex.Message)
        End Try
    End Function

    '/*----------------------------------------------------------
    '	Method gets the latest log file based on our search
    '	condition (for example: NECS*.log). This method
    '	sorts all files that match our search condition and we
    '	retrieve the latest file. This method accepts an optional
    '	parameter to return the full path to the log file.
    '----------------------------------------------------------*/
    Private Function GetLatestLogFile(ByVal dir As DirectoryInfo) As String
        Return GetLatestLogFile(dir, True)
    End Function

    Private Function GetLatestLogFile(ByVal dir As DirectoryInfo, ByVal getDir As Boolean) As String
        Try
            Dim fileInfoArray() As FileInfo = dir.GetFiles(GetFileSearchCondition())
            Array.Sort(fileInfoArray, New CompareFileInfoEntries(CompareByOptions.LastWriteTime))
            If (getDir) Then
                Return _mLogPath & "\\" & fileInfoArray.GetValue(fileInfoArray.GetUpperBound(0)).ToString()
            Else
                Return fileInfoArray.GetValue(fileInfoArray.GetUpperBound(0)).ToString()
            End If
        Catch de As DirectoryNotFoundException
            Throw New DirectoryNotFoundException("The directory " & dir.ToString() & " does not exist.", de)
        Catch ex As Exception
            Throw New Exception(ex.Message)
        End Try
    End Function

    '/*----------------------------------------------------------
    ' Method checks to see if the log file exists. There are 
    ' conditions that have to be met in order for this to return
    ' the proper boolean value. They are:
    '   If log file interval = 0 (only use 1 log file for app)
    '   then we assume the file exists and we get the latest
    '   file, which is the 1 file created.

    '   If log file interval > 0 (specifies the number of days
    '   to create a new log file) then we check the difference
    '   in days between NOW and the latest file. If the number
    '   of days equals or is greater than the interval, then
    '   we create our new file, otherwise, just get our latest
    '   log file.

    '   (NOTE: Will be met with the first log file created) 
    '   If while looping through the log file directory we 
    '   do not find any files that match our latest file, 
    '   then we build a new file.
    '----------------------------------------------------------*/
    Private Function LogFileExists(ByVal dir As DirectoryInfo) As Boolean
        Try

            Dim searchPattern As String = GetFileSearchCondition()
            Dim fileInfoArray() As FileInfo = dir.GetFiles(searchPattern)
            Dim fi As FileInfo
            For Each fi In fileInfoArray
                Dim diff As System.TimeSpan = DateTime.Now.Subtract(fi.CreationTime)
                If (_mFileDuration > 0) Then
                    Return Not (diff.Days >= _mFileDuration)
                Else
                    Return True
                End If
            Next
            Return False
        Catch de As DirectoryNotFoundException
            Throw New DirectoryNotFoundException("The directory " & dir.ToString() & " does not exist.", de)
        Catch ex As Exception
            Throw New Exception(ex.Message)
        End Try
    End Function

#End Region

#Region " PUBLIC METHODS "

    '/*----------------------------------------------------------
    ' Method writes the exception information into the log
    ' file.
    '----------------------------------------------------------*/
    Public Function WriteToAppFileLog(ByVal addlInfo As String, ByVal addlInfoType As AdditionalErrorInfoTypes) As Boolean
        Return WriteToAppFileLog(addlInfo, addlInfoType, Nothing)
    End Function

    Public Function WriteToAppFileLog(ByVal addlInfo As String, _
                                        ByVal addlInfoType As AdditionalErrorInfoTypes, _
                                            ByVal exception As Exception) As Boolean
        Try
            Dim newFile As Boolean
            Dim dirInfo As DirectoryInfo

            dirInfo = GetLogDirectory()

            Dim fileName As String
            If (LogFileExists(dirInfo)) Then
                fileName = GetLatestLogFile(dirInfo)
            Else
                fileName = BuildNewLogFileName()
                newFile = True
            End If

            Dim sw As StreamWriter = New StreamWriter(fileName, True)
            With sw
                .WriteLine("Source        : " + exception.Source.ToString().Trim())
                .WriteLine("Method        : " + exception.TargetSite.Name.ToString())
                .WriteLine("Date          : " + DateTime.Now.ToShortDateString())
                .WriteLine("Time          : " + DateTime.Now.ToLongTimeString())
                .WriteLine("Computer      : " + Dns.GetHostName().ToString())
                .WriteLine("Addl Info     : " + addlInfo)
                .WriteLine("Info Type     : " + addlInfoType.ToString())
                .WriteLine("Error         : " + exception.Message.ToString().Trim())
                .WriteLine("Stack Trace   : " + exception.StackTrace.ToString().Trim())
                .WriteLine("=======================================================================")
                .Close()
            End With
            sw = Nothing
            Return True

        Catch de As DirectoryNotFoundException
            Throw New DirectoryNotFoundException("The directory does not exist.", de)
        Catch ioe As IOException
            Throw New Exception("An I/O File error occurred while attempting to write to the log file.", ioe)
        Catch ex As Exception
            Throw New Exception(ex.Message)
        End Try
    End Function

    '/*----------------------------------------------------------
    ' Method that executes the stored procedure to update the
    ' application log table in Oracle.
    '----------------------------------------------------------*/
    'Public Function WriteToAppDbLog(ByVal addlInfo As String, _
    '                                ByVal addlInfoType As AdditionalErrorInfoTypes, _
    '                                ByVal serverCheck As ServerCheck) As Boolean

    '    Return WriteToAppDbLog(addlInfo, GetAddlInfoType(addlInfoType), serverCheck)

    'End Function

    'Public Function WriteToAppDbLog(ByVal addlInfo As String, _
    '                                ByVal addlInfoType As String, _
    '                                ByVal serverCheck As ServerCheck) As Boolean

    '    Dim errMessage As String
    '    Dim inner As Exception = m_Ex
    '    Try
    '        errMessage = ""
    '        Do
    '            errMessage += "MESSAGE:" + inner.Message.ToString() + "\r\n"
    '            errMessage += "TRACE:" + inner.StackTrace.ToString() + "\r\n"
    '            inner = inner.InnerException
    '        Loop

    '        While Not (inner Is Nothing)

    '            Dim oraParams(4) As OracleParameter
    '            Dim msg As String = errMessage

    '            If (msg.Length > 4000) Then msg = msg.Substring(0, 4000)
    '            If (addlInfo.Length > 4000) Then addlInfo.Substring(0, 4000)
    '            If (addlInfoType.Length > 10) Then addlInfoType.Substring(0, 10)

    '            oraParams(0) = New OracleParameter("err_number", OracleType.Number, 15, ParameterDirection.Input, False, 0, 0, "err_number", DataRowVersion.Default, 0)
    '            oraParams(1) = New OracleParameter("err_message", OracleType.VarChar, 4000, ParameterDirection.Input, False, 0, 0, "err_message", DataRowVersion.Default, msg)
    '            oraParams(2) = New OracleParameter("module_name", OracleType.VarChar, 255, ParameterDirection.Input, True, 0, 0, "module_name", DataRowVersion.Default, m_Ex.TargetSite.Name.ToString())
    '            oraParams(3) = New OracleParameter("addl_info", OracleType.VarChar, 4000, ParameterDirection.Input, True, 0, 0, "addl_info", DataRowVersion.Default, addlInfo)
    '            oraParams(4) = New OracleParameter("addl_info_type", OracleType.VarChar, 10, ParameterDirection.Input, True, 0, 0, "addl_info_type", DataRowVersion.Default, addlInfoType)

    '            Dim dataAccess As New OracleDataAccess(serverCheck.GetConnectionString)
    '            dataAccess.ExecuteNonQuery(oraParams, m_LogErrorProcedure)
    '            Return True

    '        End While
    '    Catch oex As OracleException
    '        Throw oex
    '    End Try
    'End Function

#End Region

#Region " FILE SEARCH ( INNER CLASS ) "

    Public Class CompareFileInfoEntries : Implements IComparer

        Private _compareBy As CompareByOptions = CompareByOptions.FileName

        Public Sub New(ByVal cBy As CompareByOptions)
            _compareBy = cBy
        End Sub

        Public Overridable Overloads Function Compare(ByVal file1 As Object, ByVal file2 As Object) _
                                                                    As Integer Implements IComparer.Compare

            'Convert file1 and file2 to FileInfo entries
            Dim f1 As FileInfo = CType(file1, FileInfo)
            Dim f2 As FileInfo = CType(file2, FileInfo)

            'Compare the file names
            Select Case _compareBy
                Case CompareByOptions.FileName
                    Return String.Compare(f1.Name, f2.Name)
                Case CompareByOptions.LastWriteTime
                    Return DateTime.Compare(f1.LastWriteTime, f2.LastWriteTime)
                Case CompareByOptions.LastAccessTime
                    Return DateTime.Compare(f1.LastAccessTime, f2.LastAccessTime)
                Case CompareByOptions.FileCreationTime
                    Return DateTime.Compare(f1.CreationTime, f2.CreationTime)
                Case CompareByOptions.Length
                    Return CType(f1.Length - f2.Length, Integer)
            End Select
        End Function

    End Class

#End Region

End Class