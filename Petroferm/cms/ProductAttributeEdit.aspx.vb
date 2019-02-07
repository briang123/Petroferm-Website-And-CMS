
Partial Class CmsProductAttributeEdit
    Inherits CMSPage
    Private _formMode As CMSFormUtils.FormMode = CMSFormUtils.FormMode.Read ' default to read
    Private Const ListPage As String = "ProductAttributeList.aspx"

    Protected Sub Page_Load(ByVal sender As Object, ByVal e As System.EventArgs) Handles Me.Load



        Dim prodAttribId As Integer
        If Not Session("FormMode") Is Nothing Then
            _formMode = Convert.ToInt32(Session("FormMode"))
            hidFormMode.Text = _formMode
            Session("FormMode") = Nothing ' clear out session variable
        ElseIf hidFormMode.Text.Length > 0 Then
            _formMode = Convert.ToInt32(hidFormMode.Text)
        End If
        SetFormMode(_formMode)

        ' The ID is sent from the list page in session -- if it's an add, 0 is passed as the ID
        If Not Session("FormProdAttribID") Is Nothing Then
            prodAttribID = Convert.ToInt32(Session("FormProdAttribID"))
            Session("FormProdAttribID") = Nothing ' clear out session variable
        End If
        If Not IsPostBack Then
            Dim editProdAttrib As ProductAttribute
            ' if this is an edit, get the bus unit info and fill the form
            If prodAttribID <> 0 Then
                editProdAttrib = New ProductAttribute(prodAttribID)
                With editProdAttrib
                    .Fill()
                    txtAttribName.Text = .AttribName
                    chkAllowMultiple.Checked = .AllowMultiple
                    hidReadOnly.Text = .IsReadOnly.ToString
                    dtePublishDate.SelectedDate = .PublishDate
                    dteExpireDate.SelectedDate = .ExpireDate
                    hidProdAttribID.Text = .AttribID
                    ' set workflow control
                    ucWorkflowInfo.SetValues(editProdAttrib)
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
        Me.Master.PageTitle = Me.Master.PageTitle & " Product Attribute"
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
        chkAllowMultiple.Enabled = enable
        dtePublishDate.Enabled = enable
        dteExpireDate.Enabled = enable
    End Sub

    Protected Sub wzForm_FinishButtonClick(ByVal sender As Object, ByVal e As System.Web.UI.WebControls.WizardNavigationEventArgs) Handles wzForm.FinishButtonClick
        Dim goBack As Boolean
        Dim prodAttrib As New ProductAttribute

        Try
            ' if it's readonly here, just go back
            If _formMode = CMSFormUtils.FormMode.Edit Then

                If Page.IsValid Then
                    With prodAttrib
                        If Me.hidProdAttribID.Text.Length > 0 Then
                            .AttribID = Convert.ToInt32(Me.hidProdAttribID.Text)
                        End If
                        .AttribName = Me.txtAttribName.Text.Trim
                        .BusUnitID = Session("BusUnitID")
                        .AllowMultiple = chkAllowMultiple.Checked
                        If hidReadOnly.Text.Length > 0 Then
                            .IsReadOnly = Convert.ToBoolean(hidReadOnly.Text)
                        End If
                        .PublishDate = dtePublishDate.SelectedDate
                        .ExpireDate = dteExpireDate.SelectedDate
                        ' TODO: CMS - Put in Job ID and User ID as args below
                        .JobID = Me.ActiveJobID
                        .LastModBy = Me.ActiveUserID

                        If .Save() Then
                            goBack = True
                        Else
                            lblMessage.Text = "There was an error saving the Product Attribute."
                            lblMessage.CssClass = "errorMessage"
                        End If
                    End With
                Else
                    lblMessage.Text = "The Product Attribute cannot be saved unless all invalid information is corrected."
                    lblMessage.CssClass = "errorMessage"
                End If
            Else ' just go back to list page
                goBack = True
            End If
        Catch ex As Exception
            If TypeOf ex Is NLTException Then
                Throw ex
            Else
                Throw New NLTException("Error saving Product Attribute.", ex, "cms/ProductAttributeEdit.aspx", "Protected Sub wzForm_FinishButtonClick(ByVal sender As Object, ByVal e As System.Web.UI.WebControls.WizardNavigationEventArgs) Handles wzForm.FinishButtonClick")
            End If
        End Try

        ' if information was saved, go back to list page
        If goBack Then
            Response.Redirect(ListPage)
        End If
    End Sub



End Class
