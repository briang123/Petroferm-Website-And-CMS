
Partial Class CmsControlsDocumentEdit
    Inherits System.Web.UI.UserControl
    Private _formMode As CMSFormUtils.FormMode = CMSFormUtils.FormMode.Read ' default to read
    Private _mCurrentDocumentModule As New DocumentModule
    Public Property CurrentDocumentModule() As DocumentModule
        Get
            Return _mCurrentDocumentModule
        End Get
        Set(ByVal value As DocumentModule)
            _mCurrentDocumentModule = value
        End Set
    End Property
    Private Property CurrentDocumentModuleId() As Integer
        Get
            If ViewState("CurrentDocumentModuleID") IsNot Nothing Then
                Return Services.GetNULLableInteger(ViewState("CurrentDocumentModuleID"))
            Else
                Return 0
            End If
        End Get
        Set(ByVal value As Integer)
            ViewState("CurrentDocumentModuleID") = value
        End Set
    End Property
    Private Property CurrentPageModuleRelnId() As Integer
        Get
            If ViewState("CurrentPageModuleRelnID") IsNot Nothing Then
                Return Services.GetNULLableInteger(ViewState("CurrentPageModuleRelnID"))
            Else
                Return 0
            End If
        End Get
        Set(ByVal value As Integer)
            ViewState("CurrentPageModuleRelnID") = value
        End Set
    End Property
    Public Function SetFormValues() As Boolean

        If CurrentDocumentModule IsNot Nothing Then
            With CurrentDocumentModule
                If .DocumentRelnId <> 0 Then
                    Me.CurrentDocumentModuleID = .DocumentRelnId
                    Me.CurrentPageModuleRelnID = .PageModuleRelnId
                    ' content id is set from calling page
                    txtDocLinkText.Text = .LinkText



                    If .PublishDate <> #12:00:00 AM# Then
                        Me.dtePublishDate.SelectedDate = .PublishDate
                    End If
                    If .ExpireDate <> #12:00:00 AM# Then
                        Me.dteExpireDate.SelectedDate = .ExpireDate
                    End If
                Else
                    ' default values
                    Me.dtePublishDate.SelectedDate = Today.Date
                End If


            End With
        End If
    End Function
    ''' <summary>
    ''' Gets all values from the form and sets it to the content module property
    ''' </summary>
    ''' <remarks></remarks>
    Public Sub GetFormValues()
        With CurrentDocumentModule
            .DocumentRelnId = Me.CurrentDocumentModuleID
            .PageModuleRelnId = Me.CurrentPageModuleRelnID
            .ModuleType = "DOCUMENT"
            .ModuleOrder = 1
            .LinkText = Me.txtDocLinkText.Text
            .PublishDate = Me.dtePublishDate.SelectedDate
            .ExpireDate = Me.dteExpireDate.SelectedDate
        End With
    End Sub
    Public Sub SetControlEnabledProperty(ByVal enable As Boolean)

        txtDocLinkText.Enabled = enable
        dtePublishDate.Enabled = enable
        dteExpireDate.Enabled = enable


    End Sub

    ''' <summary>
    ''' This sets the form mode based on mode specified
    ''' </summary>
    ''' <param name="mode"></param>
    ''' <remarks></remarks>
    Public Sub SetFormMode(ByVal mode As CMSFormUtils.FormMode)
        Select Case mode
            Case CMSFormUtils.FormMode.Edit
                Me.lblFormLabel.Text = "Add/Edit Document Module"
                SetControlEnabledProperty(True)
            Case CMSFormUtils.FormMode.Read
                Me.lblFormLabel.Text = "View Document Module"
                SetControlEnabledProperty(False)
        End Select
    End Sub
    Public Sub ResetForm()
        ' now clear out the form
        Me.tblUploadNewDoc.Visible = False
        Me.ddlExistingDoc.Visible = False

        txtDocLinkText.Text = String.Empty
        dtePublishDate.SelectedDate = #12:00:00 AM#
        dteExpireDate.SelectedDate = #12:00:00 AM#

        Me.CurrentDocumentModule = Nothing
        Me.CurrentPageModuleRelnID = 0
        Me.CurrentDocumentModuleID = 0
    End Sub

    Protected Sub Page_Load(ByVal sender As Object, ByVal e As System.EventArgs) Handles Me.Load
    End Sub
    Protected Sub ddlDocContentType_PreRender(ByVal sender As Object, ByVal e As System.EventArgs) Handles ddlDocContentType.PreRender
        ' add initial empty "select" doc type item
        ' if it's not there already
        With ddlDocContentType
            If .Items.Count > 0 Then
                If .Items(0).Value <> "" Then
                    Dim li As New ListItem("-- Select Content Type --", "")
                    .Items.Insert(0, li)
                End If
            End If
        End With
    End Sub
    Protected Sub ddlDocRegion_PreRender(ByVal sender As Object, ByVal e As System.EventArgs) Handles ddlDocRegion.PreRender
        ' add initial empty "select" item
        ' if it's not there already
        With ddlDocRegion
            If .Items.Count > 0 Then
                If .Items(0).Value <> "0" Then
                    Dim li As New ListItem("-- Select Region --", "0")
                    .Items.Insert(0, li)
                End If
            End If
        End With
    End Sub


    Protected Sub rdoExistingDoc_CheckedChanged(ByVal sender As Object, ByVal e As System.EventArgs) Handles rdoExistingDoc.CheckedChanged
        SetDocumentSelection()

    End Sub
    Sub SetDocumentSelection()
        Select Case True
            Case Me.rdoExistingDoc.Checked
                Me.tblUploadNewDoc.Visible = False
                Me.ddlExistingDoc.Visible = True
            Case Me.rdoUploadNewDoc.Checked
                Me.tblUploadNewDoc.Visible = True
                Me.ddlExistingDoc.Visible = False
        End Select
    End Sub

    Protected Sub rdoUploadNewDoc_CheckedChanged(ByVal sender As Object, ByVal e As System.EventArgs) Handles rdoUploadNewDoc.CheckedChanged
        SetDocumentSelection()
    End Sub

    Protected Sub ddlExistingDoc_PreRender(ByVal sender As Object, ByVal e As System.EventArgs) Handles ddlExistingDoc.PreRender
        ' add initial empty "select" doc type item
        ' if it's not there already
        With ddlExistingDoc
            If .Items.Count > 0 Then
                If .Items(0).Value <> "" Then
                    Dim li As New ListItem("-- Select Existing Document --", "")
                    .Items.Insert(0, li)
                End If
            End If
        End With
    End Sub
End Class
