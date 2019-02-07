<%@ Control Language="VB" AutoEventWireup="false" CodeFile="ContentEdit.ascx.vb" Inherits="CmsControlsContentEdit" %>
<%@ Register TagPrefix="ew" Namespace="eWorld.UI" Assembly="eWorld.UI" %>   
    <div class="pageModuleEditContainer">
        <table>
           <tr>
               <td colspan="2" style="text-align: left">
                   <asp:Label ID="lblFormLabel" runat="server" CssClass="subFormTitle" Width="464px">Add/Edit Content Module</asp:Label></td>
           </tr>
            <tr>
                <td colspan="2" style="text-align: left">
                        <asp:Label ID="lblInstructions" runat="server" Width="143px" Visible="False"></asp:Label></td>
            </tr>
            <tr>
                <td style="width: 100px;" class="formFieldLabel" valign="middle">
                    Content Type</td>
                <td style="width: 433px;" valign="middle">
                    <asp:RadioButtonList ID="rdoContentType" runat="server" RepeatDirection="Horizontal">
                        <asp:ListItem Value="CONTENT">Content</asp:ListItem>
                        <asp:ListItem Value="SIDE CONTENT">Side Content</asp:ListItem>
                    </asp:RadioButtonList></td>
            </tr>
            <tr>
                <td style="width: 100px" class="formFieldLabel">
                    Title</td>
                <td style="width: 433px">
                    <asp:TextBox ID="txtTitle" runat="server" Width="282px"></asp:TextBox>
                    <asp:RequiredFieldValidator ID="vldTitleRequired" runat="server" ControlToValidate="txtTitle"
                        ErrorMessage="Title is required."></asp:RequiredFieldValidator></td>
            </tr>
           <tr>
               <td class="formFieldLabel" style="width: 100px">
                   Display Title</td>
               <td style="width: 433px">
                   <asp:CheckBox ID="chkDisplayTitle" runat="server" /></td>
           </tr>
           <tr>
               <td class="formFieldLabel" style="width: 100px; height: 21px">
                   Module Order</td>
               <td style="width: 433px; height: 21px">
                   <asp:TextBox ID="txtModuleOrder" runat="server" MaxLength="2" Width="41px"></asp:TextBox>
                   <asp:RequiredFieldValidator ID="vldOrderRequired" runat="server" ControlToValidate="txtModuleOrder"
                       Display="Dynamic" ErrorMessage="Module Order is required."></asp:RequiredFieldValidator>
                   <asp:CompareValidator ID="vldOrderValid" runat="server" ControlToValidate="txtModuleOrder"
                       Display="Dynamic" ErrorMessage="Module Order must be numeric." Operator="DataTypeCheck"
                       Type="Integer"></asp:CompareValidator>
               </td>
           </tr>
           <tr>
               <td style="width: 100px" class="formFieldLabel" valign="top">
                   Content</td>
               <td style="width: 433px" valign="top">
                   <asp:PlaceHolder ID="phContentEditor" runat="server"></asp:PlaceHolder>
               </td>
           </tr>
           <tr>
               <td class="formFieldLabel" style="width: 129px">
                   Publish Date</td>
               <td style="width: 352px">
                   <ew:calendarpopup id="dtePublishDate" runat="server" allowarbitrarytext="False" backcolor="White"
                       bordercolor="Silver" cellpadding="2px" cellspacing="0px" controldisplay="TextBoxImage"
                       culture="English (United States)" disabletextboxentry="False" displayoffsetx="20" imageurl="~/App_Themes/CMS_Theme/images/calendar-ew.gif"
                       javascriptonchangefunction="" lowerbounddate="" nullable="True" padsingledigits="True"
                       selecteddate="" showcleardate="True" text=" " upperbounddate="12/31/9999 23:59:59"
                       width="75px"><TODAYDAYSTYLE BackColor="LightGoldenrodYellow" Font-Names="Verdana,Helvetica,Tahoma,Arial" Font-Size="XX-Small" ForeColor="Black" /><WEEKENDSTYLE BackColor="LightGray" Font-Names="Verdana,Helvetica,Tahoma,Arial" Font-Size="XX-Small" ForeColor="Black" /><OFFMONTHSTYLE BackColor="AntiqueWhite" Font-Names="Verdana,Helvetica,Tahoma,Arial" Font-Size="XX-Small" ForeColor="Gray" /><WEEKDAYSTYLE BackColor="White" Font-Names="Verdana,Helvetica,Tahoma,Arial" Font-Size="XX-Small" ForeColor="Black" /><SELECTEDDATESTYLE BackColor="Yellow" Font-Names="Verdana,Helvetica,Tahoma,Arial" Font-Size="XX-Small" ForeColor="Black" /><MONTHHEADERSTYLE CssClass="popupCalendarMonthHeader" Font-Names="Verdana,Helvetica,Tahoma,Arial" Font-Size="XX-Small" ForeColor="Black" /><GOTOTODAYSTYLE BackColor="White" Font-Names="Verdana,Helvetica,Tahoma,Arial" Font-Size="XX-Small" ForeColor="Black" /><DAYHEADERSTYLE CssClass="popupCalendarDayHeader" Font-Names="Verdana,Helvetica,Tahoma,Arial" Font-Size="XX-Small" ForeColor="Black" /><CLEARDATESTYLE BackColor="White" Font-Names="Verdana,Helvetica,Tahoma,Arial" Font-Size="XX-Small" ForeColor="Black" /></ew:calendarpopup>
                   <asp:CompareValidator ID="vldPublishDateValid" runat="server" ControlToValidate="dtePublishDate"
                       Display="Dynamic" ErrorMessage="Valid publish date is required." Operator="DataTypeCheck"
                       Type="Date"></asp:CompareValidator>
               </td>
           </tr>
           <tr>
               <td class="formFieldLabel" style="width: 129px; height: 37px">
                   Expiration Date</td>
               <td style="width: 352px; height: 37px">
                   <ew:calendarpopup id="dteExpireDate" runat="server" allowarbitrarytext="False" backcolor="White"
                       bordercolor="Silver" cellpadding="2px" cellspacing="0px" controldisplay="TextBoxImage"
                       culture="English (United States)" disabletextboxentry="False" displayoffsetx="20" imageurl="~/App_Themes/CMS_Theme/images/calendar-ew.gif"
                       javascriptonchangefunction="" lowerbounddate="" nullable="True" padsingledigits="True"
                       selecteddate="" showcleardate="True" text=" " upperbounddate="12/31/9999 23:59:59"
                       width="75px"><TODAYDAYSTYLE BackColor="LightGoldenrodYellow" Font-Names="Verdana,Helvetica,Tahoma,Arial" Font-Size="XX-Small" ForeColor="Black" /><WEEKENDSTYLE BackColor="LightGray" Font-Names="Verdana,Helvetica,Tahoma,Arial" Font-Size="XX-Small" ForeColor="Black" /><OFFMONTHSTYLE BackColor="AntiqueWhite" Font-Names="Verdana,Helvetica,Tahoma,Arial" Font-Size="XX-Small" ForeColor="Gray" /><WEEKDAYSTYLE BackColor="White" Font-Names="Verdana,Helvetica,Tahoma,Arial" Font-Size="XX-Small" ForeColor="Black" /><SELECTEDDATESTYLE BackColor="Yellow" Font-Names="Verdana,Helvetica,Tahoma,Arial" Font-Size="XX-Small" ForeColor="Black" /><MONTHHEADERSTYLE CssClass="popupCalendarMonthHeader" Font-Names="Verdana,Helvetica,Tahoma,Arial" Font-Size="XX-Small" ForeColor="Black" /><GOTOTODAYSTYLE BackColor="White" Font-Names="Verdana,Helvetica,Tahoma,Arial" Font-Size="XX-Small" ForeColor="Black" /><DAYHEADERSTYLE CssClass="popupCalendarDayHeader" Font-Names="Verdana,Helvetica,Tahoma,Arial" Font-Size="XX-Small" ForeColor="Black" /><CLEARDATESTYLE BackColor="White" Font-Names="Verdana,Helvetica,Tahoma,Arial" Font-Size="XX-Small" ForeColor="Black" /></ew:calendarpopup>
                   <asp:CompareValidator ID="vldExpireDateValid" runat="server" ControlToValidate="dteExpireDate"
                       Display="Dynamic" ErrorMessage="Valid expiration date is required." Operator="DataTypeCheck"
                       Type="Date"></asp:CompareValidator>
               </td>
           </tr>
         
                   
        </table>

    </div>
 