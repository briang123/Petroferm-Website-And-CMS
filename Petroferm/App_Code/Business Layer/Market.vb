Imports Microsoft.VisualBasic

Public Class Market
    Inherits WorkflowItem

    Private _mMarketId As Integer
    Private _mBusUnitId As Integer
    Private _mMarketName As String
    Private _mOrder As Integer
    Private _mLiveModeStatus As WorkflowItem.LiveMode
    Private _mImageModules As ImageModules
    Private _mTopMenuNavigationRegion As ArrayList
    Private _mHeaderImageRegion As ArrayList
    Private _mHeaderSideImageRegion As ArrayList

    Public Sub New()
    End Sub

    Public Sub New(ByVal marketId As Integer)
        Me.MarketID = MarketId
    End Sub

    Public Property ImageModules() As ImageModules
        Get
            Return _mImageModules
        End Get
        Set(ByVal value As ImageModules)
            _mImageModules = value
        End Set
    End Property

    Public Property LiveModeStatus() As WorkflowItem.LiveMode
        Get
            Return _mLiveModeStatus
        End Get
        Set(ByVal value As WorkflowItem.LiveMode)
            _mLiveModeStatus = value
        End Set
    End Property

    Public Property MarketId() As Integer
        Get
            Return _mMarketId
        End Get
        Set(ByVal value As Integer)
            _mMarketId = value
        End Set
    End Property

    Public Property BusUnitId() As Integer
        Get
            Return _mBusUnitId
        End Get
        Set(ByVal value As Integer)
            _mBusUnitId = value
        End Set
    End Property

    Public Property MarketName() As String
        Get
            Return _mMarketName
        End Get
        Set(ByVal value As String)
            _mMarketName = value
        End Set
    End Property

    Public Property Order() As Integer
        Get
            Return _mOrder
        End Get
        Set(ByVal value As Integer)
            _mOrder = value
        End Set
    End Property


    Public Property TopMenuNavigationRegion() As ArrayList
        Get
            Return _mTopMenuNavigationRegion
        End Get
        Set(ByVal value As ArrayList)
            _mTopMenuNavigationRegion = value
        End Set
    End Property

    Public Property HeaderImageRegion() As ArrayList
        Get
            Return _mHeaderImageRegion
        End Get
        Set(ByVal value As ArrayList)
            _mHeaderImageRegion = value
        End Set
    End Property

    Public Property HeaderSideImageRegion() As ArrayList
        Get
            Return _mHeaderSideImageRegion
        End Get
        Set(ByVal value As ArrayList)
            _mHeaderSideImageRegion = value
        End Set
    End Property

    Function Save() As Boolean
        Dim success As Boolean
        Dim iCmd As IDbCommand
        Dim iParmId As IDbDataParameter
        Dim iParmBusId As IDbDataParameter = Nothing

        Dim data As New DataAccess(SiteProfile.GetConnectionString, DataAccess.DataProvider.SQL)
        Dim dict As New System.Collections.Specialized.HybridDictionary
        Dim strStoredProc As String

        ' determine whether item should be added or updated
        If Me.MarketID = 0 Then
            strStoredProc = "sp__AddMarket"
            iParmID = data.GetParameter(DataAccess.DataProvider.SQL, "@MktID", DbType.Int32, System.DBNull.Value, 4, ParameterDirection.Output)
            iParmBusID = data.GetParameter(DataAccess.DataProvider.SQL, "@BusID", DbType.Int32, Me.BusUnitID, 4, ParameterDirection.Input)
        Else
            strStoredProc = "sp__UpdateMarket"
            iParmID = data.GetParameter(DataAccess.DataProvider.SQL, "@MktID", DbType.Int32, Me.MarketID, 4, ParameterDirection.Input)
        End If

        Dim iParmName As IDbDataParameter = data.GetParameter(DataAccess.DataProvider.SQL, "@MktName", DbType.String, Me.MarketName, 200, ParameterDirection.Input)
        Dim iParmJobId As IDbDataParameter = data.GetParameter(DataAccess.DataProvider.SQL, "@JobID", DbType.Int32, Me.JobID, 4, ParameterDirection.Input)

        Dim iParmUserId As IDbDataParameter = data.GetParameter(DataAccess.DataProvider.SQL, "@UserID", DbType.Int32, Me.LastModBy, 4, ParameterDirection.Input)
        Dim iParmOrder As IDbDataParameter = data.GetParameter(DataAccess.DataProvider.SQL, "@MktOrder", DbType.Int32, Me.Order, 1, ParameterDirection.Input)
        Dim iParmExpireDate As IDbDataParameter
        If Me.ExpireDate <> #12:00:00 AM# Then
            iParmExpireDate = data.GetParameter(DataAccess.DataProvider.SQL, "@ExpireDate", DbType.Date, Me.ExpireDate, 8, ParameterDirection.Input)
        Else
            iParmExpireDate = data.GetParameter(DataAccess.DataProvider.SQL, "@ExpireDate", DbType.Date, System.DBNull.Value, 8, ParameterDirection.Input)
        End If
        Dim iParmPublishDate As IDbDataParameter = data.GetParameter(DataAccess.DataProvider.SQL, "@PublishDate", DbType.Date, Me.PublishDate, 8, ParameterDirection.Input)

        '' create cmd and add parms
        iCmd = data.GetCommand(strStoredProc, CommandType.StoredProcedure, DataAccess.DataProvider.SQL)
        With iCmd.Parameters
            .Add(iParmID)
            .Add(iParmName)
            .Add(iParmJobID)
            If iParmBusID IsNot Nothing Then
                .Add(iParmBusID)
            End If
            .Add(iParmUserID)
            .Add(iParmOrder)
            .Add(iParmExpireDate)
            .Add(iParmPublishDate)
        End With

        dict.Add(dict.Count, iCmd)

        Try
            success = data.ExecuteNonQuery(dict)
            If success Then
                If Me.MarketID = 0 Then
                    ' set the id
                    Me.MarketID = Services.GetNULLableInteger(iParmID.Value)
                End If
            End If

            Return success
        Catch ex As Exception
            Throw New NLTException("Error saving Market.", ex, "Market.vb", "Function Save() As Boolean")
        Finally
            If iCmd.Connection.State <> ConnectionState.Closed Then
                iCmd.Connection.Close()
            End If
        End Try



    End Function

    Function Delete() As Boolean
        Dim success As Boolean
        Dim iCmd As IDbCommand
        Dim data As New DataAccess(SiteProfile.GetConnectionString, DataAccess.DataProvider.SQL)
        Dim dict As New System.Collections.Specialized.HybridDictionary

        If MarketID <> 0 Then
            Me.MarketID = MarketID
        End If

        iCmd = data.GetCommand("sp__DeleteMarket", CommandType.StoredProcedure, DataAccess.DataProvider.SQL)
        Dim iParmId As IDbDataParameter = data.GetParameter(DataAccess.DataProvider.SQL, "@MarketID", DbType.Int32, Me.MarketID, 4, ParameterDirection.Input)
        Dim iParmJobId As IDbDataParameter = data.GetParameter(DataAccess.DataProvider.SQL, "@JobID", DbType.Int32, Me.JobID, 4, ParameterDirection.Input)
        Dim iParmUserId As IDbDataParameter = data.GetParameter(DataAccess.DataProvider.SQL, "@UserID", DbType.Int32, Me.LastModBy, 4, ParameterDirection.Input)

        With iCmd.Parameters
            .Add(iParmID)
            .Add(iParmJobID)
            .Add(iParmUserID)
        End With

        dict.Add(dict.Count, iCmd)

        Try
            success = data.ExecuteNonQuery(dict)
            Return success
        Catch ex As Exception
            Throw New NLTException("Error deleting Market.", ex, "Market.vb", "Function Delete() As Boolean")
        Finally
            If iCmd.Connection.State <> ConnectionState.Closed Then
                iCmd.Connection.Close()
            End If
        End Try


    End Function

    Function GetListByBu(ByVal busUnitId As Integer, ByVal mode As LiveMode) As DataView
        Try
            Dim dvSource As DataView
            Dim data As New DataAccess(SiteProfile.GetConnectionString, DataAccess.DataProvider.SQL)
            Dim iCmd As IDbCommand = data.GetCommand("sp__GetMarketsByBU", CommandType.StoredProcedure, DataAccess.DataProvider.SQL)
            If busUnitID = 0 Then
                busUnitID = Me.BusUnitID
            End If
            Dim iParmBusUnitId As IDbDataParameter = data.GetParameter(DataAccess.DataProvider.SQL, "@BusUnitID", DbType.Int32, busUnitID, 4, ParameterDirection.Input)
            Dim iParmLiveMode As IDbDataParameter = data.GetParameter(DataAccess.DataProvider.SQL, "@LiveMode", DbType.Int32, Convert.ToInt32(mode), 4, ParameterDirection.Input)

            iCmd.Parameters.Add(iParmLiveMode)
            iCmd.Parameters.Add(iParmBusUnitID)

            Dim dt As DataTable = data.GetDataTable(iCmd)

            dvSource = New DataView(dt)
            Return dvSource

        Catch ex As Exception
            Throw New NLTException("Error retrieving Markets.", ex, "Market.vb", "Function GetListByBU() As DataView Implements IBusinessObject.GetList")
        End Try

    End Function

    Function Fill(ByVal liveMode As Boolean) As Boolean

        Try
            Dim data As New DataAccess(SiteProfile.GetConnectionString, DataAccess.DataProvider.SQL)
            Dim dict As New System.Collections.Specialized.HybridDictionary

            Dim strStoredProc As String = ""
            Dim iParmId As IDbDataParameter
            Dim iParmLiveMode As IDbDataParameter

            'PROC(sp__GetMarketByID)
            '@MarketID int = null,
            '@LiveMode bit = 1,
            strStoredProc = "sp__GetMarketByID"
            iParmID = data.GetParameter(DataAccess.DataProvider.SQL, "@MarketID", DbType.Int32, Me.MarketID, 4, ParameterDirection.Input)
            iParmLiveMode = data.GetParameter(DataAccess.DataProvider.SQL, "@LiveMode", DbType.Int32, Convert.ToInt32(liveMode), 4, ParameterDirection.Input)
            ' need all of the output parms here, which will be used to set 
            ' the properties of this class
            '@BusUnitID int OUTPUT,
            Dim iParmBusUnitId As IDbDataParameter = data.GetParameter(DataAccess.DataProvider.SQL, "@BusUnitID", DbType.Int32, System.DBNull.Value, 4, ParameterDirection.Output)
            '@MarketName varchar(100) OUTPUT,
            Dim iParmMarketName As IDbDataParameter = data.GetParameter(DataAccess.DataProvider.SQL, "@MarketName", DbType.String, String.Empty, 100, ParameterDirection.Output)
            '    Dim iParmMarketName As IDbDataParameter = New System.Data.SqlClient.SqlParameter
            '@MarketOrder int OUTPUT,
            Dim iParmMarketOrder As IDbDataParameter = data.GetParameter(DataAccess.DataProvider.SQL, "@MarketOrder", DbType.Int32, System.DBNull.Value, 3, ParameterDirection.Output)
            '@WorkflowStatus varchar(50) OUTPUT,
            Dim iParmWorkflowStatus As IDbDataParameter = data.GetParameter(DataAccess.DataProvider.SQL, "@WorkflowStatus", DbType.String, System.DBNull.Value, 50, ParameterDirection.Output)
            '@MarkedForDeletion bit OUTPUT,
            Dim iParmMarkedForDeletion As IDbDataParameter = data.GetParameter(DataAccess.DataProvider.SQL, "@MarkedForDeletion", DbType.Int32, System.DBNull.Value, 1, ParameterDirection.Output)
            '@FmtMarkedForDeletion varchar(3) OUTPUT,
            Dim iParmFmtMarkedForDeletion As IDbDataParameter = data.GetParameter(DataAccess.DataProvider.SQL, "@FmtMarkedForDeletion", DbType.String, System.DBNull.Value, 3, ParameterDirection.Output)
            '@PublishDate datetime OUTPUT,
            Dim iParmPublishDate As IDbDataParameter = data.GetParameter(DataAccess.DataProvider.SQL, "@PublishDate", DbType.Date, System.DBNull.Value, 8, ParameterDirection.Output)
            '@ExpireDate datetime OUTPUT,
            Dim iParmExpireDate As IDbDataParameter = data.GetParameter(DataAccess.DataProvider.SQL, "@ExpireDate", DbType.Date, System.DBNull.Value, 8, ParameterDirection.Output)
            '@LastModifiedDate datetime OUTPUT,
            Dim iParmLastModifiedDate As IDbDataParameter = data.GetParameter(DataAccess.DataProvider.SQL, "@LastModifiedDate", DbType.Date, System.DBNull.Value, 8, ParameterDirection.Output)
            '@LastModifiedBy int OUTPUT,
            Dim iParmLastModifiedBy As IDbDataParameter = data.GetParameter(DataAccess.DataProvider.SQL, "@LastModifiedBy", DbType.Int32, System.DBNull.Value, 4, ParameterDirection.Output)
            '@LastModifiedByName varchar(150) OUTPUT,
            Dim iParmLastModifiedByName As IDbDataParameter = data.GetParameter(DataAccess.DataProvider.SQL, "@LastModifiedByName", DbType.String, System.DBNull.Value, 150, ParameterDirection.Output)
            '@JobID int OUTPUT,
            Dim iParmJobId As IDbDataParameter = data.GetParameter(DataAccess.DataProvider.SQL, "@JobID", DbType.Int32, JobID, 4, ParameterDirection.Output)
            '@JobName varchar(100) OUTPUT,
            Dim iParmJobName As IDbDataParameter = data.GetParameter(DataAccess.DataProvider.SQL, "@JobName", DbType.String, System.DBNull.Value, 100, ParameterDirection.Output)
            '@JobDescription varchar(500) OUTPUT
            Dim iParmJobDescription As IDbDataParameter = data.GetParameter(DataAccess.DataProvider.SQL, "@JobDescription", DbType.String, System.DBNull.Value, 500, ParameterDirection.Output)
            Dim iCmd As IDbCommand = data.GetCommand(strStoredProc, CommandType.StoredProcedure, DataAccess.DataProvider.SQL)

            With iCmd.Parameters
                .Add(iParmID)
                .Add(iParmLiveMode)
                .Add(iParmBusUnitID)
                .Add(iParmMarketName)
                .Add(iParmMarketOrder)
                .Add(iParmWorkflowStatus)
                .Add(iParmMarkedForDeletion)
                .Add(iParmFmtMarkedForDeletion)
                .Add(iParmPublishDate)
                .Add(iParmExpireDate)
                .Add(iParmLastModifiedDate)
                .Add(iParmLastModifiedBy)
                .Add(iParmLastModifiedByName)
                .Add(iParmJobID)
                .Add(iParmJobName)
                .Add(iParmJobDescription)
            End With

            dict.Add(dict.Count, iCmd)

            If data.ExecuteNonQuery(dict) Then

                ' check to make sure something came back
                If Not iParmBusUnitID.Value Is System.DBNull.Value Then
                    ' fill properties
                    Me.BusUnitID = iParmBusUnitID.Value
                    Me.MarketName = iParmMarketName.Value
                    Me.Order = iParmMarketOrder.Value
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
                    Dim ex As New Exception("No Market was returned for Market ID " & Me.MarketID)
                    Throw New NLTException("Error retrieving Market.", ex, "Market.vb", "Function Fill(liveMode as Boolean) As Boolean")
                End If
            End If

        Catch ex As Exception
            Throw New NLTException("Error retrieving Market.", ex, "Market.vb", "Function Fill(liveMode as Boolean) As Boolean")
        End Try


    End Function

    Function GoToEdit(ByVal businessUnitId As Integer) As Boolean
        My.Response.Redirect("~/cms/MarketEdit.aspx?mktid=" & Me.MarketID.ToString)
    End Function

    Public Sub FillMarketWithImageModules(ByVal marketId As Integer, ByVal liveMode As WorkflowItem.LiveMode)
        Try
            Dim data As New DataAccess(SiteProfile.GetConnectionString, DataAccess.DataProvider.SQL)
            Dim iCmd As IDbCommand = data.GetCommand("sp__GetNavImagesByMarket", CommandType.StoredProcedure, DataAccess.DataProvider.SQL)
            Dim iParmMarketId As IDbDataParameter = data.GetParameter(DataAccess.DataProvider.SQL, "@MarketID", DbType.Int32, Services.GetNULLableInteger(MarketId), 4, ParameterDirection.Input)
            Dim iParmLiveMode As IDbDataParameter = data.GetParameter(DataAccess.DataProvider.SQL, "@LiveMode", DbType.Boolean, LiveMode, 1, ParameterDirection.Input)
            With iCmd.Parameters
                .Add(iParmMarketID)
                .Add(iParmLiveMode)
            End With

            Dim collMarketImages As New ImageModules
            Dim dt As DataTable = data.GetDataTable(iCmd)
            For Each row As DataRow In dt.Rows
                Dim sourceName As String = Services.GetNULLableString(row("SourceName"))
                Dim sourceId As Integer = Services.GetNULLableInteger(row("SourceId"))
                Select Case sourceName.ToUpper
                    Case "NAV ON IMAGE", "NAV OFF IMAGE", "HEADER IMAGE", "HEADER SIDE CONTENT IMAGE"
                        Dim imgMod As New ImageModule(sourceId, WorkflowItem.LiveMode.Live)
                        With imgMod
                            .PageModuleRelnId = Services.GetNULLableInteger(row("PageModuleRelnId"))
                            .ImageId = Services.GetNULLableInteger(row("ImageId"))
                            .ShowTitle = Services.GetNULLableBoolean(row("ShowTitle"))
                            .ModuleType = sourceName.ToUpper
                            .ImageType = Services.GetNULLableString(row("ImageType"))
                            .ImageOrder = Services.GetNULLableInteger(row("ImageOrder"))
                            .ImageModuleId = sourceId
                            .ModuleOrder = Services.GetNULLableInteger(row("ModuleOrder"))
                            With .ImageFile
                                .ImageId = Services.GetNULLableInteger(row("ImageId"))
                                .ImagePath = Services.GetNULLableString(row("ImagePath"))
                                .AltText = Services.GetNULLableString(row("Alt"))
                                .Height = Services.GetNULLableInteger(row("Height"))
                                .Width = Services.GetNULLableInteger(row("Width"))
                            End With
                        End With
                        collMarketImages.Add(imgMod)
                End Select
            Next

            Dim topNavList As ArrayList = Nothing
            topNavList = collMarketImages.GetSortedModulesBySection(PageModules.PageSection.TopMenuNavigationImage)
            topNavList.Sort(New PageModuleComparer(SortDirection.Descending))
            Me.TopMenuNavigationRegion = topNavList

            Dim headerImageList As ArrayList = Nothing
            headerImageList = collMarketImages.GetSortedModulesBySection(PageModules.PageSection.HeaderMenuImage)
            headerImageList.Sort(New PageModuleComparer(SortDirection.Ascending))
            Me.HeaderImageRegion = headerImageList

            Dim headerSideContentImageList As ArrayList = Nothing
            headerSideContentImageList = collMarketImages.GetSortedModulesBySection(PageModules.PageSection.HeaderSideImage)
            headerSideContentImageList.Sort(New PageModuleComparer(SortDirection.Ascending))
            Me.HeaderSideImageRegion = headerSideContentImageList

            Me.ImageModules = collMarketImages

        Catch ex As Exception
            Throw New NLTException("Error retrieving Markets.", ex, "Market.vb", "Sub FillMarketImageModules()")
        End Try

    End Sub


    Public Function GetListByJob(ByVal jobId As Integer) As System.Data.DataTable
        Try
            Dim data As New DataAccess(SiteProfile.GetConnectionString, DataAccess.DataProvider.SQL)
            Dim iCmd As IDbCommand = data.GetCommand("sp__GetMarketsByJobID", CommandType.StoredProcedure, DataAccess.DataProvider.SQL)
            Dim iParmJobId As IDbDataParameter = data.GetParameter(DataAccess.DataProvider.SQL, "@JobID", DbType.Int32, jobID, 4, ParameterDirection.Input)
            iCmd.Parameters.Add(iParmJobID)
            Dim dt As DataTable = data.GetDataTable(iCmd)
            Return dt

        Catch ex As Exception
            Throw New NLTException("Error retrieving Markets by Job.", ex, "Market.vb", "Function GetListByJob(jobID as Integer) As System.Data.DataTable")
        End Try
    End Function


End Class
