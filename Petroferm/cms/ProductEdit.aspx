<%@ Page Language="VB" MasterPageFile="~/cms/MasterCMS.master" AutoEventWireup="false" CodeFile="ProductEdit.aspx.vb" Inherits="CmsProductEdit" Title="Untitled Page" Theme="CMS_Theme" StylesheetTheme="CMS_Theme" validateRequest="false" Debug="true" %>
<%@ Register Assembly="WYSIWYGEditor" Namespace="InnovaStudio" TagPrefix="cc1" %>
<%@ MasterType TypeName="MasterCMS" %>
<%@ Register TagPrefix="ew" Namespace="eWorld.UI" Assembly="eWorld.UI" %>
<%@ Register Src="controls/WorkflowInfo.ascx" TagName="WorkflowInfo" TagPrefix="uc1" %>



<asp:Content ID="Content1" ContentPlaceHolderID="phMain" runat="Server">
    <asp:Label ID="lblMessage" runat="server"></asp:Label>
    <asp:Wizard ID="wzForm" runat="server" ActiveStepIndex="1" Height="174px" Width="800px"
        DisplayCancelButton="True">
        <SideBarStyle Width="125px" />
        <WizardSteps>
            <asp:WizardStep runat="server" Title="1 - General Info" ID="GeneralInfo">
            <asp:Label ID="lblInstructionsStep1" runat="server"></asp:Label>
                <asp:TextBox ID="hidGeneralInfoReadOnly" runat="server" Visible="False" Width="43px">False</asp:TextBox>
                <table id="TABLE1" style="vertical-align: top;">
                    <tr valign="top">
                        <td style="height: 12px;" class="formFieldLabel" valign="middle">
                            Product Name</td>
                        <td style="width: 558px; height: 12px;" valign="middle">
                            <asp:TextBox ID="txtProductName" runat="server" MaxLength="200" Width="300px"></asp:TextBox>
                            <asp:RequiredFieldValidator ID="vldNameRequired" runat="server" Display="Dynamic"
                                ErrorMessage="Name is required." ControlToValidate="txtProductName"></asp:RequiredFieldValidator>
                            &nbsp;
                        </td>
                    </tr>
                    <tr valign="top">
                        <td class="formFieldLabel" valign="top" style="height: 26px">
                            Keywords<br />
                        </td>
                        <td style="width: 558px; height: 26px" valign="middle">
                            <asp:TextBox ID="txtKeywords" runat="server" MaxLength="200" Rows="3" Width="368px"
                                Height="90px" TextMode="MultiLine"></asp:TextBox>
                        </td>
                    </tr>
                    <tr valign="top">
                        <td valign="top">
                            <div class="formFieldLabel">Blurb</div>
                            <div class="smallCaption">
                            This will be used for product search results.
                            </div>
                        </td>
                        <td style="width: 558px; height: 26px" valign="top">
                            <asp:TextBox ID="txtBlurb" runat="server" Height="84px" MaxLength="200" Rows="3"
                                Width="367px" TextMode="MultiLine"></asp:TextBox>
                            <asp:RequiredFieldValidator ID="RequiredFieldValidator1" runat="server" ControlToValidate="txtBlurb"
                                Display="Dynamic" ErrorMessage="Blurb is required."></asp:RequiredFieldValidator>
                        </td>
                    </tr>
                    <tr valign="top">
                        <td class="formFieldLabel" style="width: 103px; height: 17px" valign="top">
                            Approvals</td>
                        <td style="width: 558px; height: 17px" valign="middle">
                            <asp:PlaceHolder ID="phApprovalsEditor" runat="server"></asp:PlaceHolder>
                            &nbsp;
                        </td>
                    </tr>
                    <tr style="color: #000000">
                        <td style="width: 103px; height: 26px;" class="formFieldLabel">
                            Publish Date</td>
                        <td style="width: 558px; height: 26px;">
                            <ew:CalendarPopup ID="dtePublishDate" runat="server" AllowArbitraryText="False" BackColor="White"
                                BorderColor="Silver" CellPadding="2px" CellSpacing="0px" ControlDisplay="TextBoxImage"
                                Culture="English (United States)" DisableTextboxEntry="False" DisplayOffsetX="20"
                                EnableHideDropDown="True" ImageUrl="~/App_Themes/CMS_Theme/images/calendar-ew.gif"
                                JavascriptOnChangeFunction="" LowerBoundDate="" Nullable="True" PadSingleDigits="True"
                                SelectedDate="" ShowClearDate="True" Text=" " UpperBoundDate="12/31/9999 23:59:59"
                                Width="75px">
                                <TodayDayStyle BackColor="LightGoldenrodYellow" Font-Names="Verdana,Helvetica,Tahoma,Arial"
                                    Font-Size="XX-Small" ForeColor="Black" />
                                <WeekendStyle BackColor="LightGray" Font-Names="Verdana,Helvetica,Tahoma,Arial" Font-Size="XX-Small"
                                    ForeColor="Black" />
                                <OffMonthStyle BackColor="AntiqueWhite" Font-Names="Verdana,Helvetica,Tahoma,Arial"
                                    Font-Size="XX-Small" ForeColor="Gray" />
                                <WeekdayStyle BackColor="White" Font-Names="Verdana,Helvetica,Tahoma,Arial" Font-Size="XX-Small"
                                    ForeColor="Black" />
                                <SelectedDateStyle BackColor="Yellow" Font-Names="Verdana,Helvetica,Tahoma,Arial"
                                    Font-Size="XX-Small" ForeColor="Black" />
                                <MonthHeaderStyle CssClass="popupCalendarMonthHeader" Font-Names="Verdana,Helvetica,Tahoma,Arial"
                                    Font-Size="XX-Small" ForeColor="Black" />
                                <GoToTodayStyle BackColor="White" Font-Names="Verdana,Helvetica,Tahoma,Arial" Font-Size="XX-Small"
                                    ForeColor="Black" />
                                <DayHeaderStyle CssClass="popupCalendarDayHeader" Font-Names="Verdana,Helvetica,Tahoma,Arial"
                                    Font-Size="XX-Small" ForeColor="Black" />
                                <ClearDateStyle BackColor="White" Font-Names="Verdana,Helvetica,Tahoma,Arial" Font-Size="XX-Small"
                                    ForeColor="Black" />
                            </ew:CalendarPopup>
                            &nbsp;&nbsp;
                            <asp:CompareValidator ID="vldPublishDateValid" runat="server" ControlToValidate="dtePublishDate"
                                Display="Dynamic" ErrorMessage="Valid publish date is required." Operator="DataTypeCheck"
                                Type="Date"></asp:CompareValidator>
                        </td>
                    </tr>
                    <tr>
                        <td class="formFieldLabel" style="width: 103px; height: 26px">
                            Expiration Date</td>
                        <td style="width: 558px; height: 26px">
                            <ew:CalendarPopup ID="dteExpireDate" runat="server" AllowArbitraryText="False" BackColor="White"
                                BorderColor="Silver" CellPadding="2px" CellSpacing="0px" ControlDisplay="TextBoxImage"
                                Culture="English (United States)" DisableTextboxEntry="False" DisplayOffsetX="20"
                                EnableHideDropDown="True" ImageUrl="~/App_Themes/CMS_Theme/images/calendar-ew.gif"
                                JavascriptOnChangeFunction="" LowerBoundDate="" Nullable="True" PadSingleDigits="True"
                                SelectedDate="" ShowClearDate="True" Text=" " UpperBoundDate="12/31/9999 23:59:59"
                                Width="75px">
                                <TodayDayStyle BackColor="LightGoldenrodYellow" Font-Names="Verdana,Helvetica,Tahoma,Arial"
                                    Font-Size="XX-Small" ForeColor="Black" />
                                <WeekendStyle BackColor="LightGray" Font-Names="Verdana,Helvetica,Tahoma,Arial" Font-Size="XX-Small"
                                    ForeColor="Black" />
                                <OffMonthStyle BackColor="AntiqueWhite" Font-Names="Verdana,Helvetica,Tahoma,Arial"
                                    Font-Size="XX-Small" ForeColor="Gray" />
                                <WeekdayStyle BackColor="White" Font-Names="Verdana,Helvetica,Tahoma,Arial" Font-Size="XX-Small"
                                    ForeColor="Black" />
                                <SelectedDateStyle BackColor="Yellow" Font-Names="Verdana,Helvetica,Tahoma,Arial"
                                    Font-Size="XX-Small" ForeColor="Black" />
                                <MonthHeaderStyle CssClass="popupCalendarMonthHeader" Font-Names="Verdana,Helvetica,Tahoma,Arial"
                                    Font-Size="XX-Small" ForeColor="Black" />
                                <GoToTodayStyle BackColor="White" Font-Names="Verdana,Helvetica,Tahoma,Arial" Font-Size="XX-Small"
                                    ForeColor="Black" />
                                <DayHeaderStyle CssClass="popupCalendarDayHeader" Font-Names="Verdana,Helvetica,Tahoma,Arial"
                                    Font-Size="XX-Small" ForeColor="Black" />
                                <ClearDateStyle BackColor="White" Font-Names="Verdana,Helvetica,Tahoma,Arial" Font-Size="XX-Small"
                                    ForeColor="Black" />
                            </ew:CalendarPopup>
                            &nbsp; &nbsp;<asp:CompareValidator ID="vldExpireDateValid" runat="server" ControlToValidate="dteExpireDate"
                                Display="Dynamic" ErrorMessage="Valid expiration date is required." Operator="DataTypeCheck"
                                Type="Date"></asp:CompareValidator>
                        </td>
                    </tr>
                </table>
            </asp:WizardStep>
            <asp:WizardStep ID="Attributes" runat="server" Title="2 - Attributes">
                <asp:Label ID="lblInstructionsStep2" runat="server"></asp:Label>
                <table id="Table4" style="width: 650px; vertical-align: top;" height="100%">
                    <tr valign="top">
                        <td colspan="2" style="height: 18px">
                            <asp:Label ID="lblNameStep2" runat="server" CssClass="formFieldLabel">Product Name</asp:Label>
                            &nbsp;
                            <asp:Label ID="lblProductNameStep2" runat="server"></asp:Label>
                        </td>
                    </tr>
                    <tr style="color: #000000" valign="top">
                        <td colspan="2" style="text-align: left;width:650px;">
                            <asp:Panel runat="server" ID="pnlAddEditAttribValue" Width="100%">
                                <asp:Label ID="lblAttributeValue" runat="server" Width="319px" CssClass="subFormTitle">Add Attribute Value</asp:Label>
                                &nbsp;
                                <table border="0" style="border-right: silver thin solid; border-top: silver thin solid;
                                    border-left: silver thin solid; width: 650px; border-bottom: silver thin solid">
                                    <tr>
                                        <td style="width: 46px; text-align: left" class="formFieldLabel">
                                            Attribute</td>
                                        <td style="width: 596px; text-align: left;">
                                            &nbsp;<asp:DropDownList ID="ddlAttribute" runat="server" DataSourceID="ProdAttribDS"
                                                DataTextField="AttribName" DataValueField="AttribTypeID" AutoPostBack="True">
                                            </asp:DropDownList>
                                            <asp:Label ID="lblAttributeName" runat="server"></asp:Label>
                                            <asp:TextBox ID="hidProdAttribRelnID" runat="server" Visible="False" Width="1px"></asp:TextBox>
                                            <asp:TextBox ID="hidAttribTypeID" runat="server" Visible="False" Width="1px"></asp:TextBox>
                                            <asp:ObjectDataSource ID="ProdAttribDS" runat="server" SelectMethod="GetList" TypeName="ProductAttribute">
                                                <SelectParameters>
                                                    <asp:SessionParameter Name="busUnitId" SessionField="BusUnitID" Type="Int32" />
                                                </SelectParameters>
                                            </asp:ObjectDataSource>
                                        </td>
                                    </tr>
                                    <tr>
                                        <td style="width: 46px; text-align: left" valign="top" class="formFieldLabel">
                                            <asp:Label ID="lblValue" runat="server" Visible="False">Value</asp:Label>
                                        </td>
                                        <td style="width: 596px">
                                            <table>
                                                <tr>
                                                    <td style="text-align: left; width: 450px;">
                                                        <asp:RadioButton ID="rdoNewValue" runat="server" Text="Enter new value:" GroupName="ValueType"
                                                            Checked="True" Visible="False" Width="150px" />
                                                        <asp:TextBox ID="txtNewValue" runat="server" Width="275px" Visible="False"></asp:TextBox>
                                                    </td>
                                                </tr>
                                                <tr>
                                                    <td style="width: 202px">
                                                        <asp:RadioButton ID="rdoExistingValue" runat="server" Text="Select existing value:"
                                                            GroupName="ValueType" Visible="False" Width="150px" />
                                                        <asp:DropDownList ID="ddlValues" runat="server" Visible="False" Width="275px">
                                                        </asp:DropDownList>
                                                        <asp:ListBox ID="lstValues" runat="server" SelectionMode="Multiple" Visible="False" Width="275px">
                                                        </asp:ListBox>
                                                    </td>
                                                </tr>
                                            </table>
                                        </td>
                                    </tr>
                                    <tr>
                                        <td style="text-align: center;" colspan="2">
                                            <asp:Button ID="btnSaveAttribValue" runat="server" Text="Add Attribute Value" SkinID="WizardButton"
                                                Visible="False" />
                                            &nbsp; &nbsp;
                                            <asp:Button ID="btnCancelSaveAttrib" runat="server" Text="Cancel" SkinID="WizardButton"
                                                Visible="False" />
                                        </td>
                                    </tr>
                                </table>
                            </asp:Panel>
                        </td>
                    </tr>
                    <tr style="color: #000000" valign="top">
                        <td colspan="2" rowspan="1">
                            <asp:GridView ID="gvAttribValues" runat="server" AllowPaging="True" AllowSorting="True"
                                AutoGenerateColumns="False" DataKeyNames="ProdAttribRelnID" EnableTheming="True"
                                DataSourceID="ProductAttributeValuesDS" EnableViewState="False">
                                <Columns>
                                    <asp:TemplateField>
                                        <ItemTemplate>
                                            <asp:ImageButton ID="ibtnDelete" runat="server" AlternateText="Delete" CommandArgument='<%# Eval("ProdAttribRelnID") %>'
                                                CommandName="DeleteItem" ImageUrl="../App_Themes/CMS_Theme/images/delcnt.gif" />
                                        </ItemTemplate>
                                    </asp:TemplateField>
                                    <asp:TemplateField>
                                        <ItemTemplate>
                                            <asp:ImageButton ID="ibtnEdit" runat="server" AlternateText="Edit" CommandArgument='<%# Eval("ProdAttribRelnID") %>'
                                                CommandName="EditItem" ImageUrl="../App_Themes/CMS_Theme/images/edit.gif" />
                                        </ItemTemplate>
                                    </asp:TemplateField>
                                    <asp:BoundField DataField="AttribName" HeaderText="Attribute Name" SortExpression="AttribName" />
                                    <asp:BoundField DataField="AttribValue" HeaderText="Attribute Value" SortExpression="AttribValue" />
                                    <asp:BoundField DataField="WorkflowStatus" HeaderText="Workflow Status" SortExpression="WorkflowStatus">
                                        <ItemStyle HorizontalAlign="Center" />
                                    </asp:BoundField>
                                    <asp:BoundField DataField="PublishDate" DataFormatString="{0:d}" HeaderText="Publish Date"
                                        HtmlEncode="False" SortExpression="PublishDate">
                                        <ItemStyle HorizontalAlign="Center" />
                                    </asp:BoundField>
                                    <asp:BoundField DataField="ExpirationDate" DataFormatString="{0:d}" HeaderText="Expire Date"
                                        HtmlEncode="False" SortExpression="ExpirationDate">
                                        <ItemStyle HorizontalAlign="Center" />
                                    </asp:BoundField>
                                    <asp:BoundField DataField="JobName" HeaderText="Job Name" SortExpression="JobName" />
                                    <asp:BoundField DataField="LastModifiedDate" DataFormatString="{0:g}" HeaderText="Last Modified"
                                        HtmlEncode="False" SortExpression="LastModifiedDate">
                                        <ItemStyle HorizontalAlign="Center" Width="60px" />
                                    </asp:BoundField>
                                    <asp:BoundField DataField="FmtMarkedForDeletion" HeaderText="Marked for Deletion"
                                        SortExpression="FmtMarkedForDeletion">
                                        <ItemStyle HorizontalAlign="Center" Width="65px" />
                                    </asp:BoundField>
                                </Columns>
                            </asp:GridView>
                            &nbsp;
                            <asp:ObjectDataSource ID="ProductAttributeValuesDS" runat="server" SelectMethod="GetList"
                                TypeName="ProductAttributeValue">
                                <SelectParameters>
                                    <asp:ControlParameter ControlID="hidProductID" Name="prodId" PropertyName="Text"
                                        Type="Int32" />
                                </SelectParameters>
                            </asp:ObjectDataSource>
                        </td>
                    </tr>
                </table>
            </asp:WizardStep>
            <asp:WizardStep runat="server" Title="3 - Search Attributes" ID="SearchAttributes">
            <asp:Label ID="lblInstructionsStep3" runat="server"></asp:Label>
                <table id="tblSearchAttribs" style="vertical-align: top;" height="100%" border="0">
                    <tr valign="top">
                        <td colspan="2">
                            <asp:Label ID="lblNameStep3" runat="server" CssClass="formFieldLabel">Product Name</asp:Label>&nbsp;&nbsp;<asp:Label
                                ID="lblProductNameStep3" runat="server"></asp:Label>
                        </td>
                    </tr>
                    <tr valign="top">
                        <td colspan="2">
                            <asp:Panel runat="server" ID="pnlAddSearchAttrib" Width="100%">
                                <table width="100%">
                                    <tr>
                                        <td class="formFieldLabel" style="width: 100px;">
                                            Market</td>
                                        <td style="width: 304px; height: 26px">
                                            <asp:DropDownList ID="ddlMarket" runat="server" AutoPostBack="True" DataSourceID="MarketDS"
                                                DataTextField="MarketName" DataValueField="MarketID">
                                            </asp:DropDownList>
                                            <asp:ObjectDataSource ID="MarketDS" runat="server" SelectMethod="GetListByBu" TypeName="Market">
                                                <SelectParameters>
                                                    <asp:SessionParameter Name="busUnitId" SessionField="BusUnitID" Type="Int32" />
                                                    <asp:Parameter DefaultValue="0" Name="mode" Type="Object" />
                                                </SelectParameters>
                                            </asp:ObjectDataSource>
                                        </td>
                                    </tr>
                                    <tr>
                                        <td class="formFieldLabel" style="width: 98px;" valign="top">
                                            Search Attribute</td>
                                        <td style="width: 304px; height: 26px">
                                            <asp:ListBox ID="lstSearchAttrib" runat="server" DataSourceID="UnselectedSearchAttribsDS"
                                                DataTextField="ListBoxDisplay" DataValueField="SearchAttribTypeID" Rows="10"
                                                SelectionMode="Multiple"></asp:ListBox>
                                            <asp:ObjectDataSource ID="UnselectedSearchAttribsDS" runat="server" SelectMethod="GetListByProduct"
                                                TypeName="ProductSearchAttributeReln">
                                                <SelectParameters>
                                                    <asp:ControlParameter ControlID="hidProductID" Name="productId" PropertyName="Text"
                                                        Type="Int32" />
                                                    <asp:SessionParameter DefaultValue="" Name="busUnitId" SessionField="BusUnitID" Type="Int32" />
                                                    <asp:ControlParameter ControlID="ddlMarket" DefaultValue="0" Name="mktId" PropertyName="SelectedValue"
                                                        Type="Int32" />
                                                    <asp:Parameter DefaultValue="False" Name="selected" Type="Boolean" />
                                                </SelectParameters>
                                            </asp:ObjectDataSource>
                                            &nbsp;&nbsp;
                                        </td>
                                    </tr>
                                    <tr>
                                        <td class="formFieldLabel" style="width: 98px;">
                                        </td>
                                        <td style="width: 304px; height: 26px">
                                            <asp:Button ID="btnAddSearchAttrib" runat="server" Text="Add Search Attribute" SkinID="WizardButton" />
                                            &nbsp;
                                        </td>
                                    </tr>
                                </table>
                            </asp:Panel>
                        </td>
                    </tr>
                    <tr>
                        <td colspan="2" style="height: 26px">
                            <asp:GridView ID="gvSearchAttribs" runat="server" AllowPaging="True" AllowSorting="True"
                                AutoGenerateColumns="False" DataKeyNames="ProdSearchAttribRelnID" EnableTheming="True"
                                DataSourceID="ProductSearchAttribsDS" EnableViewState="False">
                                <Columns>
                                    <asp:TemplateField>
                                        <ItemTemplate>
                                            <asp:ImageButton ID="ibtnDelete" runat="server" AlternateText="Delete" CommandArgument='<%# Eval("ProdSearchAttribRelnID") %>'
                                                CommandName="DeleteItem" ImageUrl="../App_Themes/CMS_Theme/images/delcnt.gif" />
                                        </ItemTemplate>
                                    </asp:TemplateField>
                                    <asp:BoundField DataField="SearchAttributeName" HeaderText="Search Attribute" SortExpression="SearchAttributeName" />
                                    <asp:BoundField DataField="MarketName" HeaderText="Market Name" SortExpression="MarketName" />
                                    <asp:BoundField DataField="WorkflowStatus" HeaderText="Workflow Status" SortExpression="WorkflowStatus">
                                        <ItemStyle HorizontalAlign="Center" />
                                    </asp:BoundField>
                                    <asp:BoundField DataField="PublishDate" DataFormatString="{0:d}" HeaderText="Publish Date"
                                        HtmlEncode="False" SortExpression="PublishDate">
                                        <ItemStyle HorizontalAlign="Center" />
                                    </asp:BoundField>
                                    <asp:BoundField DataField="ExpirationDate" DataFormatString="{0:d}" HeaderText="Expire Date"
                                        HtmlEncode="False" SortExpression="ExpirationDate">
                                        <ItemStyle HorizontalAlign="Center" />
                                    </asp:BoundField>
                                    <asp:BoundField DataField="JobName" HeaderText="Job Name" SortExpression="JobName" />
                                    <asp:BoundField DataField="LastModifiedDate" DataFormatString="{0:g}" HeaderText="Last Modified"
                                        HtmlEncode="False" SortExpression="LastModifiedDate">
                                        <ItemStyle HorizontalAlign="Center" Width="60px" />
                                    </asp:BoundField>
                                    <asp:BoundField DataField="FmtMarkedForDeletion" HeaderText="Marked for Deletion"
                                        SortExpression="FmtMarkedForDeletion">
                                        <ItemStyle HorizontalAlign="Center" Width="65px" />
                                    </asp:BoundField>
                                </Columns>
                            </asp:GridView>
                            <asp:ObjectDataSource ID="ProductSearchAttribsDS" runat="server" SelectMethod="GetListByProduct"
                                TypeName="ProductSearchAttributeReln">
                                <SelectParameters>
                                    <asp:ControlParameter ControlID="hidProductID" Name="productId" PropertyName="Text"
                                        Type="Int32" />
                                    <asp:SessionParameter DefaultValue="" Name="busUnitId" SessionField="BusUnitID" Type="Int32" />
                                    <asp:Parameter DefaultValue="0" Name="mktId" Type="Int32" />
                                    <asp:Parameter DefaultValue="True" Name="selected" Type="Boolean" />
                                </SelectParameters>
                            </asp:ObjectDataSource>
                        </td>
                    </tr>
                    <tr>
                        <td class="formFieldLabel" style="height: 26px" colspan="2">
                        </td>
                    </tr>
                </table>
            </asp:WizardStep>
            <asp:WizardStep runat="server" Title="4 - Documents" ID="Documents">
            <asp:Label ID="lblInstructionsStep4" runat="server"></asp:Label>
                <table id="Table3" style="vertical-align: top;" height="100%">
                    <tr valign="top">
                        <td colspan="2">
                            <asp:Label ID="lblNameStep4" runat="server" CssClass="formFieldLabel">Product Name</asp:Label>
                            &nbsp;&nbsp;
                            <asp:Label ID="lblProductNameStep4" runat="server"></asp:Label>
                        </td>
                    </tr>
                    <tr valign="top">
                        <td class="" colspan="2" style="height: 26px">
                            <asp:Panel runat="server" ID="pnlAddDocument" Width="100%">
                                <table width="100%">
                                    <tr>
                                        <td class="formFieldLabel" style="width: 100px; height: 19px;" colspan="2">
                                            <asp:Label ID="lblAddEditDoc" runat="server" CssClass="subFormTitle" Width="319px">Add Document</asp:Label>
                                            <asp:TextBox ID="hidDocumentID" runat="server" Visible="False" Width="22px"></asp:TextBox>
                                        </td>
                                    </tr>
                                    <tr valign="top">
                                        <td class="formFieldLabel" style="height: 28px; width: 101px;">
                                            Document Title</td>
                                        <td style="width: 339px; height: 28px;">
                                            <asp:TextBox ID="txtDocTitle" runat="server" MaxLength="100" Width="325px"></asp:TextBox>
                                            <asp:RequiredFieldValidator ID="vldDocTitleRequired" runat="server" ControlToValidate="txtDocTitle"
                                                Display="Dynamic" ErrorMessage="Document Title is required."></asp:RequiredFieldValidator>
                                        </td>
                                    </tr>
                                    <tr valign="top">
                                        <td class="formFieldLabel" style="width: 101px; height: 26px">
                                            Content Type</td>
                                        <td style="width: 339px">
                                            <asp:DropDownList ID="ddlDocContentType" runat="server" DataSourceID="DocContentTypeDS">
                                            </asp:DropDownList>
                                            <asp:RequiredFieldValidator ID="vldContentTypeRequired" runat="server" ControlToValidate="ddlDocContentType"
                                                Display="Dynamic" ErrorMessage="Content Type is required."></asp:RequiredFieldValidator>
                                            <asp:ObjectDataSource ID="DocContentTypeDS" runat="server" SelectMethod="GetContentTypeList"
                                                TypeName="Document"></asp:ObjectDataSource>
                                        </td>
                                    </tr>
                                    <tr valign="top">
                                        <td class="formFieldLabel" style="width: 101px; height: 26px">
                                            Region</td>
                                        <td style="width: 339px">
                                            <asp:DropDownList ID="ddlDocRegion" runat="server" DataSourceID="RegionsDS" DataTextField="RegionName" DataValueField="RegionID">
                                            </asp:DropDownList>
                                            <asp:RequiredFieldValidator ID="vldRegionRequired" runat="server" ControlToValidate="ddlDocRegion"
                                                Display="Dynamic" ErrorMessage="Region is required." InitialValue="0"></asp:RequiredFieldValidator>
                                            <asp:ObjectDataSource ID="RegionsDS" runat="server" SelectMethod="GetList" TypeName="Region">
                                                <SelectParameters>
                                                    <asp:Parameter DefaultValue="0" Name="mode" Type="Object" />
                                                </SelectParameters>
                                            </asp:ObjectDataSource>
                                        </td>
                                    </tr>
                                    <tr valign="top">
                                        <td class="formFieldLabel" style="width: 101px; height: 28px">
                                            Existing File</td>
                                        <td style="width: 339px; height: 28px">
                                            <asp:HyperLink ID="lnkDoc" runat="server">(none)</asp:HyperLink>
                                            <asp:TextBox ID="hidExistingDocPath" runat="server" Visible="False" Width="22px"></asp:TextBox>
                                            <asp:TextBox ID="hidDocUploadDate" runat="server" Visible="False" Width="22px"></asp:TextBox>
                                        </td>
                                    </tr>
                                    <tr valign="top">
                                        <td class="formFieldLabel" style="width: 101px; height: 28px">
                                            Upload New File</td>
                                        <td style="width: 339px; height: 28px">
                                            <asp:FileUpload ID="fupDoc" runat="server" Width="351px" />
                                        </td>
                                    </tr>
                                    <tr valign="top">
                                        <td class="formFieldLabel" style="width: 101px; height: 26px">
                                        </td>
                                        <td style="width: 339px">
                                            <asp:Button ID="btnSaveDoc" runat="server" Text="Add Document" SkinID="WizardButton" />
                                            &nbsp; &nbsp;
                                            <asp:Button ID="btnCancelSaveDoc" runat="server" Text="Cancel" SkinID="WizardButton" CausesValidation="False" />
                                        </td>
                                    </tr>
                                </table>
                            </asp:Panel>
                        </td>
                    </tr>
                    <tr valign="top">
                        <td colspan="2" style="height: 26px">
                            <asp:GridView ID="gvDocuments" runat="server" AllowPaging="True" AllowSorting="True"
                                AutoGenerateColumns="False" DataKeyNames="DocumentID" EnableTheming="True" DataSourceID="ProductDocumentsDS" EnableViewState="False">
                                <Columns>
                                    <asp:TemplateField>
                                        <ItemTemplate>
                                            <asp:ImageButton ID="ibtnDelete" runat="server" AlternateText="Delete" CommandArgument='<%# Eval("DocumentID") %>'
                                                CommandName="DeleteItem" CausesValidation="false" ImageUrl="../App_Themes/CMS_Theme/images/delcnt.gif" />
                                        </ItemTemplate>
                                    </asp:TemplateField>
                                    <asp:TemplateField>
                                        <ItemTemplate>
                                            <asp:ImageButton ID="ibtnEdit" runat="server" AlternateText="Edit" CommandArgument='<%# Eval("DocumentID") %>'
                                                CommandName="EditItem" CausesValidation="false" ImageUrl="../App_Themes/CMS_Theme/images/edit.gif" />
                                        </ItemTemplate>
                                    </asp:TemplateField>
                                    <asp:TemplateField HeaderText="Document Title" SortExpression="DocTitle">
                                        <ItemTemplate>
                                            <asp:HyperLink ID="lnkDocument" runat="server">[lnkDocument]</asp:HyperLink>
                                        </ItemTemplate>
                                    </asp:TemplateField>
                                    <asp:BoundField DataField="ContentType" HeaderText="Type" SortExpression="ContentType" />
                                    <asp:BoundField DataField="WorkflowStatus" HeaderText="Workflow Status" SortExpression="WorkflowStatus">
                                        <ItemStyle HorizontalAlign="Center" />
                                    </asp:BoundField>
                                    <asp:BoundField DataField="PublishDate" DataFormatString="{0:d}" HeaderText="Publish Date"
                                        HtmlEncode="False" SortExpression="PublishDate">
                                        <ItemStyle HorizontalAlign="Center" />
                                    </asp:BoundField>
                                    <asp:BoundField DataField="ExpirationDate" DataFormatString="{0:d}" HeaderText="Expire Date"
                                        HtmlEncode="False" SortExpression="ExpirationDate">
                                        <ItemStyle HorizontalAlign="Center" />
                                    </asp:BoundField>
                                    <asp:BoundField DataField="JobName" HeaderText="Job Name" SortExpression="JobName" />
                                    <asp:BoundField DataField="LastModifiedDate" DataFormatString="{0:g}" HeaderText="Last Modified"
                                        HtmlEncode="False" SortExpression="LastModifiedDate">
                                        <ItemStyle HorizontalAlign="Center" Width="60px" />
                                    </asp:BoundField>
                                    <asp:BoundField DataField="FmtMarkedForDeletion" HeaderText="Marked for Deletion"
                                        SortExpression="FmtMarkedForDeletion">
                                        <ItemStyle HorizontalAlign="Center" Width="65px" />
                                    </asp:BoundField>
                                </Columns>
                            </asp:GridView>
                            <asp:ObjectDataSource ID="ProductDocumentsDS" runat="server" SelectMethod="GetListByProduct"
                                TypeName="Document">
                                <SelectParameters>
                                    <asp:ControlParameter ControlID="hidProductID" Name="productId" PropertyName="Text"
                                        Type="Int32" />
                                </SelectParameters>
                            </asp:ObjectDataSource>
                        </td>
                    </tr>
                </table>
            </asp:WizardStep>
        </WizardSteps>
        <SideBarButtonStyle Width="125px"/>
        <FinishNavigationTemplate>
            <table cellspacing="5" cellpadding="5" border="0">
                <tr>
                    <td align="right">
                        <asp:Button ID="FinishPreviousButton" runat="server" CausesValidation="False" CommandName="MovePrevious"
                            Text="Previous" SkinID="WizardButton" />
                        <asp:Button ID="FinishButton" runat="server" CommandName="MoveComplete" Text="Finish"
                            SkinID="WizardButton" CausesValidation="False" />
                        <asp:Button ID="CancelButton" runat="server" CausesValidation="False" CommandName="Cancel"
                            Text="Cancel" SkinID="WizardButton" />
                    </td>
                </tr>
            </table>
        </FinishNavigationTemplate>
        <SideBarTemplate>
            <asp:DataList ID="SideBarList" runat="server">
                <SelectedItemStyle Font-Bold="True" ForeColor="White" />
                <ItemTemplate>
                    <asp:LinkButton ID="SideBarButton" runat="server" Width="125px" CausesValidation="false" ForeColor="White"></asp:LinkButton>
                </ItemTemplate>
            </asp:DataList>
        </SideBarTemplate>
    </asp:Wizard>
    <uc1:WorkflowInfo ID="ucWorkflowInfo" runat="server" />
    <asp:TextBox ID="hidProductID" runat="server" Visible="False" Width="22px"></asp:TextBox>
    <asp:TextBox ID="hidFormMode" runat="server" Visible="False" Width="19px"></asp:TextBox>
    &nbsp;&nbsp;
</asp:Content>
