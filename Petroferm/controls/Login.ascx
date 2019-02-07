<%@ Control Language="VB" AutoEventWireup="false" CodeFile="Login.ascx.vb" Inherits="ControlsLogin" %>
<table style="padding-top:30;" width="100%">
    <tr>
        <td>
        <asp:Login ID="Login1" runat="server" BackColor="#F7F6F3" BorderColor="#666666" BorderPadding="4" BorderStyle="Solid" BorderWidth="1px" Font-Names="Verdana" Font-Size="10px" ForeColor="#333333" style="background-color: white">
            <TitleTextStyle BackColor="#5D7B9D" Font-Bold="True" Font-Size="0.9em" ForeColor="White" />
            <InstructionTextStyle Font-Italic="True" ForeColor="Black" />
            <TextBoxStyle Font-Size="0.8em" />
            <LoginButtonStyle BackColor="#FFFBFF" BorderColor="#CCCCCC" BorderStyle="Solid" BorderWidth="1px" Font-Names="Verdana" Font-Size="0.8em" ForeColor="#284775" />
            <LayoutTemplate>
                <table border="0" cellpadding="0">
                    <tr>
                        <td align="center" colspan="2" style="background-color: #c3c3b0; height: 15px;" class="bodySmallCaps">Login</td>
                    </tr>
                    <tr>
                        <td align="right">
                            <asp:Label ID="UserNameLabel" runat="server" CssClass="bodySmall" AssociatedControlID="UserName" Width="60px">User Name:</asp:Label></td>
                        <td>
                            <asp:TextBox ID="UserName" runat="server" CssClass="text" Width="75px" />
                            <asp:RequiredFieldValidator ID="UserNameRequired" runat="server" ControlToValidate="UserName"
                                ErrorMessage="User Name is required." ToolTip="User Name is required." ValidationGroup="ctl00$Login1">*</asp:RequiredFieldValidator>
                        </td>
                    </tr>
                    <tr>
                        <td align="right">
                            <asp:Label ID="PasswordLabel" runat="server" AssociatedControlID="Password" CssClass="bodySmall">Password:</asp:Label></td>
                        <td>
                            <asp:TextBox ID="Password" runat="server" CssClass="text" TextMode="Password" Width="75px"></asp:TextBox>
                            <asp:RequiredFieldValidator ID="PasswordRequired" runat="server" ControlToValidate="Password"
                                ErrorMessage="Password is required." ToolTip="Password is required." ValidationGroup="ctl00$Login1">*</asp:RequiredFieldValidator>
                        </td>
                    </tr>
                    <tr>
                        <td colspan="2">
                            <asp:CheckBox ID="RememberMe" runat="server" Text="Remember me?" Width="146px" CssClass="bodySmall" />
                        </td>
                    </tr>
                    <tr>
                        <td align="center" colspan="2" CssClass="bodySmall" style="color: red">
                            <asp:Literal ID="FailureText" runat="server" EnableViewState="False"></asp:Literal>
                        </td>
                    </tr>
                    <tr>
                        <td align="right" colspan="2">
                            
                            <span style="float:left;padding-left:5;"><a runat="server" ID="lnkRegister"  title="Register for an Online Petroferm account">Register</a></span>
                            <asp:Button ID="LoginButton" runat="server" BackColor="#FFFBFF" BorderColor="#CCCCCC"
                                BorderStyle="Solid" BorderWidth="1px" CommandName="Login" Font-Names="Verdana"
                                Font-Size="0.8em" ForeColor="DimGray" Text="Log In" ValidationGroup="ctl00$Login1" />
                        </td>
                    </tr>
                </table>
            </LayoutTemplate>
        </asp:Login>
        </td>
    </tr>
</table> 