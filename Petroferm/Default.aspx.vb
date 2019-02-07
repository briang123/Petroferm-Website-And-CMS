Partial Class [Default]
    Inherits System.Web.UI.Page

    Protected Sub Page_Load(ByVal sender As Object, ByVal e As System.EventArgs) Handles Me.Load



        ' also check for bu= query string...if it's not there just go to Petroferm Home
        Dim busUnitId As Integer
        If Request.QueryString("bu") IsNot Nothing Then
            If IsNumeric(Request.QueryString("bu").ToString) Then
                busUnitID = Convert.ToInt32(Request.QueryString("bu").ToString)
            Else
                busUnitID = 1
            End If
        Else

            'domain sniffer - 12/27/2006 kr - task #54
            Dim redirectUrl As String
            redirectURL = LinkGenerator.GetFriendlyURLFromDomain(Request.Url.Host)
            If redirectURL <> String.Empty Then
                Response.Redirect(redirectURL)
            Else

                ' go to petroferm home
                busUnitID = 1
            End If

        End If
        Response.Redirect(LinkGenerator.BuildHomePageFriendlyPageLink(busUnitID))
    End Sub
End Class
