<%@ Control Language="VB" AutoEventWireup="false" CodeFile="ImageEdit.ascx.vb" Inherits="CmsControlsImageEdit" %>
<%@ Register TagPrefix="ew" Namespace="eWorld.UI" Assembly="eWorld.UI" %>   
   
    <div class="pageModuleEditContainer">
       <span class="formTitle"></span> &nbsp;<table>
           <tr>
               <td colspan="2" style="text-align: left">
                   <asp:Label ID="lblFormLabel" runat="server" CssClass="subFormTitle" Width="464px">Add/Edit Image Module</asp:Label></td>
           </tr>
            <tr>
                <td colspan="2" style="text-align: left">
                    Image dimension rules here</td>
            </tr>
            <tr>
                <td style="width: 83px; height: 26px;">
                    <strong class="formFieldLabel">
                    Image Type</strong></td>
                <td style="width: 503px; height: 26px;">
                    &nbsp;<asp:Label ID="lblImageType" runat="server" Text="Image Type" Width="465px"></asp:Label>
                    <asp:TextBox ID="hidImageID" runat="server" Visible="False" Width="16px"></asp:TextBox></td>
            </tr>
           <tr runat="server" id="trImageOrder">
               <td class="formFieldLabel">
                   Image Order</td>
               <td style="width: 503px; height: 26px">
                   &nbsp;<asp:TextBox ID="txtModuleOrder" runat="server" MaxLength="2" Width="41px"></asp:TextBox>
                   <asp:RequiredFieldValidator
                       ID="vldOrderRequired" runat="server" ControlToValidate="txtModuleOrder" Display="Dynamic"
                       ErrorMessage="Image Order is required."></asp:RequiredFieldValidator><asp:CompareValidator
                           ID="vldOrderValid" runat="server" ControlToValidate="txtModuleOrder" Display="Dynamic"
                           ErrorMessage="Image Order must be numeric." Operator="DataTypeCheck" Type="Integer"></asp:CompareValidator></td>
           </tr>
            
            <tr valign="top">
                <td style="width: 83px">
                    <strong>
                        <asp:Label ID="lblImageUpload" runat="server" Text="Image" Width="85px"></asp:Label></strong></td>
                <td style="width: 503px" valign="top">
                    <table>
                        <tr runat="server" id="trCurrentImage">
                            <td style="width: 100px" valign="top">
                                <asp:RadioButton ID="rdoUseCurrent" runat="server" Text="Use Current" GroupName="GetImage" Width="117px" /></td>
                            <td style="width: 100px">
                                <asp:Image ID="imgCurrent" runat="server" /></td>
                        </tr>
                        <tr>
                            <td valign="top">
                                <asp:RadioButton ID="rdoExisting" runat="server" Text="Select Existing" GroupName="GetImage"
                                    Width="117px" /></td>
                            <td>
                                <asp:DropDownList ID="ddlExistingImage" runat="server" DataSourceID="ImageListDS"
                                    DataTextField="FmtImagePath" DataValueField="ImageID">
                                </asp:DropDownList></td>
                        </tr>
                        <tr>
                            <td style="width: 122px">
                                <asp:RadioButton ID="rdoUpload" runat="server" Text="Upload New" GroupName="GetImage" /></td>
                            <td style="width: 129px">
                    <asp:FileUpload ID="fupImage" runat="server" Width="286px" /></td></tr></table>
                    </td>
            </tr>     
           <tr valign="top" runat="server" id="trPetroHomePageMgmtRow1of4">
               <td colspan="2" style="padding-top: 5px">
                   The following is for the navigation of this image module: what header image displays
                   when a user hovers over the image, what displays in the Welcome to blue area, and
                   the navigation links.</td>
           </tr>
           <tr valign="top" runat="server" id="trPetroHomePageMgmtRow2of4">
               <td class="formFieldLabel" style="padding-top:5px">
                   Welcome Hover Image</td>
               <td style="width: 503px" valign="top">
                   <table>
                       <tr runat="server" id="trUseCurrentWelcomeImage">
                           <td style="width: 100px" valign="top">
                               <asp:RadioButton ID="rdoUseCurrentWelcomeImage" runat="server" Text="Use Current" GroupName="GetWelcomeImage" Width="117px" /></td>
                           <td style="width: 100px">
                               <asp:Image ID="imgCurrentWelcome" runat="server" /></td>
                       </tr>
                       <tr>
                           <td valign="top">
                               <asp:RadioButton ID="rdoUseExistingWelcomeImage" runat="server" Text="Select Existing" GroupName="GetWelcomeImage"
                                    Width="117px" /></td>
                           <td>
                               <asp:DropDownList ID="ddlExistingWelcomeImage" runat="server" DataSourceID="ImageListDS"
                                    DataTextField="FmtImagePath" DataValueField="ImageID">
                               </asp:DropDownList></td>
                       </tr>
                       <tr>
                           <td style="width: 122px">
                               <asp:RadioButton ID="rdoUploadNewWelcomeImage" runat="server" Text="Upload New" GroupName="GetWelcomeImage" /></td>
                           <td style="width: 129px">
                               <asp:FileUpload ID="fupWelcomeImage" runat="server" Width="286px" /></td>
                       </tr>
                   </table>
               </td>
           </tr>
           <tr valign="middle" runat="server" id="trPetroHomePageMgmtRow3of4">
               <td class="formFieldLabel" style="height: 26px">
                   Welcome Title</td>
               <td style="width: 503px; height: 26px" valign="top">
                   <asp:TextBox ID="txtWelcomeTitle" runat="server" MaxLength="50" Width="378px"></asp:TextBox></td>
           </tr>
           <tr valign="top" runat="server" id="trPetroHomePageMgmtRow4of4">
               <td class="formFieldLabel" style="padding-top:10px">
                   Navigation Link</td>
               <td style="width: 503px; height: 26px" valign="top">
                   <table width="100%">
                       <tr runat="server" id="Tr2" valign="top">
                           <td style="width: 105px; padding-top: 4px;" valign="top">
                               <asp:RadioButton ID="rdoSingleLink" runat="server" Text="Single Link" GroupName="WelcomeLinkType" Width="117px" /></td>
                           <td style="width: 400px;" colspan="2">
                           </td>
                       </tr>
                       <tr runat="server" valign="top">
                           <td colspan="3" style="padding-top: 4px; height: 49px; text-indent: 10px;" valign="top">
                               <table style="padding-top:5px;">
                               <tr>
                                   <td class="formFieldLabel" style="width: 20px" valign="middle">
                                   </td>
                                   <td valign="middle" style="width: 58px" class="formFieldLabel">
                                       Page</td>
                                   <td>
                                       <asp:DropDownList ID="ddlSinglePage" runat="server" Width="375px">
                                       </asp:DropDownList></td>
                               </tr>
                           </table>
                           </td>
                       </tr>
                       <tr>
                           <td valign="top" style="height: 22px; width: 105px; padding-top: 1px;">
                               <asp:RadioButton ID="rdoMultipleLinks" runat="server" Text="Multiple Links" GroupName="WelcomeLinkType"
                                    Width="117px" /></td>
                           <td class="formFieldLabel" colspan="2" style="height: 22px">
                              
                           </td>
                       </tr>
                       <tr>
                           <td colspan="3" style="padding-top: 1px; height: 22px; text-indent: 10px;" valign="top">
                           
                            <table>
                                   <tr runat="server" id="Tr4">
                                       <td colspan="1" style="width: 20px; height: 21px" valign="top">
                                       </td>
                                       <td style="height: 21px;" valign="top" colspan="2" class="formFieldLabel">
                                           Link 1</td>
                                   </tr>
                                   <tr valign="middle">
                                       <td style="width: 20px" valign="middle">
                                       </td>
                                       <td valign="middle" style="width: 73px" class="formFieldLabel">
                                           Page</td>
                                       <td>
                                           <asp:DropDownList ID="ddlMultPage1" runat="server" Width="375px">
                                           </asp:DropDownList></td>
                                   </tr>
                                   <tr valign="middle">
                                       <td style="width: 20px">
                                       </td>
                                       <td style="width: 73px" class="formFieldLabel">
                                           Link Text</td>
                                       <td style="width: 129px">
                                           <asp:TextBox ID="txtMultLinkText1" runat="server" MaxLength="50" Width="325px"></asp:TextBox></td>
                                   </tr>
                               </table>
                               <br /><table>
                                   <tr runat="server" id="Tr5">
                                       <td colspan="1" style="width: 20px; height: 21px" valign="top">
                                       </td>
                                       <td style="height: 21px;" valign="top" colspan="2" class="formFieldLabel">
                                           Link 2</td>
                                   </tr>
                                   <tr valign="middle">
                                       <td style="width: 20px" valign="middle">
                                       </td>
                                       <td valign="middle" style="width: 73px" class="formFieldLabel">
                                           Page</td>
                                       <td>
                                           <asp:DropDownList ID="ddlMultPage2" runat="server" Width="375px">
                                           </asp:DropDownList></td>
                                   </tr>
                                   <tr valign="middle">
                                       <td style="width: 20px">
                                       </td>
                                       <td style="width: 73px" class="formFieldLabel">
                                           Link Text</td>
                                       <td style="width: 129px">
                                           <asp:TextBox ID="txtMultLinkText2" runat="server" MaxLength="50" Width="325px"></asp:TextBox></td>
                                   </tr>
                               </table>
                               <br /><table>
                                   <tr runat="server" id="Tr3">
                                       <td colspan="1" style="width: 20px; height: 21px" valign="top">
                                       </td>
                                       <td style="height: 21px;" valign="top" colspan="2" class="formFieldLabel">
                                           Link 3</td>
                                   </tr>
                                   <tr valign="middle">
                                       <td style="width: 20px" valign="middle">
                                       </td>
                                       <td valign="middle" style="width: 73px" class="formFieldLabel">
                                           Page</td>
                                       <td>
                                           <asp:DropDownList ID="ddlMultPage3" runat="server" Width="375px">
                                           </asp:DropDownList></td>
                                   </tr>
                                   <tr valign="middle">
                                       <td style="width: 20px">
                                       </td>
                                       <td style="width: 73px" class="formFieldLabel">
                                           Link Text</td>
                                       <td style="width: 129px">
                                           <asp:TextBox ID="txtMultLinkText3" runat="server" MaxLength="50" Width="325px"></asp:TextBox></td>
                                   </tr>
                               </table>
                               <br />
                               <table>
                                   <tr runat="server" id="Tr6">
                                       <td class="formFieldLabel" colspan="1" style="width: 20px; height: 21px" valign="top">
                                       </td>
                                       <td style="height: 21px;" valign="top" colspan="2" class="formFieldLabel">
                                           Link 4</td>
                                   </tr>
                                   <tr valign="middle">
                                       <td class="formFieldLabel" style="width: 20px" valign="middle">
                                       </td>
                                       <td valign="middle" style="width: 73px" class="formFieldLabel">
                                           Page</td>
                                       <td>
                                           <asp:DropDownList ID="ddlMultPage4" runat="server" Width="375px">
                                           </asp:DropDownList></td>
                                   </tr>
                                   <tr valign="middle">
                                       <td class="formFieldLabel" style="width: 20px">
                                       </td>
                                       <td style="width: 73px" class="formFieldLabel">
                                           Link Text</td>
                                       <td style="width: 129px">
                                           <asp:TextBox ID="txtMultLinkText4" runat="server" MaxLength="50" Width="325px"></asp:TextBox></td>
                                   </tr>
                               </table>
                               <br />
                               <table>
                                   <tr runat="server" id="Tr7">
                                       <td class="formFieldLabel" colspan="1" style="width: 20px; height: 21px" valign="top">
                                       </td>
                                       <td style="height: 21px;" valign="top" colspan="2" class="formFieldLabel">
                                           Link 5</td>
                                   </tr>
                                   <tr valign="middle">
                                       <td class="formFieldLabel" style="width: 20px" valign="middle">
                                       </td>
                                       <td valign="middle" style="width: 73px" class="formFieldLabel">
                                           Page</td>
                                       <td>
                                           <asp:DropDownList ID="ddlMultPage5" runat="server" Width="375px">
                                           </asp:DropDownList></td>
                                   </tr>
                                   <tr valign="middle">
                                       <td class="formFieldLabel" style="width: 20px">
                                       </td>
                                       <td style="width: 73px" class="formFieldLabel">
                                           Link Text</td>
                                       <td style="width: 129px">
                                           <asp:TextBox ID="txtMultLinkText5" runat="server" MaxLength="50" Width="325px"></asp:TextBox></td>
                                   </tr>
                               </table>
                               <br />
                               <table>
                                   <tr runat="server" id="Tr8">
                                       <td class="formFieldLabel" colspan="1" style="width: 20px; height: 21px" valign="top">
                                       </td>
                                       <td style="height: 21px;" valign="top" colspan="2" class="formFieldLabel">
                                           Link 6</td>
                                   </tr>
                                   <tr valign="middle">
                                       <td class="formFieldLabel" style="width: 20px" valign="middle">
                                       </td>
                                       <td valign="middle" style="width: 73px" class="formFieldLabel">
                                           Page</td>
                                       <td>
                                           <asp:DropDownList ID="ddlMultPage6" runat="server" Width="375px">
                                           </asp:DropDownList></td>
                                   </tr>
                                   <tr valign="middle">
                                       <td class="formFieldLabel" style="width: 20px">
                                       </td>
                                       <td style="width: 73px" class="formFieldLabel">
                                           Link Text</td>
                                       <td style="width: 129px">
                                           <asp:TextBox ID="txtMultLinkText6" runat="server" MaxLength="50" Width="325px"></asp:TextBox></td>
                                   </tr>
                               </table>
                           
                           
                           </td>
                       </tr>
                   </table>
               </td>
           </tr>
           <tr runat="server" id="trPublishDate">
               <td class="formFieldLabel" style="width: 155px; height: 37px;">
                   Publish Date</td>
               <td style="width: 573px; height: 37px">
                   <ew:calendarpopup id="dtePublishDate" runat="server" allowarbitrarytext="False" backcolor="White"
                       bordercolor="Silver" cellpadding="2px" cellspacing="0px" controldisplay="TextBoxImage"
                       culture="English (United States)" disabletextboxentry="False" displayoffsetx="20"
                       imageurl="~/App_Themes/CMS_Theme/images/calendar-ew.gif" javascriptonchangefunction=""
                       lowerbounddate="" nullable="True" padsingledigits="True" selecteddate="" showcleardate="True"
                       text=" " upperbounddate="12/31/9999 23:59:59" width="75px"><TODAYDAYSTYLE ForeColor="Black" Font-Size="XX-Small" Font-Names="Verdana,Helvetica,Tahoma,Arial" BackColor="LightGoldenrodYellow" /><WEEKENDSTYLE ForeColor="Black" Font-Size="XX-Small" Font-Names="Verdana,Helvetica,Tahoma,Arial" BackColor="LightGray" /><OFFMONTHSTYLE ForeColor="Gray" Font-Size="XX-Small" Font-Names="Verdana,Helvetica,Tahoma,Arial" BackColor="AntiqueWhite" /><WEEKDAYSTYLE ForeColor="Black" Font-Size="XX-Small" Font-Names="Verdana,Helvetica,Tahoma,Arial" BackColor="White" /><SELECTEDDATESTYLE ForeColor="Black" Font-Size="XX-Small" Font-Names="Verdana,Helvetica,Tahoma,Arial" BackColor="Yellow" /><MONTHHEADERSTYLE ForeColor="Black" Font-Size="XX-Small" Font-Names="Verdana,Helvetica,Tahoma,Arial" CssClass="popupCalendarMonthHeader" /><GOTOTODAYSTYLE ForeColor="Black" Font-Size="XX-Small" Font-Names="Verdana,Helvetica,Tahoma,Arial" BackColor="White" /><DAYHEADERSTYLE ForeColor="Black" Font-Size="XX-Small" Font-Names="Verdana,Helvetica,Tahoma,Arial" CssClass="popupCalendarDayHeader" /><CLEARDATESTYLE ForeColor="Black" Font-Size="XX-Small" Font-Names="Verdana,Helvetica,Tahoma,Arial" BackColor="White" /></ew:calendarpopup>
                   <asp:CompareValidator ID="vldPublishDateValid" runat="server" ControlToValidate="dtePublishDate"
                       Display="Dynamic" ErrorMessage="Valid publish date is required." Operator="DataTypeCheck"
                       Type="Date"></asp:CompareValidator>
               </td>
           </tr>
           <tr runat="server" id="trExpireDate">
               <td class="formFieldLabel" style="width: 155px">
                   Expiration Date</td>
               <td style="width: 573px; height: 37px">
                   <ew:calendarpopup id="dteExpireDate" runat="server" allowarbitrarytext="False" backcolor="White"
                       bordercolor="Silver" cellpadding="2px" cellspacing="0px" controldisplay="TextBoxImage"
                       culture="English (United States)" disabletextboxentry="False" displayoffsetx="20"
                       imageurl="~/App_Themes/CMS_Theme/images/calendar-ew.gif" javascriptonchangefunction=""
                       lowerbounddate="" nullable="True" padsingledigits="True" selecteddate="" showcleardate="True"
                       text=" " upperbounddate="12/31/9999 23:59:59" width="75px"><TODAYDAYSTYLE ForeColor="Black" Font-Size="XX-Small" Font-Names="Verdana,Helvetica,Tahoma,Arial" BackColor="LightGoldenrodYellow" /><WEEKENDSTYLE ForeColor="Black" Font-Size="XX-Small" Font-Names="Verdana,Helvetica,Tahoma,Arial" BackColor="LightGray" /><OFFMONTHSTYLE ForeColor="Gray" Font-Size="XX-Small" Font-Names="Verdana,Helvetica,Tahoma,Arial" BackColor="AntiqueWhite" /><WEEKDAYSTYLE ForeColor="Black" Font-Size="XX-Small" Font-Names="Verdana,Helvetica,Tahoma,Arial" BackColor="White" /><SELECTEDDATESTYLE ForeColor="Black" Font-Size="XX-Small" Font-Names="Verdana,Helvetica,Tahoma,Arial" BackColor="Yellow" /><MONTHHEADERSTYLE ForeColor="Black" Font-Size="XX-Small" Font-Names="Verdana,Helvetica,Tahoma,Arial" CssClass="popupCalendarMonthHeader" /><GOTOTODAYSTYLE ForeColor="Black" Font-Size="XX-Small" Font-Names="Verdana,Helvetica,Tahoma,Arial" BackColor="White" /><DAYHEADERSTYLE ForeColor="Black" Font-Size="XX-Small" Font-Names="Verdana,Helvetica,Tahoma,Arial" CssClass="popupCalendarDayHeader" /><CLEARDATESTYLE ForeColor="Black" Font-Size="XX-Small" Font-Names="Verdana,Helvetica,Tahoma,Arial" BackColor="White" /></ew:calendarpopup>
                   <asp:CompareValidator ID="vldExpireDateValid" runat="server" ControlToValidate="dteExpireDate"
                       Display="Dynamic" ErrorMessage="Valid expiration date is required." Operator="DataTypeCheck"
                       Type="Date"></asp:CompareValidator>
               </td>
           </tr>
            
                   
        </table>

    </div>
