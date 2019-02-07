Imports System.Text
Imports System.Text.RegularExpressions
Imports System.Net.Mail

Public Class EMail

    Private _mToEmail As String = String.Empty
    Private _mFromEmail As String = String.Empty
    Private _mCcEmail As String = String.Empty
    Private _mBccEmail As String = String.Empty
    Private _mSubject As String = String.Empty
    Private _mBody As String = String.Empty
    Private _mRecipientName As String = String.Empty
    Private _mPriority As System.Net.Mail.MailPriority = MailPriority.Normal
    Private _mSmtpServer As String

    Public Sub New()
    End Sub

    WriteOnly Property ToEmail() As String
        Set(ByVal value As String)
            _mToEmail = Value.Trim.Replace(",", ";")
        End Set
    End Property

    WriteOnly Property FromEmail() As String
        Set(ByVal value As String)
            _mFromEmail = Value.Trim
        End Set
    End Property

    WriteOnly Property CcEmail() As String
        Set(ByVal value As String)
            _mCcEmail = Value.Trim.Replace(",", ";")
        End Set
    End Property

    WriteOnly Property BccEmail() As String
        Set(ByVal value As String)
            _mBccEmail = Value.Trim.Replace(",", ";")
        End Set
    End Property

    WriteOnly Property Subject() As String
        Set(ByVal value As String)
            _mSubject = Value.Trim
        End Set
    End Property

    WriteOnly Property Body() As String
        Set(ByVal value As String)
            _mBody = Value.Trim
        End Set
    End Property

    WriteOnly Property RecipientName() As String
        Set(ByVal value As String)
            _mRecipientName = Value.Trim
        End Set
    End Property

    WriteOnly Property Priority() As MailPriority
        Set(ByVal value As MailPriority)
            _mPriority = Value
        End Set
    End Property

    ReadOnly Property SmtpServer() As String
        Get
            Return SiteProfile.GetSmtpServer()
        End Get
    End Property

    Public Sub Send()

        Dim mail As New System.Net.Mail.SmtpClient
        Dim message As New System.Net.Mail.MailMessage
        mail.Host = SiteProfile.GetSmtpServer()

        Try
            mail.Send(_mFromEmail, _mToEmail, _mSubject, _mBody)
        Catch frex As System.Net.Mail.SmtpFailedRecipientException
            Throw New NLTException("An error occurred. The recipient could not be reached.", frex, "Email.vb", "Sub Send()")
        Catch mex As System.Net.Mail.SmtpException
            Throw New NLTException("An error occurred while trying to send an email.", mex, "Email.vb", "Sub Send()")
        Catch ex As Exception
            Throw New NLTException("An unexpected error occurred while trying to send an email.", ex, "Email.vb", "Sub Send()")
        Finally
            mail = Nothing
        End Try

    End Sub

    Private Function IsValidEmail(ByVal email As String) As Boolean
        Dim expr As String = "^([a-zA-Z0-9_\-\.]+)@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.)|(([a-zA-Z0-9\-]+\.)+))([a-zA-Z]{2,4}|[0-9]{1,3})(\]?)$"
        Dim re As Regex = New Regex(expr)
        If re.IsMatch(email) Then
            Return True
        Else
            Return False
        End If
    End Function

End Class

