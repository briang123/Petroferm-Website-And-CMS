<%@ Page Language="VB" MasterPageFile="~/cms/MasterCMS.master" AutoEventWireup="false" CodeFile="ProductAttributeEdit.aspx.vb" Inherits="CmsProductAttributeEdit" title="Untitled Page" StylesheetTheme="CMS_Theme" Theme="CMS_Theme" %>

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
            <td style="width: 129px;" class="formFieldLabel">
                Attribute Name&nbsp;
            </td>
            <td style="width: 352px;">
                <asp:TextBox ID="txtAttribName" runat="server" Width="209px" MaxLength="100"></asp:TextBox>
                <asp:RequiredFieldValidator ID="vldNameRequired" runat="server" ControlToValidate="txtAttribName"
                    Display="Dynamic" ErrorMessage="Name is required." SetFocusOnError="True"></asp:RequiredFieldValidator></td>
        </tr>
        <tr style="color: #000000">
            <td class="formFieldLabel" style="width: 129px;">
                Allow Multiple Values?</td>
            <td style="width: 352px;">
                <asp:CheckBox ID="chkAllowMultiple" runat="server" />
            </td>
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
                    Text=" " UpperBoundDate="12/31/9999 23:59:59" Width="75px">
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
                    Text=" " UpperBoundDate="12/31/9999 23:59:59" Width="75px">
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
    </table>
            <asp:TextBox ID="hidProdAttribID" runat="server" Visible="False" Width="22px"></asp:TextBox>
                <asp:TextBox ID="hidFormMode" runat="server" Visible="False" Width="19px"></asp:TextBox>
                <asp:TextBox ID="hidReadOnly" runat="server" Visible="False" Width="19px"></asp:TextBox>
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
    
    
    
</asp:Content>

