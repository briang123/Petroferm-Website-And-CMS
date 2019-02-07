Imports Microsoft.VisualBasic
Imports System.Data
Imports Data
Public Class ProductAttribute
    Inherits WorkflowItem
    Implements IProductAttribute
    Private _mAttribId As Integer
    Private _mAttribName As String
    Private _mBusUnitId As Integer
    Private _mAllowMultiple As Boolean
    Private _mIsReadOnly As Integer
    Public Sub New()

    End Sub

    Public Sub New(ByVal attribId As Integer)
        _mAttribId = attribID
    End Sub

    Public Property AttribId() As Integer Implements IProductAttribute.AttribId
        Get
            Return _mAttribId
        End Get
        Set(ByVal value As Integer)
            _mAttribId = value
        End Set
    End Property

    Public Property AttribName() As String Implements IProductAttribute.AttribName
        Get
            Return _mAttribName
        End Get
        Set(ByVal value As String)
            _mAttribName = value.Trim
        End Set
    End Property

    Public Property BusUnitId() As Integer Implements IProductAttribute.BusUnitId
        Get
            Return _mBusUnitId
        End Get
        Set(ByVal value As Integer)
            _mBusUnitId = value
        End Set
    End Property

    Public Property IsReadOnly() As Boolean Implements IProductAttribute.IsReadOnly
        Get
            Return _mIsReadOnly
        End Get
        Set(ByVal value As Boolean)
            _mIsReadOnly = value
        End Set
    End Property

    Public Property AllowMultiple() As Boolean Implements IProductAttribute.AllowMultiple
        Get
            Return _mAllowMultiple
        End Get
        Set(ByVal value As Boolean)
            _mAllowMultiple = value
        End Set
    End Property

    Public Function Save() As Boolean Implements IProductAttribute.Save
        Dim success As Boolean
        Dim iCmd As IDbCommand
        Dim iParmId As IDbDataParameter

        Dim data As New DataAccess(SiteProfile.GetConnectionString, DataAccess.DataProvider.SQL)
        Dim dict As New System.Collections.Specialized.HybridDictionary
        Dim strStoredProc As String

        ' determine whether item should be added or updated
        If Me.AttribID = 0 Then
            strStoredProc = "sp__AddProductAttribute"
            iParmID = data.GetParameter(DataAccess.DataProvider.SQL, "@AttribTypeID", DbType.Int32, System.DBNull.Value, 4, ParameterDirection.Output)
        Else
            strStoredProc = "sp__UpdateProductAttribute"
            iParmID = data.GetParameter(DataAccess.DataProvider.SQL, "@AttribTypeID", DbType.Int32, Me.AttribID, 4, ParameterDirection.Input)
        End If

        '@BusUnitID int = null,
        Dim iParmBusId As IDbDataParameter = data.GetParameter(DataAccess.DataProvider.SQL, "@BusUnitID", DbType.Int32, Me.BusUnitID, 4, ParameterDirection.Input)
        '@AttribName varchar(100) = null,
        Dim iParmAttribName As IDbDataParameter = data.GetParameter(DataAccess.DataProvider.SQL, "@AttribName", DbType.String, Me.AttribName, 100, ParameterDirection.Input)
        '@AllowMultiple bit = 0,
        Dim iParmAllowMultiple As IDbDataParameter = data.GetParameter(DataAccess.DataProvider.SQL, "@AllowMultiple", DbType.Boolean, Me.AllowMultiple, 1, ParameterDirection.Input)
        '@IsReadOnly bit = 0,
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
            .Add(iParmID)
            .Add(iParmBusID)
            .Add(iParmAttribName)
            .Add(iParmAllowMultiple)
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
                If Me.AttribID = 0 Then
                    ' set the id
                    Me.AttribID = iParmID.Value
                End If
            End If

            Return success
        Catch ex As Exception
            Throw New NLTException("Error saving Product Attribute.", ex, "ProductAttribute.vb", "Function Save() As Boolean")
        End Try
    End Function

    Public Function Delete() As Boolean Implements IProductAttribute.Delete
        Dim success As Boolean
        Dim iCmd As IDbCommand
        Dim data As New DataAccess(SiteProfile.GetConnectionString, DataAccess.DataProvider.SQL)
        Dim dict As New System.Collections.Specialized.HybridDictionary

        'proc(sp__DeleteProductAttribute)
        iCmd = data.GetCommand("sp__DeleteProductAttribute", CommandType.StoredProcedure, DataAccess.DataProvider.SQL)
        '@AttribTypeID int = null,
        Dim iParmAttribTypeId As IDbDataParameter = data.GetParameter(DataAccess.DataProvider.SQL, "@AttribTypeID", DbType.Int32, Me.AttribID, 4, ParameterDirection.Input)
        '@UserID int = null,
        Dim iParmUserId As IDbDataParameter = data.GetParameter(DataAccess.DataProvider.SQL, "@UserID", DbType.Int32, Me.LastModBy, 4, ParameterDirection.Input)
        '@JobID int = null,
        Dim iParmJobId As IDbDataParameter = data.GetParameter(DataAccess.DataProvider.SQL, "@JobID", DbType.Int32, Me.JobID, 4, ParameterDirection.Input)
        '@WorkflowStatus varchar(50) = 'WORKING'
        ' no parm -- use default value

        With iCmd.Parameters
            .Add(iParmAttribTypeID)
            .Add(iParmJobID)
            .Add(iParmUserID)
        End With

        dict.Add(dict.Count, iCmd)

        Try
            success = data.ExecuteNonQuery(dict)
            Return success
        Catch ex As Exception
            Throw New NLTException("Error deleting Product Attribute.", ex, "ProductAttribute.vb", "Function Delete() As Boolean")
        Finally
            If iCmd.Connection.State <> ConnectionState.Closed Then
                iCmd.Connection.Close()
            End If
        End Try
    End Function

    Public Sub Fill() Implements IProductAttribute.Fill
        Try
            Dim data As New DataAccess(SiteProfile.GetConnectionString, DataAccess.DataProvider.SQL)
            Dim dict As New System.Collections.Specialized.HybridDictionary

            'PROC(sp__GetProductAttributeByID)
            Dim strStoredProc As String = "sp__GetProductAttributeByID"

            '@AttribTypeID int = null,
            Dim iParmAttribTypeId As IDbDataParameter = data.GetParameter(DataAccess.DataProvider.SQL, "@AttribTypeID", DbType.Int32, Me.AttribID, 4, ParameterDirection.Input)
            '@BusUnitID int OUTPUT,
            Dim iParmBusUnitId As IDbDataParameter = data.GetParameter(DataAccess.DataProvider.SQL, "@BusUnitID", DbType.Int32, System.DBNull.Value, 4, ParameterDirection.Output)
            '@AttribName varchar(100) OUTPUT,
            Dim iParmAttribName As IDbDataParameter = data.GetParameter(DataAccess.DataProvider.SQL, "@AttribName", DbType.String, String.Empty, 100, ParameterDirection.Output)
            '@AllowMultiple bit OUTPUT,
            Dim iParmAllowMultiple As IDbDataParameter = data.GetParameter(DataAccess.DataProvider.SQL, "@AllowMultiple", DbType.Boolean, System.DBNull.Value, 1, ParameterDirection.Output)
            '@FmtAllowMultiple varchar(3) OUTPUT,
            Dim iParmFmtAllowMultiple As IDbDataParameter = data.GetParameter(DataAccess.DataProvider.SQL, "@FmtAllowMultiple", DbType.String, String.Empty, 3, ParameterDirection.Output)
            '@IsReadOnly bit OUTPUT,
            Dim iParmIsReadOnly As IDbDataParameter = data.GetParameter(DataAccess.DataProvider.SQL, "@IsReadOnly", DbType.Boolean, System.DBNull.Value, 1, ParameterDirection.Output)
            '@FmtIsReadOnly varchar(3) OUTPUT,
            Dim iParmFmtIsReadOnly As IDbDataParameter = data.GetParameter(DataAccess.DataProvider.SQL, "@FmtIsReadOnly", DbType.String, String.Empty, 3, ParameterDirection.Output)
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
                .Add(iParmAttribTypeID)
                .Add(iParmBusUnitID)
                .Add(iParmAttribName)
                .Add(iParmAllowMultiple)
                .Add(iParmFmtAllowMultiple)
                .Add(iParmIsReadOnly)
                .Add(iParmFmtIsReadOnly)
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
                    Me.BusUnitID = Services.GetNULLableInteger(iParmBusUnitID.Value)
                    Me.AttribName = iParmAttribName.Value.ToString
                    Me.AllowMultiple = Services.GetNULLableBoolean(iParmAllowMultiple.Value)
                    Me.IsReadOnly = Services.GetNULLableBoolean(iParmIsReadOnly.Value)
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
                    Dim ex As New Exception("No Product Attribute was returned for Product Attribute ID " & Me.AttribID)
                    Throw New NLTException("Error retrieving Product Attribute.", ex, "ProductAttribute.vb", "Function Fill() As Boolean")
                End If
            End If

        Catch ex As Exception
            Throw New NLTException("Error retrieving Product Attribute.", ex, "ProductAttribute.vb", "Function Fill() As Boolean")
        End Try

    End Sub

    Public Function GetList(ByVal busUnitId As Integer) As DataTable Implements IProductAttribute.GetList
        Try
            Dim data As New DataAccess(SiteProfile.GetConnectionString, DataAccess.DataProvider.SQL)
            Dim iCmd As IDbCommand = data.GetCommand("sp__GetProductAttributesByBU", CommandType.StoredProcedure, DataAccess.DataProvider.SQL)


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
            Throw New NLTException("Error retrieving Product Attributes.", ex, "ProductAttribute.vb", "Public Function GetList(ByVal busUnitID As Integer) As DataTable Implements IProductAttribute.GetList")
        End Try
    End Function

    Public Function GetListByJob(ByVal jobId As Integer) As System.Data.DataTable
        Try
            Dim data As New DataAccess(SiteProfile.GetConnectionString, DataAccess.DataProvider.SQL)
            Dim iCmd As IDbCommand = data.GetCommand("sp__GetProductAttributesByJobID", CommandType.StoredProcedure, DataAccess.DataProvider.SQL)
            Dim iParmJobId As IDbDataParameter = data.GetParameter(DataAccess.DataProvider.SQL, "@JobID", DbType.Int32, jobID, 4, ParameterDirection.Input)
            iCmd.Parameters.Add(iParmJobID)
            Dim dt As DataTable = data.GetDataTable(iCmd)
            Return dt

        Catch ex As Exception
            Throw New NLTException("Error retrieving Product Attributes by Job.", ex, "ProductAttribute.vb", "Function GetListByJob(jobID as Integer) As System.Data.DataTable")
        End Try
    End Function


End Class
