Imports data
Imports System.Data
Imports System.Web.Mail
Imports System.Net.Mail.SmtpClient
Imports System.Configuration.ConfigurationManager
Public Class NltErrorLogger

#Region " METHODS "

    Public Sub Log(ByVal exToLog As NLTException)
        Try
            'Dim logEx As NLTException = CType(exToLog.InnerException, NLTException)
            LogToDB(exToLog)
            ' LogToEmail(exToLog)
        Catch ex As Exception

        End Try
    End Sub
    Private Function LogToDb(ByVal ex As NLTException) As Boolean
        Dim success As Boolean
        Dim iCmd As IDbCommand
        Dim iParmId As IDbDataParameter
        Dim errorId As Integer

        Dim data As New DataAccess(SiteProfile.GetConnectionString, DataAccess.DataProvider.SQL)
        Dim dict As New System.Collections.Specialized.HybridDictionary
        Dim strStoredProc As String

        strStoredProc = "sp__LogError"
        iParmID = data.GetParameter(DataAccess.DataProvider.SQL, "@ErrorID", DbType.Int32, errorID, 4, ParameterDirection.Output)

        '@SourceFileName 	varchar(255) = null,
        '@SourceMethodName 	varchar(255) = null,
        '@Message		text = null,
        '@StackTrace		text = null,
        '@Source			text = null,
        '@UserName 		varchar(100) = null,
        Dim iParmSourceFileName As IDbDataParameter = data.GetParameter(DataAccess.DataProvider.SQL, "@SourceFileName", DbType.String, Services.GetNULLableString(ex.SourceFileName), 255, ParameterDirection.Input)
        Dim iParmSourceMethodName As IDbDataParameter = data.GetParameter(DataAccess.DataProvider.SQL, "@SourceMethodName", DbType.String, Services.GetNULLableString(ex.SourceMethodName), 255, ParameterDirection.Input)
        Dim iParmMessage As IDbDataParameter = data.GetParameter(DataAccess.DataProvider.SQL, "@Message", DbType.String, Services.GetNULLableString(ex.Message), Services.GetNULLableString(ex.Message).Length, ParameterDirection.Input)
        Dim iParmStackTrace As IDbDataParameter = data.GetParameter(DataAccess.DataProvider.SQL, "@StackTrace", DbType.String, Services.GetNULLableString(ex.StackTrace), Services.GetNULLableString(ex.StackTrace).Length, ParameterDirection.Input)
        Dim iParmSource As IDbDataParameter = data.GetParameter(DataAccess.DataProvider.SQL, "@Source", DbType.String, Services.GetNULLableString(ex.Source), Services.GetNULLableString(ex.Source).Length, ParameterDirection.Input)
        Dim iParmUserName As IDbDataParameter = data.GetParameter(DataAccess.DataProvider.SQL, "@UserName", DbType.String, My.User.Name, 100, ParameterDirection.Input)

        ' create cmd and add parms
        iCmd = data.GetCommand(strStoredProc, CommandType.StoredProcedure, DataAccess.DataProvider.SQL)
        With iCmd.Parameters
            .Add(iParmID)
            .Add(iParmSourceFileName)
            .Add(iParmSourceMethodName)
            .Add(iParmMessage)
            .Add(iParmStackTrace)
            .Add(iParmSource)
            .Add(iParmUserName)
        End With

        dict.Add(dict.Count, iCmd)

        Try
            success = data.ExecuteNonQuery(dict)
            Return success
        Catch exIgnore As Exception
            ' just ignore
        Finally
            If iCmd.Connection.State <> ConnectionState.Closed Then
                iCmd.Connection.Close()
            End If
        End Try


    End Function
    Private Function LogToFile(ByVal ex As NLTException) As Boolean

        '        Try
        '            '----------------------------------------------
        '            ' We check to see if we have file logging
        '            ' turned on. If so, then proceed
        '            '----------------------------------------------
        '            If CType(ConfigurationSettings.AppSettings("DO_FILE_LOGGING"), Boolean) Then

        '                Dim logger As New ErrorLogging(inner.Message, inner)

        '                '-------------------------------------
        '                ' set properties from web.config file
        '                '-------------------------------------
        '                With logger
        '                    .LogFileExt = ConfigurationSettings.AppSettings("LOG_FILE_EXTENSION")
        '                    .LogFileInterval = CType(ConfigurationSettings.AppSettings("DEFAULT_NEW_FILE_INTERVAL"), Integer)
        '#If DEBUG Then
        '                    .LogPath = ConfigurationSettings.AppSettings("DEBUG_LOGGING_DIRECTORY")
        '#Else
        '                    .LogPath = ConfigurationSettings.AppSettings("LOGGING_DIRECTORY")
        '#End If
        '                    .AppName = ConfigurationSettings.AppSettings("APP_NAME")
        '                    Return .WriteToAppFileLog()
        '                End With
        '            Else
        '                Return True
        '            End If
        '        Catch ex As Exception
        '            Throw New Exception(ex.Message)
        '        End Try




    End Function
    'Private Sub LogToEmail(ByVal ex As NLTException)
    '    Dim subject As String
    '    Dim messageBody As New System.Text.StringBuilder
    '    Dim configSmtp As New Config("SMTP_SERVER")
    '    Dim email As New MailMessage

    '    configSmtp.Fill()

    '    subject = "CCMEAP Website Error"
    '    With messageBody
    '        .Append("<table cellpadding=""2"" cellspacing=""0"" border=""0"" bordercolor=""silver"">")
    '        .AppendFormat("<tr><th>Error Date/Time</th><td>{0}</td></tr>", Today.Now)
    '        .AppendFormat("<tr><th>File Name</th><td>{0}</td></tr>", ex.SourceFileName)
    '        .AppendFormat("<tr><th>Method</th><td>{0}</td></tr>", ex.SourceMethodName)
    '        .AppendFormat("<tr><th>Message</th><td>{0}</td></tr>", ex.Message)
    '        .AppendFormat("<tr><th>Stack Trace</th><td>{0}</td></tr>", ex.StackTrace)
    '        .AppendFormat("<tr><th>Source</th><td>{0}</td></tr>", ex.Source)
    '        .AppendFormat("<tr><th>User ID</th><td>{0}</td></tr>", ex.UserID)
    '        .Append("</table>")
    '    End With

    '    With email
    '        .Subject = subject
    '        .Body = messageBody.ToString
    '        .From = "CCMEAP <website@ccmeap.com>"
    '        .To = ConfigurationSettings.AppSettings("ERROR_LOG_EMAIL")
    '        .BodyFormat = MailFormat.Html
    '        SmtpMail.SmtpServer = configSmtp.ConfigValue
    '        SmtpMail.Send(email)
    '    End With

    'End Sub
#End Region

End Class
