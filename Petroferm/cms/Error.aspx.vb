
Partial Class CmsError
    Inherits System.Web.UI.Page

    Protected Sub Page_Load(ByVal sender As Object, ByVal e As System.EventArgs) Handles Me.Load
        Dim friendlyErrMessage As String = ""
        'TODO: CMS - Error Handling - Maybe use trycast to fix the issue of problems casting to NLT Exception?
        'Dim lastException As NLTException = CType(Server.GetLastError().InnerException, NLTException)
        Dim lastException As Exception = Server.GetLastError()

        Me.Master.PageTitle = "Error Occurred"

        If Not lastException Is Nothing Then
            friendlyErrMessage &= lastException.Message
            ' show friendly message
            Me.lblFriendlyMessage.Text = friendlyErrMessage
            ' show exception details
            Me.lblExceptionDetails.Text = lastException.ToString
        Else
            Me.lblFriendlyMessage.Text = "An error occurred."
            Me.lblExceptionDetails.Text = Server.GetLastError().ToString()
        End If
        Server.ClearError()
    End Sub
End Class
