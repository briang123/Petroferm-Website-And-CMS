
Partial Class CmsSearchAttributeEdit
    Inherits CMSPage
    Private _formMode As CMSFormUtils.FormMode = CMSFormUtils.FormMode.Read ' default to read
    Private Const ListPage As String = "SearchAttributeList.aspx"
    Private Const DeleteColumn As Integer = 0
    Private Const EditColumn As Integer = 1

    Protected Sub Page_Load(ByVal sender As Object, ByVal e As System.EventArgs) Handles Me.Load

        Dim searchAttribId As Integer
        If Not Session("FormMode") Is Nothing Then
            _formMode = Convert.ToInt32(Session("FormMode"))
            hidFormMode.Text = _formMode
            Session("FormMode") = Nothing ' clear out session variable
        ElseIf hidFormMode.Text.Length > 0 Then
            _formMode = Convert.ToInt32(hidFormMode.Text)
        End If


        ' The ID is sent from the list page in session -- if it's an add, 0 is passed as the ID
        If Not Session("FormSearchAttribID") Is Nothing Then
            searchAttribID = Convert.ToInt32(Session("FormSearchAttribID"))
            Session("FormSearchAttribID") = Nothing ' clear out session variable
        End If
        If Not IsPostBack Then
            Dim editSearchAttrib As SearchAttribute
            ' if this is an edit, get the bus unit info and fill the form
            If searchAttribID <> 0 Then
                editSearchAttrib = New SearchAttribute(searchAttribID)
                With editSearchAttrib
                    .Fill()
                    Dim mkt As New Market(.MarketID)
                    mkt.Fill(0)
                    lblMarket.Text = mkt.MarketName
                    ' hide the dropdown
                    ddlMarket.Visible = False
                    hidMarketID.Text = mkt.MarketID
                    txtAttribName.Text = .SearchAttribName
                    dtePublishDate.SelectedDate = .PublishDate
                    dteExpireDate.SelectedDate = .ExpireDate
                    hidSearchAttribID.Text = .SearchAttribTypeID
                    ' set workflow control
                    ucWorkflowInfo.SetValues(editSearchAttrib)

                    ' if this is part of another job that's not live, make this read only
                    If _formMode = CMSFormUtils.FormMode.Edit Then
                        If .JobID <> Me.ActiveJobID And .WorkflowStatus <> "LIVE" Then
                            ' make this form readonly!
                            _formMode = CMSFormUtils.FormMode.Read
                        End If
                    End If


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
                End If
            End If

            SetFormMode(_formMode) ' moved to bottom of page load

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
            Case CMSFormUtils.FormMode.Read
                SetControlEnabledProperty(False)
                Me.Master.PageTitle = "View"
        End Select
        Me.Master.PageTitle = Me.Master.PageTitle & " Search Attribute"
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
        txtAttribName.Enabled = enable
        dtePublishDate.Enabled = enable
        dteExpireDate.Enabled = enable
        Me.lstProducts.Enabled = enable
        Me.btnAddProduct.Enabled = enable
    End Sub

    Protected Sub wzForm_FinishButtonClick(ByVal sender As Object, ByVal e As System.Web.UI.WebControls.WizardNavigationEventArgs) Handles wzForm.FinishButtonClick
        Dim goBack As Boolean


        Try
            ' if it's readonly here, just go back
            If _formMode = CMSFormUtils.FormMode.Edit Then
                If SaveSearchAttrib() Then
                    goBack = True
                End If
            Else ' just go back to list page
                goBack = True
            End If
        Catch ex As Exception
            If TypeOf ex Is NLTException Then
                Throw ex
            Else
                Throw New NLTException("Error saving Search Attribute.", ex, "cms/SearchAttributeEdit.aspx", "Protected Sub wzForm_FinishButtonClick(ByVal sender As Object, ByVal e As System.Web.UI.WebControls.WizardNavigationEventArgs) Handles wzForm.FinishButtonClick")
            End If
        End Try

        ' if information was saved, go back to list page
        If goBack Then
            Response.Redirect(ListPage)
        End If
    End Sub
    Function SaveSearchAttrib() As Boolean
        Dim searchAttrib As New SearchAttribute
        If Page.IsValid Then
            With searchAttrib
                If Me.hidSearchAttribID.Text.Length > 0 Then
                    .SearchAttribTypeID = Convert.ToInt32(Me.hidSearchAttribID.Text)
                    .MarketID = Convert.ToInt32(Me.hidMarketID.Text)
                Else
                    .MarketID = Convert.ToInt32(ddlMarket.SelectedValue)
                End If
                .SearchAttribName = Me.txtAttribName.Text.Trim
                .BusUnitID = Session("BusUnitID")
                .PublishDate = dtePublishDate.SelectedDate
                .ExpireDate = dteExpireDate.SelectedDate
                ' TODO: CMS - Put in Job ID and User ID as args below
                .JobID = Me.ActiveJobID
                .LastModBy = Me.ActiveUserID
                If .Save() Then
                    hidSearchAttribID.Text = .SearchAttribTypeID.ToString
                    hidMarketID.Text = .MarketID.ToString
                    Return True
                Else
                    Return False
                    lblMessage.Text = "There was an error saving the Search Attribute."
                    lblMessage.CssClass = "errorMessage"
                End If
            End With
        Else
            Return False
            lblMessage.Text = "The Search Attribute cannot be saved unless all invalid information is corrected."
            lblMessage.CssClass = "errorMessage"
        End If
    End Function
    Protected Sub btnAddProduct_Click(ByVal sender As Object, ByVal e As System.EventArgs) Handles btnAddProduct.Click
        Dim li As ListItem
        Dim reln As New ProductSearchAttributeReln
        With reln

            ' must add attrib first, if it's not already 
            If hidSearchAttribID.Text.Length = 0 Then
                SaveSearchAttrib()
            End If

            .SearchAttribTypeID = Convert.ToInt32(hidSearchAttribID.Text)
            ' don't forget to store the these values (from the general info step)
            .PublishDate = dtePublishDate.SelectedDate
            .ExpireDate = dteExpireDate.SelectedDate
            ' TODO: CMS - Put in Job ID and User ID as args below
            .JobID = Me.ActiveJobID
            .LastModBy = Me.ActiveUserID
            For Each li In lstProducts.Items
                If li.Selected Then
                    .ProdSearchAttribRelnID = 0 ' reset id to save a new one
                    .ProductID = Convert.ToInt32(li.Value)
                    .Save()
                End If
            Next
        End With
        ' refresh grid
        gvSearchAttribs.DataBind()
        ' also refresh listbox
        lstProducts.DataBind()
    End Sub

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
                        lstProducts.DataBind()
                    End If

                End With
        End Select
    End Sub

    Protected Sub gvSearchAttribs_RowDataBound(ByVal sender As Object, ByVal e As System.Web.UI.WebControls.GridViewRowEventArgs) Handles gvSearchAttribs.RowDataBound
        'TODO: CMS - Product search Attribute - ADD CAPABILITY CHECK FOR ALLOWING DELETE/EDIT BUTTONS TO DISPLAY

        ' this adds a confirmation message to the delete command
        If e.Row.RowType = DataControlRowType.DataRow Then
            Dim productName As String = DataBinder.Eval(e.Row.DataItem, "ProductName")
            ' replace any apostrophes
            productName = productName.Replace("'", "\'")

            Dim ibtnDelete As ImageButton = e.Row.FindControl("ibtnDelete")
            ibtnDelete.Attributes.Add("onclick", "javascript:return " & _
              "confirm('Are you sure you want to delete " & _
              productName & "?')")


            ' hide the edit/delete button for item that is marked for deletion or marked as read only
            If Convert.ToBoolean(DataBinder.Eval(e.Row.DataItem, "MarkedForDeletion")) Then
                e.Row.Cells(DeleteColumn).Text = CMSGlobals.BlankIcon
            End If


            ' -- part of other job check --
            ' if the item is part of another job and in non-LIVE status, then hide edit/delete icons
            If Convert.ToInt32(DataBinder.Eval(e.Row.DataItem, "DeploymentJobID")) <> _
                    Me.ActiveJobID And _
                DataBinder.Eval(e.Row.DataItem, "WorkflowStatus").ToString <> "LIVE" Then
                e.Row.Cells(DeleteColumn).Text = CMSGlobals.BlankIcon
            End If

            ' if there's no active job, then hide delete/edit icons
            If Me.ActiveJobID = 0 Then
                e.Row.Cells(EditColumn).Text = CMSGlobals.BlankIcon
                e.Row.Cells(DeleteColumn).Text = CMSGlobals.BlankIcon
            End If

        End If


    End Sub
End Class
