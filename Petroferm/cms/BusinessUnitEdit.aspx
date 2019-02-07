<%@ Page Language="VB" MasterPageFile="~/cms/MasterCMS.master" AutoEventWireup="false" CodeFile="BusinessUnitEdit.aspx.vb" Inherits="CmsBusinessUnitEdit" title="" StylesheetTheme="CMS_Theme" %>

<%@ Register Src="controls/WorkflowInfo.ascx" TagName="WorkflowInfo" TagPrefix="uc1" %>
<%@ Register Src="controls/ImageEdit.ascx" TagName="ImageEdit" TagPrefix="uc2" %>
<%@ MasterType TypeName="MasterCMS" %> 
<%@ Register TagPrefix="ew" Namespace="eWorld.UI" Assembly="eWorld.UI" %>

<asp:Content ID="Content1" ContentPlaceHolderID="phMain" Runat="Server">
    <asp:Label ID="lblMessage" runat="server"></asp:Label>
    <asp:Wizard ID="wzForm" runat="server" ActiveStepIndex="1" DisplayCancelButton="True" Width="800px">
        <WizardSteps>
            <asp:WizardStep runat="server" Title="1 - General Info">

    <table id="TABLE1" style="width: 523px">
        <tr>
            <td style="width: 123px; height: 26px;" class="formFieldLabel">
                Business Unit Name&nbsp;
            </td>
            <td style="width: 223px; height: 26px;">
                <asp:TextBox ID="txtBusinessUnitName" runat="server" Width="254px"></asp:TextBox>
                <asp:RequiredFieldValidator ID="vldNameRequired" runat="server" Display="Dynamic"
                    ErrorMessage="Name is required." ControlToValidate="txtBusinessUnitName"></asp:RequiredFieldValidator></td>
        </tr>
        <tr>
            <td colspan="2" style="height: 18px">
                <asp:CheckBox ID="chkDocAuth" runat="server" Text="Require registration to view documents" /></td>
        </tr>
        <tr>
            <td style="width: 123px; height: 26px;" class="formFieldLabel">
                Publish Date</td>
            <td style="width: 223px; height: 26px;">
                <ew:CalendarPopup ID="dtePublishDate" runat="server" AllowArbitraryText="False" BackColor="White"
                    BorderColor="Silver" CellPadding="2px" CellSpacing="0px" ControlDisplay="TextBoxImage"
                    Culture="English (United States)" DisableTextboxEntry="False" DisplayOffsetX="20" ImageUrl="~/App_Themes/CMS_Theme/images/calendar-ew.gif"
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
                &nbsp;
                <asp:CompareValidator ID="vldPublishDateValid" runat="server" ControlToValidate="dtePublishDate"
                    Display="Dynamic" ErrorMessage="Valid publish date is required." Operator="DataTypeCheck"
                    Type="Date"></asp:CompareValidator>
                &nbsp;
            </td>
        </tr>
        <tr>
            <td class="formFieldLabel" style="width: 123px; height: 26px">
                Expiration Date</td>
            <td style="width: 223px; height: 26px">
                <ew:CalendarPopup ID="dteExpireDate" runat="server" AllowArbitraryText="False" BackColor="White"
                    BorderColor="Silver" CellPadding="2px" CellSpacing="0px" ControlDisplay="TextBoxImage"
                    Culture="English (United States)" DisableTextboxEntry="False" DisplayOffsetX="20" ImageUrl="~/App_Themes/CMS_Theme/images/calendar-ew.gif"
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
                &nbsp;
                <asp:CompareValidator ID="vldExpireDateValid" runat="server" ControlToValidate="dteExpireDate"
                    Display="Dynamic" ErrorMessage="Valid expiration date is required." Operator="DataTypeCheck"
                    Type="Date"></asp:CompareValidator>
            </td>
        </tr>
    </table>
                &nbsp;
            </asp:WizardStep>
            <asp:WizardStep runat="server" Title="2 - Logo"><uc2:ImageEdit ID="ucImageEdit" runat="server" EnableViewState="true" />
            </asp:WizardStep>
            <asp:WizardStep ID="stepProdCategory" runat="server" Title="3 - Product Category">
                <table id="Table4" height="100%" style="vertical-align: top; width: 650px">
                    <tr style="color: #000000" valign="top">
                        <td colspan="2" style="width: 129px; text-align: left">
                            <asp:Panel ID="pnlAddEditProductCategory" runat="server" Width="100%">
                                <asp:Label ID="lblProductCategory" runat="server" CssClass="subFormTitle" Width="319px">Add Product Category</asp:Label>
                                <br />
                                <asp:Label ID="lblInstructionsProdCategory" runat="server" Visible="False"></asp:Label>
                                &nbsp;
                                <table border="0" style="border-right: silver thin solid; border-top: silver thin solid;
                                    border-left: silver thin solid; width: 604px; border-bottom: silver thin solid">
                                    <tr>
                                        <td class="formFieldLabel" style="width: 46px; text-align: left; height: 26px;">
                                            Category</td>
                                        <td style="width: 337px; text-align: left; height: 26px;">
                                            <asp:TextBox ID="txtProductCategory" runat="server" MaxLength="50" Width="267px"></asp:TextBox>
                                            <asp:RequiredFieldValidator ID="vldCategoryReq" runat="server" ControlToValidate="txtProductCategory"
                                                Display="Dynamic" ErrorMessage="Category is required."></asp:RequiredFieldValidator>
                                        </td>
                                    </tr>
                                    <tr>
                                        <td class="formFieldLabel" style="width: 46px; text-align: left">
                                            Order</td>
                                        <td style="text-align: left">
                                            <asp:TextBox ID="txtProdCatOrder" runat="server" MaxLength="2" Width="21px"></asp:TextBox>
                                            <asp:RequiredFieldValidator ID="vldOrderRequired" runat="server" ControlToValidate="txtProdCatOrder"
                                                Display="Dynamic" ErrorMessage="Module Order is required."></asp:RequiredFieldValidator>
                                            <asp:CompareValidator ID="vldOrderValid" runat="server" ControlToValidate="txtProdCatOrder"
                                                Display="Dynamic" ErrorMessage="Module Order must be numeric." Operator="DataTypeCheck"
                                                Type="Integer"></asp:CompareValidator>
                                        </td>
                                    </tr>
                                    <tr>
                                        <td colspan="2" style="text-align: center">
                                            <asp:Button ID="btnSaveProductCategory" runat="server" SkinID="WizardButton" Text="Add Product Category" />
                                            &nbsp; &nbsp;
                                            <asp:Button ID="btnCancelSaveProdCat" CausesValidation="false" runat="server" SkinID="WizardButton" Text="Cancel" />
                                        </td>
                                    </tr>
                                </table>
                            </asp:Panel>
                        </td>
                    </tr>
                    <tr style="color: #000000" valign="top">
                        <td colspan="2" rowspan="1">
                            <asp:GridView ID="gvProductCategories" runat="server" AllowPaging="True" AllowSorting="True"
                                AutoGenerateColumns="False" DataKeyNames="ProdCatID" DataSourceID="ProductCategoriesDS"
                                EnableTheming="True" EnableViewState="False">
                                <Columns>
                                    <asp:TemplateField>
                                        <ItemTemplate>
                                            <asp:ImageButton ID="ibtnDelete" CausesValidation="false" runat="server" AlternateText="Delete" CommandArgument='<%# Eval("ProdCatID") %>'
                                                CommandName="DeleteItem" ImageUrl="../App_Themes/CMS_Theme/images/delcnt.gif" />
                                        </ItemTemplate>
                                    </asp:TemplateField>
                                    <asp:TemplateField>
                                        <ItemTemplate>
                                            <asp:ImageButton ID="ibtnEdit" CausesValidation="false" runat="server" AlternateText="Edit" CommandArgument='<%# Eval("ProdCatID") %>'
                                                CommandName="EditItem" ImageUrl="../App_Themes/CMS_Theme/images/edit.gif" />
                                        </ItemTemplate>
                                    </asp:TemplateField>
                                    <asp:BoundField DataField="CategoryName" HeaderText="Product Category" SortExpression="CategoryName" />
                                    <asp:BoundField DataField="CategoryOrder" HeaderText="Order" SortExpression="CategoryOrder">
                                     <ItemStyle HorizontalAlign="Center" />
                                    </asp:BoundField>
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
                            <asp:ObjectDataSource ID="ProductCategoriesDS" runat="server" SelectMethod="GetList"
                                TypeName="ProductCategory">
                                <SelectParameters>
                                    <asp:ControlParameter ControlID="hidBusUnitID" Name="busUnitId" PropertyName="Text"
                                        Type="Int32" />
                                </SelectParameters>
                            </asp:ObjectDataSource>
                        </td>
                    </tr>
                </table>
            </asp:WizardStep>
        </WizardSteps>
        <FinishNavigationTemplate>
            <table cellspacing="5" cellpadding="5" border="0">
                <tr>
                    <td align="right">
                        <asp:Button ID="FinishPreviousButton" runat="server" CausesValidation="False" CommandName="MovePrevious"
                            Text="Previous" SkinID="WizardButton" />
                        <asp:Button ID="FinishButton" runat="server" CommandName="MoveComplete" Text="Finish"
                          SkinID="WizardButton" />
                        <asp:Button ID="CancelButton" runat="server" CausesValidation="False" CommandName="Cancel"
                            Text="Cancel" SkinID="WizardButton" />
                    </td>
                </tr>
            </table>
        </FinishNavigationTemplate>
        <SideBarStyle Width="150px" />
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
            <asp:TextBox ID="hidBusUnitID" runat="server" Visible="False" Width="31px"></asp:TextBox>
                <asp:TextBox ID="hidFormMode" runat="server" Visible="False" Width="31px"></asp:TextBox><br />
</asp:Content>

