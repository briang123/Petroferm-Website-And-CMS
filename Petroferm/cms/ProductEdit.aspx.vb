
Partial Class CmsProductEdit
    Inherits CMSPage
    Private _formMode As CMSFormUtils.FormMode = CMSFormUtils.FormMode.Read ' default to read
    Private Const ListPage As String = "ProductList.aspx"
    Private Const DeleteColumn As Integer = 0
    Private Const EditColumn As Integer = 1
    Private Property ProductApprovalText() As String
        Get
            Return ViewState("ProductApprovalText").ToString()
        End Get
        Set(ByVal value As String)
            ViewState("ProductApprovalText") = value
        End Set
    End Property
#Region " GENERAL METHODS "
    Protected Sub Page_Load(ByVal sender As Object, ByVal e As System.EventArgs) Handles Me.Load

        ' TODO: CMS - Determine title based on whether it's add or edit
        Me.Master.PageTitle = "Add/Edit Product"
        lblMessage.Text = ""

        BuildHTMLEditors()

        Dim productId As Integer
        If Not Session("FormMode") Is Nothing Then
            wzForm.ActiveStepIndex = 0 ' set the first step to active one 
            _formMode = Convert.ToInt32(Session("FormMode"))
            hidFormMode.Text = _formMode
            Session("FormMode") = Nothing ' clear out session variable
        ElseIf hidFormMode.Text.Length > 0 Then
            _formMode = Convert.ToInt32(hidFormMode.Text)
        End If

        ' The ID is sent from the list page in session -- if it's an add, 0 is passed as the ID
        If Not Session("FormProductID") Is Nothing Then
            productID = Convert.ToInt32(Session("FormProductID"))
            Session("FormProductID") = Nothing ' clear out session variable
        Else ' check for the hidden value (could be switching between steps)
            If hidProductID.Text.Length > 0 Then
                productID = Convert.ToInt32(hidProductID.Text)
            End If
        End If

        ' TODO: CMS - Product Edit - For a new product, add default attribs that can't be deleted


        Dim editProduct As Product = Nothing
        ' if this is an edit, fill the entire wizard form
        If productID <> 0 Then
            If Not IsPostBack Then
                ' === Fill General Info Step ===
                editProduct = New Product(productID)
                With editProduct
                    .Fill()
                    txtProductName.Text = .ProductName
                    txtKeywords.Text = .ProductKeywords
                    txtBlurb.Text = .ProductBlurb
                    Dim edApprovals As HtmlEditor
                    edApprovals = Me.phApprovalsEditor.FindControl("edApprovals")
                    If Not edApprovals Is Nothing Then
                        edApprovals.Content = .ProductApprovals
                    End If
                    Me.ProductApprovalText = .ProductApprovals ' set viewstate item
                    dtePublishDate.SelectedDate = .PublishDate
                    dteExpireDate.SelectedDate = .ExpireDate
                    hidProductID.Text = .ProductID
                    ' set workflow control
                    ucWorkflowInfo.SetValues(editProduct)


                End With

                ' set product name labels for the other steps
                Me.lblProductNameStep2.Text = editProduct.ProductName.ToString
                Me.lblProductNameStep4.Text = editProduct.ProductName.ToString
                Me.lblProductNameStep3.Text = editProduct.ProductName.ToString



                ' === Fill Product Attributes Step ===
                ' n/a

            End If
        Else
            ' check form mode -- if read, then just redirect back to list
            If _formMode = CMSFormUtils.FormMode.Read Then
                Response.Redirect(ListPage)
            Else
                If Not IsPostBack Then ' only run this when first getting to this page
                    ' adding an item
                    ' hide workflow control
                    ucWorkflowInfo.Visible = False
                    ' default the publish date
                    dtePublishDate.SelectedDate = Today.Date
                End If
            End If
        End If


        ' if this is part of another job that's not live, make this read only
        If _formMode = CMSFormUtils.FormMode.Edit And editProduct IsNot Nothing Then
            If editProduct.JobID <> Me.ActiveJobID And editProduct.WorkflowStatus <> "LIVE" Then
                Me.hidGeneralInfoReadOnly.Text = "True"
            End If
        End If

        ' set the controls read only if form mode is read
        SetFormMode(_formMode)
    End Sub



    ''' <summary>
    ''' This sets the form mode based on mode specified
    ''' </summary>
    ''' <param name="mode"></param>
    ''' <remarks></remarks>
    Private Sub SetFormMode(ByVal mode As CMSFormUtils.FormMode)
        Select Case mode
            Case CMSFormUtils.FormMode.Edit
                SetControlEnabledProperty(True)
                Me.Master.PageTitle = "Add/Edit"
            Case CMSFormUtils.FormMode.Read
                SetControlEnabledProperty(False)
                Me.Master.PageTitle = "View"
        End Select
        Me.Master.PageTitle = Me.Master.PageTitle & " Product"
        ' set the cancel destination page
        wzForm.CancelDestinationPageUrl = ListPage
        ' set the finish button text/attribute
        ' but don't set the confirm message since the product info is actually
        ' saved via the "next" button, not the finish button
        CMSFormUtils.SetFinishButtonProperties(CType(wzForm.FindControl("FinishNavigationTemplateContainerID$FinishButton"), Button), _formMode, False)

    End Sub
    ''' <summary>
    ''' This sets just the General Info items for read only
    ''' Fixes "part of other job" issue
    ''' </summary>
    ''' <param name="enable"></param>
    ''' <remarks></remarks>
    Private Sub SetControlEnabledPropertyGeneralInfo(ByVal enable As Boolean)
        txtProductName.Enabled = enable
        txtKeywords.Enabled = enable
        txtBlurb.Enabled = enable

        ' disable the editors!

        Dim edApprovals As HtmlEditor = phApprovalsEditor.FindControl("edApprovals")
        If Not edApprovals Is Nothing Then
            If Not enable Then ' get rid of editor -- just display content
                Dim txtApprovals As String = edApprovals.Content
                phApprovalsEditor.Controls.Clear()
                phApprovalsEditor.Controls.Add(New LiteralControl("<div class=""readOnlyEditorContent"">" & Me.ProductApprovalText.ToString & "</div>"))
            End If
        End If
        dtePublishDate.Enabled = enable
        dteExpireDate.Enabled = enable
    End Sub

    ''' <summary>
    ''' This sets all of the user input controls enabled property
    ''' based on the parm value
    ''' </summary>
    ''' <param name="enable">True/False</param>
    ''' <remarks></remarks>
    Private Sub SetControlEnabledProperty(ByVal enable As Boolean)

        If Me.hidGeneralInfoReadOnly.Text = "True" Then ' make sure the make the general info stuff readonly
            SetControlEnabledPropertyGeneralInfo(False)
        Else
            SetControlEnabledPropertyGeneralInfo(enable) ' just use form_mode
        End If


        ' product attribs

        gvAttribValues.Columns(DeleteColumn).Visible = enable
        gvAttribValues.Columns(EditColumn).Visible = enable
        pnlAddEditAttribValue.Visible = enable

        ' search attribute -- hide the add section and the delete column of gridview
        pnlAddSearchAttrib.Visible = enable
        gvSearchAttribs.Columns(DeleteColumn).Visible = enable

        ' document -- hide the add section and the delete column of the gridview
        pnlAddDocument.Visible = enable
        gvDocuments.Columns(DeleteColumn).Visible = enable



    End Sub

    Protected Sub wzForm_FinishButtonClick(ByVal sender As Object, ByVal e As System.Web.UI.WebControls.WizardNavigationEventArgs) Handles wzForm.FinishButtonClick
        ' just go back to list page
        Response.Redirect(ListPage)
    End Sub

    Protected Sub wzForm_NextButtonClick(ByVal sender As Object, ByVal e As System.Web.UI.WebControls.WizardNavigationEventArgs) Handles wzForm.NextButtonClick
        ' save information on the step
        ' (only in edit mode)
        If _formMode = CMSFormUtils.FormMode.Edit And Me.hidGeneralInfoReadOnly.Text <> "True" Then
            Select Case wzForm.ActiveStepIndex
                Case 0 ' General Info -- save it before going somewhere else
                    If Not SaveProductInfo() Then
                        e.Cancel = True
                    End If


            End Select
        End If
    End Sub

 
#End Region

#Region " STEP 1 - GENERAL INFO "
    ''' <summary>
    ''' This will save the information on Step 1 - General Info 
    ''' (Name, Keywords, Blurb, Approvals)
    ''' </summary>
    ''' <remarks></remarks>
    Private Function SaveProductInfo() As Boolean
        If Me.txtProductName.Enabled Then ' know we can save the info 
            Dim saveProduct As New Product
            Dim success As Boolean
            Try
                ' if it's readonly here, don't save
                If _formMode = CMSFormUtils.FormMode.Edit Then
                    If Page.IsValid Then
                        With saveProduct
                            If Me.hidProductID.Text.Length > 0 Then
                                .ProductID = Convert.ToInt32(Me.hidProductID.Text)
                            End If
                            .BusUnitID = Session("BusUnitID")
                            .ProductName = Me.txtProductName.Text.Trim
                            .ProductKeywords = Me.txtKeywords.Text.Trim
                            Dim edApprovals As HtmlEditor = phApprovalsEditor.FindControl("edApprovals")
                            If Not edApprovals Is Nothing Then
                                .ProductApprovals = edApprovals.Content.Trim
                            End If
                            .ProductBlurb = Me.txtBlurb.Text.Trim
                            .PublishDate = dtePublishDate.SelectedDate
                            .ExpireDate = dteExpireDate.SelectedDate
                            ' TODO: CMS - Put in Job ID and User ID as args below
                            .JobID = Me.ActiveJobID
                            .LastModBy = Me.ActiveUserID
                            If .Save() Then
                                success = True
                                ' set the product id hidden form field
                                Me.hidProductID.Text = .ProductID.ToString
                                Me.lblProductNameStep2.Text = .ProductName.ToString
                                Me.lblProductNameStep3.Text = .ProductName.ToString
                                Me.lblProductNameStep4.Text = .ProductName.ToString
                                ' reset the workflow stuff
                                ' set workflow control
                                .Fill()
                                ucWorkflowInfo.SetValues(saveProduct)
                            Else
                                success = False
                                lblMessage.Text = "There was an error saving the Product."
                                lblMessage.CssClass = "errorMessage"
                            End If
                        End With
                    Else
                        success = False
                        lblMessage.Text = "The Product cannot be saved unless all invalid information is corrected."
                        lblMessage.CssClass = "errorMessage"
                    End If
                End If
            Catch ex As Exception
                If TypeOf ex Is NLTException Then
                    Throw ex
                Else
                    Throw New NLTException("Error saving Product.", ex, "cms/ProductEdit.aspx", "Private Function SaveProductInfo() As Boolean")
                End If
            End Try
            Return success
        End If

    End Function

    Private Sub BuildHtmlEditors()
        'WYSIWYG EDITOR CODE WHEN SUBMITTING FORM VIA LINK BUTTON
        'lbtnSendReport.Attributes.Add("onclick", "finish_wysiwyg_editing()")
        Dim edApprovals As New HtmlEditor
        With edApprovals
            .ID = "edApprovals"
            .ButtonFeatures = New String() { _
                "Print", "SpellCheck", "|", "Cut", "Copy", "Paste", "PasteWord", "|", "Undo", "Redo", "|", "Bookmark", "Hyperlink", "Image", "Characters", "|", "Table", "Guidelines", "|", "Numbering", "Bullets", "|", "Indent", "Outdent", "|", "RemoveFormat", "XHTMLSource", "ClearAll", "BRK", _
                "StyleAndFormatting", "TextFormatting", "ListFormatting", "BoxFormatting", "ParagraphFormatting", "CssText", "FontName", "FontSize", "|", "Bold", "Italic", "|", "JustifyLeft", "JustifyCenter", "JustifyRight", "JustifyFull"}
            '.Content = BuildBodyBeginning() & BuildSignature()
            .scriptPath = "scripts/"
            .spellCheckMode = "NetSpell"
            .btnSpellCheck = True
            .EditorHeight = "200"
            .EditorWidth = "300"
        End With
        phApprovalsEditor.Controls.Add(edApprovals)
    End Sub
