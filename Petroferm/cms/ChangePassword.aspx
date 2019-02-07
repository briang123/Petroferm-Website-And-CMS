<%@ Page Language="VB" MasterPageFile="~/cms/MasterCMS.master" AutoEventWireup="false" CodeFile="ChangePassword.aspx.vb" Inherits="CmsChangePassword" title="Change Password" %>
<%@ MasterType TypeName="MasterCMS" %> 
<asp:Content ID="Content1" ContentPlaceHolderID="phMain" Runat="Server">
    <asp:ChangePassword ID="ChangePassword1" runat="server" ContinueDestinationPageUrl="~/cms/Default.aspx"
        Height="101px" Width="386px">
    </asp:ChangePassword>
</asp:Content>

