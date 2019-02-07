<%@ Page Language="VB" MasterPageFile="~/cms/MasterCMS.master" AutoEventWireup="false"
    CodeFile="MarketList.aspx.vb" Inherits="CmsMarketList" Title="Untitled Page"
    Theme="CMS_Theme" StylesheetTheme="CMS_Theme" %>

<%@ MasterType TypeName="MasterCMS" %>
<asp:Content ID="Content1" ContentPlaceHolderID="phMain" runat="Server">
    <asp:LinkButton ID="lbtnAdd" runat="server"><img alt="Add Market" src= "../App_Themes/CMS_Theme/images/newitem.gif" style="padding-right:5px;padding-bottom:5px;border:none;vertical-align:middle;"  />Add Market</asp:LinkButton>
    <asp:Label id="lblMessage" runat="server"></asp:Label>
    <asp:GridView ID="gvMarket" runat="server" AutoGenerateColumns="False" DataSourceID="MarketListDS"
        AllowPaging="True" AllowSorting="True" DataKeyNames="MarketID">
        <Columns>
            <asp:TemplateField>
                <ItemTemplate>
                    <asp:ImageButton ID="ibtnDelete" AlternateText="Delete" CommandArgument='<%# Eval("MarketID") %>'
                        CommandName="DeleteItem" runat="server" ImageUrl="../App_Themes/CMS_Theme/images/delcnt.gif" />
                </ItemTemplate>
            </asp:TemplateField>
            <asp:TemplateField>
                <ItemTemplate>
                    <asp:ImageButton ID="ibtnEdit" AlternateText="Edit" CommandArgument='<%# Eval("MarketID") %>'
                        CommandName="GoToEditPage" runat="server" ImageUrl="../App_Themes/CMS_Theme/images/edit.gif" />
                </ItemTemplate>
            </asp:TemplateField>
            <asp:TemplateField>
                <ItemTemplate>
                    <asp:ImageButton ID="ibtnView" AlternateText="View" CommandArgument='<%# Eval("MarketID") %>'
                        CommandName="GoToReadPage" runat="server" ImageUrl="../App_Themes/CMS_Theme/images/view.gif" />
                </ItemTemplate>
            </asp:TemplateField>
            <asp:BoundField DataField="MarketName" HeaderText="Market Name" SortExpression="MarketName" />
            <asp:BoundField DataField="MarketOrder" HeaderText="Order" SortExpression="MarketOrder">
                <ItemStyle HorizontalAlign="Center" />
            </asp:BoundField>
            <asp:BoundField DataField="WorkflowStatus" HeaderText="Workflow Status" SortExpression="WorkflowStatus">
                <ItemStyle HorizontalAlign="Center" />
            </asp:BoundField>
            <asp:BoundField DataField="PublishDate" HeaderText="Publish Date" SortExpression="PublishDate" DataFormatString="{0:d}" HtmlEncode="False">
                <ItemStyle HorizontalAlign="Center" />
            </asp:BoundField>
            <asp:BoundField DataField="ExpirationDate" HeaderText="Expire Date" SortExpression="ExpirationDate" DataFormatString="{0:d}" HtmlEncode="False">
                <ItemStyle HorizontalAlign="Center" />
            </asp:BoundField>
            <asp:BoundField DataField="JobName" HeaderText="Job Name" SortExpression="JobName" />
            <asp:BoundField DataField="LastModifiedDate" HeaderText="Last Modified" SortExpression="LastModifiedDate" DataFormatString="{0:g}" HtmlEncode="False">
                <ItemStyle HorizontalAlign="Center" Width="60px" />
            </asp:BoundField>
            <asp:BoundField DataField="FmtMarkedForDeletion" HeaderText="Marked for Deletion"
                SortExpression="MarkedForDeletion">
                <ItemStyle HorizontalAlign="Center" Width="65px" />
            </asp:BoundField>
        </Columns>
    </asp:GridView>
    <asp:ObjectDataSource ID="MarketListDS" runat="server" SelectMethod="GetListByBu"
        TypeName="Market">
        <SelectParameters>
            <asp:SessionParameter Name="busUnitId" SessionField="BusUnitID" Type="Int32" />
            <asp:Parameter DefaultValue="0" Name="mode" Type="Object" />
        </SelectParameters>
    </asp:ObjectDataSource>
</asp:Content>
