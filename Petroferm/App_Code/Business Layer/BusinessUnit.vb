Imports Microsoft.VisualBasic
Imports System.Data
Imports Data
Public Class BusinessUnit
    Inherits WorkflowItem

    Private _mBusUnitId As Integer
    Private _mLogoImage As New ImageFile
    Private _mMarkets As SortedList
    Private _mBusName As String
    Private _collMarkets As New SortedList
    Private _mPublishDate As Date
    Private _mExpireDate As Date
    Private _mDocAuth As Integer
    Private _mLiveModeStatus As WorkflowItem.LiveMode

    ' task #28 - 12/24/06 - kr
    Private _mImageModules As New ImageModules
    Private _mTopMenuNavigationRegion As New ArrayList
    Private _mHeaderImageRegion As New ArrayList
    Private _mHeaderSideImageRegion As New ArrayList

    Public Sub New()
        MyBase.New()
    End Sub

    Public Sub New(ByVal busUnitId As Integer)
        MyBase.New()

        Me.BusUnitID = BusUnitID
    End Sub

    Public Sub New(ByVal busUnitId As Integer, ByVal liveMode As WorkflowItem.LiveMode)
        Me.BusUnitID = BusUnitID
        Me.LiveModeStatus = LiveMode
    End Sub

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

    Public Property BusUnitId() As Integer
        Get
            Return _mBusUnitId
        End Get
        Set(ByVal value As Integer)
            _mBusUnitId = value
        End Set
    End Property

    Public Property LogoImage() As ImageFile
        Get
            Return _mLogoImage
        End Get
        Set(ByVal value As ImageFile)
            _mLogoImage = value
        End Set
    End Property

    Public Property BusName() As String
        Get
            Return _mBusName
        End Get
        Set(ByVal value As String)
            _mBusName = value
        End Set
    End Property

    Public Property DocAuth() As Boolean
        Get
            Return _mDocAuth
        End Get
        Set(ByVal value As Boolean)
            _mDocAuth = value
        End Set
    End Property

    Public Property Markets() As SortedList
        Get
            Return _mMarkets
        End Get
        Set(ByVal value As SortedList)
            _mMarkets = value
        End Set
    End Property

    Function Save() As Boolean
        Dim success As Boolean
        Dim iCmd As IDbCommand
        Dim iParmId As IDbDataParameter
        Dim iParmLogoId As IDbDataParameter
        Dim iParmExistingLogoId As IDbDataParameter = Nothing
        Dim data As New DataAccess(SiteProfile.GetConnectionString, DataAccess.DataProvider.SQL)
        Dim dict As New System.Collections.Specialized.HybridDictionary
        Dim strStoredProc As String

        ' determine whether item should be added or updated
        If Me.BusUnitID = 0 Then
            strStoredProc = "sp__AddBusinessUnit"
            iParmID = data.GetParameter(DataAccess.DataProvider.SQL, "@BusUnitID", DbType.Int32, System.DBNull.Value, 4, ParameterDirection.Output)
            iParmLogoID = data.GetParameter(DataAccess.DataProvider.SQL, "@LogoID", DbType.Int32, System.DBNull.Value, 4, ParameterDirection.Output)
            iParmExistingLogoID = data.GetParameter(DataAccess.DataProvider.SQL, "@ExistingLogoID", DbType.Int32, Me.LogoImage.ImageId, 4, ParameterDirection.Input)
        Else
            strStoredProc = "sp__UpdateBusinessUnit"
            iParmID = data.GetParameter(DataAccess.DataProvider.SQL, "@BusUnitID", DbType.Int32, Me.BusUnitID, 4, ParameterDirection.Input)
            iParmLogoID = data.GetParameter(DataAccess.DataProvider.SQL, "@LogoID", DbType.Int32, Me.LogoImage.ImageId, 4, ParameterDirection.Input)
        End If

        Dim iParmName As IDbDataParameter = data.GetParameter(DataAccess.DataProvider.SQL, "@BusName", DbType.String, Me.BusName, 200, ParameterDirection.Input)
        Dim iParmJobId As IDbDataParameter = data.GetParameter(DataAccess.DataProvider.SQL, "@JobID", DbType.Int32, Me.JobID, 4, ParameterDirection.Input)
        Dim iParmUserId As IDbDataParameter = data.GetParameter(DataAccess.DataProvider.SQL, "@UserID", DbType.Int32, Me.LastModBy, 4, ParameterDirection.Input)
        Dim iParmDocAuth As IDbDataParameter = data.GetParameter(DataAccess.DataProvider.SQL, "@DocAuth", DbType.Int32, Me.DocAuth, 1, ParameterDirection.Input)
        Dim iParmExpireDate As IDbDataParameter
        If Me.ExpireDate <> #12:00:00 AM# Then
            iParmExpireDate = data.GetParameter(DataAccess.DataProvider.SQL, "@ExpireDate", DbType.Date, Me.ExpireDate, 8, ParameterDirection.Input)
        Else
            iParmExpireDate = data.GetParameter(DataAccess.DataProvider.SQL, "@ExpireDate", DbType.Date, System.DBNull.Value, 8, ParameterDirection.Input)
        End If
        Dim iParmPublishDate As IDbDataParameter = data.GetParameter(DataAccess.DataProvider.SQL, "@PublishDate", DbType.Date, Me.PublishDate, 8, ParameterDirection.Input)
        Dim iParmLogoPath As IDbDataParameter = data.GetParameter(DataAccess.DataProvider.SQL, "@LogoImagePath", DbType.String, Me.LogoImage.ImagePath, 500, ParameterDirection.Input)
        Dim iParmLogoAlt As IDbDataParameter = data.GetParameter(DataAccess.DataProvider.SQL, "@LogoAltText", DbType.String, Me.LogoImage.AltText.ToString, 200, ParameterDirection.Input)
        Dim iParmLogoHeight As IDbDataParameter = data.GetParameter(DataAccess.DataProvider.SQL, "@LogoHeight", DbType.Int32, Me.LogoImage.Height, 4, ParameterDirection.Input)
        Dim iParmLogoWidth As IDbDataParameter = data.GetParameter(DataAccess.DataProvider.SQL, "@LogoWidth", DbType.Int32, Me.LogoImage.Width, 4, ParameterDirection.Input)

        '' create cmd and add parms
        iCmd = data.GetCommand(strStoredProc, CommandType.StoredProcedure, DataAccess.DataProvider.SQL)
        With iCmd.Parameters
            .Add(iParmID)
            .Add(iParmLogoID)
            If iParmExistingLogoID IsNot Nothing Then
                .Add(iParmExistingLogoID)
            End If
            .Add(iParmName)
            .Add(iParmJobID)
            .Add(iParmUserID)
            .Add(iParmDocAuth)
            .Add(iParmExpireDate)
            .Add(iParmPublishDate)
            .Add(iParmLogoPath)
            .Add(iParmLogoAlt)
            .Add(iParmLogoHeight)
            .Add(iParmLogoWidth)
        End With

        dict.Add(dict.Count, iCmd)

        Try
            success = data.ExecuteNonQuery(dict)
            If success Then
                If Me.BusUnitID = 0 Then
                    ' set the bus unit id
                    Me.BusUnitID = iParmID.Value
                End If
            End If

            Return success
        Catch ex As Exception
            Throw New NLTException("Error saving Business Unit.", ex, "BusinessUnit.vb", "Function Save() As Boolean")
        Finally
            If iCmd.Connection.State <> ConnectionState.Closed Then
                iCmd.Connection.Close()
            End If
        End Try



    End Function

    ' a business unit id must passed in due gridview objdatasource delete requirements
    Function Delete() As Boolean
        Dim success As Boolean
        Dim iCmd As IDbCommand
        Dim data As New DataAccess(SiteProfile.GetConnectionString, DataAccess.DataProvider.SQL)
        Dim dict As New System.Collections.Specialized.HybridDictionary

        iCmd = data.GetCommand("sp__DeleteBusinessUnit", CommandType.StoredProcedure, DataAccess.DataProvider.SQL)
        Dim iParmId As IDbDataParameter = data.GetParameter(DataAccess.DataProvider.SQL, "@BusUnitID", DbType.Int32, Me.BusUnitID, 4, ParameterDirection.Input)
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
            Throw New NLTException("Error deleting Business Unit.", ex, "BusinessUnit.vb", "Function Delete() As Boolean")
        Finally
            If iCmd.Connection.State <> ConnectionState.Closed Then
                iCmd.Connection.Close()
            End If
        End Try


    End Function

    Function GetList(ByVal mode As LiveMode) As DataTable
        Try
            Dim data As New DataAccess(SiteProfile.GetConnectionString, DataAccess.DataProvider.SQL)
            Dim iCmd As IDbCommand = data.GetCommand("sp__GetBusinessUnits", CommandType.StoredProcedure, DataAccess.DataProvider.SQL)
            Dim iParmLiveMode As IDbDataParameter = data.GetParameter(DataAccess.DataProvider.SQL, "@LiveMode", DbType.Int32, Convert.ToInt32(mode), 4, ParameterDirection.Input)
            iCmd.Parameters.Add(iParmLiveMode)
            Dim dt As DataTable = data.GetDataTable(iCmd)
            Return dt

        Catch ex As Exception
            Throw New NLTException("Error retrieving Business Units.", ex, "BusinessUnit.vb", "Function GetList() As DataTable")
        End Try

    End Function

    Function GoToEdit(ByVal businessUnitId As Integer) As Boolean
        My.Response.Redirect("~/cms/BusinessUnitEdit.aspx?busid=" & BusinessUnitID.ToString)
    End Function

    Function Fill(ByVal mode As LiveMode) As Boolean

        Try

            Dim data As New DataAccess(SiteProfile.GetConnectionString, DataAccess.DataProvider.SQL)
            Dim strStoredProc As String = ""
            Dim iParmId As IDbDataParameter = Nothing
            Dim iParmLiveMode As IDbDataParameter = Nothing
            Dim iCmd As IDbCommand = Nothing

            If Me.BusUnitID <> 0 Then
                strStoredProc = "sp__GetBusinessUnitByID"
                iParmID = data.GetParameter(DataAccess.DataProvider.SQL, "@BusUnitID", DbType.Int32, Me.BusUnitID, 4, ParameterDirection.Input)
                iParmLiveMode = data.GetParameter(DataAccess.DataProvider.SQL, "@LiveMode", DbType.Int32, Convert.ToInt32(mode), 4, ParameterDirection.Input)
            End If

            iCmd = data.GetCommand(strStoredProc, CommandType.StoredProcedure, DataAccess.DataProvider.SQL)
            With iCmd
                .Parameters.Add(iParmID)
                .Parameters.Add(iParmLiveMode)
            End With

            Dim dt As DataTable = data.GetDataTable(iCmd)

            If dt.Rows.Count > 0 Then
                Dim row As DataRow = dt.Rows(0)

                ' fill properties
                Me.BusUnitID = Convert.ToInt32(row("BusinessUnitID"))
                Me.BusName = row("BusinessUnitName").ToString
                Me.DocAuth = Services.GetNULLableBoolean(row("DocAuthorization"))
                Me.LogoImage.ImageId = Services.GetNULLableInteger(row("LogoImageID"))
                Me.LogoImage.ImagePath = row("ImagePath").ToString
                Me.LogoImage.AltText = row("Alt").ToString
                Me.LogoImage.Height = Services.GetNULLableInteger(row("Height"))
                Me.LogoImage.Width = Services.GetNULLableInteger(row("Width"))
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
            Throw New NLTException("Error retrieving Business Unit.", ex, "BusinessUnit.vb", "Function Fill() As Boolean")
        End Try
    End Function

    ''' <summary>
    ''' This method retrieves the image modules for Petroferm to handle top navigation
    ''' </summary>
    ''' <param name="liveMode"></param>
    ''' <remarks></remarks>
    Public Sub FillPetrofermWithImageModules(ByVal liveMode As WorkflowItem.LiveMode)
        Try
            Dim data As New DataAccess(SiteProfile.GetConnectionString, DataAccess.DataProvider.SQL)
            Dim iCmd As IDbCommand = data.GetCommand("sp__GetNavImagesForPetroferm", CommandType.StoredProcedure, DataAccess.DataProvider.SQL)
            Dim iParmLiveMode As IDbDataParameter = data.GetParameter(DataAccess.DataProvider.SQL, "@LiveMode", DbType.Boolean, LiveMode, 1, ParameterDirection.Input)
            With iCmd.Parameters
                .Add(iParmLiveMode)
            End With

            Dim collPetrofermImages As New ImageModules
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

                            ' added for task #28 - 12/24/06 - kr
                            With .WelcomeImageFile
                                .ImageId = Services.GetNULLableInteger(row("Welcome_ImageId"))
                                .ImagePath = Services.GetNULLableString(row("Welcome_ImagePath"))
                                .AltText = Services.GetNULLableString(row("Welcome_Alt"))
                                .Height = Services.GetNULLableInteger(row("Welcome_Height"))
                                .Width = Services.GetNULLableInteger(row("Welcome_Width"))
                            End With
                            .WelcomeImageID = Services.GetNULLableInteger(row("WelcomeImageID"))
                            .WelcomeTitle = Services.GetNULLableString(row("WelcomeTitle"))
                            .WelcomeLinkPageID = Services.GetNULLableInteger(row("WelcomeLinkPageID"))
                            .WelcomeLinkPageFriendlyURL = Services.GetNULLableString(row("WelcomeLinkUrlFriendlyName"))
                            .WelcomeLinkPageIDList = Services.GetNULLableString(row("WelcomeLinkPageIDList"))
                            .WelcomeLinkTextList = Services.GetNULLableString(row("WelcomeLinkTextList"))

                            With .ImageFile
                                .ImageId = Services.GetNULLableInteger(row("ImageId"))
                                .ImagePath = Services.GetNULLableString(row("ImagePath"))
                                .AltText = Services.GetNULLableString(row("Alt"))
                                .Height = Services.GetNULLableInteger(row("Height"))
                                .Width = Services.GetNULLableInteger(row("Width"))
                            End With
                        End With
                        collPetrofermImages.Add(imgMod)
                End Select
            Next

            Dim topNavList As ArrayList = Nothing
            topNavList = collPetrofermImages.GetSortedModulesBySection(PageModules.PageSection.TopMenuNavigationImage)
            topNavList.Sort(New PageModuleComparer(SortDirection.Ascending))
            Me.TopMenuNavigationRegion = topNavList

            Dim headerImageList As ArrayList = Nothing
            headerImageList = collPetrofermImages.GetSortedModulesBySection(PageModules.PageSection.HeaderMenuImage)
            headerImageList.Sort(New PageModuleComparer(SortDirection.Ascending))
            Me.HeaderImageRegion = headerImageList

            Dim headerSideContentImageList As ArrayList = Nothing
            headerSideContentImageList = collPetrofermImages.GetSortedModulesBySection(PageModules.PageSection.HeaderSideImage)
            headerSideContentImageList.Sort(New PageModuleComparer(SortDirection.Ascending))
            Me.HeaderSideImageRegion = headerSideContentImageList

            Me.ImageModules = collPetrofermImages

        Catch ex As Exception
            Throw New NLTException("Error retrieving Petroferm image modules.", ex, "Business.vb", "Sub FillPetrofermWithImageModules()")
        End Try

    End Sub


    Public Sub FillMarkets(ByVal liveMode As WorkflowItem.LiveMode)
        Dim mktList As New Market
        Dim dv As DataView = mktList.GetListByBU(Me.BusUnitID, Me.LiveModeStatus)
        For Each rowView As DataRowView In dv
            With rowView
                Dim currentMarket As New Market
                With currentMarket
                    .MarketID = Services.GetNULLableInteger(rowView("MarketID"))
                    .LiveModeStatus = LiveMode
                    .MarketName = Services.GetNULLableString(rowView("MarketName"))
                    .Order = Services.GetNULLableInteger(rowView("MarketOrder"))
                    .BusUnitID = Me.BusUnitID
                    .FillMarketWithImageModules(.MarketID, .LiveModeStatus)
                End With
                _collMarkets.Add(currentMarket.Order, currentMarket)
            End With
        Next
        Me.Markets = _collMarkets
    End Sub

    Public Function GetListByJob(ByVal jobId As Integer) As System.Data.DataTable
        Try
            Dim data As New DataAccess(SiteProfile.GetConnectionString, DataAccess.DataProvider.SQL)
            Dim iCmd As IDbCommand = data.GetCommand("sp__GetBusinessUnitsByJobID", CommandType.StoredProcedure, DataAccess.DataProvider.SQL)
            Dim iParmJobId As IDbDataParameter = data.GetParameter(DataAccess.DataProvider.SQL, "@JobID", DbType.Int32, jobID, 4, ParameterDirection.Input)
            iCmd.Parameters.Add(iParmJobID)
            Dim dt As DataTable = data.GetDataTable(iCmd)
            Return dt

        Catch ex As Exception
            Throw New NLTException("Error retrieving Business Units by Job.", ex, "Market.vb", "Function GetListByJob(jobID as Integer) As System.Data.DataTable")
        End Try
    End Function

End Class
