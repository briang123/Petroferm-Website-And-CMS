<%@ Control Language="VB" AutoEventWireup="false" CodeFile="WorkflowInfo.ascx.vb" Inherits="CmsControlsWorkflowInfo" %>
<div style="padding-top:25px;">
<table style="border: solid 1px; background-color:#efefef;">
    <tr>
        <td class="workflowLabel">Publish Date</td>
        <td class="workflowValue"><asp:Label ID="lblPublishDate" runat="server" CssClass="workflowValue"/></td>
    </tr>    
    <tr>
        <td class="workflowLabel">Expiration Date</td>
        <td class="workflowValue"><asp:Label ID="lblExpireDate" runat="server" CssClass="workflowValue"/></td>
    </tr>            
    <tr>
        <td class="workflowLabel">Workflow Status</td>
        <td class="workflowValue"><asp:Label ID="lblWorkflowStatus" runat="server" CssClass="workflowValue"/></td>
    </tr>
    <tr>
        <td class="workflowLabel">Last Modified Date</td>
        <td class="workflowValue"><asp:Label ID="lblLastModDate" runat="server" CssClass="workflowValue"/></td>
    </tr>
    <tr>
        <td class="workflowLabel">Last Modified By</td>
        <td class="workflowValue"><asp:Label ID="lblLastModByName" runat="server" CssClass="workflowValue"/></td>
    </tr>    
    <tr>
        <td class="workflowLabel">Marked For Deletion</td>
        <td class="workflowValue"><asp:Label ID="lblMarkedForDelete" runat="server" CssClass="workflowValue"/></td>
    </tr>    
    <tr>
        <td class="workflowLabel">Job Name</td>
        <td class="workflowValue"><asp:Label ID="lblJobName" runat="server" CssClass="workflowValue"/></td>
    </tr>            
    <tr>
        <td class="workflowLabel">Job Description</td>
        <td class="workflowValue"><asp:Label ID="lblJobDesc" runat="server" CssClass="workflowValue"/></td>
    </tr>            
 
</table>


</div>