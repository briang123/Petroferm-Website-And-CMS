Imports Microsoft.VisualBasic
Imports System.Data
Imports Data
Public MustInherit Class WorkflowItem
    Implements IWorkflowItem
    Private _mPublishDate As Date
    Private _mExpireDate As Date
    Private _mWorkflowStatus As String
    Private _mLastModDate As Date
    Private _mLastModBy As Integer
    Private _mActiveFlag As Boolean
    Private _mMarkedForDelete As Boolean
    Private _mJobId As Integer
    Private _mJobName As String
    Private _mLastModByName As String
    Private _mJobDescription As String
    Private _mMarkedForDeleteFmt As String
    Public Enum LiveMode
        Cms = 0
        Live = 1
    End Enum

    Public Property PublishDate() As Date Implements IWorkflowItem.PublishDate
        Get
            Return _mPublishDate
        End Get
        Set(ByVal value As Date)
            _mPublishDate = value
        End Set
    End Property

    Public Property ExpireDate() As Date Implements IWorkflowItem.ExpireDate
        Get
            Return _mExpireDate
        End Get
        Set(ByVal value As Date)
            _mExpireDate = value
        End Set
    End Property

    Public Property WorkflowStatus() As String Implements IWorkflowItem.WorkflowStatus
        Get
            Return _mWorkflowStatus.ToUpper
        End Get
        Set(ByVal value As String)
            _mWorkflowStatus = value.Trim.ToUpper
        End Set
    End Property

    Public Property LastModDate() As Date Implements IWorkflowItem.LastModDate
        Get
            Return _mLastModDate
        End Get
        Set(ByVal value As Date)
            _mLastModDate = value
        End Set
    End Property

    Public Property LastModBy() As Integer Implements IWorkflowItem.LastModBy
        Get
            Return _mLastModBy
        End Get
        Set(ByVal value As Integer)
            _mLastModBy = value
        End Set
    End Property

    Public Property ActiveFlag() As Boolean Implements IWorkflowItem.ActiveFlag
        Get
            Return _mActiveFlag
        End Get
        Set(ByVal value As Boolean)
            _mActiveFlag = value
        End Set
    End Property

    Public Property MarkedForDelete() As Boolean Implements IWorkflowItem.MarkedForDelete
        Get
            Return _mMarkedForDelete
        End Get
        Set(ByVal value As Boolean)
            _mMarkedForDelete = value
        End Set
    End Property

    Public Property JobId() As Integer Implements IWorkflowItem.JobId
        Get
            Return _mJobId
        End Get
        Set(ByVal value As Integer)
            _mJobId = value
        End Set
    End Property

    Public Property JobName() As String Implements IWorkflowItem.JobName
        Get
            Return _mJobName
        End Get
        Set(ByVal value As String)
            _mJobName = value.Trim
        End Set
    End Property

    Public Property JobDescription() As String Implements IWorkflowItem.JobDescription
        Get
            Return _mJobDescription
        End Get
        Set(ByVal value As String)
            _mJobDescription = value
        End Set
    End Property

    Public Property LastModByName() As String Implements IWorkflowItem.LastModByName
        Get
            Return _mLastModByName
        End Get
        Set(ByVal value As String)
            _mLastModByName = value.Trim
        End Set
    End Property

    Public Property MarkedForDeleteFmt() As String
        Get
            Return _mMarkedForDeleteFmt
        End Get
        Set(ByVal value As String)
            _mMarkedForDeleteFmt = value
        End Set
    End Property

End Class
