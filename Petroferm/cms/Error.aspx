<%@ Page Language="VB" MasterPageFile="~/cms/MasterCMS.master" AutoEventWireup="false" CodeFile="Error.aspx.vb" Inherits="CmsError" title="Untitled Page" %>
<%@ MasterType TypeName="MasterCMS" %> 

<asp:Content ID="myContent" ContentPlaceHolderID="phMain" Runat="Server">
    <asp:Label ID="lblFriendlyMessage" runat="server" ForeColor="Red" Font-Bold="true"></asp:Label><br />
    <br />
    <asp:Label ID="lblExceptionDetails" runat="server"></asp:Label>
    <br />
    <br />
</asp:Content>

