Imports Microsoft.VisualBasic

Public Class LinkGenerator

    Private Sub New()
    End Sub

    Public Enum PageType
        MarketHome
        BusinessHome
        Terms
        About
        Capabilities
        History
        General
        Passthrough
        Search
        Product
    End Enum

    'Public Shared Function BuildUrlPageLink(ByVal pageId As Integer) As String
    '    Dim dtRewritePaths As DataTable = TryCast(HttpContext.Current.Cache("URL_REWRITE"), DataTable)
    '    Dim dvPaths As DataView = dtRewritePaths.DefaultView
    '    dvPaths.RowFilter = "PageId= " + pageId.ToString
    '    Dim targetUrl As String = dvPaths(0)("UrlFriendlyName").ToString
    '    Return "~/" + targetUrl
    'End Function

    Public Shared Function BuildCommonPageLink(ByVal targetPageId As Integer) As String
        Dim dtRewritePaths As DataTable = TryCast(HttpContext.Current.Cache("URL_REWRITE"), DataTable)
        If dtRewritePaths Is Nothing Then
            Dim rewriteValidator As New UrlRewriteValidator
            dtRewritePaths = rewriteValidator.LoadUrlRewritePaths
        End If

        Dim dvPaths As DataView = dtRewritePaths.DefaultView
        dvPaths.RowFilter = "PageId=" + targetPageId.ToString
        Dim targetUrl As String
        If dvPaths.Count > 0 Then
            targetUrl = dvPaths(0)("UrlFriendlyName").ToString
        Else
            targetUrl = String.Empty
        End If

        'Return "~/" + targetUrl
        Return targetUrl
    End Function

    Public Shared Function BuildTopNavMenuLinks(ByVal busUnitId As Integer, ByVal marketId As Integer) As String
        Dim targetUrl As String = String.Empty
        Dim pageType As String = "MARKET HOME"
        If marketId = 0 Then
            pageType = "BUSINESS HOME"
        End If

        Dim dtRewritePaths As DataTable = TryCast(HttpContext.Current.Cache("URL_REWRITE"), DataTable)
        If dtRewritePaths Is Nothing Then
            Dim rewriteValidator As New UrlRewriteValidator
            dtRewritePaths = rewriteValidator.LoadUrlRewritePaths
        End If

        Dim dvPaths As DataView = dtRewritePaths.DefaultView
        dvPaths.RowFilter = "BusinessUnitID=" + busUnitId.ToString + " AND MarketID=" + marketId.ToString + " AND PageType='" + pageType + "'"
        If dvPaths.Count > 0 Then
            targetUrl = dvPaths(0)("UrlFriendlyName").ToString
        Else
            targetUrl = String.Empty
        End If
        'Return "~/" + targetUrl
        Return targetUrl
    End Function

    Public Shared Function BuildCommonPageLink(ByVal busUnitId As Integer, ByVal targetPageType As PageType) As String

        Dim targetUrl As String = String.Empty
        Dim pageType As String = "GENERAL CONTENT"
        Select Case targetPageType
            Case LinkGenerator.PageType.GENERAL : pageType = "GENERAL CONTENT"
            Case LinkGenerator.PageType.BusinessHome : pageType = "BUSINESS HOME"
            Case LinkGenerator.PageType.ABOUT : pageType = "GENERAL CONTENT > ABOUT"
            Case LinkGenerator.PageType.CAPABILITIES : pageType = "GENERAL CONTENT > CAPABILITIES"
            Case LinkGenerator.PageType.HISTORY : pageType = "GENERAL CONTENT > HISTORY"
            Case LinkGenerator.PageType.TERMS : pageType = "GENERAL CONTENT > TERMS"
            Case LinkGenerator.PageType.SEARCH : pageType = "SEARCH"
            Case LinkGenerator.PageType.MarketHome : pageType = "MARKET HOME"
            Case LinkGenerator.PageType.PASSTHROUGH : pageType = "PASSTHROUGH"
        End Select
        Dim dtRewritePaths As DataTable = TryCast(HttpContext.Current.Cache("URL_REWRITE"), DataTable)
        If dtRewritePaths Is Nothing Then
            Dim rewriteValidator As New UrlRewriteValidator
            dtRewritePaths = rewriteValidator.LoadUrlRewritePaths
        End If

        If dtRewritePaths IsNot Nothing Then
            Dim dvPaths As DataView = dtRewritePaths.DefaultView
            'Terms & Conditions page is a Petroferm page (not specific to each BU)
            If targetPageType <> LinkGenerator.PageType.TERMS Then
                Select Case targetPageType
                    Case LinkGenerator.PageType.ABOUT, LinkGenerator.PageType.BusinessHome, LinkGenerator.PageType.CAPABILITIES, LinkGenerator.PageType.HISTORY
                        dvPaths.RowFilter = "PageType = '" + pageType + "' and BusinessUnitID = " + busUnitId.ToString
                        targetUrl = dvPaths(0)("UrlFriendlyName").ToString
                    Case Else
                        targetUrl = String.Empty
                End Select
            Else
                dvPaths.RowFilter = "PageType = '" + pageType + "'"
                If dvPaths.Count > 0 Then
                    targetUrl = dvPaths(0)("UrlFriendlyName").ToString
                Else
                    targetUrl = String.Empty
                End If
            End If
        End If

        'Return "~/" + targetUrl
        Return targetUrl

    End Function

    Public Shared Function BuildCommonPageLink(ByVal busUnitId As Integer, ByVal targetPageType As PageType, ByVal referringPage As Integer) As String

        If referringPage > 0 Then
            Return LinkGenerator.BuildCommonPageLink(busUnitId, targetPageType) & "?ref=" + busUnitId.ToString + "," + referringPage.ToString
        Else
            Return LinkGenerator.BuildCommonPageLink(busUnitId, targetPageType)
        End If

    End Function



    Public Shared Function BuildHomePageFriendlyPageLink(ByVal busUnitId As Integer) As String
        Dim dtRewritePaths As DataTable = TryCast(HttpContext.Current.Cache("URL_REWRITE"), DataTable)
        If dtRewritePaths Is Nothing Then
            Dim rewriteValidator As New UrlRewriteValidator
            dtRewritePaths = rewriteValidator.LoadUrlRewritePaths
        End If

        Dim dvPaths As DataView = dtRewritePaths.DefaultView
        dvPaths.RowFilter = "PageType = 'BUSINESS HOME' and BusinessUnitID = " + busUnitId.ToString
        If dvPaths.Count > 0 Then
            Dim homePage As String = dvPaths(0)("UrlFriendlyName").ToString
            'Return "~/" + homePage
            Return homePage
        Else
            Return String.Empty
        End If
    End Function
    ''' <summary>
    ''' Gets the friendly url from the domain
    ''' </summary>
    ''' <param name="domain"></param>
    ''' <returns></returns>
    ''' <remarks>Kelly Roe    (12/27/2006)  Created function</remarks>
    Public Shared Function GetFriendlyUrlFromDomain(ByVal domain As String) As String
        Dim data As New DataAccess(SiteProfile.GetConnectionString, DataAccess.DataProvider.SQL)
        Dim dict As New System.Collections.Specialized.HybridDictionary
        Dim iParmDomain As IDbDataParameter = data.GetParameter(DataAccess.DataProvider.SQL, "@DomainName", DbType.String, domain, 200, ParameterDirection.Input)
        Dim iParmFriendlyUrl As IDbDataParameter = data.GetParameter(DataAccess.DataProvider.SQL, "@UrlFriendlyName", DbType.String, String.Empty, 500, ParameterDirection.Output)

        Dim iCmd As IDbCommand = data.GetCommand("sp__GetFriendlyUrlByDomain", CommandType.StoredProcedure, DataAccess.DataProvider.SQL)

        With iCmd.Parameters
            .Add(iParmDomain)
            .Add(iParmFriendlyURL)
        End With

        dict.Add(dict.Count, iCmd)

        If data.ExecuteNonQuery(dict) Then
            Return Services.GetNULLableString(iParmFriendlyURL.Value)
        Else
            Return String.Empty
        End If
    End Function

End Class
