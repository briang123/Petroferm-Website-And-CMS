Imports System.Configuration.ConfigurationManager

Partial Class CmsPageEdit
    Inherits CMSPage
    Private _formMode As CMSFormUtils.FormMode = CMSFormUtils.FormMode.Read ' default to read
    Private Const ListPage As String = "PageList.aspx"
    Private Const DeleteColumn As Integer = 0
    Private Const EditColumn As Integer = 1
    Private Const ViewColumn As Integer = 2
    Private Const PageModuleTitleColumn As Integer = 3
    Private Property CurrentPageId() As Integer
        Get
            If ViewState("CurrentPageID") IsNot Nothing Then
                Return Services.GetNULLableInteger(ViewState("CurrentPageID"))
            Else
                Return 0
            End If
        End Get
        Set(ByVal value As Integer)
            ViewState("CurrentPageID") = value
            ' still need to set hidden control -- for gv datasources
            Me.hidPageID.Text = value
        End Set
    End Property

    Private Property GeneralInfoFormMode() As CMSFormUtils.FormMode
        Get
            If ViewState("GeneralInfoFormMode") IsNot Nothing Then
                Return CType(ViewState("GeneralInfoFormMode"), CMSFormUtils.FormMode)
            Else
                Return CMSFormUtils.FormMode.Read ' default to read
            End If
        End Get
        Set(ByVal value As CMSFormUtils.FormMode)
            ViewState("GeneralInfoFormMode") = value
        End Set
    End Property

    Private Property CurrentMarketId() As Integer
        Get
            If ViewState("CurrentMarketID") IsNot Nothing Then
                Return Services.GetNULLableInteger(ViewState("CurrentMarketID"))
            Else
                Return 0
            End If
        End Get
        Set(ByVal value As Integer)
            ViewState("CurrentMarketID") = value
        End Set
    End Property

    Private Property CurrentPageType() As String
        Get
            Return ViewState("CurrentPageType")
        End Get
        Set(ByVal value As String)
            ViewState("CurrentPageType") = value
        End Set
    End Property

    Private Property CurrentSideNavId() As Integer
        Get
            If ViewState("CurrentSideNavID") IsNot Nothing Then
                Return Services.GetNULLableInteger(ViewState("CurrentSideNavID"))
            Else
                Return 0
            End If
        End Get
        Set(ByVal value As Integer)
            ViewState("CurrentSideNavID") = value
        End Set
    End Property

    Protected Sub Page_Load(ByVal sender As Object, ByVal e As System.EventArgs) Handles Me.Load


        Page.ClientScript.RegisterClientScriptInclude(Me.GetType(), "LoginJS", "../web/files/scripts/selectbox.js")
        Page.ClientScript.RegisterClientScriptInclude(Me.GetType(), "findDOM", "../web/files/scripts/findDOM.js")
        'Me.Page.ClientScript.RegisterClientScriptBlock(Me.GetType, "selectall", Me.ucProductBlurbModule.SelectProductsJSBlock)


        lblMessage.Text = ""
        Dim pageId As Integer
        If Not Session("FormMode") Is Nothing Then
            wzForm.ActiveStepIndex = 0 ' set the first step to active one 
            _formMode = Convert.ToInt32(Session("FormMode"))
            hidFormMode.Text = _formMode
            Session("FormMode") = Nothing ' clear out session variable
        ElseIf hidFormMode.Text.Length > 0 Then
            _formMode = Convert.ToInt32(hidFormMode.Text)
        End If


        ' The ID is sent from the list page in session -- if it's an add, 0 is passed as the ID
        If Not Session("FormPageID") Is Nothing Then
            pageID = Convert.ToInt32(Session("FormPageID"))
            Session("FormPageID") = Nothing ' clear out session variable
        End If



        ' TODO: CMS - Page Edit - Enable the copying of page modules
        ' for now, disable it because it's not done yet
        Me.trCopyExistingModule.VISIBLE = False

        Dim editPage As WebPage = Nothing
        If Not IsPostBack Then

            ' if this is an edit, get the bus unit info and fill the form
            If pageID <> 0 Then
                editPage = New WebPage
                With editPage
                    .PageId = pageID
                    .FillCMSContent()
                    Me.CurrentPageID = .PageId
                    Me.CurrentMarketID = .CurrentMarket.MarketID
                    Me.CurrentPageType = .PageType
                    If .CurrentMarket.MarketID <> 0 Then
                        ddlMarket.SelectedValue = .CurrentMarket.MarketID
                    End If
                    txtPageTitle.Text = .PageTitle
                    Me.txtFriendlyURL.Text = .URLRewritePath
                    lblPageTitleStep2.Text = .PageTitle
                    txtMetaKeywords.Text = .MetaKeywords
                    txtMetaDescription.Text = .MetaDescription
                    dtePublishDate.SelectedDate = .PublishDate
                    dteExpireDate.SelectedDate = .ExpireDate
                    hidPageID.Text = .PageId
                    'set view state vals
                    Me.CurrentPageID = .PageId
                    ' set workflow control
                    Me.ucWorkflowInfo.SetValues(editPage)
                End With
            Else

                ' check form mode -- if read, then just redirect back to list
                If _formMode = CMSFormUtils.FormMode.Read Then
                    Response.Redirect(ListPage)
                Else
                    ' adding an item
                    ' hide workflow control
                    ucWorkflowInfo.Visible = False
                    ' default the publish date
                    dtePublishDate.SelectedDate = Today.Date
                    ' default the page type
                    Me.CurrentPageType = "GENERAL CONTENT"
                End If
            End If


        End If

        ' if this is part of another job that's not live, make this read only
        If _formMode = CMSFormUtils.FormMode.Edit And editPage IsNot Nothing Then
            If editPage.JobID <> Me.ActiveJobID And editPage.WorkflowStatus <> "LIVE" Then
                Me.GeneralInfoFormMode = CMSFormUtils.FormMode.Read
            Else
                Me.GeneralInfoFormMode = CMSFormUtils.FormMode.Edit
            End If
        ElseIf _formMode = CMSFormUtils.FormMode.Edit And Me.CurrentPageID = 0 Then ' adding a new one
            Me.GeneralInfoFormMode = CMSFormUtils.FormMode.Edit
        End If
        ' set the controls read only if form mode is read
        SetFormMode(_formMode)
        ' step 1 - general info - hide/show friendly url
        If Me.CurrentPageID = 0 Then
            Me.trFriendlyURL.Visible = False
        Else
            Me.trFriendlyURL.Visible = True
        End If

    End Sub

    ''' <summary>
    ''' This sets the form mode based on mode specified
    ''' </summary>
    ''' <param name="mode"></param>
    ''' <remarks></remarks>
    Sub SetFormMode(ByVal mode As CMSFormUtils.FormMode)
        Select Case mode
            Case CMSFormUtils.FormMode.Edit
                SetControlEnabledProperty(True)
                Me.Master.PageTitle = "Add/Edit"
                ' set instructions
                Me.lblNavigationInstructions.Text = AppSettings("PAGE_EDIT_PAGE_MODULES")
            Case CMSFormUtils.FormMode.Read
                SetControlEnabledProperty(False)
                Me.Master.PageTitle = "View"
        End Select
        Me.Master.PageTitle = Me.Master.PageTitle & " Page"
        ' set the cancel destination page
        wzForm.CancelDestinationPageUrl = ListPage
        ' set the finish button text/attribute
        CMSFormUtils.SetFinishButtonProperties(CType(wzForm.FindControl("FinishNavigationTemplateContainerID$FinishButton"), Button), _formMode)

        ' set the page module page form mode
        If Not IsPostBack Then
            ResetPageModuleStep(_formMode)
        End If


        ' REMOVE THE NAVIGATION STEP FOR BUSINESS/MARKET HOME PAGES
        If Me.CurrentPageType = "BUSINESS HOME" Or _
           Me.CurrentPageType = "MARKET HOME" Or _
           Me.CurrentPageType = "PASSTHROUGH" Then
            Me.wzForm.WizardSteps.RemoveAt(2)
        End If


    End Sub

    ''' <summary>
    ''' This sets just the General Info items for read only
    ''' Fixes "part of other job" issue
    ''' </summary>
    ''' <param name="enable"></param>
    ''' <remarks></remarks>
    Private Sub SetControlEnabledPropertyGeneralInfo(ByVal enable As Boolean)
        txtPageTitle.Enabled = enable
        txtMetaDescription.Enabled = enable
        txtMetaKeywords.Enabled = enable
        dtePublishDate.Enabled = enable
        dteExpireDate.Enabled = enable
        ddlMarket.Enabled = enable
        Me.txtFriendlyURL.Enabled = enable
    End Sub

    ''' <summary>
    ''' This sets all of the user input controls enabled property
    ''' based on the parm value
    ''' </summary>
    ''' <param name="enable">True/False</param>
    ''' <remarks></remarks>
    Sub SetControlEnabledProperty(ByVal enable As Boolean)

        If Me.GeneralInfoFormMode = CMSFormUtils.FormMode.Read Then ' make sure the make the general info stuff readonly
            SetControlEnabledPropertyGeneralInfo(False)
            ' set controls on side nav step, but tie it to the page -- can't edit it if the page is being edited
            If Me.wzForm.WizardSteps.Count = 3 Then
                Me.ddlSideNavSection.Enabled = False
                Me.ddlProductCategory.Enabled = False
                Me.txtLinkText.Enabled = False
                Me.rdoSideNavYesNo.Enabled = False
                Me.rdoSideNavYesNo.SelectedValue = "No"
            End If
        Else
            SetControlEnabledPropertyGeneralInfo(enable) ' just use form_mode
            ' set controls on side nav step, but tie it to the page 
            If Me.wzForm.WizardSteps.Count = 3 Then
                Me.ddlSideNavSection.Enabled = enable
                Me.ddlProductCategory.Enabled = enable
                Me.txtLinkText.Enabled = enable
                Me.rdoSideNavYesNo.Enabled = enable
                If Not Me.rdoSideNavYesNo.Enabled Then
                    Me.rdoSideNavYesNo.SelectedValue = "No"
                End If
            End If
        End If


    End Sub

    Protected Sub wzForm_ActiveStepChanged(ByVal sender As Object, ByVal e As System.EventArgs) Handles wzForm.ActiveStepChanged
        Select Case wzForm.ActiveStepIndex
            Case 0 ' general info

            Case 1 ' page modules
                ResetPageModuleStep(_formMode)
            Case 2 ' navigation
                Select Case Me.CurrentPageType
                    Case "BUSINESS HOME", "MARKET HOME", "PASSTHROUGH"
                        'wzForm.ActiveStep.Visible = False
                        'redirect back to list page?
                    Case Else
                        If Me.CurrentSideNavID = 0 And Me.CurrentPageID <> 0 Then
                            '  fill side nav step if applicable
                            Dim sideNav As New SideNavigation
                            With sideNav
                                ' set the page id (the fill will know what to use to get the side nav info)
                                .PageID = Me.CurrentPageID
                                .Fill()
                                If .ID <> 0 Then ' a record was returned, set the controls on step 3
                                    Me.rdoSideNavYesNo.SelectedValue = "Yes"
                                    Me.ddlSideNavSection.DataBind()
                                    Me.ddlSideNavSection.SelectedValue = .SectionID
                                    If Me.ddlSideNavSection.SelectedValue = "1" Then 'if it's a product section, set prod cat ddl
                                        Me.trProductCategory.Visible = True
                                        Me.ddlProductCategory.DataBind()
                                        Me.ddlProductCategory.SelectedValue = .ProdCatID
                                    Else
                                        Me.trProductCategory.Visible = False
                                    End If
                                    Me.txtLinkText.Text = .Title
                                    Me.CurrentSideNavID = .ID
                                Else
                                    Me.tblSideNavInfo.Visible = False
                                End If
                            End With
                        End If
                End Select


        End Select
    End Sub

    Function SavePageInfo() As Boolean
        ' TODO: CMS - Page Edit - Make sure to check to see if PageTitle is unique
        ' a stored proc will return an output parm indicating if the PageTitle is a duplicate
        ' it will not save if it's a duplicate
        ' display the error to the user indicating it's a duplicate
        Dim savePage As New WebPage
        Dim success As Boolean
        Try
            ' if it's readonly here, don't save
            If _formMode = CMSFormUtils.FormMode.Edit Then
                If Page.IsValid Then
                    With savePage
                        ' get page id from viewstate
                        .PageId = Me.CurrentPageID
                        ' first fill the obj from the db (need to get other info that's not on this form)
                        If .PageId <> 0 Then
                            .FillCMSContent()
                        Else
                            .BusUnit.BusUnitID = Session("BusUnitID")
                        End If

                        ' now get the new info
                        .PageType = Me.CurrentPageType
                        .CurrentMarket.MarketID = Services.GetNULLableInteger(Me.ddlMarket.SelectedValue)
                        Me.CurrentMarketID = .CurrentMarket.MarketID
                        .PageTitle = Me.txtPageTitle.Text.Trim
                        .MetaKeywords = Me.txtMetaKeywords.Text.Trim
                        .MetaDescription = Me.txtMetaDescription.Text.Trim
                        .PublishDate = dtePublishDate.SelectedDate
                        .ExpireDate = dteExpireDate.SelectedDate
                        .URLRewritePath = Me.txtFriendlyURL.Text.Trim
                        .JobID = Me.ActiveJobID
                        .LastModBy = Me.ActiveUserID
                        If .Save() Then
                            success = True
                            ' set the product id hidden form field
                            Me.hidPageID.Text = .PageId.ToString
                            Me.CurrentPageID = .PageId
                            Me.lblPageTitleStep2.Text = .PageTitle
                            ' reset the workflow stuff
                            ' set workflow control
                            .FillCMSContent()
                            ' if it's an add, make sure to fill the friendly url text box
                            Me.txtFriendlyURL.Text = .URLRewritePath
                            ucWorkflowInfo.SetValues(savePage)
                        Else
                            success = False
                            lblMessage.Text = "There was an error saving the Product Attribute."
                            lblMessage.CssClass = "errorMessage"
                        End If
                    End With
                Else
                    success = False
                    lblMessage.Text = "The Page cannot be saved unless all invalid information is corrected."
                    lblMessage.CssClass = "errorMessage"
                End If
            End If
        Catch ex As Exception
            If TypeOf ex Is NLTException Then
                Throw ex
            Else
                Throw New NLTException("Error saving Page.", ex, "cms/PageEdit.aspx", "Function SavePage() As Boolean")
            End If
        End Try
        Return success




        Return True

    End Function

    Protected Sub gvPageModules_RowCommand(ByVal sender As Object, ByVal e As System.Web.UI.WebControls.GridViewCommandEventArgs) Handles gvPageModules.RowCommand
        ' If multiple ButtonField column fields are used, use the
        ' CommandName property to determine which button was clicked.

        Dim controlMode As CMSFormUtils.FormMode
        Select Case e.CommandName
            Case "EditItem", "ReadItem"
                ' Get the ID to be edited
                Dim args As String() = e.CommandArgument.ToString.Split("|")
                ' this will bring back the following values:
                ' args(0) = source name (module type)
                ' args(1) = source id (id of the module)
                ' need to find out what module type it is
                Dim sourceName As String = args(0)
                Dim sourceId As String = args(1)

                If e.CommandName = "EditItem" Then
                    controlMode = CMSFormUtils.FormMode.Edit
                Else
                    controlMode = CMSFormUtils.FormMode.Read
                End If

                Select Case sourceName
                    Case "CONTENT", "SIDE CONTENT"
                        Dim editContent As New ContentModule
                        With editContent
                            .ContentId = sourceID
                            .ModuleType = sourceName
                            .PageId = Me.CurrentPageID
                            .LiveModeStatus = False
                            .Fill()
                        End With
                        SetModuleControl(sourceName, editContent, controlMode)
                    Case "HEADER SIDE CONTENT"
                        Dim editHeaderSideContent As New HeaderSideContentModule
                        With editHeaderSideContent
                            .HeaderSideContentModuleId = sourceID
                            .ModuleType = sourceName
                            .PageId = Me.CurrentPageID
                            .LiveModeStatus = False
                            .Fill()
                        End With
                        SetModuleControl(sourceName, editHeaderSideContent, controlMode)
                    Case "PRODUCT BLURB"
                        Dim editProductBlurb As New ProductBlurbModule
                        With editProductBlurb
                            .ProductBlurbModuleID = sourceID
                            .ModuleType = sourceName
                            .PageId = Me.CurrentPageID
                            .Fill(False)
                        End With
                        SetModuleControl(sourceName, editProductBlurb, controlMode)
                    Case "PRODUCT GRID"
                        Dim editProductGrid As New ProductGridModule
                        With editProductGrid
                            .ProductGridModuleID = sourceID
                            .ModuleType = sourceName
                            .PageId = Me.CurrentPageID
                            .LiveModeStatus = WorkflowItem.LiveMode.CMS
                            .Fill()
                        End With
                        SetModuleControl(sourceName, editProductGrid, controlMode)
                    Case "NAV ON IMAGE", "NAV OFF IMAGE", "HEADER IMAGE", "HEADER SIDE CONTENT IMAGE"
                        Dim editImage As New ImageModule(sourceid, WorkflowItem.LiveMode.CMS)
                        With editImage
                            .ModuleType = sourceName
                            .PageId = Me.CurrentPageID
                            .Fill()
                        End With
                        SetModuleControl(sourceName, editImage, controlMode)
                End Select

                ' hide the add module panel, but show the add/cancel buttons
                Me.pnlAddPageModuleDropdown.Visible = False
                Me.pnlSaveCancelModuleButtons.Visible = True
                ' need to set the save/cancel buttons depending on mode
                If controlMode = CMSFormUtils.FormMode.Read Then
                    Me.btnSaveModule.Visible = False
                    Me.btnCancelModule.Text = "Close"
                Else
                    Me.btnSaveModule.Visible = True
                    Me.btnCancelModule.Text = "Cancel"
                End If

                Me.gvPageModules.Visible = False

            Case "DeleteItem"
                ' Get the item to be edited
                Dim args As String() = e.CommandArgument.ToString.Split("|")
                Dim deleted As Boolean = False
                ' this will bring back the following values:
                ' args(0) = source name (module type)
                ' args(1) = source id
                ' need to find out what module type it is
                Dim sourceName As String = args(0)
                Dim sourceId As String = args(1)
                Select Case sourceName
                    Case "CONTENT", "SIDE CONTENT"
                        Dim delModule As New ContentModule
                        With delModule
                            .ContentId = sourceID
                            .ModuleType = sourceName
                            .PageId = Me.CurrentPageID
                            ' TODO: CMS - Put in Job ID and User ID as args below
                            .JobID = Me.ActiveJobID
                            .LastModBy = Me.ActiveUserID
                            .LiveModeStatus = False
                            If .Delete() Then
                                deleted = True
                            End If
                        End With
                    Case "HEADER SIDE CONTENT"
                        Dim delModule As New HeaderSideContentModule
                        With delModule
                            .HeaderSideContentModuleId = sourceID
                            .ModuleType = sourceName
                            .PageId = Me.CurrentPageID
                            ' TODO: CMS - Put in Job ID and User ID as args below
                            .JobID = Me.ActiveJobID
                            .LastModBy = Me.ActiveUserID
                            .LiveModeStatus = False
                            If .Delete() Then
                                deleted = True
                            End If
                        End With
                    Case "PRODUCT BLURB"
                        Dim delModule As New ProductBlurbModule
                        With delModule
                            .ProductBlurbModuleID = sourceID
                            .ModuleType = sourceName
                            .PageId = Me.CurrentPageID
                            ' TODO: CMS - Put in Job ID and User ID as args below
                            .JobID = Me.ActiveJobID
                            .LastModBy = Me.ActiveUserID
                            If .Delete() Then
                                deleted = True
                            End If
                        End With
                    Case "PRODUCT BLURB"
                        Dim delModule As New ProductBlurbModule
                        With delModule
                            .ProductBlurbModuleID = sourceID
                            .ModuleType = sourceName
                            .PageId = Me.CurrentPageID
                            ' TODO: CMS - Put in Job ID and User ID as args below
                            .JobID = Me.ActiveJobID
                            .LastModBy = Me.ActiveUserID
                            If .Delete() Then
                                deleted = True
                            End If
                        End With
                    Case "PRODUCT GRID"
                        Dim delModule As New ProductGridModule
                        With delModule
                            .ProductGridModuleId = sourceID
                            .ModuleType = sourceName
                            .PageId = Me.CurrentPageID
                            ' TODO: CMS - Put in Job ID and User ID as args below
                            .JobID = Me.ActiveJobID
                            .LastModBy = Me.ActiveUserID
                            If .Delete() Then
                                deleted = True
                            End If
                        End With
                    Case "NAV ON IMAGE", "NAV OFF IMAGE", "HEADER IMAGE", "HEADER SIDE CONTENT IMAGE"
                        Dim delModule As New ImageModule
                        With delModule
                            .ImageModuleId = sourceID
                            .ModuleType = sourceName
                            .PageId = Me.CurrentPageID
                            ' TODO: CMS - Put in Job ID and User ID as args below
                            .JobID = Me.ActiveJobID
                            .LastModBy = Me.ActiveUserID
                            If .Delete() Then
                                deleted = True
                            End If
                        End With
                End Select
                If deleted Then
                    lblMessage.Text = "The page module has been deleted or marked for deletion."
                    lblMessage.CssClass = "infoMessage"
                    ResetPageModuleStep(_formMode)
                    gvPageModules.DataBind()
                End If
        End Select
    End Sub

    Protected Sub gvPageModules_RowDataBound(ByVal sender As Object, ByVal e As System.Web.UI.WebControls.GridViewRowEventArgs) Handles gvPageModules.RowDataBound



        ' this adds a confirmation message to the delete command
        If e.Row.RowType = DataControlRowType.DataRow Then
            Dim moduleTitle As String = DataBinder.Eval(e.Row.DataItem, "ModuleTitle")
            ' replace any apostrophes
            moduleTitle = moduleTitle.Replace("'", "\'")

            Dim ibtnDelete As ImageButton = e.Row.FindControl("ibtnDelete")
            ibtnDelete.Attributes.Add("onclick", "javascript:return " & _
              "confirm('Are you sure you want to delete " & _
              moduleTitle & "?')")


            ' for the buttons, use source name and source id as the command argument values (will split into array at rowcommand)
            Dim cmdArg As String = DataBinder.Eval(e.Row.DataItem, "SourceName").ToString & _
                    "|" & DataBinder.Eval(e.Row.DataItem, "SourceID").ToString

            ibtnDelete.CommandArgument = cmdArg

            Dim ibtnEdit As ImageButton = e.Row.FindControl("ibtnEdit")
            ibtnEdit.CommandArgument = cmdArg

            Dim ibtnView As ImageButton = e.Row.FindControl("ibtnView")
            ibtnView.CommandArgument = cmdArg


            ' hide the edit/delete button for item that is marked for deletion
            If Convert.ToBoolean(DataBinder.Eval(e.Row.DataItem, "MarkedForDeletion")) Then
                e.Row.Cells(EditColumn).Text = String.Empty
                e.Row.Cells(DeleteColumn).Text = String.Empty
            End If

            ' -- part of other job check --
            ' if the item is part of another job and in non-LIVE status, then hide edit/delete icons
            If Convert.ToInt32(DataBinder.Eval(e.Row.DataItem, "DeploymentJobID")) <> _
                    Me.ActiveJobID And _
                DataBinder.Eval(e.Row.DataItem, "WorkflowStatus").ToString <> "LIVE" Then
                e.Row.Cells(EditColumn).Text = CMSGlobals.BlankIcon
                e.Row.Cells(DeleteColumn).Text = CMSGlobals.BlankIcon
            End If

            If hidFormMode.Text.Length > 0 Then
                _formMode = Convert.ToInt32(hidFormMode.Text)
            End If

            ' if in read only mode, hide the edit/delete buttons
            If Me._formMode = CMSFormUtils.FormMode.Read Then
                e.Row.Cells(EditColumn).Text = CMSGlobals.BlankIcon
                e.Row.Cells(DeleteColumn).Text = CMSGlobals.BlankIcon
            End If

            ' if there's no active job, then hide delete/edit icons
            If Me.ActiveJobID = 0 Then
                e.Row.Cells(EditColumn).Text = CMSGlobals.BlankIcon
                e.Row.Cells(DeleteColumn).Text = CMSGlobals.BlankIcon
            End If


            ' add image or document links to the module title column 
            Select Case DataBinder.Eval(e.Row.DataItem, "SourceName").ToString
                Case "NAV ON IMAGE", "NAV OFF IMAGE", "HEADER IMAGE", "HEADER SIDE CONTENT IMAGE"
                    Dim img As New Image
                    With img
                        .ID = "imgImageModule"
                        .ImageUrl = "~/" & DataBinder.Eval(e.Row.DataItem, "ExtraModuleInfo").ToString
                        .AlternateText = DataBinder.Eval(e.Row.DataItem, "ModuleTitle").ToString
                        .Width = CMSGlobals.GridImageMaxWidth
                        .Height = CMSGlobals.GridImageMaxHeight
                    End With
                    e.Row.Cells(PageModuleTitleColumn).Text = String.Empty
                    e.Row.Cells(PageModuleTitleColumn).Controls.Add(img)
                Case "DOCUMENT" ' provide link to open doc in new window
                    Dim lnk As New HyperLink
                    With lnk
                        .ID = "lnkDoc"
                        .NavigateUrl = "~/" & DataBinder.Eval(e.Row.DataItem, "ExtraModuleInfo").ToString
                        .Text = DataBinder.Eval(e.Row.DataItem, "ModuleTitle").ToString
                        .Target = "_blank"
                        e.Row.Cells(PageModuleTitleColumn).Text = String.Empty
                        e.Row.Cells(PageModuleTitleColumn).Controls.Add(lnk)
                    End With
            End Select


        End If
    End Sub

    Sub SetModuleControl(ByVal moduleType As String, ByVal editModule As Object, ByVal mode As CMSFormUtils.FormMode)
        'Me.btnSaveModule.Attributes.Remove("onclick")
        Select Case moduleType
            Case "CONTENT", "SIDE CONTENT"
                With ucContentModule
                    If editModule IsNot Nothing Then ' set the property to this obj
                        .CurrentContentModule = TryCast(editModule, ContentModule)
                    Else
                        .CurrentContentModule.ModuleType = moduleType
                        .CurrentContentModule.PageId = Me.CurrentPageID
                    End If
                    .SetFormValues()
                    .SetFormMode(mode)
                    .Visible = True
                End With

            Case "HEADER SIDE CONTENT"
                With ucHeaderSideContentModule
                    If editModule IsNot Nothing Then ' set the property to this obj
                        .CurrentHeaderSideContentModule = TryCast(editModule, HeaderSideContentModule)
                    Else
                        .CurrentHeaderSideContentModule.ModuleType = moduleType
                        .CurrentHeaderSideContentModule.PageId = Me.CurrentPageID
                    End If
                    .SetFormValues()
                    .SetFormMode(mode)
                    .Visible = True
                End With

            Case "PRODUCT BLURB"
                With ucProductBlurbModule
                    .ResetForm()
                    If editModule IsNot Nothing Then ' set the property to this obj
                        .CurrentProductBlurbModule = TryCast(editModule, ProductBlurbModule)
                    Else
                        .CurrentProductBlurbModule = New ProductBlurbModule
                        .CurrentProductBlurbModule.ModuleType = moduleType
                        .CurrentProductBlurbModule.PageId = Me.CurrentPageID
                    End If

                    .SetFormValues()
                    .SetFormMode(mode)
                    .Visible = True
                End With

            Case "PRODUCT GRID"
                With ucProductGridModule
                    .ResetForm()
                    If editModule IsNot Nothing Then ' set the property to this obj
                        .CurrentProductGridModule = TryCast(editModule, ProductGridModule)
                    Else
                        .CurrentProductGridModule = New ProductGridModule
                        .CurrentProductGridModule.ModuleType = moduleType
                        .CurrentProductGridModule.PageId = Me.CurrentPageID
                    End If

                    .SetFormValues()
                    .SetFormMode(mode)
                    .Visible = True

                End With
                ' also add onclick to select all prods/attribs before saving

                Me.btnSaveModule.Attributes.Remove("onclick")
                Me.btnSaveModule.Attributes.Add("onclick", "selectAll();return true;")

            Case "DOCUMENT"
                With ucDocumentModule
                    .ResetForm()
                    If editModule IsNot Nothing Then ' set the property to this obj
                        .CurrentDocumentModule = TryCast(editModule, DocumentModule)
                    Else
                        .CurrentDocumentModule = New DocumentModule
                        .CurrentDocumentModule.ModuleType = moduleType
                        .CurrentDocumentModule.PageId = Me.CurrentPageID
                    End If

                    .SetFormValues()
                    .SetFormMode(mode)
                    .Visible = True
                End With
            Case "NAV ON IMAGE", "NAV OFF IMAGE", "HEADER IMAGE", "HEADER SIDE CONTENT IMAGE"
                With ucImageModule
                    .ResetForm()
                    .ImageType = moduleType
                    ' check to see if it's a nav on image and the petro home page
                    ' if so, then we'll want to display the "welcome" fields
                    If Me.CurrentPageID = 1 And (moduleType = "NAV ON IMAGE" Or moduleType = "NAV OFF IMAGE") Then
                        .IsPetroHomePageNavOnImage = True
                    End If
                    If editModule IsNot Nothing Then ' set the property to this obj
                        .CurrentImageModule = TryCast(editModule, ImageModule)
                    Else
                        .CurrentImageModule = New ImageModule
                        .CurrentImageModule.ModuleType = moduleType
                        .CurrentImageModule.PageId = Me.CurrentPageID
                    End If

                    .SetFormValues()
                    .SetFormMode(mode)
                    .Visible = True
                End With


        End Select
    End Sub

    Protected Sub lbtnAdd_Click(ByVal sender As Object, ByVal e As System.EventArgs) Handles lbtnAddModule.Click
        Dim setForm As Boolean = False

        SetModuleControl(ddlModuleAdd.SelectedValue, Nothing, CMSFormUtils.FormMode.Edit)
        setForm = True
        If ddlModuleAdd.SelectedValue.Length > 0 Then
            ' only set the form if they selected a module type to add
            If setForm Then
                ' hide the add module panel, but show the add/cancel buttons
                Me.pnlAddPageModuleDropdown.Visible = False
                Me.pnlSaveCancelModuleButtons.Visible = True
                Me.btnSaveModule.Visible = True
                Me.btnCancelModule.Text = "Cancel"
            End If
        End If
        Me.gvPageModules.Visible = False


    End Sub

    Protected Sub btnCancelModule_Click(ByVal sender As Object, ByVal e As System.EventArgs) Handles btnCancelModule.Click
        ResetPageModuleStep(_formMode)
    End Sub

    Sub ResetPageModuleStep(ByVal formMode As CMSFormUtils.FormMode)
        If formMode = CMSFormUtils.FormMode.Edit Then
            ' hide the add module panel
            Me.pnlAddPageModuleDropdown.Visible = True
        Else
            Me.pnlAddPageModuleDropdown.Visible = False
        End If
        ' clear the module control and save/cancel buttons
        Me.pnlSaveCancelModuleButtons.Visible = False

        Select Case True
            Case Me.ucContentModule.Visible
                Me.ucContentModule.ResetForm()
                Me.ucContentModule.Visible = False
            Case Me.ucHeaderSideContentModule.Visible
                ucHeaderSideContentModule.ResetForm()
                Me.ucHeaderSideContentModule.Visible = False
            Case Me.ucProductBlurbModule.Visible
                ucProductBlurbModule.ResetForm()
                Me.ucProductBlurbModule.Visible = False
            Case Me.ucProductGridModule.Visible
                ucProductGridModule.ResetForm()
                Me.ucProductGridModule.Visible = False
            Case Me.ucDocumentModule.Visible
                ucProductBlurbModule.ResetForm()
                Me.ucProductBlurbModule.Visible = False
            Case Me.ucImageModule.Visible
                ucImageModule.ResetForm()
                Me.ucImageModule.Visible = False

        End Select
        ddlModuleAdd.ClearSelection()
        ddlModuleCopy.ClearSelection()
        Me.gvPageModules.Visible = True

    End Sub

    Sub ResetSideNavStep()
        Me.ddlSideNavSection.ClearSelection()
        Me.ddlProductCategory.ClearSelection()
        Me.trProductCategory.Visible = False
        Me.txtLinkText.Text = String.Empty
    End Sub

    Protected Sub btnSaveModule_Click(ByVal sender As Object, ByVal e As System.EventArgs) Handles btnSaveModule.Click
        Dim refreshGrid As Boolean
        Select Case True
            ' content module 
            Case ucContentModule.Visible
                ' get the form values, it fills the content module prop of the control
                ucContentModule.GetFormValues()
                With ucContentModule.CurrentContentModule
                    .PageId = Me.CurrentPageID
                    ' TODO: CMS - Put in Job ID and User ID as args below
                    .JobID = Me.ActiveJobID
                    .LastModBy = Me.ActiveUserID
                    .Save()
                End With
                ucContentModule.Visible = False
                ucContentModule.ResetForm()
                refreshGrid = True
            Case ucHeaderSideContentModule.Visible
                ' get the form values, it fills the content module prop of the control
                ucHeaderSideContentModule.GetFormValues()
                With ucHeaderSideContentModule.CurrentHeaderSideContentModule
                    .PageId = Me.CurrentPageID
                    ' TODO: CMS - Put in Job ID and User ID as args below
                    .JobID = Me.ActiveJobID
                    .LastModBy = Me.ActiveUserID
                    .Save()
                End With
                ucHeaderSideContentModule.Visible = False
                ucHeaderSideContentModule.ResetForm()
                refreshGrid = True
            Case ucProductBlurbModule.Visible
                ' get the form values, it fills the content module prop of the control
                ucProductBlurbModule.GetFormValues()
                With ucProductBlurbModule.CurrentProductBlurbModule
                    .PageId = Me.CurrentPageID
                    ' TODO: CMS - Put in Job ID and User ID as args below
                    .JobID = Me.ActiveJobID
                    .LastModBy = Me.ActiveUserID
                    .Save()
                End With
                ucProductBlurbModule.Visible = False
                ucProductBlurbModule.ResetForm()
                refreshGrid = True
            Case ucProductGridModule.Visible
                ' get the form values, it fills the content module prop of the control
                ucProductGridModule.GetFormValues()
                With ucProductGridModule.CurrentProductGridModule
                    .PageId = Me.CurrentPageID
                    ' TODO: CMS - Put in Job ID and User ID as args below
                    .JobID = Me.ActiveJobID
                    .LastModBy = Me.ActiveUserID
                    .Save()
                End With
                ucProductGridModule.Visible = False
                ucProductGridModule.ResetForm()
                refreshGrid = True
            Case ucImageModule.Visible
                Dim doSave As Boolean = True
                ' get the form values, it fills the image module prop of the control
                ucImageModule.GetFormValues()

                With ucImageModule.CurrentImageModule
                    .PageId = Me.CurrentPageID
                    .JobID = Me.ActiveJobID
                    .LastModBy = Me.ActiveUserID
                    ' do the file upload, if applicable
                    If .ImageFile.ImageId = 0 Then
                        If Not ucImageModule.UploadImage(.ImageFile, "MAIN") Then
                            doSave = False
                        End If
                    End If
                    ' do the file upload for welcome img, if applicable
                    If .WelcomeImageFile.ImageId = 0 And .IsPetrofermHomePage Then
                        If Not ucImageModule.UploadImage(.WelcomeImageFile, "WELCOME") Then
                            doSave = False
                        End If
                    End If

                    If doSave Then
                        .Save()
                    End If
                End With
                ucImageModule.Visible = False
                ucImageModule.ResetForm()
                refreshGrid = True

            Case ucDocumentModule.Visible
                ' get the form values, it fills the image module prop of the control
                ucDocumentModule.GetFormValues()

                With ucDocumentModule.CurrentDocumentModule
                    .PageId = Me.CurrentPageID
                    .JobID = Me.ActiveJobID
                    .LastModBy = Me.ActiveUserID
                    .Save()
                End With
                ucDocumentModule.Visible = False
                ucDocumentModule.ResetForm()
                refreshGrid = True

        End Select

        If refreshGrid Then
            Me.gvPageModules.DataBind()
        End If
        ResetPageModuleStep(_formMode)
    End Sub

    Protected Sub ddlModuleAdd_PreRender(ByVal sender As Object, ByVal e As System.EventArgs) Handles ddlModuleAdd.PreRender
        ' add initial empty "select" module type item
        ' if it's not there already
        With ddlModuleAdd
            If .Items.Count > 0 Then
                If .Items(0).Value <> "" Then
                    Dim li As New ListItem("-- Select Module Type --", "")
                    .Items.Insert(0, li)
                End If
            End If
        End With

        'TODO: CMS - Page Edit - put back DOCUMENT module, right now just removing it because it's not done.
        Me.ddlModuleAdd.Items.Remove("DOCUMENT")
    End Sub

    Protected Sub ddlMarket_PreRender(ByVal sender As Object, ByVal e As System.EventArgs) Handles ddlMarket.PreRender
        ' add item to market name dropdown list on search attribute step -- for All Markets
        ' if it's not there already
        With ddlMarket
            If .Items.Count > 0 Then
                If .Items(0).Value <> "0" Then
                    Dim li As New ListItem("No Market", "0")
                    .Items.Insert(0, li)
                End If

            Else ' just add the initial item
                Dim li As New ListItem("No Market", "0")
                .Items.Insert(0, li)
            End If
        End With
    End Sub

    Protected Sub wzForm_NextButtonClick(ByVal sender As Object, ByVal e As System.Web.UI.WebControls.WizardNavigationEventArgs) Handles wzForm.NextButtonClick
        ' save information on the step
        ' (only in edit mode)
        If IsValid Then
            If _formMode = CMSFormUtils.FormMode.Edit And GeneralInfoFormMode = CMSFormUtils.FormMode.Edit Then
                Select Case wzForm.ActiveStepIndex
                    Case 0 ' General Info -- save it before going somewhere else
                        If Not SavePageInfo() Then
                            e.Cancel = True
                        End If


                End Select
            End If
        End If
    End Sub

    Protected Sub wzForm_FinishButtonClick(ByVal sender As Object, ByVal e As System.Web.UI.WebControls.WizardNavigationEventArgs) Handles wzForm.FinishButtonClick

        Dim sideNav As New SideNavigation
        Dim savePage As Boolean = False
        ' SAVE THE NAVIGATION STEP INFO
        ' TODO: CMS - Default the SideNav Order to 100 (for now)
        If Me.wzForm.ActiveStepIndex = 2 Then
            ' save side nav info

            ' if it's readonly here, just go back
            If _formMode = CMSFormUtils.FormMode.Edit Then

                If Me.rdoSideNavYesNo.SelectedValue = "Yes" Then
                    With sideNav
                        .ID = Me.CurrentSideNavID
                        ' fill the item before setting the new form values
                        If .ID <> 0 Then
                            .Fill()
                        End If
                        .BusinessUnitID = Session("BusUnitID")
                        If Me.ddlProductCategory.Visible Then
                            .ProdCatID = Services.GetNULLableInteger(Me.ddlProductCategory.SelectedValue)
                            ' we also need to update the page type to PRODUCT
                            If Me.CurrentPageType <> "PRODUCT" Then ' update the page type
                                Me.CurrentPageType = "PRODUCT"
                                savePage = True
                            End If
                        End If

                        ' if the section is datasheet, then check to see if there's a doc module
                        ' if so, then change the page type to DOCUMENT
                        ' 12/23/06 kr - task #9
                        If Me.ddlSideNavSection.SelectedValue = "2" Then
                            ' check for document module
                            Dim pgModule As New PageModule
                            Dim dv As DataView = pgModule.GetList(Me.CurrentPageID, False).DefaultView
                            dv.RowFilter = "SourceName = 'DOCUMENT'"
                            If dv.Count > 0 Then
                                Me.CurrentPageType = "DOCUMENT"
                                savePage = True
                            End If
                        End If


                        .Title = Me.txtLinkText.Text 'TODO: CMS - ?? verify this
                        .Description = .Title 'TODO: CMS - ?? verify this
                        .MarketID = Me.CurrentMarketID
                        .PageID = Me.CurrentPageID
                        .ItemOrder = 100 ' TODO: CMS - Change this from a default of 100 to what they specify (add a field)
                        '.Parent=??
                        .SectionID = Services.GetNULLableInteger(Me.ddlSideNavSection.SelectedValue)
                        .PublishDate = Me.dtePublishDate.SelectedDate
                        .ExpireDate = Me.dteExpireDate.SelectedDate
                        .JobID = Me.ActiveJobID
                        .LastModBy = Me.ActiveUserID
                        .Save()
                    End With
                ElseIf Me.CurrentSideNavID <> 0 Then ' we need to delete the side nav item
                    ' delete code here
                    With sideNav
                        .ID = Me.CurrentSideNavID
                        .JobID = Me.ActiveJobID
                        .LastModBy = Me.ActiveUserID
                        .LiveModeStatus = WorkflowItem.LiveMode.CMS
                        .Delete()
                    End With
                    ' if the page was a PRODUCT page, need to change it back to GENERAL CONTENT
                    If Me.CurrentPageType = "PRODUCT" Then
                        Me.CurrentPageType = "GENERAL CONTENT"
                        savePage = True
                    End If
                End If
                ' i think we should be saving the page every time when finish button is clicked
                '  If savePage Then
                Me.SavePageInfo()
                'End If

            End If
        End If
        Response.Redirect(ListPage)

    End Sub

    Protected Sub ddlModuleCopy_PreRender(ByVal sender As Object, ByVal e As System.EventArgs) Handles ddlModuleCopy.PreRender
        ' add item to market name dropdown list on search attribute step -- for All Markets
        ' if it's not there already
        With ddlModuleCopy
            If .Items.Count > 0 Then
                If .Items(0).Value <> "0" Then
                    Dim li As New ListItem("-- Select Module to Copy --", "0")
                    .Items.Insert(0, li)
                End If

            Else ' just add the initial item
                Dim li As New ListItem("-- Select Module to Copy --", "0")
                .Items.Insert(0, li)
            End If
        End With
    End Sub

    Protected Sub ddlSideNavSection_PreRender(ByVal sender As Object, ByVal e As System.EventArgs) Handles ddlSideNavSection.PreRender
        ' add initial empty "select" module type item
        ' if it's not there already
        With Me.ddlSideNavSection
            If .Items.Count > 0 Then
                If .Items(0).Value <> "0" Then
                    Dim li As New ListItem("-- Select Section --", "0")
                    .Items.Insert(0, li)
                End If
            End If
        End With
    End Sub

    Protected Sub ddlSideNavSection_SelectedIndexChanged(ByVal sender As Object, ByVal e As System.EventArgs) Handles ddlSideNavSection.SelectedIndexChanged
        ' if product is selected then
        Dim li As ListItem = Me.ddlSideNavSection.SelectedItem
        If li IsNot Nothing Then
            If li.Text.ToUpper = "PRODUCT CATEGORY" Or li.Value = "1" Then ' it's a prod cat
                Me.trProductCategory.visible = True
                Me.ddlProductCategory.DataBind()
            Else
                Me.ddlProductCategory.ClearSelection()
                Me.trProductCategory.Visible = False
            End If
        End If

    End Sub

    Protected Sub ddlProductCategory_PreRender(ByVal sender As Object, ByVal e As System.EventArgs) Handles ddlProductCategory.PreRender
        ' add initial empty "select" module type item
        ' if it's not there already
        With Me.ddlProductCategory
            If .Items.Count > 0 Then
                If .Items(0).Value <> "0" Then
                    Dim li As New ListItem("-- Select Product Category --", "0")
                    .Items.Insert(0, li)
                End If
            End If
        End With
    End Sub

    Protected Sub rdoSideNavYesNo_SelectedIndexChanged(ByVal sender As Object, ByVal e As System.EventArgs) Handles rdoSideNavYesNo.SelectedIndexChanged
        If Me.rdoSideNavYesNo.SelectedValue.ToUpper = "YES" Then
            Me.tblSideNavInfo.Visible = True

        Else
            Me.tblSideNavInfo.visible = False
        End If
    End Sub

    Protected Sub Page_PreRender(ByVal sender As Object, ByVal e As System.EventArgs) Handles Me.PreRender



        ' check to see if any of the page module controls are visible -- if so, then hide the grid
        If ucContentModule.Visible Or _
           ucHeaderSideContentModule.Visible Or _
           ucProductBlurbModule.Visible Or _
           ucProductGridModule.Visible Or _
           ucImageModule.Visible Or _
           ucDocumentModule.Visible Then
            gvPageModules.Visible = False
        End If


    End Sub

    Protected Sub vldDuplicateFriendlyURL_ServerValidate(ByVal source As Object, ByVal args As System.Web.UI.WebControls.ServerValidateEventArgs) Handles vldDuplicateFriendlyURL.ServerValidate
        Dim pg As New WebPage
        With pg
            .PageId = Me.CurrentPageID
            .URLRewritePath = Me.txtFriendlyURL.Text.Trim
            If .IsDuplicateURLFriendlyName Then
                args.IsValid = False
            Else
                args.IsValid = True
            End If
        End With
    End Sub
End Class
