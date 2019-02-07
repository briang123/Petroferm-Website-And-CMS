
Partial Class CmsUserEdit
    Inherits CMSPage

    Private _formMode As CMSFormUtils.FormMode = CMSFormUtils.FormMode.Read 'default to read
    Private Const ListPage As String = "UserList.aspx"

    Public Property DoCreateNewUser() As Boolean
        Get
            Dim o As Object = ViewState("DoCreateNewUser")
            If o Is Nothing Then
                Return False
            Else
                Return CType(o, Boolean)
            End If
        End Get
        Set(ByVal value As Boolean)
            ViewState("DoCreateNewUser") = value
        End Set
    End Property

    Public Property UserNameVs() As String
        Get
            Dim o As Object = ViewState("UserName")
            If o Is Nothing Then
                Return String.Empty
            Else
                Return CType(o, String)
            End If
        End Get
        Set(ByVal value As String)
            ViewState("UserName") = value
        End Set
    End Property

    Sub New()
        DoCreateNewUser = True
    End Sub

    Protected Sub Page_Load(ByVal sender As Object, ByVal e As System.EventArgs) Handles Me.Load

        'If Session("FormUserId") IsNot Nothing Then
        '    If CType(Session("FormUserId"), Integer) > 0 Then
        '        DoCreateNewUser = False
        '    Else
        '        DoCreateNewUser = True
        '    End If
        '    Session("FormUserId") = Nothing
        'End If

        Me.Master.HideBusinessUnitDropdown()
        Me.Master.HideJobDropdown()

        If Session("FormUserName") IsNot Nothing Then
            UserNameVS = Session("FormUserName").ToString
            DoCreateNewUser = False
        Else
            DoCreateNewUser = True
            UserNameVS = Me.UserName.Text
        End If

        If Not Session("FormMode") Is Nothing Then
            _formMode = Convert.ToInt32(Session("FormMode"))
            hidFormMode.Text = _formMode
            Session("FormMode") = Nothing ' clear out session variable
        ElseIf hidFormMode.Text.Length > 0 Then
            _formMode = Convert.ToInt32(hidFormMode.Text)
        End If
        SetFormMode(_formMode)

        Dim userName As String = UserNameVS 'CType(Session("FormUserName"), String)

        If DoCreateNewUser Then
            Me.UserName.Enabled = True
        Else
            Me.UserName.Enabled = False
        End If

        Dim memUser As MembershipUser = Membership.GetUser(UserName)

        If IsPostBack = False Then

            Me.wzForm.ActiveStepIndex = 0
            Dim appUser As New User(memUser)

            Dim defaultBu As Integer = 0
            Dim userBu As DataTable = Nothing

            If DoCreateNewUser = False Then
                defaultBU = appUser.GetDefaultBUByUserID()
                userBU = appUser.GetBUByUserID()
            End If

            Dim bu As New BusinessUnit
            Dim buList As DataTable = bu.GetList(WorkflowItem.LiveMode.CMS)

            If buList IsNot Nothing Then
                lstBusinessUnits.DataSource = buList
                lstBusinessUnits.DataValueField = "BusinessUnitID"
                lstBusinessUnits.DataTextField = "BusinessUnitName"
                lstBusinessUnits.DataBind()

                If userBU IsNot Nothing Then
                    For Each row As DataRow In userBU.Rows
                        lstBusinessUnits.Items.FindByValue(CType(row("BusinessUnitID"), Integer)).Selected = True
                    Next
                End If
            End If

            If DoCreateNewUser = False Then
                Me.UserName.Text = memUser.UserName
                Me.txtComments.Text = memUser.Comment
                Me.Email.Text = memUser.Email

                appUser.Fill()
                Me.FirstName.Text = appUser.FirstName
                Me.LastName.Text = appUser.LastName
            Else
                Me.UserName.Text = String.Empty
                Me.Email.Text = String.Empty
                Me.txtComments.Text = String.Empty
                Me.FirstName.Text = String.Empty
                Me.LastName.Text = String.Empty
            End If
        End If

    End Sub

    Protected Sub wzForm_NextButtonClick(ByVal sender As Object, ByVal e As System.Web.UI.WebControls.WizardNavigationEventArgs) Handles wzForm.NextButtonClick

        ' save information on the step - (only in edit mode)
        Dim userName As String = UserNameVS 'CType(Session("FormUserName"), String)

        If _formMode = CMSFormUtils.FormMode.Edit Then
            Select Case wzForm.ActiveStepIndex
                Case 0
                    Dim memUser As MembershipUser
                    If DoCreateNewUser Then
                        memUser = Membership.GetUser(Me.UserName.Text)
                        If memUser Is Nothing Then
                            Membership.CreateUser(Me.UserName.Text, SiteProfile.GetUserTemporaryPassword, Me.Email.Text, "What is the temporary password?", "Symbol + Company + Year", False, MembershipCreateStatus.Success)
                        Else
                            Throw New MembershipCreateUserException(MembershipCreateStatus.DuplicateUserName)
                        End If

                        memUser = Membership.GetUser(Me.UserName.Text)
                        memUser.Comment = Me.txtComments.Text
                        Membership.UpdateUser(memUser)

                        Dim appUser As New User(memUser)
                        appUser.FirstName = Me.FirstName.Text
                        appUser.LastName = Me.LastName.Text
                        appUser.AddAppUser(MyBase.ActiveUserID)
                    Else
                        memUser = Membership.GetUser(UserName)
                        memUser.Email = Me.Email.Text
                        memUser.Comment = Me.txtComments.Text
                        Membership.UpdateUser(memUser)

                        Dim appUser As New User(memUser)
                        appUser.FirstName = Me.FirstName.Text
                        appUser.LastName = Me.LastName.Text
                        appUser.UpdateAppUser(MyBase.ActiveUserID)
                    End If

                Case 1
                    Dim buIdList As String = String.Empty
                    Dim hasBu As Boolean = False
                    For Each buItem As ListItem In lstBusinessUnits.Items
                        If buItem.Selected = True Then
                            buIdList += buItem.Value.ToString + ","
                            hasBU = True
                        End If
                    Next

                    If DoCreateNewUser Then
                        UserName = Me.UserName.Text
                    End If

                    Dim memUser As MembershipUser = Membership.GetUser(UserName)
                    Dim appuser As New User(memUser)
                    appuser.UpdateUserBUList(buIdList.Substring(0, buIdList.Length - 1), MyBase.ActiveUserID)
                Case 2 'Step 3 - Default Business

                    Dim buCount As Integer = 0
                    For Each buItem As ListItem In lstBusinessUnits.Items
                        If buItem.Selected = True Then
                            buCount += 1
                        End If
                    Next

                    If DoCreateNewUser Then
                        UserName = Me.UserName.Text
                    End If

                    Dim memUser As MembershipUser = Membership.GetUser(UserName)
                    Dim appuser As New User(memUser)

                    If buCount = 1 Then
                        ddlBusinessUnits.Items.FindByText(lstBusinessUnits.Items.FindByText(lstBusinessUnits.SelectedItem.Text).Text).Selected = True
                    End If

                    appuser.UpdateUserDefaultBU(CType(ddlBusinessUnits.SelectedItem.Value, Integer), MyBase.ActiveUserID)

            End Select
        End If
    End Sub

    Protected Sub wzForm_ActiveStepChanged(ByVal sender As Object, ByVal e As System.EventArgs) Handles wzForm.ActiveStepChanged

        Dim userName As String = UserNameVS 'CType(Session("FormUserName"), String)
        Dim memUser As MembershipUser
        memUser = Membership.GetUser(UserName)
        Dim appUser As New User(memUser)

        Select Case wzForm.ActiveStepIndex
            Case 1 'Step 2 - User Business Units

                If DoCreateNewUser = False Then
                    Dim userBu As DataTable = appUser.GetBUByUserID()
                    Dim bu As New BusinessUnit
                    Dim buList As DataTable = bu.GetList(WorkflowItem.LiveMode.CMS)

                    If buList IsNot Nothing Then
                        lstBusinessUnits.DataSource = buList
                        lstBusinessUnits.DataValueField = "BusinessUnitID"
                        lstBusinessUnits.DataTextField = "BusinessUnitName"
                        lstBusinessUnits.DataBind()

                        If userBU IsNot Nothing Then
                            For Each row As DataRow In userBU.Rows
                                lstBusinessUnits.Items.FindByValue(CType(row("BusinessUnitID"), Integer)).Selected = True
                            Next
                        End If
                    End If
                End If

            Case 2 'Step 3 - Default Business

                Dim userBu As DataTable = appUser.GetBUByUserID()
                Dim defaultBu As Integer = appUser.GetDefaultBUByUserID()

                If userBU IsNot Nothing Then
                    ddlBusinessUnits.DataSource = userBU
                    ddlBusinessUnits.DataValueField = "BusinessUnitID"
                    ddlBusinessUnits.DataTextField = "BusinessUnitName"
                    ddlBusinessUnits.DataBind()

                    For Each item As ListItem In ddlBusinessUnits.Items
                        If item.Value = defaultBU Then
                            item.Selected = True
                            Exit For 'just in case we have 2 defaults
                        End If
                    Next
                End If

            Case 3 'Step4 - User Roles

                chkRoles.DataSource = Roles.GetAllRoles
                chkRoles.DataBind()

                Dim currentCheckbox As ListItem
                Dim enumRoles As IEnumerator = Roles.GetAllRoles.GetEnumerator
                While enumRoles.MoveNext
                    currentCheckbox = chkRoles.Items.FindByText(enumRoles.Current.ToString)
                    If Roles.IsUserInRole(UserName, enumRoles.Current.ToString) Then
                        currentCheckbox.Selected = True
                    End If
                End While
        End Select

    End Sub

    Protected Sub wzForm_FinishButtonClick(ByVal sender As Object, ByVal e As System.Web.UI.WebControls.WizardNavigationEventArgs) Handles wzForm.FinishButtonClick
        Response.Redirect(ListPage)
    End Sub

    Sub SetFormMode(ByVal mode As CMSFormUtils.FormMode)
        Select Case mode
            Case CMSFormUtils.FormMode.Edit
                SetControlEnabledProperty(True)
                Me.Master.PageTitle = "Add/Edit"
            Case CMSFormUtils.FormMode.Read
                SetControlEnabledProperty(False)
                Me.Master.PageTitle = "View"
        End Select

        Me.Master.PageTitle = Me.Master.PageTitle & " User Information"

        wzForm.CancelDestinationPageUrl = ListPage
        'CMSFormUtils.SetFinishButtonProperties(CType(wzForm.FindControl("FinishNavigationTemplateContainerID$FinishButton"), Button), FORM_MODE)
    End Sub

    Sub RoleCheck_Click(ByVal sender As Object, ByVal e As EventArgs)
        UpdateUserRoles()
    End Sub

    Sub UpdateUserRoles()
        For Each item As ListItem In chkRoles.Items
            If item.Selected = True Then
                If Roles.IsUserInRole(Me.UserName.Text, item.Text) = False Then
                    Roles.AddUserToRole(Me.UserName.Text, item.Text)
                End If
            Else
                If Roles.IsUserInRole(Me.UserName.Text, item.Text) = True Then
                    Roles.RemoveUserFromRole(Me.UserName.Text, item.Text)
                End If
            End If
        Next
    End Sub

    Sub SetControlEnabledProperty(ByVal enable As Boolean)
        Me.Email.Enabled = enable
        Me.txtComments.Enabled = enable
        Me.FirstName.Enabled = enable
        Me.LastName.Enabled = enable
        Me.lstBusinessUnits.Enabled = enable
        Me.ddlBusinessUnits.Enabled = enable
        Me.chkRoles.Enabled = enable
    End Sub

    '#Region " STEP 3 - PRODUCT CATEGORIES "

    '    Protected Sub btnSaveProductCategory_Click(ByVal sender As Object, ByVal e As System.EventArgs) Handles btnSaveProductCategory.Click
    '        Dim prodCat As New ProductCategory(Me.CurrentProductCategoryID)
    '        With prodCat
    '            .BusinessUnitID = Me.CurrentBusinessUnitID
    '            .CategoryName = Me.txtProductCategory.Text.Trim
    '            .CategoryOrder = Services.GetNULLableInteger(Me.txtProdCatOrder.Text)

    '            ' don't forget to store the these values (from the general info step)
    '            .PublishDate = dtePublishDate.SelectedDate
    '            .ExpireDate = dteExpireDate.SelectedDate
    '            ' TODO: CMS - Put in Job ID and User ID as args below
    '            .JobID = Me.ActiveJobID
    '            .LastModBy = Me.ActiveUserID

    '            If .Save() Then
    '                ' re-bind the grid
    '                gvProductCategories.DataBind()
    '            End If

    '        End With
    '        ResetProductCategoryForm()
    '    End Sub

    '    Protected Sub gvProductCategories_RowCommand(ByVal sender As Object, ByVal e As System.Web.UI.WebControls.GridViewCommandEventArgs) Handles gvProductCategories.RowCommand
    '        ' If multiple ButtonField column fields are used, use the
    '        ' CommandName property to determine which button was clicked.

    '        Select Case e.CommandName
    '            Case "EditItem"
    '                ' Get the ID to be edited
    '                Dim editProdCat As New ProductCategory(Convert.ToInt32(e.CommandArgument))
    '                With editProdCat
    '                    .Fill()
    '                    If .CategoryName.Length > 0 Then
    '                        Me.txtProductCategory.Text = .CategoryName
    '                        Me.txtProdCatOrder.Text = .CategoryOrder
    '                        Me.CurrentProductCategoryID = .CategoryID

    '                        ' set title/button
    '                        lblProductCategory.Text = "Edit Product Category"
    '                        lblProductCategory.CssClass = "subFormTitle"
    '                        btnSaveProductCategory.Text = "Edit Product Category"

    '                    End If
    '                End With

    '                ' show buttons
    '                btnSaveProductCategory.Visible = True
    '                btnCancelSaveProdCat.Visible = True

    '            Case "DeleteItem"
    '                Dim delProdCat As New ProductCategory(Convert.ToInt32(e.CommandArgument))
    '                With delProdCat
    '                    .JobID = Me.ActiveJobID
    '                    .LastModBy = Me.ActiveUserID
    '                    If .Delete() Then
    '                        lblMessage.Text = "The product category has been deleted."
    '                        lblMessage.CssClass = "infoMessage"
    '                        ' refresh grid
    '                        ' re-bind the grid
    '                        gvProductCategories.DataBind()
    '                        ResetProductCategoryForm()
    '                    End If

    '                End With
    '        End Select
    '    End Sub

    '    Protected Sub gvProductCategories_RowDataBound(ByVal sender As Object, ByVal e As System.Web.UI.WebControls.GridViewRowEventArgs) Handles gvProductCategories.RowDataBound
    '        'TODO: CMS - Product Attribute - ADD CAPABILITY CHECK FOR ALLOWING DELETE/EDIT BUTTONS TO DISPLAY

    '        ' this adds a confirmation message to the delete command
    '        If e.Row.RowType = DataControlRowType.DataRow Then
    '            Dim categoryName As String = DataBinder.Eval(e.Row.DataItem, "CategoryName")

    '            ' replace any apostrophes
    '            categoryName = categoryName.Replace("'", "\'")

    '            Dim ibtnDelete As ImageButton = e.Row.FindControl("ibtnDelete")
    '            ibtnDelete.Attributes.Add("onclick", "javascript:return " & _
    '              "confirm('Are you sure you want to delete " & _
    '              categoryName & "?')")


    '            ' hide the edit/delete button for item that is marked for deletion or marked as read only
    '            If Convert.ToBoolean(DataBinder.Eval(e.Row.DataItem, "MarkedForDeletion")) Then
    '                e.Row.Cells(EDIT_COLUMN).Text = CMSGlobals.BlankIcon
    '                e.Row.Cells(DELETE_COLUMN).Text = CMSGlobals.BlankIcon
    '            End If

    '            ' -- part of other job check --
    '            ' if the item is part of another job and in non-LIVE status, then hide edit/delete icons
    '            If Convert.ToInt32(DataBinder.Eval(e.Row.DataItem, "DeploymentJobID")) <> _
    '                    Me.ActiveJobID And _
    '                DataBinder.Eval(e.Row.DataItem, "WorkflowStatus").ToString <> "LIVE" Then
    '                e.Row.Cells(EDIT_COLUMN).Text = CMSGlobals.BlankIcon
    '                e.Row.Cells(DELETE_COLUMN).Text = CMSGlobals.BlankIcon
    '            End If

    '            ' if there's no active job, then hide delete/edit icons
    '            If Me.ActiveJobID = 0 Then
    '                e.Row.Cells(EDIT_COLUMN).Text = CMSGlobals.BlankIcon
    '                e.Row.Cells(DELETE_COLUMN).Text = CMSGlobals.BlankIcon
    '            End If
    '        End If


    '    End Sub

    '    Sub ResetProductCategoryForm()
    '        ' now clear out the form
    '        Me.txtProdCatOrder.Text = String.Empty
    '        Me.txtProductCategory.Text = String.Empty

    '        ' set title/button
    '        lblProductCategory.Text = "Add Product Category"
    '        lblProductCategory.CssClass = "subFormTitle"
    '        Me.btnSaveProductCategory.Text = "Add Product Category"

    '        ' reset viewstate property for cat id
    '        Me.CurrentProductCategoryID = 0
    '    End Sub

    '    Protected Sub btnCancelSaveProdCat_Click(ByVal sender As Object, ByVal e As System.EventArgs) Handles btnCancelSaveProdCat.Click
    '        ResetProductCategoryForm()
    '    End Sub
    '#End Region


    'Function SaveBUGeneralInfo() As Boolean
    '    Dim bu As New BusinessUnit(Me.CurrentBusinessUnitID)
    '    Dim success As Boolean = False
    '    ' Set BU values
    '    With bu
    '        .BusName = txtBusinessUnitName.Text.Trim
    '        .DocAuth = chkDocAuth.Checked
    '        .PublishDate = dtePublishDate.SelectedDate
    '        If dteExpireDate.SelectedDate <> #12:00:00 AM# Then
    '            .ExpireDate = dteExpireDate.SelectedDate
    '        End If
    '        Me.ucImageEdit.GetFormValues()
    '        .LogoImage = ucImageEdit.CurrentBusinessLogoImage
    '        .LogoImage.AltText = .BusName
    '        .JobID = Me.ActiveJobID
    '        .LastModBy = Me.ActiveUserID

    '        ' if it fails, don't save anything
    '        If DirectCast(ucImageEdit.FindControl("rdoUpload"), RadioButton).Checked Then
    '            If ucImageEdit.UploadImage(bu.LogoImage) Then

    '                .LogoImage = ucImageEdit.CurrentBusinessLogoImage
    '                .LogoImage.AltText = .BusName
    '                If bu.Save() Then
    '                    ' make sure to set the current bus unit id
    '                    Me.CurrentBusinessUnitID = bu.BusUnitID
    '                    success = True
    '                Else
    '                    lblMessage.Text = "There was an error saving the Business Unit."
    '                    lblMessage.CssClass = "errorMessage"
    '                End If
    '            End If
    '        Else ' using existing or current image
    '            If bu.Save() Then
    '                Me.CurrentBusinessUnitID = bu.BusUnitID
    '                success = True
    '            Else
    '                lblMessage.Text = "There was an error saving the Business Unit."
    '                lblMessage.CssClass = "errorMessage"
    '            End If
    '        End If
    '    End With
    '    Return success = True
    'End Function


End Class
