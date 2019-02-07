Public Class RewriteUrl
    Implements System.Web.IHttpModule

    Public Sub Init(ByVal appl As System.Web.HttpApplication) Implements IHttpModule.Init
        AddHandler Appl.BeginRequest, AddressOf RewriteURL_BeginRequest
    End Sub

    Public Sub RewriteURL_BeginRequest(ByVal sender As Object, ByVal args As System.EventArgs)

        'cast the sender to an HttpApplication object
        Dim appl As System.Web.HttpApplication = DirectCast(sender, System.Web.HttpApplication)

        Dim incomingUrl As String = Appl.Request.Path.ToLower
        Dim path() As String = incomingUrl.Split("/" & Appl.Request.ServerVariables("PATH_INFO") & "/")
        incomingUrl = path(path.GetUpperBound(0)) 'strip the filename

        Dim dtRewritePaths As DataTable = TryCast(HttpContext.Current.Cache("URL_REWRITE"), DataTable)
        If dtRewritePaths Is Nothing Then
            Dim rewriteValidator As New UrlRewriteValidator
            dtRewritePaths = rewriteValidator.LoadUrlRewritePaths
        End If

        If dtRewritePaths IsNot Nothing Then
            Dim rewriteValidator As New UrlRewriteValidator
            Dim destinationUrl As String = rewriteValidator.GetDestinationUrl(incomingUrl, dtRewritePaths, Appl)

            If destinationUrl.Length > 0 Then
                Appl.Context.RewritePath(destinationUrl)
            End If
        End If

    End Sub

    Public Sub Dispose() Implements IHttpModule.Dispose
    End Sub

End Class
