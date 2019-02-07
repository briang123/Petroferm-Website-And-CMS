<%@ Page Language="VB" MasterPageFile="~/cms/MasterCMS.master" AutoEventWireup="false" CodeFile="ProductAttributeList.aspx.vb" Inherits="CmsProductAttributeList" title="Untitled Page" StylesheetTheme="CMS_Theme" Theme="CMS_Theme" %>
<%@ MasterType TypeName="MasterCMS" %> 
<asp:Content ID="Content1" ContentPlaceHolderID="phMain" Runat="Server">
<asp:LinkButton ID="lbtnAdd" runat="server"><img alt="Add Product Attribute" src= "../App_Themes/CMS_Theme/images/newitem.gif" style="padding-right:5px;padding-bottom:5px;border:none;vertical-align:middle;"  />Add Product Attribute</asp:LinkButton>

<br /><asp:Label runat="server" ID="lblMessage"></asp:Label>
    <asp:GridView ID="gvProductAttributes" runat="server" AutoGenerateColumns="False" DataSourceID="ProdAttribDS"
        AllowPaging="True" AllowSorting="True" DataKeyNames="AttribTypeID">
        <Columns>
            <asp:TemplateField>
                <ItemTemplate>
                    <asp:ImageButton ID="ibtnDelete" AlternateText="Delete" CommandArgument='<%# Eval("AttribTypeID") %>'
                        CommandName="DeleteItem" runat="server" ImageUrl="../App_Themes/CMS_Theme/images/delcnt.gif" />
                </ItemTemplate>
            </asp:TemplateField>
            <asp:TemplateField>
                <ItemTemplate>
                    <asp:ImageButton ID="ibtnEdit" AlternateText="Edit" CommandArgument='<%# Eval("AttribTypeID") %>'
                        CommandName="GoToEditPage" runat="server" ImageUrl="../App_Themes/CMS_Theme/images/edit.gif" />
                </ItemTemplate>
            </asp:TemplateField>
            <asp:TemplateField>
                <ItemTemplate>
                    <asp:ImageButton ID="ibtnView" AlternateText="View" CommandArgument='<%# Eval("AttribTypeID") %>'
                        CommandName="GoToReadPage" runat="server" ImageUrl="../App_Themes/CMS_Theme/images/view.gif" />
                </ItemTemplate>
            </asp:TemplateField>
            <asp:BoundField DataField="AttribName" HeaderText="Attribute Name" SortExpression="AttribName" />
            <asp:BoundField DataField="FmtAllowMultiple" HeaderText="Allow Multiple" SortExpression="FmtAllowMultiple">
                <ItemStyle HorizontalAlign="Center" />
            </asp:BoundField>
            <asp:BoundField DataField="FmtIsReadOnly" HeaderText="Read Only"
                SortExpression="FmtIsReadOnly">
                <ItemStyle HorizontalAlign="Center" Width="65px" />
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
                SortExpression="FmtMarkedForDeletion">
                <ItemStyle HorizontalAlign="Center" Width="65px" />
            </asp:BoundField>
        </Columns>
    </asp:GridView>

    <asp:ObjectDataSource ID="ProdAttribDS" runat="server" SelectMethod="GetList" TypeName="ProductAttribute">
        <SelectParameters>
            <asp:SessionParameter Name="busUnitId" SessionField="BusUnitID" Type="Int32" />
        </SelectParameters>
    </asp:ObjectDataSource>


</asp:Content>

