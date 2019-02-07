
Partial Class CmsControlsImageEdit
    Inherits System.Web.UI.UserControl
    Private _mActiveImage As ImageFile
    Private _mCurrentImageModule As New ImageModule ' used for image module for pages
    Private _mCurrentBusinessLogoImage As New ImageFile ' used for business unit mgmt

    Public Property ImageType() As String
        Get
            Return lblImageType.Text
        End Get
        Set(ByVal value As String)
            lblImageType.Text = value.Trim
            '  lblImageUpload.Text = value.Trim & " Image"
        End Set
    End Property

    Private Property CurrentImageId() As Integer
        Get
            If ViewState("CurrentImageID") IsNot Nothing Then
                Return Services.GetNULLableInteger(ViewState("CurrentImageID"))
            Else
                Return 0
            End If
        End Get
        Set(ByVal value As Integer)
            ViewState("CurrentImageID") = value
        End Set
    End Property

    Private Property CurrentWelcomeImageId() As Integer
        Get
            If ViewState("CurrentWelcomeImageID") IsNot Nothing Then
                Return Services.GetNULLableInteger(ViewState("CurrentWelcomeImageID"))
            Else
                Return 0
            End If
        End Get
        Set(ByVal value As Integer)
            ViewState("CurrentWelcomeImageID") = value
        End Set
    End Property

    Public Property CurrentImageModule() As ImageModule
        Get
            Return _mCurrentImageModule
        End Get
        Set(ByVal value As ImageModule)
            _mCurrentImageModule = value
        End Set
    End Property

    Public Property CurrentBusinessLogoImage() As ImageFile
        Get
            Return _mCurrentBusinessLogoImage
        End Get
        Set(ByVal value As ImageFile)
            _mCurrentBusinessLogoImage = value
        End Set
    End Property
    Private Property CurrentImageModuleId() As Integer
        Get
            If ViewState("CurrentImageModuleID") IsNot Nothing Then
                Return Services.GetNULLableInteger(ViewState("CurrentImageModuleID"))
            Else
                Return 0
            End If
        End Get
        Set(ByVal value As Integer)
            ViewState("CurrentImageModuleID") = value
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

    Public Property IsPetroHomePageNavOnImage() As Boolean
        Get
            If ViewState("IsPetroHomePageNavOnImage") IsNot Nothing Then
                Return Services.GetNULLableBoolean(ViewState("IsPetroHomePageNavOnImage"))
            Else
                Return False
            End If

        End Get
        Set(ByVal value As Boolean)
            ViewState("IsPetroHomePageNavOnImage") = value
        End Set
    End Property

    Public Function SetFormValues(ByVal img As ImageFile) As Boolean
        With imgCurrent
            .ImageUrl = "~/" & img.ImagePath
            .AlternateText = img.AltText
            .Visible = True
        End With
        ' also default the radio button "use current"
        hidImageID.Text = img.ImageId
        Me.CurrentImageID = img.ImageId
        rdoUseCurrent.Checked = True
    End Function

    Public Sub SetFormValues()

        Me.trPetroHomePageMgmtRow1of4.Visible = IsPetroHomePageNavOnImage
        Me.trPetroHomePageMgmtRow2of4.Visible = IsPetroHomePageNavOnImage
        Me.trPetroHomePageMgmtRow3of4.Visible = IsPetroHomePageNavOnImage
        Me.trPetroHomePageMgmtRow4of4.Visible = IsPetroHomePageNavOnImage

        If Me.ImageType = "LOGO" Then
            ' it's a business unit logo
            If CurrentBusinessLogoImage.ImageId <> 0 Then
                With imgCurrent
                    .ImageUrl = "~/" & Me.CurrentBusinessLogoImage.ImagePath
                    .AlternateText = CurrentBusinessLogoImage.AltText
                    .Visible = True
                End With
                ' also default the radio button "use current"
                hidImageID.Text = CurrentBusinessLogoImage.ImageId
                Me.CurrentImageID = CurrentBusinessLogoImage.ImageId
                rdoUseCurrent.Checked = True
                Me.trCurrentImage.Visible = True
            Else
                Me.trCurrentImage.Visible = False
            End If

            'hide the order/publish/expire dates
            Me.trImageOrder.Visible = False
            Me.trExpireDate.Visible = False
            Me.trPublishDate.Visible = False

            Me.lblFormLabel.Text = "Set Business Unit Logo"
        Else



            With Me.CurrentImageModule
                If .ImageModuleId <> 0 Then
                    ' set current image
                    imgCurrent.ImageUrl = "~/" & .ImageFile.ImagePath
                    imgCurrent.AlternateText = .ImageFile.AltText
                    imgCurrent.Visible = True
                    rdoUseCurrent.Checked = True
                    rdoUseCurrent.Visible = True
                    Me.CurrentImageID = .ImageFile.ImageId
                    Me.CurrentImageModuleID = .ImageModuleId
                    Me.CurrentPageModuleRelnID = .PageModuleRelnId
                    Me.trCurrentImage.Visible = True
                    Me.txtModuleOrder.Text = .ModuleOrder.ToString
                    Me.lblImageType.Text = .ModuleType.ToString
                    Me.dtePublishDate.SelectedDate = .PublishDate
                    Me.dteExpireDate.SelectedDate = .ExpireDate

                    If IsPetroHomePageNavOnImage Then
                        BuildDropdowns()


                        ' set current welcome image
                        imgCurrentWelcome.ImageUrl = "~/" & .WelcomeImageFile.ImagePath
                        imgCurrentWelcome.Visible = True
                        Me.rdoUseCurrentWelcomeImage.Checked = True
                        Me.trUseCurrentWelcomeImage.Visible = True
                        Me.CurrentWelcomeImageID = .WelcomeImageFile.ImageId
                        Me.ddlExistingWelcomeImage.ClearSelection()
                        Me.txtWelcomeTitle.Text = .WelcomeTitle.ToString
                        ' set values for single-link type
                        If .WelcomeLinkPageID <> 0 Then
                            Me.rdoSingleLink.Checked = True
                            Dim li As ListItem = Me.ddlSinglePage.Items.FindByValue(.WelcomeLinkPageID.ToString)
                            If li IsNot Nothing Then
                                li.Selected = True
                            End If
                        End If
                        ' set values for multiple-link type
                        If .WelcomeLinkPageIDList.Length > 0 Then
                            Me.rdoMultipleLinks.Checked = True
                            Dim pageIdList() As String
                            pageIDList = .WelcomeLinkPageIDList.Split("|")
                            Dim linkTextList() As String
                            linkTextList = .WelcomeLinkTextList.Split("|")
                            'loop through values 
                            Dim i As Integer
                            For i = 0 To pageIDList.Length - 1
                                Dim ddlPage As DropDownList = Nothing
                                Dim txtLinkText As TextBox = Nothing
                                ddlPage = Me.FindControl("ddlMultPage" & (i + 1).ToString)
                                If ddlPage IsNot Nothing Then
                                    Dim liMultPage As ListItem = ddlPage.Items.FindByValue(pageIDList(i).ToString)
                                    If liMultPage IsNot Nothing Then
                                        liMultPage.Selected = True
                                    End If
                                End If
                                txtLinkText = Me.FindControl("txtMultLinkText" & (i + 1).ToString)
                                If txtLinkText IsNot Nothing Then
                                    txtLinkText.Text = linkTextList(i).ToString
                                End If
                            Next
                        End If
                    End If

                Else
                    Me.trCurrentImage.Visible = False

                    If IsPetroHomePageNavOnImage Then
                        Me.trUseCurrentWelcomeImage.Visible = False
                    End If

                    ' default the dates
                    Me.dtePublishDate.SelectedDate = Today.Date
                    Me.dteExpireDate.SelectedDate = Today.AddYears(30)
                End If
            End With


        End If






    End Sub

    Private Sub BuildDropdowns()
        With ddlSinglePage
            .DataSource = Me.InternalLinkPageDS
            .DataTextField = "PageTitleDisplay"
            .DataValueField = "PageID"
            .DataBind()
            .Items.Insert(0, New ListItem("-- Select Single Page  --", "0"))
        End With

        With ddlMultPage1
            .DataSource = Me.InternalLinkPageDS
            .DataTextField = "PageTitleDisplay"
            .DataValueField = "PageID"
            .DataBind()
            .Items.Insert(0, New ListItem("-- Select Multiple Page 1 --", "0"))
        End With

        With ddlMultPage2
            .DataSource = Me.InternalLinkPageDS
            .DataTextField = "PageTitleDisplay"
            .DataValueField = "PageID"
            .DataBind()
            .Items.Insert(0, New ListItem("-- Select Multiple Page 2 --", "0"))
        End With

        With ddlMultPage3
            .DataSource = Me.InternalLinkPageDS
            .DataTextField = "PageTitleDisplay"
            .DataValueField = "PageID"
            .DataBind()
            .Items.Insert(0, New ListItem("-- Select Multiple Page 3 --", "0"))
        End With

        With ddlMultPage4
            .DataSource = Me.InternalLinkPageDS
            .DataTextField = "PageTitleDisplay"
            .DataValueField = "PageID"
            .DataBind()
            .Items.Insert(0, New ListItem("-- Select Multiple Page 4 --", "0"))
        End With

        With ddlMultPage5
            .DataSource = Me.InternalLinkPageDS
            .DataTextField = "PageTitleDisplay"
            .DataValueField = "PageID"
            .DataBind()
            .Items.Insert(0, New ListItem("-- Select Multiple Page 5 --", "0"))
        End With

        With ddlMultPage6
            .DataSource = Me.InternalLinkPageDS
            .DataTextField = "PageTitleDisplay"
            .DataValueField = "PageID"
            .DataBind()
            .Items.Insert(0, New ListItem("-- Select Multiple Page 6 --", "0"))
        End With

    End Sub


    ''' <summary>
    ''' This sets the form mode based on mode specified
    ''' </summary>
    ''' <param name="mode"></param>
    ''' <remarks></remarks>
    Public Sub SetFormMode(ByVal mode As CMSFormUtils.FormMode)
        Select Case mode
            Case CMSFormUtils.FormMode.Edit
                Me.lblFormLabel.Text = "Add/Edit Image Module"
                SetControlEnabledProperty(True)
            Case CMSFormUtils.FormMode.Read
                Me.lblFormLabel.Text = "View Image Module"
                SetControlEnabledProperty(False)
        End Select
    End Sub

    Public Sub GetFormValues()

        If Me.ImageType = "LOGO" Then
            With Me.CurrentBusinessLogoImage
                Select Case True
                    Case Me.rdoUseCurrent.Checked ' the upload new will set the use current rdo when it's uploaded
                        If hidImageID.Text.Length > 0 Then
                            .ImageId = Services.GetNULLableInteger(hidImageID.Text)

                        End If
                        .ImageId = CurrentImageID ' use the viewstate var instead
                        .ImagePath = imgCurrent.ImageUrl

                    Case Me.rdoExisting.Checked
                        .ImageId = Services.GetNULLableInteger(Me.ddlExistingImage.SelectedValue)
                        Me.CurrentBusinessLogoImage.Fill()
                End Select
            End With

        Else

            With Me.CurrentImageModule
                .ImageModuleId = Me.CurrentImageModuleID
                Select Case True
                    Case Me.rdoUseCurrent.Checked ' the upload new will set the use current rdo when it's uploaded
                        If hidImageID.Text.Length > 0 Then
                            .ImageFile.ImageId = Services.GetNULLableInteger(hidImageID.Text)
                        End If
                        .ImageFile.ImageId = CurrentImageID ' use the viewstate var instead
                        .ImageFile.ImagePath = imgCurrent.ImageUrl

                    Case Me.rdoExisting.Checked
                        .ImageFile.ImageId = Services.GetNULLableInteger(Me.ddlExistingImage.SelectedValue)
                        .ImageFile.Fill()
                End Select
                ' image order and module order are the same
                .ImageOrder = Services.GetNULLableInteger(Me.txtModuleOrder.Text)
                .ModuleOrder = Services.GetNULLableInteger(Me.txtModuleOrder.Text)
                .ImageType = Me.lblImageType.Text
                .ModuleType = Me.lblImageType.Text
                .ImageFile.AltText = .ImageType & " - " & .ImageOrder.ToString
                .PublishDate = Me.dtePublishDate.SelectedDate
                .ExpireDate = Me.dteExpireDate.SelectedDate

                ' now get petroferm home page nav on values if applicable
                If Me.IsPetroHomePageNavOnImage Then
                    .IsPetrofermHomePage = True
                    .WelcomeTitle = Me.txtWelcomeTitle.Text.Trim

                    Select Case True
                        Case Me.rdoUseCurrentWelcomeImage.Checked
                            .WelcomeImageID = CurrentWelcomeImageID
                            .WelcomeImageFile.ImageId = CurrentWelcomeImageID
                            .WelcomeImageFile.ImagePath = Me.imgCurrentWelcome.ImageUrl
                        Case Me.rdoUseExistingWelcomeImage.Checked
                            .WelcomeImageID = Services.GetNULLableInteger(Me.ddlExistingWelcomeImage.SelectedValue)
                            .WelcomeImageFile.ImageId = Services.GetNULLableInteger(Me.ddlExistingWelcomeImage.SelectedValue)
                            .WelcomeImageFile.Fill()
                    End Select

                    Select Case True
                        Case Me.rdoSingleLink.Checked
                            .WelcomeLinkPageID = Convert.ToInt32(Me.ddlSinglePage.SelectedValue)
                        Case Me.rdoMultipleLinks.Checked
                            Dim i As Integer
                            Dim sbPageId As New StringBuilder
                            Dim sbLinkText As New StringBuilder
                            For i = 1 To 6
                                Dim ddlPage As DropDownList = Nothing
                                Dim txtLinkText As TextBox = Nothing
                                ddlPage = Me.FindControl("ddlMultPage" & i.ToString)
                                txtLinkText = Me.FindControl("txtMultLinkText" & i.ToString)
                                If ddlPage IsNot Nothing And txtLinkText IsNot Nothing Then
                                    If ddlPage.SelectedValue <> "0" And txtLinkText.Text.Trim.Length > 0 Then
                                        sbPageID.Append(ddlPage.SelectedValue & "|")
                                        sbLinkText.Append(txtLinkText.Text.Trim & "|")
                                    End If
                                End If
                            Next
                            ' strip off last pipe
                            sbPageID.Remove(sbPageID.Length - 1, 1)
                            sbLinkText.Remove(sbLinkText.Length - 1, 1)
                            ' now set properties
                            .WelcomeLinkPageIDList = sbPageID.ToString
                            .WelcomeLinkTextList = sbLinkText.ToString

                    End Select
                End If

            End With
        End If



    End Sub

    Public Sub SetControlEnabledProperty(ByVal enable As Boolean)

        rdoExisting.Enabled = enable
        rdoUpload.Enabled = enable
        rdoUseCurrent.Enabled = enable
        ddlExistingImage.Enabled = enable
        fupImage.Enabled = enable
        txtModuleOrder.Enabled = enable
        dtePublishDate.Enabled = enable
        dteExpireDate.Enabled = enable

        Me.rdoUseCurrentWelcomeImage.Enabled = enable
        Me.rdoUseExistingWelcomeImage.Enabled = enable
        Me.rdoUploadNewWelcomeImage.Enabled = enable
        Me.txtWelcomeTitle.Enabled = enable
        Me.rdoSingleLink.Enabled = enable
        Me.ddlSinglePage.Enabled = enable
        Me.rdoMultipleLinks.Enabled = enable
        Me.ddlMultPage1.Enabled = enable
        Me.txtMultLinkText1.Enabled = enable
        Me.ddlMultPage2.Enabled = enable
        Me.txtMultLinkText2.Enabled = enable
        Me.ddlMultPage3.Enabled = enable
        Me.txtMultLinkText3.Enabled = enable
        Me.ddlMultPage4.Enabled = enable
        Me.txtMultLinkText4.Enabled = enable
        Me.ddlMultPage5.Enabled = enable
        Me.txtMultLinkText5.Enabled = enable
        Me.ddlMultPage6.Enabled = enable
        Me.txtMultLinkText6.Enabled = enable

    End Sub

    Public Function GetImagePath(ByVal imageType As String) As String
        Dim path As String = ""
        Select Case imageType.ToUpper
            Case "LOGO"
                path = SiteProfile.GetLogoImagePath("")
            Case "HEADER", "HEADER IMAGE", "HEADER SIDE CONTENT IMAGE"
                path = SiteProfile.GetHeaderImagePath("")
            Case "NAVIGATION ON", "NAVIGATION OFF", "NAV OFF IMAGE", "NAV ON IMAGE", "NAV IMAGE ON", "NAV IMAGE OFF"
                path = SiteProfile.GetNavImagePath("")
        End Select
        Return path
    End Function

    Public Function UploadImage(ByRef refreshImg As ImageFile, ByVal whichImage As String) As Boolean
        ' TODO: CMS - Specify correct path by image type

        'Dim path As String = Server.MapPath("~/web/files/images/logos/")
        Dim path As String = Server.MapPath("~/" & GetImagePath(Me.ImageType))
        Dim fileOk As Boolean = False
        If fupImage.HasFile And Me.rdoUpload.Checked Then
            Dim fileExtension As String
            fileExtension = System.IO.Path. _
                GetExtension(fupImage.FileName).ToLower()
            Dim allowedExtensions As String() = _
                {".jpg", ".jpeg", ".png", ".gif"}
            For i As Integer = 0 To allowedExtensions.Length - 1
                If fileExtension = allowedExtensions(i) Then
                    fileOK = True
                End If
            Next
            If fileOK Then
                Try
                    fupImage.PostedFile.SaveAs(path & _
                         fupImage.FileName)
                    '                    Label1.Text = "File uploaded!"
                    Select Case whichImage.ToUpper
                        Case "MAIN"
                            With imgCurrent
                                .ImageUrl = "~/" & GetImagePath(Me.ImageType) & fupImage.FileName
                                .Visible = True
                            End With
                            Me.rdoUseCurrent.Checked = True
                            ' now set the refreshed img object with the form values
                            'refreshImg = Me.GetFormValues
                            refreshImg.ImagePath = imgCurrent.ImageUrl
                        Case "WELCOME"
                            With imgCurrentWelcome
                                .ImageUrl = "~/" & GetImagePath(Me.ImageType) & fupImage.FileName
                                .Visible = True
                            End With
                            Me.rdoUseCurrentWelcomeImage.Checked = True
                            ' now set the refreshed img object with the form values
                            'refreshImg = Me.GetFormValues
                            refreshImg.ImagePath = imgCurrentWelcome.ImageUrl
                    End Select



                    Return True
                Catch ex As Exception
                    '                   Label1.Text = "File could not be uploaded."
                    Return False
                End Try
            Else
                Select Case whichImage.ToUpper
                    Case "MAIN"
                        imgCurrent.Visible = False
                    Case "WELCOME"
                        imgCurrentWelcome.Visible = False
                End Select
            End If
        Else
            Return True
        End If
    End Function

    Public Sub ResetForm()

        Me.rdoUseCurrent.Checked = False
        Me.rdoExisting.Checked = False
        Me.ddlExistingImage.ClearSelection()
        Me.rdoUpload.Checked = False
        Me.trCurrentImage.Visible = False
        Me.txtModuleOrder.Text = String.Empty
        hidImageID.Text = String.Empty

        Me.rdoUseCurrentWelcomeImage.Checked = False
        Me.rdoUseExistingWelcomeImage.Checked = False
        Me.rdoUploadNewWelcomeImage.Checked = False
        Me.txtWelcomeTitle.Text = String.Empty
        Me.rdoSingleLink.Checked = False
        Me.ddlSinglePage.ClearSelection()
        Me.rdoMultipleLinks.Checked = False
        Me.ddlMultPage1.ClearSelection()
        Me.txtMultLinkText1.Text = String.Empty
        Me.ddlMultPage2.ClearSelection()
        Me.txtMultLinkText2.Text = String.Empty
        Me.ddlMultPage3.ClearSelection()
        Me.txtMultLinkText3.Text = String.Empty
        Me.ddlMultPage4.ClearSelection()
        Me.txtMultLinkText4.Text = String.Empty
        Me.ddlMultPage5.ClearSelection()
        Me.txtMultLinkText5.Text = String.Empty
        Me.ddlMultPage6.ClearSelection()
        Me.txtMultLinkText6.Text = String.Empty

        dtePublishDate.SelectedDate = #12:00:00 AM#
        dteExpireDate.SelectedDate = #12:00:00 AM#

    End Sub

    Protected Sub ddlExistingImage_PreRender(ByVal sender As Object, ByVal e As System.EventArgs) Handles ddlExistingImage.PreRender
        ' add initial empty "select" module type item
        ' if it's not there already
        With Me.ddlExistingImage
            If .Items.Count > 0 Then
                If .Items(0).Value <> "0" Then
                    Dim li As New ListItem("-- Select Existing Image --", "0")
                    .Items.Insert(0, li)
                End If
            End If
        End With
    End Sub

    Protected Sub Page_PreRender(ByVal sender As Object, ByVal e As System.EventArgs) Handles Me.PreRender

    End Sub

    Protected Sub ddlExistingWelcomeImage_PreRender(ByVal sender As Object, ByVal e As System.EventArgs) Handles ddlExistingWelcomeImage.PreRender

        If ddlExistingWelcomeImage.Items(0).Value <> "0" Then
            ddlExistingWelcomeImage.Items.Insert(0, New ListItem("-- Select Existing Welcome Image  --", "0"))
        End If
    End Sub
End Class
