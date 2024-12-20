
<cftry>
    <cfset variables.fileName="contactData.pdf">
    <cfset contactList = application.dbObj.getData()>
    
    <!--- Generate PDF content --->
    <cfdocument format="PDF" orientation="portrait">
        <cfheader name="Content-Disposition" value="attachment; filename=#variables.fileName#">
        <h1 style="text-align: center;">Address Book</h1>
        <table border="1" cellpadding="5" cellspacing="0">  
            <thead>
                <tr>
                    <th>Name</th>
                    <th>Email</th>
                    <th>Phone</th>
                    <th>Hobbies</th>
                </tr>
            </thead>
            <tbody>
                <cfoutput query="contactList">
                    <tr>
                        <td>#contactList.FIRSTNAME# #contactList.LASTNAME#</td>
                        <td>#contactList.email#</td>
                        <td>#contactList.phone#</td>
                        <td>
                            <cfloop list="#contactList.hobby_name#" index="hobby">
                                #hobby#,
                            </cfloop>
                        </td>
                    </tr>
                </cfoutput>
            </tbody>
        </table>
    </cfdocument>
    
<cfcatch>
    <cfdump var="#cfcatch#">
</cfcatch>
</cftry>
