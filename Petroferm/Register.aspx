<%@ Page Language="VB" MasterPageFile="~/GeneralContent.master" AutoEventWireup="false" CodeFile="Register.aspx.vb" Inherits="Register" title="Registration" %>
<%@ MasterType virtualPath="GeneralContent.master" %>

<asp:Content ID="Content3" ContentPlaceHolderID="MasterBodyContent" Runat="Server">
    <div class="blueTitle">Registration</div>
    <br /><br />
    <asp:CreateUserWizard ID="CreateUserWizard1" runat="server" CreateUserButtonText="Register" InstructionText="" Width="505px" ActiveStepIndex="1">
        <WizardSteps>
            <asp:CreateUserWizardStep ID="CreateUserWizardStep1" runat="server">
                <ContentTemplate>
                    <p align=left>Please provide us with the following information to create a Petroferm account to gain access to additional information.</p>
                    <table width="500" cellpadding="2" cellspacing="0" border="0">
                            <tr>
                                <td style="width: 143px">Company Name:</td>
                                <td style="width: 389px"><asp:TextBox ID="txtCompanyName" runat="server" CssClass="text" Width="175px" />
                                    <asp:RequiredFieldValidator ID="RequiredFieldValidator1" runat="server" ControlToValidate="txtCompanyName"
                                        ErrorMessage="Company name is required"></asp:RequiredFieldValidator>
                                </td>
                            </tr>
                            <tr>
                                <td style="width: 143px">Full Name:</td>
                                <td style="width: 389px"><asp:TextBox ID="txtFullName" runat="server" CssClass="text" Width="175px" />
                                    <asp:RequiredFieldValidator ID="RequiredFieldValidator2" runat="server" ControlToValidate="txtFullName"
                                        ErrorMessage="Your name is required"></asp:RequiredFieldValidator>
                                </td>
                            </tr>
                            <tr>
                                <td style="width: 143px">Phone Number:</td>
                                <td style="width: 389px"><asp:TextBox ID="txtPhoneNumber" runat="server" CssClass="text" /></td>
                            </tr>
                            <tr>
                                <td style="width: 143px">Username:</td>
                                <td style="width: 389px">
                                    <asp:TextBox runat="server" ID="UserName" CssClass="text" />
                                    <asp:RequiredFieldValidator runat="server" ID="RequiredFieldValidator9" ControlToValidate="UserName" 
                                        ErrorMessage="Username is required." />
                                </td>
                            </tr>
                            <tr>
                                <td style="width: 143px">Password:</td>
                                <td style="width: 389px">
                                    <asp:TextBox runat="server" ID="Password" TextMode="Password" CssClass="text" />
                                    <asp:RequiredFieldValidator runat="server" ID="RequiredFieldValidator10" ControlToValidate="Password" 
                                        ErrorMessage="Password is required." />
                                </td>
                            </tr>
                            <tr>
                                <td style="width: 143px">Confirm Password:</td>
                                <td style="width: 389px">
                                    <asp:TextBox runat="server" ID="ConfirmPassword" TextMode="Password" CssClass="text" />
                                    <asp:RequiredFieldValidator runat="server" ID="RequiredFieldValidator13" ControlToValidate="ConfirmPassword" 
                                        ErrorMessage="Confirm Password is required." />
                                </td>
                            </tr>
                            <tr>
                                <td style="width: 143px">Email Address:</td>
                                <td style="width: 389px">
                                    <asp:TextBox runat="server" ID="Email" CssClass="text" Width="175px" />
                                    <asp:RequiredFieldValidator runat="server" ID="RequiredFieldValidator11" ControlToValidate="Email" 
                                        ErrorMessage="Email is required." />
                                </td>
                            </tr>
                            <tr>
                                <td style="width: 143px">Region Preference:</td>
                                <td style="width: 389px"><asp:DropDownList ID="ddlRegionList" runat="server" CssClass="text" /></td>
                            </tr>
                            <tr>
                                <td style="width: 143px">Interests:</td>
                                <td style="width: 389px"><asp:ListBox ID="lstInterests" runat="server" CssClass="text" SelectionMode="Multiple" Rows="5">
                                    <asp:ListItem Value="Marketing Information">Marketing Information</asp:ListItem>
                                    <asp:ListItem Value="Newsletters">Newsletters</asp:ListItem>
                                    <asp:ListItem Value="Product Samples">Product Samples</asp:ListItem>
                                    <asp:ListItem Value="Datasheets">Datasheets</asp:ListItem>
                                    <asp:ListItem Value="Other">Other</asp:ListItem>
                                </asp:ListBox>
                                </td>
                            </tr>
                            <tr><td colspan="2">Comments:</td></tr>
                            <tr><td colspan="2"><asp:TextBox ID="txtComments" runat="server" TextMode="MultiLine" Rows="5" Columns="90" Width="370px"></asp:TextBox></td></tr>                            
                            <tr>
                                <td colspan="2">
                                     <asp:CompareValidator ID="PasswordCompare" runat="server" ControlToCompare="Password"
                                            ControlToValidate="ConfirmPassword" Display="Dynamic" ErrorMessage="The Password and Confirmation Password must match."></asp:CompareValidator>
                                </td>
                            </tr>
                            <tr>
                                <td colspan="2">
                                    <asp:Literal ID="ErrorMessage" runat="server" EnableViewState="False"></asp:Literal>
                                </td>
                            </tr>
                        </table>                 
                </ContentTemplate>
            </asp:CreateUserWizardStep>
            <asp:CompleteWizardStep ID="CreateUserWizardStep2" runat="server"> 
                <ContentTemplate>
                    <table border="0" style="background-color:#eeeeee;">
                        <tr>
                            <td align="center" colspan="2" style="font-weight:bold;">Registration Complete!</td>
                        </tr>
                        <tr>
                            <td>Your account has been successfully created; Please allow us to review your information, which then you will be notified regarding your registration request.</td>
                        </tr>
                        <tr>
                            <td align="right" colspan="2" style="height: 26px">
                                <asp:Button ID="ContinueButton" runat="server" CssClass="text" CausesValidation="False" CommandName="Continue"
                                    OnClick="ContinueButton_Click" Text="Continue" ValidationGroup="CreateUserWizard1" />
                            </td>
                        </tr>
                    </table>
                </ContentTemplate>
            </asp:CompleteWizardStep>
        </WizardSteps>
        <FinishNavigationTemplate>
            <asp:Button ID="FinishPreviousButton" runat="server" CssClass="text" CausesValidation="False" CommandName="MovePrevious"
                Text="Previous" />
            <asp:Button ID="FinishButton" runat="server" CssClass="text"  CommandName="MoveComplete" Text="Finish" />
        </FinishNavigationTemplate>
        <CreateUserButtonStyle CssClass="text" />
    </asp:CreateUserWizard>        
</asp:Content>