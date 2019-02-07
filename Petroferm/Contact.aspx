<%@ Page Language="VB" MasterPageFile="~/GeneralContent.master" AutoEventWireup="false" CodeFile="Contact.aspx.vb" Inherits="Contact" title="Welcome to Petroferm Inc." %>
<%@ MasterType virtualPath="GeneralContent.master" %>
<asp:Content ID="Content1" ContentPlaceHolderID="MasterBodyContent" Runat="Server">
<div class="blueTitle" id="PageTitle" runat="server">Provide Feedback</div>
<p id="BodyText" runat="server" align="left"></p>
<p id="ThankYouMessage" runat="server" align="left" style="color:red;"></p>
<table width="500px" cellpadding="2" cellspacing="0" border="0" ID="Table1">
    <tr>
        <td>Company Name</td>
        <td><input runat=server type="text" name="Company Name" class="text" size="40" ID="txtCompanyName"></td>
    </tr>
    <tr>
        <td>Full Name</td>
        <td><input runat=server type="text" name="Full Name" class="text" size="40" ID="txtFullName"></td>
    </tr>
    <tr>
        <td>Phone Number</td>
        <td><input runat=server type="text" name="Phone Number" class="text" size="40" ID="txtPhoneNumber"></td>
    </tr>
    <tr>
        <td>Email Address</td>
        <td><input runat=server type="text" name="Email Address" class="text" size="40" ID="txtEmail"></td>
    </tr>
    <tr>
        <td>Category</td>
        <td>        
            <asp:dropdownlist CssClass="text" ID="ddlCategories" runat=server />
        </td>
    </tr>
    <tr><td colspan="2">Comments</td></tr>
    <tr>
        <td colspan="2">
            <asp:textbox runat=server CssClass="text" TextMode=MultiLine Columns=90 Rows=5 ID="txtComments" Wrap="true" />
        </td>
    </tr>
    <tr id="RequestCallback" runat="server">
        <td colspan="2">
            Would you like someone to follow up with you?&nbsp;&nbsp;
            <asp:RadioButton ID="radioYes" runat="server" Text="Yes" GroupName="Callback" />&nbsp;
            <asp:RadioButton ID="radioNo" runat=server Text="No" GroupName="Callback" />
        </td>
    </tr>
    <tr>
        <td colspan="2" align="left">
            <asp:button ID="Submit" CssClass="text" runat="server" Text="Submit"></asp:button>
        </td>
    </tr>
</table>
</asp:Content>

