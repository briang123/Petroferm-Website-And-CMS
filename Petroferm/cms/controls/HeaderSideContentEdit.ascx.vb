
Partial Class CmsControlsHeaderSideContentEdit
    Inherits System.Web.UI.UserControl
    Private _formMode As CMSFormUtils.FormMode = CMSFormUtils.FormMode.Read ' default to read
    Private _mCurrentHeaderSideContentModule As New HeaderSideContentModule
    Public Property CurrentHeaderSideContentModule() As HeaderSideContentModule
        Get
            Return _mCurrentHeaderSideContentModule
        End Get
        Set(ByVal value As HeaderSideContentModule)
            _mCurrentHeaderSideContentModule = value
        End Set
    End Property
    Private Property CurrentHeaderSideContentModuleId() As Integer
        Get
            If ViewState("CurrentHeaderSideContentModuleID") IsNot Nothing Then
                Return Services.GetNULLableInteger(ViewState("CurrentHeaderSideContentModuleID"))
            Else
                Return 0
            End If
        End Get
        Set(ByVal value As Integer)
            ViewState("CurrentHeaderSideContentModuleID") = value
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

        If CurrentHeaderSideContentModule IsNot Nothing Then
            With CurrentHeaderSideContentModule
                If .HeaderSideContentModuleId <> 0 Then
                    Me.CurrentHeaderSideContentModuleID = .HeaderSideContentModuleId
                    Me.CurrentPageModuleRelnID = .PageModuleRelnId
                    ' content id is set from calling page
                    txtTitle.Text = .Title
                    txtLineText1.Text = .LineText1
                    If .InternalLink1Type.Length > 0 Then
                        Me.rdoLinkType1.SelectedValue = "Internal Link"
                        Me.ddlInternalLinkType1.SelectedValue = .InternalLink1Type
                        ' now bind the internal link list, based on the link type
                        Select Case .InternalLink1Type.ToUpper
                            Case "PAGE"
                                With ddlInternalLink1
                                    .DataSource = Me.InternalLinkPageDS
                                    .DataTextField = "PageTitleDisplay"
                                    .DataValueField = "PageID"
                                    .DataBind()
                                End With
                            Case "DOCUMENT"
                                With ddlInternalLink1
                                    .DataSource = Me.InternalLinkDocDS
                                    .DataTextField = "DocTitle"
                                    .DataValueField = "DocumentID"
                                    .DataBind()
                                End With
                        End Select
                        If Me.ddlInternalLink1.Items.FindByValue(.InternalLink1) IsNot Nothing Then
                            Me.ddlInternalLink1.SelectedValue = .InternalLink1
                        End If
                    Else
                        Me.rdoLinkType1.SelectedValue = "External Link"
                        Me.txtExternalLinkURL1.Text = .ExternalLink1
                    End If
                    txtLineText2.Text = .LineText2
                    If .InternalLink2Type.Length > 0 Then
                        Me.rdoLinkType2.SelectedValue = "Internal Link"
                        Me.ddlInternalLinkType2.SelectedValue = .InternalLink2Type
                        ' now bind the internal link list, based on the link type
                        Select Case .InternalLink2Type.ToUpper
                            Case "PAGE"
                                With ddlInternalLink2
                                    .DataSource = Me.InternalLinkPageDS
                                    .DataTextField = "PageTitleDisplay"
                                    .DataValueField = "PageID"
                                    .DataBind()
                                End With
                            Case "DOCUMENT"
                                With ddlInternalLink2
                                    .DataSource = Me.InternalLinkDocDS
                                    .DataTextField = "DocTitle"
                                    .DataValueField = "DocumentID"
                                    .DataBind()
                                End With
                        End Select
                        If Me.ddlInternalLink2.Items.FindByValue(.InternalLink2) IsNot Nothing Then
                            Me.ddlInternalLink2.SelectedValue = .InternalLink2
                        End If
                    Else
                        Me.rdoLinkType2.SelectedValue = "External Link"
                        Me.txtExternalLinkURL2.Text = .ExternalLink2
                    End If


                    SetInternalExternalLinkDisplay()

                    If .PublishDate <> #12:00:00 AM# Then
                        Me.dtePublishDate.SelectedDate = .PublishDate
                    End If
                    If .ExpireDate <> #12:00:00 AM# Then
                        Me.dteExpireDate.SelectedDate = .ExpireDate
                    End If
                Else
                    ' default values
                    Me.dtePublishDate.SelectedDate = Today.Date
                    Me.dteExpireDate.SelectedDate = Today.Date.AddYears(30)
                    Me.txtExternalLinkURL1.Text = "http://"
                    Me.txtExternalLinkURL2.Text = "http://"
                End If


            End With
        End If
    End Function
    ''' <summary>
    ''' Gets all values from the form and sets it to the content module property
    ''' </summary>
    ''' <remarks></remarks>
    Public Sub GetFormValues()
        With CurrentHeaderSideContentModule
            .HeaderSideContentModuleId = Me.CurrentHeaderSideContentModuleID
            .PageModuleRelnId = Me.CurrentPageModuleRelnID
            .ModuleType = "HEADER SIDE CONTENT"
            ' fixed value for module order
            .ModuleOrder = 1
            .Title = Me.txtTitle.Text
            .PublishDate = Me.dtePublishDate.SelectedDate
            .ExpireDate = Me.dteExpireDate.SelectedDate
            .LineText1 = Me.txtLineText1.Text.Trim
            ' find out whether to get internal or external info
            Select Case Me.rdoLinkType1.SelectedValue
                Case "Internal Link"
                    .InternalLink1Type = Me.ddlInternalLinkType1.SelectedValue
                    .InternalLink1 = Me.ddlInternalLink1.SelectedValue
                Case "External Link"
                    .ExternalLink1 = Me.txtExternalLinkURL1.Text.Trim
            End Select
            .LineText2 = Me.txtLineText2.Text.Trim
            Select Case Me.rdoLinkType2.SelectedValue
                Case "Internal Link"
                    .InternalLink2Type = Me.ddlInternalLinkType2.SelectedValue
                    .InternalLink2 = Me.ddlInternalLink2.SelectedValue
                Case "External Link"
                    .ExternalLink2 = Me.txtExternalLinkURL2.Text.Trim
            End Select
        End With
    End Sub
    Public Sub SetControlEnabledProperty(ByVal enable As Boolean)

        txtTitle.Enabled = enable
        dtePublishDate.Enabled = enable
        dteExpireDate.Enabled = enable

        rdoLinkType1.Enabled = enable
        txtLineText1.Enabled = enable
        ddlInternalLinkType1.Enabled = enable
        ddlInternalLink1.Enabled = enable
        txtExternalLinkURL1.Enabled = enable

        rdoLinkType2.Enabled = enable
        txtLineText2.Enabled = enable
        ddlInternalLinkType2.Enabled = enable
        ddlInternalLink2.Enabled = enable
        txtExternalLinkURL2.Enabled = enable

    End Sub

    ''' <summary>
    ''' This sets the form mode based on mode specified
    ''' </summary>
    ''' <param name="mode"></param>
    ''' <remarks></remarks>
    Public Sub SetFormMode(ByVal mode As CMSFormUtils.FormMode)
        Select Case mode
            Case CMSFormUtils.FormMode.Edit
                Me.lblFormLabel.Text = "Add/Edit Header Side Content Module"
                SetControlEnabledProperty(True)
            Case CMSFormUtils.FormMode.Read
                Me.lblFormLabel.Text = "View Header Side Content Module"
                SetControlEnabledProperty(False)
        End Select
    End Sub
    Public Sub ResetForm()
        ' now clear out the form
        rdoLinkType1.ClearSelection()
        txtLineText1.Text = String.Empty
        ddlInternalLinkType1.ClearSelection()
        ddlInternalLink1.ClearSelection()
        ddlInternalLink1.Items.Clear()
        txtExternalLinkURL1.Text = String.Empty

        rdoLinkType2.ClearSelection()
        txtLineText2.Text = String.Empty
        ddlInternalLinkType2.ClearSelection()
        ddlInternalLink2.ClearSelection()
        ddlInternalLink2.Items.Clear()
        txtExternalLinkURL2.Text = String.Empty

        txtTitle.Text = String.Empty
        dtePublishDate.SelectedDate = #12:00:00 AM#
        dteExpireDate.SelectedDate = #12:00:00 AM#

        Me.CurrentHeaderSideContentModule = Nothing
        Me.CurrentPageModuleRelnID = 0
        Me.CurrentHeaderSideContentModuleID = 0
    End Sub

    Protected Sub rdoLinkType1_SelectedIndexChanged(ByVal sender As Object, ByVal e As System.EventArgs) Handles rdoLinkType1.SelectedIndexChanged
        SetInternalExternalLinkDisplay()
    End Sub
    Protected Sub rdoLinkType2_SelectedIndexChanged(ByVal sender As Object, ByVal e As System.EventArgs) Handles rdoLinkType2.SelectedIndexChanged
        SetInternalExternalLinkDisplay()
    End Sub

    Sub SetInternalExternalLinkDisplay()

        Select Case Me.rdoLinkType1.SelectedValue
            Case "Internal Link"
                Me.trInternalLinkForm1a.Visible = True
                Me.trInternalLinkForm1b.Visible = True
                Me.trExternalLinkForm1.Visible = False
            Case "External Link"
                Me.trInternalLinkForm1a.Visible = False
                Me.trInternalLinkForm1b.Visible = False
                Me.trExternalLinkForm1.Visible = True
        End Select

        Select Case Me.rdoLinkType2.SelectedValue
            Case "Internal Link"
                Me.trInternalLinkForm2a.Visible = True
                Me.trInternalLinkForm2b.Visible = True
                Me.trExternalLinkForm2.Visible = False
            Case "External Link"
                Me.trInternalLinkForm2a.Visible = False
                Me.trInternalLinkForm2b.Visible = False
                Me.trExternalLinkForm2.Visible = True
        End Select
    End Sub

    Protected Sub Page_Load(ByVal sender As Object, ByVal e As System.EventArgs) Handles Me.Load
        Me.trInternalLinkForm1a.Visible = False
        Me.trInternalLinkForm1b.Visible = False
        Me.trExternalLinkForm1.Visible = False
        Me.trInternalLinkForm2a.Visible = False
        Me.trInternalLinkForm2b.Visible = False
        Me.trExternalLinkForm2.Visible = False
    End Sub

    Protected Sub ddlInternalLinkType1_SelectedIndexChanged(ByVal sender As Object, ByVal e As System.EventArgs) Handles ddlInternalLinkType1.SelectedIndexChanged
        Select Case ddlInternalLinkType1.SelectedValue.ToUpper
            Case "PAGE"
                With ddlInternalLink1
                    .DataSource = Me.InternalLinkPageDS
                    .DataTextField = "PageTitleDisplay"
                    .DataValueField = "PageID"
                    .DataBind()
                End With
            Case "DOCUMENT"
                With ddlInternalLink1
                    .DataSource = Me.InternalLinkDocDS
                    .DataTextField = "DocTitle"
                    .DataValueField = "DocumentID"
                    .DataBind()
                End With
        End Select
        SetInternalExternalLinkDisplay()
    End Sub

    Protected Sub ddlInternalLinkType2_SelectedIndexChanged(ByVal sender As Object, ByVal e As System.EventArgs) Handles ddlInternalLinkType2.SelectedIndexChanged
        Select Case ddlInternalLinkType2.SelectedValue.ToUpper
            Case "PAGE"
                With ddlInternalLink2
                    .DataSource = Me.InternalLinkPageDS
                    .DataTextField = "PageTitleDisplay"
                    .DataValueField = "PageID"
                    .DataBind()
                End With
            Case "DOCUMENT"
                With ddlInternalLink2
                    .DataSource = Me.InternalLinkDocDS
                    .DataTextField = "DocTitle"
                    .DataValueField = "DocumentID"
                    .DataBind()
                End With
        End Select
        SetInternalExternalLinkDisplay()
    End Sub
End Class
