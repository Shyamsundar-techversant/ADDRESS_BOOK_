<cfif structKeyExists(url,"filename")>
	<cfset destinationPath = expandPath('./download/') & #url.filename#> 
	<cfif fileExists(destinationPath)>
		<cfset header = "Content-Disposition: attachment; filename=result.xlsx">
		<cfheader name="Content-Type" value="application/vnd.openxmlformats-officedocument.spreadsheetml.sheet">
		<cfcontent file="#destinationPath#" deleteFile="true">
	<cfelse>
		<cflocation url = "home.cfm" addtoken="no">
	</cfif>

</cfif>


