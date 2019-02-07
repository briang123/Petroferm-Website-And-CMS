Imports Microsoft.VisualBasic
Imports System.Data
Imports Data
Public Class SearchAttribute
    Inherits WorkflowItem
    Implements ISearchAttribute
    Private _mSearchAttribTypeId As Integer
    Private _mBusUnitId As Integer
    Private _mMarketId As Integer
    Private _mSearchAttribName As String
    Public Sub New()

    End Sub
    Public Sub New(ByVal attribId As Integer)
        SearchAttribTypeID = attribID
    End Sub

    Public Property SearchAttribTypeId() As Integer Implements ISearchAttribute.SearchAttribTypeId
        Get
            Return _mSearchAttribTypeId
        End Get
        Set(ByVal value As Integer)
            _mSearchAttribTypeId = value
        End Set
    End Property

    Public Property BusUnitId() As Integer Implements ISearchAttribute.BusUnitId
        Get
            Return _mBusUnitId
        End Get
        Set(ByVal value As Integer)
            _mBusUnitId = value
        End Set
    End Property

    Public Property MarketId() As Integer Implements ISearchAttribute.MarketId
        Get
            Return _mMarketId
        End Get
        Set(ByVal value As Integer)
            _mMarketId = value
        End Set
    End Property

    Public Property SearchAttribName() As String Implements ISearchAttribute.SearchAttribName
        Get
            Return _mSearchAttribName
        End Get
        Set(ByVal value As String)
            _mSearchAttribName = value
        End Set
    End Property

    Public Function Delete() As Boolean Implements ISearchAttribute.Delete
        Dim success As Boolean
        Dim iCmd As IDbCommand
        Dim data As New DataAccess(SiteProfile.GetConnectionString, DataAccess.DataProvider.SQL)
        Dim dict As New System.Collections.Specialized.HybridDictionary

        'proc(sp__DeleteProductAttribute)
        iCmd = data.GetCommand("sp__DeleteSearchAttribute", CommandType.StoredProcedure, DataAccess.DataProvider.SQL)
        '@SearchAttribTypeID int = null,
        Dim iParmSearchAttribTypeId As IDbDataParameter = data.GetParameter(DataAccess.DataProvider.SQL, "@SearchAttribTypeID", DbType.Int32, Me.SearchAttribTypeID, 4, ParameterDirection.Input)
        '@UserID int = null,
        Dim iParmUserId As IDbDataParameter = data.GetParameter(DataAccess.DataProvider.SQL, "@UserID", DbType.Int32, Me.LastModBy, 4, ParameterDirection.Input)
        '@JobID int = null,
        Dim iParmJobId As IDbDataParameter = data.GetParameter(DataAccess.DataProvider.SQL, "@JobID", DbType.Int32, Me.JobID, 4, ParameterDirection.Input)
        '@WorkflowStatus varchar(50) = 'WORKING'
        ' no parm -- use default value

        With iCmd.Parameters
            .Add(iParmSearchAttribTypeID)
            .Add(iParmJobID)
            .Add(iParmUserID)
        End With

        dict.Add(dict.Count, iCmd)

        Try
            success = data.ExecuteNonQuery(dict)
            Return success
        Catch ex As Exception
            Throw New NLTException("Error deleting Search Attribute.", ex, "SearchAttribute.vb", "Function Delete() As Boolean")
        End Try

    End Function

    Public Sub Fill() Implements ISearchAttribute.Fill
        Try
            Dim data As New DataAccess(SiteProfile.GetConnectionString, DataAccess.DataProvider.SQL)
            Dim dict As New System.Collections.Specialized.HybridDictionary
            Dim strStoredProc As String = "sp__GetSearchAttributeByID"

            '@SearchAttribTypeID int = null,
            Dim iParmSearchAttribTypeId As IDbDataParameter = data.GetParameter(DataAccess.DataProvider.SQL, "@SearchAttribTypeID", DbType.Int32, Me.SearchAttribTypeID, 4, ParameterDirection.Input)
            '@BusUnitID int OUTPUT,
            Dim iParmBusUnitId As IDbDataParameter = data.GetParameter(DataAccess.DataProvider.SQL, "@BusUnitID", DbType.Int32, System.DBNull.Value, 4, ParameterDirection.Output)
            '@MarketID int OUTPUT,
            Dim iParmMarketId As IDbDataParameter = data.GetParameter(DataAccess.DataProvider.SQL, "@MarketID", DbType.Int32, System.DBNull.Value, 4, ParameterDirection.Output)
            '@SearchAttribName varchar(100) OUTPUT,
            Dim iParmSearchAttribName As IDbDataParameter = data.GetParameter(DataAccess.DataProvider.SQL, "@SearchAttribName", DbType.String, String.Empty, 100, ParameterDirection.Output)
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
                .Add(iParmSearchAttribTypeID)
                .Add(iParmBusUnitID)
                .Add(iParmMarketID)
                .Add(iParmSearchAttribName)
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
                    Me.MarketID = Services.GetNULLableInteger(iParmMarketID.Value)
                    Me.SearchAttribName = iParmSearchAttribName.Value.ToString
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
                    Dim ex As New Exception("No Search Attribute was returned for Product Attribute ID " & Me.SearchAttribTypeID)
                    Throw New NLTException("Error retrieving Search Attribute.", ex, "SearchAttribute.vb", "Function Fill() As Boolean")
                End If
            End If

        Catch ex As Exception
            Throw New NLTException("Error retrieving Search Attribute.", ex, "SearchAttribute.vb", "Sub Fill()")
        End Try
    End Sub

    Public Function GetList(ByVal busUnitId As Integer, ByVal mktId As Integer, ByVal liveMode As Boolean) As System.Data.DataTable Implements ISearchAttribute.GetList
        Try
            Dim data As New DataAccess(SiteProfile.GetConnectionString, DataAccess.DataProvider.SQL)
            Dim strStoredProc As String
            Dim iParmMktId As IDbDataParameter = Nothing
            Dim iParmBusUnitId As IDbDataParameter = Nothing

            Dim iparmLiveMode As IDbDataParameter = data.GetParameter(DataAccess.DataProvider.SQL, "@LiveMode", DbType.Boolean, liveMode, 1, ParameterDirection.Input)

            If mktID <> 0 Then
                Me.MarketID = mktID
            End If

            If Me.MarketID <> 0 Then ' get list by market
                '	@MktID int = null,
                strStoredProc = "sp__GetSearchAttributesByMkt"
                iParmMktID = data.GetParameter(DataAccess.DataProvider.SQL, "@MktID", DbType.Int32, Me.MarketID, 4, ParameterDirection.Input)
            Else
                ' get all attribs (by business unit)
                strStoredProc = "sp__GetSearchAttributesByBU"
                '	@BusUnitID int = null,
                iParmBusUnitID = data.GetParameter(DataAccess.DataProvider.SQL, "@BusUnitID", DbType.Int32, busUnitID, 4, ParameterDirection.Input)
            End If

            Dim iCmd As IDbCommand = data.GetCommand(strStoredProc, CommandType.StoredProcedure, DataAccess.DataProvider.SQL)

            ' add appropriate parm
            Select Case True
                Case Not iParmMktID Is Nothing
                    iCmd.Parameters.Add(iParmMktID)
                    iCmd.Parameters.Add(iparmLiveMode)
                Case Not iParmBusUnitID Is Nothing
                    iCmd.Parameters.Add(iParmBusUnitID)
            End Select

            '	@LiveMode bit = 0
            ' (parm not needed)

            Dim dt As DataTable = data.GetDataTable(iCmd)
            Return dt

        Catch ex As Exception
            Throw New NLTException("Error retrieving Search Attributes by Market.", ex, "SearchAttribute.vb", "Public Function GetList(ByVal mktID As Integer) As DataTable Implements ISearchAttribute.GetList")
        End Try
    End Function



    ''' <summary>
    ''' This gets a list of attributes by market
    ''' </summary>
    ''' <param name="mktId"></param>
    ''' <returns></returns>
    ''' <remarks></remarks>
    Public Function GetList(ByVal busUnitId As Integer, ByVal mktId As Integer) As System.Data.DataTable Implements ISearchAttribute.GetList
        Try
            Dim data As New DataAccess(SiteProfile.GetConnectionString, DataAccess.DataProvider.SQL)
            Dim strStoredProc As String
            Dim iParmMktId As IDbDataParameter = Nothing
            Dim iParmBusUnitId As IDbDataParameter = Nothing

            If mktID <> 0 Then
                Me.MarketID = mktID
            End If

            If Me.MarketID <> 0 Then ' get list by market
                '	@MktID int = null,
                strStoredProc = "sp__GetSearchAttributesByMkt"
                iParmMktID = data.GetParameter(DataAccess.DataProvider.SQL, "@MktID", DbType.Int32, Me.MarketID, 4, ParameterDirection.Input)

            Else
                ' get all attribs (by business unit)
                strStoredProc = "sp__GetSearchAttributesByBU"
                '	@BusUnitID int = null,
                iParmBusUnitID = data.GetParameter(DataAccess.DataProvider.SQL, "@BusUnitID", DbType.Int32, busUnitID, 4, ParameterDirection.Input)
            End If

            Dim iCmd As IDbCommand = data.GetCommand(strStoredProc, CommandType.StoredProcedure, DataAccess.DataProvider.SQL)

            ' add appropriate parm
            Select Case True
                Case Not iParmMktID Is Nothing
                    iCmd.Parameters.Add(iParmMktID)
                Case Not iParmBusUnitID Is Nothing
                    iCmd.Parameters.Add(iParmBusUnitID)
            End Select

            '	@LiveMode bit = 0
            ' (parm not needed)

            Dim dt As DataTable = data.GetDataTable(iCmd)
            If Not dt Is Nothing Then
                Return dt
            Else
                ' just return empty datatable
                dt = New DataTable
                Return dt
            End If

        Catch ex As Exception
            Throw New NLTException("Error retrieving Search Attributes by Market.", ex, "SearchAttribute.vb", "Public Function GetList(ByVal mktID As Integer) As DataTable Implements ISearchAttribute.GetList")
        End Try
    End Function
    ''' <summary>
    ''' This gets a list of ALL search attributes
    ''' </summary>
    ''' <returns></returns>
    ''' <remarks></remarks>
    Public Function GetList() As System.Data.DataTable
        Try
            Dim data As New DataAccess(SiteProfile.GetConnectionString, DataAccess.DataProvider.SQL)
            Dim iCmd As IDbCommand = data.GetCommand("sp__GetSearchAttributes", CommandType.StoredProcedure, DataAccess.DataProvider.SQL)

            '	@LiveMode bit = 0
            ' (parm not needed)

            Dim dt As DataTable = data.GetDataTable(iCmd)
            If Not dt Is Nothing Then
                Return dt
            Else
                ' just return empty datatable
                dt = New DataTable
                Return dt
            End If


        Catch ex As Exception
            Throw New NLTException("Error retrieving Search Attributes.", ex, "SearchAttribute.vb", "Public Function GetList() As DataTable")
        End Try
    End Function


    Public Function Save() As Boolean Implements ISearchAttribute.Save
        Dim success As Boolean
        Dim iCmd As IDbCommand
        Dim iParmId As IDbDataParameter

        Dim data As New DataAccess(SiteProfile.GetConnectionString, DataAccess.DataProvider.SQL)
        Dim dict As New System.Collections.Specialized.HybridDictionary
        Dim strStoredProc As String

        ' determine whether item should be added or updated
        If Me.SearchAttribTypeID = 0 Then
            strStoredProc = "sp__AddSearchAttribute"
            iParmID = data.GetParameter(DataAccess.DataProvider.SQL, "@SearchAttribTypeID", DbType.Int32, System.DBNull.Value, 4, ParameterDirection.Output)
        Else
            strStoredProc = "sp__UpdateSearchAttribute"
            iParmID = data.GetParameter(DataAccess.DataProvider.SQL, "@SearchAttribTypeID", DbType.Int32, Me.SearchAttribTypeID, 4, ParameterDirection.Input)
        End If

        '@BusUnitID int = null,
        Dim iParmBusId As IDbDataParameter = data.GetParameter(DataAccess.DataProvider.SQL, "@BusUnitID", DbType.Int32, Me.BusUnitID, 4, ParameterDirection.Input)
        '@MarketID int = null,
        Dim iParmMktId As IDbDataParameter = data.GetParameter(DataAccess.DataProvider.SQL, "@MarketID", DbType.Int32, Me.MarketID, 4, ParameterDirection.Input)
        '@SearchAttribName varchar(100) = null,
        Dim iParmSearchAttribName As IDbDataParameter = data.GetParameter(DataAccess.DataProvider.SQL, "@SearchAttribName", DbType.String, Me.SearchAttribName, 100, ParameterDirection.Input)
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
            .Add(iParmMktID)
            .Add(iParmSearchAttribName)
            .Add(iParmPublishDate)
            .Add(iParmExpireDate)
            .Add(iParmJobID)
            .Add(iParmUserID)
        End With

        dict.Add(dict.Count, iCmd)

        Try
            success = data.ExecuteNonQuery(dict)
            If success Then
                If Me.SearchAttribTypeID = 0 Then
                    ' set the id
                    Me.SearchAttribTypeID = iParmID.Value
                End If
            End If

            Return success
        Catch ex As Exception
            Throw New NLTException("Error saving Search Attribute.", ex, "SearchAttribute.vb", "Function Save() As Boolean")
        End Try
    End Function

    Public Function GetListByJob(ByVal jobId As Integer) As System.Data.DataTable
        Try
            Dim data As New DataAccess(SiteProfile.GetConnectionString, DataAccess.DataProvider.SQL)
            Dim iCmd As IDbCommand = data.GetCommand("sp__GetSearchAttributesByJobID", CommandType.StoredProcedure, DataAccess.DataProvider.SQL)
            Dim iParmJobId As IDbDataParameter = data.GetParameter(DataAccess.DataProvider.SQL, "@JobID", DbType.Int32, jobID, 4, ParameterDirection.Input)
            iCmd.Parameters.Add(iParmJobID)
            Dim dt As DataTable = data.GetDataTable(iCmd)
            Return dt

        Catch ex As Exception
            Throw New NLTException("Error retrieving Search Attributes by Job.", ex, "SearchAttribute.vb", "Function GetListByJob(jobID as Integer) As System.Data.DataTable")
        End Try
    End Function




End Class