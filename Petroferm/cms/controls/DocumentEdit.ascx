<%@ Control Language="VB" AutoEventWireup="false" CodeFile="DocumentEdit.ascx.vb" Inherits="CmsControlsDocumentEdit" %>
<%@ Register TagPrefix="ew" Namespace="eWorld.UI" Assembly="eWorld.UI" %>   
    <div class="pageModuleEditContainer">
        <table>
           <tr>
               <td colspan="2" style="text-align: left">
                   <asp:Label ID="lblFormLabel" runat="server" CssClass="subFormTitle" Width="464px">Add/Edit Document Module</asp:Label></td>
           </tr>
            <tr>
                <td colspan="2" style="text-align: left">
                        <asp:Label ID="lblInstructions" runat="server" Width="143px" Visible="False"></asp:Label></td>
            </tr>
            <tr>
                <td style="width: 97px" class="formFieldLabel">
                    Link Text</td>
                <td style="width: 573px">
                    <asp:TextBox ID="txtDocLinkText" runat="server" Width="282px"></asp:TextBox>
                    <asp:RequiredFieldValidator ID="vldDocLinkTextRequired" runat="server" ControlToValidate="txtDocLinkText"
                        ErrorMessage="Link Text is required."></asp:RequiredFieldValidator></td>
            </tr>
            <tr>
                <td class="formFieldLabel" style="width: 97px">
                    Section</td>
                <td style="width: 573px">
                </td>
            </tr>
            <tr>
                <td class="formFieldLabel" style="width: 97px; padding-top: 5px;" valign="top">
                    Document</td>
                <td style="width: 573px">
                    <table>
                        <tr>
                            <td style="width: 175px; height: 25px;" colspan="">
                                <asp:RadioButton ID="rdoExistingDoc" runat="server" GroupName="DocumentSelection"
                                    Text="Existing Document" AutoPostBack="True" /></td>
                            <td style="width: 375px; height: 25px;">
                                <asp:DropDownList ID="ddlExistingDoc" runat="server" DataSourceID="InternalLinkDocDS" DataTextField="DocTitle" DataValueField="DocumentID">
                                </asp:DropDownList></td>
                        </tr>
                        <tr>
                            <td style="width: 175px; height: 22px;" colspan="">
                                <asp:RadioButton ID="rdoUploadNewDoc" runat="server" GroupName="DocumentSelection" Text="Upload New Document" AutoPostBack="True" /></td>
                            <td style="width: 375px; height: 22px;">
                            </td>
                        </tr>
                        <tr>
                            <td colspan="3" style="text-indent: 10px">
                                <table id="tblUploadNewDoc" runat="server">
                                    <tr>
                                        <td style="width: 13px">
                                        </td>
                                        <td style="width: 100px">
                                            Document Title</td>
                                        <td>
                                            <asp:TextBox ID="txtDocTitle" runat="server" Width="282px"></asp:TextBox></td>
                                    </tr>
                                    <tr>
                                        <td style="width: 13px">
                                        </td>
                                        <td style="width: 100px">
                                            Content Type</td>
                                        <td>
                                            <asp:DropDownList ID="ddlDocContentType" runat="server" DataSourceID="DocContentTypeDS">
                                            </asp:DropDownList><asp:RequiredFieldValidator ID="vldContentTypeRequired" runat="server"
                                                ControlToValidate="ddlDocContentType" Display="Dynamic" ErrorMessage="Content Type is required."></asp:RequiredFieldValidator><asp:ObjectDataSource
                                                    ID="DocContentTypeDS" runat="server" SelectMethod="GetContentTypeList" TypeName="Document">
                                                </asp:ObjectDataSource>
                                        </td>
                                    </tr>
                                    <tr>
                                        <td style="width: 13px">
                                        </td>
                                        <td style="width: 100px">
                                            Region</td>
                                        <td>
                                            <asp:DropDownList ID="ddlDocRegion" runat="server" DataSourceID="RegionsDS" DataTextField="RegionName"
                                                DataValueField="RegionID">
                                            </asp:DropDownList><asp:RequiredFieldValidator ID="vldRegionRequired" runat="server"
                                                ControlToValidate="ddlDocRegion" Display="Dynamic" ErrorMessage="Region is required."
                                                InitialValue="0"></asp:RequiredFieldValidator><asp:ObjectDataSource ID="RegionsDS"
                                                    runat="server" SelectMethod="GetList" TypeName="Region">
                                                    <SelectParameters>
                                                        <asp:Parameter DefaultValue="0" Name="mode" Type="Object" />
                                                    </SelectParameters>
                                                </asp:ObjectDataSource>
                                        </td>
                                    </tr>
                                    <tr>
                                        <td style="width: 13px; height: 24px">
                                        </td>
                                        <td style="width: 100px; height: 24px">
                                            Upload File</td>
                                        <td style="width: 100px; height: 24px">
                                            <asp:FileUpload ID="fupNewDoc" runat="server" Width="380px" /></td>
                                    </tr>
                                </table>
                            </td>
                        </tr>
                    </table>
                </td>
            </tr>
            <tr>
                <td style="width: 573px; height: 21px" colspan="2">
                </td>
            </tr>
            <tr>
                <td style="width: 573px; height: 21px" colspan="2">
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
 