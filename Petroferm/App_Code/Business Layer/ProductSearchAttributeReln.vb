Imports Microsoft.VisualBasic

Public Class ProductSearchAttributeReln
    Inherits WorkflowItem
    Implements IProductSearchAttributeReln
    Private _mProdSearchAttribRelnId As Integer
    Private _mProductId As Integer
    Private _mSearchAttribTypeId As Integer
    Public Sub New()

    End Sub
    Public Sub New(ByVal id As Integer)
        ProdSearchAttribRelnID = id
    End Sub

    Public Property ProdSearchAttribRelnId() As Integer Implements IProductSearchAttributeReln.ProdSearchAttribRelnId
        Get
            Return _mProdSearchAttribRelnId
        End Get
        Set(ByVal value As Integer)
            _mProdSearchAttribRelnId = value
        End Set
    End Property

    Public Property ProductId() As Integer Implements IProductSearchAttributeReln.ProductId
        Get
            Return _mProductId
        End Get
        Set(ByVal value As Integer)
            _mProductId = value
        End Set
    End Property

    Public Property SearchAttribTypeId() As Integer Implements IProductSearchAttributeReln.SearchAttribTypeId
        Get
            Return _mSearchAttribTypeId
        End Get
        Set(ByVal value As Integer)
            _mSearchAttribTypeId = value
        End Set
    End Property

    Public Function Save() As Boolean Implements IProductSearchAttributeReln.Save
        Dim success As Boolean
        Dim iCmd As IDbCommand
        Dim iParmProdSearchAttribRelnId As IDbDataParameter

        Dim data As New DataAccess(SiteProfile.GetConnectionString, DataAccess.DataProvider.SQL)
        Dim dict As New System.Collections.Specialized.HybridDictionary
        Dim strStoredProc As String

        ' determine whether item should be added or updated
        '@ProdSearchAttribRelnID int OUTPUT
        If Me.ProdSearchAttribRelnID = 0 Then
            strStoredProc = "sp__AddProductSearchAttributeReln"
            iParmProdSearchAttribRelnID = data.GetParameter(DataAccess.DataProvider.SQL, "@ProdSearchAttribRelnID", DbType.Int32, System.DBNull.Value, 4, ParameterDirection.Output)
        Else
            strStoredProc = "sp__UpdateProductSearchAttributeReln"
            iParmProdSearchAttribRelnID = data.GetParameter(DataAccess.DataProvider.SQL, "@ProdSearchAttribRelnID", DbType.Int32, Me.ProdSearchAttribRelnID, 4, ParameterDirection.Input)
        End If

        '@ProductID int = null,
        Dim iParmProductId As IDbDataParameter = data.GetParameter(DataAccess.DataProvider.SQL, "@ProductID", DbType.Int32, Me.ProductID, 4, ParameterDirection.Input)
        '@SearchAttribTypeID int = null,
        Dim iParmSearchAttribTypeId As IDbDataParameter = data.GetParameter(DataAccess.DataProvider.SQL, "@SearchAttribTypeID", DbType.Int32, Me.SearchAttribTypeID, 4, ParameterDirection.Input)
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
            .Add(iParmProdSearchAttribRelnID)
            .Add(iParmProductID)
            .Add(iParmSearchAttribTypeID)
            .Add(iParmPublishDate)
            .Add(iParmExpireDate)
            .Add(iParmJobID)
            .Add(iParmUserID)
        End With

        dict.Add(dict.Count, iCmd)

        Try
            success = data.ExecuteNonQuery(dict)
            If success Then
                If Me.ProdSearchAttribRelnID = 0 Then
                    ' set the id
                    Me.ProdSearchAttribRelnID = Services.GetNULLableInteger(iParmProdSearchAttribRelnID.Value)
                End If
            End If

            Return success
        Catch ex As Exception
            Throw New NLTException("Error saving Product Search Attribute Relationship.", ex, "ProductSearchAttributeReln.vb", "Function Save() As Boolean")
        End Try
    End Function

    Public Function Delete() As Boolean Implements IProductSearchAttributeReln.Delete
        Dim success As Boolean
        Dim iCmd As IDbCommand
        Dim data As New DataAccess(SiteProfile.GetConnectionString, DataAccess.DataProvider.SQL)
        Dim dict As New System.Collections.Specialized.HybridDictionary

        'proc(sp__DeleteProductAttributeReln)
        iCmd = data.GetCommand("sp__DeleteProductSearchAttributeReln", CommandType.StoredProcedure, DataAccess.DataProvider.SQL)
        '@ProdAttribRelnID int = null,
        Dim iParmProdSearchAttribRelnId As IDbDataParameter = data.GetParameter(DataAccess.DataProvider.SQL, "@ProdSearchAttribRelnID", DbType.Int32, Me.ProdSearchAttribRelnID, 4, ParameterDirection.Input)
        '@UserID int = null,
        Dim iParmUserId As IDbDataParameter = data.GetParameter(DataAccess.DataProvider.SQL, "@UserID", DbType.Int32, Me.LastModBy, 4, ParameterDirection.Input)
        '@JobID int = null,
        Dim iParmJobId As IDbDataParameter = data.GetParameter(DataAccess.DataProvider.SQL, "@JobID", DbType.Int32, Me.JobID, 4, ParameterDirection.Input)
        '@WorkflowStatus varchar(50) = 'WORKING'
        ' no parm -- use default value

        With iCmd.Parameters
            .Add(iParmProdSearchAttribRelnID)
            .Add(iParmJobID)
            .Add(iParmUserID)
        End With

        dict.Add(dict.Count, iCmd)

        Try
            success = data.ExecuteNonQuery(dict)
            Return success
        Catch ex As Exception
            Throw New NLTException("Error deleting Product Attribute Value.", ex, "ProductAttributeValue.vb", "Function Delete() As Boolean")
        End Try
    End Function

    Public Sub Fill() Implements IProductSearchAttributeReln.Fill

    End Sub

    Public Function GetList(ByVal searchAttribTypeId As Integer, ByVal prodId As Integer) As System.Data.DataTable Implements IProductSearchAttributeReln.GetList
        Return Nothing
    End Function

    Function GetListByProduct(ByVal productId As Integer, ByVal busUnitId As Integer, ByVal mktId As Integer, ByVal selected As Boolean) As DataTable
        Try
            Dim data As New DataAccess(SiteProfile.GetConnectionString, DataAccess.DataProvider.SQL)

            Dim iCmd As IDbCommand = data.GetCommand("sp__GetProductSearchAttributeRelnsByProduct", CommandType.StoredProcedure, DataAccess.DataProvider.SQL)

            '	@ProductID int = null,
            Dim iParmProductId As IDbDataParameter = data.GetParameter(DataAccess.DataProvider.SQL, "@ProductID", DbType.Int32, productID, 4, ParameterDirection.Input)

            '	@BusUnitID int = null,
            Dim iParmBusUnitId As IDbDataParameter = data.GetParameter(DataAccess.DataProvider.SQL, "@BusUnitID", DbType.Int32, busUnitID, 4, ParameterDirection.Input)


            '	@MarketID int = null,
            ' if market id = 0, get ALL markets
            Dim iParmMarketId As IDbDataParameter = data.GetParameter(DataAccess.DataProvider.SQL, "@MarketID", DbType.Int32, mktID, 4, ParameterDirection.Input)

            '@Selected bit = 0,
            Dim iParmSelected As IDbDataParameter = data.GetParameter(DataAccess.DataProvider.SQL, "@Selected", DbType.Boolean, Selected, 1, ParameterDirection.Input)


            '	@LiveMode bit = 0
            ' (parm not needed)
            With iCmd.Parameters
                .Add(iParmProductID)
                .Add(iParmBusUnitID)
                .Add(iParmMarketID)
                .Add(iParmSelected)
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
            Throw New NLTException("Error retrieving Search Attributes by Product.", ex, "SearchAttribute.vb", "Public Function GetList(ByVal mktID As Integer) As DataTable Implements ISearchAttribute.GetList")
        End Try
    End Function

    Function GetListByAttrib(ByVal searchAttribId As Integer, ByVal busUnitId As Integer, ByVal selected As Boolean) As DataTable
        Try
            Dim data As New DataAccess(SiteProfile.GetConnectionString, DataAccess.DataProvider.SQL)

            Dim iCmd As IDbCommand = data.GetCommand("sp__GetProductSearchAttributeRelnsByAttrib", CommandType.StoredProcedure, DataAccess.DataProvider.SQL)

            '@SearchAttribTypeID int = null,
            Dim iParmSearchAttribTypeId As IDbDataParameter = data.GetParameter(DataAccess.DataProvider.SQL, "@SearchAttribTypeID", DbType.Int32, searchAttribID, 4, ParameterDirection.Input)
            Dim iParmBusUnitId As IDbDataParameter = data.GetParameter(DataAccess.DataProvider.SQL, "@BusUnitID", DbType.Int32, busUnitID, 4, ParameterDirection.Input)

            '@Selected bit = 0,
            Dim iParmSelected As IDbDataParameter = data.GetParameter(DataAccess.DataProvider.SQL, "@Selected", DbType.Boolean, Selected, 1, ParameterDirection.Input)


            '	@LiveMode bit = 0
            ' (parm not needed)
            With iCmd.Parameters
                .Add(iParmSearchAttribTypeID)
                .Add(iParmBusUnitID)
                .Add(iParmSelected)
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
            Throw New NLTException("Error retrieving Search Attributes by Product.", ex, "SearchAttribute.vb", "Public Function GetList(ByVal mktID As Integer) As DataTable Implements ISearchAttribute.GetList")
        End Try
    End Function
End Class
