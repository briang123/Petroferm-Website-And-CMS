Imports Microsoft.VisualBasic

Public Class ProductAttributeValue
    Inherits WorkflowItem
    Implements IProductAttributeValue
    Private _mProductId As Integer
    Private _mAttribType As New ProductAttribute
    Private _mAttribValue As String
    Private _mProdAttribRelnId As Integer
    Public Sub New()

    End Sub
    Public Sub New(ByVal prodAttRelnId As Integer)
        ProdAttribRelnID = prodAttRelnID
    End Sub
    Public Property AttribType() As ProductAttribute Implements IProductAttributeValue.AttribType
        Get
            Return _mAttribType
        End Get
        Set(ByVal value As ProductAttribute)
            _mAttribType = value
        End Set
    End Property
    Public Property ProdAttribRelnId() As Integer Implements IProductAttributeValue.ProdAttribRelnId
        Get
            Return _mProdAttribRelnId
        End Get
        Set(ByVal value As Integer)
            _mProdAttribRelnId = value
        End Set
    End Property

    Public Property ProductId() As Integer Implements IProductAttributeValue.ProductId
        Get
            Return _mProductId
        End Get
        Set(ByVal value As Integer)
            _mProductId = value
        End Set
    End Property

    Public Property AttribValue() As String Implements IProductAttributeValue.AttribValue
        Get
            Return _mAttribValue
        End Get
        Set(ByVal value As String)
            _mAttribValue = value.Trim
        End Set
    End Property

    Public Function Delete() As Boolean Implements IProductAttributeValue.Delete
        Dim success As Boolean
        Dim iCmd As IDbCommand
        Dim data As New DataAccess(SiteProfile.GetConnectionString, DataAccess.DataProvider.SQL)
        Dim dict As New System.Collections.Specialized.HybridDictionary

        'proc(sp__DeleteProductAttributeReln)
        iCmd = data.GetCommand("sp__DeleteProductAttributeReln", CommandType.StoredProcedure, DataAccess.DataProvider.SQL)
        '@ProdAttribRelnID int = null,
        Dim iParmProdAttribRelnId As IDbDataParameter = data.GetParameter(DataAccess.DataProvider.SQL, "@ProdAttribRelnID", DbType.Int32, Me.ProdAttribRelnID, 4, ParameterDirection.Input)
        '@UserID int = null,
        Dim iParmUserId As IDbDataParameter = data.GetParameter(DataAccess.DataProvider.SQL, "@UserID", DbType.Int32, Me.LastModBy, 4, ParameterDirection.Input)
        '@JobID int = null,
        Dim iParmJobId As IDbDataParameter = data.GetParameter(DataAccess.DataProvider.SQL, "@JobID", DbType.Int32, Me.JobID, 4, ParameterDirection.Input)
        '@WorkflowStatus varchar(50) = 'WORKING'
        ' no parm -- use default value

        With iCmd.Parameters
            .Add(iParmProdAttribRelnID)
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

    Public Sub Fill() Implements IProductAttributeValue.Fill
        Try
            Dim data As New DataAccess(SiteProfile.GetConnectionString, DataAccess.DataProvider.SQL)
            Dim dict As New System.Collections.Specialized.HybridDictionary
            Dim strStoredProc As String = "sp__GetProductAttributeRelnByID"

            '@ProdAttribRelnID int = null,
            Dim iParmProdAttribRelnId As IDbDataParameter = data.GetParameter(DataAccess.DataProvider.SQL, "@ProdAttribRelnID", DbType.Int32, Me.ProdAttribRelnID, 4, ParameterDirection.Input)
            '@AttribID int = null,
            Dim iParmAttribId As IDbDataParameter = data.GetParameter(DataAccess.DataProvider.SQL, "@AttribID", DbType.Int32, System.DBNull.Value, 4, ParameterDirection.Output)
            '@AttribName varchar(100) OUTPUT,
            Dim iParmAttribName As IDbDataParameter = data.GetParameter(DataAccess.DataProvider.SQL, "@AttribName", DbType.String, String.Empty, 100, ParameterDirection.Output)
            '@AttribValue varchar(500) OUTPUT,
            Dim iParmAttribValue As IDbDataParameter = data.GetParameter(DataAccess.DataProvider.SQL, "@AttribValue", DbType.String, String.Empty, 500, ParameterDirection.Output)
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
                .Add(iParmProdAttribRelnID)
                .Add(iParmAttribID)
                .Add(iParmAttribValue)
                .Add(iParmAttribName)
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
                If Not iParmAttribValue.Value Is System.DBNull.Value Then
                    ' fill properties
                    Me.AttribType.AttribName = iParmAttribName.Value.ToString
                    Me.AttribType.AttribID = Services.GetNULLableInteger(iParmAttribID.Value)
                    Me.AttribValue = iParmAttribValue.Value.ToString
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
                    Dim ex As New Exception("No Product Attribute was returned for Product Attribute Value ID " & Me.ProdAttribRelnID)
                    Throw New NLTException("Error retrieving Product Attribute.", ex, "ProductAttributeValue.vb", "Function Fill() As Boolean")
                End If
            End If

        Catch ex As Exception
            Throw New NLTException("Error retrieving Product Attribute.", ex, "ProductAttributeValue.vb", "Function Fill() As Boolean")
        End Try

    End Sub

    Public Function GetList(ByVal prodId As Integer) As System.Data.DataTable Implements IProductAttributeValue.GetList
        'sp__GetProductAttributeRelnsByProduct
        Try
            Dim data As New DataAccess(SiteProfile.GetConnectionString, DataAccess.DataProvider.SQL)
            Dim iCmd As IDbCommand = data.GetCommand("sp__GetProductAttributeRelnsByProduct", CommandType.StoredProcedure, DataAccess.DataProvider.SQL)

            If prodID <> 0 Then
                Me.ProductID = prodID
            End If

            'sp__GetProductAttributeValuesByProduct
            '	@ProductID int = null,
            Dim iParmProductId As IDbDataParameter = data.GetParameter(DataAccess.DataProvider.SQL, "@ProductID", DbType.Int32, Me.ProductID, 4, ParameterDirection.Input)
            iCmd.Parameters.Add(iParmProductID)
            Dim dt As DataTable = data.GetDataTable(iCmd)
            If Not dt Is Nothing Then
                Return dt
            Else
                ' just return empty datatable
                dt = New DataTable
                Return dt
            End If
        Catch ex As Exception
            Throw New NLTException("Error retrieving Product Attribute Values.", ex, "ProductAttributeValue.vb", "Public Function GetList() As DataTable Implements IProductAttribute.GetList")
        End Try
    End Function

    Public Function GetDistinctListByAttribute(ByVal attribId As Integer) As DataTable
        Try
            Dim data As New DataAccess(SiteProfile.GetConnectionString, DataAccess.DataProvider.SQL)
            Dim iCmd As IDbCommand = data.GetCommand("sp__GetProductAttributeRelnsByAttribute", CommandType.StoredProcedure, DataAccess.DataProvider.SQL)

            If attribID <> 0 Then
                Me.AttribType.AttribID = attribID
            End If

            ' PROC(sp__GetProductAttributeValuesByAttribute)
            '	@AttribID int = null,
            Dim iParmAttribId As IDbDataParameter = data.GetParameter(DataAccess.DataProvider.SQL, "@AttribID", DbType.Int32, Me.AttribType.AttribID, 4, ParameterDirection.Input)
            iCmd.Parameters.Add(iParmAttribID)
            Dim dt As DataTable = data.GetDataTable(iCmd)
            If Not dt Is Nothing Then
                Return dt
            Else
                ' just return empty datatable
                dt = New DataTable
                Return dt
            End If
        Catch ex As Exception
            Throw New NLTException("Error retrieving Distinct Product Attribute Values.", ex, "ProductAttributeValue.vb", "Public Function GetList(ByVal attribID As Integer) As DataTable")
        End Try
    End Function

    Public Function Save() As Boolean Implements IProductAttributeValue.Save
        Dim success As Boolean
        Dim iCmd As IDbCommand
        Dim iParmProdAttribRelnId As IDbDataParameter

        Dim data As New DataAccess(SiteProfile.GetConnectionString, DataAccess.DataProvider.SQL)
        Dim dict As New System.Collections.Specialized.HybridDictionary
        Dim strStoredProc As String

        ' determine whether item should be added or updated
        '@ProdAttribRelnID int OUTPUT
        If Me.ProdAttribRelnID = 0 Then
            strStoredProc = "sp__AddProductAttributeReln"
            iParmProdAttribRelnID = data.GetParameter(DataAccess.DataProvider.SQL, "@ProdAttribRelnID", DbType.Int32, System.DBNull.Value, 4, ParameterDirection.Output)
        Else
            strStoredProc = "sp__UpdateProductAttributeReln"
            iParmProdAttribRelnID = data.GetParameter(DataAccess.DataProvider.SQL, "@ProdAttribRelnID", DbType.Int32, Me.ProdAttribRelnID, 4, ParameterDirection.Input)
        End If

        '@ProductID int = null,
        Dim iParmProductId As IDbDataParameter = data.GetParameter(DataAccess.DataProvider.SQL, "@ProductID", DbType.Int32, Me.ProductID, 4, ParameterDirection.Input)
        '@AttribID int = null,
        Dim iParmAttribId As IDbDataParameter = data.GetParameter(DataAccess.DataProvider.SQL, "@AttribID", DbType.Int32, Me.AttribType.AttribID, 4, ParameterDirection.Input)
        '@AttribValue varchar(500) = null,
        Dim iParmAttribValue As IDbDataParameter = data.GetParameter(DataAccess.DataProvider.SQL, "@AttribValue", DbType.String, Me.AttribValue, 500, ParameterDirection.Input)
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
            .Add(iParmProdAttribRelnID)
            .Add(iParmProductID)
            .Add(iParmAttribID)
            .Add(iParmAttribValue)
            .Add(iParmPublishDate)
            .Add(iParmExpireDate)
            .Add(iParmJobID)
            .Add(iParmUserID)
        End With

        dict.Add(dict.Count, iCmd)

        Try
            success = data.ExecuteNonQuery(dict)
            If success Then
                If Me.ProdAttribRelnID = 0 Then
                    ' set the id
                    Me.ProdAttribRelnID = Services.GetNULLableInteger(iParmProdAttribRelnID.Value)
                End If
            End If

            Return success
        Catch ex As Exception
            Throw New NLTException("Error saving Product Attribute Value.", ex, "ProductAttributeValue.vb", "Function Save() As Boolean")
        End Try
    End Function
End Class
