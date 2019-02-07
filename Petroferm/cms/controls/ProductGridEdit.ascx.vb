
Partial Class CmsControlsProductGridEdit
    Inherits System.Web.UI.UserControl
    Private _formMode As CMSFormUtils.FormMode = CMSFormUtils.FormMode.Read ' default to read
    Private _mCurrentProductGridModule As New ProductGridModule
    Public Property CurrentProductGridModule() As ProductGridModule
        Get
            Return _mCurrentProductGridModule
        End Get
        Set(ByVal value As ProductGridModule)
            _mCurrentProductGridModule = value
        End Set
    End Property

    Private Property CurrentProductGridModuleId() As Integer
        Get
            If ViewState("CurrentProductGridModuleID") IsNot Nothing Then
                Return Services.GetNULLableInteger(ViewState("CurrentProductGridModuleID"))
            Else
                Return 0
            End If
        End Get
        Set(ByVal value As Integer)
            ViewState("CurrentProductGridModuleID") = value
            'also set form control (for datasource)
            Me.hidProductGridModuleID.Text = value.ToString
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

    Private Property CurrentProductGridId() As Integer
        Get
            If ViewState("CurrentProductGridID") IsNot Nothing Then
                Return Services.GetNULLableInteger(ViewState("CurrentProductGridID"))
            Else
                Return 0
            End If
        End Get
        Set(ByVal value As Integer)
            ViewState("CurrentProductGridID") = value
            'also set form control (for datasource)
            Me.hidProductGridID.Text = value.ToString
        End Set
    End Property

    Protected Sub Page_Load(ByVal sender As Object, ByVal e As System.EventArgs) Handles Me.Load


        Me.Page.ClientScript.RegisterClientScriptBlock(Me.GetType, "selectall", SelectProductsJSBlock)

        If Not IsPostBack Then

            Me.btnAddProducts.Attributes.Add("onclick", "moveSelectedOptions(document.forms[0]['" & Me.lstProductsUnselected.ClientID & "'],document.forms[0]['" & Me.lstProductsSelected.ClientID & "'],false);return false;")
            Me.btnAddAllProducts.Attributes.Add("onclick", "moveAllOptions(document.forms[0]['" & Me.lstProductsUnselected.ClientID & "'],document.forms[0]['" & Me.lstProductsSelected.ClientID & "'],false);return false;")
            Me.btnRemoveProducts.Attributes.Add("onclick", "moveSelectedOptions(document.forms[0]['" & Me.lstProductsSelected.ClientID & "'],document.forms[0]['" & Me.lstProductsUnselected.ClientID & "'],false);return false;")
            Me.btnRemoveAllProducts.Attributes.Add("onclick", "moveAllOptions(document.forms[0]['" & Me.lstProductsSelected.ClientID & "'],document.forms[0]['" & Me.lstProductsUnselected.ClientID & "'],false);return false;")
            Me.btnMoveProductUp.Attributes.Add("onclick", "moveOptionUp(this.form['" & Me.lstProductsSelected.ClientID & "']);return false;")
            Me.btnMoveProductDown.Attributes.Add("onclick", "moveOptionDown(this.form['" & Me.lstProductsSelected.ClientID & "']);return false;")


            Me.btnAddAttributes.Attributes.Add("onclick", "moveSelectedOptions(document.forms[0]['" & Me.lstAttributesUnselected.ClientID & "'],document.forms[0]['" & Me.lstAttributesSelected.ClientID & "'],false);return false;")
            Me.btnAddAllAttributes.Attributes.Add("onclick", "moveAllOptions(document.forms[0]['" & Me.lstAttributesUnselected.ClientID & "'],document.forms[0]['" & Me.lstAttributesSelected.ClientID & "'],false);return false;")
            Me.btnRemoveAttributes.Attributes.Add("onclick", "moveSelectedOptions(document.forms[0]['" & Me.lstAttributesSelected.ClientID & "'],document.forms[0]['" & Me.lstAttributesUnselected.ClientID & "'],false);return false;")
            Me.btnRemoveAllAttributes.Attributes.Add("onclick", "moveAllOptions(document.forms[0]['" & Me.lstAttributesSelected.ClientID & "'],document.forms[0]['" & Me.lstAttributesUnselected.ClientID & "'],false);return false;")
            Me.btnMoveAttributeUp.Attributes.Add("onclick", "moveOptionUp(this.form['" & Me.lstAttributesSelected.ClientID & "']);return false;")
            Me.btnMoveAttributeDown.Attributes.Add("onclick", "moveOptionDown(this.form['" & Me.lstAttributesSelected.ClientID & "']);return false;")


        End If

    End Sub

    Public Function SetFormValues() As Boolean
        Me.ddlExistingGrid.DataBind() ' reset the dropdown for existing grids
        If CurrentProductGridModule IsNot Nothing Then
            With CurrentProductGridModule
                If .ProductGridModuleId <> 0 Then
                    Me.CurrentProductGridModuleID = .ProductGridModuleId
                    Me.CurrentPageModuleRelnID = .PageModuleRelnId
                    ' content id is set from calling page
                    txtProductGridTitle.Text = .ProductGridTitle
                    txtModuleOrder.Text = .ModuleOrder.ToString
                    Me.txtProductGridBlurb.Text = .ProductGridBlurb
                    Me.chkDisplayTitle.Checked = .ShowTitle
                    Me.txtProductGridName.Text = .ProductGrid.ProductGridName
                    Me.CurrentProductGridID = .ProductGrid.ProductGridID
                    ' rebind the listboxes
                    Me.lstAttributesSelected.DataBind()
                    Me.lstAttributesUnselected.DataBind()
                    Me.lstProductsSelected.DataBind()
                    Me.lstProductsUnselected.DataBind()

                    If .PublishDate <> #12:00:00 AM# Then
                        Me.dtePublishDate.SelectedDate = .PublishDate
                    End If
                    If .ExpireDate <> #12:00:00 AM# Then
                        Me.dteExpireDate.SelectedDate = .ExpireDate
                    End If

                    Me.CurrentProductGridModule.LiveModeStatus = WorkflowItem.LiveMode.CMS


                    Me.lblChooseGrid.Text = "Use a Different Grid"
                    phView.Controls.Add(New LiteralControl("<div>" & Me.CurrentProductGridModule.GetProductGrid & "</div>"))
                Else
                    Me.lblChooseGrid.Text = "Use an Existing Grid"
                    Me.lstAttributesSelected.DataBind()
                    Me.lstAttributesUnselected.DataBind()
                    Me.lstProductsSelected.DataBind()
                    Me.lstProductsUnselected.DataBind()

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
        With CurrentProductGridModule
            .ProductGridModuleID = Me.CurrentProductGridModuleID
            .PageModuleRelnId = Me.CurrentPageModuleRelnID
            .ModuleType = "PRODUCT GRID"
            .ModuleOrder = Services.GetNULLableInteger(txtModuleOrder.Text)
            .ProductGridTitle = Me.txtProductGridTitle.Text.Trim
            .ShowTitle = Me.chkDisplayTitle.Checked
            .ProductGridBlurb = Me.txtProductGridBlurb.Text.Trim
            .ProductGrid.ProductGridID = Me.CurrentProductGridID
            .ProductGrid.ProductGridName = Me.txtProductGridName.Text.Trim
            .ProductGrid.BusUnitID = Services.GetNULLableInteger(Session("BusUnitID"))
            .ProductGrid.AttributeColumnList = Request.Form(Me.lstAttributesSelected.Name)
            .ProductGrid.ProductRowList = Request.Form(Me.lstProductsSelected.Name)
            .PublishDate = Me.dtePublishDate.SelectedDate
            .ExpireDate = Me.dteExpireDate.SelectedDate
        End With
    End Sub

    Public Sub SetControlEnabledProperty(ByVal enable As Boolean)

        txtProductGridTitle.Enabled = enable
        txtModuleOrder.Enabled = enable
        dtePublishDate.Enabled = enable
        dteExpireDate.Enabled = enable
        chkDisplayTitle.Enabled = enable

        txtProductGridBlurb.Enabled = enable
        lstProductsSelected.Disabled = Not enable
        lstProductsUnselected.Disabled = Not enable
        lstAttributesSelected.Disabled = Not enable
        lstAttributesUnselected.Disabled = Not enable
        txtProductGridName.Enabled = enable
        ddlExistingGrid.Enabled = enable

        Me.btnAddAllAttributes.Enabled = enable
        Me.btnAddAllProducts.Enabled = enable
        Me.btnAddAttributes.Enabled = enable
        Me.btnAddProducts.Enabled = enable
        Me.btnMoveAttributeDown.Enabled = enable
        Me.btnMoveAttributeUp.Enabled = enable
        Me.btnMoveProductDown.Enabled = enable
        Me.btnMoveProductUp.Enabled = enable
        Me.btnRemoveAttributes.Enabled = enable
        Me.btnRemoveAllProducts.Enabled = enable
        Me.btnRemoveAllAttributes.Enabled = enable
        Me.btnRemoveProducts.Enabled = enable

    End Sub

    ''' <summary>
    ''' This sets the form mode based on mode specified
    ''' </summary>
    ''' <param name="mode"></param>
    ''' <remarks></remarks>
    Public Sub SetFormMode(ByVal mode As CMSFormUtils.FormMode)
        Select Case mode
            Case CMSFormUtils.FormMode.Edit
                Me.lblFormLabel.Text = "Add/Edit Product Grid Module"
                SetControlEnabledProperty(True)
            Case CMSFormUtils.FormMode.Read
                Me.lblFormLabel.Text = "View Product Grid Module"
                SetControlEnabledProperty(False)
        End Select
    End Sub

    Public Sub ResetForm()
        ' now clear out the form
        txtProductGridTitle.Text = String.Empty
        dtePublishDate.SelectedDate = #12:00:00 AM#
        dteExpireDate.SelectedDate = #12:00:00 AM#

        Me.chkDisplayTitle.Checked = False
        Me.txtModuleOrder.Text = String.Empty
        Me.txtProductGridBlurb.Text = String.Empty
        Me.txtProductGridName.Text = String.Empty

        ' Me.lstProductsSelected.ClearSelection()
        '  Me.lstProductsUnselected.ClearSelection()

        'Me.lstProductsSelected.Items.Clear()
        'Me.lstProductsUnselected.Items.Clear()
        'Me.lstProductsSelected.ClearSelection()
        ' Me.lstProductsUnselected.ClearSelection()


        Me.hidProductGridID.Text = String.Empty
        Me.hidProductGridModuleID.Text = String.Empty

        Me.CurrentProductGridModule = Nothing
        Me.CurrentPageModuleRelnID = 0
        Me.CurrentProductGridModuleID = 0
        Me.CurrentProductGridID = 0
        Me.phView.Controls.Clear()

        Me.trGridName.Visible = True
        Me.trProductSelection.Visible = True
        Me.trAttributeSelection.Visible = True
        Me.ddlExistingGrid.ClearSelection()

    End Sub

    Public Function SelectProductsJsBlock() As String
        Dim js As New StringBuilder
        With js
            .Append("<script language=""javascript"">" & vbCrLf)
            .Append("function selectAll() { ")
            .Append("  for (var i = 0; i < document.forms[0]['" & Me.lstProductsSelected.ClientID & "'].options.length; i++)")
            .Append("  {  var p = document.forms[0]['" & Me.lstProductsSelected.ClientID & "'].options[i];")
            .Append("     p.selected = true; } " & vbCrLf)
            .Append("  for (var j = 0; j < document.forms[0]['" & Me.lstAttributesSelected.ClientID & "'].options.length; j++)")
            .Append("  {  var a = document.forms[0]['" & Me.lstAttributesSelected.ClientID & "'].options[j];")
            .Append("     a.selected = true;  }}</script>" & vbCrLf)
            .Append("")
        End With
        Return js.ToString
    End Function

    Protected Sub ddlExistingGrid_PreRender(ByVal sender As Object, ByVal e As System.EventArgs) Handles ddlExistingGrid.PreRender
        ' add initial empty "select" module type item
        ' if it's not there already
        With Me.ddlExistingGrid
            If .Items.Count > 0 Then
                If .Items(0).Value <> "0" Then
                    Dim li As New ListItem
                    li.Value = "0"
                    If Me.CurrentProductGridID = 0 Then
                        li.Text = "-- Select Existing Product Grid --"
                    Else
                        li.Text = "-- Use Another Product Grid --"
                    End If
                    .Items.Insert(0, li)
                End If
            End If
        End With
    End Sub

    Protected Sub ddlExistingGrid_SelectedIndexChanged(ByVal sender As Object, ByVal e As System.EventArgs) Handles ddlExistingGrid.SelectedIndexChanged
        If Me.ddlExistingGrid.SelectedValue <> "0" Then
            ' fill in the form values
            Me.CurrentProductGridID = Services.GetNULLableInteger(Me.ddlExistingGrid.SelectedValue)
            Me.CurrentProductGridModule.ProductGrid.ProductGridID = Me.CurrentProductGridID
            Me.CurrentProductGridModule.ProductGrid.Fill(0)
            Me.txtProductGridName.Text = CurrentProductGridModule.ProductGrid.ProductGridName
            ' rebind the listboxes
            Me.lstAttributesSelected.DataBind()
            Me.lstAttributesUnselected.DataBind()
            Me.lstProductsSelected.DataBind()
            Me.lstProductsUnselected.DataBind()
        Else
            ' fill in the form values
            ' TODO: CMS - Product Grid Module - Deselecting an existing grid clears out the grid info
            Me.CurrentProductGridID = 0
            Me.CurrentProductGridModule.ProductGrid.ProductGridID = 0
            Me.txtProductGridName.Text = String.Empty
            ' rebind the listboxes
            Me.lstAttributesSelected.DataBind()
            Me.lstAttributesUnselected.DataBind()
            Me.lstProductsSelected.DataBind()
            Me.lstProductsUnselected.DataBind()

        End If
    End Sub
End Class
