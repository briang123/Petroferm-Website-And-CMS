<%@ Page Language="VB" MasterPageFile="~/cms/MasterCMS.master" AutoEventWireup="false" CodeFile="UserList.aspx.vb" Inherits="CmsUserList" title="Manage Users" Theme="CMS_Theme" StylesheetTheme="CMS_Theme" %>
<%@ MasterType TypeName="MasterCMS" %> 

<asp:Content ID="Content1" ContentPlaceHolderID="phMain" Runat="Server">
   <asp:LinkButton ID="lbtnAdd" runat="server"><img alt="Add User" src= "../App_Themes/CMS_Theme/images/newitem.gif" style="padding-right:5px;padding-bottom:5px;border:none;vertical-align:middle;"  />Add User</asp:LinkButton>
   <asp:Label id="lblMessage" runat="server"></asp:Label>
    <asp:GridView EnableViewState="false" ID="gvUserList" runat="server" AutoGenerateColumns="False" DataSourceID="UserDS"
        DataKeyNames="UserId" AllowPaging="True" AllowSorting="True">
        <Columns>
            <asp:TemplateField>
                <ItemTemplate>
                    <asp:ImageButton ID="ibtnDelete" AlternateText="Delete" CommandArgument='<%# Eval("UserName") %>'
                        CommandName="DeleteItem" runat="server" ImageUrl="../App_Themes/CMS_Theme/images/delcnt.gif" />
                </ItemTemplate>
            </asp:TemplateField>
            <asp:TemplateField>
                <ItemTemplate>
                    <asp:ImageButton ID="ibtnEdit" AlternateText="Edit" CommandArgument='<%# Eval("UserName") %>'
                        CommandName="GoToEditPage" runat="server" ImageUrl="../App_Themes/CMS_Theme/images/edit.gif" />
                </ItemTemplate>
            </asp:TemplateField>
            <asp:TemplateField>
                <ItemTemplate>
                    <asp:ImageButton ID="ibtnView" AlternateText="View" CommandArgument='<%# Eval("UserName") %>'
                        CommandName="GoToReadPage" runat="server" ImageUrl="../App_Themes/CMS_Theme/images/view.gif" />
                </ItemTemplate>
            </asp:TemplateField>
            <asp:BoundField DataField="UserId" Visible="false" />
            <asp:BoundField DataField="AppUserId" Visible="false" />
            <asp:BoundField DataField="UserName" HeaderText="User Name" SortExpression="UserName" />
            <asp:BoundField DataField="Email" HeaderText="Email" SortExpression="Email" />
            <asp:TemplateField HeaderText="Locked?">
                <ItemStyle HorizontalAlign="center" />
                <ItemTemplate>
                    <asp:Image ID="imgLocked" runat="server" ImageUrl="~/App_Themes/CMS_Theme/images/1x1.gif" AlternateText="" BorderWidth="0" />
                    <asp:ImageButton ID="ibtnLocked" CommandArgument='<%# Eval("UserName") %>' CommandName="UnlockUser" runat="server" ImageUrl="../App_Themes/CMS_Theme/images/locked.gif" AlternateText="Click to Unlock User" BorderWidth="0" />
                </ItemTemplate>
            </asp:TemplateField>
            <asp:TemplateField HeaderText="Approved?">
                <ItemStyle HorizontalAlign="center" />
                <ItemTemplate>
                    <asp:ImageButton ID="ibtnApproveUser" CommandArgument='<%# Eval("UserName") %>' CommandName="ApproveUser" runat="server" ImageUrl="../App_Themes/CMS_Theme/images/imnhdr.gif" BorderWidth="0" />
                </ItemTemplate>
            </asp:TemplateField>
            <asp:TemplateField HeaderText="Online?" Visible=false >
                <ItemStyle HorizontalAlign="center" />
                <ItemTemplate>
                    <asp:Image ID="imgOnline" runat="server" ImageUrl="~/App_Themes/CMS_Theme/images/1x1.gif" AlternateText="" BorderWidth="0" />
                </ItemTemplate>
            </asp:TemplateField>
            <asp:BoundField DataField="LastLoginDate" HeaderText="Last Login Date" SortExpression="LastLoginDate" Visible=false />
            <asp:BoundField DataField="Comment" HeaderText="Comment" />
        </Columns>
    </asp:GridView>
    <asp:ObjectDataSource ID="UserDS" runat="server" SelectMethod="GetList" TypeName="User" />
    &nbsp;
</asp:Content>

