Imports Microsoft.VisualBasic
Imports System.Configuration.ConfigurationManager

Public Class PageModule
    Inherits WorkflowItem
    Implements IPageModule
    Private _mPageId As Integer
    Private _mModuleId As Integer
    Private _mModuleOrder As Integer
    Private _mModuleType As String
    Private _mPageModuleRelnId As Integer
    Private _mShowTitle As Boolean

    Public Sub New()
    End Sub

    Public Property PageId() As Integer Implements IPageModule.PageId
        Get
            Return _mPageId
        End Get
        Set(ByVal value As Integer)
            _mPageId = value
        End Set
    End Property

    Public Property ModuleId() As Integer Implements IPageModule.ModuleId
        Get
            Return _mModuleId
        End Get
        Set(ByVal value As Integer)
            _mModuleId = value
        End Set
    End Property

    Public Property ModuleOrder() As Integer Implements IPageModule.ModuleOrder
        Get
            Return _mModuleOrder
        End Get
        Set(ByVal value As Integer)
            _mModuleOrder = value
        End Set
    End Property

    Public Property ModuleType() As String Implements IPageModule.ModuleType
        Get
            Return _mModuleType
        End Get
        Set(ByVal value As String)
            _mModuleType = value
        End Set
    End Property

    Public Property PageModuleRelnId() As Integer Implements IPageModule.PageModuleRelnId
        Get
            Return _mPageModuleRelnId
        End Get
        Set(ByVal value As Integer)
            _mPageModuleRelnId = value
        End Set
    End Property

    Public Property ShowTitle() As Boolean Implements IPageModule.ShowTitle
        Get
            Return _mShowTitle
        End Get
        Set(ByVal value As Boolean)
            _mShowTitle = value
        End Set
    End Property

    Public Function GetList(ByVal pageId As Integer, ByVal liveMode As Boolean) As DataTable Implements IPageModule.GetList

        Try
            Dim data As New DataAccess(SiteProfile.GetConnectionString, DataAccess.DataProvider.SQL)
            Dim iCmd As IDbCommand = data.GetCommand("sp__GetPageModulesByPage", CommandType.StoredProcedure, DataAccess.DataProvider.SQL)

            '	@BusUnitID int = null,
            Dim iParmPageId As IDbDataParameter = data.GetParameter(DataAccess.DataProvider.SQL, "@PageID", DbType.Int32, pageID, 4, ParameterDirection.Input)
            '	@LiveMode bit = 0
            Dim iParmLiveMode As IDbDataParameter = data.GetParameter(DataAccess.DataProvider.SQL, "@LiveMode", DbType.Boolean, liveMode, 1, ParameterDirection.Input)


            iCmd.Parameters.Add(iParmPageID)
            iCmd.Parameters.Add(iParmLiveMode)

            Dim dt As DataTable = data.GetDataTable(iCmd)
            If Not dt Is Nothing Then
                Return dt
            Else
                ' just return empty datatable
                dt = New DataTable
                Return dt
            End If


        Catch ex As Exception
            Throw New NLTException("Error retrieving Page Modules By Page.", ex, "PageModule.vb", "Public Function GetList(ByVal pageID As Integer, ByVal liveMode As Boolean) As DataTable Implements IPageModule.GetList")
        End Try


    End Function
    ''' <summary>
    ''' This returns a list of copyable modules -- Content/Side Content/Header Side Content/Product Blurb types only
    ''' </summary>
    ''' <param name="busUnitId"></param>
    ''' <returns></returns>
    ''' <remarks></remarks>
    Public Function GetCopyListByBu(ByVal busUnitId As Integer) As DataTable

        Try
            Dim data As New DataAccess(SiteProfile.GetConnectionString, DataAccess.DataProvider.SQL)
            Dim iCmd As IDbCommand = data.GetCommand("sp__GetPageModulesByBUForCopy", CommandType.StoredProcedure, DataAccess.DataProvider.SQL)

            '	@BusUnitID int = null,
            Dim iParmBusUnitId As IDbDataParameter = data.GetParameter(DataAccess.DataProvider.SQL, "@BusUnitID", DbType.Int32, busUnitID, 4, ParameterDirection.Input)

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
            Throw New NLTException("Error retrieving Copyable Page Modules By BU.", ex, "PageModule.vb", "Public Function GetCopyListByBU(ByVal busUnitID As Integer) As DataTable")
        End Try
    End Function

    Public Function GetModuleTypes() As String()
        Return AppSettings("PAGE_MODULE_TYPE_LIST").Split(",")
    End Function


    Public Function GetListByJob(ByVal jobId As Integer) As DataTable
        Try
            Dim data As New DataAccess(SiteProfile.GetConnectionString, DataAccess.DataProvider.SQL)
            Dim iCmd As IDbCommand = data.GetCommand("sp__GetPageModulesByJobId", CommandType.StoredProcedure, DataAccess.DataProvider.SQL)
            Dim iParmJobId As IDbDataParameter = data.GetParameter(DataAccess.DataProvider.SQL, "@JobID", DbType.Int32, jobID, 4, ParameterDirection.Input)
            iCmd.Parameters.Add(iParmJobID)
            Dim dt As DataTable = data.GetDataTable(iCmd)
            Return dt

        Catch ex As Exception
            Throw New NLTException("Error retrieving Page Modules by Job.", ex, "PageModule.vb", "Function GetListByJob(jobID) As System.Data.DataTable")
        End Try
    End Function

End Class
