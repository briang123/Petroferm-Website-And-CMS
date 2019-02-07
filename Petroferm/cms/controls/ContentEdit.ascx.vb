
Partial Class CmsControlsContentEdit
    Inherits System.Web.UI.UserControl
    Private _formMode As CMSFormUtils.FormMode = CMSFormUtils.FormMode.Read ' default to read
    Private _mCurrentContentModule As New ContentModule
    Public Property CurrentContentModule() As ContentModule
        Get
            Return _mCurrentContentModule
        End Get
        Set (ByVal value As ContentModule)
            _mCurrentContentModule = value
        End Set
    End Property
    Private Property CurrentContentId() As Integer
        Get
            If ViewState("CurrentContentID") IsNot Nothing Then
                Return Services.GetNULLableInteger(ViewState("CurrentContentID"))
            Else
                Return 0
            End If
        End Get
        Set(ByVal value As Integer)
            ViewState("CurrentContentID") = value
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
        If CurrentContentModule IsNot Nothing Then
            With CurrentContentModule
                Me.CurrentContentID = .ContentId
                Me.CurrentPageModuleRelnID = .PageModuleRelnId
                ' content id is set from calling page
                txtTitle.Text = .ContentTitle
                rdoContentType.SelectedValue = .ModuleType
                chkDisplayTitle.Checked = .ShowTitle
                If .ModuleOrder <> 0 Then
                    txtModuleOrder.Text = .ModuleOrder.ToString
                End If
                Dim edContent As HtmlEditor = phContentEditor.FindControl("edContent")
                If Not edContent Is Nothing Then
                    edContent.Content = .Content
                End If
                If .PublishDate <> #12:00:00 AM# Then
                    Me.dtePublishDate.SelectedDate = .PublishDate
                Else
                    Me.dtePublishDate.SelectedDate = Today.Date
                End If
                If .ExpireDate <> #12:00:00 AM# Then
                    Me.dteExpireDate.SelectedDate = .ExpireDate
                End If

            End With
        End If
    End Function
    ''' <summary>
    ''' Gets all values from the form and sets it to the content module property
    ''' </summary>
    ''' <remarks></remarks>
    Public Sub GetFormValues()
        With CurrentContentModule
            .ContentId = Me.CurrentContentID
            .PageId = Me.CurrentContentModule.PageId
            .PageModuleRelnId = Me.CurrentPageModuleRelnID
            .ModuleType = Me.rdoContentType.SelectedValue
            .ModuleOrder = Services.GetNULLableInteger(Me.txtModuleOrder.Text)
            Dim edContent As HtmlEditor = phContentEditor.FindControl("edContent")
            If Not edContent Is Nothing Then
                .Content = edContent.Content.Trim
            End If
            .ContentTitle = Me.txtTitle.Text
            .ShowTitle = Me.chkDisplayTitle.Checked
            .PublishDate = Me.dtePublishDate.SelectedDate
            .ExpireDate = Me.dteExpireDate.SelectedDate
        End With
    End Sub
    Public Sub SetControlEnabledProperty(ByVal enable As Boolean)
        rdoContentType.Enabled = enable
        txtTitle.Enabled = enable
        chkDisplayTitle.Enabled = enable
        txtModuleOrder.Enabled = enable
        dtePublishDate.Enabled = enable
        dteExpireDate.Enabled = enable

        Dim edContent As HtmlEditor = phContentEditor.FindControl("edContent")
        If Not edContent Is Nothing Then
            If Not enable Then ' get rid of editor -- just display content
                Dim contentText As String = edContent.Content
                phContentEditor.Controls.Clear()
                phContentEditor.Controls.Add(New LiteralControl("<div class=""readOnlyEditorContent"">" & contentText & "</div>"))
            End If
        End If
    End Sub


    Private Sub BuildContentEditor()
        'WYSIWYG EDITOR CODE WHEN SUBMITTING FORM VIA LINK BUTTON
        'lbtnSendReport.Attributes.Add("onclick", "finish_wysiwyg_editing()")
        Dim edContent As New HtmlEditor
        With edContent
            .ID = "edContent"
            ' these were moved to the constructor (new()) of HTMLEditor class
            '.ButtonFeatures = New String() { _
            '    "Print", "SpellCheck", "|", "Cut", "Copy", "Paste", "PasteWord", "|", "Undo", "Redo", "|", "Bookmark", "Hyperlink", "Image", "Characters", "|", "Table", "Guidelines", "|", "Numbering", "Bullets", "|", "Indent", "Outdent", "|", "RemoveFormat", "XHTMLSource", "ClearAll", "BRK", _
            '    "StyleAndFormatting", "TextFormatting", "ListFormatting", "BoxFormatting", "ParagraphFormatting", "CssText", "FontName", "FontSize", "|", "Bold", "Italic", "|", "JustifyLeft", "JustifyCenter", "JustifyRight", "JustifyFull"}
            ''.Content = BuildBodyBeginning() & BuildSignature()
            '.scriptPath = "scripts/"
            '.spellCheckMode = "NetSpell"
            '.btnSpellCheck = True
            .EditorHeight = "300"
            .EditorWidth = "600"
        End With
        phContentEditor.Controls.Add(edContent)
    End Sub

    Protected Sub Page_Load(ByVal sender As Object, ByVal e As System.EventArgs) Handles Me.Load
        BuildContentEditor()
    End Sub

    ''' <summary>
    ''' This sets the form mode based on mode specified
    ''' </summary>
    ''' <param name="mode"></param>
    ''' <remarks></remarks>
    Public Sub SetFormMode(ByVal mode As CMSFormUtils.FormMode)
        Select Case mode
            Case CMSFormUtils.FormMode.Edit
                Me.lblFormLabel.Text = "Add/Edit Content Module"
                SetControlEnabledProperty(True)
            Case CMSFormUtils.FormMode.Read
                Me.lblFormLabel.Text = "View Content Module"
                SetControlEnabledProperty(False)
        End Select
    End Sub
    Public Sub ResetForm() ' MAY NOT NEED THIS 
        ' now clear out the form
        rdoContentType.ClearSelection()
        txtTitle.Text = String.Empty
        chkDisplayTitle.Checked = False
        txtModuleOrder.Text = String.Empty
        dtePublishDate.SelectedDate = #12:00:00 AM#
        dteExpireDate.SelectedDate = #12:00:00 AM#
        Dim edContent As HtmlEditor = phContentEditor.FindControl("edContent")
        If Not edContent Is Nothing Then
            edContent.Content = String.Empty
        End If
        Me.CurrentContentModule = Nothing
        Me.CurrentPageModuleRelnID = 0
        Me.CurrentContentID = 0
    End Sub
End Class