#End Region

#Region " STEP 2 - PRODUCT ATTRIBUTES "
    Protected Sub btnSaveAttribValue_Click(ByVal sender As Object, ByVal e As System.EventArgs) Handles btnSaveAttribValue.Click
        ' add/edit the attrib value
        Dim prodAttribVal As New ProductAttributeValue

        With prodAttribVal
            ' get the id if this is an edit
            If hidProdAttribRelnID.Text.Length > 0 Then
                .ProdAttribRelnID = Services.GetNULLableInteger(hidProdAttribRelnID.Text)
            End If
            If ddlAttribute.Visible Then
                .AttribType.AttribID = Services.GetNULLableInteger(ddlAttribute.SelectedValue)
            Else 'get hidden value 
                .AttribType.AttribID = Services.GetNULLableInteger(hidAttribTypeID.Text)
            End If

            .ProductID = Services.GetNULLableInteger(hidProductID.Text)
            ' don't forget to store the these values (from the general info step)
            .PublishDate = dtePublishDate.SelectedDate
            .ExpireDate = dteExpireDate.SelectedDate
            ' TODO: CMS - Put in Job ID and User ID as args below
            .JobID = Me.ActiveJobID
            .LastModBy = Me.ActiveUserID

            ' now find out if a single or multiple values are being saved
            If rdoNewValue.Checked Or Not lstValues.Visible Then ' single value
                Select Case True
                    Case rdoNewValue.Checked
                        .AttribValue = txtNewValue.Text
                    Case rdoExistingValue.Checked
                        .AttribValue = ddlValues.SelectedValue
                End Select
                If .Save() Then
                    ' re-bind the grid
                    gvAttribValues.DataBind()
                End If
            Else ' save multiple attributes -- should this be a transaction? for now, they'll be saved singly
                Dim li As ListItem
                For Each li In lstValues.Items
                    If li.Selected Then
                        .ProdAttribRelnID = 0 ' reset id to save a new one
                        .AttribValue = li.Value
                        .Save()
                    End If
                Next
                ' re-bind the grid
                gvAttribValues.DataBind()
            End If
        End With

        ResetAttributeValueForm()


    End Sub

    Protected Sub ddlAttribute_PreRender(ByVal sender As Object, ByVal e As System.EventArgs) Handles ddlAttribute.PreRender
        ' add dummy initial item to attrib name dropdown list on Attribute step
        ' if it's not there already
        With ddlAttribute
            If .Items.Count > 0 Then
                If .Items(0).Value <> "0" Then
                    Dim li As New ListItem("-- Select Attribute --", "0")
                    .Items.Insert(0, li)
                End If
            End If
        End With
    End Sub

    Protected Sub ddlAttribute_SelectedIndexChanged(ByVal sender As Object, ByVal e As System.EventArgs) Handles ddlAttribute.SelectedIndexChanged

        Dim attrib As New ProductAttribute(Convert.ToInt32(ddlAttribute.SelectedValue))
        If attrib.AttribID <> 0 Then
            attrib.Fill()
            Dim attribVal As New ProductAttributeValue
            Dim dt As DataTable = attribVal.GetDistinctListByAttribute(attrib.AttribID)

            If dt.Rows.Count > 0 Then
                'reset enter new/select existing value radio buttons
                rdoExistingValue.Visible = True
                rdoExistingValue.Checked = False
                rdoNewValue.Checked = False
                rdoNewValue.Visible = True
                txtNewValue.Visible = True

                If attrib.AllowMultiple Then
                    ' show the list box
                    With lstValues
                        .Visible = True
                        .DataSource = dt
                        .DataTextField = "AttribValue"
                        .DataValueField = "AttribValue"
                        .DataBind()
                    End With
                    'lstValues.DataBind()
                    ddlValues.Visible = False
                Else

                    With ddlValues
                        .Visible = True
                        .DataSource = dt
                        .DataTextField = "AttribValue"
                        .DataValueField = "AttribValue"
                        .DataBind()
                    End With
                    ' show the dropdown
                    lstValues.Visible = False
                End If
            Else
                ' don't show this option
                rdoExistingValue.Checked = False
                rdoExistingValue.Visible = False
                lstValues.Visible = False
                ddlValues.Visible = False
                ' hide the enter new value radio, too
                rdoNewValue.Checked = True
                lblValue.Visible = True
                txtNewValue.Visible = True
            End If

            ' show buttons
            btnSaveAttribValue.Visible = True
            btnCancelSaveAttrib.Visible = True
        Else ' reset form
            ResetAttributeValueForm()
        End If



    End Sub

    Protected Sub gvAttribValues_RowCommand(ByVal sender As Object, ByVal e As System.Web.UI.WebControls.GridViewCommandEventArgs) Handles gvAttribValues.RowCommand
        ' If multiple ButtonField column fields are used, use the
        ' CommandName property to determine which button was clicked.

        Select Case e.CommandName
            Case "EditItem"
                ' Get the ID to be edited
                Dim editAttribValue As New ProductAttributeValue(Convert.ToInt32(e.CommandArgument))
                With editAttribValue
                    .Fill()
                    If .AttribValue.Length > 0 Then
                        ' set form values
                        lblAttributeName.Text = .AttribType.AttribName
                        lblAttributeName.Visible = True
                        txtNewValue.Text = .AttribValue
                        txtNewValue.Visible = True
                        lblValue.Visible = True
                        rdoNewValue.Checked = True
                        rdoNewValue.Visible = False

                        ' set title/button
                        lblAttributeValue.Text = "Edit Attribute Value"
                        lblAttributeValue.CssClass = "subFormTitle"
                        btnSaveAttribValue.Text = "Edit Attribute Value"

                        ' show buttons
                        btnSaveAttribValue.Visible = True
                        btnCancelSaveAttrib.Visible = True

                        ' set hidden fields
                        hidAttribTypeID.Text = .AttribType.AttribID
                        hidProdAttribRelnID.Text = .ProdAttribRelnID

                        ' hide the existing value stuff
                        ddlAttribute.Visible = False
                        rdoExistingValue.Checked = False
                        rdoExistingValue.Visible = False
                        ddlValues.Items.Clear()
                        ddlValues.Visible = False
                        lstValues.Items.Clear()
                        lstValues.Visible = False
                    Else
                        ' error retrieving attribute value
                    End If
                End With
            Case "DeleteItem"
                Dim delProdAttribValue As New ProductAttributeValue(Convert.ToInt32(e.CommandArgument))
                With delProdAttribValue
                    .JobID = Me.ActiveJobID
                    .LastModBy = Me.ActiveUserID
                    If .Delete() Then
                        lblMessage.Text = "The product attribute value has been deleted."
                        lblMessage.CssClass = "infoMessage"
                        ' refresh grid
                        ' re-bind the grid
                        gvAttribValues.DataBind()
                        ResetAttributeValueForm()
                    End If

                End With
        End Select
    End Sub

    Protected Sub gvAttribValues_RowDataBound(ByVal sender As Object, ByVal e As System.Web.UI.WebControls.GridViewRowEventArgs) Handles gvAttribValues.RowDataBound
        'TODO: CMS - Product Attribute - ADD CAPABILITY CHECK FOR ALLOWING DELETE/EDIT BUTTONS TO DISPLAY

        ' this adds a confirmation message to the delete command
        If e.Row.RowType = DataControlRowType.DataRow Then
            Dim attribText As String = DataBinder.Eval(e.Row.DataItem, "AttribName") & " - " & _
              DataBinder.Eval(e.Row.DataItem, "AttribValue")

            ' replace any apostrophes
            attribText = attribText.Replace("'", "\'")

            Dim ibtnDelete As ImageButton = e.Row.FindControl("ibtnDelete")
            ibtnDelete.Attributes.Add("onclick", "javascript:return " & _
              "confirm('Are you sure you want to delete " & _
              attribText & "?')")


            ' hide the edit/delete button for item that is marked for deletion or marked as read only
            If Convert.ToBoolean(DataBinder.Eval(e.Row.DataItem, "MarkedForDeletion")) Then
                e.Row.Cells(EditColumn).Text = CMSGlobals.BlankIcon
                e.Row.Cells(DeleteColumn).Text = CMSGlobals.BlankIcon
            End If

            ' -- part of other job check --
            ' if the item is part of another job and in non-LIVE status, then hide edit/delete icons
            If Convert.ToInt32(DataBinder.Eval(e.Row.DataItem, "DeploymentJobID")) <> _
                    Me.ActiveJobID And _
                DataBinder.Eval(e.Row.DataItem, "WorkflowStatus").ToString <> "LIVE" Then
                e.Row.Cells(EditColumn).Text = CMSGlobals.BlankIcon
                e.Row.Cells(DeleteColumn).Text = CMSGlobals.BlankIcon
            End If

            ' if there's no active job, then hide delete/edit icons
            If Me.ActiveJobID = 0 Then
                e.Row.Cells(EditColumn).Text = CMSGlobals.BlankIcon
                e.Row.Cells(DeleteColumn).Text = CMSGlobals.BlankIcon
            End If
        End If


    End Sub

    Sub ResetAttributeValueForm()
        ' now clear out the form
        lblAttributeName.Text = String.Empty
        lblAttributeName.Visible = False
        ddlAttribute.Visible = True
        If ddlAttribute.Items.Count > 0 Then
            ddlAttribute.SelectedIndex = 0
        End If
        lblValue.Visible = False
        rdoNewValue.Checked = False
        rdoNewValue.Visible = False
        txtNewValue.Text = String.Empty
        txtNewValue.Visible = False
        rdoExistingValue.Checked = False
        rdoExistingValue.Visible = False
        ddlValues.Items.Clear()
        ddlValues.Visible = False
        lstValues.Items.Clear()
        lstValues.Visible = False
        ' set title/button
        lblAttributeValue.Text = "Add Attribute Value"
        lblAttributeValue.CssClass = "subFormTitle"
        btnSaveAttribValue.Text = "Add Attribute Value"

        ' hide buttons
        btnSaveAttribValue.Visible = False
        btnCancelSaveAttrib.Visible = False

        ' set hidden fields
        hidAttribTypeID.Text = String.Empty
        hidProdAttribRelnID.Text = String.Empty

    End Sub

    Protected Sub btnCancelSaveAttrib_Click(ByVal sender As Object, ByVal e As System.EventArgs) Handles btnCancelSaveAttrib.Click
        ResetAttributeValueForm()
    End Sub
