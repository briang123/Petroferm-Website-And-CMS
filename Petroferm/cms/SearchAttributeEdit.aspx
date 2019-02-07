<%@ Page Language="VB" MasterPageFile="~/cms/MasterCMS.master" AutoEventWireup="false" CodeFile="SearchAttributeEdit.aspx.vb" Inherits="CmsSearchAttributeEdit" title="Untitled Page" StylesheetTheme="CMS_Theme" Theme="CMS_Theme" %>

<%@ Register Src="controls/WorkflowInfo.ascx" TagName="WorkflowInfo" TagPrefix="uc1" %>
<%@ MasterType TypeName="MasterCMS" %> 
<%@ Register TagPrefix="ew" Namespace="eWorld.UI" Assembly="eWorld.UI" %>
<asp:Content ID="Content1" ContentPlaceHolderID="phMain" Runat="Server">
<asp:Label ID="lblMessage" runat="server"></asp:Label>
   <asp:Wizard ID="wzForm" runat="server" DisplaySideBar="False" DisplayCancelButton="True" >
        <WizardSteps>
            <asp:WizardStep ID="WizardStep1" runat="server" Title="1 - General Info">
    <table id="TABLE1" style="width: 527px">
        <tr>
            <td class="formFieldLabel" style="width: 129px">
                Market</td>
            <td style="width: 352px">
                <asp:DropDownList ID="ddlMarket" runat="server" DataSourceID="MarketDS" DataTextField="MarketName"
                    DataValueField="MarketID">
                </asp:DropDownList>
                <asp:Label ID="lblMarket" runat="server"></asp:Label>
                <asp:TextBox ID="hidMarketID" runat="server" Visible="False" Width="19px"></asp:TextBox>
            </td>
        </tr>
        <tr>
            <td style="width: 129px;" class="formFieldLabel">
                Attribute Name&nbsp;
            </td>
            <td style="width: 352px;">
                <asp:TextBox ID="txtAttribName" runat="server" Width="209px" MaxLength="100"></asp:TextBox>
                <asp:RequiredFieldValidator ID="vldNameRequired" runat="server" ControlToValidate="txtAttribName"
                    Display="Dynamic" ErrorMessage="Name is required." SetFocusOnError="True"></asp:RequiredFieldValidator></td>
        </tr>
        <tr>
            <td class="formFieldLabel" style="width: 129px;">
                Publish Date</td>
            <td style="width: 352px;">
                <ew:CalendarPopup ID="dtePublishDate" runat="server" AllowArbitraryText="False" BackColor="White"
                    BorderColor="Silver" CellPadding="2px" CellSpacing="0px" ControlDisplay="TextBoxImage"
                    Culture="English (United States)" DisableTextboxEntry="False" DisplayOffsetX="20"
                    ImageUrl="~/App_Themes/CMS_Theme/images/calendar-ew.gif" JavascriptOnChangeFunction=""
                    LowerBoundDate="" Nullable="True" PadSingleDigits="True" SelectedDate="" ShowClearDate="True"
                    Text=" " UpperBoundDate="12/31/9999 23:59:59" Width="75px" EnableHideDropDown="True">
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
                <asp:CompareValidator ID="vldPublishDateValid" runat="server" ControlToValidate="dtePublishDate"
                    Display="Dynamic" ErrorMessage="Valid publish date is required." Operator="DataTypeCheck"
                    Type="Date"></asp:CompareValidator></td>
        </tr>
        <tr>
            <td class="formFieldLabel" style="width: 129px; height: 37px">
                Expiration Date</td>
            <td style="width: 352px; height: 37px;">
                <ew:CalendarPopup ID="dteExpireDate" runat="server" AllowArbitraryText="False" BackColor="White"
                    BorderColor="Silver" CellPadding="2px" CellSpacing="0px" ControlDisplay="TextBoxImage"
                    Culture="English (United States)" DisableTextboxEntry="False" DisplayOffsetX="20"
                    ImageUrl="~/App_Themes/CMS_Theme/images/calendar-ew.gif" JavascriptOnChangeFunction=""
                    LowerBoundDate="" Nullable="True" PadSingleDigits="True" SelectedDate="" ShowClearDate="True"
                    Text=" " UpperBoundDate="12/31/9999 23:59:59" Width="75px" EnableHideDropDown="True">
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
                <asp:CompareValidator ID="vldExpireDateValid" runat="server" ControlToValidate="dteExpireDate"
                    Display="Dynamic" ErrorMessage="Valid expiration date is required." Operator="DataTypeCheck"
                    Type="Date"></asp:CompareValidator></td>
        </tr>
        <tr>
            <td class="formFieldLabel" style="width: 129px; height: 37px" valign="top">
                Add Product</td>
            <td style="width: 352px; height: 37px">
                <asp:ListBox ID="lstProducts" runat="server" DataSourceID="UnrelatedProductsDS" DataTextField="ProductName"
                    DataValueField="ProductID" Rows="10" SelectionMode="Multiple"></asp:ListBox>
                <asp:ObjectDataSource ID="UnrelatedProductsDS" runat="server" SelectMethod="GetListByAttrib"
                    TypeName="ProductSearchAttributeReln">
                    <SelectParameters>
                        <asp:ControlParameter ControlID="hidSearchAttribID" Name="searchAttribId" PropertyName="Text"
                            Type="Int32" DefaultValue="0" />
                        <asp:SessionParameter Name="busUnitId" SessionField="BusUnitID" Type="Int32" />
                        <asp:Parameter DefaultValue="False" Name="selected" Type="Boolean" />
                    </SelectParameters>
                </asp:ObjectDataSource>
                &nbsp;&nbsp;
            </td>
        </tr>
        <tr>
            <td class="formFieldLabel" style="width: 129px; height: 37px">
            </td>
            <td>
                <asp:Button ID="btnAddProduct" runat="server" SkinID="WizardButton" Text="Add Product" />
            </td>
        </tr>
        <tr>
            <td colspan="2" style="height: 37px">
                <asp:GridView ID="gvSearchAttribs" runat="server" AllowPaging="True" AllowSorting="True"
                    AutoGenerateColumns="False" DataKeyNames="ProdSearchAttribRelnID" DataSourceID="ProductsBySearchAttribDS"
                    EnableTheming="True">
                    <Columns>
                        <asp:TemplateField>
                            <ItemTemplate>
                                <asp:ImageButton ID="ibtnDelete" runat="server" AlternateText="Delete" CommandArgument='<%# Eval("ProdSearchAttribRelnID") %>'
                                    CommandName="DeleteItem" ImageUrl="../App_Themes/CMS_Theme/images/delcnt.gif" />
                            </ItemTemplate>
                        </asp:TemplateField>
                        <asp:BoundField DataField="ProductName" HeaderText="Product Name" SortExpression="ProductName" />
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
                <asp:ObjectDataSource ID="ProductsBySearchAttribDS" runat="server" SelectMethod="GetListByAttrib"
                    TypeName="ProductSearchAttributeReln">
                    <SelectParameters>
                        <asp:ControlParameter ControlID="hidSearchAttribID" Name="searchAttribId" PropertyName="Text"
                            Type="Int32" />
                        <asp:SessionParameter Name="busUnitId" SessionField="BusUnitID" Type="Int32" />
                        <asp:Parameter DefaultValue="True" Name="selected" Type="Boolean" />
                    </SelectParameters>
                </asp:ObjectDataSource>
            </td>
        </tr>
    </table>
            <asp:TextBox ID="hidSearchAttribID" runat="server" Visible="False" Width="22px"></asp:TextBox>
                <asp:TextBox ID="hidFormMode" runat="server" Visible="False" Width="19px"></asp:TextBox>
                &nbsp;&nbsp;
                <asp:ObjectDataSource ID="ProductDS" runat="server" SelectMethod="GetList" TypeName="Product">
                    <SelectParameters>
                        <asp:SessionParameter Name="busUnitId" SessionField="BusUnitID" Type="Int32" />
                    </SelectParameters>
                </asp:ObjectDataSource>
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
    </asp:Wizard>
    <uc1:WorkflowInfo ID="ucWorkflowInfo" runat="server" />
    <asp:ObjectDataSource ID="MarketDS" runat="server" SelectMethod="GetListByBu" TypeName="Market">
        <SelectParameters>
            <asp:SessionParameter Name="busUnitId" SessionField="BusUnitID" Type="Int32" />
            <asp:Parameter DefaultValue="0" Name="mode" Type="Object" />
        </SelectParameters>
    </asp:ObjectDataSource>
    
    
    
</asp:Content>

