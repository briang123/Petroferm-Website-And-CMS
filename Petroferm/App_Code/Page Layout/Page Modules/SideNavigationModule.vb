Imports Microsoft.VisualBasic

Public Class SideNavigationModule

    Private _mPageType As String
    Private _mBusinessUnitId As Integer
    Private _mMarketId As Integer
    Private _mModuleId As Integer
    Private _mPageId As Integer
    Private _mLiveModeStatus As WorkflowItem.LiveMode

    Public Sub New()
    End Sub

    Public Sub New(ByVal pageId As Integer)
        Me.PageId = PageId
    End Sub

    Private _mBusinessUnitName As String
    Public Property BusinessUnitName() As String
        Get
            Return _mBusinessUnitName
        End Get
        Set(ByVal value As String)
            _mBusinessUnitName = value
        End Set
    End Property

    Private _mCurrentPage As New WebPage
    Public Property CurrentPage() As WebPage
        Get
            Return _mCurrentPage
        End Get
        Set(ByVal value As WebPage)
            _mCurrentPage = value
        End Set
    End Property

    Public Sub New(ByVal currentPage As WebPage)
        Me.CurrentPage = currentPage
        Me.BusinessUnitId = currentPage.BusUnit.BusUnitID
        Me.BusinessUnitName = currentPage.BusUnit.BusName
        Me.PageId = currentPage.PageId
        Me.LiveModeStatus = currentPage.LiveModeStatus
        Me.PageType = currentPage.PageType
    End Sub
    Public Sub New(ByVal businessUnitId As Integer, _
                    ByVal pageId As Integer, _
                    ByVal pageType As String, _
                    ByVal liveModeStatus As WorkflowItem.LiveMode)

        Me.BusinessUnitId = BusinessUnitId
        Me.PageType = PageType
        Me.PageId = PageId
        Me.LiveModeStatus = LiveModeStatus
    End Sub

    Public Sub New(ByVal businessUnitId As Integer, _
                    ByVal pageId As Integer, _
                    ByVal pageType As String, _
                    ByVal liveModeStatus As WorkflowItem.LiveMode, _
                    ByVal businessUnitName As String)

        Me.BusinessUnitId = BusinessUnitId
        Me.PageType = PageType
        Me.PageId = PageId
        Me.LiveModeStatus = LiveModeStatus
        Me.BusinessUnitName = BusinessUnitName
    End Sub


    Property PageId() As Integer
        Get
            Return _mPageId
        End Get
        Set(ByVal value As Integer)
            _mPageId = value
        End Set
    End Property

    Property LiveModeStatus() As WorkflowItem.LiveMode
        Get
            Return _mLiveModeStatus
        End Get
        Set(ByVal value As WorkflowItem.LiveMode)
            _mLiveModeStatus = value
        End Set
    End Property

    Public Property BusinessUnitId() As Integer
        Get
            Return _mBusinessUnitId
        End Get
        Set(ByVal value As Integer)
            _mBusinessUnitId = value
        End Set
    End Property

    Public Property PageType() As String
        Get
            Return _mPageType
        End Get
        Set(ByVal value As String)
            _mPageType = value
        End Set
    End Property

    Public Function BuildSideNavigation() As String


        'START: 12th hour determination of expandability/collapsing menus
        ' TODO: Fix caching issues - I commented this out so that the paths are pulled from the db every time - 12/20/06 - KR
        '        Dim dtRewritePaths As DataTable = TryCast(HttpContext.Current.Cache("URL_REWRITE"), DataTable)
        Dim dtRewritePaths As DataTable = Nothing
        If dtRewritePaths Is Nothing Then
            Dim rewriteValidator As New UrlRewriteValidator
            dtRewritePaths = rewriteValidator.LoadUrlRewritePaths
        End If

        Dim dvPaths As DataView = dtRewritePaths.DefaultView
        dvPaths.RowFilter = "PageID=" + Me.PageId.ToString
        Dim prodCatId As Integer = 0
        Dim sectionId As Integer = 0
        Dim currentFriendlyUrl As String = String.Empty
        If dvPaths.Count > 0 Then
            For Each rowview As DataRowView In dvPaths
                currentFriendlyUrl = Services.GetNULLableString(rowview("UrlFriendlyName"))
                prodCatId = Services.GetNULLableInteger(rowview("PC_ProdCatID"))
                sectionId = Services.GetNULLableInteger(rowview("SectionID"))
            Next
        End If
        'END: 12th hour determination of expandability/collapsing menus

        Dim dataSectLkp As New DataAccess(SiteProfile.GetConnectionString, DataAccess.DataProvider.SQL)
        Dim iCmdSectLkp As IDbCommand = dataSectLKP.GetCommand("select SectionID, SectionName from tblSideNavSection_LKP where ActiveFlag = 1 order by SectionOrder asc", CommandType.Text, DataAccess.DataProvider.SQL)
        Dim dtSectLkp As DataTable = dataSectLKP.GetDataTable(iCmdSectLKP)

        Dim data As New DataAccess(SiteProfile.GetConnectionString, DataAccess.DataProvider.SQL)
        Dim iCon As IDbConnection = data.GetConnection(SiteProfile.GetConnectionString, DataAccess.DataProvider.SQL)
        Dim iCmd As IDbCommand = data.GetCommand("sp__GetSideNav", CommandType.StoredProcedure, DataAccess.DataProvider.SQL)
        Dim iparmBusIdIn As IDbDataParameter = data.GetParameter(DataAccess.DataProvider.SQL, "@BusID", DbType.Int32, Me.BusinessUnitId, 4, ParameterDirection.Input)
        Dim iparmMktIdIn As IDbDataParameter = data.GetParameter(DataAccess.DataProvider.SQL, "@MktId", DbType.Int32, Me.CurrentPage.CurrentMarket.MarketID, 4, ParameterDirection.Input)
        Dim iparmIsLiveIn As IDbDataParameter = data.GetParameter(DataAccess.DataProvider.SQL, "@LiveMode", DbType.Boolean, Me.LiveModeStatus, 1, ParameterDirection.Input)
        With iCmd.Parameters
            .Add(iparmBusIdIn)
            .Add(iparmMktIdIn)
            .Add(iparmIsLiveIn)
        End With
        Dim dtSideNav As DataTable = data.GetDataTable(iCmd)

        Dim sb As New StringBuilder
        Dim productCategoryCounter As Integer = 0
        Dim isDoneWithProdCategories As Boolean = False
        Dim currentProdCatId As Integer = 0


        If HttpContext.Current.Request.ServerVariables("PATH_INFO").ToUpper.IndexOf("CONTACT") > -1 Or _
            HttpContext.Current.Request.ServerVariables("PATH_INFO").ToUpper.IndexOf("SEARCH") > -1 Then
            PageType = "GENERAL"
        End If

        sb.Append("<table valign=""top"" border=""0"" width=""164"" cellspacing=""0"" cellpadding=""0"">" + vbCrLf)

        'MARKET HOME
        '


        Dim filteredRows() As DataRow

        If PageType = "MARKET HOME" Or PageType = "PRODUCT" Or PageType.StartsWith("GENERAL") Or prodCatId > 0 Or sectionId = 1 Then

            sb.Append("<tr><td colspan=""2"" height=""20"" bgcolor=""#FFFFFF"" class=""navHeader"" style=""padding-left: 7px;"">")
            filteredRows = dtSideNav.Select("SectionID = 1", "")
            If filteredRows.Length > 0 Then
                If PageType.StartsWith("GENERAL") = True Then
                    sb.Append("&nbsp;</td></tr>" + vbCrLf)
                Else
                    sb.Append("Products:</td></tr>" + vbCrLf)
                End If

            Else
                sb.Append("&nbsp;</td></tr>" + vbCrLf)
            End If

            sb.Append("<tr>" + vbCrLf)
            sb.Append("<td colspan=""2"" style=""padding-left: 7px;"">" + vbCrLf)
            ''sb.Append("<div id=""sideNavContainer"">" + vbCrLf)

        ElseIf PageType = "GENERAL" Then
            sb.Append("<tr><td colspan=""2"" height=""20"" bgcolor=""#FFFFFF"" class=""navHeader"" style=""padding-left: 7px;"">")
            sb.Append("&nbsp;</td></tr>" + vbCrLf)
            sb.Append("<tr>" + vbCrLf)
            sb.Append("<td colspan=""2"" style=""padding-left: 7px;"">" + vbCrLf)
            ''sb.Append("<div id=""sideNavContainer"">" + vbCrLf)
        End If


        
        Dim counter As Integer = 0
        Dim isDoneWithProductCategorySection As Boolean = False
        For Each sectRow As DataRow In dtSectLKP.Rows
            If IsDoneWithProductCategorySection = False Then
                If PageType = "MARKET HOME" Or PageType = "PRODUCT" Then 'Or prodCatId > 0 Or sectionId = 1 Then

                    ''filteredRows = dtSideNav.Select("MarketID = " + Me.CurrentPage.CurrentMarket.MarketID.ToString + " AND SectionID = " + sectRow("SectionID").ToString, "")

                    filteredRows = dtSideNav.Select("SectionID = " + sectRow("SectionID").ToString, "")
                    If filteredRows.Length > 0 Then
                        For Each dataRow As DataRow In filteredRows
                            If IsDoneWithProductCategorySection = False Then
                                If CType(dataRow("SectionID"), Integer) = 1 Then

                                    Dim dtProductCategories As DataTable = Services.RemoveDuplicateRows(dtSideNav, "ProdCatID", "")
                                    Dim prodCatRows() As DataRow = dtProductCategories.Select("ProdCatId > 0", "CategoryOrder ASC")
                                    sb.Append("<div id=""Sect" + dataRow("SectionID").ToString + "Container"">" + vbCrLf)
                                    For Each prodCatRow As DataRow In prodCatRows

                                        Dim isFirstCategoryRow As Boolean = True
                                        'sb.Append("<div id=""Sect" + dataRow("SectionID").ToString + "Container"">" + vbCrLf)

                                        For Each cat As DataRow In dtSideNav.Select("ProdCatID = " + prodCatRow("ProdCatID").ToString)
                                            If IsFirstCategoryRow Then
                                                ' added section id to span id 1/2/07 kr
                                                sb.Append(vbCrLf + vbCrLf + "<span id=""Sect" + dataRow("SectionID").ToString + cat("ProdCatID").ToString + "MenuClick"" onClick=""toggleDIV('Sect" + dataRow("SectionID").ToString + cat("ProdCatID").ToString + "Menu');navImageToggle('imgSect" + dataRow("SectionID").ToString + prodCatRow("ProdCatID").ToString + "', 'http://www.petroferm.com/images/arrow_blue_down.gif', 'http://www.petroferm.com/images/arrow_white.gif', 'Sect" + sectRow("SectionID").ToString + "Container', 'Sect" + dataRow("SectionID").ToString + cat("ProdCatID").ToString + "MenuClick');return false;"">" + vbCrLf)
                                                ''sb.Append(vbCrLf + vbCrLf + "<span id=""Sect" + dataRow("SectionID").ToString + "MenuClick"" onClick=""toggleDIV('Sect" + dataRow("SectionID").ToString + "Menu');navImageToggle('imgSect" + dataRow("SectionID").ToString + "', 'http://www.petroferm.com/images/arrow_blue_down.gif', 'http://www.petroferm.com/images/arrow_white.gif', 'Sect" + dataRow("SectionID").ToString + "Container', 'Sect" + dataRow("SectionID").ToString + "MenuClick');return false;"">" + vbCrLf)
                                                sb.Append("<table width=""100%"" cellpadding=""0"" cellspacing=""0"" border=""0"" class=""navback-main"">" + vbCrLf)
                                                sb.Append("<tr>" + vbCrLf)
                                                ''sb.Append("<td width=""17"" height=""20""><img src=""web/files/images/misc/arrow_white.gif"" alt=""Petroferm Inc."" name=""imgSect" + cat("ProdCatID").ToString + """ border=""0""></td>" + vbCrLf)
                                                '
                                                'not expanding because we are hard coding the image; we should try making the image src a variable
                                                sb.Append("<td width=""17"" height=""20""><img src=""http://www.petroferm.com/images/arrow_white.gif"" alt=""Petroferm Inc."" name=""imgSect" + dataRow("SectionID").ToString + cat("ProdCatID").ToString + """ border=""0""></td>" + vbCrLf)
                                                'sb.Append("<td width=""17"" height=""20""><img src=""web/files/images/misc/arrow_white.gif"" alt=""Petroferm Inc."" name=""imgSect" + dataRow("SectionID").ToString + """ border=""0""></td>" + vbCrLf)
                                                sb.Append("<td align=""left"" width=""147"" style=""padding-right: 10px;"">" + vbCrLf)
                                                sb.Append("<a href=""#"" class=""rightNav"" onMouseOver=""window.status='Click to expand or collapse menu.'; return true;"" onMouseOut=""window.status=' '; return true;"">" + cat("CategoryName").ToString + "</a>" + vbCrLf)
                                                sb.Append("</td>" + vbCrLf)
                                                sb.Append("</tr>" + vbCrLf)
                                                sb.Append("</table>" + vbCrLf)
                                                sb.Append("</span>" + vbCrLf + vbCrLf)

                                                IsFirstCategoryRow = False
                                                ' added section id to span id 1/2/07 kr
                                                sb.Append("<span id=""Sect" + dataRow("SectionID").ToString + cat("ProdCatID").ToString + "Menu"" class=""menuchild"">")
                                            End If
                                            sb.Append("<table width=""150"" border=""0"" cellspacing=""0"" cellpadding=""0"">" + vbCrLf)
                                            sb.Append("<tr>" + vbCrLf)
                                            sb.Append("<td width=""24"" height=""20"" align=""right""><img src=""web/files/images/misc/spacer.gif"" alt=""Petroferm Inc."" width=""7"" height=""7"" border=""0"">-&nbsp;</td>" + vbCrLf)
                                            sb.Append("<td align=""left"" width=""126"" >" + vbCrLf)
                                            'cat("URL").ToString {replaced in {0} with linkgenerator} / GetClassName(cat("URL").ToString) replaced with linkgenerator in {1}
                                            'Dim url As String = LinkGenerator.BuildCommonPageLink(CType(cat("PageId"), Integer))
                                            sb.AppendFormat("<a href=""{0}"" class=""{1}"" title=""{2}"" onMouseOver=""window.status='Get information about {3}';return true;"" onMouseOut=""window.status=' '; return true;"">{3}</a>" + vbCrLf, _
                                                    cat("UrlFriendlyName").ToString, _
                                                    Me.GetClassName(currentFriendlyUrl, cat("UrlFriendlyName").ToString), _
                                                    cat("Description").ToString, _
                                                    cat("Title").ToString)
                                            sb.Append("</td>" + vbCrLf)
                                            sb.Append("</tr>" + vbCrLf)
                                            sb.Append("</table>" + vbCrLf)
                                        Next
                                        sb.Append("</span>" + vbCrLf + vbCrLf)

                                    Next
                                    IsDoneWithProductCategorySection = True
                                End If
                            End If
                        Next
                    Else
                        IsDoneWithProductCategorySection = True
                    End If
                Else
                    IsDoneWithProductCategorySection = True
                End If
            Else

                If PageType = "MARKET HOME" Or PageType = "PRODUCT" Or prodCatId > 0 Or sectionId = 1 Then

                    sb.Append("</div>" + vbCrLf)
                    sb.Append("</td>" + vbCrLf)
                    sb.Append("</tr>" + vbCrLf)
                End If

                Dim isFirstPassInThisSection As Boolean = True
                Dim isDoneWithSection As Boolean = False
                Dim isFirstLinkInGeneralLinks As Boolean = True
                Dim isDoneWithCurrentSection As Boolean = False

                'get unique list of section ids in our side navigation table 
                '1 - Product Category; 2 - Data Sheets; 3 - About Us; 4 - Contact Us; 5 - Registration; 6 - Other Links
                Dim dtSections As DataTable = Services.RemoveDuplicateRows(dtSideNav, "SectionID", "")

                'get all the values contained in the current section (ignore Product Category Section) because that's all the 
                'product-related sub-menu items were handled first and is done by now
                Dim sectRows() As DataRow = dtSections.Select("SectionID = " + sectRow("SectionID").ToString + " AND ProdCatID = 0", "")

                If IsDoneWithSection = False Then

                    'iterate through each navigational sub-item
                    For Each section As DataRow In sectRows

                        'Since we perform an inner loop for each menu section, we tell the system within 
                        'that inner loop when we done with that section
                        IsDoneWithCurrentSection = False

                        'get all the sub-menu items for a particular section
                        Dim currentSectionRows() As DataRow = dtSideNav.Select("SectionID = " + section("SectionID").ToString)

                        'iterate through all sub-menu items
                        For Each subItem As DataRow In currentSectionRows

                            Select Case CType(subItem("SectionID"), Integer)
                                Case 2 'Data Sheets Section
                                    If PageType = "MARKET HOME" Or PageType = "PRODUCT" Or prodCatId > 0 Or sectionId = 1 Then


                                        If IsDoneWithCurrentSection = False Then
                                            If PageType = "MARKET HOME" Or PageType = "PRODUCT" Or prodCatId > 0 Or sectionId = 1 Then


                                                sb.Append("<tr><td colspan=""2"" height=""1"" align=""right"" style=""padding-top: 20px;""><img src=""web/files/images/misc/spcr_white.gif"" alt=""Petroferm Inc."" width=""157"" height=""1"" border=""0""></td></tr>" + vbCrLf)
                                            Else
                                                sb.Append("<tr><td colspan=""2"" height=""1"" align=""right""><img src=""web/files/images/misc/spcr_white.gif"" alt=""Petroferm Inc."" width=""157"" height=""1"" border=""0""></td></tr>" + vbCrLf)
                                            End If

                                            For Each subMenuItem As DataRow In currentSectionRows
                                                sb.Append("<tr>" + vbCrLf)
                                                sb.Append("     <td style=""padding-left: 7px;"" width=""17"" height=""20""><a href="".""><img src=""web/files/images/misc/arrow_white.gif"" alt=""Petroferm Inc."" width=""7"" height=""7"" border=""0""></a></td>" + vbCrLf)
                                                sb.Append("     <td align=""left"" width=""147"" style=""padding-right: 10px;"">" + vbCrLf)
                                                'subMenuItem("URL").ToString replaced by linkgenerator
                                                sb.AppendFormat("       <a href=""~/{0}"" class=""rightNav"" onMouseOver = ""window.status='Get information about {1}'; return true;"" onMouseOut=""window.status=' '; return true;"">{1}</a>" + vbCrLf, subMenuItem("UrlFriendlyName").ToString, subMenuItem("Title").ToString)
                                                sb.Append("     </td>" + vbCrLf)
                                                sb.Append("</tr>" + vbCrLf)
                                            Next

                                            IsDoneWithCurrentSection = True
                                        End If

                                    End If

                                Case 3, 4 'About Us/Contact Us

                                    If IsDoneWithCurrentSection = False Then
                                        If IsFirstPassInThisSection = True And subItem("SectionID").ToString = "3" Then

                                            If PageType = "PETROFERM HOME" Then
                                                'add extra white space between the about us section and whatever is above it (products or datasheets)
                                                'sb.Append("<tr><td colspan=""2"" height=""1"" align=""right"" ><img src=""web/files/images/misc/spcr_white.gif"" alt=""Petroferm Inc."" width=""157"" height=""1"" border=""0""></td></tr>" + vbCrLf)
                                            Else

                                                'If PageType <> "BUSINESS HOME" And PageType.StartsWith("GENERAL") = False And PageType <> "SEARCH" Then
                                                If PageType <> "BUSINESS HOME" And PageType <> "SEARCH" And PageType.StartsWith("GENERAL") = False Then 'And (sectionId = 1 Or prodCatId > 0) Then

                                                    'add extra white space between the about us section and whatever is above it (products or datasheets)
                                                    sb.Append("<tr><td colspan=""2"" height=""1"" align=""right"" style=""padding-top:10px;""><img src=""web/files/images/misc/spcr_white.gif"" alt=""Petroferm Inc."" width=""157"" height=""1"" border=""0""></td></tr>" + vbCrLf)

                                                Else
                                                    'sb.Append("<tr><td colspan=""2"" height=""1"" align=""right""><img src=""web/files/images/misc/spcr_white.gif"" alt=""Petroferm Inc."" width=""157"" height=""1"" border=""0""></td></tr>" + vbCrLf)

                                                End If
                                            End If

                                        End If

                                        sb.Append("<tr>" + vbCrLf)
                                        sb.Append("<td colspan=""2"" style=""padding-left: 7px;"">" + vbCrLf)

                                        'configure the About Us/Contact Us Link Text container
                                        If IsFirstPassInThisSection = True Then
                                            sb.Append("<div id=""Sect" + subItem("SectionID").ToString + "Container"">" + vbCrLf)
                                            'TODO: Change the domain and image path (http://www.petroferm.com/images/arrow_blue_down.gif ==> http://www.petroferm.com/web/files/images/misc/arrow_blue_down.gif AND http://www.petroferm.com/images/arrow_white.gif ==> http://www.petroferm.com/web/files/images/misc/arrow_white.gif
                                            sb.Append("     <span id=""Sect" + subItem("SectionID").ToString + "MenuClick"" onClick=""toggleDIV('Sect" + subItem("SectionID").ToString + "Menu');navImageToggle('imgSect" + subItem("SectionID").ToString + "', 'http://www.petroferm.com/images/arrow_blue_down.gif', 'http://www.petroferm.com/images/arrow_white.gif', 'Sect" + subItem("SectionID").ToString + "Container', 'Sect" + subItem("SectionID").ToString + "MenuClick');return false;"">" + vbCrLf)
                                            sb.Append("         <table width=""100%"" cellpadding=""0"" cellspacing=""0"" border=""0"" class=""navback-main"">" + vbCrLf)
                                            sb.Append("         <tr>" + vbCrLf)
                                            sb.Append("             <td width=""17"" height=""20""><img src=""web/files/images/misc/arrow_white.gif"" alt=""Petroferm Inc."" name=""imgSect" + subItem("SectionID").ToString + """ border=""0""></td>" + vbCrLf)
                                            sb.Append("             <td align=""left"" width=""147"" style=""padding-right: 10px;"">" + vbCrLf)
                                            sb.Append("                 <a href=""#"" class=""rightNav""" + vbCrLf)
                                            sb.Append("                     onMouseOver = ""window.status='Click to expand or collapse menu.'; return true;""" + vbCrLf)
                                            sb.Append("                     onMouseOut=""window.status=' '; return true;"">" + subItem("SectionName") + "</a>" + vbCrLf)
                                            sb.Append("             </td>" + vbCrLf)
                                            sb.Append("         </tr>" + vbCrLf)
                                            sb.Append("         </table>" + vbCrLf)
                                            sb.Append("</span>" + vbCrLf)

                                            'configure the begining tags for the sub-menu items
                                            sb.Append("<span id=""Sect" + subItem("SectionID").ToString() + "Menu"" class=""menuchild"">" + vbCrLf)
                                            sb.Append("     <table width=""150"" border=""0"" cellspacing=""0"" cellpadding=""0"">" + vbCrLf)

                                            IsFirstPassInThisSection = False
                                        End If

                                        For Each item As DataRow In currentSectionRows 'AllSubItems
                                            sb.Append("     <tr>" + vbCrLf)
                                            sb.Append("         <td width=""24"" height=""20"" align=""right""><img src=""web/files/images/misc/spacer.gif"" width=""7"" height=""7"" border=""0"">-&nbsp;</td>" + vbCrLf)
                                            sb.Append("         <td align=""left"" width=""126"" >" + vbCrLf)

                                            '=============================
                                            'MODIFY THIS SECTION (4) TO HANDLE PASSTHROUGH PAGETYPES (WHICH IS THE CONTACT.ASPX PAGE IN THIS SECTION, BUT SERVES AS 2 PAGES -- FEEDBACK AND REQUEST INFORMATION
                                            '"~/Search.aspx?ref=" + CurrentPage.BusUnit.BusUnitID.ToString + "," + CurrentPage.CurrentMarket.MarketID.ToString + "," + MyBase.CurrentPageId.ToString + "&type=simple"
                                            '=============================
                                            ' kr - added querystrings - 12/24/06
                                            Dim url As String = item("UrlFriendlyName").ToString
                                            url &= "?ref=" & CurrentPage.BusUnit.BusUnitID.ToString & "," & CurrentPage.CurrentMarket.MarketID.ToString & "," & Me.CurrentPage.PageId.ToString



                                            sb.AppendFormat("           <a href=""{0}"" class=""{1}"" onMouseOver=""window.status='View {2} about our division'; return true;"" onMouseOut=""window.status=' '; return true;"">{2}</a>" + vbCrLf, url, Me.GetClassName(currentFriendlyUrl, item("UrlFriendlyName").ToString), item("Title").ToString)
                                            sb.Append("         </td>" + vbCrLf)
                                            sb.Append("     </tr>" + vbCrLf)
                                        Next

                                        sb.Append("     </table>" + vbCrLf)
                                        sb.Append("</span>" + vbCrLf)
                                        sb.Append("</div>" + vbCrLf)

                                        sb.Append("<tr><td colspan=""2"" height=""1"" align=""right""><img src=""web/files/images/misc/spcr_white.gif"" alt=""Petroferm Inc."" width=""157"" height=""1"" border=""0""></td></tr>" + vbCrLf)

                                        IsDoneWithCurrentSection = True
                                    End If

                                Case 5, 6 'Registration and Other Links Sections

                                    'add white line above each link in the "Other Links" section
                                    If subItem("SectionID").ToString = "6" Then
                                        sb.Append("<tr><td colspan=""2"" height=""1"" align=""right""><img src=""web/files/images/misc/spcr_white.gif"" alt=""Petroferm Inc."" width=""157"" height=""1"" border=""0""></td></tr>" + vbCrLf)
                                    End If

                                    sb.Append("<tr>" + vbCrLf)
                                    sb.Append("     <td style=""padding-left: 7px;"" width=""17"" height=""20""><a href=""#""><img src=""web/files/images/misc/arrow_white.gif"" alt=""Petroferm Inc."" width=""7"" height=""7"" border=""0""></a></td>" + vbCrLf)
                                    sb.Append("     <td align=""left"" width=""147"" style=""padding-right: 10px;"">" + vbCrLf)

                                    '=============================
                                    ' MODIFY THIS SECTION (5,6) TO HANDLE PASSTHROUGH PAGETYPES (WHICH IS ONLY THE REGISTER.ASPX PAGE IN THIS SECTION)
                                    '"~/Search.aspx?ref=" + CurrentPage.BusUnit.BusUnitID.ToString + "," + CurrentPage.CurrentMarket.MarketID.ToString + "," + MyBase.CurrentPageId.ToString + "&type=simple"
                                    '=============================
                                    ' kr - added querystrings - 12/22/06
                                    Dim url As String = subItem("UrlFriendlyName").ToString
                                    url &= "?ref=" & CurrentPage.BusUnit.BusUnitID.ToString & "," & CurrentPage.CurrentMarket.MarketID.ToString & "," & Me.CurrentPage.PageId.ToString

                                    sb.AppendFormat("       <a href=""{0}"" class=""rightNav"" onmouseover=""window.status='Get information about {1}'; return true;"" onMouseOut=""window.status=' '; return true;"">{1}</a>" + vbCrLf, url, subItem("Title").ToString)
                                    sb.Append("     </td>" + vbCrLf)
                                    sb.Append("</tr>" + vbCrLf)

                                    IsFirstLinkInGeneralLinks = False

                            End Select

                        Next

                    Next
                    'sb.Append("</td>" + vbCrLf)
                    'sb.Append("</tr>" + vbCrLf)

                    IsDoneWithSection = True
                End If
            End If

        Next


        'If PageType = "GENERAL" Or PageType = "MARKET HOME" Or PageType = "PRODUCT" Then

        'If PageType <> "PETROFERM HOME" And PageType <> "BUSINESS HOME" Then ' PageType = "MARKET HOME" Or PageType = "PRODUCT" Or PageType = "GENERAL" Or sectionId = 1 Or prodCatId > 0 Then
        If PageType <> "PETROFERM HOME" And PageType <> "BUSINESS HOME" And CurrentPage.BusUnit.BusUnitID > 1 Then
            'business division home page (displayed when not on "PETROFERM HOME" page or business home page)
            sb.Append("<tr>" + vbCrLf)
            sb.Append(" <td colspan=""2"" height=""1"" align=""right""><img src=""web/files/images/misc/spcr_white.gif"" alt=""Petroferm Inc."" width=""157"" height=""1"" border=""0""></td>" + vbCrLf)
            sb.Append("</tr>" + vbCrLf)
            sb.Append("<tr>" + vbCrLf)
            sb.Append(" <td style=""padding-left: 7px;"" width=""17"" height=""20""><img src=""web/files/images/misc/arrow_white.gif"" alt=""Petroferm Inc."" width=""7"" height=""7"" border=""0""></td>" + vbCrLf)
            sb.Append(" <td align=""left"" width=""147"" style=""padding-right: 10px;"">" + vbCrLf)
            sb.Append("     <a href=""" + LinkGenerator.BuildHomePageFriendlyPageLink(BusinessUnitId) + """ class=""rightNav"" " + vbCrLf)
            sb.Append("         onMouseOver=""window.status='Return to the home page'; return true;"" " + vbCrLf)
            sb.Append("         onMouseOut=""window.status=' '; return true;"">" + Me.BusinessUnitName + " Homepage</a>" + vbCrLf)
            sb.Append(" </td>" + vbCrLf)
            sb.Append("</tr>" + vbCrLf)

        End If

        If PageType <> "PETROFERM HOME" Then

            'page link (displayed when not on "PETROFERM HOME" page)
            sb.Append("<tr>" + vbCrLf)
            sb.Append(" <td colspan=""2"" height=""1"" align=""right""><img src=""web/files/images/misc/spcr_white.gif"" alt=""Petroferm Inc."" width=""157"" height=""1"" border=""0""></td>" + vbCrLf)
            sb.Append("</tr>" + vbCrLf)
            sb.Append("<tr>" + vbCrLf)
            sb.Append(" <td style=""padding-left: 7px;"" width=""17"" height=""20""><img src=""web/files/images/misc/arrow_white.gif"" alt=""Petroferm Inc."" width=""7"" height=""7"" border=""0""></td>" + vbCrLf)
            sb.Append(" <td align=""left"" width=""147"" style=""padding-right: 10px;"">" + vbCrLf)
            sb.Append("     <a href=""" + LinkGenerator.BuildHomePageFriendlyPageLink(1) + """ class=""rightNav"" " + vbCrLf)
            sb.Append("         onMouseOver=""window.status='Return to the Petroferm Inc. home page';return true;"" " + vbCrLf)
            sb.Append("         onMouseOut=""window.status=' '; return true;"">Petroferm Inc. Homepage</a>" + vbCrLf)
            sb.Append(" </td>" + vbCrLf)
            sb.Append("</tr>" + vbCrLf)
            sb.Append("<tr>" + vbCrLf)
            sb.Append("<td colspan=""2"" height=""1"" align=""right"" style=""padding-bottom: 50px;""><img src=""web/files/images/misc/spcr_white.gif"" alt=""Petroferm Inc."" width=""157"" height=""1"" border=""0""></td>" + vbCrLf)
            sb.Append("</tr>" + vbCrLf)


            ''not displayed on the "PETROFERM HOME"page; otherwise displayed on all other pages
            ''sb.Append("<tr><td colspan=""2"" height=""1"" align=""right""><img src=""web/files/images/misc/spcr_white.gif"" alt=""Petroferm Inc."" width=""157"" height=""1"" border=""0""></td></tr>" + vbCrLf)
            'sb.Append("<tr><td colspan=""2"">")
            'sb.Append("<br/><br/>" + vbCrLf)
            'sb.Append("<table border=""0"" width=""164"" cellspacing=""0"" cellpadding=""0"">" + vbCrLf)
            'sb.Append("<tr>" + vbCrLf)
            'sb.Append("<td align=""center"">" + vbCrLf)
            'sb.Append("<a href=""http://www.adobe.com/products/acrobat/readstep2.html"" " + vbCrLf)
            'sb.Append("Title = ""Download Adobe Reader""" + vbCrLf)
            'sb.Append("target = ""_blank""" + vbCrLf)
            'sb.Append("onMouseOver = ""window.status='Download Adobe Reader from www.adobe.com.'; return true;""" + vbCrLf)
            'sb.Append("onMouseOut = ""window.status=' '; return true;"">" + vbCrLf)
            'sb.Append("<img src=""web/files/images/misc/get_adobe_reader.gif"" border=""0"" alt=""Adobe Reader"" width=""88px"" height=""31px"">" + vbCrLf)
            'sb.Append("</a>" + vbCrLf)
            'sb.Append("</td>" + vbCrLf)
            'sb.Append("	</tr>" + vbCrLf)
            'sb.Append("<tr>" + vbCrLf)
            'sb.Append("<td style=""padding:5px;font-size:11px;"">Adobe Reader is required to view any of our downloadable files.</td>" + vbCrLf)
            'sb.Append("</tr>" + vbCrLf)
            'sb.Append("</table>" + vbCrLf)

        End If

        sb.Append("</td></tr></table>" + vbCrLf)

        'sb.Append("</table>" + vbCrLf)


        Return sb.ToString

    End Function

    Private Function GetClassName(ByVal currentUrl As String, ByVal sideNavUrl As String) As String
        Dim classname As String = "navsub-inact"
        If currentUrl.ToLower = sideNavUrl.ToLower Then
            classname = "navsub-selected"
        End If
        Return classname
    End Function

End Class
