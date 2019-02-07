Imports Microsoft.VisualBasic

Public Class ImageFile
    Inherits WorkflowItem

    Private _mImageId As Integer
    Private _mImagePath As String = ""
    Private _mAltText As String = ""
    Private _mHeight As Integer = 0
    Private _mWidth As Integer = 0
    Private _mLiveMode As Boolean

    Public Sub New()
    End Sub

    Public Sub New(ByVal imageId As Integer)
        _mImageId = ImageId
    End Sub

    Public Property ImageId() As Integer
        Get
            Return _mImageId
        End Get
        Set(ByVal value As Integer)
            _mImageId = value
        End Set
    End Property

    Public Property ImagePath() As String
        Get
            Return _mImagePath
        End Get
        Set(ByVal value As String)
            ' take out the ~/ (just in case)
            If value.Length > 0 Then
                If value.Substring(0, 2) = "~/" Then
                    _mImagePath = value.Replace("~/", "")
                ElseIf value.Substring(0, 1) = "/" Then
                    _mImagePath = value.Substring(1)
                Else
                    _mImagePath = value
                End If
            Else
                _mImagePath = value
            End If

        End Set
    End Property

    Public Property AltText() As String
        Get
            Return _mAltText
        End Get
        Set(ByVal value As String)
            _mAltText = value
        End Set
    End Property

    Public Property Height() As Integer
        Get
            Return _mHeight
        End Get
        Set(ByVal value As Integer)
            _mHeight = value
        End Set
    End Property

    Public Property Width() As Integer
        Get
            Return _mWidth
        End Get
        Set(ByVal value As Integer)
            _mWidth = value
        End Set
    End Property


    Sub Fill()

    End Sub

    Function Save() As Boolean
        Dim success As Boolean
        Dim iCmd As IDbCommand = Nothing
        Dim iParmId As IDbDataParameter

        Dim data As New DataAccess(SiteProfile.GetConnectionString, DataAccess.DataProvider.SQL)
        Dim dict As New System.Collections.Specialized.HybridDictionary
        Dim strStoredProc As String

        '       PROC(sp__CreateBusinessUnit)
        '@UserID int = null,
        '@JobID int = null,
        '@BusName varchar(300) = null,
        '@IsPetro bit = 0,
        '@BusUnitID int OUTPUT

        ' determine whether item should be added or updated
        If Me.ImageId = 0 Then
            strStoredProc = "sp__AddImage"
            iParmID = data.GetParameter(DataAccess.DataProvider.SQL, "@BusUnitID", DbType.Int32, Me.ImageId, 4, ParameterDirection.Output)
        Else
            strStoredProc = "sp__UpdateImage"
            iParmID = data.GetParameter(DataAccess.DataProvider.SQL, "@BusUnitID", DbType.Int32, Me.ImageId, 4, ParameterDirection.Input)
        End If

        Dim iParmPath As IDbDataParameter = data.GetParameter(DataAccess.DataProvider.SQL, "@ImagePath", DbType.String, Me.ImagePath, 500, ParameterDirection.Input)
        'Dim iParmDesc As IDbDataParameter = data.GetParameter(DataAccess.DataProvider.SQL, "@CategoryDesc", DbType.String, Me.CategoryDesc, 1000, ParameterDirection.Input)
        'Dim iParmParentID As IDbDataParameter = data.GetParameter(DataAccess.DataProvider.SQL, "@ParentCategoryID", DbType.Int32, Me.ParentCategoryID, 4, ParameterDirection.Input)
        'Dim iParmFlag As IDbDataParameter = data.GetParameter(DataAccess.DataProvider.SQL, "@ActiveFlag", DbType.Int32, Me.ActiveFlag, 1, ParameterDirection.Input)

        '' create cmd and add parms
        'iCmd = data.GetCommand(strStoredProc, CommandType.StoredProcedure, DataAccess.DataProvider.SQL)
        'With iCmd.Parameters
        '    .Add(iParmID)
        '    .Add(iParmName)
        '    .Add(iParmDesc)
        '    .Add(iParmParentID)
        '    .Add(iParmFlag)
        'End With

        ' dict.Add(dict.Count, iCmd)

        Try
            success = data.ExecuteNonQuery(dict)
            Return success
        Catch ex As Exception
            Throw New NLTException("Error saving Image.", ex, "Image.vb", "Function Save() As Boolean")
        Finally
            If iCmd.Connection.State <> ConnectionState.Closed Then
                iCmd.Connection.Close()
            End If
        End Try
    End Function

    Function GetList() As DataTable
        Try
            Dim data As New DataAccess(SiteProfile.GetConnectionString, DataAccess.DataProvider.SQL)
            Dim iCmd As IDbCommand = data.GetCommand("sp__GetImages", CommandType.StoredProcedure, DataAccess.DataProvider.SQL)
            Dim dt As DataTable = data.GetDataTable(iCmd)
            Return dt

        Catch ex As Exception
            Throw New NLTException("Error retrieving Images.", ex, "ImageFile.vb", "Function GetList() As DataTable")
        End Try
    End Function
End Class
