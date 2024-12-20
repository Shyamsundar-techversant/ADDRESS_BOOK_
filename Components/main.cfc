<cfcomponent>

	<!--- Hash Password  --->
	<cffunction name="hashPassword" access="private">
		<cfargument name="userPassword" type="string" required="true">
		<cfargument name="salt" type="string" required="true">
		<cfset local.saltedPass = arguments.userPassword & arguments.salt>
		<cfset local.hashedPass = hash(local.saltedPass,"SHA-256","UTF-8")>	
		<cfreturn local.hashedPass>
	</cffunction>

	<!--- FORM VALIDATION --->
	<cffunction name="validateForm" access="public" returntype="array">
		<cfargument name="fullName" type="string" required="true">
		<cfargument name="userEmail" type="string" required="true">
		<cfargument name="username" type="string" required="true">
		<cfargument name="password" type="string" required="true">
		<cfargument name="passwordConf" type="string" required="true">
		<cfset local.errors=[]>
		<!--- Validate fullname --->
		<cfif len(trim(arguments.fullName)) EQ 0>
			<cfset arrayAppend(local.errors,"*Fullname is required")>
		<cfelseif NOT reFindNoCase("^[A-Za-z]+(\s[A-Za-z]+)?$",arguments.fullName)>
			<cfset arrayAppend(local.errors,"*Enter a valid fullname")>
		</cfif>	
			
		<!--- Validate Email--->
		<cfif len(trim(arguments.userEmail)) EQ 0>
			<cfset arrayAppend(local.errors,"*Email is required")>
		<cfelseif NOT reFindNoCase("^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$",arguments.userEmail)>
			<cfset arrayAppend(local.errors,"*Enter a valid email")>
		</cfif>
			
		<!--- Validate Username--->
		<cfif len(trim(arguments.username)) EQ 0>
			<cfset arrayAppend(local.errors,"*Please enter the username")>
		<cfelseif NOT reFindNoCase("^[a-zA-Z_][a-zA-Z0-9_]{4,14}$",arguments.username)>
			<cfset arrayAppend(local.errors,"*Please enter a valid username")>
		</cfif>
			
		<!--- Validate Password --->
		<cfif len(trim(arguments.password)) EQ 0>
			<cfset arrayAppend(local.errors,"*Please enter the password")>
		<cfelseif NOT reFindNoCase("^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[@$!%*?&])[A-Za-z\d@$!%*?&]{8,}$",arguments.password)>
			<cfset arrayAppend(local.errors,"*Please enter a valid password")>
		</cfif>
			
		<!---Confirm Password Validation --->
		<cfif len(trim(arguments.passwordConf)) EQ 0>
			<cfset arrayAppend(local.errors,"*Password confirmation required")>
		<cfelseif arguments.passwordConf NEQ arguments.password>
			<cfset arrayAppend(local.errors,"*Password confirmation failed")>
		</cfif>
		<cfreturn local.errors>
	</cffunction>

	<!--- Register User--->
	<cffunction name="registerUser" access="public" returntype="string">
		<cfargument name="fullName" type="string" required="true">
		<cfargument name="emailId" type="string" required="true">
		<cfargument name="userName" type="string" required="true">
		<cfargument name="password" type="string" required="true">
		
		<cfset local.result="">
		
		<cftry>
			<cfquery name="local.registerUser" datasource="coldfusion">
				SELECT 	
					email,userName
				FROM 
					registeredUsers
				WHERE 
					email=<cfqueryparam value="#arguments.emailId#" cfsqltype="cf_sql_varchar">
				AND	
					userName = <cfqueryparam value="#arguments.userName#" cfsqltype="cf_sql_varchar">

			</cfquery>
			<cfif local.registerUser.recordCount GT 0>
				<cfset local.result="User Already Exist">
			<cfelse>
				<cfset local.salt = generateSecretKey('AES')>
				<cfset local.hashedPassword=hashPassword(arguments.password,local.salt)>
				<cfquery name="local.insertUser" datasource="coldfusion">
					INSERT INTO
							registeredUsers(
										fullName,
										email,
										userName,	
										password,
										salt
									)
					VALUES(
							<cfqueryparam value="#arguments.fullName#" cfsqltype="cf_sql_varchar">,
							<cfqueryparam value="#arguments.emailId#" cfsqltype="cf_sql_varchar">,
							<cfqueryparam value="#arguments.userName#" cfsqltype="cf_sql_varchar">,
							<cfqueryparam value="#local.hashedPassword#" cfsqltype="cf_sql_varchar">,
							<cfqueryparam value="#local.salt#" cfsqltype="cf_sql_varchar">
						)
				</cfquery>
				<cflocation url="logIn.cfm" addtoken="false"> 
			</cfif>
			<cfreturn local.result>
		<cfcatch>
			<cfdump var="#cfcatch#">
			<cfreturn local.result>
		</cfcatch>
		</cftry>
	</cffunction>

	<!--- LOGIN FORM --->
	<cffunction name="logUser" access="public" returntype="any">
		<cfargument name="userName" type="string" required="true">
		<cfargument name="password" type="string" required="true">		
		<cftry>
			<cfquery name="local.userLog" datasource="coldfusion">
				SELECT 
					userName,
					userId,
					password,
					salt
				FROM 
					registeredUsers
				WHERE 
					userName=<cfqueryparam value="#arguments.userName#" cfsqltype="cf_sql_varchar">					
			</cfquery>
			<cfif local.userLog.recordCount EQ 1>
				<cfset local.salt = local.userLog.salt>
				<cfset local.hashedPassword = hashPassword(arguments.password,local.salt)>
			
				<cfif local.hashedPassword EQ local.userLog.password>
					<cfset local.result="LogIn successful">
					<cfset session['username'] = arguments.username>
					<cfset session['userId'] = local.userLog.userId>
					<cflocation url="home.cfm" addtoken="false">
				<cfelse>
					<cfset local.result="Invalid data">
				</cfif>
			<cfelse>
				<cfset local.result="Invalid username or password">				
			</cfif>
			<cfreturn local.hashedPassword>
		<cfcatch>
			<cfdump var="#cfcatch#">
			<cfset local.result="#cfcatch.message#">
			<cfreturn local.result>
		</cfcatch>
		</cftry>
	</cffunction>

	<!--- GET TITLE--->
	<cffunction name="getTitle" access="public" returntype="query">
		<cftry>
			<cfquery name="local.titleValue" datasource="coldfusion">
				SELECT 
					id,
					titles
				FROM 	
					title
			</cfquery>
			<cfif local.titleValue.recordCount EQ 3>
				<cfreturn local.titleValue>
			</cfif>
		<cfcatch>
			<cfset local.result="#cfcatch.message#">
			<cfreturn local.result>
		</cfcatch>
		</cftry>	
	</cffunction>

	<!--- GET GENDER --->
	<cffunction name="getGender" access="public" returntype="query">
		<cftry>
			<cfquery name="local.genderValues" datasource="coldfusion">
				SELECT 
					id,
					gender_values
				FROM 
					gender
			</cfquery>
			<cfif local.genderValues.recordCount EQ 3>
				<cfreturn local.genderValues>
			</cfif>
		<cfcatch>
	
			<cfset local.result="#cfcatch.message#">
			<cfreturn local.result>
		</cfcatch>
		</cftry>
	</cffunction>

	<!--- GET HOBBIES --->
	<cffunction name="getHobbies" access="public" returntype="query">
		<cftry>
			<cfquery name="local.hobbyValues" datasource="coldfusion">
				SELECT 
					id,
					hobby_name
				FROM 
					hobbies
			</cfquery>
			<cfif local.hobbyValues.recordCount EQ 5>
				<cfreturn local.hobbyValues>
			</cfif>
		<cfcatch>
	
			<cfset local.result="#cfcatch.message#">
			<cfreturn local.result>
		</cfcatch>
		</cftry>
	</cffunction>


	<!--- VALIDATE CONTACT FORM--->
	<cffunction name="validateFormAndCreateOrUpdateUser" access="remote" returntype="any">
		<cfargument name="titleName" type="string" required = "false">
		<cfargument name="title" type="numeric" required="false">
		<cfargument name="firstname" type="string" required="true">
		<cfargument name="lastname" type="string" required="true">
		<cfargument name="genderName" type="string" required="false">
		<cfargument name="gender" type="string" required="false">
		<cfargument name="dob" type="string" required="true">
		<cfargument name="formFile" type="string" required="false">
		<cfargument name="email" type="string" required="true">
		<cfargument name="phone" type="string" required="true">
		<cfargument name="address" type="string" required="true">
		<cfargument name="street" type="string" required="true">
		<cfargument name="pincode" type="string" required="true">	
		<cfargument name="hobbies" type="string" required="false">
		<cfargument name="hobbieName"  type = "string" required="false">
		<cfargument name="id" type="string" required="false">
		<cfargument name="public" type="numeric" required="false">	
		<cfargument name="isExcel" type="numeric" required="false">

		<cfset local.errors=[]>	

		


		<!--- Title --->
		<cfset local.titleArr=[]>	
		<cfset local.titleValues=getTitle()>
		<cfloop query="local.titleValues">
			<cfset arrayAppend(local.titleArr,local.titleValues.id)>
		</cfloop>
		<cfif structKeyExists(arguments,"title")>
			<cfif NOT ArrayContains(local.titleArr,arguments.title)>
				<cfset arrayAppend(local.errors,"*Enter a valid title")>
			</cfif>
		</cfif>
		<cfif structKeyExists(arguments,"titleName")>
			<cfquery name="local.getTitleId" datasource="coldfusion">
				SELECT 
					id
				FROM
					title
				WHERE
					titles = <cfqueryparam value="#arguments.titleName#" cfsqltype="cf_sql_varchar">
			</cfquery>
			<cfif local.getTitleId.recordCount EQ 1>
				<cfset arguments.title = local.getTitleId.id>
			<cfelse>
				<cfset arrayAppend(local.errors,"*Invalid Title")>
			</cfif>
		</cfif>
		
		<!--- VALIDATE FIRSTNAME  --->	
		<cfif len(trim(arguments.firstname)) EQ 0>
			<cfset arrayAppend(local.errors,"*Firstname is required")>
		<cfelseif NOT reFindNoCase("^[A-Za-z]+(\s[A-Za-z]+)?$",arguments.firstname)>
			<cfset arrayAppend(local.errors,"*Enter a valid firstname")>
		</cfif>

		<!--- VALIDATE LASTNAME--->
		<cfif len(trim(arguments.lastname)) EQ 0>
			<cfset arrayAppend(local.errors,"*Lastname is required")>
		<cfelseif NOT reFindNoCase("^[A-Za-z]+(\s[A-Za-z]+)?$",arguments.lastname)>
			<cfset arrayAppend(local.errors,"*Enter a valid lastname")>
		</cfif>

		<!--- VALIDATE GENDER --->
		<cfset local.genderArr=[]>
		<cfset local.genderValues=getGender()>
		<cfloop query="local.genderValues">
			<cfset arrayAppend(local.genderArr,local.genderValues.id)>	
		</cfloop>
		<cfif structKeyExists(arguments,"gender")>
			<cfif NOT ArrayContains(local.genderArr,arguments.gender)>
				<cfset arrayAppend(local.errors,"*Please enter a valid gender")>
			</cfif> 
		</cfif>
		<cfif structKeyExists(arguments,"genderName")>
			<cfquery name="local.getGenderId" datasource="coldfusion">
				SELECT 
					id
				FROM
					gender
				WHERE
					gender_values = <cfqueryparam value="#arguments.genderName#" cfsqltype="cf_sql_varchar">
			</cfquery>
			<cfif local.getGenderId.recordCount EQ 1>
				<cfset arguments.gender = local.getGenderId.id>
			<cfelse>
				<cfset arrayAppend(local.errors,"*Invalid Gender")>
			</cfif>
		</cfif>		


		<!--- VALIDATE DOB --->
		<cfif len(arguments.dob) EQ 0>
			<cfset arrayAppend(local.errors,"*Please enter date of birth")>
		<cfelseif NOT IsDate(arguments.dob)>
			<cfset arrayAppend(local.errors,"*Please enter a valid date")>
		</cfif> 
		
		<!--- VALIDATE IMAGE --->		
		<cfset local.maxSize=5*1024*1024>
		<cfset local.allowedExtensions = "jpeg,jpg,png,gif">
		<cfset local.uploadedImage=structNew()>

		<cfif NOT structKeyExists(form,"uploadImg") OR arguments.formFile EQ "">
			<cfif NOT structKeyExists(arguments,"id") OR arguments.id EQ "">
				<cfif arguments.isExcel>
					<cfset arguments['uploadImg'] = "contactImage.png">	
				<cfelse>
					<cfset arrayAppend(local.errors,"* Photo is required")>
				</cfif>
			<cfelse>
				<cfset local.decryptedId=decrypt(arguments.id,application.encryptionKey,"AES","Hex")>
				<cfquery name="local.contactImage" datasource="coldfusion">
					SELECT 
						imagePath
					FROM 
						contacts
					WHERE
						id=<cfqueryparam value="#local.decryptedId#" cfsqltype="cf_sql_integer">
				</cfquery>					
				<cfset arguments['uploadImg'] = local.contactImage.imagePath>	
			</cfif>
		<cfelse>
			<cfset local.uploadDir=expandPath('./Uploads/')>

			<cfif NOT directoryExists(local.uploadDir)>
				<cfdirectory action="create" directory="#local.uploadDir#">
			</cfif>

			<cfif len(trim(arguments.formFile))>
				<cffile action="upload"
					fileField="form.uploadImg"
					destination="#application.imageSavePath#"
					nameconflict="makeunique"
					result="local.uploadedImage"					
				> 
			</cfif>

			<cfif local.uploadedImage.FILESIZE GT maxSize>
				<cfset arrayAppend(local.errors,"*Image size should be less than 5 MB")>
			</cfif>	

			<cfif NOT ListFindNoCase(local.allowedExtensions,"#local.uploadedImage.CLIENTFILEEXT#")>
				<cfset arrayAppend(local.errors,"*Image should be jpeg,png or gif format")>
			</cfif>

			<cfset local.imagePath=local.uploadedImage.SERVERFILE>
			<cfset arguments['uploadImg'] = local.imagePath>
		</cfif>
		<!--- VALIDATE EMAIL  --->
		<cfif structKeyExists(arguments,"isExcel")>
			<cfquery name="local.excelEmail" datasource="coldfusion">
				SELECT 
					id
				FROM 
					contacts
				WHERE 
					email=<cfqueryparam value="#arguments.email#" cfsqltype="cf_sql_varchar">
				AND
					userId = <cfqueryparam value="#session.userId#" cfsqltype="cf_sql_integer">				
			</cfquery>
			<cfif local.excelEmail.recordCount EQ 1>
				<cfset arguments['id'] = encrypt(
									local.excelEmail.id,
									application.encryptionKey,
									"AES",
									"Hex"
	
								) 
				>
			</cfif>		
		<cfelse>
			<cfquery name="local.contactEmail" datasource="coldfusion">
				SELECT 
					email
				FROM 
					contacts
				WHERE 
					email=<cfqueryparam value="#arguments.email#" cfsqltype="cf_sql_varchar">
				AND
					userId = <cfqueryparam value="#session.userId#" cfsqltype="cf_sql_integer">				
			</cfquery>
			<cfif NOT structKeyExists(arguments,"id")>
				<cfif local.contactEmail.recordCount GT 0>
					<cfset arrayAppend(local.errors,"*Contact with same email id already exists")>
				</cfif>
			</cfif>
		</cfif>
		<cfif len(trim(arguments.email)) EQ 0>
			<cfset arrayAppend(local.errors,"*Email is required")>
		<cfelseif NOT reFindNoCase("^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$",arguments.email)>
			<cfset arrayAppend(local.errors,"*Enter a valid email")>
		</cfif>
		


	
		<!--- VALIDATE PHONE--->
		<cfif len(trim(arguments.phone)) EQ 0>
			<cfset arrayAppend(local.errors,"*Phone number is required")>
		<cfelseif NOT reFindNoCase("^[6-9]\d{9}$",arguments.phone)>
			<cfset arrayAppend(local.errors,"*Enter a valid phone number")>
		</cfif>
		
		<!--- VALIDATE ADDRESS--->
		<cfif len(trim(arguments.address)) EQ 0>
			<cfset arrayAppend(local.errors,"*Address is required")>
		</cfif>
	
		<!--- VALIDATE STREET --->
		<cfif len(trim(arguments.street)) EQ 0>
			<cfset arrayAppend(local.errors,"*Street name is required")>
		</cfif>

		<!---VALIDATE PINCODE --->
		<cfif len(trim(arguments.pincode)) EQ 0>
			<cfset  arrayAppend(local.errors,"*Pincode is required")>
		<cfelseif NOT reFindNoCase("^[1-9][0-9]{5}$",arguments.pincode)>
			<cfset arrayAppend(local.errors,"*Enter a valid pincode")>
		</cfif> 

		<!--- VALIDATE HOBBIES --->
		<cfif  NOT structKeyExists(arguments,"hobbies")>
			<cfif structKeyExists(arguments,"hobbieName")>
				
				<cfset local.dbHobbies = getHobbies()>
				<cfset local.dbHobbyList = valueList(local.dbHobbies.hobby_name)>
				
				<cfset local.excelHobbyList = arguments.hobbieName>				
				<cfset local.invalidHobby = [] >
				<cfloop list="#local.excelHobbyList#" item="local.hobbyName">
					<cfif NOT  ListFindNoCase(local.dbHobbyList,local.hobbyName)>
						<cfset arrayAppend(local.invalidHobby,local.hobbyName)>
					</cfif>				
				</cfloop>
		
				<cfif arrayLen(local.invalidHobby) GT 0>
					<cfset arrayAppend(local.errors,"*Invalid Hobby")>
				<cfelse>

				</cfif>

				<cfquery name="local.getHobbyId" datasource="coldfusion">
					SELECT
						id
					FROM 
						hobbies
					WHERE
						hobby_name
					IN(<cfqueryparam value="#arguments.hobbieName#" cfsqltype="cf_sql_varchar" list="true">)
				</cfquery> 	
				<cfif local.getHobbyId.recordCount GT 0>
					<cfset arguments['hobbies'] = valueList(local.getHobbyId.id)>
				</cfif>	

			<cfelse>
				<cfset arrayAppend(local.errors,"*Hobbies required")>					
			</cfif>
		<cfelse>
			<cfset local.hobbyArr=[]>
			<cfset local.hobbyValues=getHobbies()>
			<cfloop query="local.hobbyValues">
				<cfset arrayAppend(local.hobbyArr,local.hobbyValues.id)>
			</cfloop>
			<cfset local.hobbyToValidate=ListToArray(arguments.hobbies,",")>
			<cfset local.hobbyFalse=0>
			<cfloop array="#local.hobbyToValidate#" index="value">
				<cfif NOT ArrayContains(local.hobbyArr,value)>
					<cfset local.hobbyFalse=1>
					<cfbreak>
				</cfif>
			</cfloop>
			<cfif hobbyFalse EQ 1>
				<cfset arrayAppend(local.errors,"*Enter a valid hobby")>
			</cfif>			
		</cfif>
		<!--- VALIDATE PUBLIC --->

		<cfset local.publicArr=[1,0]>
		<cfif NOT arrayContains(local.publicArr,arguments.public)>
			<cfset arrayAppend(local.errors,"*Can'nt change the value of public")>
		</cfif>
		
		

		<!--- ADD EDIT FUNCTION CALL   --->
		<cfset local.excelResult = {
					'errors':[],
					'remarks':""
					}
		> 
		<cfif arrayLen(local.errors) EQ 0>
			<cfset local.result = addEditContact(
						argumentCollection=arguments									
					)
			>
			<cfif NOT structKeyExists(arguments,"isExcel")>
				<cfreturn local.errors>
			<cfelse>
				<cfset local.excelResult.remarks = structKeyExists(arguments,"id")?"UPDATED" : "ADDED">
				<cfreturn local.excelResult>
			</cfif>
			
		<cfelse>
			<cfif NOT structKeyExists(arguments,"isExcel")>
				<cfreturn local.errors>
			<cfelse>
				<cfset local.excelResult.errors = local.errors>	
				<cfset local.excelResult.remarks = arrayToList(local.errors)>
				<cfreturn local.excelResult>
			</cfif>
		</cfif>
	</cffunction> 
	
	<!--- ADD EDIT CONTACT --->
	<cffunction name="addEditContact" access="public" returntype="string" returnformat="JSON">
		<cfargument name="title" type="string" required="true">
		<cfargument name="firstname" type="string" required="true">
		<cfargument name="lastname" type="string" required="true">
		<cfargument name="gender" type="string" required="true">
		<cfargument name="dob" type="date" required="true">
		<cfargument name="uploadImg" type="string" required="false">
		<cfargument name="email" type="string" required="true">
		<cfargument name="phone" type="string" required="true">
		<cfargument name="address" type="string" required="true">
		<cfargument name="street" type="string" required="true">
		<cfargument name="pincode" type="string" required="true">
		<cfargument name="hobbies" type="string" required="true">
		<cfargument name="id" type="string" required="false">
		<cfargument name="public" type="numeric" required="true">	
		
		<cftry>
			<cfif NOT structKeyExists(arguments,"id") OR arguments.id EQ "">
				<cfquery   datasource="coldfusion" result="local.contactAdd">
					INSERT INTO
						contacts(
							userId,
							titleId,
							firstName,
							lastName,
                        				genderId,
                        				dob,
                        				imagePath,
                        				address,
							street,
							pincode,
							email,
							phone,
							public
						)
					VALUES(
						<cfqueryparam value= #session.userId#  cfsqltype="cf_sql_integer">,
						<cfqueryparam value="#arguments.title#" cfsqltype="cf_sql_integer">,
						<cfqueryparam value="#arguments.firstname#" cfsqltype="cf_sql_varchar">,
						<cfqueryparam value="#arguments.lastname#" cfsqltype="cf_sql_varchar">,
						<cfqueryparam value="#arguments.gender#" cfsqltype="cf_sql_integer"> ,
						<cfqueryparam value="#arguments.dob#" cfsqltype="cf_sql_date">,
						<cfqueryparam value="#arguments.uploadImg#" cfsqltype="cf_sql_varchar">,
						<cfqueryparam value="#arguments.address#" cfsqltype="cf_sql_varchar">,
						<cfqueryparam value="#arguments.street#" cfsqltype="cf_sql_varchar">,
						<cfqueryparam value="#arguments.pincode#" cfsqltype="cf_sql_integer">,
						<cfqueryparam value="#arguments.email#" cfsqltype="cf_sql_varchar">,
						<cfqueryparam value="#arguments.phone#" cfsqltype="cf_sql_bigint">,
						<cfqueryparam value="#arguments.public#" cfsqltype="cf_sql_integer">
					)
				</cfquery>
				<cfset local.newId= local.contactAdd.GENERATEDKEY>
				<cfset local.hobbyArr=ListToArray(arguments.hobbies,",")>
				<cfloop array="#local.hobbyArr#" index="hobby_id">
					<cfquery datasource="coldfusion" result="local.contactHobbies">
						INSERT INTO contact_hobbies(
										contact_id,
										hobby_id
									)
						VALUES(
							<cfqueryparam value="#local.newId#" cfsqltype="cf_sql_integer">,
							<cfqueryparam value="#hobby_id#" cfsqltype="cf_sql_integer">
						)
					</cfquery>
				</cfloop>
				<cfset local.result="Success">
			<cfelse>	
				<cfset local.decryptedId=decrypt(arguments.id,application.encryptionKey,"AES","Hex")>
				<cfset local.hobbyArr=ListToArray(arguments.hobbies,",")>
		
				<!--- UPDATE CONTACTS --->	
				<cfquery name="local.editCont" datasource="coldfusion">
					UPDATE contacts
					SET 
						titleId=<cfqueryparam value="#arguments.title#" cfsqltype="cf_sql_integer">,
						firstName=<cfqueryparam value="#arguments.firstname#" cfsqltype="cf_sql_varchar">,
						lastName=<cfqueryparam value="#arguments.lastname#" cfsqltype="cf_sql_varchar">,
						genderId=<cfqueryparam value="#arguments.gender#" cfsqltype="cf_sql_varchar">,
						dob=<cfqueryparam value="#arguments.dob#" cfsqltype="cf_sql_date">,
						imagePath=<cfqueryparam value="#arguments.uploadImg#" cfsqltype="cf_sql_varchar">,
						address=<cfqueryparam value="#arguments.address#" cfsqltype="cf_sql_varchar">,
						street=<cfqueryparam value="#arguments.street#" cfsqltype="cf_sql_varchar">,
						pincode=<cfqueryparam value="#arguments.pincode#" cfsqltype="cf_sql_integer">,
						email=<cfqueryparam value="#arguments.email#" cfsqltype="cf_sql_varchar">,
						phone=<cfqueryparam value="#arguments.phone#" cfsqltype="cf_sql_bigint">,
						public=<cfqueryparam value="#arguments.public#" cfsqltype="cf_sql_integer">
					WHERE
						id=<cfqueryparam value="#local.decryptedId#" cfsqltype="cf_sql_integer">
					AND
						userId=<cfqueryparam value="#session.userId#" cfsqltype="cf_sql_integer">
				</cfquery>
				
				<!--- UPDATE CONTACT_HOBBIES --->
				<cfquery datasource="coldfusion" name="local.existingHobbies">
					SELECT
						hobby_id
					FROM 
						contact_hobbies
					WHERE 
						contact_id=<cfqueryparam value="#local.decryptedId#" cfsqltype="cf_sql_integer">
				</cfquery> 
				<cfset local.existingHobbiesArray=[]>
				<cfloop query="local.existingHobbies">
					<cfset arrayAppend(local.existingHobbiesArray,local.existingHobbies.hobby_id)>
				</cfloop>
				
				<cfset local.newHobbies=arguments.hobbies>
				<cfset local.newHobbiesArray=ListToArray(local.newHobbies,",")>
				<cfset local.newHobbiesToInsert = []>
				
				<cfloop array="#local.newHobbiesArray#" index="id">
					<cfif NOT ArrayFind(local.existingHobbiesArray,id)>
						<cfset arrayAppend(local.newHobbiesToInsert,id)>
					</cfif>
				</cfloop>

				<cfquery datasource="coldfusion" result="local.deleteContactHobbies">
					DELETE 
					FROM 
						contact_hobbies
					WHERE						
						hobby_id 
					NOT IN(<cfqueryparam value="#arguments.hobbies#" cfsqltype="cf_sql_varchar" list="true">)
					AND
						contact_id=<cfqueryparam value="#local.decryptedId#" cfsqltype="cf_sql_integer">	
				</cfquery>
			
				<cfif #arrayLen(local.newHobbiesToInsert)# GT 0 >
					<cfquery datasource="coldfusion" name="local.addNewHobbies">
						INSERT INTO
							contact_hobbies(
										contact_id,
										hobby_id
									)
						VALUES
							<cfloop array="#local.newHobbiesToInsert#" index = "local.i" item="local.hobby"  >
								(
									<cfqueryparam value="#local.decryptedId#" cfsqltype="cf_sql_integer">,
									<cfqueryparam value="#local.hobby#" cfsqltype="cf_sql_integer">
								)
								<cfif local.i LT #arrayLen(local.newHobbiesToInsert)#>
									,
								</cfif>
							</cfloop>;
					</cfquery>
				</cfif>							
			</cfif>
			<cfset local.result="Success">	
			<cfreturn local.result>	
 		<cfcatch>
			<cfset local.result="Failed">
			<cfdump var="#cfcatch#">
		</cfcatch>
		</cftry>	
			
	</cffunction>

	<!--- DELETE CONTACT --->

	<cffunction name="deleteCont" access="remote" returnformat="JSON">
		<cfargument name="id" type="string" required="true">
		<cfset local.decryptedId=decrypt(arguments.id,application.encryptionKey,"AES","Hex")>
		<cfset local.result="">
		<cftry>
			<cfquery datasource="coldfusion" result="delResult">
				DELETE	FROM 
					contacts
				WHERE
					id=<cfqueryparam value="#local.decryptedId#" cfsqltype="cf_sql_integer">	
				AND
					userId=<cfqueryparam value="#session.userId#" cfsqltype="cf_sql_integer">		
			</cfquery>
			<cfif delResult.recordCount GT 0>
				<cfset local.result="Success">			
			<cfelse>
				<cfset local.result="Failed">
			</cfif>
			<cfreturn local.result>
		<cfcatch>
			<cfoutput>#cfcath.message#</cfoutput>
		</cfcatch>
		</cftry>
	</cffunction>

	<!--- GET DATA BY ID --->
	<cffunction name="getDataById" access="remote" returntype="any" returnformat="JSON">	
		<cfargument name="id" type="string" required="false">
		<cfset local.decryptedId=decrypt(arguments.id,application.encryptionKey,"AES","Hex")>
		<cftry>
			<cfif structKeyExists(arguments,id) OR Len(arguments.id) GT 0>
				<cfquery name="local.getCont" datasource="coldfusion">
					SELECT 
						c.id,
						c.titleId,
						c.firstName,
						c.lastName,
                        			c.genderId,
                        			c.dob,
                        			c.imagePath,
                        			c.address,
						c.street,
						c.pincode,
						c.email,
						c.phone,
						c.public,
						t.titles,
						g.gender_values,
						GROUP_CONCAT(h.hobby_name) AS hobby_name, 
						GROUP_CONCAT(h.id) AS hobby_Id
					FROM 
						contacts c
					INNER JOIN 
						title t ON c.titleId=t.id
					INNER JOIN
						gender g ON c.genderId=g.id
					INNER JOIN
						contact_hobbies ch ON c.id=ch.contact_id
					INNER JOIN 
						hobbies h ON ch.hobby_id=h.id
					WHERE 
						c.id=<cfqueryparam value="#decryptedId#"  cfsqltype="cf_sql_integer">	
					AND
						userId=<cfqueryparam value="#session.userId#" cfsqltype="cf_sql_integer">
								
				</cfquery>
				<cfset local.idData = {
						
							'id'=local.getCont.id,
							'titleId' = local.getCont.titleId,
							'firstName' = local.getCont.firstName,
							'lastName' = local.getCont.lastName,
							'genderId' = local.getCont.genderId,
							'dob' = local.getCont.dob,
							'imagePath' = local.getCont.imagePath,
							'address' = local.getCont.address,
							'street' = local.getCont.street,
							'pincode' = local.getCont.pincode,
							'email' = local.getCont.email,
							'phone' = local.getCont.phone,
							'public' = local.getCont.public,
							'titles' = local.getCont.titles,
							'gender_values'= local.getCont.gender_values,
							'hobby_name' = local.getCont.hobby_name,
							'hobby_Id' = local.getCont.hobby_Id						
	
						}
				>
				<cfreturn local.idData>
			<cfelse>
			<!---	<cftry>
					<cfquery name="local.totalData" datasource="coldfusion">
						SELECT 
							c.id,
							c.userId,
							c.titleId,
							c.firstName,
							c.lastName,
                        				c.genderId,
                        				c.dob,
                        				c.imagePath,
                        				c.address,
							c.street,
							c.pincode,
							c.email,
							c.phone,
							c.public,
							t.titles,
							g.gender_values,
							GROUP_CONCAT(h.hobby_name) AS hobbies					
						FROM 
							contacts c
						INNER JOIN 
							title t ON c.titleId=t.id
						INNER JOIN
							gender g ON c.genderId=g.id
						INNER JOIN
							contact_hobbies ch ON c.id=ch.contact_id
						INNER JOIN 
							hobbies h ON ch.hobby_id=h.id
						WHERE
						userId=<cfqueryparam value="#session.userId#" cfsqltype="cf_sql_integer">
						OR 
						public=<cfqueryparam value="1" cfsqltype="cf_sql_integer">
						GROUP BY
						c.id
					</cfquery>	
					<cfreturn local.totalData>			
				<cfcatch>
					<cfdump var="#cfcatch#">
				</cfcatch>
				</cftry> --->


		

			</cfif>
		<cfcatch>
			<cfdump var="#cfcatch#">
		</cfcatch>
		</cftry>	

	</cffunction>












	<!--- GET ALL CONTACT --->
	<cffunction name="getData" access="remote" returntype="any" returnformat="JSON">
		<cfargument name="id" type="string" required="false" >
		<cfif structKeyExists(arguments,"id")>
			<cfset local.decryptedId=decrypt(arguments.id,application.encryptionKey,"AES","Hex")>
		</cfif>
		<cftry>
			<cfquery name="local.getCont" datasource="coldfusion">
				SELECT 
					c.id,
					<cfif NOT structKeyExists(arguments,"id")>
						c.userId,					
					</cfif>
					c.titleId,
					c.firstName,
					c.lastName,
                        		c.genderId,
                        		c.dob,
                        		c.imagePath,
                        		c.address,
					c.street,
					c.pincode,
					c.email,
					c.phone,
					c.public,
					t.titles,
					g.gender_values,
					GROUP_CONCAT(h.hobby_name) AS hobby_name, 
					GROUP_CONCAT(h.id) AS hobby_Id
				FROM 
					contacts c
				INNER JOIN 
					title t ON c.titleId=t.id
				INNER JOIN
					gender g ON c.genderId=g.id
				INNER JOIN
					contact_hobbies ch ON c.id=ch.contact_id
				INNER JOIN 
					hobbies h ON ch.hobby_id=h.id
				<cfif structKeyExists(arguments,"id")>
					WHERE 
						c.id=<cfqueryparam value="#decryptedId#"  cfsqltype="cf_sql_integer">
				<cfelse>
					WHERE
						(	userId=<cfqueryparam value="#session.userId#" cfsqltype="cf_sql_integer">
								OR 
							public=<cfqueryparam value="1" cfsqltype="cf_sql_integer">
						)
					GROUP BY
						c.id
				</cfif>						
			</cfquery>
				
			<cfif NOT structKeyExists (arguments,"id")>
				<cfreturn local.getCont>
			<cfelse>
				<cfset local.idData = {
						
							'id'=local.getCont.id,
							'titleId' = local.getCont.titleId,
							'firstName' = local.getCont.firstName,
							'lastName' = local.getCont.lastName,
							'genderId' = local.getCont.genderId,
							'dob' = local.getCont.dob,
							'imagePath' = local.getCont.imagePath,
							'address' = local.getCont.address,
							'street' = local.getCont.street,
							'pincode' = local.getCont.pincode,
							'email' = local.getCont.email,
							'phone' = local.getCont.phone,
							'public' = local.getCont.public,
							'titles' = local.getCont.titles,
							'gender_values'= local.getCont.gender_values,
							'hobby_name' = local.getCont.hobby_name,
							'hobby_Id' = local.getCont.hobby_Id						
	
						}
				>
				<cfreturn local.idData>
			</cfif> 		
		<cfcatch>
			<cfdump var="#cfcatch#">
		</cfcatch>
		</cftry>
	</cffunction>







	<!--- GET ALL CONTACT --->
	<cffunction name="getDatas" access="remote" returntype="any" returnformat="JSON">
		<cfargument name="id" type="string" required="false" >
		<cftry>
			<cfif structKeyExists(arguments,"id") >
				<cfset local.decryptedId=decrypt(arguments.id,application.encryptionKey,"AES","Hex")>
				<cfquery name="local.getCont" datasource="coldfusion">
					SELECT 
						c.id,
						c.titleId,
						c.firstName,
						c.lastName,
                        			c.genderId,
                        			c.dob,
                        			c.imagePath,
                        			c.address,
						c.street,
						c.pincode,
						c.email,
						c.phone,
						c.public,
						t.titles,
						g.gender_values,
						GROUP_CONCAT(h.hobby_name) AS hobby_name, 
						GROUP_CONCAT(h.id) AS hobby_Id
					FROM 
						contacts c
					INNER JOIN 
						title t ON c.titleId=t.id
					INNER JOIN
						gender g ON c.genderId=g.id
					INNER JOIN
						contact_hobbies ch ON c.id=ch.contact_id
					INNER JOIN 
						hobbies h ON ch.hobby_id=h.id
					WHERE 
						c.id=<cfqueryparam value="#decryptedId#"  cfsqltype="cf_sql_integer">						
				</cfquery>
				<cfset local.idData = {
						
							'id'=local.getCont.id,
							'titleId' = local.getCont.titleId,
							'firstName' = local.getCont.firstName,
							'lastName' = local.getCont.lastName,
							'genderId' = local.getCont.genderId,
							'dob' = local.getCont.dob,
							'imagePath' = local.getCont.imagePath,
							'address' = local.getCont.address,
							'street' = local.getCont.street,
							'pincode' = local.getCont.pincode,
							'email' = local.getCont.email,
							'phone' = local.getCont.phone,
							'public' = local.getCont.public,
							'titles' = local.getCont.titles,
							'gender_values'= local.getCont.gender_values,
							'hobby_name' = local.getCont.hobby_name,
							'hobby_Id' = local.getCont.hobby_Id						
	
						}
				>
				<cfreturn local.idData>
			<cfelse>
				<cfquery name="local.totalData" datasource="coldfusion">
					SELECT 
						c.id,
						c.userId,
						c.titleId,
						c.firstName,
						c.lastName,
                        			c.genderId,
                        			c.dob,
                        			c.imagePath,
                        			c.address,
						c.street,
						c.pincode,
						c.email,
						c.phone,
						c.public,
						t.titles,
						g.gender_values,
						GROUP_CONCAT(h.hobby_name) AS hobbies					
					FROM 
						contacts c
					INNER JOIN 
						title t ON c.titleId=t.id
					INNER JOIN
						gender g ON c.genderId=g.id
					INNER JOIN
						contact_hobbies ch ON c.id=ch.contact_id
					INNER JOIN 
						hobbies h ON ch.hobby_id=h.id
					WHERE
						userId=<cfqueryparam value="#session.userId#" cfsqltype="cf_sql_integer">
					OR 
						public=<cfqueryparam value="1" cfsqltype="cf_sql_integer">
					GROUP BY
						c.id
				</cfquery>	
				<cfreturn local.totalData>
			</cfif>			
		<cfcatch>
			<cfdump var="#cfcatch#">
		</cfcatch>
		</cftry>
	</cffunction>
</cfcomponent>


