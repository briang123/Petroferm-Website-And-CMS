<%@ Page Language="VB" MasterPageFile="~/cms/MasterCMS.master" AutoEventWireup="false" CodeFile="UserEdit.aspx.vb" Inherits="CmsUserEdit" title="" StylesheetTheme="CMS_Theme" %>
<%@ MasterType TypeName="MasterCMS" %> 
<asp:Content ID="Content1" ContentPlaceHolderID="phMain" Runat="Server">
    <asp:Label ID="lblMessage" runat="server"></asp:Label>
    <asp:Wizard ID="wzForm" runat="server" ActiveStepIndex="1" DisplayCancelButton="true" Width="750px">
        <WizardSteps>
            <asp:WizardStep runat="server" Title="1 - General Info">
                <table width="500" cellpadding="2" cellspacing="0" border="0">
                        <tr>
                            <td style="width: 143px">Username:</td>
                            <td style="width: 389px">
                                <asp:TextBox runat="server" ID="UserName"/>
                            </td>
                        </tr>
                        <tr>
                            <td style="width: 143px">Email Address:</td>
                            <td style="width: 389px">
                                <asp:TextBox runat="server" ID="Email" Width="175px" />
                                <asp:RequiredFieldValidator runat="server" ID="RequiredFieldValidator11" ControlToValidate="Email" 
                                    ErrorMessage="Email is required." />
                            </td>
                        </tr>
                        <tr>
                            <td style="width: 143px">First Name:</td>
                            <td style="width: 389px">
                                <asp:TextBox runat="server" ID="FirstName" Width="175px" />
                                <asp:RequiredFieldValidator runat="server" ID="RequiredFieldValidator1" ControlToValidate="FirstName" 
                                    ErrorMessage="First Name is required." />
                            </td>
                        </tr>
                        <tr>
                            <td style="width: 143px">Last Name:</td>
                            <td style="width: 389px">
                                <asp:TextBox runat="server" ID="LastName" Width="175px" />
                                <asp:RequiredFieldValidator runat="server" ID="RequiredFieldValidator2" ControlToValidate="LastName" 
                                    ErrorMessage="Last Name is required." />
                            </td>
                        </tr>                                                
                        <tr><td colspan="2">Comments:</td></tr>
                        <tr><td colspan="2"><asp:TextBox ID="txtComments" runat="server" TextMode="MultiLine" Rows="5" Columns="90" Width="370px"></asp:TextBox></td></tr>
                        <tr>
                            <td colspan="2">
                                <asp:Literal ID="ErrorMessage" runat="server" EnableViewState="False"></asp:Literal>
                            </td>
                        </tr>
                    </table>                 
            </asp:WizardStep>
            
            <asp:WizardStep runat="server" Title="2 - Business Units">
                <table border="0">
                    <tr>
                        <td style="width: 143px">Business Units:</td>
                        <td style="width: 389px">
                            <asp:ListBox ID="lstBusinessUnits" runat="server" Rows="7" SelectionMode="Multiple"></asp:ListBox>
                        </td>
                    </tr>
                </table>
            </asp:WizardStep>
            
            <asp:WizardStep runat="server" Title="3 - Default Business">
                <table border="0">
                    <tr>
                        <td style="width: 143px" valign="top">Default Business Unit:</td>
                        <td style="width: 389px">
                            <asp:DropDownList ID="ddlBusinessUnits" runat="server"></asp:DropDownList>
                            &nbsp;<br /><br /><br /><br /><br /><br />
                        </td>
                    </tr>
                </table>
            </asp:WizardStep>            

            <asp:WizardStep runat="server" Title="4 - User Roles">
                <table border="0">
                    <tr>
                        <td style="width: 143px">User Roles:</td>
                        <td style="width: 389px">
                            <asp:CheckBoxList ID="chkRoles" runat="server" AutoPostBack="true" OnSelectedIndexChanged="RoleCheck_Click" CellPadding="2" RepeatColumns="1" RepeatDirection=Vertical RepeatLayout=Flow></asp:CheckBoxList>
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
    </asp:wizard>                
    <asp:TextBox ID="hidFormMode" runat="server" Visible="False" Width="31px"></asp:TextBox><br />
</asp:Content>



