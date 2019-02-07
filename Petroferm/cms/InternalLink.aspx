<%@ Page Language="VB" AutoEventWireup="false" CodeFile="InternalLink.aspx.vb" Inherits="CmsInternalLink" StylesheetTheme="CMS_Theme" %>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title>Select Internal Link</title>
    <link href="scripts/style/editor.css" rel="stylesheet" type="text/css">
<script language="JavaScript">
function insertLink(url,title,target)
	{
	if(navigator.appName.indexOf('Microsoft')!=-1)
		{
		/*For IE version
		*Use dialogArguments.oUtil.oName to get editor object name and then
		*use insertLink() function to insert your custom link
		*-------------------------------------------------------------
		*/
		
		//var oName=dialogArguments.oUtil.oName;
		//eval("dialogArguments."+oName).insertLink(url,title,target);
		
		// kr - 12/23/06 - actually use the mozilla version of this code
		var oName=window.opener.oUtil.oName;
		eval("window.opener."+oName).insertLink(url,title,target);
		self.close();
		}
	else
		{
		/*For Mozilla version
		*Use window.opener.oUtil.oName to get editor object name and then
		*use insertLink() function to insert your custom link
		*-------------------------------------------------------------
		*/
		var oName=window.opener.oUtil.oName;
		eval("window.opener."+oName).insertLink(url,title,target);
		self.close();
		}	
	}
</script>    
<style type="text/css">
    .itemHover { padding-left:3px;background-color: #74BBCE;line-height:20px;color:white; cursor:hand; }
    .altItemHover { padding-left:3px;background-color: #74BBCE;line-height:20px;color:white; cursor:hand; }
    .item { padding-left:3px;color:DimGray; background-color:#ffffff;line-height:20px; }
    .altItem { padding-left:3px;color:DimGray;background-color:#efefef;line-height:20px; }
</style>
</head>
<body style="margin: 5px 5px 5px 5px">
    <form id="form1" runat="server">
        <div style="overflow:auto;height:200px;background-color:White;border:solid 1px silver;">
            <asp:ObjectDataSource ID="InternalLinkPageDS" runat="server" SelectMethod="GetListForInternalLink"
                TypeName="WebPage"></asp:ObjectDataSource>
     
        <asp:Repeater ID="Repeater1" runat="server" DataSourceID="InternalLinkPageDS">
        
        
            <ItemTemplate>
                <div class="item" 
                    onmouseover="this.className = 'itemHover';" 
                    onmouseout="this.className = 'item';" 
                    onclick="insertLink('<%#DataBinder.Eval(Container.DataItem, "UrlFriendlyName")%>','<%#DataBinder.Eval(Container.DataItem, "LinkTitle")%>');">
                    <%#DataBinder.Eval(Container.DataItem, "PageTitleDisplay")%></div>
            </ItemTemplate>
            <AlternatingItemTemplate>
                <div class="altItem" 
                    onmouseover="this.className = 'altItemHover';" 
                    onmouseout="this.className = 'altItem';"
                    onclick="insertLink('<%#DataBinder.Eval(Container.DataItem, "UrlFriendlyName")%>','<%#DataBinder.Eval(Container.DataItem, "LinkTitle")%>');">
                    <%#DataBinder.Eval(Container.DataItem, "PageTitleDisplay")%></div>
            </AlternatingItemTemplate>
        </asp:Repeater>
                </div>
        <br />
        <div style="text-align:right;">
                <input type="button" name="btnClose" id="btnClose" value="close" onclick="self.close()"
            class="inpBtn" onmouseover="this.className='inpBtnOver';" onmouseout="this.className='inpBtnOut'">
</div>

    </form>
</body>
</html>
