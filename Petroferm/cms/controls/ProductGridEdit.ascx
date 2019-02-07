<%@ Control Language="VB" AutoEventWireup="false" CodeFile="ProductGridEdit.ascx.vb"
    Inherits="CmsControlsProductGridEdit" %>
<%@ Register TagPrefix="ew" Namespace="eWorld.UI" Assembly="eWorld.UI" %>
<div class="pageModuleEditContainer">
    <table>
        <tr>
            <td colspan="2" style="text-align: left">
                <asp:Label ID="lblFormLabel" runat="server" CssClass="subFormTitle" Width="464px">Add/Edit Product Grid Module</asp:Label></td>
        </tr>
        <tr>
            <td colspan="2" style="text-align: left">
                <asp:Label ID="lblInstructions" runat="server" Width="143px" Visible="False"></asp:Label></td>
        </tr>
        <tr>
            <td style="width: 155px" class="formFieldLabel">
                Title</td>
            <td style="width: 573px">
                <asp:TextBox ID="txtProductGridTitle" runat="server" Width="282px" MaxLength="50"></asp:TextBox>
                <asp:RequiredFieldValidator ID="vldTitleRequired" runat="server" ControlToValidate="txtProductGridTitle"
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
            <td class="formFieldLabel" style="width: 155px; height: 24px; padding-top: 2px;"
                valign="top">
                Blurb</td>
            <td style="width: 573px; height: 24px">
                <asp:TextBox ID="txtProductGridBlurb" runat="server" Width="500px" Height="100px" TextMode="MultiLine"></asp:TextBox></td>
        </tr>
        <tr>
            <td class="formFieldLabel" style="width: 155px; padding-top: 2px; height: 24px" valign="top">
                <asp:Label ID="lblChooseGrid" runat="server" CssClass="formFieldLabel"
                    Width="143px"></asp:Label></td>
            <td style="width: 573px; height: 24px">
                <asp:DropDownList ID="ddlExistingGrid" runat="server" DataSourceID="ProductGridsDS"
                    DataTextField="ProductGridName" DataValueField="ProductGridID" AutoPostBack="True">
                </asp:DropDownList><asp:ObjectDataSource ID="ProductGridsDS" runat="server" SelectMethod="GetList"
                    TypeName="ProductGrid">
                    <SelectParameters>
                        <asp:SessionParameter Name="busUnitId" SessionField="BusUnitID" Type="Int32" />
                    </SelectParameters>
                </asp:ObjectDataSource>
            </td>
        </tr>
        <tr runat="server" id="trGridName">
            <td class="formFieldLabel" style="width: 155px; padding-top: 2px; height: 24px" valign="top">
                Grid Name</td>
            <td style="width: 573px; height: 24px">
                <asp:TextBox ID="txtProductGridName" runat="server" MaxLength="100" Width="282px"></asp:TextBox>
                <asp:RequiredFieldValidator ID="vldGridNameRequired" runat="server" ControlToValidate="txtProductGridName"
                    ErrorMessage="Grid Name is required."></asp:RequiredFieldValidator></td>
        </tr>
        <tr runat="server" id="trAttributeSelection">
            <td class="formFieldLabel" style="width: 155px; padding-top: 2px; height: 24px" valign="top">
                Attribute Selection</td>
            <td style="width: 573px; height: 24px">
                <table id="Table1" runat="server" cellpadding="0" cellspacing="0">
                    <tr>
                        <td style="width: 100px; height: 166px;">
                            <select runat="server" id="lstAttributesUnselected" datasourceid="AttributeUnselectedDS"
                                datatextfield="AttribName" datavaluefield="AttribTypeID" size="10" multiple style="width: 225px" enableviewstate="true">
                            </select>
                        </td>
                        <td style="width: 35px; height: 166px;" align="center">
                            <asp:Button ID="btnAddAttributes" runat="server" SkinID="WizardButton" Text=">" Width="25px"
                                CausesValidation="False" /><br />
                            <br />
                            <asp:Button ID="btnAddAllAttributes" runat="server" SkinID="WizardButton" Text=">>"
                                Width="25px" CausesValidation="False" /><br /><br />
                            <asp:Button ID="btnRemoveAttributes" runat="server" SkinID="WizardButton" Text="<"
                                Width="25px" CausesValidation="False" /><br />
                            <br />
                            <asp:Button ID="btnRemoveAllAttributes" runat="server" SkinID="WizardButton" Text="<<"
                                Width="25px" CausesValidation="False" /><br />
                        </td>
                        <td align="center" style="width: 30px; height: 166px">
                            <select runat="server" id="lstAttributesSelected" size="10" multiple style="width: 225px" enableviewstate="true" name="lstAttributesSelected" datasourceid="AttributeSelectedDS" datatextfield="AttribName" datavaluefield="AttribTypeID">
                            </select>
                        </td>
                        <td style="width: 100px; height: 166px; padding-left: 5px; vertical-align: middle;">
                            <asp:Button ID="btnMoveAttributeUp" runat="server" SkinID="WizardButton" Text="Move Up"
                                Width="80px" CausesValidation="False" /><br />
                            <br />
                            <asp:Button ID="btnMoveAttributeDown" runat="server" SkinID="WizardButton" Text="Move Down"
                                Width="80px" CausesValidation="False" /><br />
                            &nbsp;</td>
                    </tr>
                </table>
            </td>
        </tr>
       <tr runat="server" id="trProductSelection">
            <td class="formFieldLabel" style="width: 155px; height: 24px; padding-top: 2px;"
                valign="top">
                Product Selection</td>
            <td style="width: 573px; height: 24px">
                <table id="tblProductSelection" runat="server" cellpadding="0" cellspacing="0">
                    <tr>
                        <td style="width: 100px; height: 166px;">
                            <select runat="server" id="lstProductsUnselected" datasourceid="ProductUnselectedDS"
                                datatextfield="ProductName" datavaluefield="ProductID" size="10" multiple style="width: 225px" enableviewstate="true">
                            </select>
                        </td>
                        <td style="width: 35px; height: 166px;" align="center">
                            <asp:Button ID="btnAddProducts" runat="server" SkinID="WizardButton" Text=">" Width="25px"
                                CausesValidation="False" /><br />
                            <br />
                            <asp:Button ID="btnAddAllProducts" runat="server" SkinID="WizardButton" Text=">>"
                                Width="25px" CausesValidation="False" /><br /><br />
                            <asp:Button ID="btnRemoveProducts" runat="server" SkinID="WizardButton" Text="<"
                                Width="25px" CausesValidation="False" /><br />
                            <br />
                            <asp:Button ID="btnRemoveAllProducts" runat="server" SkinID="WizardButton" Text="<<"
                                Width="25px" CausesValidation="False" /><br />
                        </td>
                        <td align="center" style="width: 30px; height: 166px">
                            <select runat="server" id="lstProductsSelected" size="10" multiple style="width: 225px" enableviewstate="true" name="lstProductsSelected" datasourceid="ProductSelectedDS" datatextfield="ProductName" datavaluefield="ProductID">
                            </select>
                        </td>
                        <td style="width: 100px; height: 166px; padding-left: 5px; vertical-align: middle;">
                            <asp:Button ID="btnMoveProductUp" runat="server" SkinID="WizardButton" Text="Move Up"
                                Width="80px" CausesValidation="False" /><br />
                            <br />
                            <asp:Button ID="btnMoveProductDown" runat="server" SkinID="WizardButton" Text="Move Down"
                                Width="80px" CausesValidation="False" />
                        </td>
                    </tr>
                </table>
            </td>
        </tr>
        <tr>
            <td class="formFieldLabel" style="width: 155px;">
                Publish Date</td>
            <td style="width: 573px; height: 37px;">
                <ew:CalendarPopup ID="dtePublishDate" runat="server" AllowArbitraryText="False" BackColor="White"
                    BorderColor="Silver" CellPadding="2px" CellSpacing="0px" ControlDisplay="TextBoxImage"
                    Culture="English (United States)" DisableTextboxEntry="False" DisplayOffsetX="20"
                    ImageUrl="~/App_Themes/CMS_Theme/images/calendar-ew.gif" JavascriptOnChangeFunction=""
                    LowerBoundDate="" Nullable="True" PadSingleDigits="True" SelectedDate="" ShowClearDate="True"
                    Text=" " UpperBoundDate="12/31/9999 23:59:59" Width="75px">
                    <TodayDayStyle BackColor="LightGoldenrodYellow" Font-Names="Verdana,Helvetica,Tahoma,Arial"
                        Font-Size="XX-Small" ForeColor="Black" />
                    <WeekendStyle BackColor="LightGray" Font-Names="Verdana,Helvetica,Tahoma,Arial" Font-Size="XX-Small"
                        ForeColor="Black" />
                    <OffMonthStyle BackColor="AntiqueWhite" Font-Names="Verdana,Helvetica,Tahoma,Arial"
                        Font-Size="XX-Small" ForeColor="Gray" />
                    <WeekdayStyle BackColor="White" Font-Names="Verdana,Helvetica,Tahoma,Arial" Font-Size="XX-Small"
                        ForeColor="Black" />
                    <SelectedDateStyle BackColor="Yellow" Font-Names="Verdana,Helvetica,Tahoma,Arial"
                        Font-Size="XX-Small" ForeColor="Black" />
                    <MonthHeaderStyle CssClass="popupCalendarMonthHeader" Font-Names="Verdana,Helvetica,Tahoma,Arial"
                        Font-Size="XX-Small" ForeColor="Black" />
                    <GoToTodayStyle BackColor="White" Font-Names="Verdana,Helvetica,Tahoma,Arial" Font-Size="XX-Small"
                        ForeColor="Black" />
                    <DayHeaderStyle CssClass="popupCalendarDayHeader" Font-Names="Verdana,Helvetica,Tahoma,Arial"
                        Font-Size="XX-Small" ForeColor="Black" />
                    <ClearDateStyle BackColor="White" Font-Names="Verdana,Helvetica,Tahoma,Arial" Font-Size="XX-Small"
                        ForeColor="Black" />
                </ew:CalendarPopup>
                <asp:CompareValidator ID="vldPublishDateValid" runat="server" ControlToValidate="dtePublishDate"
                    Display="Dynamic" ErrorMessage="Valid publish date is required." Operator="DataTypeCheck"
                    Type="Date"></asp:CompareValidator>
            </td>
        </tr>
        <tr>
            <td class="formFieldLabel" style="width: 155px;">
                Expiration Date</td>
            <td style="width: 573px; height: 37px">
                <ew:CalendarPopup ID="dteExpireDate" runat="server" AllowArbitraryText="False" BackColor="White"
                    BorderColor="Silver" CellPadding="2px" CellSpacing="0px" ControlDisplay="TextBoxImage"
                    Culture="English (United States)" DisableTextboxEntry="False" DisplayOffsetX="20"
                    ImageUrl="~/App_Themes/CMS_Theme/images/calendar-ew.gif" JavascriptOnChangeFunction=""
                    LowerBoundDate="" Nullable="True" PadSingleDigits="True" SelectedDate="" ShowClearDate="True"
                    Text=" " UpperBoundDate="12/31/9999 23:59:59" Width="75px">
                    <TodayDayStyle BackColor="LightGoldenrodYellow" Font-Names="Verdana,Helvetica,Tahoma,Arial"
                        Font-Size="XX-Small" ForeColor="Black" />
                    <WeekendStyle BackColor="LightGray" Font-Names="Verdana,Helvetica,Tahoma,Arial" Font-Size="XX-Small"
                        ForeColor="Black" />
                    <OffMonthStyle BackColor="AntiqueWhite" Font-Names="Verdana,Helvetica,Tahoma,Arial"
                        Font-Size="XX-Small" ForeColor="Gray" />
                    <WeekdayStyle BackColor="White" Font-Names="Verdana,Helvetica,Tahoma,Arial" Font-Size="XX-Small"
                        ForeColor="Black" />
                    <SelectedDateStyle BackColor="Yellow" Font-Names="Verdana,Helvetica,Tahoma,Arial"
                        Font-Size="XX-Small" ForeColor="Black" />
                    <MonthHeaderStyle CssClass="popupCalendarMonthHeader" Font-Names="Verdana,Helvetica,Tahoma,Arial"
                        Font-Size="XX-Small" ForeColor="Black" />
                    <GoToTodayStyle BackColor="White" Font-Names="Verdana,Helvetica,Tahoma,Arial" Font-Size="XX-Small"
                        ForeColor="Black" />
                    <DayHeaderStyle CssClass="popupCalendarDayHeader" Font-Names="Verdana,Helvetica,Tahoma,Arial"
                        Font-Size="XX-Small" ForeColor="Black" />
                    <ClearDateStyle BackColor="White" Font-Names="Verdana,Helvetica,Tahoma,Arial" Font-Size="XX-Small"
                        ForeColor="Black" />
                </ew:CalendarPopup>
                <asp:CompareValidator ID="vldExpireDateValid" runat="server" ControlToValidate="dteExpireDate"
                    Display="Dynamic" ErrorMessage="Valid expiration date is required." Operator="DataTypeCheck"
                    Type="Date"></asp:CompareValidator>
            </td>
        </tr>
        <tr>
            <td class="formFieldLabel" style="width: 155px; padding-top: 2px;" valign="top">
                View Grid</td>
            <td style="width: 573px; height: 37px">
                <asp:PlaceHolder ID="phView" runat="server"></asp:PlaceHolder>
            </td>
        </tr>
    </table>
