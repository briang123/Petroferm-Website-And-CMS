Public MustInherit Class PassthroughBasePage
    Inherits System.Web.UI.Page

    Public IsSearchPage As Boolean = False
    Public CurrentPage As WebPage
    Public StyleObjects As New StringBuilder
    MustOverride Function BuildTopMenu(ByVal currentPage As WebPage) As Control
    Private _refBu As Integer = 0
    Private _refMkt As Integer = 0
    Private _refPage As Integer = 0

    Sub New()
    End Sub

    Public ReadOnly Property CurrentPageId() As Integer
        Get
            Return CType(Request.QueryString("PageId"), Integer)
        End Get
    End Property

    Private Sub Page_LoadComplete(ByVal sender As Object, ByVal e As System.EventArgs) Handles Me.LoadComplete

        'Dim refBU As Integer = 0
        'Dim refMkt As Integer = 0
        'Dim refPage As Integer = 0
        Dim refSearch As String = Services.GetNULLableString(Request.Params("ref"))

        If refSearch.Split(","c).Length = 3 Then
            _refBu = Services.GetNULLableInteger(refSearch.Split(","c).GetValue(0))
            _refMkt = Services.GetNULLableInteger(refSearch.Split(","c).GetValue(1))
            _refPage = Services.GetNULLableInteger(refSearch.Split(","c).GetValue(2))
        End If

        If _refPage = 0 Then     'user got here through an outside link somehow or manually entered the search page url
            _refPage = 1         'use the petroferm homepage context
        End If

        'I change the name of this variable from currentPage like everywhere else because we only care about the business unit type stuff
        currentPage = New WebPage(_refPage, WorkflowItem.LiveMode.Live)

        IsSearchPage = Me.Request.ServerVariables("PATH_INFO").ToString.ToUpper.IndexOf("SEARCH") > -1

    End Sub

