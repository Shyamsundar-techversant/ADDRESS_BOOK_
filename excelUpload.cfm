<cffile action="upload" fileField="form.excelUpload" destination="#application.tempPath#"
	nameconflict="makeunique" result="excelUploadedFile"
>
<cfset uploadDir = expandPath('./temp/')>
<cfset excelUploadFile = excelUploadedFile.SERVERFILE>
<cfset excelPath = "#uploadDir##excelUploadFile#">
<cfspreadsheet
	action = "read"
	src = "#excelPath#"
	excludeHeaderRow = "true"
	headerrow = "1"
	query="excelContactAdd"
	sheetname="AddressBook"
>

<cfloop query = "excelContactAdd">
	<cfset local.result = application.dbObj.validateFormAndCreateOrUpdateUser(
											"title" = excelContactAdd.title,
											"firstname" = excelContactAdd.firstname,
											"lastname" = excelContactAdd.lastname,
											"gender" = excelContactAdd.gender,
											"dob" = excelContactAdd.dob,
											"email" = excelContactAdd.email,
											"phone" = excelContactAdd.phone,
											"address" = excelContactAdd.address,
											"street" = excelContactAdd.street,
											"pincode" = excelContactAdd.pincode,
											"hobbies" = excelContactAdd.pincode,
											"public" = excelContactAdd.public
										)
	>	
</cfloop> 