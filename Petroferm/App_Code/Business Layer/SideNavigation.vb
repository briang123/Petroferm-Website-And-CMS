Imports Microsoft.VisualBasic

Public Class SideNavigation
    Inherits WorkflowItem
    Implements ISideNavigation

    Private _mId As Integer
    Private _mProdCatId As Integer
    Private _mTitle As String
    Private _mDescription As String
    Private _mUrl As String
    Private _mBusinessUnitId As Integer
    Private _mMarketId As Integer
    Private _mPageId As Integer
    Private _mItemOrder As Integer
    Private _mParent As Integer
    Private _mSectionId As Integer
    Private _mLiveModeStatus As LiveMode

    Public Property Id() As Integer Implements ISideNavigation.Id
        Get
            Return _mId
        End Get
        Set(ByVal value As Integer)
            _mId = value
        End Set
    End Property

    Public Property LiveModeStatus() As LiveMode Implements ISideNavigation.LiveModeStatus
        Get
            Return _mLiveModeStatus
        End Get
        Set(ByVal value As LiveMode)
            _mLiveModeStatus = value
        End Set
    End Property

    Public Property BusinessUnitId() As Integer Implements ISideNavigation.BusinessUnitId
        Get
            Return _mBusinessUnitId
        End Get
        Set(ByVal value As Integer)
            _mBusinessUnitId = value
        End Set
    End Property

    Public Property Description() As String Implements ISideNavigation.Description
        Get
            Return _mDescription
        End Get
        Set(ByVal value As String)
            _mDescription = value
        End Set
    End Property

    Public Property ItemOrder() As Integer Implements ISideNavigation.ItemOrder
        Get
            Return _mItemOrder
        End Get
        Set(ByVal value As Integer)
            _mItemOrder = value
        End Set
    End Property

    Public Property MarketId() As Integer Implements ISideNavigation.MarketId
        Get
            Return _mMarketId
        End Get
        Set(ByVal value As Integer)
            _mMarketId = value
        End Set
    End Property

    Public Property PageId() As Integer Implements ISideNavigation.PageId
        Get
            Return _mPageId
        End Get
        Set(ByVal value As Integer)
            _mPageId = value
        End Set
    End Property

    Public Property Parent() As Integer Implements ISideNavigation.Parent
        Get
            Return _mParent
        End Get
        Set(ByVal value As Integer)
            _mParent = value
        End Set
    End Property

    Public Property ProdCatId() As Integer Implements ISideNavigation.ProdCatId
        Get
            Return _mProdCatId
        End Get
        Set(ByVal value As Integer)
            _mProdCatId = value
        End Set
    End Property


    Public Property SectionId() As Integer Implements ISideNavigation.SectionId
        Get
            Return _mSectionId
        End Get
        Set(ByVal value As Integer)
            _mSectionId = value
        End Set
    End Property

    Public Property Title() As String Implements ISideNavigation.Title
        Get
            Return _mTitle
        End Get
        Set(ByVal value As String)
            _mTitle = value
        End Set
    End Property

    Public Property Url() As String Implements ISideNavigation.Url
        Get
            Return _mUrl
        End Get
        Set(ByVal value As String)
            _mUrl = value
        End Set
    End Property



    Public Function GetList() As System.Data.DataTable Implements ISideNavigation.GetList
        Return Nothing
    End Function

    Public Function Delete() As Boolean Implements ISideNavigation.Delete

        Dim success As Boolean
        Dim iCmd As IDbCommand
        Dim data As New DataAccess(SiteProfile.GetConnectionString, DataAccess.DataProvider.SQL)
        Dim dict As New System.Collections.Specialized.HybridDictionary

        'proc(sp__DeleteProductAttribute)
        iCmd = data.GetCommand("sp__DeleteSideNavProdCategory", CommandType.StoredProcedure, DataAccess.DataProvider.SQL)
        '@ProdCatID int = null,
        Dim iParmProdCatId As IDbDataParameter = data.GetParameter(DataAccess.DataProvider.SQL, "@ProdCatID", DbType.Int32, Me.ProdCatID, 4, ParameterDirection.Input)
        '@UserID int = null,
        Dim iParmUserId As IDbDataParameter = data.GetParameter(DataAccess.DataProvider.SQL, "@UserID", DbType.Int32, Me.LastModBy, 4, ParameterDirection.Input)
        '@JobID int = null,
        Dim iParmJobId As IDbDataParameter = data.GetParameter(DataAccess.DataProvider.SQL, "@JobID", DbType.Int32, Me.JobID, 4, ParameterDirection.Input)
        '@WorkflowStatus varchar(50) = 'WORKING'
        ' no parm -- use default value

        With iCmd.Parameters
            .Add(iParmProdCatID)
            .Add(iParmJobID)
            .Add(iParmUserID)
        End With

        dict.Add(dict.Count, iCmd)

        Try
            success = data.ExecuteNonQuery(dict)
            Return success
        Catch ex As Exception
            Throw New NLTException("Error deleting Product Category.", ex, "ProductCategory.vb", "Function Delete() As Boolean")
        End Try


    End Function

    Public Sub Fill() Implements ISideNavigation.Fill
        Try
            Dim data As New DataAccess(SiteProfile.GetConnectionString, DataAccess.DataProvider.SQL)
            Dim dict As New System.Collections.Specialized.HybridDictionary
            Dim strStoredProc As String = ""
            Dim iParmId As IDbDataParameter = Nothing

            ' find out if it's fill by ID or Page ID
            If Me.ID <> 0 Then
                strStoredProc = "sp__GetSideNavByID"
                '@ID int = null,
                iParmID = data.GetParameter(DataAccess.DataProvider.SQL, "@ID", DbType.Int32, Me.ID, 4, ParameterDirection.Input)
            ElseIf Me.PageID <> 0 Then
                strStoredProc = "sp__GetSideNavByPageID"
                '@ID int = null,
                iParmID = data.GetParameter(DataAccess.DataProvider.SQL, "@PageID", DbType.Int32, Me.PageID, 4, ParameterDirection.Input)
            Else
                ' error
            End If

            '@LiveMode bit = 1
            Dim iParmLiveMode As IDbDataParameter = data.GetParameter(DataAccess.DataProvider.SQL, "@LiveMode", DbType.Boolean, Me.LiveModeStatus, 4, ParameterDirection.Input)

            Dim iCmd As IDbCommand = data.GetCommand(strStoredProc, CommandType.StoredProcedure, DataAccess.DataProvider.SQL)
            With iCmd.Parameters
                .Add(iParmID)
                .Add(iParmLiveMode)
            End With

            dict.Add(dict.Count, iCmd)

            Dim dt As DataTable = data.GetDataTable(iCmd)

            If dt.Rows.Count > 0 Then
                Dim row As DataRow = dt.Rows(0)
                ' fill properties
                Me.ID = Services.GetNULLableInteger(row("ID"))
                Me.ProdCatID = Services.GetNULLableInteger(row("ProdCatID"))
                Me.Title = row("Title").ToString
                Me.Description = row("Description").ToString
                Me.URL = row("URL").ToString
                Me.BusinessUnitID = Services.GetNULLableInteger(row("BusinessUnitID"))
                Me.PageID = Services.GetNULLableInteger(row("PageID"))
                Me.ItemOrder = Services.GetNULLableInteger(row("ItemOrder"))
                Me.Parent = Services.GetNULLableInteger(row("Parent"))
                Me.SectionID = Services.GetNULLableInteger(row("SectionID"))

                ' set workflow properties
                Me.PublishDate = Convert.ToDateTime(row("PublishDate"))
                Me.ExpireDate = Convert.ToDateTime(row("ExpirationDate"))
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

        Catch ex As Exception
            Throw New NLTException("Error retrieving Side Navigation.", ex, "ProductCategory.vb", "Function Fill() As Boolean")
        End Try





    End Sub

    Public Function Save() As Boolean Implements ISideNavigation.Save
        Dim success As Boolean
        Dim iCmd As IDbCommand
        Dim iParmId As IDbDataParameter

        Dim data As New DataAccess(SiteProfile.GetConnectionString, DataAccess.DataProvider.SQL)
        Dim dict As New System.Collections.Specialized.HybridDictionary
        Dim strStoredProc As String

        ' determine whether item should be added or updated
        If Me.ID = 0 Then
            strStoredProc = "sp__AddSideNavItem"
            iParmID = data.GetParameter(DataAccess.DataProvider.SQL, "@ID", DbType.Int32, System.DBNull.Value, 4, ParameterDirection.Output)
        Else
            strStoredProc = "sp__UpdateSideNavItem"
            iParmID = data.GetParameter(DataAccess.DataProvider.SQL, "@ID", DbType.Int32, Me.ID, 4, ParameterDirection.Input)
        End If

        '@BusUnitID int = null,
        Dim iParmBusId As IDbDataParameter = data.GetParameter(DataAccess.DataProvider.SQL, "@BusUnitID", DbType.Int32, Me.BusinessUnitID, 4, ParameterDirection.Input)
        '@MarketID int = 0,
        Dim iParmMarketId As IDbDataParameter = data.GetParameter(DataAccess.DataProvider.SQL, "@MarketID", DbType.Int32, Me.MarketID, 4, ParameterDirection.Input)
        '@ProdCatID int = 0, 
        Dim iParmProdCatId As IDbDataParameter = data.GetParameter(DataAccess.DataProvider.SQL, "@ProdCatID", DbType.Int32, Me.ProdCatID, 4, ParameterDirection.Input)
        '@Title varchar(100) = null, 
        Dim iParmTitle As IDbDataParameter = data.GetParameter(DataAccess.DataProvider.SQL, "@Title", DbType.String, Me.Title, 100, ParameterDirection.Input)
        '@Description varchar(500) = null, 
        Dim iParmDescription As IDbDataParameter = data.GetParameter(DataAccess.DataProvider.SQL, "@Description", DbType.String, Me.Description, 500, ParameterDirection.Input)
        '@URL varchar(500) = null, 
        Dim iParmUrl As IDbDataParameter = data.GetParameter(DataAccess.DataProvider.SQL, "@URL", DbType.String, Me.URL, 500, ParameterDirection.Input)
        '@PageID int = 0, 
        Dim iParmPageId As IDbDataParameter = data.GetParameter(DataAccess.DataProvider.SQL, "@PageID", DbType.Int32, Me.PageID, 4, ParameterDirection.Input)
        '@ItemOrder int = null, 
        Dim iParmItemOrder As IDbDataParameter = data.GetParameter(DataAccess.DataProvider.SQL, "@ItemOrder", DbType.Int32, Me.ItemOrder, 4, ParameterDirection.Input)
        '@Parent int = 0, 
        Dim iParmParent As IDbDataParameter = data.GetParameter(DataAccess.DataProvider.SQL, "@Parent", DbType.Int32, Me.Parent, 4, ParameterDirection.Input)
        '@SectionID int = 6, 
        Dim iParmSectionId As IDbDataParameter = data.GetParameter(DataAccess.DataProvider.SQL, "@SectionID", DbType.Int32, Me.SectionID, 4, ParameterDirection.Input)

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
            .Add(iParmID)
            .Add(iParmBusID)
            .Add(iParmMarketID)
            .Add(iParmProdCatID)
            .Add(iParmTitle)
            .Add(iParmDescription)
            .Add(iParmURL)
            .Add(iParmPageID)
            .Add(iParmItemOrder)
            .Add(iParmParent)
            .Add(iParmSectionID)
            .Add(iParmPublishDate)
            .Add(iParmExpireDate)
            .Add(iParmJobID)
            .Add(iParmUserID)
        End With

        dict.Add(dict.Count, iCmd)

        Try
            success = data.ExecuteNonQuery(dict)
            If success Then
                If Me.ID = 0 And iParmID.Value IsNot System.DBNull.Value Then
                    ' set the id
                    Me.ID = iParmID.Value
                End If
            End If

            Return success
        Catch ex As Exception
            Throw New NLTException("Error saving Side Navigation.", ex, "SideNavigation.vb", "Function Save() As Boolean")
        End Try
    End Function

    Public Function GetSectionList() As DataTable
        Try
            Dim data As New DataAccess(SiteProfile.GetConnectionString, DataAccess.DataProvider.SQL)
            Dim iCmd As IDbCommand = data.GetCommand("sp__GetSideNavSections", CommandType.StoredProcedure, DataAccess.DataProvider.SQL)
            Dim dt As DataTable = data.GetDataTable(iCmd)
            Return dt
        Catch ex As Exception
            Throw New NLTException("Error retrieving Side Navigation Sections.", ex, "SideNavigation.vb", "Public Function GetList(ByVal busUnitID As Integer) As DataTable")
        End Try

    End Function
End Class
