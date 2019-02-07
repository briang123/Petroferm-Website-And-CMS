<%@ Page Language="VB" MasterPageFile="~/cms/MasterCMS.master" AutoEventWireup="false" CodeFile="PageList.aspx.vb" Inherits="CmsPageList" title="Untitled Page" Theme="CMS_Theme" StylesheetTheme="CMS_Theme" %>
<%@ MasterType TypeName="MasterCMS" %>
<asp:Content ID="Content1" ContentPlaceHolderID="phMain" Runat="Server">

    <asp:LinkButton ID="lbtnAdd" runat="server"><img alt="Add Page" src= "../App_Themes/CMS_Theme/images/newitem.gif" style="padding-right:5px;padding-bottom:5px;border:none;vertical-align:middle;"  />Add Page</asp:LinkButton>
   
   <br />
    <div style="padding-bottom:5px"><asp:Label ID="lblMarket" runat="server" CssClass="formFieldLabel">Filter by Market: </asp:Label>
    <asp:DropDownList ID="ddlMarket" runat="server" DataSourceID="MarketDS" DataTextField="MarketName" DataValueField="MarketID" AutoPostBack="True">
    </asp:DropDownList></div>
    <asp:Label id="lblMessage" runat="server"></asp:Label>
    
    <asp:GridView ID="gvPages" runat="server" AutoGenerateColumns="False" DataSourceID="PageListDS"
        AllowPaging="True" AllowSorting="True" DataKeyNames="PageID" EnableViewState="False">
        <Columns>
            <asp:TemplateField>
                <ItemTemplate>
                    <asp:ImageButton ID="ibtnDelete" AlternateText="Delete" CommandArgument='<%# Eval("PageID") %>'
                        CommandName="DeleteItem" runat="server" ImageUrl="../App_Themes/CMS_Theme/images/delcnt.gif" />
                </ItemTemplate>
            </asp:TemplateField>
            <asp:TemplateField>
                <ItemTemplate>
                    <asp:ImageButton ID="ibtnEdit" AlternateText="Edit" CommandArgument='<%# Eval("PageID") %>'
                        CommandName="GoToEditPage" runat="server" ImageUrl="../App_Themes/CMS_Theme/images/edit.gif" />
                </ItemTemplate>
            </asp:TemplateField>
            <asp:TemplateField>
                <ItemTemplate>
                    <asp:ImageButton ID="ibtnView" AlternateText="View" CommandArgument='<%# Eval("PageID") %>'
                        CommandName="GoToReadPage" runat="server" ImageUrl="../App_Themes/CMS_Theme/images/view.gif" />
                </ItemTemplate>
            </asp:TemplateField>
            <asp:BoundField DataField="PageTitle" HeaderText="Page Title" SortExpression="PageTitle" />
            <asp:BoundField DataField="MarketName" HeaderText="Market Name" SortExpression="MarketName" />
            
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
    <asp:ObjectDataSource ID="PageListDS" runat="server" SelectMethod="GetList"
        TypeName="WebPage">
        <SelectParameters>
            <asp:SessionParameter Name="busUnitId" SessionField="BusUnitID" Type="Int32" />
            <asp:ControlParameter ControlID="ddlMarket" DefaultValue="0" Name="mktId" PropertyName="SelectedValue"
                Type="Int32" />
        </SelectParameters>
    </asp:ObjectDataSource>
    <asp:ObjectDataSource ID="MarketDS" runat="server" SelectMethod="GetListByBu" TypeName="Market">
        <SelectParameters>
            <asp:SessionParameter Name="busUnitId" SessionField="BusUnitID" Type="Int32" />
            <asp:Parameter DefaultValue="0" Name="mode" Type="Object" />
        </SelectParameters>
    </asp:ObjectDataSource>
</asp:Content>

