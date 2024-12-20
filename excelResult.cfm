<cfset variables.resultFile = "excelResult.xlsx">
<cfset spreadsheetObj = SpreadsheetNew("AddressBook",true)>
<cfset myFormat = structNew()>
<cfset myFormat.bold = "true">
<cfset myFormat.alignV = "center">
<cfset data = {color = "white",fgcolor = "grey_50_percent",alignV="center"}>
<cfset dataHead = {color = "white",fgcolor = "grey_50_percent",bold="true",alignV = "center"}>
<cfset currentRow = 1>
<cfset spreadsheetSetCellValue(spreadsheetObj,"TITLE",1,1)>
<cfset spreadsheetSetCellValue(spreadsheetObj, "FIRSTNAME", 1, 2)>
<cfset spreadsheetSetCellValue(spreadsheetObj, "LASTNAME", 1, 3)>
<cfset spreadsheetSetCellValue(spreadsheetObj, "GENDER", 1, 4)>
<cfset spreadsheetSetCellValue(spreadsheetObj, "DOB", 1, 5)>
<cfset spreadsheetSetCellValue(spreadsheetObj, "EMAIL", 1, 6)>
<cfset spreadsheetSetCellValue(spreadsheetObj, "PHONE", 1, 7)>
<cfset spreadsheetSetCellValue(spreadsheetObj, "STREET",1,8)>
<cfset spreadsheetSetCellValue(spreadsheetObj, "ADDRESS",1,9)>
<cfset spreadsheetSetCellValue(spreadsheetObj, "PINCODE",1,10)>
<cfset spreadsheetSetCellValue(spreadsheetObj,"HOBBIES",1,11)>
<cfset spreadsheetSetCellValue(spreadsheetObj,"PUBLIC",1,12)>
<cfset spreadsheetSetCellValue(spreadsheetObj,"RESULT",1,13)>	
<cfset SpreadsheetFormatRow (spreadsheetObj, dataHead, 1)>
<cfoutput>
	<cfif arrayLen(errorArray) GT 0>
		<cfloop array="#errorArray#" index = "contact">
			<cfset spreadsheetSetCellValue(spreadsheetObj, "#contact.titleName#", currentRow+1, 1)>
			<cfset spreadsheetSetCellValue(spreadsheetObj, "#contact.firstname#", currentRow+1, 2)>
			<cfset spreadsheetSetCellValue(spreadsheetObj, "#contact.lastname#",currentRow+1, 3)>
			<cfset spreadsheetSetCellValue(spreadsheetObj, "#contact.genderName#", currentRow+1, 4)>
			<cfset spreadsheetSetCellValue(spreadsheetObj, "#contact.dob#",currentRow+1, 5)>
			<cfset spreadsheetSetCellValue(spreadsheetObj, "#contact.email#", currentRow+1, 6)>
			<cfset spreadsheetSetCellValue(spreadsheetObj, "#contact.phone#", currentRow+1, 7)>
			<cfset spreadsheetSetCellValue(spreadsheetObj, "#contact.address#",currentRow+1, 8)>
			<cfset spreadsheetSetCellValue(spreadsheetObj, "#contact.street#", currentRow+1, 9)>
			<cfset spreadsheetSetCellValue(spreadsheetObj, "#contact.pincode#",currentRow+1, 10)>
			<cfset spreadsheetSetCellValue(spreadsheetObj,"#contact.hobbieName#",currentRow+1,11)>
			<cfset spreadsheetSetCellValue(spreadsheetObj,"#contact.public#",currentRow+1,12)>
			<cfset spreadsheetSetCellValue(spreadsheetObj,"#contact.remarks#",currentRow+1,13)>
			<cfset SpreadsheetSetRowHeight(spreadsheetObj,currentRow+1,20)>
			<cfset currentRow = currentRow + 1>
		</cfloop>
	</cfif>
	<cfif arrayLen(successArray) GT 0 >
		<cfloop array="#successArray#" index = "contact">
			<cfset spreadsheetSetCellValue(spreadsheetObj, "#contact.titleName#", currentRow+1, 1)>
			<cfset spreadsheetSetCellValue(spreadsheetObj, "#contact.firstname#", currentRow+1, 2)>
			<cfset spreadsheetSetCellValue(spreadsheetObj, "#contact.lastname#",currentRow+1, 3)>
			<cfset spreadsheetSetCellValue(spreadsheetObj, "#contact.genderName#", currentRow+1, 4)>
			<cfset spreadsheetSetCellValue(spreadsheetObj, "#contact.dob#",currentRow+1, 5)>
			<cfset spreadsheetSetCellValue(spreadsheetObj, "#contact.email#", currentRow+1, 6)>
			<cfset spreadsheetSetCellValue(spreadsheetObj, "#contact.phone#", currentRow+1, 7)>
			<cfset spreadsheetSetCellValue(spreadsheetObj, "#contact.address#",currentRow+1, 8)>
			<cfset spreadsheetSetCellValue(spreadsheetObj, "#contact.street#", currentRow+1, 9)>
			<cfset spreadsheetSetCellValue(spreadsheetObj, "#contact.pincode#",currentRow+1, 10)>
			<cfset spreadsheetSetCellValue(spreadsheetObj,"#contact.hobbieName#",currentRow+1,11)>
			<cfset spreadsheetSetCellValue(spreadsheetObj,"#contact.public#",currentRow+1,12)>
			<cfset spreadsheetSetCellValue(spreadsheetObj,"#contact.remarks#",currentRow+1,13)>
			<cfset SpreadsheetSetRowHeight(spreadsheetObj,currentRow+1,20)>
			<cfset currentRow = currentRow + 1>
		</cfloop>
	</cfif>
</cfoutput>

<cfset SpreadsheetSetColumnWidth(spreadsheetObj,1,25)>
<cfset SpreadSheetSetColumnWidth(spreadsheetobj,2,25)>
<cfset SpreadSheetSetColumnWidth(spreadsheetobj,3,25)>
<cfset SpreadSheetSetColumnWidth(spreadsheetobj,4,25)>
<cfset SpreadSheetSetColumnWidth(spreadsheetobj,5,20)>
<cfset SpreadSheetSetColumnWidth(spreadsheetobj,6,25)>
<cfset SpreadSheetSetColumnWidth(spreadsheetobj,7,25)>
<cfset SpreadSheetSetColumnWidth(spreadsheetobj,8,35)>
<cfset SpreadSheetSetColumnWidth(spreadsheetobj,9,25)>
<cfset SpreadSheetSetColumnWidth(spreadsheetobj,10,20)>
<cfset SpreadSheetSetColumnWidth(spreadsheetobj,11,50)>
<cfset SpreadSheetSetColumnWidth(spreadsheetobj,12,20)>
<cfset SpreadSheetSetColumnWidth(spreadsheetobj,13,50)>
<cfset SpreadSheetSetColumnWidth(spreadsheetobj,14,50)>

<cftry>
	<cfset binary = SpreadsheetReadBinary(spreadsheetObj)>
	<cfset downloadFile = expandPath('./download/excelResult.xlsx')>
	<cffile action="write" file="#downloadFile#" output="#binary#" addnewline="no">

<cfcatch>
	<cfdump var="#cfcatch#">
</cfcatch>
</cftry>














