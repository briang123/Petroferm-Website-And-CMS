Imports Microsoft.VisualBasic

Public Class UrlRewriteValidator

    Public Sub New()
    End Sub

    Public Function LoadUrlRewritePaths() As DataTable

        Dim sqlDependency As SqlCacheDependency = Nothing
        Dim data As New DataAccess(SiteProfile.GetConnectionString, DataAccess.DataProvider.SQL)
        Dim iCon As IDbConnection = data.GetConnection(SiteProfile.GetConnectionString, DataAccess.DataProvider.SQL)
        Dim iCmd As IDbCommand = data.GetCommand("sp__GetUrlRewritePath", CommandType.StoredProcedure, DataAccess.DataProvider.SQL)
        Dim dtRewritePaths As DataTable = data.GetDataTable(iCmd)
        Try
            sqlDependency = New SqlCacheDependency("Petroferm", "tblUrlRewrite_LIVE")
        Catch exDbNot As DatabaseNotEnabledForNotificationException
            Try
                SqlCacheDependencyAdmin.EnableNotifications("Petroferm")
            Catch exPerm As UnauthorizedAccessException
                'TODO: Redirect to a generic error page (to be created)
                'HttpContext.Current.Response.Redirect(".\error.asp")
            End Try
        Catch exTableNot As TableNotEnabledForNotificationException
            Try
                SqlCacheDependencyAdmin.EnableTableForNotifications(SiteProfile.GetConnectionString, "tblUrlRewrite_LIVE")
            Catch ex As SqlClient.SqlException
                'TODO: Redirect to a generic error page (to be created)
                'HttpContext.Current.Response.Redirect(".\error.asp")
            End Try
        Finally
            'add an expiration to the cache should there be a change made in the database
            HttpContext.Current.Cache.Insert("URL_REWRITE", dtRewritePaths, sqlDependency, DateTime.Now.AddDays(1), Cache.NoSlidingExpiration)
        End Try

        Return dtRewritePaths

    End Function

    Public Function GetDestinationUrl(ByVal incomingUrl As String, ByVal dt As DataTable, ByRef appl As System.Web.HttpApplication) As String

        Dim appPath As String = Appl.Request.ApplicationPath
        Dim newUrl As String = String.Empty

        For Each dbPath As DataRow In dt.Rows
            Dim rewriteUrl As String = Services.GetNULLableString(dbPath("UrlFriendlyName"))

            If incomingUrl = rewriteUrl Then
                Dim destinationUrl As String = String.Empty
                Dim busId As Integer = Services.GetNULLableInteger(dbPath("BusinessUnitId"))
                Dim mktId As Integer = Services.GetNULLableInteger(dbPath("MarketID"))
                Dim pageId As Integer = Services.GetNULLableInteger(dbPath("PageID"))
                Dim prodCatId As Integer = Services.GetNULLableInteger(dbPath("PC_ProdCatID"))

                Dim passthroughPage As String = Services.GetNULLableString(dbPath("PAGE_PassthroughURL"))
                Dim isPetrofermHomePage As Boolean = (Services.GetNULLableInteger(dbPath("PageId")) = 1)
                Dim isBusinessHomePage As Boolean = (Services.GetNULLableString(dbPath("PageType")).ToUpper = "BUSINESS HOME")
                Dim isMarketHomePage As Boolean = (Services.GetNULLableString(dbPath("PageType")).ToUpper = "MARKET HOME")
                Dim isGeneralPage As Boolean = (Services.GetNULLableString(dbPath("PageType")).ToUpper.StartsWith("GENERAL") = True)
                Dim isProductPage As Boolean = (Services.GetNULLableString(dbPath("PageType")).ToUpper.StartsWith("PRODUCT") = True)
                Dim isPassthroughPage As Boolean = (Services.GetNULLableString(dbPath("PageType")).ToUpper = "PASSTHROUGH")
                Dim isDocumentPage As Boolean = (Services.GetNULLableString(dbPath("PageType")).ToUpper = "DOCUMENT")

                Dim queryParms As String = "?bu=" + busId.ToString + "&mkt=" + mktId.ToString + "&pageID=" + pageId.ToString + "&pcat=" + prodCatId.ToString
                Select Case True
                    Case IsDocumentPage
                        destinationUrl = "~/GetFile.aspx?file=" + Services.GetNULLableString(Appl.Request.QueryString("file"))
                    Case IsPetrofermHomePage, IsBusinessHomePage
                        destinationUrl = "~/Business.aspx" + queryParms
                    Case IsMarketHomePage
                        destinationUrl = "~/Market.aspx" + queryParms
                    Case IsGeneralPage
                        If incomingUrl.StartsWith("~/") = False Then
                            destinationUrl = destinationUrl + "~/"
                        Else
                            destinationUrl = ""
                        End If

                        If pageId > 0 Then
                            destinationUrl = "~/General.aspx" + queryParms
                        Else
                            destinationUrl = "~/Default.aspx"
                        End If
                    Case IsProductPage
                        destinationUrl = "~/General.aspx" + queryParms
                    Case IsPassthroughPage
                        If passthroughPage.StartsWith("~/") = False Then
                            destinationUrl = destinationUrl + "~/"
                        Else
                            destinationUrl = ""
                        End If

                        If passthroughPage.Contains("?") Then
                            destinationUrl = destinationUrl + passthroughPage + "&mkt=" + mktId.ToString + "&pageID=" + pageId.ToString + "&pcat=" + prodCatId.ToString
                        Else
                            destinationUrl = destinationUrl + passthroughPage + "?mkt=" + mktId.ToString + "&pageID=" + pageId.ToString + "&pcat=" + prodCatId.ToString
                        End If

                        ' also add ref= stuff so that the look and feel of page is retained
                        ' 12/24/06 - task #51 - kr
                        destinationUrl &= "&ref=" & busId.ToString & "," & mktId.ToString & "," & pageId.ToString

                    Case Else
                        'destinationUrl = "~/404.htm"
                End Select

                newUrl = destinationUrl.Replace("~", appPath.ToLower)
                Exit For
            End If
        Next

        Return newUrl

    End Function

End Class
