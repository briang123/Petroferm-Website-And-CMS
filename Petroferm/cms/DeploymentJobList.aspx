<%@ Page Language="VB" MasterPageFile="~/cms/MasterCMS.master" AutoEventWireup="false"
    CodeFile="DeploymentJobList.aspx.vb" Inherits="CmsDeploymentJobList" Title="Untitled Page"
    Theme="CMS_Theme" StylesheetTheme="CMS_Theme" %>

<%@ MasterType TypeName="MasterCMS" %>
<asp:Content ID="Content1" ContentPlaceHolderID="phMain" runat="Server">
    <asp:LinkButton ID="lbtnAdd" runat="server"><img alt="Add Deployment Job" src= "../App_Themes/CMS_Theme/images/newitem.gif" style="padding-right:5px;padding-bottom:5px;border:none;vertical-align:middle;"  />Add Deployment Job</asp:LinkButton>
    <asp:Label id="lblMessage" runat="server"></asp:Label>
    <asp:GridView ID="gvJobs" runat="server" AutoGenerateColumns="False" DataSourceID="JobListDS"
        AllowPaging="True" AllowSorting="True" DataKeyNames="DeploymentJobID">
        <Columns>
            <asp:TemplateField>
                <ItemTemplate>
                    <asp:ImageButton ID="ibtnRollback" AlternateText="Rollback Job Changes" CommandArgument='<%# Eval("DeploymentJobID") %>'
                        CommandName="RollbackItem" runat="server" ImageUrl="../App_Themes/CMS_Theme/images/undo.gif" />
                </ItemTemplate>
            </asp:TemplateField>
            <asp:TemplateField>
                <ItemTemplate>
                    <asp:ImageButton ID="ibtnEdit" AlternateText="Edit" CommandArgument='<%# Eval("DeploymentJobID") %>'
                        CommandName="GoToEditPage" runat="server" ImageUrl="../App_Themes/CMS_Theme/images/edit.gif" />
                </ItemTemplate>
            </asp:TemplateField>
            <asp:TemplateField>
                <ItemTemplate>
                    <asp:ImageButton ID="ibtnView" AlternateText="View" CommandArgument='<%# Eval("DeploymentJobID") %>'
                        CommandName="GoToReadPage" runat="server" ImageUrl="../App_Themes/CMS_Theme/images/view.gif" />
                </ItemTemplate>
            </asp:TemplateField>
            <asp:TemplateField>
                <ItemTemplate>
                    <asp:ImageButton ID="ibtnDetail" AlternateText="View Details" CommandArgument='<%# Eval("DeploymentJobID") %>'
                        CommandName="GoToDetailPage" runat="server" ImageUrl="../App_Themes/CMS_Theme/images/detail.gif" />
                </ItemTemplate>
            </asp:TemplateField>            
            <asp:BoundField DataField="JobName" HeaderText="Job Name" SortExpression="JobName" />
            <asp:BoundField DataField="JobDescription" HeaderText="Description" SortExpression="JobDescription">
            </asp:BoundField>
            <asp:BoundField DataField="WorkflowStatus" HeaderText="Workflow Status" SortExpression="WorkflowStatus">
                <ItemStyle HorizontalAlign="Center" />
            </asp:BoundField>
            <asp:BoundField DataField="ReviewByName" HeaderText="Reviewed By" SortExpression="ReviewByName" />
            <asp:BoundField DataField="ApproveByName" HeaderText="Approved By" SortExpression="ApproveByName" />
            <asp:BoundField DataField="DeployByName" HeaderText="Deployed By" SortExpression="DeployByName" />
            <asp:BoundField DataField="DeploymentDate" DataFormatString="{0:d}" HeaderText="Deployment Date"
                SortExpression="DeploymentDate" HtmlEncode="false" >
                <ItemStyle HorizontalAlign="Center" Width="60px" />
               </asp:BoundField>
            <asp:BoundField DataField="LastModifiedDate" HeaderText="Last Modified" SortExpression="LastModifiedDate" DataFormatString="{0:g}" HtmlEncode="False">
                <ItemStyle HorizontalAlign="Center" Width="60px" />
            </asp:BoundField>
            <asp:BoundField DataField="LastModByName" HeaderText="Last Modified By" SortExpression="LastModByName" />
        </Columns>
    </asp:GridView>
    <asp:ObjectDataSource ID="JobListDS" runat="server" SelectMethod="GetActiveList"
        TypeName="DeploymentJob">
    </asp:ObjectDataSource>
</asp:Content>
