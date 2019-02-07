
Partial Class CmsMarketEdit
    Inherits CMSPage
    Private _formMode As CMSFormUtils.FormMode = CMSFormUtils.FormMode.Read ' default to read
    Private Const ListPage As String = "MarketList.aspx"

    Protected Sub Page_Load(ByVal sender As Object, ByVal e As System.EventArgs) Handles Me.Load

        Dim mktId As Integer

        If Not Session("FormMode") Is Nothing Then
            _formMode = Convert.ToInt32(Session("FormMode"))
            hidFormMode.Text = _formMode
            Session("FormMode") = Nothing ' clear out session variable
        ElseIf hidFormMode.Text.Length > 0 Then
            _formMode = Convert.ToInt32(hidFormMode.Text)
        End If
        SetFormMode(_formMode)

        ' The ID is sent from the list page in session -- if it's an add, 0 is passed as the ID
        If Not Session("FormMktID") Is Nothing Then
            mktID = Convert.ToInt32(Session("FormMktID"))
            Session("FormMktID") = Nothing ' clear out session variable
        End If

        If Not IsPostBack Then
            Dim editMkt As Market
            ' if this is an edit, get the bus unit info and fill the form
            If mktID <> 0 Then
                editMkt = New Market(mktID)
                With editMkt
                    .Fill(False)
                    txtMarketName.Text = .MarketName
                    txtOrder.Text = .Order
                    dtePublishDate.SelectedDate = .PublishDate
                    dteExpireDate.SelectedDate = .ExpireDate
                    hidMarketID.Text = .MarketID
                End With
                ' set workflow control
                ucWorkflowInfo.SetValues(editMkt)
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

    Protected Sub wzForm_FinishButtonClick(ByVal sender As Object, ByVal e As System.Web.UI.WebControls.WizardNavigationEventArgs) Handles wzForm.FinishButtonClick
        Dim goBack As Boolean
        Dim mkt As New Market


        Try

            ' if it's readonly here, just go back
            If _formMode = CMSFormUtils.FormMode.Edit Then
                If IsValid Then
                    With mkt
                        If Me.hidMarketID.Text.Length > 0 Then
                            .MarketID = Convert.ToInt32(Me.hidMarketID.Text)
                        End If
                        .MarketName = Me.txtMarketName.Text.Trim
                        .BusUnitID = Session("BusUnitID")
                        .Order = Me.txtOrder.Text.Trim
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
                    lblMessage.Text = "The Market cannot be saved unless all invalid information is corrected."
                    lblMessage.CssClass = "errorMessage"
                End If
            Else ' just go back to list page
                goBack = True

            End If




        Catch ex As Exception
            If TypeOf ex Is NLTException Then
                Throw ex
            Else
                Throw New NLTException("Error saving Market.", ex, "cms/MarketEdit.aspx", "Protected Sub wzForm_FinishButtonClick(ByVal sender As Object, ByVal e As System.Web.UI.WebControls.WizardNavigationEventArgs) Handles wzForm.FinishButtonClick")
            End If
        End Try

        ' if information was saved, go back to list page
        If goBack Then
            Response.Redirect(ListPage)
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
        Me.Master.PageTitle = Me.Master.PageTitle & " Market"
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
        txtMarketName.Enabled = enable
        txtOrder.Enabled = enable
        dtePublishDate.Enabled = enable
        dteExpireDate.Enabled = enable
    End Sub
End Class
