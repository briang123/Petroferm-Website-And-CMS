<%@ Page Language="VB" MasterPageFile="~/cms/MasterCMS.master" AutoEventWireup="false"
    CodeFile="DeploymentJobDetail.aspx.vb" Inherits="CmsDeploymentJobDetail" Title="Untitled Page"
    Theme="CMS_Theme" StylesheetTheme="CMS_Theme" %>

<%@ MasterType TypeName="MasterCMS" %>
<asp:Content ID="Content1" ContentPlaceHolderID="phMain" runat="Server">
    <asp:Label id="lblMessage" runat="server"></asp:Label><br />
    <asp:Label ID="lblJobDetail" runat="server" CssClass="subFormTitle">Deployment Job Information</asp:Label><br />
    <br />
    <table style="border-right: 1px solid; border-top: 1px solid; border-left: 1px solid;
        border-bottom: 1px solid; background-color: #efefef" width="800">
        <tr>
            <td class="formFieldLabel" style="width: 200px">
                Job Name</td>
            <td class="" style="width: 600px">
                <asp:Label ID="lblJobName" runat="server" EnableViewState="False"></asp:Label></td>
        </tr>
        <tr>
            <td class="formFieldLabel" style="width: 200px">
                Description</td>
            <td class="" style="width: 600px">
                <asp:Label ID="lblJobDesc" runat="server" EnableViewState="False"></asp:Label></td>
        </tr>
        <tr>
            <td class="formFieldLabel" style="width: 200px">
                Workflow Status</td>
            <td class="" style="width: 600px">
                <asp:Label ID="lblWorkflowStatus" runat="server" EnableViewState="False"></asp:Label></td>
        </tr>
        <tr>
            <td class="formFieldLabel" style="width: 200px">
                Reviewed By</td>
            <td class="" style="width: 600px">
                <asp:Label ID="lblReviewedBy" runat="server" EnableViewState="False"></asp:Label></td>
        </tr>
        <tr>
            <td class="formFieldLabel" style="width: 200px">
                Approved By</td>
            <td class="" style="width: 600px">
                <asp:Label ID="lblApprovedBy" runat="server" EnableViewState="False"></asp:Label></td>
        </tr>
        <tr>
            <td class="formFieldLabel" style="height: 18px; width: 200px;">
                Deployed By</td>
            <td class="" style="width: 600px; height: 18px">
                <asp:Label ID="lblDeployedBy" runat="server" EnableViewState="False"></asp:Label></td>
        </tr>
        <tr>
            <td class="formFieldLabel" style="width: 200px">
                Deployment Date</td>
            <td class="" style="width: 600px">
                <asp:Label ID="lblDeploymentDate" runat="server" EnableViewState="False"></asp:Label></td>
        </tr>
        <tr>
            <td class="formFieldLabel" style="width: 200px">
                Last Modified By</td>
            <td class="" style="width: 600px">
                <asp:Label ID="lblLastModByName" runat="server" EnableViewState="False"></asp:Label></td>
        </tr>
        <tr>
            <td class="formFieldLabel" style="height: 16px; width: 200px;">
                Last Modified Date</td>
            <td class="" style="width: 600px; height: 16px">
                <asp:Label ID="lblLastModDate" runat="server" EnableViewState="False"></asp:Label></td>
        </tr>
        <tr runat="server" ID="trChangeWorkflowStatus">
            <td class="formFieldLabel" style="width: 200px; height: 16px" valign="top">
                Change Workflow Status</td>
            <td class="" style="width: 600px; height: 16px">
                <span style="font-size: 7pt">
                WORKING =&gt; PENDING REVIEW =&gt; PENDING APPROVAL =&gt; PENDING DEPLOYMENT =&gt;
                LIVE<br />
                </span>
                <asp:Button ID="btnAccept" runat="server" Text="Accept Changes" />&nbsp;
                <asp:Button ID="btnReject" runat="server" Text="Reject Changes" />
                <br />
    <asp:Label ID="lblInstructions" runat="server" EnableViewState="False"></asp:Label></td>
        </tr>
    </table>
    <br />
    <br />
    <asp:Panel runat="server" ID="pnlChangeDetail">
    <asp:Label ID="lblBusinessUnitHeading" runat="server" CssClass="subFormTitle">Business Units</asp:Label>
    <asp:HyperLink ID="lnkManageBUs" runat="server" NavigateUrl="~/cms/BusinessUnitList.aspx">Manage Business Units</asp:HyperLink><br />
    <asp:Label ID="lblBusinessUnitsNone" runat="server" Visible="False">(None)</asp:Label>
    <asp:GridView ID="gvBusUnitList" runat="server" AllowPaging="True" AllowSorting="True"
        AutoGenerateColumns="False" DataKeyNames="BusinessUnitID" DataSourceID="BusinessUnitDS" EnableViewState="False">
        <Columns>
            <asp:TemplateField Visible="False">
                <ItemTemplate>
                    <asp:ImageButton ID="ibtnDelete" runat="server" AlternateText="Delete" CommandArgument='<%# Eval("BusinessUnitID") %>'
                        CommandName="DeleteItem" ImageUrl="../App_Themes/CMS_Theme/images/delcnt.gif" />
                </ItemTemplate>
            </asp:TemplateField>
            <asp:TemplateField Visible="False">
                <ItemTemplate>
                    <asp:ImageButton ID="ibtnEdit" runat="server" AlternateText="Edit" CommandArgument='<%# Eval("BusinessUnitID") %>'
                        CommandName="GoToEditPage" ImageUrl="../App_Themes/CMS_Theme/images/edit.gif" />
                </ItemTemplate>
            </asp:TemplateField>
            <asp:TemplateField Visible="False">
                <ItemTemplate>
                    <asp:ImageButton ID="ibtnView" runat="server" AlternateText="View" CommandArgument='<%# Eval("BusinessUnitID") %>'
                        CommandName="GoToReadPage" ImageUrl="../App_Themes/CMS_Theme/images/view.gif" />
                </ItemTemplate>
            </asp:TemplateField>
            <asp:BoundField DataField="BusinessUnitName" HeaderText="Business Name" SortExpression="BusinessUnitName" />
            <asp:BoundField DataField="FmtDocAuthorization" HeaderText="Doc Auth" SortExpression="DocAuthorization">
                <ItemStyle HorizontalAlign="Center" />
            </asp:BoundField>
            <asp:TemplateField HeaderText="Logo">
                <ItemTemplate>
                    <asp:Image ID="imgLogo" runat="server" />
                </ItemTemplate>
            </asp:TemplateField>
            <asp:BoundField DataField="WorkflowStatus" HeaderText="Workflow Status" SortExpression="WorkflowStatus">
                <ItemStyle HorizontalAlign="Center" />
            </asp:BoundField>
            <asp:BoundField DataField="PublishDate" DataFormatString="{0:d}" HeaderText="Publish Date"
                HtmlEncode="False" SortExpression="PublishDate">
                <ItemStyle HorizontalAlign="Center" />
            </asp:BoundField>
            <asp:BoundField DataField="ExpirationDate" DataFormatString="{0:d}" HeaderText="Expire Date"
                HtmlEncode="False" SortExpression="ExpirationDate">
                <ItemStyle HorizontalAlign="Center" />
            </asp:BoundField>
            <asp:BoundField DataField="JobName" HeaderText="Job Name" SortExpression="JobName" />
            <asp:BoundField DataField="LastModifiedDate" DataFormatString="{0:g}" HeaderText="Last Modified"
                HtmlEncode="False" SortExpression="LastModifiedDate">
                <ItemStyle HorizontalAlign="Center" Width="60px" />
            </asp:BoundField>
            <asp:BoundField DataField="FmtMarkedForDeletion" HeaderText="Marked for Deletion"
                SortExpression="MarkedForDeletion">
                <ItemStyle HorizontalAlign="Center" Width="65px" />
            </asp:BoundField>
        </Columns>
    </asp:GridView>
    <asp:ObjectDataSource ID="BusinessUnitDS" runat="server" SelectMethod="GetListByJob"
        TypeName="BusinessUnit">
        <SelectParameters>
            <asp:SessionParameter Name="jobId" SessionField="FormJobID" Type="Int32" />
        </SelectParameters>
    </asp:ObjectDataSource>
    <br />
    <asp:Label ID="lblMarketsHeading" runat="server" CssClass="subFormTitle">Markets</asp:Label>
    <asp:HyperLink ID="lnkManageMarkets" runat="server" NavigateUrl="~/cms/MarketList.aspx">Manage Markets</asp:HyperLink><br />
    <asp:Label ID="lblMarketsNone" runat="server" Visible="False">(None)</asp:Label><asp:GridView
        ID="gvMarket" runat="server" AllowPaging="True" AllowSorting="True" AutoGenerateColumns="False"
        DataKeyNames="MarketID" DataSourceID="MarketListDS" EnableViewState="False">
        <Columns>
            <asp:TemplateField Visible="False">
                <ItemTemplate>
                    <asp:ImageButton ID="ibtnDelete" runat="server" AlternateText="Delete" CommandArgument='<%# Eval("MarketID") %>'
                        CommandName="DeleteItem" ImageUrl="../App_Themes/CMS_Theme/images/delcnt.gif" />
                </ItemTemplate>
            </asp:TemplateField>
            <asp:TemplateField Visible="False">
                <ItemTemplate>
                    <asp:ImageButton ID="ibtnEdit" runat="server" AlternateText="Edit" CommandArgument='<%# Eval("MarketID") %>'
                        CommandName="GoToEditPage" ImageUrl="../App_Themes/CMS_Theme/images/edit.gif" />
                </ItemTemplate>
            </asp:TemplateField>
            <asp:TemplateField Visible="False">
                <ItemTemplate>
                    <asp:ImageButton ID="ibtnView" runat="server" AlternateText="View" CommandArgument='<%# Eval("MarketID") %>'
                        CommandName="GoToReadPage" ImageUrl="../App_Themes/CMS_Theme/images/view.gif" />
                </ItemTemplate>
            </asp:TemplateField>
            <asp:BoundField DataField="MarketName" HeaderText="Market Name" SortExpression="MarketName" />
            <asp:BoundField DataField="MarketOrder" HeaderText="Order" SortExpression="MarketOrder">
                <ItemStyle HorizontalAlign="Center" />
            </asp:BoundField>
            <asp:BoundField DataField="WorkflowStatus" HeaderText="Workflow Status" SortExpression="WorkflowStatus">
                <ItemStyle HorizontalAlign="Center" />
            </asp:BoundField>
            <asp:BoundField DataField="PublishDate" DataFormatString="{0:d}" HeaderText="Publish Date"
                HtmlEncode="False" SortExpression="PublishDate">
                <ItemStyle HorizontalAlign="Center" />
            </asp:BoundField>
            <asp:BoundField DataField="ExpirationDate" DataFormatString="{0:d}" HeaderText="Expire Date"
                HtmlEncode="False" SortExpression="ExpirationDate">
                <ItemStyle HorizontalAlign="Center" />
            </asp:BoundField>
            <asp:BoundField DataField="JobName" HeaderText="Job Name" SortExpression="JobName" />
            <asp:BoundField DataField="LastModifiedDate" DataFormatString="{0:g}" HeaderText="Last Modified"
                HtmlEncode="False" SortExpression="LastModifiedDate">
                <ItemStyle HorizontalAlign="Center" Width="60px" />
            </asp:BoundField>
            <asp:BoundField DataField="FmtMarkedForDeletion" HeaderText="Marked for Deletion"
                SortExpression="MarkedForDeletion">
                <ItemStyle HorizontalAlign="Center" Width="65px" />
            </asp:BoundField>
        </Columns>
    </asp:GridView>
    <asp:ObjectDataSource ID="MarketListDS" runat="server" SelectMethod="GetListByJob"
        TypeName="Market">
        <SelectParameters>
            <asp:SessionParameter Name="jobId" SessionField="FormJobID" Type="Int32" />
        </SelectParameters>
    </asp:ObjectDataSource>
    &nbsp;<br />
    
        <asp:Label ID="lblProductListHeading" runat="server" CssClass="subFormTitle">Products</asp:Label>
        <asp:HyperLink ID="lnkManageProducts" runat="server" NavigateUrl="~/cms/ProductList.aspx">Manage Products</asp:HyperLink><br />
        <asp:Label ID="lblProductListNone" runat="server" Visible="false">(None)</asp:Label>
    <asp:GridView ID="gvProducts" runat="server" AllowPaging="True" AllowSorting="True"
        AutoGenerateColumns="False" DataKeyNames="ProductID" DataSourceID="ProductDS"
        EnableTheming="True" width="800px" EnableViewState="False">
        <Columns>
            <asp:TemplateField Visible="False">
                <ItemTemplate>
                    <asp:ImageButton ID="ibtnDelete" runat="server" AlternateText="Delete" CommandArgument='<%# Eval("ProductID") %>'
                        CommandName="DeleteItem" ImageUrl="../App_Themes/CMS_Theme/images/delcnt.gif" />
                </ItemTemplate>
            </asp:TemplateField>
            <asp:TemplateField Visible="False">
                <ItemTemplate>
                    <asp:ImageButton ID="ibtnEdit" runat="server" AlternateText="Edit" CommandArgument='<%# Eval("ProductID") %>'
                        CommandName="GoToEditPage" ImageUrl="../App_Themes/CMS_Theme/images/edit.gif" />
                </ItemTemplate>
            </asp:TemplateField>
            <asp:TemplateField Visible="False">
                <ItemTemplate>
                    <asp:ImageButton ID="ibtnView" runat="server" AlternateText="View" CommandArgument='<%# Eval("ProductID") %>'
                        CommandName="GoToReadPage" ImageUrl="../App_Themes/CMS_Theme/images/view.gif" />
                </ItemTemplate>
            </asp:TemplateField>
            <asp:BoundField DataField="ProductName" HeaderText="Product Name" SortExpression="ProductName" />
            <asp:BoundField DataField="WorkflowStatus" HeaderText="Workflow Status" SortExpression="WorkflowStatus">
                <ItemStyle HorizontalAlign="Center" />
            </asp:BoundField>
            <asp:BoundField DataField="PublishDate" DataFormatString="{0:d}" HeaderText="Publish Date"
                HtmlEncode="False" SortExpression="PublishDate">
                <ItemStyle HorizontalAlign="Center" />
            </asp:BoundField>
            <asp:BoundField DataField="ExpirationDate" DataFormatString="{0:d}" HeaderText="Expire Date"
                HtmlEncode="False" SortExpression="ExpirationDate">
                <ItemStyle HorizontalAlign="Center" />
            </asp:BoundField>
            <asp:BoundField DataField="JobName" HeaderText="Job Name" SortExpression="JobName" />
            <asp:BoundField DataField="LastModifiedDate" DataFormatString="{0:g}" HeaderText="Last Modified"
                HtmlEncode="False" SortExpression="LastModifiedDate">
                <ItemStyle HorizontalAlign="Center" Width="60px" />
            </asp:BoundField>
            <asp:BoundField DataField="FmtMarkedForDeletion" HeaderText="Marked for Deletion"
                SortExpression="FmtMarkedForDeletion">
                <ItemStyle HorizontalAlign="Center" Width="65px" />
            </asp:BoundField>
        </Columns>
    </asp:GridView>
    <asp:ObjectDataSource ID="ProductDS" runat="server" SelectMethod="GetListByJob" TypeName="Product">
        <SelectParameters>
            <asp:SessionParameter Name="jobId" SessionField="FormJobID" Type="Int32" />
        </SelectParameters>
    </asp:ObjectDataSource>
    <br />
        <asp:Label ID="lblProductAttributesHeading" runat="server" CssClass="subFormTitle">Product Attributes</asp:Label>
    <asp:HyperLink ID="lnkManageProductAttributes" runat="server" NavigateUrl="~/cms/ProductAttributeList.aspx">Manage Product Attributes</asp:HyperLink><br />
        <asp:Label ID="lblProductAttributesNone" runat="server" Visible="false">(None)</asp:Label>
    <asp:GridView ID="gvProductAttributes" runat="server" AllowPaging="True" AllowSorting="True"
        AutoGenerateColumns="False" DataKeyNames="AttribTypeID" DataSourceID="ProdAttribDS" width="800px" EnableViewState="False">
        <Columns>
            <asp:TemplateField Visible="False">
                <ItemTemplate>
                    <asp:ImageButton ID="ibtnDelete" runat="server" AlternateText="Delete" CommandArgument='<%# Eval("AttribTypeID") %>'
                        CommandName="DeleteItem" ImageUrl="../App_Themes/CMS_Theme/images/delcnt.gif" />
                </ItemTemplate>
            </asp:TemplateField>
            <asp:TemplateField Visible="False">
                <ItemTemplate>
                    <asp:ImageButton ID="ibtnEdit" runat="server" AlternateText="Edit" CommandArgument='<%# Eval("AttribTypeID") %>'
                        CommandName="GoToEditPage" ImageUrl="../App_Themes/CMS_Theme/images/edit.gif" />
                </ItemTemplate>
            </asp:TemplateField>
            <asp:TemplateField Visible="False">
                <ItemTemplate>
                    <asp:ImageButton ID="ibtnView" runat="server" AlternateText="View" CommandArgument='<%# Eval("AttribTypeID") %>'
                        CommandName="GoToReadPage" ImageUrl="../App_Themes/CMS_Theme/images/view.gif" />
                </ItemTemplate>
            </asp:TemplateField>
            <asp:BoundField DataField="AttribName" HeaderText="Attribute Name" SortExpression="AttribName" />
            <asp:BoundField DataField="FmtAllowMultiple" HeaderText="Allow Multiple" SortExpression="FmtAllowMultiple">
                <ItemStyle HorizontalAlign="Center" />
            </asp:BoundField>
            <asp:BoundField DataField="FmtIsReadOnly" HeaderText="Read Only" SortExpression="FmtIsReadOnly">
                <ItemStyle HorizontalAlign="Center" Width="65px" />
            </asp:BoundField>
            <asp:BoundField DataField="WorkflowStatus" HeaderText="Workflow Status" SortExpression="WorkflowStatus">
                <ItemStyle HorizontalAlign="Center" />
            </asp:BoundField>
            <asp:BoundField DataField="PublishDate" DataFormatString="{0:d}" HeaderText="Publish Date"
                HtmlEncode="False" SortExpression="PublishDate">
                <ItemStyle HorizontalAlign="Center" />
            </asp:BoundField>
            <asp:BoundField DataField="ExpirationDate" DataFormatString="{0:d}" HeaderText="Expire Date"
                HtmlEncode="False" SortExpression="ExpirationDate">
                <ItemStyle HorizontalAlign="Center" />
            </asp:BoundField>
            <asp:BoundField DataField="JobName" HeaderText="Job Name" SortExpression="JobName" />
            <asp:BoundField DataField="LastModifiedDate" DataFormatString="{0:g}" HeaderText="Last Modified"
                HtmlEncode="False" SortExpression="LastModifiedDate">
                <ItemStyle HorizontalAlign="Center" Width="60px" />
            </asp:BoundField>
            <asp:BoundField DataField="FmtMarkedForDeletion" HeaderText="Marked for Deletion"
                SortExpression="FmtMarkedForDeletion">
                <ItemStyle HorizontalAlign="Center" Width="65px" />
            </asp:BoundField>
        </Columns>
    </asp:GridView>
    <asp:ObjectDataSource ID="ProdAttribDS" runat="server" SelectMethod="GetListByJob" TypeName="ProductAttribute">
        <SelectParameters>
            <asp:SessionParameter Name="jobId" SessionField="FormJobID" Type="Int32" />
        </SelectParameters>
    </asp:ObjectDataSource>
    <br />
    <asp:Label ID="lblSearchAttributesHeading" runat="server" CssClass="subFormTitle">Product Search Attributes</asp:Label>
    <asp:HyperLink ID="lnkManageSearchAttributes" runat="server" NavigateUrl="~/cms/SearchAttributeList.aspx">Manage Product Search Attributes</asp:HyperLink><br />
    <asp:Label ID="lblSearchAttributesNone" runat="server" Visible="False">(None)</asp:Label>
    <asp:GridView ID="gvSearchAttributes" runat="server" AllowPaging="True" AllowSorting="True"
        AutoGenerateColumns="False" DataKeyNames="SearchAttribTypeID" DataSourceID="SearchAttribListDS" width="800px" EnableViewState="False">
        <Columns>
            <asp:TemplateField Visible="False">
                <ItemTemplate>
                    <asp:ImageButton ID="ibtnDelete" runat="server" AlternateText="Delete" CommandArgument='<%# Eval("SearchAttribTypeID") %>'
                        CommandName="DeleteItem" ImageUrl="../App_Themes/CMS_Theme/images/delcnt.gif" />
                </ItemTemplate>
            </asp:TemplateField>
            <asp:TemplateField Visible="False">
                <ItemTemplate>
                    <asp:ImageButton ID="ibtnEdit" runat="server" AlternateText="Edit" CommandArgument='<%# Eval("SearchAttribTypeID") %>'
                        CommandName="GoToEditPage" ImageUrl="../App_Themes/CMS_Theme/images/edit.gif" />
                </ItemTemplate>
            </asp:TemplateField>
            <asp:TemplateField Visible="False">
                <ItemTemplate>
                    <asp:ImageButton ID="ibtnView" runat="server" AlternateText="View" CommandArgument='<%# Eval("SearchAttribTypeID") %>'
                        CommandName="GoToReadPage" ImageUrl="../App_Themes/CMS_Theme/images/view.gif" />
                </ItemTemplate>
            </asp:TemplateField>
            <asp:BoundField DataField="SearchAttributeName" HeaderText="Attribute Name" SortExpression="SearchAttributeName" />
            <asp:BoundField DataField="MarketName" HeaderText="Market" SortExpression="MarketName" />
            <asp:BoundField DataField="WorkflowStatus" HeaderText="Workflow Status" SortExpression="WorkflowStatus">
                <ItemStyle HorizontalAlign="Center" />
            </asp:BoundField>
            <asp:BoundField DataField="PublishDate" DataFormatString="{0:d}" HeaderText="Publish Date"
                HtmlEncode="False" SortExpression="PublishDate">
                <ItemStyle HorizontalAlign="Center" />
            </asp:BoundField>
            <asp:BoundField DataField="ExpirationDate" DataFormatString="{0:d}" HeaderText="Expire Date"
                HtmlEncode="False" SortExpression="ExpirationDate">
                <ItemStyle HorizontalAlign="Center" />
            </asp:BoundField>
            <asp:BoundField DataField="JobName" HeaderText="Job Name" SortExpression="JobName" />
            <asp:BoundField DataField="LastModifiedDate" DataFormatString="{0:g}" HeaderText="Last Modified"
                HtmlEncode="False" SortExpression="LastModifiedDate">
                <ItemStyle HorizontalAlign="Center" Width="60px" />
            </asp:BoundField>
            <asp:BoundField DataField="FmtMarkedForDeletion" HeaderText="Marked for Deletion"
                SortExpression="FmtMarkedForDeletion">
                <ItemStyle HorizontalAlign="Center" Width="65px" />
            </asp:BoundField>
        </Columns>
    </asp:GridView>
    <asp:ObjectDataSource ID="SearchAttribListDS" runat="server" SelectMethod="GetListByJob"
        TypeName="SearchAttribute">
        <SelectParameters>
            <asp:SessionParameter Name="jobId" SessionField="FormJobID" Type="Int32" />
        </SelectParameters>
    </asp:ObjectDataSource>
    <br />
    <asp:Label ID="lblPageListHeading" runat="server" CssClass="subFormTitle">Pages</asp:Label>
    <asp:HyperLink ID="lnkManagePages" runat="server" NavigateUrl="~/cms/PageList.aspx">Manage Pages</asp:HyperLink><br />
    <asp:Label ID="lblPageListNone" runat="server" Visible="false">(None)</asp:Label><asp:GridView ID="gvPages" runat="server" AllowPaging="True" AllowSorting="True"
        AutoGenerateColumns="False" DataKeyNames="PageID" DataSourceID="PageListDS" width="800px" EnableViewState="False">
        <Columns>
            <asp:TemplateField Visible="False">
                <ItemTemplate>
                    <asp:ImageButton ID="ibtnDelete" runat="server" AlternateText="Delete" CommandArgument='<%# Eval("PageID") %>'
                        CommandName="DeleteItem" ImageUrl="../App_Themes/CMS_Theme/images/delcnt.gif" />
                </ItemTemplate>
            </asp:TemplateField>
            <asp:TemplateField Visible="False">
                <ItemTemplate>
                    <asp:ImageButton ID="ibtnEdit" runat="server" AlternateText="Edit" CommandArgument='<%# Eval("PageID") %>'
                        CommandName="GoToEditPage" ImageUrl="../App_Themes/CMS_Theme/images/edit.gif" />
                </ItemTemplate>
            </asp:TemplateField>
            <asp:TemplateField Visible="False">
                <ItemTemplate>
                    <asp:ImageButton ID="ibtnView" runat="server" AlternateText="View" CommandArgument='<%# Eval("PageID") %>'
                        CommandName="GoToReadPage" ImageUrl="../App_Themes/CMS_Theme/images/view.gif" />
                </ItemTemplate>
            </asp:TemplateField>
            <asp:BoundField DataField="PageTitle" HeaderText="Page Title" SortExpression="PageTitle" />
            <asp:BoundField DataField="MarketName" HeaderText="Market Name" SortExpression="MarketName" />
            <asp:BoundField DataField="WorkflowStatus" HeaderText="Workflow Status" SortExpression="WorkflowStatus">
                <ItemStyle HorizontalAlign="Center" />
            </asp:BoundField>
            <asp:BoundField DataField="PublishDate" DataFormatString="{0:d}" HeaderText="Publish Date"
                HtmlEncode="False" SortExpression="PublishDate">
                <ItemStyle HorizontalAlign="Center" />
            </asp:BoundField>
            <asp:BoundField DataField="ExpirationDate" DataFormatString="{0:d}" HeaderText="Expire Date"
                HtmlEncode="False" SortExpression="ExpirationDate">
                <ItemStyle HorizontalAlign="Center" />
            </asp:BoundField>
            <asp:BoundField DataField="JobName" HeaderText="Job Name" SortExpression="JobName" />
            <asp:BoundField DataField="LastModifiedDate" DataFormatString="{0:g}" HeaderText="Last Modified"
                HtmlEncode="False" SortExpression="LastModifiedDate">
                <ItemStyle HorizontalAlign="Center" Width="60px" />
            </asp:BoundField>
            <asp:BoundField DataField="FmtMarkedForDeletion" HeaderText="Marked for Deletion"
                SortExpression="MarkedForDeletion">
                <ItemStyle HorizontalAlign="Center" Width="65px" />
            </asp:BoundField>
        </Columns>
    </asp:GridView>
    <asp:ObjectDataSource ID="PageListDS" runat="server" SelectMethod="GetListByJob"
        TypeName="WebPage">
        <SelectParameters>
            <asp:SessionParameter Name="jobId" SessionField="FormJobID" Type="Int32" />
        </SelectParameters>
    </asp:ObjectDataSource>
        <br />
        <asp:Label ID="lblPageModuleListHeading" runat="server" CssClass="subFormTitle">Page Modules</asp:Label><br />
        <asp:Label ID="lblPageModuleListNone" runat="server" Visible="False">(None)</asp:Label>
        <asp:GridView ID="gvPageModules" runat="server" AllowPaging="True" AllowSorting="True"
            AutoGenerateColumns="False" DataKeyNames="PageModuleRelnID" DataSourceID="PageModulesDS"
            EnableTheming="True" EnableViewState="False">
            <Columns>
                <asp:TemplateField Visible="False">
                    <ItemTemplate>
                        <asp:ImageButton ID="ibtnDelete" runat="server" AlternateText="Delete" CommandArgument='<%# Eval("PageModuleRelnID") %>'
                            CommandName="DeleteItem" ImageUrl="../App_Themes/CMS_Theme/images/delcnt.gif" />
                    </ItemTemplate>
                </asp:TemplateField>
                <asp:TemplateField Visible="False">
                    <ItemTemplate>
                        <asp:ImageButton ID="ibtnEdit" runat="server" AlternateText="Edit" CommandArgument='<%# Eval("PageModuleRelnID") %>'
                            CommandName="EditItem" ImageUrl="../App_Themes/CMS_Theme/images/edit.gif" />
                    </ItemTemplate>
                </asp:TemplateField>
                <asp:TemplateField Visible="False">
                    <ItemTemplate>
                        <asp:ImageButton ID="ibtnView" runat="server" AlternateText="View" CommandArgument='<%# Eval("PageModuleRelnID") %>'
                            CommandName="ReadItem" ImageUrl="../App_Themes/CMS_Theme/images/view.gif" />
                    </ItemTemplate>
                </asp:TemplateField>
                <asp:BoundField DataField="ModuleTitle" HeaderText="Module Title" SortExpression="ModuleTitle" />
                 <asp:BoundField DataField="PageTitle" HeaderText="Page Title" SortExpression="PageTitle" />
                <asp:BoundField DataField="SourceName" HeaderText="Module Type" SortExpression="SourceName" />
                <asp:BoundField DataField="ModuleOrder" HeaderText="Order" SortExpression="ModuleOrder">
                    <ItemStyle HorizontalAlign="Center" />
                </asp:BoundField>
                <asp:BoundField DataField="WorkflowStatus" HeaderText="Workflow Status" SortExpression="WorkflowStatus">
                    <ItemStyle HorizontalAlign="Center" />
                </asp:BoundField>
                <asp:BoundField DataField="PublishDate" DataFormatString="{0:d}" HeaderText="Publish Date"
                    HtmlEncode="False" SortExpression="PublishDate">
                    <ItemStyle HorizontalAlign="Center" />
                </asp:BoundField>
                <asp:BoundField DataField="ExpirationDate" DataFormatString="{0:d}" HeaderText="Expire Date"
                    HtmlEncode="False" SortExpression="ExpirationDate">
                    <ItemStyle HorizontalAlign="Center" />
                </asp:BoundField>
                <asp:BoundField DataField="JobName" HeaderText="Job Name" SortExpression="JobName" />
                <asp:BoundField DataField="LastModifiedDate" DataFormatString="{0:g}" HeaderText="Last Modified"
                    HtmlEncode="False" SortExpression="LastModifiedDate">
                    <ItemStyle HorizontalAlign="Center" Width="60px" />
                </asp:BoundField>
                <asp:BoundField DataField="FmtMarkedForDeletion" HeaderText="Marked for Deletion"
                    SortExpression="FmtMarkedForDeletion">
                    <ItemStyle HorizontalAlign="Center" Width="65px" />
                </asp:BoundField>
            </Columns>
        </asp:GridView>
        <asp:ObjectDataSource ID="PageModulesDS" runat="server" SelectMethod="GetListByJob" TypeName="PageModule">
        <SelectParameters>
            <asp:SessionParameter Name="jobId" SessionField="FormJobID" Type="Int32" />
        </SelectParameters>
        </asp:ObjectDataSource>
    <br />
    </asp:Panel>
</asp:Content>
