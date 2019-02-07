Imports Microsoft.VisualBasic

Public Class ImageModule
    Inherits PageModule
    Implements IImageModule

    Private _mImageModuleId As Integer
    Private _mImageType As String
    Private _mImageOrder As Integer
    Private _mImageFile As New ImageFile
    Private _mImageId As Integer
    Private _mLiveMode As WorkflowItem.LiveMode
    ' for the new properties to handle petroferm bu top nav 
    ' task #28 - 12/24/06 - kr
    Private _mIsPetrofermHomePage As Boolean
    Private _mWelcomeImageFile As New ImageFile
    Private _mWelcomeImageId As Integer
    Private _mWelcomeTitle As String = ""
    Private _mWelcomeLinkPageId As Integer
    Private _mWelcomeLinkPageFriendlyUrl As String = ""
    Private _mWelcomeLinkTextList As String = ""
    Private _mWelcomeLinkPageIdList As String = ""


    Sub New()
    End Sub

    Sub New(ByVal imageModuleId As Integer, ByVal liveMode As WorkflowItem.LiveMode)
        _mImageModuleId = ImageModuleID
        _mLiveMode = LiveMode
        Me.Fill()
    End Sub

    Public Property ImageId() As Integer Implements IImageModule.ImageId
        Get
            Return _mImageId
        End Get
        Set(ByVal value As Integer)
            _mImageId = value
        End Set
    End Property

    Public Property ImageModuleId() As Integer Implements IImageModule.ImageModuleId
        Get
            Return _mImageModuleId
        End Get
        Set(ByVal value As Integer)
            _mImageModuleId = value
        End Set
    End Property

    Public Property ImageType() As String Implements IImageModule.ImageType
        Get
            Return _mImageType
        End Get
        Set(ByVal value As String)

            '12/23/06 - kr - task #2
            ' to fix the inconsistency of module type vs. image type, just convert to the proper type
            Select Case value.ToUpper
                Case "NAV ON IMAGE"
                    value = "NAVIGATION ON"
                Case "NAV OFF IMAGE"
                    value = "NAVIGATION OFF"
                Case "HEADER SIDE CONTENT IMAGE"


            End Select
            _mImageType = value
        End Set
    End Property

    Public Property ImageOrder() As Integer Implements IImageModule.ImageOrder
        Get
            Return _mImageOrder
        End Get
        Set(ByVal value As Integer)
            _mImageOrder = value
        End Set
    End Property

    Public Property ImageFile() As ImageFile Implements IImageModule.ImageFile
        Get
            Return _mImageFile
        End Get
        Set(ByVal value As ImageFile)
            _mImageFile = value
        End Set
    End Property

    Public Property IsPetrofermHomePage() As Boolean
        Get
            Return _mIsPetrofermHomePage
        End Get
        Set(ByVal value As Boolean)
            _mIsPetrofermHomePage = False
        End Set
    End Property

    Public Property WelcomeImageFile() As ImageFile
        Get
            Return _mWelcomeImageFile
        End Get
        Set(ByVal value As ImageFile)
            _mWelcomeImageFile = value
        End Set
    End Property

    Public Property WelcomeImageId() As Integer
        Get
            Return _mWelcomeImageId
        End Get
        Set(ByVal value As Integer)
            _mWelcomeImageId = value
        End Set
    End Property

    Public Property WelcomeTitle() As String
        Get
            Return _mWelcomeTitle
        End Get
        Set(ByVal value As String)
            _mWelcomeTitle = value
        End Set
    End Property

    Public Property WelcomeLinkPageId() As Integer
        Get
            Return _mWelcomeLinkPageId
        End Get
        Set(ByVal value As Integer)
            _mWelcomeLinkPageId = value
        End Set
    End Property

    Public Property WelcomeLinkPageFriendlyUrl() As String
        Get
            Return _mWelcomeLinkPageFriendlyUrl
        End Get
        Set(ByVal value As String)
            _mWelcomeLinkPageFriendlyUrl = value
        End Set
    End Property

    Public Property WelcomeLinkTextList() As String
        Get
            Return _mWelcomeLinkTextList
        End Get
        Set(ByVal value As String)
            _mWelcomeLinkTextList = value
        End Set
    End Property

    Public Property WelcomeLinkPageIdList() As String
        Get
            Return _mWelcomeLinkPageIdList
        End Get
        Set(ByVal value As String)
            _mWelcomeLinkPageIdList = value
        End Set
    End Property

    Public Function Delete() As Boolean Implements IImageModule.Delete
        Dim success As Boolean
        Dim iCmd As IDbCommand
        Dim data As New DataAccess(SiteProfile.GetConnectionString, DataAccess.DataProvider.SQL)
        Dim dict As New System.Collections.Specialized.HybridDictionary

        'proc(sp__DeleteContentModule)
        iCmd = data.GetCommand("sp__DeleteImageModule", CommandType.StoredProcedure, DataAccess.DataProvider.SQL)
        '@ImageModuleID int = null,
        Dim iParmImageModuleId As IDbDataParameter = data.GetParameter(DataAccess.DataProvider.SQL, "@ImageModuleID", DbType.Int32, Me.ImageModuleId, 4, ParameterDirection.Input)
        '@UserID int = null,
        Dim iParmUserId As IDbDataParameter = data.GetParameter(DataAccess.DataProvider.SQL, "@UserID", DbType.Int32, Me.LastModBy, 4, ParameterDirection.Input)
        '@JobID int = null,
        Dim iParmJobId As IDbDataParameter = data.GetParameter(DataAccess.DataProvider.SQL, "@JobID", DbType.Int32, Me.JobID, 4, ParameterDirection.Input)
        '@WorkflowStatus varchar(50) = 'WORKING'
        ' no parm -- use default value

        With iCmd.Parameters
            .Add(iParmImageModuleID)
            .Add(iParmJobID)
            .Add(iParmUserID)
        End With

        dict.Add(dict.Count, iCmd)

        Try
            success = data.ExecuteNonQuery(dict)
            Return success
        Catch ex As Exception
            Throw New NLTException("Error deleting Image Module.", ex, "ImageModule.vb", "Function Delete() As Boolean")

        End Try
    End Function

    Public Sub Fill() Implements IImageModule.Fill

        Dim data As New DataAccess(SiteProfile.GetConnectionString, DataAccess.DataProvider.SQL)
        Dim iCmd As IDbCommand = data.GetCommand("sp__GetImageModuleByModId", CommandType.StoredProcedure, DataAccess.DataProvider.SQL)
        Dim iParmId As IDbDataParameter = data.GetParameter(DataAccess.DataProvider.SQL, "@ModId", DbType.Int32, Me.ImageModuleId, 4, ParameterDirection.Input)
        Dim iParmLiveMode As IDbDataParameter = data.GetParameter(DataAccess.DataProvider.SQL, "@LiveMode", DbType.Boolean, _mLiveMode, 1, ParameterDirection.Input)
        With iCmd
            .Parameters.Add(iParmID)
            .Parameters.Add(iParmLiveMode)
        End With

        Dim dt As DataTable = data.GetDataTable(iCmd)

        For Each row As DataRow In dt.Rows
            With Me
                .ImageId = Services.GetNULLableInteger(row("IM_ImageID"))
                .ImageType = Services.GetNULLableString(row("IM_ImageType"))
                .ImageOrder = Services.GetNULLableInteger(row("IM_Order"))
                .PublishDate = Services.GetNULLableDateTime(row("IM_PublishDate"))
                .ExpireDate = Services.GetNULLableDateTime(row("IM_ExpirationDate"))
                .WorkflowStatus = Services.GetNULLableString(row("IM_WorkflowStatus"))
                .LastModDate = Services.GetNULLableDateTime(row("IM_LastModDate"))
                .LastModBy = Services.GetNULLableInteger(row("IM_LastModBy"))
                .ActiveFlag = Services.GetNULLableBoolean(row("IM_ActiveFlag"))
                .MarkedForDelete = Services.GetNULLableBoolean(row("IM_MarkedForDeletion"))
                .MarkedForDeleteFmt = Services.GetNULLableString(row("IM_FmtMarkedForDeletion"))
                .JobID = Services.GetNULLableInteger(row("IM_JobId"))
                .JobDescription = Services.GetNULLableString(row("IM_JobDescription"))
                .LastModByName = Services.GetNULLableString(row("IM_LastModByName"))
                With .ImageFile
                    .ImageId = Services.GetNULLableInteger(row("IM_ImageID"))
                    .ImagePath = Services.GetNULLableString(row("I_Path"))
                    .AltText = Services.GetNULLableString(row("I_Alt"))
                    .Width = Services.GetNULLableInteger(row("I_Width"))
                    .Height = Services.GetNULLableInteger(row("I_Height"))
                    .PublishDate = Services.GetNULLableDateTime(row("I_PublishDate"))
                    .ExpireDate = Services.GetNULLableDateTime(row("I_ExpirationDate"))
                    .WorkflowStatus = Services.GetNULLableString(row("I_WorkflowStatus"))
                    .LastModDate = Services.GetNULLableDateTime(row("I_LastModDate"))
                    .LastModBy = Services.GetNULLableInteger(row("I_LastModBy"))
                    .ActiveFlag = Services.GetNULLableBoolean(row("I_ActiveFlag"))
                    .MarkedForDelete = Services.GetNULLableBoolean(row("I_MarkedForDeletion"))
                    .MarkedForDeleteFmt = Services.GetNULLableString(row("I_FmtMarkedForDeletion"))
                    .JobID = Services.GetNULLableInteger(row("I_JobId"))
                    .JobDescription = Services.GetNULLableString(row("I_JobDescription"))
                    .LastModByName = Services.GetNULLableString(row("I_LastModByName"))
                End With







                ' added for CMS
                If _mLiveMode = LiveMode.CMS Then
                    .PageModuleRelnId = Services.GetNULLableInteger(row("PageModuleRelnID"))
                    .ModuleOrder = Services.GetNULLableInteger(row("ModuleOrder"))
                    .ShowTitle = Services.GetNULLableBoolean(row("ShowTitle"))

                    ' added for task #56 - 12/31/2006 - kr
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
                    ' don't need this for this context
                    '.WelcomeLinkPageFriendlyURL = Services.GetNULLableString(row("WelcomeLinkUrlFriendlyName"))
                    .WelcomeLinkPageIDList = Services.GetNULLableString(row("WelcomeLinkPageIDList"))
                    .WelcomeLinkTextList = Services.GetNULLableString(row("WelcomeLinkTextList"))

                End If

            End With
        Next

    End Sub

    Public Function Save() As Boolean Implements IImageModule.Save

        Dim success As Boolean
        Dim iCmd As IDbCommand
        Dim iParmImageModuleId As IDbDataParameter
        Dim iParmPageModuleRelnId As IDbDataParameter = Nothing
        Dim iParmPageId As IDbDataParameter = Nothing
        Dim iParmModuleType As IDbDataParameter = Nothing

        Dim data As New DataAccess(SiteProfile.GetConnectionString, DataAccess.DataProvider.SQL)
        Dim dict As New System.Collections.Specialized.HybridDictionary
        Dim strStoredProc As String

        ' determine whether item should be added or updated
        If Me.ImageModuleId = 0 Then
            strStoredProc = "sp__AddImageModule"
            '@PageID int = null,
            iParmPageID = data.GetParameter(DataAccess.DataProvider.SQL, "@PageID", DbType.Int32, Me.PageId, 4, ParameterDirection.Input)
            iParmImageModuleID = data.GetParameter(DataAccess.DataProvider.SQL, "@ImageModuleID", DbType.Int32, System.DBNull.Value, 4, ParameterDirection.Output)
            iParmPageModuleRelnID = data.GetParameter(DataAccess.DataProvider.SQL, "@PageModuleRelnID", DbType.Int32, System.DBNull.Value, 4, ParameterDirection.Output)
            '@ModuleType varchar(50) = null
            iParmModuleType = data.GetParameter(DataAccess.DataProvider.SQL, "@ModuleType", DbType.String, Me.ModuleType, 50, ParameterDirection.Input)
        Else
            strStoredProc = "sp__UpdateImageModule"
            iParmPageID = data.GetParameter(DataAccess.DataProvider.SQL, "@PageID", DbType.Int32, Me.PageId, 4, ParameterDirection.Input)
            iParmImageModuleID = data.GetParameter(DataAccess.DataProvider.SQL, "@ImageModuleID", DbType.Int32, Me.ImageModuleId, 4, ParameterDirection.Input)
            iParmModuleType = data.GetParameter(DataAccess.DataProvider.SQL, "@ModuleType", DbType.String, Me.ModuleType, 50, ParameterDirection.Input)
        End If

        '@ImageID int = 0, -- may be adding image rec, will get this later
        Dim iParmImageId As IDbDataParameter = data.GetParameter(DataAccess.DataProvider.SQL, "@ImageID", DbType.Int32, Me.ImageFile.ImageId, 4, ParameterDirection.Input)
        '@ImageType varchar(25) = null,
        Dim iParmImageType As IDbDataParameter = data.GetParameter(DataAccess.DataProvider.SQL, "@ImageType", DbType.String, Me.ImageType, 25, ParameterDirection.Input)
        '@ImageOrder int = null,
        Dim iParmImageOrder As IDbDataParameter = data.GetParameter(DataAccess.DataProvider.SQL, "@ImageOrder", DbType.Int32, Me.ImageOrder, 4, ParameterDirection.Input)
        '@ImagePath varchar(500) = null,
        Dim iParmImagePath As IDbDataParameter = data.GetParameter(DataAccess.DataProvider.SQL, "@ImagePath", DbType.String, Me.ImageFile.ImagePath, 500, ParameterDirection.Input)
        '@Alt varchar(200) = null, 
        Dim iParmAlt As IDbDataParameter = data.GetParameter(DataAccess.DataProvider.SQL, "@Alt", DbType.String, Me.ImageFile.AltText, 200, ParameterDirection.Input)
        '@Height int = 1, 
        Dim iParmHeight As IDbDataParameter = data.GetParameter(DataAccess.DataProvider.SQL, "@Height", DbType.Int32, Me.ImageFile.Height, 4, ParameterDirection.Input)
        '@Width int = 1, 
        Dim iParmWidth As IDbDataParameter = data.GetParameter(DataAccess.DataProvider.SQL, "@Width", DbType.Int32, Me.ImageFile.Width, 4, ParameterDirection.Input)

        '@ModuleOrder int = null,
        Dim iParmModuleOrder As IDbDataParameter = data.GetParameter(DataAccess.DataProvider.SQL, "@ModuleOrder", DbType.Int32, Me.ModuleOrder, 4, ParameterDirection.Input)
        '@ShowTitle bit = 0,
        Dim iParmShowTitle As IDbDataParameter = data.GetParameter(DataAccess.DataProvider.SQL, "@ShowTitle", DbType.Boolean, Me.ShowTitle, 1, ParameterDirection.Input)

        ' need to add stuff for petroferm home page mgmt (welcome properties)
        ' added 12/31/2006 - kr - task #56
        '@SavePetrofermHomePageInfo bit = 0, -- used to determine whether to save welcome stuff
        Dim iParmSavePetrofermHomePageInfo As IDbDataParameter = data.GetParameter(DataAccess.DataProvider.SQL, "@SavePetrofermHomePageInfo", DbType.Boolean, Me.IsPetrofermHomePage, 1, ParameterDirection.Input)
        '@WelcomeImageID int = null, -- may be adding image rec, will get this later
        Dim iParmWelcomeImageId As IDbDataParameter = data.GetParameter(DataAccess.DataProvider.SQL, "@WelcomeImageID", DbType.Int32, Me.WelcomeImageID, 4, ParameterDirection.Input)
        '@WelcomeImagePath varchar(500) = null,
        Dim iParmWelcomeImagePath As IDbDataParameter = data.GetParameter(DataAccess.DataProvider.SQL, "@WelcomeImagePath", DbType.String, Me.WelcomeImageFile.ImagePath, 500, ParameterDirection.Input)
        '@WelcomeTitle varchar(50) = null,
        Dim iParmWelcomeTitle As IDbDataParameter = data.GetParameter(DataAccess.DataProvider.SQL, "@WelcomeTitle", DbType.String, Me.WelcomeTitle, 50, ParameterDirection.Input)
        '@WelcomeLinkPageID int = null,
        Dim iParmWelcomeLinkPageId As IDbDataParameter = data.GetParameter(DataAccess.DataProvider.SQL, "@WelcomeLinkPageID", DbType.Int32, Me.WelcomeLinkPageID, 4, ParameterDirection.Input)
        '@WelcomeLinkPageIDList varchar(25) = null,
        Dim iParmWelcomeLinkPageIdList As IDbDataParameter = data.GetParameter(DataAccess.DataProvider.SQL, "@WelcomeLinkPageIDList", DbType.String, Me.WelcomeLinkPageIDList, 25, ParameterDirection.Input)
        '@WelcomeLinkTextList varchar(200) = null,
        Dim iParmWelcomeLinkTextList As IDbDataParameter = data.GetParameter(DataAccess.DataProvider.SQL, "@WelcomeLinkTextList", DbType.String, Me.WelcomeLinkTextList, 200, ParameterDirection.Input)

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
            .Add(iParmImageModuleID)
            If iParmPageID IsNot Nothing Then
                .Add(iParmPageID)
            End If
            If iParmPageModuleRelnID IsNot Nothing Then
                .Add(iParmPageModuleRelnID)
            End If
            If iParmModuleType IsNot Nothing Then
                .Add(iParmModuleType)
            End If
            .Add(iParmImageID)
            .Add(iParmImageType)
            .Add(iParmImageOrder)
            .Add(iParmImagePath)
            .Add(iParmAlt)
            .Add(iParmHeight)
            .Add(iParmWidth)
            .Add(iParmModuleOrder)
            .Add(iParmShowTitle)
            .Add(iParmSavePetrofermHomePageInfo)
            .Add(iParmWelcomeImageID)
            .Add(iParmWelcomeImagePath)
            .Add(iParmWelcomeTitle)
            If Convert.ToInt32(iParmWelcomeLinkPageID.Value) <> 0 Then
                .Add(iParmWelcomeLinkPageID)
            End If
            .Add(iParmWelcomeLinkPageIDList)
            .Add(iParmWelcomeLinkTextList)
            .Add(iParmPublishDate)
            .Add(iParmExpireDate)
            .Add(iParmJobID)
            .Add(iParmUserID)
        End With

        dict.Add(dict.Count, iCmd)

        Try
            success = data.ExecuteNonQuery(dict)
            If success Then
                If Me.ImageModuleId = 0 And iParmImageModuleID.Value IsNot System.DBNull.Value Then
                    ' set the id
                    Me.ImageModuleId = iParmImageModuleID.Value
                End If
            End If

            Return success
        Catch ex As Exception
            Throw New NLTException("Error saving Image Module.", ex, "ImageModule.vb", "Function Save() As Boolean")
        End Try

    End Function

End Class
