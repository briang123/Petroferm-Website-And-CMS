Imports Microsoft.VisualBasic

Public Class WebPage
    Inherits WorkflowItem
    Implements IWebPage

    Private _mPageId As Integer
    Private _mPageTitle As String
    Private _mUrlRewritePath As String
    Private _mMetaKeywords As String
    Private _mMetaDescription As String
    Private _mPassthroughUrl As String
    Private _mIsRequired As Boolean
    Private _mIsReadOnly As Boolean
    Private _mCachePageContent As Boolean
    Private _mBusUnit As New BusinessUnit
    Private _mMarkets As SortedList
    Private _mCurrentMarket As New Market
    Private _mTopMenuNavigationRegion As ArrayList
    Private _mHeaderImageRegion As ArrayList
    Private _mHeaderSideContentRegion As ArrayList
    Private _mHeaderSideImageRegion As ArrayList
    Private _mSideBodyContentRegion As ArrayList
    Private _mSideNavigationRegion As String
    Private _mBodyContentRegion As ArrayList
    Private _mPageModules As PageModules
    Private _mPageType As String
    Private _mLiveModeStatus As WorkflowItem.LiveMode

    Public Property LiveModeStatus() As WorkflowItem.LiveMode
        Get
            Return _mLiveModeStatus
        End Get
        Set(ByVal value As WorkflowItem.LiveMode)
            _mLiveModeStatus = value
        End Set
    End Property

    Public Sub New()
    End Sub

    Public Sub New(ByVal pageId As Integer, ByVal liveMode As WorkflowItem.LiveMode)
        Me.PageId = PageId
        Me.LiveModeStatus = liveMode
        Me.FillLiveContent()
    End Sub

    Public Sub New(ByVal pageId As Integer)
        _mPageId = PageId
        Me.FillLiveContent()
    End Sub

    Public Property BusUnit() As BusinessUnit Implements IWebPage.BusUnit
        Get
            Return _mBusUnit
        End Get
        Set(ByVal value As BusinessUnit)
            _mBusUnit = value
        End Set
    End Property

    Public Property PageModules() As PageModules
        Get
            Return _mPageModules
        End Get
        Set(ByVal value As PageModules)
            _mPageModules = value
        End Set
    End Property

    Public Property CachePageContent() As Boolean Implements IWebPage.CachePageContent
        Get
            Return _mCachePageContent
        End Get
        Set(ByVal value As Boolean)
            _mCachePageContent = value
        End Set
    End Property

    Public Property PageType() As String Implements IWebPage.PageType
        Get
            Return _mPageType
        End Get
        Set(ByVal value As String)
            _mPageType = value
        End Set
    End Property


    Public Property IsReadOnly() As Boolean Implements IWebPage.IsReadOnly
        Get
            Return _mIsReadOnly
        End Get
        Set(ByVal value As Boolean)
            _mIsReadOnly = value
        End Set
    End Property

    Public Property IsRequired() As Boolean Implements IWebPage.IsRequired
        Get
            Return _mIsRequired
        End Get
        Set(ByVal value As Boolean)
            _mIsRequired = value
        End Set
    End Property

    Public Property MetaDescription() As String Implements IWebPage.MetaDescription
        Get
            Return _mMetaDescription
        End Get
        Set(ByVal value As String)
            _mMetaDescription = value
        End Set
    End Property

    Public Property MetaKeywords() As String Implements IWebPage.MetaKeywords
        Get
            Return _mMetaKeywords
        End Get
        Set(ByVal value As String)
            _mMetaKeywords = value
        End Set
    End Property

    Public Property PageId() As Integer Implements IWebPage.PageId
        Get
            Return _mPageId
        End Get
        Set(ByVal value As Integer)
            _mPageId = value
        End Set
    End Property

    Public Property PageTitle() As String Implements IWebPage.PageTitle
        Get
            Return _mPageTitle
        End Get
        Set(ByVal value As String)
            _mPageTitle = value
        End Set
    End Property

    Public Property UrlRewritePath() As String Implements IWebPage.UrlRewritePath
        Get
            Return _mUrlRewritePath
        End Get
        Set(ByVal value As String)
            _mUrlRewritePath = value
        End Set
    End Property

    Public Property PassthroughUrl() As String Implements IWebPage.PassthroughUrl
        Get
            Return _mPassthroughUrl
        End Get
        Set(ByVal value As String)
            _mPassthroughUrl = value
        End Set
    End Property

    Public Property BodyContentRegion() As System.Collections.ArrayList Implements IWebPage.BodyContentRegion
        Get
            Return _mBodyContentRegion
        End Get
        Set(ByVal value As System.Collections.ArrayList)
            _mBodyContentRegion = value
        End Set
    End Property

    Public Property HeaderImageRegion() As System.Collections.ArrayList Implements IWebPage.HeaderImageRegion
        Get
            Return _mHeaderImageRegion
        End Get
        Set(ByVal value As System.Collections.ArrayList)
            _mHeaderImageRegion = value
        End Set
    End Property

    Public Property HeaderSideContentRegion() As System.Collections.ArrayList Implements IWebPage.HeaderSideContentRegion
        Get
            Return _mHeaderSideContentRegion
        End Get
        Set(ByVal value As System.Collections.ArrayList)
            _mHeaderSideContentRegion = value
        End Set
    End Property

    Public Property HeaderSideImageRegion() As System.Collections.ArrayList Implements IWebPage.HeaderSideImageRegion
        Get
            Return _mHeaderSideImageRegion
        End Get
        Set(ByVal value As System.Collections.ArrayList)
            _mHeaderSideImageRegion = value
        End Set
    End Property

    Public Property SideBodyContentRegion() As System.Collections.ArrayList Implements IWebPage.SideBodyContentRegion
        Get
            Return _mSideBodyContentRegion
        End Get
        Set(ByVal value As System.Collections.ArrayList)
            _mSideBodyContentRegion = value
        End Set
    End Property

    Public Property SideNavigationRegion() As String Implements IWebPage.SideNavigationRegion
        Get
            'Return m_SideNavigationRegion
            Dim sideNav As New SideNavigationModule(Me) 'Me.BusUnit.BusUnitID, Me.PageId, Me.PageType, LiveMode.Live)
            Return sideNav.BuildSideNavigation()
        End Get
        Set(ByVal value As String)
            _mSideNavigationRegion = value
        End Set
    End Property

    Public Property TopMenuNavigationRegion() As System.Collections.ArrayList Implements IWebPage.TopMenuNavigationRegion
        Get
            Return _mTopMenuNavigationRegion
        End Get
        Set(ByVal value As System.Collections.ArrayList)
            _mTopMenuNavigationRegion = value
        End Set
    End Property

    Public Property CurrentMarket() As Market Implements IWebPage.CurrentMarket
        Get
            Return _mCurrentMarket
        End Get
        Set(ByVal value As Market)
            _mCurrentMarket = value
        End Set
    End Property

    Public Property Markets() As System.Collections.SortedList Implements IWebPage.Markets
        Get
            Return _mMarkets
        End Get
        Set(ByVal value As System.Collections.SortedList)
            _mMarkets = value
        End Set
    End Property

    Public Function Delete() As Boolean Implements IWebPage.Delete
        Dim success As Boolean
        Dim iCmd As IDbCommand
        Dim data As New DataAccess(SiteProfile.GetConnectionString, DataAccess.DataProvider.SQL)
        Dim dict As New System.Collections.Specialized.HybridDictionary

        'ALTER  proc sp__DeletePage
        '	@PageID int = null,
        '	@UserID int = null,
        '	@JobID int = null,
        '	@WorkflowStatus varchar(50) = 'WORKING'
        iCmd = data.GetCommand("sp__DeletePage", CommandType.StoredProcedure, DataAccess.DataProvider.SQL)
        '@ProductID int = null,
        Dim iParmPageId As IDbDataParameter = data.GetParameter(DataAccess.DataProvider.SQL, "@PageID", DbType.Int32, Me.PageId, 4, ParameterDirection.Input)
        '@UserID int = null,
        Dim iParmUserId As IDbDataParameter = data.GetParameter(DataAccess.DataProvider.SQL, "@UserID", DbType.Int32, Me.LastModBy, 4, ParameterDirection.Input)
        '@JobID int = null,
        Dim iParmJobId As IDbDataParameter = data.GetParameter(DataAccess.DataProvider.SQL, "@JobID", DbType.Int32, Me.JobID, 4, ParameterDirection.Input)
        '@WorkflowStatus varchar(50) = 'WORKING'
        ' no parm -- use default value

        With iCmd.Parameters
            .Add(iParmPageID)
            .Add(iParmJobID)
            .Add(iParmUserID)
        End With

        dict.Add(dict.Count, iCmd)

        Try
            success = data.ExecuteNonQuery(dict)
            Return success
        Catch ex As Exception
            Throw New NLTException("Error deleting a web page.", ex, "WebPage.vb", "Function Delete() As Boolean")
        End Try
    End Function

    Public Sub FillLiveContent() Implements IWebPage.FillLiveContent

        Try

            Dim data As New DataAccess(SiteProfile.GetConnectionString, DataAccess.DataProvider.SQL)
            Dim iCmd As IDbCommand = data.GetCommand("sp__GetPageByID", CommandType.StoredProcedure, DataAccess.DataProvider.SQL)
            Dim iParmId As IDbDataParameter = data.GetParameter(DataAccess.DataProvider.SQL, "@PageID", DbType.Int32, Me.PageId, 4, ParameterDirection.Input)
            Dim iParmLiveMode As IDbDataParameter = data.GetParameter(DataAccess.DataProvider.SQL, "@LiveMode", DbType.Boolean, Me.LiveModeStatus, 1, ParameterDirection.Input)
            With iCmd
                .Parameters.Add(iParmID)
                .Parameters.Add(iParmLiveMode)
            End With

            Dim dt As DataTable = data.GetDataTable(iCmd)
            Dim counter As Integer = 1
            Dim imageModuleCounter As Integer = 1
            Dim collMarkets As New Markets
            Dim collPageModules As New PageModules

            For Each row As DataRow In dt.Rows
                If counter = 1 Then
                    With Me.BusUnit
                        .LiveModeStatus = Me.LiveModeStatus
                        .BusUnitID = Services.GetNULLableInteger(row("BU_ID"))
                        .BusName = Services.GetNULLableString(row("BU_Name"))
                        .DocAuth = Services.GetNULLableBoolean(row("BU_DocAuth"))
                        .PublishDate = Services.GetNULLableDateTime(row("BU_PublishDate"))
                        .ExpireDate = Services.GetNULLableDateTime(row("BU_ExpirationDate"))
                        .ActiveFlag = True
                        .WorkflowStatus = Services.GetNULLableString(row("BU_WorkflowStatus"))
                        With .LogoImage
                            .ImageId = Services.GetNULLableInteger(row("BU_LogoID"))
                            .ImagePath = Services.GetNULLableString(row("BI_ImagePath"))
                            .AltText = Services.GetNULLableString(row("BI_Alt"))
                            .Width = Services.GetNULLableInteger(row("BI_Width"))
                            .Height = Services.GetNULLableInteger(row("BI_Height"))
                            .PublishDate = Services.GetNULLableDateTime(row("BI_PublishDate"))
                            .ExpireDate = Services.GetNULLableDateTime(row("BI_ExpirationDate"))
                            .ActiveFlag = Services.GetNULLableBoolean(row("BI_ActiveFlag"))
                            .WorkflowStatus = Services.GetNULLableString(row("BI_WorkflowStatus"))
                        End With

                        Dim mkt As New Market
                        With mkt
                            .LiveModeStatus = LiveMode.Live
                            .BusUnitID = _mBusUnit.BusUnitID
                            .MarketID = Services.GetNULLableInteger(row("MKT_Id"))
                            .MarketName = Services.GetNULLableString(row("MKT_Name"))
                            .Order = Services.GetNULLableInteger(row("MKT_Order"))
                            .PublishDate = Services.GetNULLableDateTime(row("MKT_PublishDate"))
                            .ExpireDate = Services.GetNULLableDateTime(row("MKT_ExpirationDate"))
                            .ActiveFlag = Services.GetNULLableBoolean(row("MKT_ActiveFlag"))
                            .WorkflowStatus = Services.GetNULLableString(row("MKT_WorkflowStatus"))
                        End With

                        .FillMarkets(Me.LiveModeStatus)

                        ' task #28 - kr - 12/26/06
                        If .BusUnitID = 1 Then
                            .FillPetrofermWithImageModules(Me.LiveModeStatus)
                        End If

                        With Me
                            .CurrentMarket = mkt
                            .Markets = BusUnit.Markets
                            .PageId = Services.GetNULLableInteger(row("PG_Id"))
                            .PageType = Services.GetNULLableString(row("PG_PageType"))
                            .PageTitle = Services.GetNULLableString(row("PG_Title"))
                            .MetaKeywords = Services.GetNULLableString(row("PG_MetaKey"))
                            .MetaDescription = Services.GetNULLableString(row("PG_MetaDesc"))
                            .PassthroughURL = Services.GetNULLableString(row("PG_Passthrough"))
                            .URLRewritePath = Services.GetNULLableString(row("URL_FriendlyName"))
                        End With

                    End With

                    MyBase.PublishDate = Services.GetNULLableDateTime(row("PG_PublishDate"))
                    MyBase.ExpireDate = Services.GetNULLableDateTime(row("PG_ExpirationDate"))
                    MyBase.ActiveFlag = Services.GetNULLableBoolean(row("PG_ActiveFlag"))
                    MyBase.WorkflowStatus = Services.GetNULLableString(row("PG_WorkflowStatus"))
                End If

                Dim sourceName As String = Services.GetNULLableString(row("PM_SourceName"))
                Dim sourceId As Integer = Services.GetNULLableInteger(row("PM_SourceID"))
                Select Case sourceName.ToUpper
                    Case "NAV ON IMAGE", "NAV OFF IMAGE", "HEADER IMAGE", "HEADER SIDE CONTENT IMAGE"
                        Dim imgMod As New ImageModule(sourceId, WorkflowItem.LiveMode.Live)
                        With imgMod
                            .PageModuleRelnId = Services.GetNULLableInteger(row("PM_ModuleId"))
                            .ShowTitle = Services.GetNULLableBoolean(row("PM_ShowTitle"))
                            .ModuleType = sourceName.ToUpper
                            .ModuleOrder = Services.GetNULLableInteger(row("PM_ModuleOrder"))
                            .PublishDate = Services.GetNULLableDateTime(row("PM_PublishDate"))
                            .ExpireDate = Services.GetNULLableDateTime(row("PM_ExpirationDate"))
                            .ActiveFlag = Services.GetNULLableBoolean(row("PM_ActiveFlag"))
                            .WorkflowStatus = Services.GetNULLableString(row("PM_WorkflowStatus"))
                        End With
                        collPageModules.Add(imgMod)
                    Case "HEADER SIDE CONTENT"
                        Dim sideContent As New HeaderSideContentModule(sourceId, Me.LiveModeStatus)
                        collPageModules.Add(sideContent)
                    Case "PRODUCT GRID"
                        Dim gridModule As New ProductGridModule(sourceId, Me.LiveModeStatus)
                        gridModule.DocAuth = Me.BusUnit.DocAuth
                        collPageModules.Add(gridModule)
                    Case "PRODUCT BLURB"
                        Dim blurbModule As New ProductBlurbModule(sourceId, Me.LiveModeStatus)
                        collPageModules.Add(blurbModule)
                    Case "CONTENT", "SIDE CONTENT"
                        Dim contentMod As New ContentModule(sourceId, Me.LiveModeStatus)
                        collPageModules.Add(contentMod)
                    Case "QUESTIONNAIRE"
                    Case "DOCUMENT"
                End Select

                counter += 1

            Next

            Dim topNavList As ArrayList = Nothing
            topNavList = collPageModules.GetSortedModulesBySection(PageModules.PageSection.TopMenuNavigationImage)
            topNavList.Sort(New PageModuleComparer(SortDirection.Descending))
            Me.TopMenuNavigationRegion = topNavList

            Dim headerImageList As ArrayList = Nothing
            headerImageList = collPageModules.GetSortedModulesBySection(PageModules.PageSection.HeaderMenuImage)
            headerImageList.Sort(New PageModuleComparer(SortDirection.Ascending))
            Me.HeaderImageRegion = headerImageList

            Dim headerSideContentList As ArrayList = Nothing
            headerSideContentList = collPageModules.GetSortedModulesBySection(PageModules.PageSection.HeaderSideContent)
            headerSideContentList.Sort(New PageModuleComparer(SortDirection.Ascending))
            Me.HeaderSideContentRegion = headerSideContentList

            Dim headerSideContentImageList As ArrayList = Nothing
            headerSideContentImageList = collPageModules.GetSortedModulesBySection(PageModules.PageSection.HeaderSideImage)
            headerSideContentImageList.Sort(New PageModuleComparer(SortDirection.Ascending))
            Me.HeaderSideImageRegion = headerSideContentImageList

            Dim bodyContentList As ArrayList = Nothing
            bodyContentList = collPageModules.GetSortedModulesBySection(PageModules.PageSection.BodyContent)
            bodyContentList.Sort(New PageModuleComparer(SortDirection.Ascending))
            Me.BodyContentRegion = bodyContentList

            Dim sideBodyContentList As ArrayList = Nothing
            sideBodyContentList = collPageModules.GetSortedModulesBySection(PageModules.PageSection.SideContent)
            sideBodyContentList.Sort(New PageModuleComparer(SortDirection.Ascending))
            Me.SideBodyContentRegion = sideBodyContentList

            Me.PageModules = collPageModules

        Catch ex As Exception
            Throw New NLTException("Error retrieving web page.", ex, "WebPage.vb", "Function FillLiveContent()")
        End Try


    End Sub

    Public Function GetList() As System.Data.DataTable Implements IWebPage.GetList
        Return Nothing
    End Function

    Public Function GetList(ByVal busUnitId As Integer, ByVal mktId As Integer) As System.Data.DataTable
        Try
            Dim data As New DataAccess(SiteProfile.GetConnectionString, DataAccess.DataProvider.SQL)
            Dim iCmd As IDbCommand

            If mktID <> 0 Then ' use different stored proc
                iCmd = data.GetCommand("sp__GetPageListByMarket", CommandType.StoredProcedure, DataAccess.DataProvider.SQL)

                Dim iParmMktId As IDbDataParameter = data.GetParameter(DataAccess.DataProvider.SQL, "@MarketID", DbType.Int32, mktID, 4, ParameterDirection.Input)
                iCmd.Parameters.Add(iParmMktID)
            Else
                iCmd = data.GetCommand("sp__GetPageListByBU", CommandType.StoredProcedure, DataAccess.DataProvider.SQL)
                Dim iParmBusUnitId As IDbDataParameter = data.GetParameter(DataAccess.DataProvider.SQL, "@BusUnitID", DbType.Int32, busUnitID, 4, ParameterDirection.Input)
                iCmd.Parameters.Add(iParmBusUnitID)
            End If

            Dim dt As DataTable = data.GetDataTable(iCmd)
            Return dt

        Catch ex As Exception
            Throw New NLTException("Error retrieving Pages.", ex, "Webpage.vb", "Function GetList(ByVal busUnitID As Integer, ByVal mktID As Integer) As System.Data.DataTable")
        End Try
    End Function

    Public Function GetListByJob(ByVal jobId As Integer) As DataTable
        Try
            Dim data As New DataAccess(SiteProfile.GetConnectionString, DataAccess.DataProvider.SQL)
            Dim iCmd As IDbCommand = data.GetCommand("sp__GetPageListByJobId", CommandType.StoredProcedure, DataAccess.DataProvider.SQL)
            Dim iParmJobId As IDbDataParameter = data.GetParameter(DataAccess.DataProvider.SQL, "@JobID", DbType.Int32, jobID, 4, ParameterDirection.Input)
            iCmd.Parameters.Add(iParmJobID)
            Dim dt As DataTable = data.GetDataTable(iCmd)
            Return dt

        Catch ex As Exception
            Throw New NLTException("Error retrieving Pages by Job.", ex, "Webpage.vb", "Function GetListByJob(ByVal busUnitID As Integer, ByVal mktID As Integer) As System.Data.DataTable")
        End Try
    End Function

    Public Function GetListForInternalLink() As System.Data.DataTable
        Try
            Dim data As New DataAccess(SiteProfile.GetConnectionString, DataAccess.DataProvider.SQL)
            Dim iCmd As IDbCommand = data.GetCommand("sp__GetPageListForInternalLink", CommandType.StoredProcedure, DataAccess.DataProvider.SQL)
            Dim dt As DataTable = data.GetDataTable(iCmd)
            Return dt
        Catch ex As Exception
            Throw New NLTException("Error retrieving Page list for internal links.", ex, "Webpage.vb", "Function GetListForInternalLink() As System.Data.DataTable")
        End Try
    End Function

    Public Function GetPageDefinition() As System.Data.DataTable Implements IWebPage.GetPageDefinition
        Return Nothing
    End Function

    Public Sub FillCmsContent() Implements IWebPage.FillCmsContent
        Try

            Dim data As New DataAccess(SiteProfile.GetConnectionString, DataAccess.DataProvider.SQL)
            Dim strStoredProc As String = ""
            Dim iParmId As IDbDataParameter = Nothing
            Dim iParmLiveMode As IDbDataParameter = Nothing
            Dim iCmd As IDbCommand = Nothing

            If Me.PageId <> 0 Then
                strStoredProc = "sp__GetPageByID"
                iParmID = data.GetParameter(DataAccess.DataProvider.SQL, "@PageID", DbType.Int32, Me.PageId, 4, ParameterDirection.Input)
                iParmLiveMode = data.GetParameter(DataAccess.DataProvider.SQL, "@LiveMode", DbType.Int32, 0, 4, ParameterDirection.Input)


                iCmd = data.GetCommand(strStoredProc, CommandType.StoredProcedure, DataAccess.DataProvider.SQL)
                With iCmd
                    .Parameters.Add(iParmID)
                    .Parameters.Add(iParmLiveMode)
                End With

                Dim dt As DataTable = data.GetDataTable(iCmd)

                If dt.Rows.Count > 0 Then
                    Dim row As DataRow = dt.Rows(0)

                    ' fill properties
                    Me.PageId = Services.GetNULLableInteger(row("PageID"))
                    Me.BusUnit.BusUnitID = Services.GetNULLableInteger(row("BusinessUnitID"))
                    Me.CurrentMarket.MarketID = Services.GetNULLableInteger(row("MarketID"))
                    Me.PageTitle = row("PageTitle").ToString
                    Me.PageType = row("PageType").ToString
                    Me.MetaKeywords = row("MetaKeywords").ToString
                    Me.MetaDescription = row("MetaDescription").ToString
                    Me.PassthroughURL = row("PassthroughURL").ToString
                    Me.IsRequired = Convert.ToBoolean(row("IsRequired"))
                    Me.IsReadOnly = Convert.ToBoolean(row("IsReadOnly"))
                    Me.URLRewritePath = Services.GetNULLableString(row("UrlFriendlyName"))

                    ' set workflow properties
                    Me.PublishDate = Convert.ToDateTime(row("PublishDate"))
                    If row("ExpirationDate") IsNot System.DBNull.Value Then
                        Me.ExpireDate = Convert.ToDateTime(row("ExpirationDate"))
                    End If
                    Me.WorkflowStatus = row("WorkflowStatus").ToString
                    Me.LastModDate = Convert.ToDateTime(row("LastModifiedDate"))
                    Me.LastModBy = Convert.ToInt32(row("LastModifiedBy"))
                    Me.LastModByName = row("LastModifiedByName").ToString
                    Me.MarkedForDelete = Convert.ToInt32(row("MarkedForDeletion"))
                    Me.MarkedForDeleteFmt = row("FmtMarkedForDeletion").ToString
                    Me.JobID = Convert.ToInt32(row("DeploymentJobID"))
                    Me.JobName = row("JobName").ToString
                    Me.JobDescription = row("JobDescription").ToString

                End If
            End If
        Catch ex As Exception
            Throw New NLTException("Error retrieving Page.", ex, "Webpage.vb", "Function FillCMSContent() Implements IWebPage.FillCMSContent")
        End Try


    End Sub

    Public Function Save() As Boolean Implements IWebPage.Save



        Dim success As Boolean
        Dim iCmd As IDbCommand
        Dim iParmPageId As IDbDataParameter

        Dim data As New DataAccess(SiteProfile.GetConnectionString, DataAccess.DataProvider.SQL)
        Dim dict As New System.Collections.Specialized.HybridDictionary
        Dim strStoredProc As String
        Dim iParmFriendlyUrl As IDbDataParameter = Nothing

        ' determine whether item should be added or updated
        '@PageID int = null,
        If Me.PageId = 0 Then
            strStoredProc = "sp__AddWebPage"
            iParmPageID = data.GetParameter(DataAccess.DataProvider.SQL, "@PageID", DbType.Int32, System.DBNull.Value, 4, ParameterDirection.Output)
        Else
            strStoredProc = "sp__UpdateWebPage"
            iParmPageID = data.GetParameter(DataAccess.DataProvider.SQL, "@PageID", DbType.Int32, Me.PageId, 4, ParameterDirection.Input)
            '@URLRewritePath
            iParmFriendlyURL = data.GetParameter(DataAccess.DataProvider.SQL, "@URLRewritePath", DbType.String, Me.URLRewritePath, 500, ParameterDirection.Input)
        End If
        '@BusUnitID int = null, 
        Dim iParmBusId As IDbDataParameter = data.GetParameter(DataAccess.DataProvider.SQL, "@BusUnitID", DbType.Int32, Me.BusUnit.BusUnitID, 4, ParameterDirection.Input)
        '@MarketID int = 0, 
        Dim iParmMarketId As IDbDataParameter = data.GetParameter(DataAccess.DataProvider.SQL, "@MarketID", DbType.Int32, Me.CurrentMarket.MarketID, 4, ParameterDirection.Input)
        '@PageType varchar(50) = 'GENERAL CONTENT', 
        Dim iParmPageType As IDbDataParameter = data.GetParameter(DataAccess.DataProvider.SQL, "@PageType", DbType.String, Me.PageType, 50, ParameterDirection.Input)
        '@PageTitle varchar(100) = null, 
        Dim iParmPageTitle As IDbDataParameter = data.GetParameter(DataAccess.DataProvider.SQL, "@PageTitle", DbType.String, Me.PageTitle, 100, ParameterDirection.Input)
        '@MetaKeywords varchar(1500) = null, 
        Dim iParmMetaKeywords As IDbDataParameter = data.GetParameter(DataAccess.DataProvider.SQL, "@MetaKeywords", DbType.String, Me.MetaKeywords, 1500, ParameterDirection.Input)
        '@MetaDescription varchar(500) = null, 
        Dim iParmMetaDescription As IDbDataParameter = data.GetParameter(DataAccess.DataProvider.SQL, "@MetaDescription", DbType.String, Me.MetaDescription, 500, ParameterDirection.Input)
        '@PassthroughURL varchar(300) = null, 
        Dim iParmPassthroughUrl As IDbDataParameter = data.GetParameter(DataAccess.DataProvider.SQL, "@PassthroughURL", DbType.String, Me.PassthroughURL, 300, ParameterDirection.Input)
        '@IsRequired bit = 0, 
        Dim iParmIsRequired As IDbDataParameter = data.GetParameter(DataAccess.DataProvider.SQL, "@IsRequired", DbType.Boolean, Me.IsRequired, 1, ParameterDirection.Input)
        '@IsReadOnly bit = 1, 
        Dim iParmIsReadOnly As IDbDataParameter = data.GetParameter(DataAccess.DataProvider.SQL, "@IsReadOnly", DbType.Boolean, Me.IsReadOnly, 1, ParameterDirection.Input)
        '@PublishDate datetime = null,
        Dim iParmPublishDate As IDbDataParameter = data.GetParameter(DataAccess.DataProvider.SQL, "@PublishDate", DbType.Date, Me.PublishDate, 8, ParameterDirection.Input)
        '@ExpireDate datetime = null,
        Dim iParmExpireDate As IDbDataParameter
        If Me.ExpireDate <> #12:00:00 AM# Then
            iParmExpireDate = data.GetParameter(DataAccess.DataProvider.SQL, "@ExpireDate", DbType.Date, Me.ExpireDate, 8, ParameterDirection.Input)
        Else
            iParmExpireDate = data.GetParameter(DataAccess.DataProvider.SQL, "@ExpireDate", DbType.Date, System.DBNull.Value, 8, ParameterDirection.Input)
        End If
        '@MarkedForDeletion bit = 0,
        ' just use default value
        '@WorkflowStatus varchar(50) = 'WORKING',
        ' just use default value
        '@JobID int = null,
        Dim iParmJobId As IDbDataParameter = data.GetParameter(DataAccess.DataProvider.SQL, "@JobID", DbType.Int32, Me.JobID, 4, ParameterDirection.Input)
        '@UserID int = null,
        Dim iParmUserId As IDbDataParameter = data.GetParameter(DataAccess.DataProvider.SQL, "@UserID", DbType.Int32, Me.LastModBy, 4, ParameterDirection.Input)

        '' create cmd and add parms
        iCmd = data.GetCommand(strStoredProc, CommandType.StoredProcedure, DataAccess.DataProvider.SQL)
        With iCmd.Parameters
            .Add(iParmPageID)
            .Add(iParmBusID)
            .Add(iParmMarketID)
            .Add(iParmPageType)
            .Add(iParmPageTitle)
            If iParmFriendlyURL IsNot Nothing Then
                .Add(iParmFriendlyURL)
            End If
            .Add(iParmMetaKeywords)
            .Add(iParmMetaDescription)
            .Add(iParmPassthroughURL)
            .Add(iParmIsRequired)
            .Add(iParmIsReadOnly)
            .Add(iParmPublishDate)
            .Add(iParmExpireDate)
            .Add(iParmJobID)
            .Add(iParmUserID)
        End With

        dict.Add(dict.Count, iCmd)

        Try
            success = data.ExecuteNonQuery(dict)
            If success Then
                If Me.PageId = 0 Then
                    ' set the id
                    Me.PageId = iParmPageID.Value
                End If
            End If

            Return success
        Catch ex As Exception
            Throw New NLTException("Error saving Page.", ex, "WebPage.vb", "Function Save() As Boolean")
        End Try
    End Function

    Public Function IsDuplicateUrlFriendlyName() As Boolean

        Try
            Dim data As New DataAccess(SiteProfile.GetConnectionString, DataAccess.DataProvider.SQL)
            Dim dict As New System.Collections.Specialized.HybridDictionary

            Dim strStoredProc As String = ""
            Dim iParmPageId As IDbDataParameter
            Dim iParmFriendlyUrl As IDbDataParameter

            iParmPageID = data.GetParameter(DataAccess.DataProvider.SQL, "@PageID", DbType.Int32, Me.PageId, 4, ParameterDirection.Input)
            '@FriendlyURL
            iParmFriendlyURL = data.GetParameter(DataAccess.DataProvider.SQL, "@FriendlyURL", DbType.String, Me.URLRewritePath, 500, ParameterDirection.Input)

            '@@IsDuplicate bit OUTPUT,
            Dim iParmIsDuplicate As IDbDataParameter = data.GetParameter(DataAccess.DataProvider.SQL, "@IsDuplicate", DbType.Int32, System.DBNull.Value, 1, ParameterDirection.Output)

            Dim iCmd As IDbCommand = data.GetCommand("sp__IsDuplicateUrlFriendlyName", CommandType.StoredProcedure, DataAccess.DataProvider.SQL)

            With iCmd.Parameters
                .Add(iParmPageID)
                .Add(iParmFriendlyURL)
                .Add(iParmIsDuplicate)
            End With

            dict.Add(dict.Count, iCmd)

            If data.ExecuteNonQuery(dict) Then
                Return iParmIsDuplicate.Value
            End If

        Catch ex As Exception
            Throw New NLTException("Error checking for duplicate URL rewrite.", ex, "WebPage.vb", "Public Function IsDuplicateURLFriendlyName() as Boolean")
        End Try

    End Function





End Class
