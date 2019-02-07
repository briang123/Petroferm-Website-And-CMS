<%@ Page Language="VB" MasterPageFile="~/GeneralContent.master" AutoEventWireup="false" CodeFile="Search.aspx.vb" Inherits="Search" title="Petroferm Inc. - Search" Theme="LIVE_Theme" %>
<%@ MasterType virtualPath="GeneralContent.master" %>
<asp:Content ID="Content3" ContentPlaceHolderID="MasterBodyContent" Runat="Server">
    <div class="blueTitle"><asp:Label runat="server" ID="lblPageTitle">Search Page</asp:Label></div>
    <p>Select from one of the following to begin your search:</p>
    <asp:RadioButton ID="radioSimple" runat="server" AutoPostBack="true" GroupName="SearchType" OnCheckedChanged="radioButton_CheckedChanged" Text="Simple Search" />
    &nbsp;&nbsp; &nbsp;
    <asp:RadioButton ID="radioAdvance" runat="server" AutoPostBack="true" GroupName="SearchType" OnCheckedChanged="radioButton_CheckedChanged" Text="Advanced Search" /><br />
    <br />
    <asp:MultiView ID="MultiView1" runat="server">
        <asp:View ID="viewSimpleSearch" runat="server">
            <div style="padding:10 5 10 5; border-style:solid; border-width:1; border-color:#666666; background-color:#eeeeee;">
            <span style="float:left;" id="spanSimpleMessage"></span>
            <span style="float:right;"><a href="javascript:void(0);" onclick="var msgS=document.getElementById('spanSimpleMessage');var divTagS=document.getElementById('searchSimpleWindow');if(divTagS.style.display=='none'){divTagS.style.display='block';msgS.innerHTML='';}else{divTagS.style.display='none';msgS.innerHTML='Expand to search again...';};return false;">Show/Hide Search</a></span>
            <br /><br />
            <div id="searchSimpleWindow">
            <asp:Label ID="lblSimpleSearchInstructions" runat="server" />
            <br />
            <br />
            Enter Keyword: <asp:TextBox CssClass="text" ID="txtSimpleSearch" runat="server" Width="200"></asp:TextBox>
            <asp:Button ID="btnSearch" CssClass="text" OnClick="btnSearch_Click" runat="server" Text="Search" />&nbsp;
            </div>
            </div>
        </asp:View>
        <asp:View ID="viewAdvancedSearch" runat="server">
            <div style="padding:10 5 10 5; border-style:solid; border-width:1; border-color:#666666; background-color:#eeeeee;">
            <span style="float:left;" id="spanAdvanceMessage"></span>
            <span style="float:right;"><a href="javascript:void(0);" onclick="var msgA=document.getElementById('spanAdvanceMessage');var divTagA=document.getElementById('searchAdvancedWindow');if(divTagA.style.display=='none'){divTagA.style.display='block';msgA.innerHTML='';}else{divTagA.style.display='none';msgA.innerHTML='Expand to search again...';};return false;">Show/Hide Search</a></span>
            <br /><br />
            <div id="searchAdvancedWindow">
            <asp:Label ID="lblAdvancedSearchInstructions" runat="server" />
            <BR />
            <BR />
            Specify Business: <asp:DropDownList CssClass="text" ID="ddlBusiness" runat="server" AutoPostBack="True"></asp:DropDownList>
            <BR />
            <BR />
            Specify Market: <asp:DropDownList CssClass="text" ID="ddlMarkets" runat="server" AutoPostBack="True"></asp:DropDownList>
                <br />
            <br />
                Specify Region:
                <asp:DropDownList CssClass="text" ID="ddlRegion" runat="server" />
                <br />
                <br />
            Specify Product Name: <asp:TextBox CssClass="text" ID="txtAdvanceSearchCriteria" Width="150" runat="server"></asp:TextBox>&nbsp;(optional)<br />
            <br />
            <asp:Label ID="lblSearchAttributeInstructions" runat="server" />
            <asp:Label ID="lblSearchAttributesValidateMessage" Text="At least one search attribute must be selected." runat="server" ForeColor="red" />
            <asp:CheckBoxList ID="chkSearchAttributes" runat="server" CssClass="text" CellPadding="5" RepeatColumns="4" RepeatDirection="vertical" RepeatLayout="Table"></asp:CheckBoxList>&nbsp;<br />
            <asp:Button ID="Button1" CssClass="text" OnClick="btnSearch_Click" runat="server" Text="Search" />
                <asp:Label ID="lblNoMarketOrProductValidationMessage" Text="Custom Message Here" runat="server" ForeColor="Red" />
             </div>
             </div>
        </asp:View>
    </asp:MultiView>
    <table width="100%" border="0"><tr><td align=right><asp:Label ID="lblSearchResults" runat="server" Text=""></asp:Label></td></tr></table>
    <asp:GridView ID="GridSimpleSearch" runat="server" OnPageIndexChanging="GridSimpleSearch_PageIndexChanging" SkinID="GridViewSiteSearchSkin">
        <Columns>
            <asp:TemplateField>
                <ItemTemplate> 
                    <table width="100%">
                        <tr>
                            <td width="100%" style="font-weight:bold;"><a href="<%#Eval("UrlFriendlyName")%>" title="<%#Eval("PageTitle")%>"><%#Eval("PageTitle")%></a></td>
                        </tr>
                        <tr>
                            <td><%#GetProductName(Eval("ProductName").ToString)%><%#GetHighlightedSearchCondition(Eval("ProductBlurb").ToString, Me.txtSimpleSearch.Text.ToUpper, Eval("UrlFriendlyName").ToString)%></td>
                        </tr>
                    </table>  
                </ItemTemplate>              
            </asp:TemplateField>
        </Columns>
    </asp:GridView>
    <asp:GridView ID="GridAdvancedSearch" runat="server" OnPageIndexChanging="GridAdvancedSearch_PageIndexChanging" SkinID="GridViewSiteSearchSkin">
        <Columns>
            <asp:TemplateField>
                <ItemTemplate>
                    <div style="font-weight:bold;"><%#Eval("ProductName") %></div>
                    <%#Eval("ProductBlurb") %><br />
                    <%#GetProductDocumentByProductId(CType(Eval("ProductId"), Integer), CType(Eval("DocAuthorization"), Integer))%>
                </ItemTemplate>
            </asp:TemplateField>
        </Columns>
    </asp:GridView> 
</asp:Content>

