
Partial Class CmsDeploymentJobEdit
    Inherits CMSPage
    Private _formMode As CMSFormUtils.FormMode = CMSFormUtils.FormMode.Read ' default to read
    Private Const ListPage As String = "DeploymentJobList.aspx"

    Private Property CurrentJobId() As Integer
        Get
            If ViewState("CurrentJobID") IsNot Nothing Then
                Return Services.GetNULLableInteger(ViewState("CurrentJobID"))
            Else
                Return 0
            End If
        End Get
        Set(ByVal value As Integer)
            ViewState("CurrentJobID") = value
        End Set
    End Property

    Protected Sub Page_Load(ByVal sender As Object, ByVal e As System.EventArgs) Handles Me.Load

        Me.Master.HideBusinessUnitDropdown()
        Me.Master.HideJobDropdown()

        If Not Session("FormMode") Is Nothing Then
            _formMode = Convert.ToInt32(Session("FormMode"))
            hidFormMode.Text = _formMode
            Session("FormMode") = Nothing ' clear out session variable
        ElseIf hidFormMode.Text.Length > 0 Then
            _formMode = Convert.ToInt32(hidFormMode.Text)
        End If
        SetFormMode(_formMode)

        ' The ID is sent from the list page in session -- if it's an add, 0 is passed as the ID
        If Not Session("FormJobID") Is Nothing Then
            Me.CurrentJobID = Convert.ToInt32(Session("FormJobID"))
            Session("FormJobID") = Nothing ' clear out session variable
        End If

        If Not IsPostBack Then
            Dim editJob As DeploymentJob
            ' if this is an edit, get the info and fill the form
            If Me.CurrentJobID <> 0 Then
                editJob = New DeploymentJob(Me.CurrentJobID)
                With editJob
                    .Fill()
                    txtJobName.Text = .JobName
                    txtJobDesc.Text = .JobDescription
                    dteDeployDate.SelectedDate = .DeploymentDate
                End With
            Else
                ' check form mode -- if read, then just redirect back to list
                If _formMode = CMSFormUtils.FormMode.Read Then
                    Response.Redirect(ListPage)
                Else
                    ' adding an item
                    ' default the deploye date
                    dteDeployDate.SelectedDate = Today.Date
                End If
            End If
        End If
    End Sub

    Protected Sub wzForm_FinishButtonClick(ByVal sender As Object, ByVal e As System.Web.UI.WebControls.WizardNavigationEventArgs) Handles wzForm.FinishButtonClick
        Dim goBack As Boolean
        Dim job As New DeploymentJob

        Try
            ' if it's readonly here, just go back
            If _formMode = CMSFormUtils.FormMode.Edit Then
                If IsValid Then
                    With job
                        .DeploymentJobID = CurrentJobID
                        ' TODO: CMS - may want to fill() before updating 
                        '(to get values of other things that aren't updatable)
                        If .DeploymentJobID <> 0 Then
                            .Fill()
                        End If
                        .JobName = Me.txtJobName.Text.Trim
                        .JobDescription = Me.txtJobDesc.Text.Trim
                        .DeploymentDate = Me.dteDeployDate.SelectedDate
                        .LastModBy = Me.ActiveUserID
                        If .Save() Then
                            goBack = True
                            Me.ActiveJobID = .DeploymentJobID
                            Me.ActiveJob = job
                        Else
                            lblMessage.Text = "There was an error saving the Deployment Job."
                            lblMessage.CssClass = "errorMessage"
                        End If
                    End With
                Else
                    lblMessage.Text = "The Deployment Job cannot be saved unless all invalid information is corrected."
                    lblMessage.CssClass = "errorMessage"
                End If
            Else ' just go back to list page
                goBack = True
            End If
        Catch ex As Exception
            If TypeOf ex Is NLTException Then
                Throw ex
            Else
                Throw New NLTException("Error saving Deployment Job.", ex, "cms/DeploymentJobEdit.aspx", "Protected Sub wzForm_FinishButtonClick(ByVal sender As Object, ByVal e As System.Web.UI.WebControls.WizardNavigationEventArgs) Handles wzForm.FinishButtonClick")
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
        Dim finishButtonText As String = "Close"
        Select Case mode
            Case CMSFormUtils.FormMode.Edit
                SetControlEnabledProperty(True)
                Me.Master.PageTitle = "Add/Edit"
                finishButtonText = "Save and Close"
            Case CMSFormUtils.FormMode.Read
                SetControlEnabledProperty(False)
                Me.Master.PageTitle = "View"
                finishButtonText = "Close"
        End Select
        Me.Master.PageTitle = Me.Master.PageTitle & " Deployment Job"
        ' set the cancel destination page
        wzForm.CancelDestinationPageUrl = ListPage
        ' set the finish button text/attribute
        ' DON'T NEED THIS FOR DEPLOYMENT JOB EDIT -- JUST SET THE BUTTON TEXT
        CType(wzForm.FindControl("FinishNavigationTemplateContainerID$FinishButton"), Button).Text = finishButtonText
        ' CMSFormUtils.SetFinishButtonProperties(CType(wzForm.FindControl("FinishNavigationTemplateContainerID$FinishButton"), Button), FORM_MODE)
    End Sub
    ''' <summary>
    ''' This sets all of the user input controls enabled property
    ''' based on the parm value
    ''' </summary>
    ''' <param name="enable">True/False</param>
    ''' <remarks></remarks>
    Sub SetControlEnabledProperty(ByVal enable As Boolean)
        Me.txtJobName.Enabled = enable
        Me.txtJobDesc.Enabled = enable
        Me.dteDeployDate.Enabled = enable
    End Sub
End Class
