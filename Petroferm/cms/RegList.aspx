<%@ Page Language="VB" MasterPageFile="~/cms/MasterCMS.master" AutoEventWireup="false" CodeFile="RegList.aspx.vb" Inherits="CmsRegList" title="Website Registration User List" Theme="CMS_Theme" StylesheetTheme="CMS_Theme" %>
<%@ MasterType TypeName="MasterCMS" %> 

<asp:Content ID="Content1" ContentPlaceHolderID="phMain" Runat="Server">
   <asp:Label id="lblMessage" runat="server"></asp:Label>
    <asp:GridView ID="gvUserList" runat="server" AutoGenerateColumns="False" DataSourceID="RegistrantDS"
        DataKeyNames="UserId" AllowPaging="True" AllowSorting="True">
        <Columns>
            <asp:TemplateField>
                <ItemTemplate>
                    <asp:ImageButton ID="ibtnDelete" AlternateText="Delete" CommandArgument='<%# Eval("UserName") %>'
                        CommandName="DeleteItem" runat="server" ImageUrl="../App_Themes/CMS_Theme/images/delcnt.gif" />
                </ItemTemplate>
            </asp:TemplateField>
            <asp:TemplateField Visible=false>
                <ItemTemplate>
                    <asp:ImageButton ID="ibtnView" AlternateText="View" CommandArgument='<%# Eval("UserName") %>'
                        CommandName="GoToReadPage" runat="server" ImageUrl="../App_Themes/CMS_Theme/images/view.gif" />
                </ItemTemplate>
            </asp:TemplateField>
            <asp:BoundField DataField="UserId" Visible="False" />
            <asp:BoundField DataField="AppUserId" Visible="False" />
            <asp:BoundField DataField="UserName" HeaderText="User Name" SortExpression="UserName" ItemStyle-HorizontalAlign="center" />
            <asp:BoundField DataField="FullName" HeaderText="Full Name" ItemStyle-HorizontalAlign="center" />
            <asp:BoundField DataField="Company" HeaderText="Company" SortExpression="Company" ItemStyle-HorizontalAlign="center" />
            <asp:BoundField DataField="Email" HeaderText="Email" SortExpression="Email" />
            <asp:BoundField DataField="Phone" HeaderText="Phone Number" />
            <asp:BoundField DataField="Region" HeaderText="Region" ItemStyle-HorizontalAlign="center" />
            <asp:TemplateField HeaderText="Locked?">
                <ItemStyle HorizontalAlign="Center" />
                <ItemTemplate>
                    <asp:Image ID="imgLocked" runat="server" ImageUrl="~/App_Themes/CMS_Theme/images/1x1.gif" AlternateText="" BorderWidth="0" />
                    <asp:ImageButton ID="ibtnLocked" CommandArgument='<%# Eval("UserName") %>' CommandName="UnlockUser" runat="server" ImageUrl="../App_Themes/CMS_Theme/images/locked.gif" AlternateText="Click to Unlock User" BorderWidth="0" />
                </ItemTemplate>
            </asp:TemplateField>
            <asp:TemplateField HeaderText="Approved?">
                <ItemStyle HorizontalAlign="Center" />
                <ItemTemplate>
                    <asp:ImageButton ID="ibtnApproveUser" CommandArgument='<%# Eval("UserName") %>' CommandName="ApproveUser" runat="server" ImageUrl="../App_Themes/CMS_Theme/images/imnhdr.gif" BorderWidth="0" />
                </ItemTemplate>
            </asp:TemplateField>
            <asp:TemplateField HeaderText="Online?" Visible="False">
                <ItemStyle HorizontalAlign="Center" />
                <ItemTemplate>
                    <asp:Image ID="imgOnline" runat="server" ImageUrl="~/App_Themes/CMS_Theme/images/1x1.gif" AlternateText="" BorderWidth="0" />
                </ItemTemplate>
            </asp:TemplateField>
            <asp:BoundField DataField="LastLoginDate" HeaderText="Last Login Date" SortExpression="LastLoginDate" Visible="False" />
            <asp:BoundField DataField="Comment" HeaderText="Comment" />
        </Columns>
    </asp:GridView>
    &nbsp;&nbsp;<asp:ObjectDataSource ID="RegistrantDS" runat="server" SelectMethod="GetList"
        TypeName="Registrant"></asp:ObjectDataSource>
</asp:Content>

