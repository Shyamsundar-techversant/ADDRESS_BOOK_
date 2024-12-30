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
<cfset errorArray = []>
<cfset successArray = []>
<cfloop query = "excelContactAdd">
	<cfset result = application.dbObj.validateFormAndCreateOrUpdateUser(
											titleName = excelContactAdd.title,
											firstname = excelContactAdd.firstname,
											lastname = excelContactAdd.lastname,
											genderName = excelContactAdd.gender,
											dob = excelContactAdd.dob,
											email = excelContactAdd.email,
											phone = excelContactAdd.phone,
											address = excelContactAdd.address,
											street = excelContactAdd.street,
											pincode = excelContactAdd.pincode,
											hobbieName = excelContactAdd.hobbies,
											public = excelContactAdd.public,
											isExcel = 1
										)
	>	

	<cfset excelRow = {
				'titleName' = excelContactAdd.title,
				'firstname' = excelContactAdd.firstname,
				'lastname' = excelContactAdd.lastname,
				'genderName' = excelContactAdd.gender,
				'dob' = excelContactAdd.dob,
				'email' = excelContactAdd.email,
				'phone' = excelContactAdd.phone,
				'address' = excelContactAdd.address,
				'street' = excelContactAdd.street,
				'pincode' = excelContactAdd.pincode,
				'hobbieName' = excelContactAdd.hobbies,
				'public' = excelContactAdd.public,
				'remarks' = result.remarks			

			}
	>
	<cfif arrayLen(result.errors) GT 0>
		<cfset arrayAppend(errorArray,excelRow)>
	<cfelse>
		<cfset arrayAppend(successArray,excelRow)>
	</cfif>
</cfloop> 

<cfinclude template = "excelResult.cfm">




