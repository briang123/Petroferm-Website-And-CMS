Imports Microsoft.VisualBasic

Public Class HeaderSideContentModule
    Inherits PageModule
    Implements IHeaderSideContentModule

    Private _mExternalLink1 As String
    Private _mExternalLink2 As String
    Private _mHeaderSideContentModuleId As Integer
    Private _mInternalLink1 As Integer
    Private _mInternalLink2 As Integer
    Private _mInternalLink1Type As String
    Private _mInternalLink2Type As String
    Private _mLineText1 As String
    Private _mLineText2 As String
    Private _mTitle As String
    Private _mLiveModeStatus As LiveMode

    Public Sub New()
    End Sub

    Public Sub New(ByVal moduleId As Integer, ByVal liveMode As LiveMode)
        MyBase.ModuleId = ModuleId
        Me.LiveModeStatus = liveMode
        Me.Fill()
    End Sub

    Public Property LiveModeStatus() As LiveMode
        Get
            Return _mLiveModeStatus
        End Get
        Set(ByVal value As LiveMode)
            _mLiveModeStatus = value
        End Set
    End Property

    Public Property ExternalLink1() As String Implements IHeaderSideContentModule.ExternalLink1
        Get
            Return _mExternalLink1
        End Get
        Set(ByVal value As String)
            _mExternalLink1 = value
        End Set
    End Property

    Public Property ExternalLink2() As String Implements IHeaderSideContentModule.ExternalLink2
        Get
            Return _mExternalLink2
        End Get
        Set(ByVal value As String)
            _mExternalLink2 = value
        End Set
    End Property

    Public Property HeaderSideContentModuleId() As Integer Implements IHeaderSideContentModule.HeaderSideContentModuleId
        Get
            Return _mHeaderSideContentModuleId
        End Get
        Set(ByVal value As Integer)
            _mHeaderSideContentModuleId = value
            MyBase.ModuleId = value
        End Set
    End Property

    Public Property InternalLink1() As Integer Implements IHeaderSideContentModule.InternalLink1
        Get
            Return _mInternalLink1
        End Get
        Set(ByVal value As Integer)
            _mInternalLink1 = value
        End Set
    End Property

    Public Property InternalLink1Type() As String Implements IHeaderSideContentModule.InternalLink1Type
        Get
            Return _mInternalLink1Type
        End Get
        Set(ByVal value As String)
            _mInternalLink1Type = value.ToUpper
        End Set
    End Property

    Public Property InternalLink2() As Integer Implements IHeaderSideContentModule.InternalLink2
        Get
            Return _mInternalLink2
        End Get
        Set(ByVal value As Integer)
            _mInternalLink2 = value
        End Set
    End Property

    Public Property InternalLink2Type() As String Implements IHeaderSideContentModule.InternalLink2Type
        Get
            Return _mInternalLink2Type
        End Get
        Set(ByVal value As String)
            _mInternalLink2Type = value.ToUpper
        End Set
    End Property

    Public Property LineText1() As String Implements IHeaderSideContentModule.LineText1
        Get
            Return _mLineText1
        End Get
        Set(ByVal value As String)
            _mLineText1 = value
        End Set
    End Property

    Public Property LineText2() As String Implements IHeaderSideContentModule.LineText2
        Get
            Return _mLineText2
        End Get
        Set(ByVal value As String)
            _mLineText2 = value
        End Set
    End Property

    Public Property Title() As String Implements IHeaderSideContentModule.Title
        Get
            Return _mTitle
        End Get
        Set(ByVal value As String)
            _mTitle = value
        End Set
    End Property

    Public Function Delete() As Boolean Implements IHeaderSideContentModule.Delete
        Dim success As Boolean
        Dim iCmd As IDbCommand
        Dim data As New DataAccess(SiteProfile.GetConnectionString, DataAccess.DataProvider.SQL)
        Dim dict As New System.Collections.Specialized.HybridDictionary

        'proc(sp__DeleteContentModule)
        iCmd = data.GetCommand("sp__DeleteHeaderSideContentModule", CommandType.StoredProcedure, DataAccess.DataProvider.SQL)
        '@HeaderSideContentModuleID int = null,
        Dim iParmHeaderSideContentModuleId As IDbDataParameter = data.GetParameter(DataAccess.DataProvider.SQL, "@HeaderSideContentModuleID", DbType.Int32, Me.HeaderSideContentModuleId, 4, ParameterDirection.Input)
        '@UserID int = null,
        Dim iParmUserId As IDbDataParameter = data.GetParameter(DataAccess.DataProvider.SQL, "@UserID", DbType.Int32, Me.LastModBy, 4, ParameterDirection.Input)
        '@JobID int = null,
        Dim iParmJobId As IDbDataParameter = data.GetParameter(DataAccess.DataProvider.SQL, "@JobID", DbType.Int32, Me.JobID, 4, ParameterDirection.Input)
        '@WorkflowStatus varchar(50) = 'WORKING'
        ' no parm -- use default value

        With iCmd.Parameters
            .Add(iParmHeaderSideContentModuleID)
            .Add(iParmJobID)
            .Add(iParmUserID)
        End With

        dict.Add(dict.Count, iCmd)

        Try
            success = data.ExecuteNonQuery(dict)
            Return success
        Catch ex As Exception
            Throw New NLTException("Error deleting Header Side Content Module.", ex, "HeaderSideContentModule.vb", "Function Delete() As Boolean")

        End Try
    End Function

    Public Sub Fill() Implements IHeaderSideContentModule.Fill

        Try
            Dim data As New DataAccess(SiteProfile.GetConnectionString, DataAccess.DataProvider.SQL)
            Dim dict As New System.Collections.Specialized.HybridDictionary
            Dim iParmId As IDbDataParameter = data.GetParameter(DataAccess.DataProvider.SQL, "@HeaderSideContentModuleID", DbType.Int32, MyBase.ModuleId, 4, ParameterDirection.Input)
            Dim iParmLiveMode As IDbDataParameter = data.GetParameter(DataAccess.DataProvider.SQL, "@LiveMode", DbType.Boolean, Me.LiveModeStatus, 1, ParameterDirection.Input)
            'Dim iParmTitle As IDbDataParameter = data.GetParameter(DataAccess.DataProvider.SQL, "@Title", DbType.String, System.DBNull.Value, 50, ParameterDirection.Output)
            'Dim iParmLineText1 As IDbDataParameter = data.GetParameter(DataAccess.DataProvider.SQL, "@LineText1", DbType.String, System.DBNull.Value, 200, ParameterDirection.Output)
            'Dim iParmInternalLink1 As IDbDataParameter = data.GetParameter(DataAccess.DataProvider.SQL, "@InternalLink1", DbType.Int32, System.DBNull.Value, 4, ParameterDirection.Output)
            'Dim iParmInternalLink1Type As IDbDataParameter = data.GetParameter(DataAccess.DataProvider.SQL, "@InternalLink1Type", DbType.String, System.DBNull.Value, 50, ParameterDirection.Output)
            'Dim iParmExternalLink1 As IDbDataParameter = data.GetParameter(DataAccess.DataProvider.SQL, "@ExternalLink1", DbType.String, System.DBNull.Value, 300, ParameterDirection.Output)
            'Dim iParmLineText2 As IDbDataParameter = data.GetParameter(DataAccess.DataProvider.SQL, "@LineText2", DbType.String, System.DBNull.Value, 200, ParameterDirection.Output)
            'Dim iParmInternalLink2 As IDbDataParameter = data.GetParameter(DataAccess.DataProvider.SQL, "@InternalLink2", DbType.Int32, System.DBNull.Value, 4, ParameterDirection.Output)
            'Dim iParmInternalLink2Type As IDbDataParameter = data.GetParameter(DataAccess.DataProvider.SQL, "@InternalLink2Type", DbType.String, System.DBNull.Value, 50, ParameterDirection.Output)
            'Dim iParmExternalLink2 As IDbDataParameter = data.GetParameter(DataAccess.DataProvider.SQL, "@ExternalLink2", DbType.String, System.DBNull.Value, 300, ParameterDirection.Output)
            'Dim iParmPublishDate As IDbDataParameter = data.GetParameter(DataAccess.DataProvider.SQL, "@PublishDate", DbType.Date, System.DBNull.Value, 8, ParameterDirection.Output)
            'Dim iParmExpireDate As IDbDataParameter = data.GetParameter(DataAccess.DataProvider.SQL, "@ExpireDate", DbType.Date, System.DBNull.Value, 8, ParameterDirection.Output)
            'Dim iParmWorkflowStatus As IDbDataParameter = data.GetParameter(DataAccess.DataProvider.SQL, "@WorkflowStatus", DbType.String, System.DBNull.Value, 50, ParameterDirection.Output)
            'Dim iParmLastModDate As IDbDataParameter = data.GetParameter(DataAccess.DataProvider.SQL, "@LastModifiedDate", DbType.Date, System.DBNull.Value, 8, ParameterDirection.Output)
            'Dim iParmLastModifiedBy As IDbDataParameter = data.GetParameter(DataAccess.DataProvider.SQL, "@LastModifiedBy", DbType.Int32, System.DBNull.Value, 4, ParameterDirection.Output)
            'Dim iParmLastModifiedByName As IDbDataParameter = data.GetParameter(DataAccess.DataProvider.SQL, "@LastModifiedByName", DbType.String, System.DBNull.Value, 150, ParameterDirection.Output)
            'Dim iParmActiveFlag As IDbDataParameter = data.GetParameter(DataAccess.DataProvider.SQL, "@ActiveFlag", DbType.Boolean, System.DBNull.Value, 1, ParameterDirection.Output)
            'Dim iParmMarkedForDeletion As IDbDataParameter = data.GetParameter(DataAccess.DataProvider.SQL, "@MarkedForDeletion", DbType.Boolean, System.DBNull.Value, 1, ParameterDirection.Output)
            'Dim iParmFmtMarkedForDeletion As IDbDataParameter = data.GetParameter(DataAccess.DataProvider.SQL, "@FmtMarkedForDeletion", DbType.String, System.DBNull.Value, 3, ParameterDirection.Output)
            'Dim iParmJobID As IDbDataParameter = data.GetParameter(DataAccess.DataProvider.SQL, "@JobID", DbType.Int32, System.DBNull.Value, 4, ParameterDirection.Output)
            'Dim iParmJobName As IDbDataParameter = data.GetParameter(DataAccess.DataProvider.SQL, "@JobName", DbType.String, System.DBNull.Value, 100, ParameterDirection.Output)
            'Dim iParmJobDescription As IDbDataParameter = data.GetParameter(DataAccess.DataProvider.SQL, "@JobDescription", DbType.String, System.DBNull.Value, 500, ParameterDirection.Output)
            Dim iCmd As IDbCommand = data.GetCommand("sp__GetHeaderSideContentByID", CommandType.StoredProcedure, DataAccess.DataProvider.SQL)

            With iCmd.Parameters
                .Add(iParmID)
                .Add(iParmLiveMode)
                '.Add(iParmTitle)
                '.Add(iParmLineText1)
                '.Add(iParmInternalLink1)
                '.Add(iParmInternalLink1Type)
                '.Add(iParmExternalLink1)
                '.Add(iParmLineText2)
                '.Add(iParmInternalLink2)
                '.Add(iParmInternalLink2Type)
                '.Add(iParmExternalLink2)
                '.Add(iParmPublishDate)
                '.Add(iParmExpireDate)
                '.Add(iParmWorkflowStatus)
                '.Add(iParmLastModDate)
                '.Add(iParmLastModifiedBy)
                '.Add(iParmLastModifiedByName)
                '.Add(iParmActiveFlag)
                '.Add(iParmMarkedForDeletion)
                '.Add(iParmFmtMarkedForDeletion)
                '.Add(iParmJobID)
                '.Add(iParmJobName)
                '.Add(iParmJobDescription)
            End With

            dict.Add(dict.Count, iCmd)
            Dim dt As DataTable = data.GetDataTable(iCmd)

            If dt.Rows.Count > 0 Then
                Dim row As DataRow = dt.Rows(0)
                ' If data.ExecuteNonQuery(dict) Then
                With Me
                    '.Title = Services.GetNULLableString(iParmTitle.Value)
                    '.LineText1 = Services.GetNULLableString(iParmLineText1.Value)
                    '.InternalLink1 = Services.GetNULLableInteger(iParmInternalLink1.Value)
                    '.InternalLink1Type = Services.GetNULLableString(iParmInternalLink1Type.Value)
                    '.ExternalLink1 = Services.GetNULLableString(iParmExternalLink1.Value)
                    '.LineText2 = Services.GetNULLableString(iParmLineText2.Value)
                    '.InternalLink2 = Services.GetNULLableInteger(iParmInternalLink2.Value)
                    '.InternalLink2Type = Services.GetNULLableString(iParmInternalLink2Type.Value)
                    '.ExternalLink2 = Services.GetNULLableString(iParmExternalLink2.Value)
                    '.ActiveFlag = Services.GetNULLableBoolean(iParmActiveFlag.Value)
                    .Title = Services.GetNULLableString(row("Title"))
                    .LineText1 = Services.GetNULLableString(row("LineText1"))
                    .InternalLink1 = Services.GetNULLableInteger(row("InternalLink1"))
                    .InternalLink1Type = Services.GetNULLableString(row("InternalLink1Type"))
                    .ExternalLink1 = Services.GetNULLableString(row("ExternalLink1"))
                    .LineText2 = Services.GetNULLableString(row("LineText2"))
                    .InternalLink2 = Services.GetNULLableInteger(row("InternalLink2"))
                    .InternalLink2Type = Services.GetNULLableString(row("InternalLink2Type"))
                    .ExternalLink2 = Services.GetNULLableString(row("ExternalLink2"))
                    .ActiveFlag = Services.GetNULLableBoolean(row("ActiveFlag"))

                End With

                ' fill workflow properties
                'MyBase.WorkflowStatus = Services.GetNULLableString(iParmWorkflowStatus.Value)
                'MyBase.MarkedForDelete = Services.GetNULLableBoolean(iParmMarkedForDeletion.Value)
                'MyBase.MarkedForDeleteFmt = Services.GetNULLableString(iParmFmtMarkedForDeletion.Value)
                'MyBase.PublishDate = Services.GetNULLableDateTime(iParmPublishDate.Value)
                'MyBase.ExpireDate = Services.GetNULLableDateTime(iParmExpireDate.Value)
                'MyBase.LastModDate = Services.GetNULLableDateTime(iParmLastModDate.Value)
                'MyBase.LastModBy = Services.GetNULLableInteger(iParmLastModifiedBy.Value)
                'MyBase.LastModByName = Services.GetNULLableString(iParmLastModifiedByName.Value)
                'MyBase.JobID = Services.GetNULLableInteger(iParmJobID.Value)
                'MyBase.JobName = Services.GetNULLableString(iParmJobName.Value)
                'MyBase.JobDescription = Services.GetNULLableString(iParmJobDescription.Value)

                ' set workflow properties
                Me.PublishDate = Services.GetNULLableDateTime(row("PublishDate"))
                Me.ExpireDate = Services.GetNULLableDateTime(row("ExpirationDate"))
                Me.WorkflowStatus = row("WorkflowStatus").ToString
                Me.LastModDate = Services.GetNULLableDateTime(row("LastModifiedDate"))
                Me.LastModBy = Services.GetNULLableInteger(row("LastModifiedBy"))
                Me.LastModByName = row("LastModifiedByName").ToString
                Me.MarkedForDelete = Services.GetNULLableInteger(row("MarkedForDeletion"))
                Me.MarkedForDeleteFmt = row("FmtMarkedForDeletion").ToString
                Me.JobID = Services.GetNULLableInteger(row("DeploymentJobID"))
                Me.JobName = row("JobName").ToString
                Me.JobDescription = row("JobDescription").ToString
            End If
        Catch ex As Exception
            Throw New NLTException("Error retrieving Header Side Content.", ex, "HeaderSideContentModule.vb", "Sub Fill()")
        End Try


    End Sub

    Public Function Save() As Boolean Implements IHeaderSideContentModule.Save

        Dim success As Boolean
        Dim iCmd As IDbCommand
        Dim iParmHeaderSideContentContentModuleId As IDbDataParameter
        Dim iParmPageModuleRelnId As IDbDataParameter = Nothing
        Dim iParmPageId As IDbDataParameter = Nothing

        Dim data As New DataAccess(SiteProfile.GetConnectionString, DataAccess.DataProvider.SQL)
        Dim dict As New System.Collections.Specialized.HybridDictionary
        Dim strStoredProc As String

        ' determine whether item should be added or updated
        '@HeaderSideContentContentModuleID int = null,
        If Me.HeaderSideContentModuleId = 0 Then
            strStoredProc = "sp__AddHeaderSideContentModule"
            '@PageID int = null,
            iParmPageID = data.GetParameter(DataAccess.DataProvider.SQL, "@PageID", DbType.Int32, Me.PageId, 4, ParameterDirection.Input)
            iParmHeaderSideContentContentModuleID = data.GetParameter(DataAccess.DataProvider.SQL, "@HeaderSideContentModuleID", DbType.Int32, System.DBNull.Value, 4, ParameterDirection.Output)
            iParmPageModuleRelnID = data.GetParameter(DataAccess.DataProvider.SQL, "@PageModuleRelnID", DbType.Int32, System.DBNull.Value, 4, ParameterDirection.Output)
        Else
            strStoredProc = "sp__UpdateHeaderSideContentModule"
            iParmHeaderSideContentContentModuleID = data.GetParameter(DataAccess.DataProvider.SQL, "@HeaderSideContentModuleID", DbType.Int32, Me.HeaderSideContentModuleId, 4, ParameterDirection.Input)
        End If

        '@ModuleType varchar(50) = null,
        Dim iParmModuleType As IDbDataParameter = data.GetParameter(DataAccess.DataProvider.SQL, "@ModuleType", DbType.String, Me.ModuleType, 50, ParameterDirection.Input)
        '@ModuleOrder int = null,
        Dim iParmModuleOrder As IDbDataParameter = data.GetParameter(DataAccess.DataProvider.SQL, "@ModuleOrder", DbType.Int32, Me.ModuleOrder, 4, ParameterDirection.Input)
        '@ShowTitle bit = 0,
        Dim iParmShowTitle As IDbDataParameter = data.GetParameter(DataAccess.DataProvider.SQL, "@ShowTitle", DbType.Boolean, Me.ShowTitle, 1, ParameterDirection.Input)
        '@Title varchar(50) = null,
        Dim iParmTitle As IDbDataParameter = data.GetParameter(DataAccess.DataProvider.SQL, "@Title", DbType.String, Me.Title, 50, ParameterDirection.Input)

        '@LineText1 varchar(200) = null,
        Dim iParmLineText1 As IDbDataParameter = data.GetParameter(DataAccess.DataProvider.SQL, "@LineText1", DbType.String, Me.LineText1, 200, ParameterDirection.Input)
        '@InternalLink1 int = null,
        Dim iParmInternalLink1 As IDbDataParameter = data.GetParameter(DataAccess.DataProvider.SQL, "@InternalLink1", DbType.Int32, Me.InternalLink1, 4, ParameterDirection.Input)
        '@InternalLink1Type varchar(50) = null,
        Dim iParmInternalLink1Type As IDbDataParameter = data.GetParameter(DataAccess.DataProvider.SQL, "@InternalLink1Type", DbType.String, Me.InternalLink1Type, 50, ParameterDirection.Input)
        '@ExternalLink1 varchar(300) = null,
        Dim iParmExternalLink1 As IDbDataParameter = data.GetParameter(DataAccess.DataProvider.SQL, "@ExternalLink1", DbType.String, Me.ExternalLink1, 300, ParameterDirection.Input)

        '@LineText2 varchar(200) = null,
        Dim iParmLineText2 As IDbDataParameter = data.GetParameter(DataAccess.DataProvider.SQL, "@LineText2", DbType.String, Me.LineText2, 200, ParameterDirection.Input)
        '@InternalLink2 int = null,
        Dim iParmInternalLink2 As IDbDataParameter = data.GetParameter(DataAccess.DataProvider.SQL, "@InternalLink2", DbType.Int32, Me.InternalLink2, 4, ParameterDirection.Input)
        '@InternalLink2Type varchar(50) = null,
        Dim iParmInternalLink2Type As IDbDataParameter = data.GetParameter(DataAccess.DataProvider.SQL, "@InternalLink2Type", DbType.String, Me.InternalLink2Type, 50, ParameterDirection.Input)
        '@ExternalLink2 varchar(300) = null,
        Dim iParmExternalLink2 As IDbDataParameter = data.GetParameter(DataAccess.DataProvider.SQL, "@ExternalLink2", DbType.String, Me.ExternalLink2, 300, ParameterDirection.Input)

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
            .Add(iParmHeaderSideContentContentModuleID)
            If iParmPageID IsNot Nothing Then
                .Add(iParmPageID)
            End If
            If iParmPageModuleRelnID IsNot Nothing Then
                .Add(iParmPageModuleRelnID)
            End If
            .Add(iParmModuleType)
            .Add(iParmModuleOrder)
            .Add(iParmShowTitle)
            .Add(iParmTitle)
            .Add(iParmLineText1)
            .Add(iParmInternalLink1)
            .Add(iParmInternalLink1Type)
            .Add(iParmExternalLink1)
            .Add(iParmLineText2)
            .Add(iParmInternalLink2)
            .Add(iParmInternalLink2Type)
            .Add(iParmExternalLink2)
            .Add(iParmPublishDate)
            .Add(iParmExpireDate)
            .Add(iParmJobID)
            .Add(iParmUserID)
        End With

        dict.Add(dict.Count, iCmd)

        Try
            success = data.ExecuteNonQuery(dict)
            If success Then
                If Me.HeaderSideContentModuleId = 0 Then
                    ' set the id
                    Me.HeaderSideContentModuleId = iParmHeaderSideContentContentModuleID.Value
                End If
            End If

            Return success
        Catch ex As Exception
            Throw New NLTException("Error saving Header Side Content.", ex, "HeaderSideContentModule.vb", "Function Save() As Boolean")
        End Try
    End Function
End Class