<%@ Control Language="VB" AutoEventWireup="false" CodeFile="HeaderSideContentEdit.ascx.vb" Inherits="CmsControlsHeaderSideContentEdit" %>
<%@ Register TagPrefix="ew" Namespace="eWorld.UI" Assembly="eWorld.UI" %>   
    <div class="pageModuleEditContainer">
        <table>
           <tr>
               <td colspan="2" style="text-align: left">
                   <asp:Label ID="lblFormLabel" runat="server" CssClass="subFormTitle" Width="464px">Add/Edit Header Side Content Module</asp:Label></td>
           </tr>
            <tr>
                <td colspan="2" style="text-align: left">
                        <asp:Label ID="lblInstructions" runat="server" Width="143px" Visible="False"></asp:Label></td>
            </tr>
            <tr>
                <td style="width: 97px" class="formFieldLabel">
                    Title</td>
                <td style="width: 573px">
                    <asp:TextBox ID="txtTitle" runat="server" Width="282px"></asp:TextBox>
                    <asp:RequiredFieldValidator ID="vldTitleRequired" runat="server" ControlToValidate="txtTitle"
                        ErrorMessage="Title is required."></asp:RequiredFieldValidator></td>
            </tr>
            <tr>
                <td style="width: 573px; height: 21px" colspan="2"><table style="width: 100%;" class="pageModuleSubform">
                        <tr>
                            <td class="formFieldLabel" style="width: 60px">
                                Item 1
                            </td>
                            <td class="formFieldLabel" style="width: 130px" >
                                Text
                            </td>
                            <td>
                                <asp:TextBox ID="txtLineText1" runat="server" Width="282px"></asp:TextBox></td>
                        </tr>
                        <tr>
                            <td class="formFieldLabel" style="width: 60px">
                            </td>
                            <td class="formFieldLabel" style="width: 130px">Select Link Type
                            </td>
                            <td>
                                <asp:RadioButtonList ID="rdoLinkType1" runat="server" AutoPostBack="True" RepeatDirection="Horizontal">
                                    <asp:ListItem>Internal Link</asp:ListItem>
                                    <asp:ListItem>External Link</asp:ListItem>
                                </asp:RadioButtonList></td>
                        </tr>
                        <tr runat="server" ID="trInternalLinkForm1a">
                            <td class="formFieldLabel" style="width: 60px">
                            </td>
                            <td class="formFieldLabel" style="width: 130px">
                                Internal&nbsp;Link&nbsp;Type</td>
                            <td>
                                <asp:DropDownList ID="ddlInternalLinkType1" runat="server" AutoPostBack="True">
                                    <asp:ListItem>-- Select Link Type --</asp:ListItem>
                                    <asp:ListItem Value="DOCUMENT">Document</asp:ListItem>
                                    <asp:ListItem Value="PAGE">Page</asp:ListItem>
                                </asp:DropDownList></td>
                        </tr>
                        <tr runat="server" ID="trInternalLinkForm1b">
                            <td class="formFieldLabel" style="width: 60px">
                            </td>
                            <td class="formFieldLabel" style="width: 130px">
                                Internal&nbsp;Link&nbsp;Item</td>
                            <td>
                                <asp:DropDownList ID="ddlInternalLink1" runat="server" Width="350px">
                                </asp:DropDownList></td>
                        </tr>
                        <tr runat="server" ID="trExternalLinkForm1">
                            <td class="formFieldLabel" style="width: 60px">
                            </td>
                            <td class="formFieldLabel" style="width: 130px">
                                External&nbsp;Link&nbsp;URL</td>
                            <td>
                                <asp:TextBox ID="txtExternalLinkURL1" runat="server" Width="282px"></asp:TextBox><br />
                            </td>
                        </tr>
                    </table>
                </td>
            </tr>
            <tr>
                <td style="width: 573px; height: 21px" colspan="2"><table style="width: 100%" class="pageModuleSubform">
                    <tr>
                        <td class="formFieldLabel" style="width: 60px">
                    Item 2&nbsp;
                        </td>
                        <td class="formFieldLabel" style="width: 130px" >
                            Text
                        </td>
                        <td>
                            <asp:TextBox ID="txtLineText2" runat="server" Width="282px"></asp:TextBox></td>
                    </tr>
                    <tr>
                        <td class="formFieldLabel" style="width: 60px; height: 47px">
                        </td>
                        <td class="formFieldLabel" style="width: 130px; height: 47px">
                            Select Link Type
                        </td>
                        <td style="height: 47px">
                            <asp:RadioButtonList ID="rdoLinkType2" runat="server" AutoPostBack="True" RepeatDirection="Horizontal">
                                <asp:ListItem>Internal Link</asp:ListItem>
                                <asp:ListItem>External Link</asp:ListItem>
                            </asp:RadioButtonList></td>
                    </tr>
                    <tr runat="server" ID="trInternalLinkForm2a">
                        <td class="formFieldLabel" style="width: 60px">
                        </td>
                        <td class="formFieldLabel" style="width: 130px">
                            Internal Link Type</td>
                        <td><asp:DropDownList ID="ddlInternalLinkType2" runat="server" AppendDataBoundItems="True" AutoPostBack="True">
                            <asp:ListItem>-- Select Link Type --</asp:ListItem>
                            <asp:ListItem Value="DOCUMENT">Document</asp:ListItem>
                            <asp:ListItem Value="PAGE">Page</asp:ListItem>
                        </asp:DropDownList></td>
                    </tr>
                    <tr runat="server" ID="trInternalLinkForm2b">
                        <td class="formFieldLabel" style="width: 60px">
                        </td>
                        <td class="formFieldLabel" style="width: 130px">
                            Internal Link Item</td>
                        <td>
                            <asp:DropDownList ID="ddlInternalLink2" runat="server" Width="350px">
                            </asp:DropDownList></td>
                    </tr>
                    <tr runat="server" ID="trExternalLinkForm2">
                        <td class="formFieldLabel" style="width: 60px">
                        </td>
                        <td class="formFieldLabel" style="width: 130px">
                            External Link URL</td>
                        <td>
                            <asp:TextBox ID="txtExternalLinkURL2" runat="server" Width="282px"></asp:TextBox><br />
                        </td>
                    </tr>
                </table>
                </td>
            </tr>
           <tr>
               <td class="formFieldLabel" style="width: 97px">
                   Publish Date</td>
               <td style="width: 573px">
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
               <td class="formFieldLabel" style="width: 97px; height: 37px">
                   Expiration Date</td>
               <td style="width: 573px; height: 37px">
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
<asp:ObjectDataSource ID="InternalLinkDocDS" runat="server" SelectMethod="GetListByBu"
    TypeName="Document">
    <SelectParameters>
        <asp:SessionParameter Name="busUnitId" SessionField="BusUnitID" Type="Int32" />
        <asp:Parameter DefaultValue="False" Name="liveMode" Type="Boolean" />
    </SelectParameters>
</asp:ObjectDataSource>
<asp:ObjectDataSource ID="InternalLinkPageDS" runat="server" SelectMethod="GetListForInternalLink"
    TypeName="WebPage"></asp:ObjectDataSource>
 