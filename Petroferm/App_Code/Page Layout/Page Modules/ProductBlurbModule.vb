Imports Microsoft.VisualBasic

Public Class ProductBlurbModule
    Inherits PageModule
    Implements IProductBlurbModule

    Private _mProductId As Integer
    Private _mProductName As String
    Private _mProductBlurbModuleId As Integer
    Private _mSourceId As Integer
    Private _mProductSelection As String ' will be Individual or Multiple
    Private _mProductIdList As String
    Private _mTitle As String
    Private _mProductBlurb As String
    Private _mLiveModeStatus As WorkflowItem.LiveMode
    Private _mProducts As Products

    Public Sub New(ByVal id As Integer)
        Me.ProductBlurbModuleID = id
    End Sub

    Public Sub New()

    End Sub

    Public Sub New(ByVal id As Integer, ByVal liveMode As WorkflowItem.LiveMode)
        Me.ProductBlurbModuleID = id
        Me.LiveModeStatus = LiveMode
        Me.Fill(LiveMode)
    End Sub

    Public Property Products() As Products Implements IProductBlurbModule.Products
        Get
            Return _mProducts
        End Get
        Set(ByVal value As Products)
            _mProducts = value
        End Set
    End Property

    Public Property ProductBlurb() As String Implements IProductBlurbModule.ProductBlurb
        Get
            Return _mProductBlurb
        End Get
        Set(ByVal value As String)
            _mProductBlurb = value
        End Set
    End Property

    Public Property ProductBlurbModuleId() As Integer Implements IProductBlurbModule.ProductBlurbModuleId
        Get
            Return _mProductBlurbModuleId
        End Get
        Set(ByVal value As Integer)
            _mProductBlurbModuleId = value
        End Set
    End Property

    Public Property ProductSelection() As String Implements IProductBlurbModule.ProductSelection
        Get
            Return _mProductSelection
        End Get
        Set(ByVal value As String)
            _mProductSelection = value.ToUpper
        End Set
    End Property

    Public Property ProductIdList() As String Implements IProductBlurbModule.ProductIdList
        Get
            Return _mProductIdList
        End Get
        Set(ByVal value As String)
            _mProductIdList = value
        End Set
    End Property

    Public Property SourceId() As Integer Implements IProductBlurbModule.SourceId
        Get
            Return _mSourceId
        End Get
        Set(ByVal value As Integer)
            _mSourceId = value
        End Set
    End Property

    Public Property Title() As String Implements IProductBlurbModule.Title
        Get
            Return _mTitle
        End Get
        Set(ByVal value As String)
            _mTitle = value.Trim
        End Set
    End Property

    Public Function Delete() As Boolean Implements IProductBlurbModule.Delete
        Dim success As Boolean
        Dim iCmd As IDbCommand
        Dim data As New DataAccess(SiteProfile.GetConnectionString, DataAccess.DataProvider.SQL)
        Dim dict As New System.Collections.Specialized.HybridDictionary

        'sp__DeleteProductBlurbModule
        iCmd = data.GetCommand("sp__DeleteProductBlurbModule", CommandType.StoredProcedure, DataAccess.DataProvider.SQL)
        '@ProductBlurbModuleID int = null,
        Dim iParmProductBlurbModuleId As IDbDataParameter = data.GetParameter(DataAccess.DataProvider.SQL, "@ProductBlurbModuleID", DbType.Int32, Me.ProductBlurbModuleID, 4, ParameterDirection.Input)
        '@UserID int = null,
        Dim iParmUserId As IDbDataParameter = data.GetParameter(DataAccess.DataProvider.SQL, "@UserID", DbType.Int32, Me.LastModBy, 4, ParameterDirection.Input)
        '@JobID int = null,
        Dim iParmJobId As IDbDataParameter = data.GetParameter(DataAccess.DataProvider.SQL, "@JobID", DbType.Int32, Me.JobID, 4, ParameterDirection.Input)
        '@WorkflowStatus varchar(50) = 'WORKING'
        ' no parm -- use default value

        With iCmd.Parameters
            .Add(iParmProductBlurbModuleID)
            .Add(iParmJobID)
            .Add(iParmUserID)
        End With

        dict.Add(dict.Count, iCmd)

        Try
            success = data.ExecuteNonQuery(dict)
            Return success
        Catch ex As Exception
            Throw New NLTException("Error deleting Product Blurb Module.", ex, "ProductBlurbModule.vb", "Function Delete() As Boolean")
        End Try
    End Function

    Public Sub Fill(ByVal liveMode As Boolean) Implements IProductBlurbModule.Fill

        Try

            Dim data As New DataAccess(SiteProfile.GetConnectionString, DataAccess.DataProvider.SQL)
            Dim strStoredProc As String = ""
            Dim iParmId As IDbDataParameter = Nothing
            Dim iParmLiveMode As IDbDataParameter = Nothing
            Dim iCmd As IDbCommand = Nothing

            '@ProductBlurbModuleId int = null,
            '@LiveMode bit = 1
            If Me.ProductBlurbModuleID <> 0 Then
                strStoredProc = "sp__GetProductBlurbModuleByID"
                iParmID = data.GetParameter(DataAccess.DataProvider.SQL, "@ProductBlurbModuleID", DbType.Int32, Me.ProductBlurbModuleID, 4, ParameterDirection.Input)
                iParmLiveMode = data.GetParameter(DataAccess.DataProvider.SQL, "@LiveMode", DbType.Boolean, liveMode, 1, ParameterDirection.Input)
            End If

            iCmd = data.GetCommand(strStoredProc, CommandType.StoredProcedure, DataAccess.DataProvider.SQL)
            With iCmd
                .Parameters.Add(iParmID)
                .Parameters.Add(iParmLiveMode)
            End With

            Dim dt As DataTable = data.GetDataTable(iCmd)
            If dt.Rows.Count > 0 Then
                Dim row As DataRow = dt.Rows(0)
                ' fill properties

                If liveMode = False Then
                    Me.PageId = Services.GetNULLableInteger(row("PageId"))
                    Me.SourceID = Services.GetNULLableInteger(row("SourceID"))
                End If

                If liveMode = True Then
                    Me.ProductId = Services.GetNULLableInteger(row("ProductId"))
                    Me.ProductName = Services.GetNULLableString(row("ProductName"))
                End If

                Me.PageModuleRelnId = Services.GetNULLableInteger(row("PageModuleRelnId"))
                Me.ModuleOrder = Services.GetNULLableInteger(row("ModuleOrder"))
                Me.ShowTitle = Services.GetNULLableBoolean(row("ShowTitle"))
                Me.ProductBlurbModuleID = Services.GetNULLableInteger(row("ProductBlurbModuleId"))
                Me.ProductSelection = Services.GetNULLableString(row("ProductSelection"))
                Me.Title = Services.GetNULLableString(row("Title"))
                Me.ProductBlurb = Services.GetNULLableString(row("ProductBlurb"))
                ' set workflow properties
                Me.PublishDate = Convert.ToDateTime(row("PublishDate"))
                Me.ExpireDate = Convert.ToDateTime(row("ExpirationDate"))
                Me.WorkflowStatus = row("WorkflowStatus").ToString
                Me.LastModDate = Convert.ToDateTime(row("LastModifiedDate"))
                Me.LastModBy = Convert.ToInt32(row("LastModifiedBy"))
                Me.LastModByName = row("LastModifiedByName").ToString
                Me.MarkedForDelete = Convert.ToInt32(row("MarkedForDeletion"))
                Me.JobID = Services.GetNULLableInteger(row("DeploymentJobID"))
                Me.JobName = Services.GetNULLableString(row("JobName"))
                Me.JobDescription = Services.GetNULLableString(row("JobDescription"))

                If liveMode = True Then

                    Dim prod As Product = Nothing
                    Dim prodColl As New Products
                    If Me.ProductSelection.ToUpper = "INDIVIDUAL" Then
                        prod = New Product(Me.ProductId)
                        prod.Fill()
                        prodColl.Add(prod)
                    Else
                        'just pass a bogus business unit id. we don't need it to get our results
                        Dim dtProd As DataTable = Me.GetProductList(Me.ProductBlurbModuleID, 1, True)
                        For Each prodRow As DataRow In dtProd.Rows
                            prod = New Product(Services.GetNULLableInteger(prodRow("ProductID")))
                            prod.Fill()
                            prodColl.Add(prod)
                        Next
                    End If

                    Me.Products = prodColl

                End If


            End If
        Catch ex As Exception
            Throw New NLTException("Error retrieving Product Blurb Module.", ex, "ProductBlurbModule.vb", "Function Fill(liveMode as boolean) As Boolean")
        End Try



    End Sub

    Public Function GetProductList(ByVal modId As Integer, ByVal busUnitId As Integer, ByVal selected As Boolean) As DataTable Implements IProductBlurbModule.GetProductList
        Try
            Dim data As New DataAccess(SiteProfile.GetConnectionString, DataAccess.DataProvider.SQL)
            Dim iCmd As IDbCommand = data.GetCommand("sp__GetProductBlurbModuleRelnsByProduct", CommandType.StoredProcedure, DataAccess.DataProvider.SQL)

            Dim iParmProductBlurbModuleId As IDbDataParameter = data.GetParameter(DataAccess.DataProvider.SQL, "@ProductBlurbModuleID", DbType.Int32, modID, 4, ParameterDirection.Input)
            Dim iParmBusUnitId As IDbDataParameter = data.GetParameter(DataAccess.DataProvider.SQL, "@BusUnitID", DbType.Int32, busUnitID, 4, ParameterDirection.Input)

            '@Selected bit = 0,-- this is for getting selected/unselected for product
            Dim iParmSelected As IDbDataParameter = data.GetParameter(DataAccess.DataProvider.SQL, "@Selected", DbType.Boolean, selected, 1, ParameterDirection.Input)
            Dim iParmLiveMode As IDbDataParameter = data.GetParameter(DataAccess.DataProvider.SQL, "@LiveMode", DbType.Boolean, Me.LiveModeStatus, 1, ParameterDirection.Input)

            With iCmd.Parameters
                .Add(iParmProductBlurbModuleID)
                .Add(iParmBusUnitID)
                .Add(iParmSelected)
                .Add(iParmLiveMode)
            End With

            Dim dt As DataTable = data.GetDataTable(iCmd)
            If Not dt Is Nothing Then
                Return dt
            Else
                ' just return empty datatable
                dt = New DataTable
                Return dt
            End If

        Catch ex As Exception
            Throw New NLTException("Error retrieving Products for Product Blurb.", ex, "ProductBlurbModule.vb", "Public Function GetProductList(ByVal modID As Integer, ByVal busUnitID As Integer, ByVal selected As Boolean) As Object Implements IProductBlurbModule.GetProductList")
        End Try

    End Function

    Public Function Save() As Boolean Implements IProductBlurbModule.Save
        Dim success As Boolean
        Dim iCmd As IDbCommand
        Dim iParmProductBlurbModuleId As IDbDataParameter
        Dim iParmPageModuleRelnId As IDbDataParameter = Nothing
        Dim iParmPageId As IDbDataParameter = Nothing
        Dim iParmModuleType As IDbDataParameter = Nothing

        Dim data As New DataAccess(SiteProfile.GetConnectionString, DataAccess.DataProvider.SQL)
        Dim dict As New System.Collections.Specialized.HybridDictionary
        Dim strStoredProc As String

        ' determine whether item should be added or updated
        If Me.ProductBlurbModuleID = 0 Then
            strStoredProc = "sp__AddProductBlurbModule"
            '@PageID int = null,
            iParmPageID = data.GetParameter(DataAccess.DataProvider.SQL, "@PageID", DbType.Int32, Me.PageId, 4, ParameterDirection.Input)
            iParmProductBlurbModuleID = data.GetParameter(DataAccess.DataProvider.SQL, "@ProductBlurbModuleID", DbType.Int32, System.DBNull.Value, 4, ParameterDirection.Output)
            iParmPageModuleRelnID = data.GetParameter(DataAccess.DataProvider.SQL, "@PageModuleRelnID", DbType.Int32, System.DBNull.Value, 4, ParameterDirection.Output)
            '@ModuleType varchar(50) = 'PRODUCT BLURB',
            iParmModuleType = data.GetParameter(DataAccess.DataProvider.SQL, "@ModuleType", DbType.String, Me.ModuleType, 50, ParameterDirection.Input)
        Else
            strStoredProc = "sp__UpdateProductBlurbModule"
            iParmProductBlurbModuleID = data.GetParameter(DataAccess.DataProvider.SQL, "@ProductBlurbModuleID", DbType.Int32, Me.ProductBlurbModuleID, 4, ParameterDirection.Input)
        End If

        '@ProductID int = 0, (it's actually source ID of the object -- will be 0 for multi-product blurbs
        Dim iParmProductId As IDbDataParameter = data.GetParameter(DataAccess.DataProvider.SQL, "@ProductID", DbType.Int32, Me.SourceID, 4, ParameterDirection.Input)
        '@ProductIDList varchar(100) = '',
        Dim iParmProductIdList As IDbDataParameter = data.GetParameter(DataAccess.DataProvider.SQL, "@ProductIDList", DbType.String, Me.ProductIDList, 100, ParameterDirection.Input)
        '@ProductSelection varchar(20) = 'INDIVIDUAL',
        Dim iParmProductSelection As IDbDataParameter = data.GetParameter(DataAccess.DataProvider.SQL, "@ProductSelection", DbType.String, Me.ProductSelection, 20, ParameterDirection.Input)
        '@ProductBlurb varchar(2000) = null,
        Dim iParmProductBlurb As IDbDataParameter = data.GetParameter(DataAccess.DataProvider.SQL, "@ProductBlurb", DbType.String, Me.ProductBlurb, 2000, ParameterDirection.Input)
        '@ModuleOrder int = null,
        Dim iParmModuleOrder As IDbDataParameter = data.GetParameter(DataAccess.DataProvider.SQL, "@ModuleOrder", DbType.Int32, Me.ModuleOrder, 4, ParameterDirection.Input)
        '@ShowTitle bit = 0,
        Dim iParmShowTitle As IDbDataParameter = data.GetParameter(DataAccess.DataProvider.SQL, "@ShowTitle", DbType.Boolean, Me.ShowTitle, 1, ParameterDirection.Input)
        '@Title varchar(50) = null,
        Dim iParmTitle As IDbDataParameter = data.GetParameter(DataAccess.DataProvider.SQL, "@Title", DbType.String, Me.Title, 50, ParameterDirection.Input)
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
            .Add(iParmProductBlurbModuleID)
            If iParmPageID IsNot Nothing Then
                .Add(iParmPageID)
            End If
            If iParmPageModuleRelnID IsNot Nothing Then
                .Add(iParmPageModuleRelnID)
            End If
            If iParmModuleType IsNot Nothing Then
                .Add(iParmModuleType)
            End If
            .Add(iParmProductID)
            .Add(iParmProductIDList)
            .Add(iParmProductSelection)
            .Add(iParmProductBlurb)
            .Add(iParmModuleOrder)
            .Add(iParmShowTitle)
            .Add(iParmTitle)
            .Add(iParmPublishDate)
            .Add(iParmExpireDate)
            .Add(iParmJobID)
            .Add(iParmUserID)
        End With

        dict.Add(dict.Count, iCmd)

        Try
            success = data.ExecuteNonQuery(dict)
            If success Then
                If Me.ProductBlurbModuleID = 0 And iParmProductBlurbModuleID.Value IsNot System.DBNull.Value Then
                    ' set the id
                    Me.ProductBlurbModuleID = iParmProductBlurbModuleID.Value
                End If
            End If

            Return success
        Catch ex As Exception
            Throw New NLTException("Error saving Product Blurb Module.", ex, "ProductBlurbModule.vb", "Function Save() As Boolean")
        End Try


    End Function

    Public Property LiveModeStatus() As WorkflowItem.LiveMode Implements IProductBlurbModule.LiveModeStatus
        Get
            Return _mLiveModeStatus
        End Get
        Set(ByVal value As WorkflowItem.LiveMode)
            _mLiveModeStatus = value
        End Set
    End Property

    Public Property ProductId() As Integer Implements IProductBlurbModule.ProductId
        Get
            Return _mProductId
        End Get
        Set(ByVal value As Integer)
            _mProductId = value
        End Set
    End Property

    Public Property ProductName() As String Implements IProductBlurbModule.ProductName
        Get
            Return _mProductName
        End Get
        Set(ByVal value As String)
            _mProductName = value
        End Set
    End Property
End Class