#End Region

#Region " STEP 3 - SEARCH ATTRIBUTES "
    Protected Sub gvSearchAttribs_RowCommand(ByVal sender As Object, ByVal e As System.Web.UI.WebControls.GridViewCommandEventArgs) Handles gvSearchAttribs.RowCommand
        ' If multiple ButtonField column fields are used, use the
        ' CommandName property to determine which button was clicked.

        Select Case e.CommandName
            Case "EditItem" ' can only add/delete search attribs
            Case "DeleteItem"
                Dim delProdSearchAttribReln As New ProductSearchAttributeReln(Convert.ToInt32(e.CommandArgument))
                With delProdSearchAttribReln
                    .JobID = Me.ActiveJobID
                    .LastModBy = Me.ActiveUserID
                    If .Delete() Then
                        lblMessage.Text = "The product search attribute relationship has been deleted or marked for deletion."
                        lblMessage.CssClass = "infoMessage"
                        ' refresh grid
                        gvSearchAttribs.DataBind()
                        ' also refresh listbox
                        lstSearchAttrib.DataBind()
                    End If

                End With
        End Select
    End Sub

    Protected Sub gvSearchAttribs_RowDataBound(ByVal sender As Object, ByVal e As System.Web.UI.WebControls.GridViewRowEventArgs) Handles gvSearchAttribs.RowDataBound
        'TODO: CMS - Product search Attribute - ADD CAPABILITY CHECK FOR ALLOWING DELETE/EDIT BUTTONS TO DISPLAY

        ' this adds a confirmation message to the delete command
        If e.Row.RowType = DataControlRowType.DataRow Then

            Dim searchAttributeName As String = DataBinder.Eval(e.Row.DataItem, "SearchAttributeName")
            ' replace any apostrophes
            searchAttributeName = searchAttributeName.Replace("'", "\'")

            Dim ibtnDelete As ImageButton = e.Row.FindControl("ibtnDelete")
            ibtnDelete.Attributes.Add("onclick", "javascript:return " & _
              "confirm('Are you sure you want to delete " & _
              searchAttributeName & "?')")

            ' hide the edit/delete button for item that is marked for deletion or marked as read only
            If Convert.ToBoolean(DataBinder.Eval(e.Row.DataItem, "MarkedForDeletion")) Then
                e.Row.Cells(EditColumn).Text = CMSGlobals.BlankIcon
                e.Row.Cells(DeleteColumn).Text = CMSGlobals.BlankIcon
            End If

            ' -- part of other job check --
            ' if the item is part of another job and in non-LIVE status, then hide edit/delete icons
            If Convert.ToInt32(DataBinder.Eval(e.Row.DataItem, "DeploymentJobID")) <> _
                    Me.ActiveJobID And _
                DataBinder.Eval(e.Row.DataItem, "WorkflowStatus").ToString <> "LIVE" Then
                e.Row.Cells(EditColumn).Text = CMSGlobals.BlankIcon
                e.Row.Cells(DeleteColumn).Text = CMSGlobals.BlankIcon
            End If

            ' if there's no active job, then hide delete/edit icons
            If Me.ActiveJobID = 0 Then
                e.Row.Cells(EditColumn).Text = CMSGlobals.BlankIcon
                e.Row.Cells(DeleteColumn).Text = CMSGlobals.BlankIcon
            End If
        End If



    End Sub

    Protected Sub ddlMarket_PreRender(ByVal sender As Object, ByVal e As System.EventArgs) Handles ddlMarket.PreRender
        ' add item to market name dropdown list on search attribute step -- for All Markets
        ' if it's not there already
        With ddlMarket
            If .Items.Count > 0 Then
                If .Items(0).Value <> "0" Then
                    Dim li As New ListItem("All Markets", "0")
                    .Items.Insert(0, li)
                End If
            End If
        End With
    End Sub

    Sub SaveSearchAttribInfo()
        ' get list of existing search attribs
        Dim dtExisting As DataTable
        Dim reln As New ProductSearchAttributeReln
        dtExisting = reln.GetList(0, Convert.ToInt32(Me.hidProductID.Text))




        ' compare it with items in list box
    End Sub

    Protected Sub btnSaveSearchAttrib_Click(ByVal sender As Object, ByVal e As System.EventArgs) Handles btnAddSearchAttrib.Click
        Dim li As ListItem
        Dim reln As New ProductSearchAttributeReln
        With reln
            .ProductID = Convert.ToInt32(hidProductID.Text)
            ' don't forget to store the these values (from the general info step)
            .PublishDate = dtePublishDate.SelectedDate
            .ExpireDate = dteExpireDate.SelectedDate
            ' TODO: CMS - Put in Job ID and User ID as args below
            .JobID = Me.ActiveJobID
            .LastModBy = Me.ActiveUserID
            For Each li In lstSearchAttrib.Items
                If li.Selected Then
                    .ProdSearchAttribRelnID = 0 ' reset id to save a new one
                    .SearchAttribTypeID = Convert.ToInt32(li.Value)
                    .Save()
                End If
            Next
        End With
        ' refresh grid
        gvSearchAttribs.DataBind()
        ' also refresh listbox
        lstSearchAttrib.DataBind()
    End Sub