</div>
&nbsp;
<asp:TextBox ID="hidProductGridModuleID" runat="server" Visible="False" Width="5px"></asp:TextBox>
<asp:TextBox ID="hidProductGridID" runat="server" Visible="False" Width="5px"></asp:TextBox>
<asp:ObjectDataSource ID="ProductUnselectedDS" runat="server" SelectMethod="GetProductList"
    TypeName="ProductGrid">
    <SelectParameters>
        <asp:ControlParameter ControlID="hidProductGridID" Name="gridId" PropertyName="Text"
            Type="Int32" />
        <asp:SessionParameter Name="busUnitId" SessionField="BusUnitID" Type="Int32" />
        <asp:Parameter DefaultValue="False" Name="selected" Type="Boolean" />
    </SelectParameters>
</asp:ObjectDataSource><asp:ObjectDataSource ID="ProductSelectedDS" runat="server" SelectMethod="GetProductList"
    TypeName="ProductGrid">
    <SelectParameters>
        <asp:ControlParameter ControlID="hidProductGridID" Name="gridId" PropertyName="Text"
            Type="Int32" />
        <asp:SessionParameter Name="busUnitId" SessionField="BusUnitID" Type="Int32" />
        <asp:Parameter DefaultValue="True" Name="selected" Type="Boolean" />
    </SelectParameters>
</asp:ObjectDataSource>
&nbsp; &nbsp;
<asp:ObjectDataSource ID="AttributeUnselectedDS" runat="server" SelectMethod="GetAttributeList"
    TypeName="ProductGrid">
    <SelectParameters>
        <asp:ControlParameter ControlID="hidProductGridID" Name="gridId" PropertyName="Text"
            Type="Int32" />
        <asp:SessionParameter Name="busUnitId" SessionField="BusUnitID" Type="Int32" />
        <asp:Parameter DefaultValue="False" Name="selected" Type="Boolean" />
    </SelectParameters>
</asp:ObjectDataSource>
<asp:ObjectDataSource ID="AttributeSelectedDS" runat="server" SelectMethod="GetAttributeList"
    TypeName="ProductGrid">
    <SelectParameters>
        <asp:ControlParameter ControlID="hidProductGridID" Name="gridId" PropertyName="Text"
            Type="Int32" />
        <asp:SessionParameter Name="busUnitId" SessionField="BusUnitID" Type="Int32" />
        <asp:Parameter DefaultValue="True" Name="selected" Type="Boolean" />
    </SelectParameters>
</asp:ObjectDataSource>