<asp:ObjectDataSource ID="ImageListDS" runat="server" SelectMethod="GetList" TypeName="ImageFile">
</asp:ObjectDataSource>
<asp:ObjectDataSource ID="InternalLinkPageDS" runat="server" SelectMethod="GetListForInternalLink"
    TypeName="WebPage"></asp:ObjectDataSource>
<br />
    
<script type="text/javascript" language="javascript">

// just hide the existing images for now, until they click the use existing radio button

//displayExistingImages('hide');

function displayExistingImages(showOrHide)
{
    document.getElementById("ctl00_phMain_wzBusinessUnit_ucImageEdit_lstExistingImages").style;
    if (showOrHide == 'show')
        document.getElementById("ctl00_phMain_wzBusinessUnit_ucImageEdit_lstExistingImages").style = "overflow:auto;height:100px;width:200px;line-height:18px;";
    else
        document.getElementById("ctl00_phMain_wzBusinessUnit_ucImageEdit_lstExistingImages").style = "display:none;overflow:auto;height:100px;width:200px;line-height:18px;";

}

function fillForm(imgPath, altText, height, width)
{
     document.getElementById("ctl00_phMain_wzBusinessUnit_ucImageEdit_txtAltText").value = altText;
     document.getElementById("ctl00_phMain_wzBusinessUnit_ucImageEdit_txtHeight").value = height;
     document.getElementById("ctl00_phMain_wzBusinessUnit_ucImageEdit_txtWidth").value = width;
}

</script>