<%@ Page Language="VB" MasterPageFile="~/cms/MasterCMS.master" AutoEventWireup="false" CodeFile="Login.aspx.vb" Inherits="CmsLogin" title="Untitled Page" Theme="CMS_Theme" %>
<%@ MasterType TypeName="MasterCMS" %> 
<asp:Content ID="Content1" ContentPlaceHolderID="phMain" Runat="Server">
    <asp:Login ID="Login1" runat="server" TitleText="" DisplayRememberMe="False">
    </asp:Login>
</asp:Content>

