Imports Microsoft.VisualBasic

Public Class DeploymentJob
    Implements IDeploymentJob
    Private _mDeploymentJobId As Integer
    Private _mJobName As String
    Private _mJobDescription As String
    Private _mReviewBy As Integer
    Private _mReviewByName As String
    Private _mApprovedBy As Integer
    Private _mApprovedByName As String
    Private _mDeploymentDate As Date
    Private _mDeployedBy As Integer
    Private _mDeployedByName As String
    Private _mWorkflowStatus As String
    Private _mLastModDate As Date
    Private _mLastModBy As Integer
    Private _mLastModByName As String
    Private _mActiveFlag As Boolean
    Public Sub New()

    End Sub

    Public Sub New(ByVal id As Integer)
        Me.DeploymentJobID = ID
    End Sub

    Public Enum WorkflowStatusType
        Working
        PendingReview
        PendingApproval
        PendingDeployment
        Live
    End Enum

    Public Property ActiveFlag() As Boolean Implements IDeploymentJob.ActiveFlag
        Get
            Return _mActiveFlag
        End Get
        Set(ByVal value As Boolean)
            _mActiveFlag = False
        End Set
    End Property

    Public Property ApprovedBy() As Integer Implements IDeploymentJob.ApprovedBy
        Get
            Return _mApprovedBy
        End Get
        Set(ByVal value As Integer)
            _mApprovedBy = value
        End Set
    End Property
    Public Property ApprovedByName() As String Implements IDeploymentJob.ApprovedByName
        Get
            Return _mApprovedByName
        End Get
        Set(ByVal value As String)
            _mApprovedByName = value.Trim
        End Set
    End Property

    Public Property DeployedBy() As Integer Implements IDeploymentJob.DeployedBy
        Get
            Return _mDeployedBy
        End Get
        Set(ByVal value As Integer)
            _mDeployedBy = value
        End Set
    End Property
    Public Property DeployedByName() As String Implements IDeploymentJob.DeployedByName
        Get
            Return _mDeployedByName
        End Get
        Set(ByVal value As String)
            _mDeployedByName = value
        End Set
    End Property

    Public Property DeploymentDate() As Date Implements IDeploymentJob.DeploymentDate
        Get
            Return _mDeploymentDate
        End Get
        Set(ByVal value As Date)
            _mDeploymentDate = value
        End Set
    End Property

    Public Property DeploymentJobId() As Integer Implements IDeploymentJob.DeploymentJobId
        Get
            Return _mDeploymentJobId
        End Get
        Set(ByVal value As Integer)
            _mDeploymentJobId = value
        End Set
    End Property

    Public Property JobDescription() As String Implements IDeploymentJob.JobDescription
        Get
            Return _mJobDescription
        End Get
        Set(ByVal value As String)
            _mJobDescription = value
        End Set
    End Property

    Public Property JobName() As String Implements IDeploymentJob.JobName
        Get
            Return _mJobName
        End Get
        Set(ByVal value As String)
            _mJobName = value
        End Set
    End Property

    Public Property LastModBy() As Integer Implements IDeploymentJob.LastModBy
        Get
            Return _mLastModBy
        End Get
        Set(ByVal value As Integer)
            _mLastModBy = value
        End Set
    End Property
    Public Property LastModByName() As String Implements IDeploymentJob.LastModByName
        Get
            Return _mLastModByName
        End Get
        Set(ByVal value As String)
            _mLastModByName = value.Trim
        End Set
    End Property

    Public Property LastModDate() As Date Implements IDeploymentJob.LastModDate
        Get
            Return _mLastModDate
        End Get
        Set(ByVal value As Date)
            _mLastModDate = value
        End Set
    End Property

    Public Property ReviewBy() As Integer Implements IDeploymentJob.ReviewBy
        Get
            Return _mReviewBy
        End Get
        Set(ByVal value As Integer)
            _mReviewBy = value
        End Set
    End Property
    Public Property ReviewByName() As String Implements IDeploymentJob.ReviewByName
        Get
            Return _mReviewByName
        End Get
        Set(ByVal value As String)
            _mReviewByName = value.Trim
        End Set
    End Property

    Public Property WorkflowStatus() As String Implements IDeploymentJob.WorkflowStatus
        Get
            Return _mWorkflowStatus
        End Get
        Set(ByVal value As String)
            _mWorkflowStatus = value.Trim.ToUpper
        End Set
    End Property

    Public Function Delete() As Boolean Implements IDeploymentJob.Delete

    End Function

    Public Function Save() As Boolean Implements IDeploymentJob.Save

        Dim success As Boolean
        Dim iCmd As IDbCommand
        Dim iParmId As IDbDataParameter
        Dim data As New DataAccess(SiteProfile.GetConnectionString, DataAccess.DataProvider.SQL)
        Dim dict As New System.Collections.Specialized.HybridDictionary
        Dim strStoredProc As String

        ' determine whether item should be added or updated
        If Me.DeploymentJobID = 0 Then
            strStoredProc = "sp__AddDeploymentJob"
            iParmID = data.GetParameter(DataAccess.DataProvider.SQL, "@JobId", DbType.Int32, System.DBNull.Value, 4, ParameterDirection.Output)
            Me.WorkflowStatus = "WORKING"
        Else
            strStoredProc = "sp__UpdateDeploymentJob"
            iParmID = data.GetParameter(DataAccess.DataProvider.SQL, "@JobId", DbType.Int32, Me.DeploymentJobID, 4, ParameterDirection.Input)
        End If
        '@UserID int,
        Dim iParmUserId As IDbDataParameter = data.GetParameter(DataAccess.DataProvider.SQL, "@UserID", DbType.Int32, Me.LastModBy, 4, ParameterDirection.Input)
        '@JobName varchar(100),
        Dim iParmName As IDbDataParameter = data.GetParameter(DataAccess.DataProvider.SQL, "@JobName", DbType.String, Me.JobName, 100, ParameterDirection.Input)
        '@JobDescription varchar(500),
        Dim iParmDesc As IDbDataParameter = data.GetParameter(DataAccess.DataProvider.SQL, "@JobDescription", DbType.String, Me.JobDescription, 500, ParameterDirection.Input)
        '@WorkflowStatus varchar(50) = 'WORKING',
        Dim iParmWorkflowStatus As IDbDataParameter = data.GetParameter(DataAccess.DataProvider.SQL, "@WorkflowStatus", DbType.String, Me.WorkflowStatus, 50, ParameterDirection.Input)
        '@DeploymentDate datetime,
        Dim iParmDeploymentDate As IDbDataParameter = data.GetParameter(DataAccess.DataProvider.SQL, "@DeploymentDate", DbType.Date, Me.DeploymentDate, 8, ParameterDirection.Input)
        '@ApprovedBy int,
        Dim iParmApprovedBy As IDbDataParameter = data.GetParameter(DataAccess.DataProvider.SQL, "@ApprovedBy", DbType.Int32, Me.ApprovedBy, 4, ParameterDirection.Input)
        '@DeployedBy int,
        Dim iParmDeployedBy As IDbDataParameter = data.GetParameter(DataAccess.DataProvider.SQL, "@DeployedBy", DbType.Int32, Me.DeployedBy, 4, ParameterDirection.Input)
        '@ReviewBy int,
        Dim iParmReviewBy As IDbDataParameter = data.GetParameter(DataAccess.DataProvider.SQL, "@ReviewBy", DbType.Int32, Me.ReviewBy, 4, ParameterDirection.Input)

        '' create cmd and add parms
        iCmd = data.GetCommand(strStoredProc, CommandType.StoredProcedure, DataAccess.DataProvider.SQL)
        With iCmd.Parameters
            .Add(iParmID)
            .Add(iParmUserID)
            .Add(iParmName)
            .Add(iParmDesc)
            .Add(iParmWorkflowStatus)
            .Add(iParmDeploymentDate)
            .Add(iParmApprovedBy)
            .Add(iParmDeployedBy)
            .Add(iParmReviewBy)
        End With

        dict.Add(dict.Count, iCmd)

        Try
            success = data.ExecuteNonQuery(dict)
            If success Then
                If Me.DeploymentJobID = 0 Then
                    ' set the id
                    Me.DeploymentJobID = Services.GetNULLableInteger(iParmID.Value)
                End If
            End If

            Return success
        Catch ex As Exception
            Throw New NLTException("Error saving Deployment Job.", ex, "DeploymentJob.vb", "Function Save() As Boolean")
        End Try


    End Function

    Public Function SetWorkflowStatus() As Boolean
        'proc sp__UpdateJobStatus
        '@UserID int = null,
        '@JobId int = null,
        '@WorkflowStatus varchar(50) = 'WORKING'
        Dim success As Boolean
        Dim iCmd As IDbCommand
        Dim data As New DataAccess(SiteProfile.GetConnectionString, DataAccess.DataProvider.SQL)
        Dim dict As New System.Collections.Specialized.HybridDictionary

        iCmd = data.GetCommand("sp__UpdateJobStatus", CommandType.StoredProcedure, DataAccess.DataProvider.SQL)
        Dim iParmJobId As IDbDataParameter = data.GetParameter(DataAccess.DataProvider.SQL, "@JobID", DbType.Int32, Me.DeploymentJobID, 4, ParameterDirection.Input)
        Dim iParmUserId As IDbDataParameter = data.GetParameter(DataAccess.DataProvider.SQL, "@UserID", DbType.Int32, Me.LastModBy, 4, ParameterDirection.Input)
        Dim iParmWorkflowStatus As IDbDataParameter = data.GetParameter(DataAccess.DataProvider.SQL, "@WorkflowStatus", DbType.String, Me.WorkflowStatus, 50, ParameterDirection.Input)

        With iCmd.Parameters
            .Add(iParmJobID)
            .Add(iParmUserID)
            .Add(iParmWorkflowStatus)
        End With

        dict.Add(dict.Count, iCmd)

        Try
            success = data.ExecuteNonQuery(dict)
            Return success
        Catch ex As Exception
            Throw New NLTException("Error updating Job WorkflowStatus.", ex, "DeploymentJob.vb", "Function SetWorkflowStatus() As Boolean")
        End Try
    End Function


    Public Sub Fill() Implements IDeploymentJob.Fill

        Try

            Dim data As New DataAccess(SiteProfile.GetConnectionString, DataAccess.DataProvider.SQL)
            Dim strStoredProc As String = ""
            Dim iParmId As IDbDataParameter = Nothing
            Dim iParmLiveMode As IDbDataParameter = Nothing
            Dim iCmd As IDbCommand = Nothing

            If Me.DeploymentJobID <> 0 Then
                strStoredProc = "sp__GetDeploymentJobByID"
                iParmID = data.GetParameter(DataAccess.DataProvider.SQL, "@DeploymentJobID", DbType.Int32, Me.DeploymentJobID, 4, ParameterDirection.Input)
            End If

            iCmd = data.GetCommand(strStoredProc, CommandType.StoredProcedure, DataAccess.DataProvider.SQL)
            With iCmd
                .Parameters.Add(iParmID)
            End With

            Dim dt As DataTable = data.GetDataTable(iCmd)
            If dt.Rows.Count > 0 Then
                Dim row As DataRow = dt.Rows(0)
                ' fill properties
                Me.DeploymentJobID = Services.GetNULLableInteger(row("DeploymentJobID"))
                Me.JobName = Services.GetNULLableString(row("JobName"))
                Me.JobDescription = Services.GetNULLableString(row("JobDescription"))
                Me.ReviewBy = Services.GetNULLableInteger(row("ReviewBy"))
                Me.ReviewByName = Services.GetNULLableString(row("ReviewByName"))
                Me.ApprovedBy = Services.GetNULLableInteger(row("ApprovedBy"))
                Me.ApprovedByName = Services.GetNULLableString(row("ApprovedByName"))
                Me.DeploymentDate = Services.GetNULLableDateTime(row("DeploymentDate"))
                Me.DeployedBy = Services.GetNULLableInteger(row("DeployedBy"))
                Me.DeployedByName = Services.GetNULLableString(row("DeployedByName"))
                Me.WorkflowStatus = Services.GetNULLableString(row("WorkflowStatus"))
                Me.LastModDate = Services.GetNULLableDateTime(row("LastModifiedDate"))
                Me.LastModBy = Services.GetNULLableInteger(row("LastModifiedBy"))
                Me.LastModByName = Services.GetNULLableString(row("LastModifiedByName"))
            End If

        Catch ex As Exception
            Throw New NLTException("Error retrieving Deployment Job.", ex, "DeploymentJob.vb", "Function Fill() As Boolean")
        End Try
    End Sub

    Public Function GetList() As DataTable Implements IDeploymentJob.GetList
        Return Nothing
    End Function

    Public Function GetActiveList() As System.Data.DataTable
        Try
            Dim data As New DataAccess(SiteProfile.GetConnectionString, DataAccess.DataProvider.SQL)
            Dim iCmd As IDbCommand = data.GetCommand("sp__GetActiveDeploymentJobs", CommandType.StoredProcedure, DataAccess.DataProvider.SQL)
            Dim dt As DataTable = data.GetDataTable(iCmd)
            Return dt
        Catch ex As Exception
            Throw New NLTException("Error retrieving non-LIVE Deployment Jobs.", ex, "DeploymentJob.vb", "Public Function GetList() As DataTable")
        End Try
    End Function

    Public Function DeployCmsContent() As Boolean
        'sp_UTIL_DeployCMSContent
        '@UserID int = 0,
        '@JobID int = 0
        Dim success As Boolean
        Dim iCmd As IDbCommand
        Dim data As New DataAccess(SiteProfile.GetConnectionString, DataAccess.DataProvider.SQL)
        Dim dict As New HybridDictionary

        iCmd = data.GetCommand("sp_UTIL_DeployCMSContent", CommandType.StoredProcedure, DataAccess.DataProvider.SQL)
        Dim iParmJobId As IDbDataParameter = data.GetParameter(DataAccess.DataProvider.SQL, "@JobID", DbType.Int32, Me.DeploymentJobID, 4, ParameterDirection.Input)
        Dim iParmUserId As IDbDataParameter = data.GetParameter(DataAccess.DataProvider.SQL, "@UserID", DbType.Int32, Me.LastModBy, 4, ParameterDirection.Input)
        Dim iParmWorkflowStatus As IDbDataParameter = data.GetParameter(DataAccess.DataProvider.SQL, "@WorkflowStatus", DbType.String, Me.WorkflowStatus, 50, ParameterDirection.Input)

        With iCmd.Parameters
            .Add(iParmJobID)
            .Add(iParmUserID)
        End With

        dict.Add(dict.Count, iCmd)

        Try
            success = data.ExecuteNonQuery(dict)
            Return success
        Catch ex As Exception
            Throw New NLTException("Error updating deploying the job.", ex, "DeploymentJob.vb", "Function DeployCMSContent() As Boolean")
        End Try


    End Function
    ''' <summary>
    ''' this function determines whether, based on job status, the current user can make updates to
    ''' item that is in the current job 
    ''' </summary>
    ''' <returns></returns>
    ''' <remarks></remarks>
    Public Function JobEditsAllowed() As Boolean
        ' an admin can always edit
        If My.User.IsInRole("Administrator") Then
            Return True
        Else
            Select Case Me.WorkflowStatus
                Case "WORKING"
                    ' any user (that can make updates) 
                    Return True
                Case "PENDING REVIEW"
                    Return My.User.IsInRole("Reviewer")
                Case "PENDING APPROVAL"
                    Return My.User.IsInRole("Approver")
                Case "PENDING DEPLOYMENT"
                    Return My.User.IsInRole("Deployer")
            End Select

        End If


    End Function


    Public Function Rollback() As Boolean
        'sp_UTIL_UpdateCMSContentFromLiveSiteByJobID()
        '@UserID int = 0,
        '@JobID int = 0

        Dim success As Boolean
        Dim iCmd As IDbCommand
        Dim data As New DataAccess(SiteProfile.GetConnectionString, DataAccess.DataProvider.SQL)
        Dim dict As New System.Collections.Specialized.HybridDictionary

        iCmd = data.GetCommand("sp_UTIL_UpdateCMSContentFromLiveSiteByJobID", CommandType.StoredProcedure, DataAccess.DataProvider.SQL)
        '@UserID int = null,
        Dim iParmUserId As IDbDataParameter = data.GetParameter(DataAccess.DataProvider.SQL, "@UserID", DbType.Int32, Me.LastModBy, 4, ParameterDirection.Input)
        '@JobID int = null,
        Dim iParmJobId As IDbDataParameter = data.GetParameter(DataAccess.DataProvider.SQL, "@JobID", DbType.Int32, Me.DeploymentJobID, 4, ParameterDirection.Input)
        With iCmd.Parameters
            .Add(iParmJobID)
            .Add(iParmUserID)
        End With

        dict.Add(dict.Count, iCmd)

        Try
            success = data.ExecuteNonQuery(dict)
            Return success
        Catch ex As Exception
            Throw New NLTException("Error rolling back the deployment job.", ex, "DeploymentJob.vb", "Function Rollback() As Boolean")
        End Try


    End Function
End Class
