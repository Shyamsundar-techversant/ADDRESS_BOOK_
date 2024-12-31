<cfset variables.fileName = "contactData.xlsx">
<cfset spreadsheetObj = SpreadsheetNew("AddressBook", true)>
<cfset dataHead = {color = "white",fgcolor = "grey_50_percent",bold = "true",alignV = "center"}>
<cfset spreadsheetSetCellValue(spreadsheetObj, "TITLE", 1, 1)>
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
<cfset SpreadsheetFormatRow (spreadsheetObj, dataHead, 1)>
<cfif structKeyExists(url,"excelData")>	
	<cfset contactList = application.dbObj.getData()>
	<cfoutput query = "contactList">
		<cfset spreadsheetSetCellValue(spreadsheetObj, contactList.TITLES,contactList.currentRow+1, 1)>
		<cfset spreadsheetSetCellValue(spreadsheetObj, contactList.FIRSTNAME,contactList.currentRow+1, 2)>
		<cfset spreadsheetSetCellValue(spreadsheetObj, contactList.LASTNAME,contactList.currentRow+1, 3)>
		<cfset spreadsheetSetCellValue(spreadsheetObj, contactList.GENDER_VALUES, contactList.currentRow+1, 4)>
		<cfset spreadsheetSetCellValue(spreadsheetObj, contactList.DOB,contactList.currentRow+1, 5)>
		<cfset spreadsheetSetCellValue(spreadsheetObj, contactList.EMAIL, contactList.currentRow+1, 6)>
		<cfset spreadsheetSetCellValue(spreadsheetObj, contactList.PHONE,contactList.currentRow+1, 7)>
		<cfset spreadsheetSetCellValue(spreadsheetObj, contactList.STREET,contactList.currentRow+1, 8)>
		<cfset spreadsheetSetCellValue(spreadsheetObj, contactList.ADDRESS, contactList.currentRow+1, 9)>
		<cfset spreadsheetSetCellValue(spreadsheetObj, contactList.PINCODE,contactList.currentRow+1, 10)>
		<cfset spreadsheetSetCellValue(spreadsheetObj,contactList.HOBBY_NAME,contactList.currentRow+1,11)>
		<cfset spreadsheetSetCellValue(spreadsheetObj,contactList.PUBLIC,contactList.currentRow+1,12)>
		<cfset SpreadsheetSetRowHeight(spreadsheetObj,contactList.currentRow+1,20)>
	</cfoutput>
</cfif>
<cfset SpreadSheetSetColumnWidth(spreadsheetobj,1,25)>
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
<cfset SpreadSheetSetColumnWidth(spreadsheetobj,13,20)>
<cfset SpreadSheetSetColumnWidth(spreadsheetobj,14,60)>

<!--- Save the spreadsheet to a temporary file --->
<cfset tempFilePath = application.tempPath &"contactData.xlsx">
<cfset SpreadsheetWrite(spreadsheetobj,tempFilePath,"",true,true)>

<!--- Read the file as binary --->
<cffile action = "readBinary" file = "#tempFilePath#" variable = "binary" >

		
<!--- <cfset binary = SpreadsheetReadBinary(spreadsheetObj)> --->

<cfheader name = "Content-Disposition" value = "attachment; filename = #variables.fileName#">
<!--- Serve the file and delete it after download --->
<cfcontent type = "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet" variable = "#binary#" >
