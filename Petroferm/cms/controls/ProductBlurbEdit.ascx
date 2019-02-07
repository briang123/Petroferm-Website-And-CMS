<%@ Control Language="VB" AutoEventWireup="false" CodeFile="ProductBlurbEdit.ascx.vb" Inherits="CmsControlsProductBlurbEdit" %>
<%@ Register TagPrefix="ew" Namespace="eWorld.UI" Assembly="eWorld.UI" %>   
    <div class="pageModuleEditContainer">
        <table>
           <tr>
               <td colspan="2" style="text-align: left">
                   <asp:Label ID="lblFormLabel" runat="server" CssClass="subFormTitle" Width="464px">Add/Edit Product Blurb Module</asp:Label></td>
           </tr>
            <tr>
                <td colspan="2" style="text-align: left">
                        <asp:Label ID="lblInstructions" runat="server" Width="143px" Visible="False"></asp:Label></td>
            </tr>
            <tr>
                <td style="width: 155px" class="formFieldLabel">
                    Title</td>
                <td style="width: 573px">
                    <asp:TextBox ID="txtTitle" runat="server" Width="282px"></asp:TextBox>
                    <asp:RequiredFieldValidator ID="vldTitleRequired" runat="server" ControlToValidate="txtTitle"
                        ErrorMessage="Title is required."></asp:RequiredFieldValidator></td>
            </tr>
            <tr>
                <td class="formFieldLabel" style="width: 100px; height: 22px">
                    Display Title</td>
                <td style="width: 433px; height: 22px">
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
                <td class="formFieldLabel" style="width: 155px; height: 24px">
                    Product Blurb Type</td>
                <td style="width: 573px; height: 24px">
                    <asp:DropDownList ID="ddlProductBlurbType" runat="server" AutoPostBack="True">
                        <asp:ListItem>-- Select Product Blurb Type --</asp:ListItem>
                        <asp:ListItem Value="INDIVIDUAL">Individual</asp:ListItem>
                        <asp:ListItem Value="MULTIPLE">Multiple</asp:ListItem>
                    </asp:DropDownList></td>
            </tr>
            <tr runat="server" id="trProductBlurb">
                <td class="formFieldLabel" style="width: 155px; height: 24px; padding-top: 2px;" valign="top">
                    Multiple Product Blurb</td>
                <td style="width: 573px; height: 24px">
                    <asp:TextBox ID="txtProductBlurb" runat="server" Width="500px" Height="100px" TextMode="MultiLine"></asp:TextBox></td>
            </tr>
            <tr runat="server" id="trProductSelection">
                <td class="formFieldLabel" style="width: 155px; height: 24px; padding-top: 2px;" valign="top">
                    Product Selection</td>
                <td style="width: 573px; height: 24px">
                    <table id="tblMultipleProductSelection" runat="server" cellpadding="0" cellspacing="0">
                        <tr>
                            <td style="width: 100px; height: 166px;">
                                <asp:ListBox ID="lstProductsUnselected" runat="server" DataSourceID="MultiProductUnselectedDS" DataTextField="ProductName" DataValueField="ProductID" Rows="10" SelectionMode="Multiple" Width="225px"></asp:ListBox></td>
                            <td style="width: 30px; height: 166px;" align="center">
                                <asp:Button ID="btnAddProducts" runat="server" SkinID="WizardButton" Text=">" Width="25px" CausesValidation="False" /><br />
                                <br />
                                <asp:Button ID="btnRemoveProducts" runat="server" SkinID="WizardButton" Text="<" Width="25px" CausesValidation="False" /></td>
                            <td style="width: 100px; height: 166px;">
                                <asp:ListBox ID="lstProductsSelected" runat="server" DataSourceID="MultiProductSelectedDS" DataTextField="ProductName" DataValueField="ProductID" Rows="10" SelectionMode="Multiple" Width="225px"></asp:ListBox></td>
                        </tr>
                    </table>
                    <asp:DropDownList ID="ddlProductSelected" runat="server" DataSourceID="SingleProductAllDS" DataTextField="ProductName" DataValueField="ProductID">
                    </asp:DropDownList></td>
            </tr>
           <tr>
               <td class="formFieldLabel" style="width: 155px;">
                   Publish Date</td>
               <td style="width: 573px; height: 37px;">
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
               <td class="formFieldLabel" style="width: 155px;">
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
&nbsp;
<asp:TextBox ID="hidProductBlurbModuleID" runat="server" Visible="False" Width="5px"></asp:TextBox>
<asp:ObjectDataSource ID="MultiProductUnselectedDS" runat="server" SelectMethod="GetProductList"
    TypeName="ProductBlurbModule">
    <SelectParameters>
        <asp:ControlParameter ControlID="hidProductBlurbModuleID" Name="modId" PropertyName="Text"
            Type="Int32" />
        <asp:SessionParameter Name="busUnitId" SessionField="BusUnitID" Type="Int32" />
        <asp:Parameter DefaultValue="False" Name="selected" Type="Boolean" />
    </SelectParameters>
</asp:ObjectDataSource>
<asp:ObjectDataSource ID="MultiProductSelectedDS" runat="server" SelectMethod="GetProductList"
    TypeName="ProductBlurbModule">
    <SelectParameters>
        <asp:ControlParameter ControlID="hidProductBlurbModuleID" Name="modId" PropertyName="Text"
            Type="Int32" />
        <asp:SessionParameter Name="busUnitId" SessionField="BusUnitID" Type="Int32" />
        <asp:Parameter DefaultValue="True" Name="selected" Type="Boolean" />
    </SelectParameters>
</asp:ObjectDataSource>
<asp:ObjectDataSource ID="SingleProductAllDS" runat="server" SelectMethod="GetList"
    TypeName="Product">
    <SelectParameters>
        <asp:SessionParameter Name="busUnitId" SessionField="BusUnitID" Type="Int32" />
    </SelectParameters>
</asp:ObjectDataSource>
 