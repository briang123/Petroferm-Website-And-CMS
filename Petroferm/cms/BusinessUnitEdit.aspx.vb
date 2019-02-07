
Partial Class CmsBusinessUnitEdit
    Inherits CMSPage
    Private _formMode As CMSFormUtils.FormMode = CMSFormUtils.FormMode.Read 'default to read
    Private Const ListPage As String = "BusinessUnitList.aspx"
    Private Const DeleteColumn As Integer = 0
    Private Const EditColumn As Integer = 1

    ''' <summary>
    ''' This property stores a value in viewstate for editing product categories
    ''' </summary>
    ''' <value></value>
    ''' <returns></returns>
    ''' <remarks></remarks>
    Property CurrentProductCategoryId() As Integer
        Get
            If ViewState("CurrentProductCategoryID") IsNot Nothing Then
                Return ViewState("CurrentProductCategoryID")
            Else
                Return 0
            End If

        End Get
        Set(ByVal value As Integer)
            ViewState("CurrentProductCategoryID") = value
        End Set
    End Property

    Property CurrentBusinessUnitId() As Integer
        Get
            If ViewState("CurrentBusinessUnitID") IsNot Nothing Then
                Return ViewState("CurrentBusinessUnitID")
            Else
                Return 0
            End If

        End Get
        Set(ByVal value As Integer)
            ViewState("CurrentBusinessUnitID") = value
            ' also set bu obj in view state (this was added later on) -- we'll probably want to clean this up
            'also set hidden id
            Me.hidBusUnitID.Text = value
        End Set
    End Property

    Protected Sub Page_Load(ByVal sender As Object, ByVal e As System.EventArgs) Handles Me.Load


        Dim busUnitId As Integer

        If Not Session("FormMode") Is Nothing Then
            _formMode = Convert.ToInt32(Session("FormMode"))
            hidFormMode.Text = _formMode
            Session("FormMode") = Nothing ' clear out session variable
        ElseIf hidFormMode.Text.Length > 0 Then
            _formMode = Convert.ToInt32(hidFormMode.Text)
        End If
        SetFormMode(_formMode)

        ' The ID is sent from the list page in session -- if it's an add, 0 is passed as the ID
        If Not Session("FormBusUnitID") Is Nothing Then
            busUnitID = Convert.ToInt32(Session("FormBusUnitID"))
            Session("FormBusUnitID") = Nothing ' clear out session variable
            Me.CurrentBusinessUnitID = busUnitID
        End If

        ' set image module user control to LOGO
        ucImageEdit.ImageType = "LOGO"

        If Not IsPostBack Then
            Me.wzForm.ActiveStepIndex = 0

            Dim editBus As BusinessUnit
            ' if this is an edit (busUnitID <> 0), get the bus unit info and fill the form
            If busUnitID > 0 Then
                editBus = New BusinessUnit(busUnitID)
                With editBus
                    .Fill(False)
                    txtBusinessUnitName.Text = .BusName
                    chkDocAuth.Checked = .DocAuth
                    dtePublishDate.SelectedDate = .PublishDate
                    dteExpireDate.SelectedDate = .ExpireDate
                    ucImageEdit.CurrentBusinessLogoImage = editBus.LogoImage

                    hidBusUnitID.Text = .BusUnitID
                    ' set workflow control
                    ucWorkflowInfo.SetValues(editBus)
                End With
            Else
                ' check form mode -- if read, then just redirect back to list
                If _formMode = CMSFormUtils.FormMode.Read Then
                    Response.Redirect(ListPage)
                Else
                    ' hide workflow control
                    ucWorkflowInfo.Visible = False
                    ' adding a bus unit
                    ' default the publish date
                    dtePublishDate.SelectedDate = Today.Date
                End If
            End If
            ' set logo control values here (for both add and edit)
            ucImageEdit.SetFormValues()
        End If


    End Sub

    Protected Sub wzForm_NextButtonClick(ByVal sender As Object, ByVal e As System.Web.UI.WebControls.WizardNavigationEventArgs) Handles wzForm.NextButtonClick
        ' save information on the step
        ' (only in edit mode)
        'If FORM_MODE = CMSFormUtils.FormMode.Edit And Me.hidGeneralInfoReadOnly.Text <> "True" Then
        If _formMode = CMSFormUtils.FormMode.Edit Then
            Select Case wzForm.ActiveStepIndex
                Case 0, 1 ' General Info/Logo -- save it before going somewhere else
                    If Not SaveBUGeneralInfo() Then
                        e.Cancel = True
                    End If
            End Select
        End If
    End Sub

    Protected Sub wzForm_ActiveStepChanged(ByVal sender As Object, ByVal e As System.EventArgs) Handles wzForm.ActiveStepChanged

        Select Case wzForm.ActiveStepIndex
            Case 0


            Case 1
                Me.ucImageEdit.ImageType = "LOGO"
        End Select
    End Sub

    Protected Sub wzForm_FinishButtonClick(ByVal sender As Object, ByVal e As System.Web.UI.WebControls.WizardNavigationEventArgs) Handles wzForm.FinishButtonClick
        Response.Redirect(ListPage)
    End Sub

    Function SaveBuGeneralInfo() As Boolean
        Dim bu As New BusinessUnit(Me.CurrentBusinessUnitID)
        Dim success As Boolean = False
        ' Set BU values
        With bu
            .BusName = txtBusinessUnitName.Text.Trim
            .DocAuth = chkDocAuth.Checked
            .PublishDate = dtePublishDate.SelectedDate
            If dteExpireDate.SelectedDate <> #12:00:00 AM# Then
                .ExpireDate = dteExpireDate.SelectedDate
            End If
            Me.ucImageEdit.GetFormValues()
            .LogoImage = ucImageEdit.CurrentBusinessLogoImage
            .LogoImage.AltText = .BusName
            .JobID = Me.ActiveJobID
            .LastModBy = Me.ActiveUserID

            ' if it fails, don't save anything
            If DirectCast(ucImageEdit.FindControl("rdoUpload"), RadioButton).Checked Then
                If ucImageEdit.UploadImage(bu.LogoImage, "") Then

                    .LogoImage = ucImageEdit.CurrentBusinessLogoImage
                    .LogoImage.AltText = .BusName
                    If bu.Save() Then
                        ' make sure to set the current bus unit id
                        Me.CurrentBusinessUnitID = bu.BusUnitID
                        success = True
                    Else
                        lblMessage.Text = "There was an error saving the Business Unit."
                        lblMessage.CssClass = "errorMessage"
                    End If
                End If
            Else ' using existing or current image
                If bu.Save() Then
                    Me.CurrentBusinessUnitID = bu.BusUnitID
                    success = True
                Else
                    lblMessage.Text = "There was an error saving the Business Unit."
                    lblMessage.CssClass = "errorMessage"
                End If
            End If
        End With
        Return success = True
    End Function

    ''' <summary>
    ''' This sets the form mode based on mode specified
    ''' </summary>
    ''' <param name="mode"></param>
    ''' <remarks></remarks>
    Sub SetFormMode(ByVal mode As CMSFormUtils.FormMode)
        Select Case mode
            Case CMSFormUtils.FormMode.Edit
                SetControlEnabledProperty(True)
                Me.ucImageEdit.SetControlEnabledProperty(True)
                Me.Master.PageTitle = "Add/Edit"
            Case CMSFormUtils.FormMode.Read
                SetControlEnabledProperty(False)
                Me.ucImageEdit.SetControlEnabledProperty(False)
                Me.Master.PageTitle = "View"
        End Select

        Me.Master.PageTitle = Me.Master.PageTitle & " Business Unit"

        ' set the cancel destination page
        wzForm.CancelDestinationPageUrl = ListPage
        ' set the finish button text/attribute
        CMSFormUtils.SetFinishButtonProperties(CType(wzForm.FindControl("FinishNavigationTemplateContainerID$FinishButton"), Button), _formMode)
    End Sub

    ''' <summary>
    ''' This sets all of the user input controls enabled property
    ''' based on the parm value
    ''' </summary>
    ''' <param name="enable">True/False</param>
    ''' <remarks></remarks>
    Sub SetControlEnabledProperty(ByVal enable As Boolean)
        txtBusinessUnitName.Enabled = enable
        chkDocAuth.Enabled = enable
        dtePublishDate.Enabled = enable
        dteExpireDate.Enabled = enable
        pnlAddEditProductCategory.Visible = enable
        gvProductCategories.Columns(DeleteColumn).Visible = enable
        gvProductCategories.Columns(EditColumn).Visible = enable
    End Sub


#Region " STEP 3 - PRODUCT CATEGORIES "

    Protected Sub btnSaveProductCategory_Click(ByVal sender As Object, ByVal e As System.EventArgs) Handles btnSaveProductCategory.Click
        Dim prodCat As New ProductCategory(Me.CurrentProductCategoryID)
        With prodCat
            .BusinessUnitID = Me.CurrentBusinessUnitID
            .CategoryName = Me.txtProductCategory.Text.Trim
            .CategoryOrder = Services.GetNULLableInteger(Me.txtProdCatOrder.Text)

            ' don't forget to store the these values (from the general info step)
            .PublishDate = dtePublishDate.SelectedDate
            .ExpireDate = dteExpireDate.SelectedDate
            ' TODO: CMS - Put in Job ID and User ID as args below
            .JobID = Me.ActiveJobID
            .LastModBy = Me.ActiveUserID

            If .Save() Then
                ' re-bind the grid
                gvProductCategories.DataBind()
            End If

        End With
        ResetProductCategoryForm()
    End Sub

    Protected Sub gvProductCategories_RowCommand(ByVal sender As Object, ByVal e As System.Web.UI.WebControls.GridViewCommandEventArgs) Handles gvProductCategories.RowCommand
        ' If multiple ButtonField column fields are used, use the
        ' CommandName property to determine which button was clicked.

        Select Case e.CommandName
            Case "EditItem"
                ' Get the ID to be edited
                Dim editProdCat As New ProductCategory(Convert.ToInt32(e.CommandArgument))
                With editProdCat
                    .Fill()
                    If .CategoryName.Length > 0 Then
                        Me.txtProductCategory.Text = .CategoryName
                        Me.txtProdCatOrder.Text = .CategoryOrder
                        Me.CurrentProductCategoryID = .CategoryID

                        ' set title/button
                        lblProductCategory.Text = "Edit Product Category"
                        lblProductCategory.CssClass = "subFormTitle"
                        btnSaveProductCategory.Text = "Edit Product Category"

                    End If
                End With

                ' show buttons
                btnSaveProductCategory.Visible = True
                btnCancelSaveProdCat.Visible = True

            Case "DeleteItem"
                Dim delProdCat As New ProductCategory(Convert.ToInt32(e.CommandArgument))
                With delProdCat
                    .JobID = Me.ActiveJobID
                    .LastModBy = Me.ActiveUserID
                    If .Delete() Then
                        lblMessage.Text = "The product category has been deleted or marked for deletion."
                        lblMessage.CssClass = "infoMessage"
                        ' refresh grid
                        ' re-bind the grid
                        gvProductCategories.DataBind()
                        ResetProductCategoryForm()
                    End If

                End With
        End Select
    End Sub

    Protected Sub gvProductCategories_RowDataBound(ByVal sender As Object, ByVal e As System.Web.UI.WebControls.GridViewRowEventArgs) Handles gvProductCategories.RowDataBound
        'TODO: CMS - Product Attribute - ADD CAPABILITY CHECK FOR ALLOWING DELETE/EDIT BUTTONS TO DISPLAY

        ' this adds a confirmation message to the delete command
        If e.Row.RowType = DataControlRowType.DataRow Then
            Dim categoryName As String = DataBinder.Eval(e.Row.DataItem, "CategoryName")

            ' replace any apostrophes
            categoryName = categoryName.Replace("'", "\'")

            Dim ibtnDelete As ImageButton = e.Row.FindControl("ibtnDelete")
            ibtnDelete.Attributes.Add("onclick", "javascript:return " & _
              "confirm('Are you sure you want to delete " & _
              categoryName & "?')")


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

    Sub ResetProductCategoryForm()
        ' now clear out the form
        Me.txtProdCatOrder.Text = String.Empty
        Me.txtProductCategory.Text = String.Empty

        ' set title/button
        lblProductCategory.Text = "Add Product Category"
        lblProductCategory.CssClass = "subFormTitle"
        Me.btnSaveProductCategory.Text = "Add Product Category"

        ' reset viewstate property for cat id
        Me.CurrentProductCategoryID = 0
    End Sub

    Protected Sub btnCancelSaveProdCat_Click(ByVal sender As Object, ByVal e As System.EventArgs) Handles btnCancelSaveProdCat.Click
        ResetProductCategoryForm()
    End Sub
#End Region





    

End Class