#Region " HELPER PAGE FUNCTIONS "

    Public Function BuildMetaTag(ByVal tag As String, ByVal value As String) As HtmlMeta
        Dim meta As New HtmlMeta
        meta.Name = tag
        meta.Content = value
        Return meta
    End Function

    Public Function BuildCopyright() As String
        Return "&copy;&nbsp;Copyright 2004 - " + Today.Year.ToString + ", All rights reserved"
    End Function

    Public Function BuildHtmlImage(ByVal src As String, ByVal altText As String, ByVal width As Integer, ByVal height As Integer, ByVal align As String) As HtmlImage
        Dim genericImage As New HtmlImage
        With GenericImage
            .Src = src
            .Alt = AltText
            .Align = align
            .Border = 0
        End With
        Return GenericImage
    End Function

    Public Function BuildHtmlImage(ByVal image As ImageFile) As HtmlImage
        Dim genericImage As New HtmlImage
        With GenericImage
            .Src = image.ImagePath
            .Alt = image.AltText
            .Align = "left"
            .Border = 0
        End With
        Return GenericImage
    End Function

    Public Function CompressStringForJavaScript(ByVal value As String) As String
        Dim temp As String = value
        Dim chars() As String = {".", ",", " ", "-", "/", "&", "!"}
        For i As Integer = 0 To chars.Length - 1
            temp = temp.Replace(chars.GetValue(i).ToString, "")
        Next
        Return temp
    End Function

    Function GetImageSource(ByVal imageType As String, ByVal welcomeImageId As Integer, ByVal currBusUnit As BusinessUnit) As String

        Dim imagePath As String = String.Empty
        Select Case imageType.ToUpper
            Case "NAVIGATION ON", "NAVIGATION OFF", "NAV ON IMAGE", "NAV OFF IMAGE"
                If currBusUnit.TopMenuNavigationRegion.Count > 0 Then
                    For i As Integer = 0 To currBusUnit.TopMenuNavigationRegion.Count - 1
                        If currBusUnit IsNot Nothing Then
                            Dim imageMod As ImageModule = TryCast(currBusUnit.TopMenuNavigationRegion.Item(i), ImageModule)
                            If imageMod IsNot Nothing Then
                                If imageMod.ImageType = imageType And imageMod.WelcomeImageID = welcomeImageID Then ' imageMod.WelcomeTitle.ToUpper = welcomeTitle.ToUpper Then
                                    imagePath = imageMod.ImageFile.ImagePath
                                    Exit For
                                End If
                            End If
                        End If
                    Next
                End If
            Case "HEADER", "HEADER IMAGE"
                If currBusUnit.HeaderImageRegion.Count > 0 Then
                    'TODO: Need to render a random image (see existing rules)
                    'Dim randCeiling As Integer = currentMarket.HeaderImageRegion.Count
                    'Dim rnd As New Random(1)
                    'Dim randomNum As Integer = rnd.Next(randCeiling)
                    For i As Integer = 1 To currBusUnit.HeaderImageRegion.Count
                        If currBusUnit IsNot Nothing Then
                            Dim imageMod As ImageModule = TryCast(currBusUnit.HeaderImageRegion.Item(i), ImageModule)
                            If imageMod IsNot Nothing Then
                                imagePath = imageMod.ImageFile.ImagePath
                                Exit For
                            End If
                        End If
                    Next
                End If
        End Select

        Return imagePath
    End Function

    Function GetImageSource(ByVal imageType As String, ByVal currentMarket As Market) As String

        Dim imagePath As String = String.Empty
        Select Case ImageType.ToUpper
            Case "NAVIGATION ON", "NAVIGATION OFF", "NAV ON IMAGE", "NAV OFF IMAGE"
                If currentMarket.TopMenuNavigationRegion.Count > 0 Then
                    For i As Integer = 1 To currentMarket.TopMenuNavigationRegion.Count
                        If currentMarket IsNot Nothing Then
                            Dim imageMod As ImageModule = TryCast(currentMarket.TopMenuNavigationRegion.Item(i), ImageModule)
                            If imageMod IsNot Nothing Then
                                If imageMod.ModuleType.ToUpper = ImageType.ToUpper Or imageMod.ImageType.ToUpper = ImageType.ToUpper Then
                                    imagePath = imageMod.ImageFile.ImagePath
                                    Exit For
                                End If
                            End If
                        End If
                    Next
                End If
            Case "HEADER", "HEADER IMAGE"
                If currentMarket.HeaderImageRegion.Count > 0 Then
                    'TODO: Need to render a random image (see existing rules)
                    'Dim randCeiling As Integer = currentMarket.HeaderImageRegion.Count
                    'Dim rnd As New Random(1)
                    'Dim randomNum As Integer = rnd.Next(randCeiling)
                    For i As Integer = 1 To currentMarket.HeaderImageRegion.Count
                        If currentMarket IsNot Nothing Then
                            Dim imageMod As ImageModule = TryCast(currentMarket.HeaderImageRegion.Item(i), ImageModule)
                            If imageMod IsNot Nothing Then
                                imagePath = imageMod.ImageFile.ImagePath
                                Exit For
                            End If
                        End If
                    Next
                End If
        End Select

        Return imagePath
    End Function

    'Public Function BuildTopMenuOfMarkets(ByVal currentPage As WebPage) As Control

    '    Dim ctl As New Control

    '    For i As Integer = 1 To currentPage.BusUnit.Markets.Count
    '        Dim market As Market = TryCast(currentPage.BusUnit.Markets.Item(i), Market)
    '        If market IsNot Nothing Then
    '            Dim imageMod As ImageModule = TryCast(market.TopMenuNavigationRegion.Item(0), ImageModule)
    '            If imageMod IsNot Nothing Then
    '                If imageMod.ImageType.ToUpper = "NAVIGATION OFF" Then

    '                    Dim TopNavImageContainer As New LiteralControl
    '                    Dim DoSelectCurrentMarket As Boolean = False
    '                    Dim NavTopMenuLink As New StringBuilder
    '                    Dim onmouseover As String = String.Empty
    '                    Dim onmouseout As String = String.Empty


    '                    Dim imageOnSrc As String = GetImageSource("NAVIGATION ON", market)
    '                    Dim ImageClientId As String = CompressStringForJavaScript(market.MarketName)
    '                    TopNavImageContainer.Text = "<img src=""" + imageMod.ImageFile.ImagePath + """ name=""" + ImageClientId + """ alt=""" + imageMod.ImageFile.AltText + """ border=""0"">"

    '                    If market.MarketID <> 0 Then
    '                        If market.MarketID <> currentPage.CurrentMarket.MarketID Then
    '                            StyleObjects.Append("#homepage" + ImageClientId + "Welcome {position:absolute;visibility:hidden;z-index:100;top:0px;left:0px;} " + vbCrLf)
    '                            onmouseover = "MM_swapImage('" + ImageClientId + "','','" + imageOnSrc + "',0);toggleWelcomeSections('homepage" + ImageClientId + "Welcome');"
    '                            onmouseout = "MM_swapImgRestore();toggleWelcomeSections('homepage" + ImageClientId + "Welcome');"
    '                        Else
    '                            TopNavImageContainer.Text = "<img src=""" + imageOnSrc + """ name=""" + ImageClientId + """ alt=""" + imageMod.ImageFile.AltText + """ border=""0"">"
    '                        End If
    '                    Else
    '                        onmouseover = "MM_swapImage('" + ImageClientId + "','','" + imageOnSrc + "',0);"
    '                        onmouseout = "MM_swapImgRestore();"
    '                    End If

    '                    NavTopMenuLink.AppendFormat("<a href=""{0}"" onmouseover=""{1}"" onmouseout=""{2}"">{3}</a>{4}", _
    '                            LinkGenerator.BuildTopNavMenuLinks(currentPage.BusUnit.BusUnitID, market.MarketID), _
    '                            onmouseover, onmouseout, TopNavImageContainer.Text, _
    '                            "<img src=""web/files/images/misc/nav_spacer.gif"" alt=""Petroferm Inc."" border=""0"" width=""1"" height=""44"">")

    '                    ctl.Controls.Add(New LiteralControl(NavTopMenuLink.ToString))
    '                End If
    '            End If
    '        End If
    '    Next

    '    Return ctl

    'End Function


    Public Function BuildTopMenuOfMarkets(ByVal currentPage As WebPage, ByVal selectMarket As Boolean) As Control

        Dim ctl As New Control
        Dim tempElement As String = String.Empty

        ' add top menu buttons for passthrough page - bg 12/31/2006
        Select Case True
            Case (_refBu = 1)
                Dim referringPage As New WebPage(_refBu, WorkflowItem.LiveMode.Live)

                ' will grab nav on/nav off image modules in lieu of markets
                For i As Integer = 0 To currentPage.BusUnit.TopMenuNavigationRegion.Count - 1
                    Dim imageMod As ImageModule = TryCast(currentPage.BusUnit.TopMenuNavigationRegion.Item(i), ImageModule)
                    If imageMod IsNot Nothing Then
                        If imageMod.ImageType.ToUpper = "NAVIGATION OFF" Then
                            Dim topNavImageContainer As New LiteralControl
                            Dim navTopMenuLink As New StringBuilder
                            Dim onmouseover As String = String.Empty
                            Dim onmouseout As String = String.Empty
                            Dim imageOnSrc As String = GetImageSource("NAVIGATION ON", imageMod.WelcomeImageID, referringPage.BusUnit)
                            Dim imageClientId As String = CompressStringForJavaScript(imageMod.WelcomeTitle)

                            TopNavImageContainer.Text = "<img src=""" + imageMod.ImageFile.ImagePath + """ name=""" + ImageClientId + """ alt=""" + imageMod.ImageFile.AltText + """ border=""0"">"
                            onmouseover = "MM_swapImage('" + ImageClientId + "','','" + imageOnSrc + "',0);"
                            onmouseout = "MM_swapImgRestore();"

                            NavTopMenuLink.AppendFormat("<a href=""{0}"" onmouseover=""{1}"" onmouseout=""{2}"">{3}</a>{4}", _
                                    imageMod.WelcomeLinkPageFriendlyURL, _
                                    onmouseover, onmouseout, TopNavImageContainer.Text, _
                                    "<img src=""web/files/images/misc/nav_spacer.gif"" alt=""Petroferm Inc."" border=""0"" width=""1"" height=""44"">")

                            ctl.Controls.Add(New LiteralControl(NavTopMenuLink.ToString))
                        End If
                    End If
                Next
            Case (_refMkt > 0 Or _refBu > 1)
                For i As Integer = 1 To currentPage.BusUnit.Markets.Count
                    Dim market As Market = TryCast(currentPage.BusUnit.Markets.Item(i), Market)
                    If market IsNot Nothing Then
                        Dim imageMod As ImageModule = TryCast(market.TopMenuNavigationRegion.Item(0), ImageModule)
                        If imageMod IsNot Nothing Then
                            If imageMod.ImageType.ToUpper = "NAVIGATION OFF" Then

                                Dim topNavImageContainer As New LiteralControl
                                Dim doSelectCurrentMarket As Boolean = False
                                Dim navTopMenuLink As New StringBuilder
                                Dim onmouseover As String = String.Empty
                                Dim onmouseout As String = String.Empty


                                Dim imageOnSrc As String = GetImageSource("NAVIGATION ON", market)
                                Dim imageClientId As String = CompressStringForJavaScript(market.MarketName)
                                TopNavImageContainer.Text = "<img src=""" + imageMod.ImageFile.ImagePath + """ name=""" + ImageClientId + """ alt=""" + imageMod.ImageFile.AltText + """ border=""0"">"

                                If SelectMarket = True Then
                                    'NOTE: THE BELOW CODE WILL SELECT THE MARKET WHICH THE USER CAME FROM
                                    If market.MarketID <> 0 Then
                                        If market.MarketID <> currentPage.CurrentMarket.MarketID Then
                                            onmouseover = "MM_swapImage('" + ImageClientId + "','','" + imageOnSrc + "',0);"
                                            onmouseout = "MM_swapImgRestore();"
                                        Else
                                            TopNavImageContainer.Text = "<img src=""" + imageOnSrc + """ name=""" + ImageClientId + """ alt=""" + imageMod.ImageFile.AltText + """ border=""0"">"
                                        End If
                                    Else
                                        onmouseover = "MM_swapImage('" + ImageClientId + "','','" + imageOnSrc + "',0);"
                                        onmouseout = "MM_swapImgRestore();"
                                    End If
                                Else
                                    'NOTE: THE BELOW CODE WILL NOT SELECT THE CURRENT MARKET (IF YOU NEED TO SWITCH THEN COMMENT THESE 2 LINES AND UNCOMMENT THE BLOCK ABOVE)
                                    onmouseover = "MM_swapImage('" + ImageClientId + "','','" + imageOnSrc + "',0);"
                                    onmouseout = "MM_swapImgRestore();"
                                End If

                                NavTopMenuLink.AppendFormat("<a href=""{0}"" onmouseover=""{1}"" onmouseout=""{2}"">{3}</a>{4}", _
                                        LinkGenerator.BuildTopNavMenuLinks(currentPage.BusUnit.BusUnitID, market.MarketID), _
                                        onmouseover, onmouseout, TopNavImageContainer.Text, _
                                        "<img src=""web/files/images/misc/nav_spacer.gif"" alt=""Petroferm Inc."" border=""0"" width=""1"" height=""44"">")

                                ctl.Controls.Add(New LiteralControl(NavTopMenuLink.ToString))
                            End If
                        End If
                    End If
                Next

        End Select

        Return ctl

    End Function

#End Region


End Class
