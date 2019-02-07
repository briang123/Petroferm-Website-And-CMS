Imports Microsoft.VisualBasic

Public Class ProductCategory
    Inherits WorkflowItem
    Implements IProductCategory
    Dim _mBusinessUnitId As Integer
    Dim _mCategoryDescription As String
    Dim _mCategoryId As Integer
    Dim _mCategoryName As String
    Dim _mCategoryOrder As Integer
    Dim _mMarketId As Integer
    Dim _mProducts As New Hashtable

    Sub New()

    End Sub

    Sub New(ByVal id As Integer)
        Me.CategoryID = id
    End Sub
    Public Property BusinessUnitId() As Integer Implements IProductCategory.BusinessUnitId
        Get
            Return _mBusinessUnitId
        End Get
        Set(ByVal value As Integer)
            _mBusinessUnitId = value
        End Set
    End Property

    Public Property CategoryDescription() As String Implements IProductCategory.CategoryDescription
        Get
            Return _mCategoryDescription
        End Get
        Set(ByVal value As String)
            _mCategoryDescription = value
        End Set
    End Property

    Public Property CategoryId() As Integer Implements IProductCategory.CategoryId
        Get
            Return _mCategoryId
        End Get
        Set(ByVal value As Integer)
            _mCategoryId = value
        End Set
    End Property

    Public Property CategoryName() As String Implements IProductCategory.CategoryName
        Get
            Return _mCategoryName
        End Get
        Set(ByVal value As String)
            _mCategoryName = value
        End Set
    End Property

    Public Property CategoryOrder() As Integer Implements IProductCategory.CategoryOrder
        Get
            Return _mCategoryOrder
        End Get
        Set(ByVal value As Integer)
            _mCategoryOrder = value
        End Set
    End Property

    Public Function Delete() As Boolean Implements IProductCategory.Delete

        Dim success As Boolean
        Dim iCmd As IDbCommand
        Dim data As New DataAccess(SiteProfile.GetConnectionString, DataAccess.DataProvider.SQL)
        Dim dict As New System.Collections.Specialized.HybridDictionary

        'proc(sp__DeleteProductAttribute)
        iCmd = data.GetCommand("sp__DeleteSideNavProdCategory", CommandType.StoredProcedure, DataAccess.DataProvider.SQL)
        '@ProdCatID int = null,
        Dim iParmProdCatId As IDbDataParameter = data.GetParameter(DataAccess.DataProvider.SQL, "@ProdCatID", DbType.Int32, Me.CategoryID, 4, ParameterDirection.Input)
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

    Public Sub Fill() Implements IProductCategory.Fill
        Try
            Dim data As New DataAccess(SiteProfile.GetConnectionString, DataAccess.DataProvider.SQL)
            Dim dict As New System.Collections.Specialized.HybridDictionary

            Dim strStoredProc As String = "sp__GetSideNavProdCategoryByID"

            '@ProdCatID int = null,
            Dim iParmProdCatId As IDbDataParameter = data.GetParameter(DataAccess.DataProvider.SQL, "@ProdCatID", DbType.Int32, Me.CategoryID, 4, ParameterDirection.Input)
            '@BusUnitID int OUTPUT,
            Dim iParmBusUnitId As IDbDataParameter = data.GetParameter(DataAccess.DataProvider.SQL, "@BusUnitID", DbType.Int32, System.DBNull.Value, 4, ParameterDirection.Output)
            '@MarketID int OUTPUT,
            Dim iParmMarketId As IDbDataParameter = data.GetParameter(DataAccess.DataProvider.SQL, "@MarketID", DbType.Int32, System.DBNull.Value, 4, ParameterDirection.Output)
            '@CategoryName varchar(50) OUTPUT,
            Dim iParmCategoryName As IDbDataParameter = data.GetParameter(DataAccess.DataProvider.SQL, "@CategoryName", DbType.String, String.Empty, 50, ParameterDirection.Output)
            '@CategoryOrder int OUTPUT,
            Dim iParmCategoryOrder As IDbDataParameter = data.GetParameter(DataAccess.DataProvider.SQL, "@CategoryOrder", DbType.Int32, System.DBNull.Value, 4, ParameterDirection.Output)
            '@PublishDate datetime OUTPUT,
            Dim iParmPublishDate As IDbDataParameter = data.GetParameter(DataAccess.DataProvider.SQL, "@PublishDate", DbType.Date, System.DBNull.Value, 8, ParameterDirection.Output)
            '@ExpireDate datetime OUTPUT,
            Dim iParmExpireDate As IDbDataParameter = data.GetParameter(DataAccess.DataProvider.SQL, "@ExpireDate", DbType.Date, System.DBNull.Value, 8, ParameterDirection.Output)
            '@WorkflowStatus varchar(50) OUTPUT,
            Dim iParmWorkflowStatus As IDbDataParameter = data.GetParameter(DataAccess.DataProvider.SQL, "@WorkflowStatus", DbType.String, System.DBNull.Value, 50, ParameterDirection.Output)
            '@LastModifiedDate datetime OUTPUT,
            Dim iParmLastModifiedDate As IDbDataParameter = data.GetParameter(DataAccess.DataProvider.SQL, "@LastModifiedDate", DbType.Date, System.DBNull.Value, 8, ParameterDirection.Output)
            '@LastModifiedBy int OUTPUT,
            Dim iParmLastModifiedBy As IDbDataParameter = data.GetParameter(DataAccess.DataProvider.SQL, "@LastModifiedBy", DbType.Int32, System.DBNull.Value, 4, ParameterDirection.Output)
            '@LastModifiedByName varchar(150) OUTPUT,
            Dim iParmLastModifiedByName As IDbDataParameter = data.GetParameter(DataAccess.DataProvider.SQL, "@LastModifiedByName", DbType.String, System.DBNull.Value, 150, ParameterDirection.Output)
            '@FmtMarkedForDeletion varchar(3) OUTPUT,
            Dim iParmFmtMarkedForDeletion As IDbDataParameter = data.GetParameter(DataAccess.DataProvider.SQL, "@FmtMarkedForDeletion", DbType.String, String.Empty, 3, ParameterDirection.Output)
            '@MarkedForDeletion bit OUTPUT,
            Dim iParmMarkedForDeletion As IDbDataParameter = data.GetParameter(DataAccess.DataProvider.SQL, "@MarkedForDeletion", DbType.Int32, System.DBNull.Value, 1, ParameterDirection.Output)
            '@JobID int OUTPUT,
            Dim iParmJobId As IDbDataParameter = data.GetParameter(DataAccess.DataProvider.SQL, "@JobID", DbType.Int32, JobID, 4, ParameterDirection.Output)
            '@JobName varchar(100) OUTPUT,
            Dim iParmJobName As IDbDataParameter = data.GetParameter(DataAccess.DataProvider.SQL, "@JobName", DbType.String, System.DBNull.Value, 100, ParameterDirection.Output)
            '@JobDescription varchar(500) OUTPUT
            Dim iParmJobDescription As IDbDataParameter = data.GetParameter(DataAccess.DataProvider.SQL, "@JobDescription", DbType.String, System.DBNull.Value, 500, ParameterDirection.Output)

            Dim iCmd As IDbCommand = data.GetCommand(strStoredProc, CommandType.StoredProcedure, DataAccess.DataProvider.SQL)
            With iCmd.Parameters
                .Add(iParmProdCatID)
                .Add(iParmBusUnitID)
                .Add(iParmMarketID)
                .Add(iParmCategoryName)
                .Add(iParmCategoryOrder)
                .Add(iParmPublishDate)
                .Add(iParmExpireDate)
                .Add(iParmWorkflowStatus)
                .Add(iParmLastModifiedDate)
                .Add(iParmLastModifiedBy)
                .Add(iParmLastModifiedByName)
                .Add(iParmFmtMarkedForDeletion)
                .Add(iParmMarkedForDeletion)
                .Add(iParmJobID)
                .Add(iParmJobName)
                .Add(iParmJobDescription)
            End With

            dict.Add(dict.Count, iCmd)

            If data.ExecuteNonQuery(dict) Then

                ' check to make sure something came back
                If Not iParmBusUnitID.Value Is System.DBNull.Value Then
                    ' fill properties
                    Me.BusinessUnitID = Services.GetNULLableInteger(iParmBusUnitID.Value)
                    Me.MarketID = Services.GetNULLableInteger(iParmMarketID.Value)
                    Me.CategoryName = iParmCategoryName.Value.ToString
                    Me.CategoryOrder = Services.GetNULLableInteger(iParmCategoryOrder.Value)
                    ' fill workflow properties
                    Me.WorkflowStatus = iParmWorkflowStatus.Value.ToString
                    Me.MarkedForDelete = Services.GetNULLableInteger(iParmMarkedForDeletion.Value)
                    Me.MarkedForDeleteFmt = iParmFmtMarkedForDeletion.Value.ToString
                    Me.PublishDate = Services.GetNULLableDateTime(iParmPublishDate.Value)
                    Me.ExpireDate = Services.GetNULLableDateTime(iParmExpireDate.Value)
                    Me.LastModDate = Services.GetNULLableDateTime(iParmLastModifiedDate.Value)
                    Me.LastModBy = Services.GetNULLableInteger(iParmLastModifiedBy.Value)
                    Me.LastModByName = iParmLastModifiedByName.Value.ToString
                    Me.JobID = Services.GetNULLableInteger(iParmJobID.Value)
                    Me.JobName = iParmJobName.Value.ToString
                    Me.JobDescription = iParmJobDescription.Value.ToString
                Else
                    Dim ex As New Exception("No Product Attribute was returned for Product Category ID " & Me.CategoryID)
                    Throw New NLTException("Error retrieving Product Category.", ex, "ProductCategory.vb", "Function Fill() As Boolean")
                End If
            End If

        Catch ex As Exception
            Throw New NLTException("Error retrieving Product Category.", ex, "ProductCategory.vb", "Function Fill() As Boolean")
        End Try





    End Sub

    Public Function GetList(ByVal busUnitId As Integer) As System.Data.DataTable Implements IProductCategory.GetList
        Try

            Dim data As New DataAccess(SiteProfile.GetConnectionString, DataAccess.DataProvider.SQL)
            Dim iCmd As IDbCommand = data.GetCommand("sp__GetSideNavProdCategories", CommandType.StoredProcedure, DataAccess.DataProvider.SQL)

            ' PROC(sp__GetProductAttributesByBU)
            '	@BusUnitID int = null,
            Dim iParmBusUnitId As IDbDataParameter = data.GetParameter(DataAccess.DataProvider.SQL, "@BusUnitID", DbType.Int32, busUnitID, 4, ParameterDirection.Input)
            '	@LiveMode bit = 0
            ' (parm not needed)
            iCmd.Parameters.Add(iParmBusUnitID)
            Dim dt As DataTable = data.GetDataTable(iCmd)
            If Not dt Is Nothing Then
                Return dt
            Else
                ' just return empty datatable
                dt = New DataTable
                Return dt
            End If


        Catch ex As Exception
            Throw New NLTException("Error retrieving Product Category List.", ex, "ProductCategory.vb", "Public Function GetList(ByVal busUnitID As Integer) As DataTable Implements IProduct.GetList")
        End Try
    End Function

    Public Property MarketId() As Integer Implements IProductCategory.MarketId
        Get
            Return _mMarketId
        End Get
        Set(ByVal value As Integer)
            _mMarketId = value
        End Set
    End Property

    Public Property Products() As System.Collections.Hashtable Implements IProductCategory.Products
        Get
            Return _mProducts
        End Get
        Set(ByVal value As System.Collections.Hashtable)
            _mProducts = value
        End Set
    End Property

    Public Function Save() As Boolean Implements IProductCategory.Save
        Dim success As Boolean
        Dim iCmd As IDbCommand
        Dim iParmId As IDbDataParameter

        Dim data As New DataAccess(SiteProfile.GetConnectionString, DataAccess.DataProvider.SQL)
        Dim dict As New System.Collections.Specialized.HybridDictionary
        Dim strStoredProc As String

        ' determine whether item should be added or updated
        If Me.CategoryID = 0 Then
            strStoredProc = "sp__AddSideNavProdCategory"
            iParmID = data.GetParameter(DataAccess.DataProvider.SQL, "@ProdCatID", DbType.Int32, System.DBNull.Value, 4, ParameterDirection.Output)
        Else
            strStoredProc = "sp__UpdateSideNavProdCategory"
            iParmID = data.GetParameter(DataAccess.DataProvider.SQL, "@ProdCatID", DbType.Int32, Me.CategoryID, 4, ParameterDirection.Input)
        End If

        '@BusUnitID int = null,
        Dim iParmBusId As IDbDataParameter = data.GetParameter(DataAccess.DataProvider.SQL, "@BusUnitID", DbType.Int32, Me.BusinessUnitID, 4, ParameterDirection.Input)
        '@MarketID int = 0,
        Dim iParmMarketId As IDbDataParameter = data.GetParameter(DataAccess.DataProvider.SQL, "@MarketID", DbType.Int32, Me.MarketID, 4, ParameterDirection.Input)

        '@CategoryName varchar(50) = null,
        Dim iParmCategoryName As IDbDataParameter = data.GetParameter(DataAccess.DataProvider.SQL, "@CategoryName", DbType.String, Me.CategoryName, 50, ParameterDirection.Input)
        '@CategoryOrder int = null,
        Dim iParmCategoryOrder As IDbDataParameter = data.GetParameter(DataAccess.DataProvider.SQL, "@CategoryOrder", DbType.Int32, Me.CategoryOrder, 4, ParameterDirection.Input)

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
            .Add(iParmCategoryName)
            .Add(iParmCategoryOrder)
            .Add(iParmPublishDate)
            .Add(iParmExpireDate)
            .Add(iParmJobID)
            .Add(iParmUserID)
        End With

        dict.Add(dict.Count, iCmd)

        Try
            success = data.ExecuteNonQuery(dict)
            If success Then
                If Me.CategoryID = 0 And iParmID.Value IsNot System.DBNull.Value Then
                    ' set the id
                    Me.CategoryID = iParmID.Value
                End If
            End If

            Return success
        Catch ex As Exception
            Throw New NLTException("Error saving Product Category.", ex, "ProductCategory.vb", "Function Save() As Boolean")
        End Try
    End Function
End Class
