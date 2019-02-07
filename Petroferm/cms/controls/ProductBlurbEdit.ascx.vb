
Partial Class CmsControlsProductBlurbEdit
    Inherits System.Web.UI.UserControl
    Private _formMode As CMSFormUtils.FormMode = CMSFormUtils.FormMode.Read ' default to read
    Private _mCurrentProductBlurbModule As New ProductBlurbModule
    Public Property CurrentProductBlurbModule() As ProductBlurbModule
        Get
            Return _mCurrentProductBlurbModule
        End Get
        Set(ByVal value As ProductBlurbModule)
            _mCurrentProductBlurbModule = value
        End Set
    End Property

    Private Property CurrentProductBlurbModuleId() As Integer
        Get
            If ViewState("CurrentProductBlurbModuleID") IsNot Nothing Then
                Return Services.GetNULLableInteger(ViewState("CurrentProductBlurbModuleID"))
            Else
                Return 0
            End If
        End Get
        Set(ByVal value As Integer)
            ViewState("CurrentProductBlurbModuleID") = value
            'also set form control (for datasource)
            Me.hidProductBlurbModuleID.Text = value.ToString
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

        If CurrentProductBlurbModule IsNot Nothing Then
            With CurrentProductBlurbModule
                If .ProductBlurbModuleId <> 0 Then
                    Me.CurrentProductBlurbModuleID = .ProductBlurbModuleId
                    Me.CurrentPageModuleRelnID = .PageModuleRelnId
                    ' content id is set from calling page
                    txtTitle.Text = .Title
                    txtModuleOrder.Text = .ModuleOrder.ToString

                    Me.chkDisplayTitle.Checked = .ShowTitle
                    Me.ddlProductBlurbType.SelectedValue = .ProductSelection

                    Select Case Me.ddlProductBlurbType.SelectedValue.ToUpper
                        Case "INDIVIDUAL"
                            Me.trProductBlurb.Visible = False
                            Me.trProductSelection.Visible = True
                            Me.tblMultipleProductSelection.Visible = False
                            Me.ddlProductSelected.Visible = True
                            If ddlProductSelected.Items.FindByValue(.SourceID.ToString) IsNot Nothing Then
                                Me.ddlProductSelected.SelectedValue = .SourceID.ToString
                            End If
                        Case "MULTIPLE"
                            Me.trProductBlurb.Visible = True
                            Me.trProductSelection.Visible = True
                            Me.tblMultipleProductSelection.Visible = True
                            Me.ddlProductSelected.Visible = False
                            Me.txtProductBlurb.Text = .ProductBlurb.ToString
                            Me.lstProductsSelected.DataBind()
                            Me.lstProductsUnselected.DataBind()
                    End Select



                    If .PublishDate <> #12:00:00 AM# Then
                        Me.dtePublishDate.SelectedDate = .PublishDate
                    End If
                    If .ExpireDate <> #12:00:00 AM# Then
                        Me.dteExpireDate.SelectedDate = .ExpireDate
                    End If
                Else
                    ' default values
                    Me.dtePublishDate.SelectedDate = Today.Date
                    Me.dteExpireDate.SelectedDate = Today.Date.AddYears(30)
                End If


            End With
        End If
    End Function

    ''' <summary>
    ''' Gets all values from the form and sets it to the content module property
    ''' </summary>
    ''' <remarks></remarks>
    Public Sub GetFormValues()
        With CurrentProductBlurbModule
            .ProductBlurbModuleId = Me.CurrentProductBlurbModuleID
            .PageModuleRelnId = Me.CurrentPageModuleRelnID
            .ModuleType = "PRODUCT BLURB"
            ' fixed value for module order
            .ModuleOrder = Services.GetNULLableInteger(txtModuleOrder.Text)
            .Title = Me.txtTitle.Text
            .ShowTitle = Me.chkDisplayTitle.Checked
            .ProductSelection = Me.ddlProductBlurbType.SelectedValue.ToUpper
            Select Case Me.ddlProductBlurbType.SelectedValue.ToUpper
                Case "INDIVIDUAL"
                    .SourceID = Services.GetNULLableInteger(Me.ddlProductSelected.SelectedValue)
                Case "MULTIPLE"
                    .ProductBlurb = Me.txtProductBlurb.Text.Trim
                    '.ProductIDList = Request.Form(lstProductsSelected.ClientID)
                    Dim li As ListItem
                    Dim productList As New StringBuilder
                    For Each li In Me.lstProductsSelected.Items
                        productList.Append(li.Value & ",")
                    Next
                    productList.Remove(productList.ToString.Length - 1, 1)
                    .ProductIDList = productList.ToString
            End Select

            .PublishDate = Me.dtePublishDate.SelectedDate
            .ExpireDate = Me.dteExpireDate.SelectedDate

        End With
    End Sub

    Public Sub SetControlEnabledProperty(ByVal enable As Boolean)

        txtTitle.Enabled = enable
        txtModuleOrder.Enabled = enable
        dtePublishDate.Enabled = enable
        dteExpireDate.Enabled = enable
        chkDisplayTitle.Enabled = enable
        ddlProductBlurbType.Enabled = enable
        ddlProductSelected.Enabled = enable
        txtProductBlurb.Enabled = enable
        lstProductsSelected.Enabled = enable
        lstProductsUnselected.Enabled = enable
    End Sub

    ''' <summary>
    ''' This sets the form mode based on mode specified
    ''' </summary>
    ''' <param name="mode"></param>
    ''' <remarks></remarks>
    Public Sub SetFormMode(ByVal mode As CMSFormUtils.FormMode)
        Select Case mode
            Case CMSFormUtils.FormMode.Edit
                Me.lblFormLabel.Text = "Add/Edit Product Blurb Module"
                SetControlEnabledProperty(True)
            Case CMSFormUtils.FormMode.Read
                Me.lblFormLabel.Text = "View Product Blurb Module"
                SetControlEnabledProperty(False)
        End Select
    End Sub

    Public Sub ResetForm()
        ' now clear out the form
        txtTitle.Text = String.Empty
        dtePublishDate.SelectedDate = #12:00:00 AM#
        dteExpireDate.SelectedDate = #12:00:00 AM#

        Me.chkDisplayTitle.Checked = False
        Me.txtModuleOrder.Text = String.Empty
        Me.txtProductBlurb.Text = String.Empty

        Me.ddlProductBlurbType.ClearSelection()
        Me.lstProductsSelected.ClearSelection()
        Me.lstProductsUnselected.ClearSelection()
        Me.ddlProductSelected.ClearSelection()

        Me.lstProductsSelected.Items.Clear()
        Me.lstProductsUnselected.Items.Clear()
        Me.lstProductsSelected.ClearSelection()
        Me.lstProductsUnselected.ClearSelection()

        Me.trProductBlurb.Visible = False
        Me.trProductSelection.Visible = False

        Me.CurrentProductBlurbModule = Nothing
        Me.CurrentPageModuleRelnID = 0
        Me.CurrentProductBlurbModuleID = 0
    End Sub


    Protected Sub ddlProductBlurbType_SelectedIndexChanged(ByVal sender As Object, ByVal e As System.EventArgs) Handles ddlProductBlurbType.SelectedIndexChanged
        ' display the appropriate fields based on what blurb type it is
        Select Case Me.ddlProductBlurbType.SelectedValue.ToUpper
            Case "INDIVIDUAL"
                Me.trProductBlurb.Visible = False
                Me.trProductSelection.Visible = True
                Me.tblMultipleProductSelection.Visible = False
                Me.ddlProductSelected.Visible = True
            Case "MULTIPLE"
                Me.trProductBlurb.Visible = True
                Me.trProductSelection.Visible = True
                Me.tblMultipleProductSelection.Visible = True
                Me.ddlProductSelected.Visible = False
                Me.lstProductsSelected.DataBind()
                Me.lstProductsUnselected.DataBind()
        End Select
    End Sub

    Protected Sub Page_Load(ByVal sender As Object, ByVal e As System.EventArgs) Handles Me.Load


        ' set onclick events for > and < buttons for multi-product blurbs
        'Me.btnAddProducts.Attributes.Add("onclick", "moveSelectedOptions(document.forms[0]['" & Me.lstProductsUnselected.ClientID & "'],document.forms[0]['" & Me.lstProductsSelected.ClientID & "'],false);return false;")
        'Me.btnRemoveProducts.Attributes.Add("onclick", "moveSelectedOptions(document.forms[0]['" & Me.lstProductsSelected.ClientID & "'],document.forms[0]['" & Me.lstProductsUnselected.ClientID & "'],false);return false;")

        ' Me.Page.ClientScript.RegisterClientScriptBlock(Me.GetType, "selectall", SelectProductsJSBlock)

    End Sub

    Public Function SelectProductsJsBlock() As String
        Dim js As New StringBuilder
        With js
            '.Append("<script language=""javascript"">function selectAllProducts() {")
            '.Append("    window.alert('kelly');")
            '.Append("  for (var = 0; document.forms[0]['" & Me.lstProductsSelected.ClientID & "'].options.length; i++)")
            '.Append("     var o = document.forms[0]['" & Me.lstProductsSelected.ClientID & "'].options[i];")
            '.Append("     o.selected = true; } }</script>")

        End With
        Return js.ToString
    End Function

    Protected Sub ddlProductSelected_PreRender(ByVal sender As Object, ByVal e As System.EventArgs) Handles ddlProductSelected.PreRender
        ' add initial empty "select" module type item
        ' if it's not there already
        With Me.ddlProductSelected
            If .Items.Count > 0 Then
                If .Items(0).Value <> "0" Then
                    Dim li As New ListItem("-- Select Product --", "0")
                    .Items.Insert(0, li)
                End If
            End If
        End With
    End Sub

    Protected Sub btnAddProducts_Click(ByVal sender As Object, ByVal e As System.EventArgs) Handles btnAddProducts.Click
        Dim li As ListItem
 Dim removeItems As New ListItemCollection

        Dim i As Integer = 0
        For Each li In Me.lstProductsUnselected.Items
            If li.Selected Then
                removeItems.Add(li)
            End If
        Next

        For Each li In removeItems
            Me.lstProductsUnselected.Items.Remove(li)
        Next

        For Each li In removeItems
            Me.lstProductsSelected.Items.Add(li)
        Next

        Me.lstProductsSelected.ClearSelection()
        Me.lstProductsUnselected.ClearSelection()

    End Sub

    Protected Sub btnRemoveProducts_Click(ByVal sender As Object, ByVal e As System.EventArgs) Handles btnRemoveProducts.Click
        Dim li As ListItem
        Dim removeItems As New ListItemCollection
        For Each li In Me.lstProductsSelected.Items
            If li.Selected Then
                removeItems.Add(li)
            End If
        Next
        For Each li In removeItems
            Me.lstProductsSelected.Items.Remove(li)
        Next

        For Each li In removeItems
            Me.lstProductsUnselected.Items.Add(li)
        Next

        Me.lstProductsSelected.ClearSelection()
        Me.lstProductsUnselected.ClearSelection()


    End Sub
End Class