#End Region

#Region " STEP 4 - DOCUMENTS "
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

    Protected Sub btnSaveDoc_Click(ByVal sender As Object, ByVal e As System.EventArgs) Handles btnSaveDoc.Click
        Dim doc As New Document
        With doc
            If Me.hidDocumentID.Text.length > 0 Then
                .DocumentId = Me.hidDocumentID.Text
            End If

            .ProductId = Convert.ToInt32(Me.hidProductID.Text)
            .DocTitle = Me.txtDocTitle.Text
            .ContentType = Me.ddlDocContentType.SelectedValue.ToString
            .RegionId = Convert.ToInt32(Me.ddlDocRegion.SelectedValue)
            .DocPath = Me.hidExistingDocPath.Text ' this may get overwritten by a new upload file (that's ok)
            .UploadDate = Services.GetNULLableDateTime(Me.hidDocUploadDate.Text) ' this may get overwritten by a new upload file (that's ok)
            ' don't forget to store the these values (from the general info step)
            .PublishDate = dtePublishDate.SelectedDate
            .ExpireDate = dteExpireDate.SelectedDate
            .JobID = Me.ActiveJobID
            .LastModBy = Me.ActiveUserID
            ' find out whether the doc should be stored in a secure folder
            Dim bu As New BusinessUnit(Convert.ToInt32(Session("BusUnitID")))
            bu.Fill(WorkflowItem.LiveMode.CMS)

            If .UploadDocument(Me.fupDoc, bu.DocAuth) Then
                If .Save() Then
                    gvDocuments.DataBind()
                    ResetDocumentForm()
                Else
                    ' show error!
                End If
            Else
                ' show error!


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
        Dim selectedItem As ListItem = Me.ddlDocRegion.Items.FindByValue("1")
        If selectedItem IsNot Nothing Then
            selectedItem.Selected = True
        End If
    End Sub

    Protected Sub gvDocuments_RowCommand(ByVal sender As Object, ByVal e As System.Web.UI.WebControls.GridViewCommandEventArgs) Handles gvDocuments.RowCommand
        ' If multiple ButtonField column fields are used, use the
        ' CommandName property to determine which button was clicked.

        Select Case e.CommandName
            Case "EditItem"
                ' Get the ID to be edited
                Dim editDoc As New Document(Services.GetNULLableInteger(e.CommandArgument))
                With editDoc
                    .Fill(0) 'live mode=0
                    If .DocPath.Length > 0 Then
                        Me.txtDocTitle.Text = .DocTitle
                        Me.ddlDocRegion.SelectedValue = .RegionId.ToString
                        Me.ddlDocContentType.SelectedValue = .ContentType.ToString
                        Me.hidExistingDocPath.Text = .DocPath
                        Me.hidDocUploadDate.Text = .UploadDate.ToShortDateString
                        Me.lnkDoc.Target = "_blank"
                        Me.lnkDoc.NavigateUrl = .DocPath
                        Me.lnkDoc.Text = .DocTitle
                        Me.hidDocumentID.Text = .DocumentId
                        ' set title/button
                        lblAddEditDoc.Text = "Edit Document"
                        btnSaveDoc.Text = "Edit Document"

                        ' show buttons
                        btnSaveAttribValue.Visible = True
                        btnCancelSaveAttrib.Visible = True
                    End If
                End With
            Case "DeleteItem"
                Dim delDoc As New Document(Convert.ToInt32(e.CommandArgument))

                With delDoc
                    .Fill(0)
                    .JobID = Me.ActiveJobID
                    .LastModBy = Me.ActiveUserID
                    If .Delete() Then
                        lblMessage.Text = "The document has been deleted or marked for deletion."
                        lblMessage.CssClass = "infoMessage"
                        ' refresh grid
                        ' re-bind the grid
                        gvDocuments.DataBind()
                        ResetDocumentForm()
                    End If

                End With
        End Select
    End Sub

    Protected Sub gvDocuments_RowDataBound(ByVal sender As Object, ByVal e As System.Web.UI.WebControls.GridViewRowEventArgs) Handles gvDocuments.RowDataBound


        ' this adds a confirmation message to the delete command
        If e.Row.RowType = DataControlRowType.DataRow Then

            Dim docTitle As String = DataBinder.Eval(e.Row.DataItem, "DocTitle")
            If docTitle IsNot Nothing Then
                ' replace any apostrophes
                docTitle = docTitle.Replace("'", "\'")
            End If

            Dim ibtnDelete As ImageButton = e.Row.FindControl("ibtnDelete")
            ibtnDelete.Attributes.Add("onclick", "javascript:return " & _
              "confirm('Are you sure you want to delete " & _
              docTitle & "?')")

            Dim lnk As HyperLink = TryCast(e.Row.FindControl("lnkDocument"), HyperLink)
            With lnk
                .Text = Services.GetNULLableString(DataBinder.Eval(e.Row.DataItem, "DocTitle"))
                .NavigateUrl = "~/" & Services.GetNULLableString(DataBinder.Eval(e.Row.DataItem, "DocPath"))
                .Target = "_blank"
            End With

            ' hide the edit/delete button for item that is marked for deletion
            If Convert.ToBoolean(DataBinder.Eval(e.Row.DataItem, "MarkedForDeletion")) Then
                e.Row.Cells(EditColumn).Text = CMSGlobals.BlankIcon
                e.Row.Cells(DeleteColumn).Text = CMSGlobals.BlankIcon
            End If

            ' -- part of other job check --
            ' if the item is part of another job and in non-LIVE status, then hide edit/delete icons
            If Convert.ToInt32(DataBinder.Eval(e.Row.DataItem, "DeploymentJobID")) <> _
                    Me.ActiveJobID And _
                DataBinder.Eval(e.Row.DataItem, "WorkflowStatus").ToString <> "LIVE" Then
                e.Row.Cells(EditColumn).Text = CMSGlobals.BlankIcon
                e.Row.Cells(DeleteColumn).Text = CMSGlobals.BlankIcon
            End If

            ' if there's no active job, then hide delete/edit icons
            If Me.ActiveJobID = 0 Then
                e.Row.Cells(EditColumn).Text = CMSGlobals.BlankIcon
                e.Row.Cells(DeleteColumn).Text = CMSGlobals.BlankIcon
            End If
        End If
    End Sub

    Sub ResetDocumentForm()
        ' now clear out the form
        Me.txtDocTitle.Text = String.Empty


        Me.ddlDocContentType.SelectedIndex = 0
        Me.lnkDoc.Target = String.Empty
        Me.lnkDoc.NavigateUrl = String.Empty
        Me.lnkDoc.Text = "(none)"
        Me.hidDocumentID.Text = String.Empty

        ' set title/button
        lblAddEditDoc.Text = "Add Document"
        lblAddEditDoc.CssClass = "subFormTitle"
        btnSaveDoc.Text = "Add Document"

        ' hide buttons
        'btnSaveAttribValue.Visible = False
        'btnCancelSaveAttrib.Visible = False

        ' set hidden fields
        hidDocumentID.Text = String.Empty

    End Sub

    Protected Sub btnCancelSaveDoc_Click(ByVal sender As Object, ByVal e As System.EventArgs) Handles btnCancelSaveDoc.Click
        ResetDocumentForm()
    End Sub
#End Region

End Class
